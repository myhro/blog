---
date: 2022-01-01
layout: post
title: MikroTik hEX (RB750Gr3) Review
...

The [MikroTik hEX (RB750Gr3)][hex] is a simple wired router - one of the cheapest from the Latvian company - that surely does its job. It's really flexible, which is simultaneously both a pro and a con. It's the router with the largest amount of configuration options that I ever seen, including the possibility of making any sort of LAN/WAN combination from the five ports available.

# Impressions

- One of MikroTik's RouterOS biggest features are the countless configuration options in its GUI, both though web and via the native application [WinBox][winbox]. The problem is that a considerable chunk of its documentation, both in the official channels and from random tips scattered around the Internet, is focused on its CLI (called just `Terminal`).
- It has a non-standard factory reset process. One has to hold its reset button, which is super thin and can't be reached with a pen, as soon as the device is connected to the power supply. It's not enough to just hold the reset button anytime.
- Its configuration options are flexible, incredibly flexible, to the point that it doesn't prevent the user from doing a catastrophic and irreversible change. In the first time I was setting up the LAN bridge options, I somehow removed the port in which the router IP (`192.168.88.1`) was associated with. This made it completely lose connectivity and there was no way to access its web UI ever again. Had to reset it to restore access after that.
- The wizard configuration system called `Quick Set` offers very few options for people who want to configure the router as quick as possible. And the same time, it does too much magic under the hood, resulting in possible headaches in the future. I don't recommend using it.
- After resetting the device a couple times and configure everything by hand in the `WebFig`, its web GUI, I scratched my head to understand how to access this interface after connecting through a Wi-Fi router, which I had to use given it only offers wired connections.
  - As the Wi-Fi router was giving me an IP in the `192.168.0.0/24` range, I wasn't able to access the router at `192.168.88.1`, even though the Wi-Fi router could reach it. I was only able to access it after manually adding the `192.168.0.0/16` range as allowed to the `admin` user. When using `Quick Set` this isn't needed, as this configuration is done without ever informing the user.
- Some options aren't available in the `WebFig` interface, like changing the MAC address of the ethernet ports directly. At the same time the `Quick Set` does this (maybe via CLI in the background), suggesting that this is indeed possible. A workaround for that is to create a single-port bridge and change the MAC address of this virtual interface.
- It's super easy to update the device, considering both the RouterOS and its firmware itself, which are two separate processes. Given that internet access is properly configured, all that is required are a couple clicks in the interface and a reboot to perform each one of them.

# Conclusion

It's not a router that I would recommend for the faint of heart nor people who are not ready to face a few frustrations. Even I, being someone used to configure routers even before I was 15 years old, scratched my head to understand how a few things work and spent at least 3 hours to leave it as close as possible from what I wanted. Even though, I wasn't able to configure the Dual-WAN option with a stand-by connection that is automatically activated when the main one goes down. Via the web UI this didn't work right and via CLI it looked like too much of a hassle.

In the end I was able to manage both connections manually, accessing the `WebFig` and deactivating one while re-activating the other. This is still better than physically switching the cable from one modem to the other, and still having to access the configuration page to switch between DHCP and PPPoE in the Wi-Fi router solely WAN port.

I'm considering trying out a MikroTik Wi-Fi router, given that having fewer devices involved might simplify the setup. Having one less device connected to the uninterruptible power supply will also probably improve its autonomy.

[hex]: https://mikrotik.com/product/RB750Gr3
[winbox]: https://wiki.mikrotik.com/wiki/Manual:Winbox
