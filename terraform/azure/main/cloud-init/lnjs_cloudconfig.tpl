#cloud-config
package_upgrade: true
packages:
write_files:
  - owner: ${admin_username}:${admin_username}
  - path: /home/${admin_username}/myapp/index.js
    content: |
      var express = require('express')
      var app = express()
      var os = require('os');
      app.get('/', function (req, res) {
          var Connection = require('tedious').Connection;

          var config = {
              server: '${sql_dns}', //update me
              authentication: {
                  type: 'default',
                  options: {
                      userName: '${sql_sa_user}', //update me
                      password: '${sql_sa_password}' //update me
                  }
              }
          };

          var connection = new Connection(config);
          connection.on('connect', function (err) {
              if (err) {
                  console.log(err);
              }  
              else    {  
                console.log("Connected");
                executeStatement();
              }
          });

          var Request = require('tedious').Request;
          var TYPES = require('tedious').TYPES;

          function executeStatement() {
              request = new Request("SELECT @@VERSION;", function (err) {
                  if (err) {
                      console.log(err);
                  }
              });
              var result = 'Hello World from host1 ' + os.hostname() + '! \n';
              request.on('row', function (columns) {
                  columns.forEach(function (column) {
                      if (column.value === null) {
                          console.log('NULL');
                      } else {
                          result += column.value + " ";
                      }
                  });
                  res.send(result);
                  result = "";
              });

              connection.execSql(request);
          }
      });
      app.listen(3000, function () {
          console.log('Hello world app listening on port 3000!')
      })
runcmd:
  - sudo curl -sL https://deb.nodesource.com/setup_13.x | sudo bash -
  - sudo apt install nodejs -y
  - sudo npm config set proxy http://${proxy}:3128/
  - sudo npm config set https-proxy http://${proxy}:3128/
  - cd "/home/${admin_username}/myapp"
  #- npm init
  - sudo npm install express -y
  - sudo npm install tedious -y
  - sudo npm install -g pm2 -y
  - sudo pm2 start /home/${admin_username}/myapp/index.js
  - sudo pm2 startup


