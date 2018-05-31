# Code analysis
/salesforce/pmd-bin-5.8.1/bin/run.sh pmd -d ./force-app -R PMD_rules.xml -r report.html -failOnViolation false

# Salesforce DX build
export SFDX_AUTOUPDATE_DISABLE=true
export SFDX_USE_GENERIC_UNIX_KEYCHAIN=true
export SFDX_DOMAIN_RETRY=300
export SFDX_DEBUG=1
export SFDX_AUTOUPDATE_DISABLE=true
openssl aes-256-cbc -k $PASS -in ./assets/server.key.enc -out ./assets/server.key -d
sfdx force:auth:jwt:grant --clientid $CONSUMERKEY --jwtkeyfile ./assets/server.key --username $USERNAME --setdefaultdevhubusername -a HubOrg
sfdx force:org:create -v HubOrg -s -f config/project-scratch-def.json -a ciorg
sfdx force:source:push -u ciorg -f
sfdx force:apex:test:run -u ciorg -c -d ./report -r junit

sfdx force:org:delete -u ciorg -p
rm -f ./assets/server.key