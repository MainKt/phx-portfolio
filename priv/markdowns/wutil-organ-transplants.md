## In the beginning
During the GSoC proposal period,
I created [`wutil`](https://github.com/MainKt/wutil),
a WiFi and network management utility,
along the lines of GhostBSD's `NetworkMgr`.
`NetworkMgr` is a Python GTK3 network manager for FreeBSD and derived OSs, very
similar in functionality to `NetworkManager` applet on linux.
`wutil` was very much like a CLI form of NetworkMgr. You could
list/enable/disable interfaces, scan and connect/disconnect from WiFi networks,
and also configure IP/netmask, gateway, dns servers, and search domain very much
like `NetworkMgr`.

Though `wutil` is in C, I initially followed `NetworkMgr`'s
way of directly calling `ifconfig(8)`, `wpa_supplicant(8)`, `service(8)`
(to start/stop/restart services like `dhclient(8)`, `netif`, `routing`), etc with
`system(3)` (`system(3)` is not secure and is bad practice (╥﹏╥)),
and also manually editing `wpa_supplicant.conf(5)` for network configuration,
`rc.conf(5)` with `sysrc(8)` calls for IP/netmask/gateway,
and `resolv.conf` for DNS nameservers. This version of wutil is available
in [`v0.0.1`](https://github.com/MainKt/wutil/tree/v0.0.1) tag.

## So what's different now?
I went on a spree to get rid of all the `system(3)` calls to external programs
and implement all the beforementioned functionality in just C with 
libraries like `libifconfig`, `lib80211` and `libwpa_client` ( ◡̀_◡́)ᕤ.

### `net/libifconfig` port
I made a port for the internal library `libifconfig`, a FreeBSD internal library
that provides programmatic access to the functionality offered by ifconfig(8).
I used `net/libpfctl` port as a reference, which is also an internal library.
Currently, `libifconfig` can't be made public,
as its interface isn't stable and making it public would require
guaranteeing a stable ABI. I plan to link libifconfig from this port,
when creating a port for `wutil`.

### Retrieving Network Interface Details
I moved to using `libifconfig`'s helpers `ifconfig_foreach_iface(...)`,
`ifconfig_foreach_ifaddr(...)`, `ifconfig_media_get_mediareq(...)`, 
`ifconfig_media_get_status(...)` to retrieve interface details. Before, I used
to `popen(3)` on `ifconfig(8)` to get these information (╥﹏╥).
`ifconfig_foreach_ifaddr(...)` and `ifconfig_foreach_ifaddr(...)` are actually
just a wrapper around `getifaddrs(3)`. Not really a fan of `ifconfig_foreach_*`
callback functions though (ᵕ—ᴗ—).

### Enabling/Disabling Network Interfaces.
`NetworkMgr` and even `wutil` used to directly call `ifconfig IFACE [up|down]`
to toggle interface state. I tried to use `rtnetlink(4)` with `RTM_GETLINK`
and `RTM_NEWLINK` to get and flip the `IFF_UP` flag of the interface,
but the netlink message would succeed and nothing would change in the interface
(it even froze my PC when I tried to send a message with `ifi_change` set (╥﹏╥)).
So, for now I went with `SIOCGIFFLAGS` and `SIOCSIFFLAGS` `ioctl`s to get and
set the `IFF_UP` flag. This is the only network related part that uses `ioctl`
currently. I gotta figure out how to properly do it with
`rtnetlink(4)` and extract this as a helper in `libifconfig`.

### Scanning for WiFi networks
I used to directly scan and parse results from `ifconfig IFACE scan`. I briefly
switched to `lib80211`, a helper library for IEEE 802.11 related `ioctl`s
(`net80211(4)`), to perform scan with `IEEE80211_IOC_SCAN_REQ`
and retrieve the results with `IEEE80211_IOC_SCAN_RESULTS`. Parsing
`struct ieee80211req_scan_result` and other scan result fields was very fun but
parsing IEs (Information Elements) to get the security related information was
very painful (ᵕ—ᴗ—). So, I dropped `lib80211` for `libwpa_client`'s
`SCAN` and `SCAN_RESULTS` commands, which also give the security and network
capabilities.
I manually wait for the `WPA_EVENT_SCAN_RESULTS` event
on the `wpa_supplicant(8)`s ctrl_interface socket
with a timeout for the scan to complete with `kqueue(2)`.

### Connecting/Disconnecting from WiFi networks
I fully switched to `libwpa_client` to connect/disconnect and configure key_mgmt
on WiFi networks. Before I used to manually edit the `wpa_supplicant.conf` but
now I use `SAVE_CONFIG` command (with `update_config=1`) on `wpa_supplicant`'s
ctrl_interface, which makes `wpa_supplicant` update the config nicely 
on its own. The user needs to be in the `wheel` group
by default to use ctrl_interface commands.

### Configuring Network Interfaces
I switched to using `rtnetlink(4)`'s `RTM_NEWADDR` to configure IP/netmask
and `RTM_NEWROUTE` for changing the default gateway. It's very easy to
create and send netlink messages with `snl(3)`. Though
`sys/netlink/route/common.h` says "not supported" for `RTM_NEWADDR`,
it works fine (˶˃ ᵕ ˂˶). I gotta move these
too as helper into `libifconfig`. I'm considering removing network
configurations altogether from wutil as it's already done by `ifconfig(8)` 
(configuring IP/netmask, MAC etc), `route(8)` (setting gateway),
and `resolv.conf` (configuring DNS servers) in order for `wutil` to
only handle WiFi related functions similar to `iwctl` (´-﹏-\`；).

### Switching to `bsdmake`
I was also using [`xmake-io`](https://xmake.io/) before,
my favorite C/C++ build tool, for `wutil`. Cuz it's very nice to generate
`compile_commands.json` for LSPs (with all cool warning flags
`-Wall -Wextra -Wpedantic -Wshadow -Wunused -g` and sanitizers (˵ ¬ᴗ¬˵)),
managing libraries, and compiling multiple binaries, and can also generate
GNUMakefile etc with `xmake`.
But after digging through `freebsd-src/`, I found `bsd.prog.mk`, which base
system binaries use and there's also `bsd.progs.mk` when generating multiple
binaries. I completely switched to `bsd.progs.mk` and used `bear(1)` to 
generate `compile_commands.json` with `WARNS=4` and `CFLAGS`/`LDFLAGS` to set
include paths and sanitizers.

I also got rid of all the string utility functions I had for parsing outputs of
shell commands. Even removed lots of code that became redundant with switch from
shell calling other programs.

## What's next?
`wutil` currently has build dependency on `libwpa_client` library which has to
be made available in `security/wpa_supplicant` port. I have a 
[modified port](https://github.com/MainKt/freebsd-ports/blob/libwpa/security/wpa_supplicant/Makefile)
of `security/wpa_supplicant` that builds `libwpa_client`, but it doesn't have a
SONAME which causes linking issues when porting `wutil`.
The `wutil` CLI is kinda cluttery and could be made much cleaner.
I plan to add commands to list and forget known WiFi networks too.
Also, gotta extract the network interface related helpers into `libifconfig`.
I'll start working on the uncooked TUI in the upcoming weeks (˶ᵔ ᵕ ᵔ˶).
