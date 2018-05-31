export SFDX_AUTOUPDATE_DISABLE=true
export SFDX_USE_GENERIC_UNIX_KEYCHAIN=true
export SFDX_DOMAIN_RETRY=300
export SFDX_DEBUG=1
export SFDX_AUTOUPDATE_DISABLE=true

sfdx force:auth:jwt:grant --clientid $CONSUMERKEY --jwtkeyfile "$SERVER_KEY" --username $USERNAME -a dev -r https://test.salesforce.com

sfdx force:mdapi:retrieve -s -r ./retrieve -p $CHANGE_SET_NAME -u dev

unzip ./retrieve/unpackaged.zip -d ./retrieve/package

sfdx force:mdapi:convert -r ./retrieve/package -d ./retrieve/sfdx

cp -af ./retrieve/sfdx/main/. ./force-app/config/
git checkout -b $CHANGE_SET_NAME
git add force-app
git commit -m "$CHANGE_SET_NAME - build number $BUILD_NUMBER"