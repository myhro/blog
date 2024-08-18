---
date: 2024-08-18
title: The cloud won, again
...

[Since 2018][cloud-migration] (and [again in 2020][cloud-era]), I've been writing about how defaulting to cloud-based solutions instead of self-hosting everything has changed my life for the better. Even knowing that for years, I still made the wrong decision to self-host a service I needed and almost doubled down on doing it again. This was until I stopped and figured out an easier way to achieve the same goal.

I've been a Dropbox user for nearly 15 years. It really simplified my approach to backups for personal stuff: a cloud-synced folder on my laptop where I put everything that's not already on a cloud service. Accidentally deleted something? I can just go to their web app and restore it. The problem is that I don't want it offering a read-write version of this folder on every device I have. Sometimes I just need a temporary folder to drop a screenshot from my Windows gaming machine so I can access it from my phone.

[Resilio Sync][resilio-sync] (previously known as BitTorrent Sync) is what I was using for that. It has a few problems, including being super slow even after configuring everything possible to bypass its relay servers (spoiler: it doesn't). Plus, it doesn't have cloud-backed storage, so I ran an instance of it on a server to have an always-on copy of the files there. Not exactly a drop-in replacement for Dropbox, but it was still useful until I realized I was completely unhappy with its performance.

Things were reaching a point where I was considering self-hosting [Nextcloud][nextcloud] (fork of the original ownCloud) just for its file-syncing feature or even writing my own cloud-folder synchronization tool backed by S3-compatible storage. That's when it clicked: I realized I don't need real-time syncing for the simple use case of easily sharing single files from a computer to my phone. I just needed a way to access a Cloudflare R2 bucket from a mobile app.

After looking around, asking ChatGPT and [Perplexity][perplexity], I settled on [S3 Files][s3-files]. I can upload a file from Windows using [WinSCP][winscp] or from a macOS/Linux terminal using [s3cmd][s3cmd]. Each machine uses a fine-grained access key I can revoke if needed. The S3 API is ubiquitous. I just needed a mobile app to access it when I'm away from my computer. It offered me the ease, speed, availability, and robustness of the cloud, which are miles ahead compared to self-hosting anything.

[cloud-era]: /2020/01/the-cloud-computing-era-is-now
[cloud-migration]: /2018/03/how-i-finally-migrated-my-whole-website-to-the-cloud
[nextcloud]: https://nextcloud.com/
[perplexity]: https://www.perplexity.ai/
[resilio-sync]: https://www.resilio.com/sync/
[s3-files]: https://apps.apple.com/us/app/s3-files-bucket-storage/id6447647340
[s3cmd]: https://s3tools.org/s3cmd
[winscp]: https://winscp.net/
