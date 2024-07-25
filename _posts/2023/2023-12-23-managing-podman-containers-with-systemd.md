---
date: 2023-12-23
layout: post
title: Managing Podman containers with systemd
...

Since my early days in programming, I've always worried about isolated development environments. Of course, this wasn't relevant when developing C applications with no external dependencies in [Code::Blocks][codeblocks], but it soon became a necessity when I had to deal with Python packages through [virtualenv][venv]. The same happened with Ruby versions using [rbenv][rbenv]. Later I settled on [asdf][asdf] to do that with multiple Go/Node.js versions, which basically solved the problem for good for many programming languages and even some CLI tools that are sensible to versioning, like `kubectl`.

But dealing with multiple runtimes or packages is just one piece of the equation in the grand schema of cleanly handling dependencies. Sometimes you have to worry about the versions of the external services a project makes use of, like a database or cache system. This is also a solved problem since [Docker][docker] came into the picture over 10 years ago. I remember that the Docker Compose mantra when it launched ([still called Fig][fig]) was: "_no more installing Postgres on your laptop!_". This is just a bit more complicated when you don't use the original Docker implementation, but another container management system, like [Podman][podman].

Podman offers several advantages over Docker. It can run containers without requiring `root` access; it doesn't depend on a service daemon running all the time; and it doesn't require [a paid subscription depending on the usage][docker-pricing]. It's a simpler tool, with an almost 1:1 compatible UI overall. The main difference is that it doesn't seamlessly handle containers with `--restart` flags. I mean, of course it does restart containers when their processes are interrupted, but they won't be brought up after a host reboot - which tends to happen from time to time in a workstation.

When looking into how to solve this problem, I realised that the `podman generate` command can create [systemd][systemd] service unit files. So instead of tinkering about how to integrate the two tools, figuring the file syntax and functionality, it's possible to just create a new systemd service of the desired container as if it were any other program/process. And the best part is that we can still do that without `root`, thanks to [systemd user services][systemd-user].

```
$ podman create --name redis -p 6379:6379 docker.io/redis:7
Trying to pull docker.io/library/redis:7...
(...)
$ mkdir -p ~/.config/systemd/user/
$ podman generate systemd --name redis > ~/.config/systemd/user/redis.service
```

To increase the service's reliability, it's preferable to drop the `PIDFile` line from the configuration file. It typically looks like:

    PIDFile=/run/user/1000/containers/vfs-containers/c1b1c3e5dba5368c29ada52a638378e5fec74e1a62e913919528b9c3846c14bb/userdata/conmon.pid

This ensures that even if the container is recreated, like when updating its image, systemd won't be referencing its older ID, as it will only care about its name. This can be done programmatically with `sed`:

    $ sed -i '/PIDFile/d' ~/.config/systemd/user/redis.service

The generated file should be similar to:

```ini
# container-redis.service
# autogenerated by Podman 4.3.1
# Sat Dec 23 17:18:01 -03 2023

[Unit]
Description=Podman container-redis.service
Documentation=man:podman-generate-systemd(1)
Wants=network-online.target
After=network-online.target
RequiresMountsFor=/run/user/1000/containers

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Restart=on-failure
TimeoutStopSec=70
ExecStart=/usr/bin/podman start redis
ExecStop=/usr/bin/podman stop  \
        -t 10 redis
ExecStopPost=/usr/bin/podman stop  \
        -t 10 redis
Type=forking

[Install]
WantedBy=default.target
```

The final step consists in starting the service and enabling it to launch on boot:

```
$ systemctl --user start redis
$ systemctl --user enable redis
Created symlink /home/myhro/.config/systemd/user/default.target.wants/redis.service → /home/myhro/.config/systemd/user/redis.service.
$ systemctl --user status redis
● redis.service - Podman container-redis.service
     Loaded: loaded (/home/myhro/.config/systemd/user/redis.service; enabled; preset: enabled)
     Active: active (running) since Sat 2023-12-23 17:25:40 -03; 13s ago
       Docs: man:podman-generate-systemd(1)
      Tasks: 17 (limit: 37077)
     Memory: 11.1M
        CPU: 60ms
     CGroup: /user.slice/user-1000.slice/user@1000.service/app.slice/redis.service
             ├─46851 /usr/bin/slirp4netns --disable-host-loopback --mtu=65520 --enable-sandbox --enable-seccomp --enable-ipv6 -c -e 3 -r 4 --netns-type=path /run/user/1000/netns/netns-102ff957-157c-adcb-bd4a-45e7e0d2a50f tap0
             ├─46853 rootlessport
             ├─46859 rootlessport-child
             └─46869 /usr/bin/conmon --api-version 1 -c c1b1c3e5dba5368c29ada52a638378e5fec74e1a62e913919528b9c3846c14bb -u c1b1c3e5dba5368c29ada52a638378e5fec74e1a62e913919528b9c3846c14bb -r /usr/bin/crun -b /home/myhro/.local/share/(...)

Dec 23 17:25:40 leptok redis[46869]: 1:C 23 Dec 2023 20:25:40.071 # Warning: no config file specified, using the default config. In order to specify a config file use redis-server /path/to/redis.conf
Dec 23 17:25:40 leptok redis[46869]: 1:M 23 Dec 2023 20:25:40.072 * monotonic clock: POSIX clock_gettime
Dec 23 17:25:40 leptok redis[46869]: 1:M 23 Dec 2023 20:25:40.072 * Running mode=standalone, port=6379.
Dec 23 17:25:40 leptok redis[46869]: 1:M 23 Dec 2023 20:25:40.072 * Server initialized
Dec 23 17:25:40 leptok redis[46869]: 1:M 23 Dec 2023 20:25:40.072 * Loading RDB produced by version 7.2.3
Dec 23 17:25:40 leptok redis[46869]: 1:M 23 Dec 2023 20:25:40.072 * RDB age 18 seconds
Dec 23 17:25:40 leptok redis[46869]: 1:M 23 Dec 2023 20:25:40.072 * RDB memory usage when created 0.83 Mb
Dec 23 17:25:40 leptok redis[46869]: 1:M 23 Dec 2023 20:25:40.072 * Done loading RDB, keys loaded: 0, keys expired: 0.
Dec 23 17:25:40 leptok redis[46869]: 1:M 23 Dec 2023 20:25:40.072 * DB loaded from disk: 0.000 seconds
Dec 23 17:25:40 leptok redis[46869]: 1:M 23 Dec 2023 20:25:40.072 * Ready to accept connections tcp
```

In summary, I quite liked how easy it was to leverage the strengths of both the Podman and systemd in their integration. Being able to do that in a rootless way is definitely a huge plus. Before doing that, I always believed that managing Linux services was a root-only thing. But now that I think about it, I realize that when Docker was the only game in town, managing containers also required elevated privileges. I'm glad that we are moving away from this idea, piece by piece.


[asdf]: https://asdf-vm.com/
[codeblocks]: https://www.codeblocks.org/
[docker-pricing]: https://www.docker.com/pricing/
[docker]: https://en.wikipedia.org/wiki/Docker_(software)
[fig]: https://web.archive.org/web/20140802222736/http://www.fig.sh/
[podman]: https://podman.io/
[rbenv]: https://github.com/rbenv/rbenv
[systemd-user]: https://wiki.archlinux.org/title/systemd/User
[systemd]: https://systemd.io/
[venv]: https://virtualenv.pypa.io/