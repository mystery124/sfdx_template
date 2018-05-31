#!/bin/bash

cp build/pushToDEV/.forceignore .forceignore -f
openssl aes-256-cbc -k $PASS -in ./assets/dev_server.key.enc -out ./assets/dev_server.key -d
sfdx force:auth:jwt:grant --clientid $CONSUMERKEY --jwtkeyfile ./assets/dev_server.key --username $USERNAME -a sd1ps -r https://test.salesforce.com
sfdx force:source:convert -d ./mdapioutput/
sfdx force:mdapi:deploy -d ./mdapioutput/ -u dev -w 100
# sfdx force:apex:test:run -u dev -c -d ./report -r junit --wait 100
rm -f ./assets/dev_server.key