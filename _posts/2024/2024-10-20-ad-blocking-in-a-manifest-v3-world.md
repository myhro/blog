---
date: 2024-10-20
layout: post
title: Ad-blocking in a Manifest V3 world
---

I started receiving warnings on Chrome about [uBlock Origin][ubo], stating, "[This extension may soon no longer be supported][warning]", after I set it up on a new computer nearly three months ago. These warnings are related to the [ongoing deprecation of Manifest V2][mv2], which has been going on for a few years and is expected to be finalized by June next year. I can't even imagine using the internet without an ad blocker, so I decided to explore the current alternatives.

To be honest, the process was a bit daunting. [Some articles suggest that there's no hope][crackdown] unless you switch to a browser supported by a company that doesn't rely on ads - something that doesn't really exist. In situations like this, I tend to try the simplest, most straightforward solution first before diving into more complex, over-the-top options. In this case, I decided to switch to the Manifest V3-based extension from the same developers: [uBlock Origin Lite][ubol].

The experience was actually better than I expected. Even in "Basic" mode, which doesn't require permission to read or change data on all sites, it worked quite well with the default filters. I did notice some empty ad boxes, as the page layouts aren't reworked, but that's something I'm already used to when visiting sites on mobile with [AdGuard][adguard] (doing the [block via DNS][adguard-dns]). No need to change to the "Optimal" mode for now.

In fact, enabling the "Overlay Notices" and "Other Annoyances" filter lists made the experience even more pleasant than before. There are no more "please disable your ad-block" or "please donate to this site using Google" overlays to disrupt my browsing. So while the transition from V2 to V3 may have been a hassle for extension developers, as an end-user, I can't say I'm unhappy with it. I'm still experiencing the (mostly) ad-free internet I was used to.

[adguard-dns]: https://adguard-dns.io/en/public-dns.html
[adguard]: https://adguard.com/
[crackdown]: https://www.osnews.com/story/140947/googles-ad-blocking-crackdown-underway/
[mv2]: https://developer.chrome.com/docs/extensions/develop/migrate/mv2-deprecation-timeline
[ubo]: https://github.com/gorhill/uBlock
[ubol]: https://github.com/uBlockOrigin/uBOL-home
[warning]: https://github.com/uBlockOrigin/uBlock-issues/wiki/About-Google-Chrome's-%22This-extension-may-soon-no-longer-be-supported%22
