#cloud-config
package_upgrade: true
packages:
  - squid
runcmd:
  - sed -i '/acl SSL_ports/i acl localnet src ${network_octets}.0.0/16' /etc/squid/squid.conf
  - sed -i '/http_access deny all/i http_access allow localnet' /etc/squid/squid.conf
  - systemctl enable squid
  - systemctl restart squid



