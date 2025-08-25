During the last few weeks, I have been working on the TUI of 
[`wutil`](https://github.com/MainKt/wutil), a WiFi utility
for FreeBSD. `wutil`, the CLI supports most station mode operations like 
scanning, connecting, disconnecting WiFi Access Points, 
managing known networks, automatic wpa_supplicant config update etc. The TUI,
which was built as a proof-of-concept for my GSoC proposal along the lines of 
[The Basics of "Uncooked" Terminal IO](https://zig.news/lhp/want-to-create-a-tui-application-the-basics-of-uncooked-terminal-io-17gm),
though pretty could only display scan results and 
network interfaces info. So it was finally time to make all `wutil`
functionalities available in the TUI, `wutui` (It sounds better when pronounced 
*What-You-I* IMHO („ᵕᴗᵕ„)),

## Getting the Terminal Raw
So normally a terminal is in a cooked state and does all the nice output and
input processing on every read and write on the tty,
like `CTRL-C` and `CTRL-Z` keybindings send a `SIGINT` and a `SIGTSTP` 
respectively,
carefully waiting for an ENTER key to read a line etc. But when building a TUI,
they must be disabled, we rather want a raw fresh uncooked tty,
which we can cook ourselves (no pun intended). We can do this by fetching and
modifying the `termios` attributes of the tty. There's
[`cfmakeraw(...)`](https://man.freebsd.org/cgi/man.cgi?tcsetattr) in `termios.h`
but it sets `VMIN` control character to 1 which blocks till a single byte is 
available to for the read syscall. We must set it to 0, so that reads are
non-blocking and can poll the tty with other file descriptors. 

We also draw the UI in an alternate buffer so that the user's previous shell
screen isn't lost.

## Some Warm-Up
I wasn't very comfortable with event handling and rendering complex UIs with 
just control sequences so I tried [implementing](https://github.com/MainKt/kilo)
antirez's 1000 LOC TUI editor,
[`kilo`](https://github.com/antirez/kilo). It uses uncooked terminal IO and
control sequence spells. I learned a bunch of cool tricks like how to implement
scrolling, proper input handling and buffering the output to prevent flickering.

## The Kernel as an Alarm Clock for our File Descriptors
We have to listen to a bunch of event sources in our TUI, majorly the tty for
reading input when available, wpa_supplicant's ctrl interface socket for
the supplicant's events, SIGWINCH when there's a change in the terminal window's
dimensions, and also some sort of periodic timers to remind us to start a 
background scan etc. One way to do it is to have a blocking queue for the events
in the main thread and listen to each event source and push the events to the
queue in listener threads. [`libvaxis`](https://github.com/rockorager/libvaxis/blob/main/src/queue.zig),
the Zig TUI library does this. But it would be way less tedious if our program 
could just sleep when there's no event and wake up only when necessary,
saving ourselves some CPU cycles. There's [`poll(2)`](https://man.freebsd.org/cgi/man.cgi?poll),
but we gotta pass the whole list of file descriptors every call. But fret not,
on FreeBSD we have `kqueue(2)`, which lets us register events with the kernel
and let it keep track of them. It also lets us listen to signals and 
create custom timers. Perfect for our event loop.

## The `wutui` Recipe
So the TUI architecture is quite simple,
```
have an initial state
|> render the UI with that state
|> listen for events in an event loop
|> cause state change on events 
|> render the UI with that state
|> ... *goes all over again* ...
```
The `wutui` struct holds all the resources 
(tty, wpa_supplicant, kq file descriptors etc) 
and keeps track of the UI states (current section, scan results, 
known networks, currently selected network, terminal window dimensions etc),
it's initialized at program startup in the main function and deinitialized
[`atexit(3)`](https://man.freebsd.org/cgi/man.cgi?atexit). 

The event loop is a
kqueue wait loop which renders the current UI and waits for an event to occur.
The event identifiers and their respective handlers are stored in the state 
struct too, this lets us swap out the handlers on an identifier for a 
specific scenario. Like for example when reading password for a WPA-PSK network 
in the input dialog box, we want the status and scan results to still be 
updating live in the background. 
So, we can launch a sub event loop with a modified handler for handling 
input on the tty file descriptor avoiding the TUI keybindings till 
the user completes entering the password. 

The
wpa_supplicant ctrl interface handler updates the scan results and
known networks on appropriate wpa_supplicant messages and also pushes the 
message as a notification which gets rendered as a toast notification 
in the UI. SIGWINCH is also handled by the kqueue event loop,
it's event handler sets updates the window dimension values allowing
us to resize on the next render. We also have timers for performing a periodic 
background scan and periodically cleaning up the older toast notifications. 
The older toast notification text is word wrapped.

We also do all the writes in a 
[`sbuf(9)`](https://man.freebsd.org/cgi/man.cgi?sbuf) buffer and do a single
write on the tty to avoid screen flickering. `sbuf` is a dynamic string buffer
library in FreeBSD base.

## The TUI
You can get a quick cheat sheet of the available keybindings by pressing 'h'
in the TUI. All the CLI functionality is available in the TUI and you get live
feedback on many events.
You can also do a HOME, END, PAGE_UP and PAGE_DOWN.

Initially scan results and known-networks were internally represented as
[`TAILQ`'s](https://man.freebsd.org/cgi/man.cgi?queue) but it was somewhat messy 
to jump to a specific entry (as we always have to loop to that entry) 
or do scrolling so we switched to a dynamic array.

## Changes to the CLI
The CLI design has been fully revamped,
```
$ ./wutil help
Usage:  wutil {subcommand [args...]}
        wutil help
        wutil interfaces
        wutil interface <interface>
        wutil [-c <wpa-ctrl-path>] known-networks
        wutil [-c <wpa-ctrl-path>] {known-network | forget} <ssid>
        wutil [-c <wpa-ctrl-path>] set
          [-p <priority>] [--autoconnect {y | n}] <ssid>
        wutil [-c <wpa-ctrl-path>] {scan | networks | status | disconnect}
        wutil [-c <wpa-ctrl-path>] connect
          [-i <eap-id>] [-p <password>] [-h] <ssid> [password]
```
The ability to set an interface's UP/DOWN state, IP, netmask and gateway has been
removed as it's already been done by 
[`ifconfig(8)`](https://man.freebsd.org/cgi/man.cgi?ifconfig) and 
[`route(8)`](https://man.freebsd.org/cgi/man.cgi?route). Also all lib80211 
`ioctl` code, which was still being used by older `wutui`, 
has been removed as that information can be 
fetched from `libwpa_client`'s `wpa_ctrl`.

## What's next?
Currently when the dimension of the terminal window is less than 80x36 
(80 cols and 36 rows), a "Terminal is too small" text is displayed. Scaling 
even below that should be supported. The `wutil(1)` manpage also needs updating.
Once `libwpa_client` is available in `net/wpa_supplicant` port, we can submit
the `wutil` [port](https://github.com/MainKt/freebsd-ports/tree/wutil/sysutils/wutil).
In the coming weeks I'll also 
implement `libifconfig` helpers to set UP/DOWN state, IP/netmask and MAC on 
network interfaces.
