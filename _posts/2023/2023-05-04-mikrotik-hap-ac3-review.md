---
date: 2023-05-04
layout: post
title: MikroTik hAP ac3 Review
...

As I [mentioned in the previous review][previous], my experience with the MikroTik router that only supported wired networking encouraged me to look for a Wi-Fi one. After browsing the available models, the slogan of a particular one, the [hAP ac3][hap_ac3], caught my attention:

> Forget about endless searching for the perfect router and scrolling through an eternity of reviews and specifications! We have created a single affordable home access point that has all the features you might need for years to come.

A highly configurable router, with gigabit wired networking and dual-band 2.4 and 5 GHz Wi-Fi at an affordable price (abroad, where it costs US$ 99, not here where it costs R$ 800)? It seemed like exactly what I was looking for.

# Findings

After spending 3 hours configuring the wired router, I thought to myself: "Ah, now that I know how MikroTik works, it'll be easy. 15 or 20 minutes and everything will be working." What a mistake. The interface is literally the same with an additional `Wireless` option in the menu, but even setting a password on the unprotected Wi-Fi network was challenging. I really scratched my head trying to understand how things worked and spent another 2 hours configuring it in the way I wanted.

Configuring the 5 GHz Wi-Fi transmission, in particular, was quite difficult. It has a "radar detection" system to use higher frequencies (5.5-5.6 GHz) that takes literally 10 minutes (!) on each boot to decide which one to use, time in which the wireless network remains unavailable during this process. To avoid frustration, I manually chose a lower frequency option (5.1-5.2 GHz).

After everything was configured, I noticed that the 5 GHz Wi-Fi signal was weaker in other rooms than it used to be with my TP-Link router. Weak enough for iOS to automatically fall back to 4G. Along with the weaker signal came a drop in connection speed. On my MacBook, it fell from 400 to 200 Mbps, and on my iPhone from 200 to 100 Mbps, both measured at [Fast.com][fast] in other rooms, compared to the TP-Link router I intended to replace. Although that would be sufficient bandwidth to cover most of my use cases, it seemed unacceptable to downgrade the speed I was used to, given the price and quality I expected from the device.

The solution was to go back to a setup identical to the wired MikroTik: connecting the TP-Link router to the new MikroTik and using only the Wi-Fi from the former. In router mode, the speed loss was the same. In access point mode, I achieved the same speed as before when connecting the TP-Link directly to the modem or the wired MikroTik.

# Conclusion

It wasn't a very wise decision to buy a more expensive model because of Wi-Fi and ultimately not use it, but the experience was valuable. It still solves my Dual WAN support issue, albeit in a less than ideal way, and I could return the borrowed MikroTik. I couldn't exactly pinpoint why its 5 GHz network was so much slower than the TP-Link, but I've encountered similar situations caused by software (as the same has happened to me with DD-WRT) in a not-so distant past. It's not what I expected from MikroTik, a device whose software is precisely its selling point, but who knows. Today, if I were to set up the same system without having the TP-Link router available, I would get a simpler wired MikroTik and connect a Unifi AP to it. It would be the best of both worlds and the cost would be virtually the same.

[fast]: https://fast.com/
[hap_ac3]: https://mikrotik.com/product/hap_ac3
[previous]: /2022/01/mikrotik-hex-rb750gr3-review
