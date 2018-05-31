# Copy .forceignore
cp build/buildQA/.forceignore .forceignore -f

openssl aes-256-cbc -k $PASS -in ./assets/server.key.enc -out ./assets/server.key -d
sfdx force:auth:jwt:grant --clientid $CONSUMERKEY_QA --jwtkeyfile ./assets/server.key --username $USERNAME_QA -a qa -r https://test.salesforce.com

openssl aes-256-cbc -k $PASS -in ./assets/dev_server.key.enc -out ./assets/dev_server.key -d
sfdx force:auth:jwt:grant --clientid $CONSUMERKEY_DEV --jwtkeyfile ./assets/dev_server.key --username $USERNAME_DEV -a dev -r https://test.salesforce.com

sfdx force:data:soql:query --query "SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue'" -u dev --json > sourceOrg.json
sfdx force:data:soql:query --query "SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue'" -u qa --json > destinationOrg.json
for filename in ./force-app/main/default/flows/*; do 
	python ./build/mapProcessBuilderQueues.py ./sourceOrg.json ./destinationOrg.json ./$filename; 
done
rm ./sourceOrg.json
rm ./destinationOrg.json

sfdx force:source:convert -d ./mdapioutput
sfdx force:mdapi:deploy -d ./mdapioutput -u qa -w 100

rm -f ./assets/server.key
rm -f ./assets/dev_server.key