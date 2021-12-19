---
date: 2021-12-19
layout: post
title: Configuring firewalld on Debian Bullseye
...

After doing a clean Debian 11 (Bullseye) installation on a new machine, the next step after installing basic CLI tools and disabling SSH root/password logins was to configure its firewall. It's easy to imagine how big was my surprise when I found out that the `iptables` command wasn't available. While [it's known for at least 5 years][iptables-successor] that this was going to happen, it still took me some time to let the idea of its deprecation sink and actually digest the situation. I scratched my head a bit wondering if the day I would be obliged to learn how to use [nftables][nftables] had finally came.

While looking for some guidance on what are the best practices to manage firewall rules these days, I found the article "[What to expect in Debian 11 Bullseye for nftables/iptables][netfilter-bullseye]", which explains the situation in a straightforward way. The article ends up suggesting that [firewalld][firewalld] is supposed to be the default firewall rules wrapper/manager - something that is news to me. I never met the author while actively working on Debian, but I do know he's the maintainer of multiple firewall-related packages in the distribution and also works on the [netfilter project][netfilter] itself. Based on these credentials, I took the advice knowing it came from someone who knows what they are doing.

A fun fact is that the `iptables` package [is actually a dependency][firewalld-debian] for `firewalld` on Debian Bullseye. This should not be the case on future releases. After installing it, I went for the simplest goal ever: block all incoming connections while allowing SSH (and preferably [Mosh][mosh], if possible). Before doing any changes, I tried to familiarize myself with the basic commands. I won't repeat what multiple other sources say, so I suggest this [Digital Ocean article that explains firewalld concepts, like zones and rules persistency][firewalld-digitalocean].

In summary, what one needs to understand is that there are multiple "zones" within firewalld. Each one can have different sets of rules. In order to simplify the setup, I checked what was the default zone, added the network interface adapter to it and defined the needed rules there. No need for further granularity in this use case. Here, the default zone is the one named `public`:

```
$ sudo firewall-cmd --get-default-zone
public
$ sudo firewall-cmd --list-all
public
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services: dhcpv6-client ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Knowing that, it was quite simple to associate the internet-connected network interface to it and update the list of allowed services. `dhcpv6-client` is going to be removed because this machine isn't on an IPv6-enabled network:

```
$ sudo firewall-cmd --change-interface eth0
success
$ sudo firewall-cmd --add-service mosh
success
$ sudo firewall-cmd --remove-service dhcpv6-client
success
```

It's important to execute `sudo firewall-cmd --runtime-to-permanent` after confirming the rules where defined as expected, otherwise they would be lost on service/machine restarts:

```
$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0
  sources:
  services: mosh ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
$ sudo firewall-cmd --runtime-to-permanent
success
```

A side effect of the `target: default` setting is that it `REJECT`s packets by default, instead of `DROP`ing them. This basically informs the client that any connections were actively rejected instead of silently dropping the packets - the latter which might be preferable. It's confusing why it's called `default` instead of `REJECT`, and also not clear [if it's actually possible to change the default behavior][firewalld-putorius]. In any case, it's possible to explicitly change it:

```
$ sudo firewall-cmd --set-target DROP --permanent
success
$ sudo firewall-cmd --reload
success
```

The `--set-target` option requires the `--permanent` flag, but it doesn't apply the changes instantly, requiring them to be reloaded.

An implication of dropping everything is that ICMP packets are blocked as well, preventing the machine from answering `ping` requests. The way this can be configured is a bit confusing, given that the logic is flipped. There's a need to enable `icmp-block-inversion` and add (which in practice would be removing it) an ICMP block for `echo-request`:

```
$ sudo firewall-cmd --add-icmp-block-inversion
success
$ sudo firewall-cmd --add-icmp-block echo-request
success
```

The result will look like this, always remembering to persist the changes:

```
$ sudo firewall-cmd --list-all
public (active)
  target: DROP
  icmp-block-inversion: yes
  interfaces: eth0
  sources:
  services: mosh ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks: echo-request
  rich rules:
$ sudo firewall-cmd --runtime-to-permanent
success
```

For someone who hadn't used `firewalld` before, I can say it was OK to use it in this simple use case. There was no need to learn the syntax for `nft` commands nor the one for `nftables` rules and it worked quite well in the end. The process of unblocking ICMP `ping` requests is a bit cumbersome with the flipped logic, and could have been made simpler, but it's still doable. All-in-all I'm happy with the solution and will look forward how to use it, for instance, in a [non-interactive way with Ansible][firewalld-ansible].

[firewalld-ansible]: https://docs.ansible.com/ansible/latest/collections/ansible/posix/firewalld_module.html
[firewalld-debian]: https://packages.debian.org/bullseye/firewalld
[firewalld-digitalocean]: https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-using-firewalld-on-centos-8
[firewalld-putorius]: https://www.putorius.net/introduction-to-firewalld-basics.html#firewalld-targets
[firewalld]: https://firewalld.org/
[iptables-successor]: https://developers.redhat.com/blog/2016/10/28/what-comes-after-iptables-its-successor-of-course-nftables
[mosh]: https://mosh.org/
[netfilter-bullseye]: https://ral-arturo.org/2019/10/14/debian-netfilter.html
[netfilter]: https://www.netfilter.org/
[nftables]: https://netfilter.org/projects/nftables/
