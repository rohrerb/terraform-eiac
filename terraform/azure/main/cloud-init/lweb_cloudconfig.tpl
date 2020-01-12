#cloud-config
package_upgrade: true
packages:
  - nginx
runcmd:
  - date "+%H:%M:%S   %d/%m/%y" >> /tmp/worked.log

