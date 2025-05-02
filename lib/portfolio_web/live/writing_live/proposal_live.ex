defmodule PortfolioWeb.WritingLive.ProposalLive do
  use PortfolioWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "FreeBSD GSoC 2025 Proposal")
      |> assign(:page_heading, "FreeBSD GSoC 2025 Proposal")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <p>Muhammad Saheed</p>

    <style>
      .no-numbering {
        list-style-type: none;
      }
    </style>

    <nav class="table-of-contents">
      <h2>Contents</h2>
      <ol class="toc-list" style="list-style-type: none;">
        <li>
          <a href="#general-information">1. General Information</a>
          <ol style="list-style-type: none;">
            <li><a href="#biography">1.1. Biography</a></li>
            <li><a href="#mentors">1.2. Mentors</a></li>
          </ol>
        </li>
        <li>
          <a href="#wifi-utility">2. WiFi and Network Management CLI/TUI Utility</a>
          <ol style="list-style-type: none;">
            <li>
              <a href="#project-description">2.1. Project Description</a>
              <ol style="list-style-type: none;">
                <li>
                  <a href="#technical-approach">2.1.1. Technical Approach</a>
                  <ol style="list-style-type: none;">
                    <li><a href="#base-features">2.1.1.1. Base features</a></li>
                    <li><a href="#tui">2.1.1.2. The TUI</a></li>
                  </ol>
                </li>
                <li><a href="#significance">2.1.2. Significance for FreeBSD</a></li>
              </ol>
            </li>
            <li><a href="#deliverables">2.2. Deliverables</a></li>
            <li><a href="#test-plan">2.3. Test Plan</a></li>
            <li><a href="#project-schedule">2.4. Project Schedule</a></li>
          </ol>
        </li>
      </ol>
    </nav>

    <h2 id="general-information">1. General Information</h2>
    <table>
      <tr>
        <td>Name</td>
        <td>Muhammad Saheed</td>
      </tr>
      <tr>
        <td>Email</td>
        <td>
          <a href="mailto:muhammad.saheed.iam AT gmail DOT
        com">
            muhammad.saheed.iam AT gmail DOT com
          </a>
        </td>
      </tr>
      <tr>
        <td>Phone</td>
        <td><a href="tel:+12 1234567890">[REDACTED]</a></td>
      </tr>
      <tr>
        <td>IRC</td>
        <td>unwrapped_monad at libera.chat</td>
      </tr>
      <tr>
        <td>GitHub</td>
        <td><a href="https://github.com/MainKt">https://github.com/MainKt</a></td>
      </tr>
      <tr>
        <td>Time zone</td>
        <td>Indian Standard Time, UTC+05:30</td>
      </tr>
    </table>

    <p>
      I can work full-time on the project, dedicating around 40 hours per week with no other obligations for the summer.
    </p>
    <p>
      My semester exams are scheduled from June 9 to June 20, and I have already discussed this with my mentor. It's flexible with their schedule.
    </p>
    <p>
      The project can begin on the official start date of June 2, with a brief pause for exams. I will resume the work on June 21.
    </p>
    <p>
      I will stay in regular contact with my mentors and the FreeBSD community over mailing lists, IRC and discord. and I'll aim to provide a day-by-day schedule before the program starts.
    </p>

    <h3 id="biography">1.1. Biography</h3>
    <p>
      I am part of <code>The sceptix club</code>
      in my college; it's a student club promoting Linux and FOSS. In my free time, I love to rice and optimize my workflow with vim, window managers and learning various CLIs but maybe it's wise to not spend too much time ricing :D. I like systems programming and building low level stuff.
    </p>
    <p>
      My prior open-source contributions including maintaining the dk window manager package on Void Linux and fixing Swift LSP config in nvim-lspconfig. I made a FreeBSD port for dk: <a href="https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=285874">Bug 285874</a>.
    </p>
    <p>
      I have FreeBSD in my old laptop, it has been a few month and have been using it as a home-server. I have been playing around with ports and jails and really been loving the vast package collection and Makefile configurations like <code>bsd.prog.mk</code>. I have built the kernel and the world (<code>buildkernel and buildworld</code>) in my other machine in around 2 mins and 26 mins respectively.
    </p>
    <p>
      I try to build and rewrite tools in Rust and Zig but lately found C much more cooler while going through <code>/usr/src</code>. I have written simple CLIs and X11 tools. I built a simple CLI WiFi util for FreeBSD called
      <a href="https://github.com/MainKt/wutil.git"><code>wutil</code></a>
      in C and have been trying to build a TUI library in C based on <code>libvaxis</code>, <a href="https://github.com/MainKt/shinsentui.git">shinsentui</a>, it's still very early though. I have read the style(9) and have tried to follow it in my code.
    </p>

    <h3 id="mentors">1.2. Mentors</h3>
    <p>
      Getz Mikalsen will be the mentor and Aymeric Wibo will the co-mentor. We have discussed the project on IRC and mail
    </p>

    <h2 id="wifi-utility">2. WiFi and Network Management CLI/TUI Utility</h2>
    <h3 id="project-description">2.1. Project Description</h3>
    <p>
      The project aims to build a CLI with a clean looking TUI in C for easier WiFi and Network Management on FreeBSD. The project will try to avoid unnecessary dependencies so that it's possible to add it to the FreeBSD base in the future. I've built a simple CLI utility called
      <code>wutil</code>
      as a prototype based on GhostBSD's <code>NetworkMgr</code>. It currently just wraps around the
      <code>ifconfig</code>
      and <code>wpa_supplicant</code>
      with features like scanning, connecting/disconnecting networks, configuring
      <code>wpa_supplicant.conf</code>
      for the network and managing network card configurations.
    </p>
    <p>
      But the GSoC project will aim to build a better CLI that makes use of <code>libfconfig</code>
      and possibly extend <code>libfconfig</code>
      with lacking features necessary to implement the functionalities without shell calling <code>ifconfig</code>. This utility will also include a REPL interface like <code>iwctl</code>. We will be avoiding ncurses and using terminal raw mode and escape sequences for building the TUI,
      <a href="https://zig.news/lhp/want-to-create-a-tui-application-the-basics-of-uncooked-terminal-io-17gm">
        The "Uncooked" Terminal IO
      </a>
      way.
    </p>

    <h4 id="technical-approach">2.1.1. Technical Approach</h4>
    <h5 id="base-features">2.1.1.1. Base features</h5>
    <dl>
      <dt>Listing network interfaces and their status</dt>
      <dd></dd>
    </dl>
    <p>
      <code>wutil</code>
      currently shell calls <code>ifconfig</code>
      and does string manipulation over it's output to retrieve the interfaces and their status. We'll switch over to <code>libifconfig</code>'s helper utilities to get this information instead using <code>ifconfig_foreach_iface(...)</code>,
      <code>ifconfig_get_ifstatus(...)</code>
      etc like shown in <a href="https://cgit.freebsd.org/src/tree/share/examples/libifconfig/status.c"><code>/usr/src/share/examples/libifconfig/status.c</code></a>.
    </p>
    <dl>
      <dt>Virtual interface creation</dt>
      <dd></dd>
    </dl>
    <p>
      <code>libifconfig</code>
      provides <code>ifconfig_create_interface_vlan(...)</code>,
      <code>ifconfig_destroy_interface(...)</code>
      for this. So we can abstract the boring <code>wlan0</code>
      virtual interface creation part on new FreeBSD installs when connecting to WiFi.
    </p>
    <dl>
      <dt>Enable, disable, and restart Network Interfaces</dt>
      <dd></dd>
    </dl>
    <p>
      We can enable/disable an interface like <code>ifconfig IF up/down</code>
      by toggling the <code>IFF_UP</code>
      flag of the interface's <code>ifaddrs</code>
      using a <code>SIOCSIFFLAGS</code> <code>ioctl(...)</code>
      call. <code>ifconfig</code>
      does this internally, this should be extracted in <code>libifconfig</code>
      as a small helper function. See
      <a href="https://cgit.freebsd.org/src/tree/sbin/ifconfig/ifconfig.c#n2071">
        <code>/usr/src/sbin/ifconfig/ifconfig.c:2071 basic_cmds</code>
      </a>
      and <a href="https://cgit.freebsd.org/src/tree/sbin/ifconfig/ifconfig.c#n1418"><code>/usr/src/sbin/ifconfig/ifconfig.c:1418 setiffags(...)</code></a>.
    </p>
    <dl>
      <dt>Scanning for networks</dt>
      <dd></dd>
    </dl>
    <p>
      <code>libifconfig</code>
      currently doesn't have a way to scan for wireless networks but
      <a href="https://cgit.freebsd.org/src/tree/sbin/ifconfig/ifieee80211.c#n3745">
        <code>/usr/src/sbin/ifconfig/ifieee80211.c:3745 ifconfig</code>
      </a>
      uses <code>lib80211_get80211len</code>
      from <code>lib80211/lib80211_ioctl.h</code>
      which is a wrapper around <code>SIOCG80211</code> <code>ioctl(...)</code>
      with a <code>ieee80211req</code>
      of the type <code>IEEE80211_IOC_SCAN_RESULTS</code>. We can cast the output buffer to a
      <code>struct ieee80211req_scan_result</code>
      to get all the proper offsets, SSID length, capabilities, beacon interval and noise etc. With this we can parse and retrieve SSID and 802.11 Information Elements (IEs). We will have to extract this into a
      <code>libifconfig</code>
      function to easily scan and retrieve these network information on wireless interfaces.
    </p>
    <dl>
      <dt><code>wpa_supplicant.conf</code> configurations</dt>
      <dd></dd>
    </dl>
    <p>
      Before connecting to a WiFi network, we gotta write a configuration for it in <code>/etc/wpa_supplicant.conf</code>. In <code>wutil</code>, we check for the IE, RSN to determine if it's a WPA2 network. We store configuration for all networks in <code>/etc/wpa_supplicant.conf</code>, which is messy when adding, removing or editing a network. For this project, I feel it's better to have separate config file for each network in <code>/etc/wpa_supplicant/</code>.
    </p>
    <dl>
      <dt>Connecting/disconnecting networks</dt>
      <dd></dd>
    </dl>
    <p>
      In <code>wutil</code>, for connecting to a network, we kill all <code>wpa_supplicant</code>
      processes and set the network's SSID via <code>ifconfig IF ssid SSID</code>
      and restart <code>wpa_supplicant</code>
      with the connecting network's <code>wpa_supplicant.conf</code>. When disconnecting, we bring down the interface with
      <code>ifconfig</code>
      and set it's SSID to <code>none</code>
      and bring it back up. We will have to extract <a href="https://cgit.freebsd.org/src/tree/sbin/ifconfig/ifieee80211.c#n604"><code>/usr/src/sbin/ifconfig/ifieee80211.c:604 set80211ssid(...)</code></a>, which is a wrapper around
      <code>lib80211_set80211(...)</code>
      for <code>SIOCS80211</code> <code>ioctl(...)</code>. from <code>ifconfig</code>
      into <code>libifconfig</code>.
    </p>
    <dl>
      <dt>Network interface configuration</dt>
      <dd></dd>
    </dl>
    <p>
      We will be handling DNS and search domain configurations in <code>/etc/resolv.d</code>
      same as wutil and NetworkMgr. For manually configuring the IP, netmask and MAC we will have to build helpers around
      <code>SIOCAIFADDR</code>
      and
      <code>SIOCDIFADDR</code> <code>ioctl(...)</code>s in <code>libifconfig</code>. Option to automatically configure these with DHCP will also be provided.
      <code>NetworkMgr</code>
      persists these configurations with a <code>sysrc</code>
      call in <code>rc.conf</code>, but we will be avoiding writing to <code>rc.conf</code>
      and only print the instructions so that the user can do it themselves if they want to.
    </p>
    <dl>
      <dt>Random MAC generation</dt>
      <dd></dd>
    </dl>
    <p>
      We can provide option to generate legitimate MAC address for both LAN and WLAN with OUI first three octets like how it's done in
      <a href="https://github.com/vermaden/scripts/blob/master/network.sh#L121">
        <code>network.sh</code>
      </a>
      by vermaden.
    </p>
    <p>
      I would also love to support WWAN like <code>network.sh</code>
      but I don't have a device to test it out :^).
    </p>
    <p>
      We will be handling operations which require root like <code>ifconfig</code>, that is to fail the operation and handle the errors if possible.
    </p>

    <h5 id="tui">2.1.1.2. The TUI</h5>
    <p>
      We will be using <code>termios</code>
      to put the terminal in non-canonical input mode and using control sequences, switch to an alternative buffer to draw the UI. The
      <a href="https://github.com/rockorager/libvaxis/blob/main/src/ctlseqs.zig">
        ctlseqs.zig in libvaxis
      </a>
      lists a lot of control sequences we could use to color and design the TUI. We will poll the
      <code>/dev/tty</code>
      file descriptor and buffer the input for parsing. On exit, we will restore the terminal state as it was before opening the TUI. The TUI will provide all the above listed base features and will try to mimic <code>nmtui</code>'s functionalities on linux but much more cleaner.
    </p>

    <h4 id="significance">2.1.2. Significance for FreeBSD</h4>
    <p>
      A network management utility would be very helpful for everyday desktop and laptop users. Extracting the wireless interface related parts from
      <code>ifconfig</code>
      to <code>libifconfig</code>
      will be very useful to use these features programmatically can help in simplifying
      <code>ifconfig</code>
      codebase in the future. Maybe we could also extract the TUI parts into a simple library with all basic stuffs needed to build similar TUIs in the future without relying on ncurses.
    </p>
    <p>I hope it will be a stepping stone to bring about the year of FreeBSD on desktop.</p>
    <p>
      I am committed to becoming a long-term FreeBSD contributor, actively maintaining the contributed code and I wish to contribute drivers and even more utilities to make FreeBSD better on my main machine, It has issues like poweroff on lid close, and hope this project will be a great starting point.
    </p>

    <h3 id="deliverables">2.2. Deliverables</h3>
    <p>Before the mid-term evaluation</p>
    <ul>
      <li>
        <p>A CLI and a REPL able to</p>
        <ol>
          <li value="1">list and configure interfaces</li>
          <li value="2">scan, connect/disconnect from wireless networks</li>
          <li value="3">manage <code>/etc/wpa_supplicant.conf</code> configurations for networks.</li>
          <li value="3">manually configure IP, netmask, gateway and automatically with DHCP</li>
          <li value="4">configure MAC address, DNS servers and search domain</li>
        </ol>
      </li>
      <li>A manpage for the CLI</li>
      <li>
        <p>Extensions to missing features needed in <code>libifconfig</code></p>
        <ol>
          <li value="1"><code>SIOCG80211</code> helper to scan wireless interfaces</li>
          <li value="2"><code>SIOCSIFFLAGS</code> helper to enable and disable network interfaces</li>
          <li value="3"><code>SIOCS80211</code> helper to connect/disconnect wireless networks</li>
          <li value="4">
            <code>SIOCAIFADDR</code> and <code>SIOCDIFADDR</code> helper to set IP/netmask and MAC
          </li>
        </ol>
      </li>
    </ul>
    <p>
      I would be happy to work with the implementation of "Network Configuration Libraries" contributor in
      <code>libifconfig</code>
      :)
    </p>
    <ul>
      <li>A manpage for <code>libifconfig</code></li>
    </ul>
    <p>After the mid-term evaluation</p>
    <ul>
      <li>A clean TUI like <code>nmtui</code> with the base features as the CLI</li>
      <li>Publishing an initial port for FreeBSD users to test it out</li>
      <li>Getting the utilities into the base system</li>
    </ul>

    <h3 id="test-plan">2.3. Test Plan</h3>
    <p>
      As it is a WiFi utility it would be difficult to mock its functionality in code, but I will make sure to write unit tests wherever appropriate.
    </p>

    <h3 id="project-schedule">2.4. Project Schedule</h3>
    <p>170 hours are allocated for the project as per the GSOC guidelines for a medium project.</p>
    <p>May 8 - June 1 Community bonding</p>
    <p>June 2 Coding starts</p>
    <p>June 9-20 My semester exams</p>
    <p>June 21 Coding resumes</p>
    <p>July 14 Midterm goals reached</p>
    <p>July 18 Midterm evaluation deadline</p>
    <p>August 25 - September 1 Final GSoC contributor evaluations</p>
    """
  end
end
