# Paperclip deployment

Paperclip runs in a dedicated, unprivileged Debian LXC with its root disk on
the `fastapps` storage pool. The guest has 4 vCPU, 4 GiB RAM, and a 32 GiB
disk. Terraform provisions the container and Ansible installs pinned versions
of Node.js and Paperclip, then runs the app as a dedicated systemd user.

The app uses authenticated private-network mode and embedded PostgreSQL.
An internal reverse proxy provides HTTPS through the homelab certificate
authority. Local DNS points a private name at that proxy. The first admin
account is claimed in a browser from the trusted LAN.

The guest is included in the staggered Proxmox backup schedule. An offsite
backup separately takes a consistent Paperclip database dump and includes
configuration, instance keys, and attachments in an encrypted restic backup.
It excludes the live PostgreSQL data directory. A staging test confirmed that
the required files and a fresh dump are present.

Deployment checks confirmed the health API returns `ok`, HTTPS validates
against the internal CA, an unauthenticated application API request is denied,
and the Zabbix agent responds to a server query.
