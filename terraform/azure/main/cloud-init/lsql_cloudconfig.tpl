#cloud-config
package_upgrade: true
packages:
runcmd:
  # Can monitor by using tail -f /var/log/cloud-init-output.log
  - echo Adding Microsoft repositories...
  - sudo curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
  - sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/16.04/mssql-server-2019.list)"
  - sudo curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list

  - echo Running apt-get update -y...
  - sudo apt-get update

  - echo Installing SQL Server...
  - sudo apt-get install mssql-server -y

  - echo Running mssql-conf setup...
  - sudo MSSQL_SA_PASSWORD="${sa_password}" MSSQL_PID="express" /opt/mssql/bin/mssql-conf -n setup accept-eula

  - echo Configuring UFW to allow traffic on port 1433...
  - sudo ufw allow 1433/tcp
  - sudo ufw reload

  - echo Restarting SQL Server...
  - sudo systemctl restart mssql-server

  - echo Installing SQL Server Tools...
  - sudo apt-get update 
  - sudo ACCEPT_EULA=Y apt-get install mssql-tools unixodbc-dev -y
  - sudo apt-get install mssql-tools -y

  - echo Adding SQL Server tools to your path...
  - echo PATH="$PATH:/opt/mssql-tools/bin" >> ~/.bash_profile
  - echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
  - source ~/.bashrc