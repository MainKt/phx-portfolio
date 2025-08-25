The last few days have been the most intense and fun period of my GSoC. 
I finally got to descend into the FreeBSD kernel (^-.- ^)↝,
hacking around `rtnetlink(4)`.
I somehow ended up breaking the CI due to my commit (╥﹏╥). 
I implemented some new Netlink-based helpers to `libifconfig`.
Also, `wutui(8)`, my WiFi utility TUI,
can finally render in small terminal windows and I fixed another issue
that had slipped past my weak eyes: the scan requests being ignored when 
the device is connected to an access point
(I hate you `wpa_supplicant(8)` (╥﹏╥)).

## Netlink and Family
Netlink is a message-based communication protocol between the 
user-space and various kernel subsystems.
It can be used to query and perform configurations
on the kernel networking stack similar to the `ioctl(2)` syscall, but unlike
`ioctl(2)`, it's easily extensible and provides event
notification groups that the userspace can subscribe to.
Netlink has two family branches, `NETLINK_ROUTE` aka `rtnetlink(4)` and
`NETLINK_GENERIC` aka `gennetlink(4)`. The `NETLINK_ROUTE` family is used for
interface (link) related configurations and usually has message types that have
an action component (`GET`, `NEW`, `DEL`, `SET`) and an object component
(`LINK`, `ADDR`, `ROUTE`, `NEIGH`, etc) on which the action is being performed, 
for example, `RTM_GETLINK`, `RTM_NEWLINK` and `RTM_DELLINK` are used for
dumping information, creating/modifying and destroying
virtual interfaces (links) respectively. Each message starts with a header
struct (`ifinfomsg` for `RTM_*LINK`, `ifaddrmsg`
for `RTM_*ADDR`, etc) with header fields followed by 
TLV (Type, Length, Value) attributes. 

The `NETLINK_GENERIC` family is a
"container" family under which the kernel subsystems can register a family
with their own custom commands and attributes. It's used to provide Netlink
interface over subsystems like WiFi, for example, The `nl80211` family on Linux.
You can use the `genl(1)` CLI to list the available `genetilink(4)` families
on your FreeBSD.

On FreeBSD, we also have `snl(3)`, a helper library for Netlink which helps us
craft and receive messages and easy parsing of messages. It internally uses 
a linear allocator (also called arenas) for the `snl_state`'s memory management.

## The `IFF_UP` flag
As mentioned in my previous [blog](/writings/wutil-organ-transplants), The
messages that modify the `IFF_UP` flag  of an interface via `RTM_NEWLINK` though
they succeed, don't actually do anything. My mentor, Aymeric, recommended me to
read the kernel source code for how the flag is being handled. It felt
scary at first (ᵕ,,¬﹏¬,,) but I used grep and ripped through freebsd-src to
pinpoint the modify_link handler,
[`_nl_modify_ifp_generic`](https://cgit.freebsd.org/src/tree/sys/netlink/route/iface_drivers.c#n66)
for `RTM_NEWLINK`. 
Turns out the handler was only requesting `if_down(9)` on change requests
with `IFF_UP` flag.
```c
if ((lattrs->ifi_change & IFF_UP) && (lattrs->ifi_flags & IFF_UP) == 0) {
    /* Request to down the interface */
    if_down(ifp);
}

```
I submitted a [revision](https://reviews.freebsd.org/D51871)
to fix this. As it happens, This fix had
existed out of tree in Aymeric's [`BATMAN` tree](https://github.com/obiwac/freebsd-gsoc/commit/d4d25ba2bbbfe9c4517b299892fec29131351a13)
long before ('o').

## Linux's `ifi_change` Bug
As per [`rtnetlink(7)`](https://man7.org/linux/man-pages/man7/rtnetlink.7.html)
manpage on Linux,
```
ifi_change is reserved for future use and should be always set to 0xFFFFFFFF
```
But in reality, the penguin kernel does look at `ifi_change` when modifying
the link's `ifi_flags`. The modify_link handler in FreeBSD also checked for
`ifi_change` before modifying `ifi_flags` but with one catch it assumed
`ifi_change == 0` to mean no change in flags whereas in Linux `ifi_change == 0`
is treated as  `ifi_change == 0xFFFFFFFF` for bugwards compatibility. We decided
to pick up this bug compatibility on FreeBSD too so I updated my patch to
account for this assumption on the `IFF_UP` and `IFF_PROMISC` 
flags. Everything worked fine and the changes got merged. It was my first commit
into `freebsd-src` (◕ᴗ◕✿). But I did a grave sin of not running
the `tests/sys/netlink` kyua tests :').

## `IFF_PROMISC` and The Broken CI
Our assumption of `ifi_change == 0` being same as
`ifi_change == 0xFFFFFFFF` was causing a test case in
`tests/sys/netlink/test_rtnl_iface` to kernel panic and broke the CI (╥﹏╥). 
The cause was the creation of a
`lo` interface with all unset `ifi_flags` i.e its `IFF_PROMISC` was being 
requested to be set to 0 on creation. The way we were handling promiscuity in 
our modify_handler was through `ifpromisc(9)`. As per `ifpromisc(9)`,
```
int ifpromisc(if_t ifp, int pswitch);

Add or remove a promiscuous reference to ifp.  If pswitch is true, add a
reference; if it is false, remove a reference.  On reference count transitions
from zero to one and one to zero, set the IFF_PROMISC flag appropriately and
call if_ioctl() to set up the interface in the desired mode.
```
So basically, it increments the reference count of `IFF_PROMISC` (number of
listeners to promiscuity) when `pswitch == 1` and decrements it when
`pswitch == 0` but the reference count can never be decremented below zero and
that'd cause a `KASSERT` failure in
[`if_setflag()`](https://cgit.freebsd.org/src/tree/sys/net/if.c#3239).
The reference count of the
newly created `lo` interface's promiscuity is zero and since `ifi_change == 0`,
the handler would call `ifpromisc(ifp, 0)` to unset the promiscuity making
its reference count decrement from zero leading to a kernel panic. My initial
approach was to ignore any changes to `IFF_PROMISC` inside `ifpromisc(9)`
when the interface's promiscuity reference count was zero, you can find the
[patch here](https://reviews.freebsd.org/D52047), but the problem is this would
cause any call to the modify_handler to decrement the promiscuity. Though it
won't go beyond zero it'll make the current reference count to be less than
the number of actual listeners to promiscuity. Aymeric pointed out that this
wasn't the right way to do promiscuity in Netlink and we hadda do something
similar to Linux. For Netlink in Linux the 
promiscuity refcounting is only modified when there's an
actual `IFF_PROMISC` transition in `dev->gflags`,
which I believe is for tracking permanent (user-requested) `IFF_PROMISC`
and permanent `IFF_ALLMULTI` flags, i.e, only modify when the current
`dev->gflags` and the requested flags were different but the refcounting
is bypassed when there's no transition.
This is similar to how we handle `IFF_PPROMISC`
(note the extra 'P' (ᵕ—ᴗ—)) in FreeBSD's [`SIOCSIFFLAGS`](https://cgit.freebsd.org/src/tree/sys/net/if.c#2592)
. Aymeric submitted a [fix](https://reviews.freebsd.org/D52056)
by refactoring the permanent promiscuity handling in `SIOCSIFFLAGS` so that when
requesting to set `IFF_PROMISC` with Netlink, 
permanent promiscuity `IFF_PPROMISC` is set instead. I also got to do my first
code review (◍•ᴗ•◍).

After this fix, I submitted `libifconfig` helpers to bring an interface up 
and down by setting `IFF_UP` via `RTM_NEWLINK`,
[D52131](https://reviews.freebsd.org/D52128).

## Setting The Link-Layer Address with `RTM_NEWLINK`
I submitted a [review](https://reviews.freebsd.org/D51922) to add `IFLA_ADDRESS` 
support to `RTM_NEWLINK`. The link layer address can be set using `RTM_NEWLINK`
message, by attaching an attribute of type `IFLA_ADDRESS` with an address buffer
as its value along with the buffer length. I used this to implement a helper in
`libifconfig` to set the MAC address of an interface. I also added a helper to
retrieve the MAC address using `RTM_GETLINK`. The `libifconfig` changes can be
found [here](https://reviews.freebsd.org/D52130).

## Adding and Removing IPv4/IPv6 Addresses
FreeBSD supports many `RTM_*ADDR` messages (even though it says "Not Supported"
in `sys/netlink/route/common.h` (ᵕ—ᴗ—)).
We can make use of `RTM_NEWADDR` and `RTM_DELADDR` messages 
to add or remove an IPv4/IPv6 address on a link.
This was being done in `ifconfig(8)`.
Using it as a reference I extracted the following helpers into
`libifconfig`: `ifconfig_add_inet()` to add an IPv4 address,
`ifconfig_del_inet()` to remove an IPv4 address,
`ifconfig_add_inet6()` to add an IPv6 address, and
`ifconfig_del_inet6()` to remove an IPv6 address.
The changes can be found
[here](https://reviews.freebsd.org/D52131).

## So Where's `wutil`?
Everyone asks "Where's `wutil`" but nobody asks "How's `wutil`" :( /s.

I have submitted a [patch](https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=288933)
to `security/wpa_supplicant` port to build
`libwpa_client` and also a [patch](https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=289079)
for `sysutils/wutil`. After `libwpa_client` is available in
`security/wpa_supplicant`, the `sysutils/wutil` port can be merged.
You can try it out by manually applying both the patches.

## So How's `wutil`?
`wutui(8)` can now shrink when the terminal window gets smaller but I realized
shrinking forever can make the TUI illegible on too small screens because 
the text gets clipped off like in `impala`, the `iwd` TUI on Linux.
`NetworkManager`'s `nmtui` doesn't care about resizing at all (ᵕ—ᴗ—). Instead,
I thought of allowing vertical shrinking to a reasonable amount and when there's
a lot of horizontal decrease in window dimensions, you get a horizontal
scrollbar which can be used to scroll left and right.

I have updated the manpage for `wutil(8)` with the revamped CLI commands and
options. Also, added a new manpage for `wutui(8)` describing all the
keybindings.

There's this weird behaviour with `wpa_supplicant(8)`, when you request a scan
while being connected to an access point, it wouldn't trigger any actual scan
and instead use the last scan cache. I looked into its code and found out it
was due to  `IEEE80211_IOC_SCAN_CHECK` flag being set on
`struct ieee80211_scan_req` for `IEEE80211_IOC_SCAN_REQ` `ioctl`s. In order to
avoid this behaviour, you have to enable the `passive_scan` option before
requesting a scan on the `wpa_supplicant(8)` control interface. In `wutil(8)`
and `wutui(8)`, we temporarily enable `passive_scan` on explicit user scan
requests, such as `$ wutil scan` and the `s` TUI keybinding.
This fixed the issue of scan requests being ignored.

## What's next?
GSoC will end in a week (╥﹏╥), it has been a great journey and I got to learn
and do a lot of things I never thought I'd be able to.
Thank you very much Getz and Aymeric (╥﹏╥).
I'll keep contributing to FreeBSD though (˶ᵔ ᵕ ᵔ˶).

In the future, I'd like to get rid of `wpa_supplicant(8)` completely and
roll our own WiFI auth if feasible or at least extract
the auth part from `wpa_supplicant(8)`.
`wpa_supplicant(8)` is just too weird and
its control interface commands are not documented properly.
I also want to hack around with getting `nl80211` on FreeBSD to
port `iw` and `iwd` for fun.
