#cloud-config
package_upgrade: true
packages:
  - nginx
write_files:
  - owner: www-data:www-data
  - path: /etc/nginx/sites-available/default
    content: |
      server {
        listen 80;
        location / {
          proxy_pass http://localhost:3000;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection keep-alive;
          proxy_set_header Host $host;
          proxy_cache_bypass $http_upgrade;
        }
      }
  - owner: ${admin_username}:${admin_username}
  - path: /home/${admin_username}/myapp/index.js
    content: |
      var express = require('express')
      var app = express()
      var os = require('os');
      app.get('/', function (req, res) {
          var Connection = require('tedious').Connection;

          var config = {
              server: '${sql_ip_address}', //update me
              authentication: {
                  type: 'default',
                  options: {
                      userName: 'sa', //update me
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
  - service nginx restart
  - cd "/home/${admin_username}/myapp"
  - curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
  - sudo apt install nodejs -y
  - npm init
  - npm install express -y
  - npm install tedious -y
  - npm install -g pm2 -y
  - pm2 start /home/${admin_username}/myapp/index.js


