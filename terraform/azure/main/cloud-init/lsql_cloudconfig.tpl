#cloud-config
package_upgrade: true
packages:
  - nginx
runcmd:
  - sudo rm -rf /etc/yum.repos.d/mssql-server.repo
  - sudo curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/rhel/7/mssql-server-2019.repo
  - sudo yum install -y mssql-server

