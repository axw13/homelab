# Capacity and service placement review — October 2026

A read-only audit of a single Proxmox server and 35 guests (32 LXCs, three VMs) used 336 populated half-hour history buckets, Zabbix hourly trends and live configuration. Compute averaged 4.6%; available host RAM never fell below 14.8 GiB. No migration was required for compute or memory capacity.

Intermittent storage contention was more relevant. After earlier repairs, full I/O pressure averaged 3.55%, with a maximum half-hour average of 19.61%; shorter monitoring samples still reached 57.2%. These metrics do not by themselves identify a particular offending disk or service.

Important guest datasets still bypassed synchronous-write protection. ZFS filesystem consistency does not guarantee database transaction durability: disabling sync can lose acknowledged transactions or leave application state inconsistent after a crash. The review recommends planning durable storage and measuring synchronous-write latency before choosing a protected SLOG or restoring normal sync behavior. No storage properties were changed.

Eight application guest roots depend on NFS exported by a NAS VM on the same host. Core recovery services and the NAS boot disk remain local. Recovery planning must reflect this dependency; moving shared databases to a nonredundant application disk is not a suitable blanket fix.

The recommended architecture keeps firewall, NAS, home automation appliances, secrets, DNS, identity, databases and monitoring isolated. A small Docker VM for compatible low-risk applications is an optional management simplification. LXCs already share a kernel, so consolidating them does not guarantee memory savings. Four prospective applications together used roughly 1 GiB; the additional VM kernel and OS may offset savings. Retiring four inactive monitoring guest OSes mainly reduces patching and backup overhead: their combined measured memory was about 0.26 GiB, much less than their configured ceilings.

Any pilot should retain trust-zone boundaries, separate Compose projects, resource limits, application-consistent backups and tested restore paths. Guest consolidation does not remove the physical server failure domain. This review did not migrate, resize, stop, delete or reboot services.

References: [Proxmox container documentation](https://github.com/proxmox/pve-docs/blob/master/pct.adoc), [Docker resource limits](https://docs.docker.com/engine/containers/resource_constraints/), [OpenZFS sync property](https://openzfs.github.io/openzfs-docs/man/master/7/zfsprops.7.html).
