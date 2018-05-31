/*------------------------------------------------------------
Author:        Filip Rafalowicz
Company:       Nike/Polsource
Zone:          Europe
Description:   Container class for Identity API callouts to webservice
Inputs:        -
Test Class:    -
History
<Date>      <Authors Name>     <Brief Description of Change>
01.02.2018  Filip Rafalowicz   creation
------------------------------------------------------------*/
public class IS_IdentityAPIClientContainer {
    private static String ADDRESS_TYPE_BILLING  = 'billing';
    private static String ADDRESS_TYPE_SHIPPING = 'shipping';
    private static String ADDRESS_TYPE_HOME     = 'home';
    /*------------------------------------------------------------
    Author:        Filip Rafalowicz
    Company:       Nike/Polsource
    Zone:          Europe
    Description:   Profile identity retrieve by upmId
                   https://confluence.nike.com/pages/viewpage.action?pageId=185730337
    Inputs:        -
    Test Class:    -
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    01.02.2018  Filip Rafalowicz   creation
    ------------------------------------------------------------*/
    public class ProfileRetrieveByUpmId extends IS_IdentityAPIClientAbstract {
        /*------------------------------------------------------------
        Author:        Filip Rafalowicz
        Company:       Nike/Polsource
        Description:   Constructor with needed params for Profile Retrieve
        Inputs:        upmId
        Returns:       -
        History
        <Date>      <Authors Name>     <Brief Description of Change>
        01.02.2018  Filip Rafalowicz   creation
        ------------------------------------------------------------*/
        public ProfileRetrieveByUpmId(String upmId) {
            this.request = createRequest('GET');
            this.request.setEndpoint(IDENTITY_API_ENDPOINT_NAME + IDNUSER_DETAIL_PATH + VIEW_ID + '/' + upmId);
            this.responseObjectType = ProfileRetrieveResponse.class;
        }
    }

    /*------------------------------------------------------------
    Author:        Filip Rafalowicz
    Company:       Nike/Polsource
    Zone:          Europe
    Description:   Profile identity retrieve by email
                   https://confluence.nike.com/pages/viewpage.action?pageId=185730337
    Inputs:        -
    Test Class:    -
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    01.02.2018  Filip Rafalowicz   creation
    ------------------------------------------------------------*/
    public class ProfileRetrieveByEmail extends IS_IdentityAPIClientAbstract {
        /*------------------------------------------------------------
        Author:        Filip Rafalowicz
        Company:       Nike/Polsource
        Description:   Constructor with needed params for Profile Retrieve
        Inputs:        email
        Returns:       -
        History
        <Date>      <Authors Name>     <Brief Description of Change>
        01.02.2018  Filip Rafalowicz   creation
        ------------------------------------------------------------*/
        public ProfileRetrieveByEmail(String email) {
            this.request = createRequest('GET');
            this.request.setEndpoint(IDENTITY_API_ENDPOINT_NAME + IDNUSER_DETAIL_PATH + VIEW_ID + USERNAME_PATH + email);
        }
    }

    /*------------------------------------------------------------
    Author:        Filip Rafalowicz
    Company:       Nike/Polsource
    Zone:          Europe
    Description:   Profile identity update
                   https://confluence.nike.com/pages/viewpage.action?pageId=185730337
    Inputs:        -
    Test Class:    -
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    22.02.2018  Filip Rafalowicz   creation
    ------------------------------------------------------------*/
    public class ProfileUpdate extends IS_IdentityAPIClientAbstract {
        /*------------------------------------------------------------
        Author:        Filip Rafalowicz
        Company:       Nike/Polsource
        Description:   Constructor with needed params for Profile Update
        Inputs:        upmId, requestPayload
        Returns:       -
        History
        <Date>      <Authors Name>     <Brief Description of Change>
        22.02.2018  Filip Rafalowicz   creation
        ------------------------------------------------------------*/
        public ProfileUpdate(String upmId, UpdateProfileRequest requestPayload) {
            this.request = createRequest('PUT');
            this.request.setEndpoint(IDENTITY_API_ENDPOINT_NAME + IDNUSER_DETAIL_PATH + VIEW_ID + '/' + upmId);
            this.request.setBody(JSON.serialize(requestPayload, true));
        }
    }

    /*------------------------------------------------------------
    Author:        Filip Rafalowicz
    Company:       Nike/Polsource
    Zone:          Europe
    Description:   Class for Identity Profile Retrieve response
    Inputs:        -
    Test Class:    -
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    01.02.2018  Filip Rafalowicz   creation
    ------------------------------------------------------------*/
    public class ProfileRetrieveResponse {
        public Boolean emailonly;
        public String userType;
        public String upmId;
        public String nuId;
        public String gender;
        public String verifiedphone;
        public String screenname;
        public Measurements measurements;
        public ProfileRetrieveAccount account;
        public ProfileAddress address;
        public ProfileName name;
        public ProfileDateOfBirth dob;
        public ProfileEmails emails;

        public ProfileRetrieveResponse(Map<String, Object> response) {
            if (response != null) {
                this.emailonly            = (Boolean) response.get('emailonly');
                this.userType             = (String) response.get('userType');
                this.upmId                = (String) response.get('upmId');
                this.nuId                 = (String) response.get('nuId');
                this.gender               = (String) response.get('gender');
                this.verifiedphone        = (String) response.get('verifiedphone');
                this.screenname           = (String) response.get('screenname');
                this.measurements         = new Measurements();
                this.account              = new ProfileRetrieveAccount();
                this.account.registration = new Registration();
                this.address              = new ProfileAddress();
                this.name                 = new ProfileName();
                this.dob                  = new ProfileDateOfBirth();

                if (response.containsKey('account')) {
                    Map<String, Object> accountObj = (Map<String, Object>) response.get('account');

                    if (accountObj != null && accountObj.containsKey('registration')) {
                        Map<String, Object> registration = (Map<String, Object>) accountObj.get('registration');
                        this.account.registration.date_x = (Long) registration.get('date');
                    }
                }

                if (response.containsKey('measurements')) {
                    Map<String, Object> measurementsObj = (Map<String, Object>) response.get('measurements');

                    if (measurementsObj.containsKey('shoeSizeAlpha')) {
                        this.measurements.shoeSizeAlpha = (String) measurementsObj.get('shoeSizeAlpha');
                    }
                }

                if (response.containsKey('address')) {
                    Map<String, Object> addressObj = (Map<String, Object>) response.get('address');

                    if (addressObj.containsKey('shipping')) {
                        Map<String, Object> shipping = (Map<String, Object>) addressObj.get('shipping');
                        this.address.shipping        = this.buildAddress(shipping);
                    }

                    if (addressObj.containsKey('billing')) {
                        Map<String, Object> billing = (Map<String, Object>) addressObj.get('billing');
                        this.address.billing        = this.buildAddress(billing);
                    }

                    if (addressObj.containsKey('home')) {
                        Map<String, Object> home = (Map<String, Object>) addressObj.get('home');
                        this.address.home        = this.buildAddress(home);
                    }
                }

                if (response.containsKey('name')) {
                    Map<String, Object> nameObj = (Map<String, Object>) response.get('name');

                    if (nameObj.containsKey('latin')) {
                        Map<String, Object> latin = (Map<String, Object>) nameObj.get('latin');
                        this.name.latin           = new ProfileNameLatin();
                        this.name.latin.family    = (String) latin.get('family');
                        this.name.latin.given     = (String) latin.get('given');
                    }
                }

                if (response.containsKey('dob')) {
                    Map<String, Object> dobObj = (Map<String, Object>) response.get('dob');
                    this.dob.day               = (Integer) dobObj.get('day');
                    this.dob.month             = (Integer) dobObj.get('month');
                    this.dob.year              = (Integer) dobObj.get('year');
                }

                if (response.containsKey('emails')) {
                    Map<String, Object> emailsObj = (Map<String, Object>) response.get('emails');
                    this.emails                   = new ProfileEmails();

                    if (emailsObj.containsKey('primary')) {
                        Map<String, Object> primary = (Map<String, Object>) emailsObj.get('primary');
                        this.emails.primary         = new ProfileEmail();
                        this.emails.primary.email   = (String) primary.get('email');
                    }
                }
            }
        }

        /*------------------------------------------------------------
        Author:        Filip Rafalowicz
        Company:       Nike/Polsource
        Description:   Builds address from Map<String, Object>
        Inputs:        Map<String, Object>
        Returns:       -
        History
        <Date>      <Authors Name>     <Brief Description of Change>
        21.03.2018  Filip Rafalowicz   creation
        ------------------------------------------------------------*/
        private ProfileSingleAddress buildAddress(Map<String, Object> address) {
            ProfileSingleAddress singleAddress = new ProfileSingleAddress();

            singleAddress.guid     = (String) address.get('guid');
            singleAddress.line1    = (String) address.get('line1');
            singleAddress.country  = (String) address.get('country');
            singleAddress.locality = (String) address.get('locality');
            singleAddress.province = (String) address.get('province');
            singleAddress.code     = (String) address.get('code');

            return singleAddress;
        }
    }

    /*------------------------------------------------------------
    Author:        Filip Rafalowicz
    Company:       Nike/Polsource
    Zone:          Europe
    Description:   Class for Measurements
    Inputs:        -
    Test Class:    -
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    07.02.2018  Filip Rafalowicz   creation
    ------------------------------------------------------------*/
    public class Measurements {
        public String shoeSizeAlpha;
    }

    /*------------------------------------------------------------
    Author:        Filip Rafalowicz
    Company:       Nike/Polsource
    Zone:          Europe
    Description:   Class for date of birth
    Inputs:        -
    Test Class:    -
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    21.03.2018  Filip Rafalowicz   creation
    ------------------------------------------------------------*/
    public class ProfileDateOfBirth {
        public Integer day;
        public Integer month;
        public Integer year;
    }

    /*------------------------------------------------------------
    Author:        Filip Rafalowicz
    Company:       Nike/Polsource
    Zone:          Europe
    Description:   Class for Account
    Inputs:        -
    Test Class:    -
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    07.02.2018  Filip Rafalowicz   creation
    ------------------------------------------------------------*/
    public class ProfileRetrieveAccount {
        public Registration registration;
    }

    /*------------------------------------------------------------
    Author:        Filip Rafalowicz
    Company:       Nike/Polsource
    Zone:          Europe
    Description:   Class for Registration
    Inputs:        -
    Test Class:    -
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    07.02.2018  Filip Rafalowicz   creation
    ------------------------------------------------------------*/
    public class Registration {
        public Long date_x;
    }

    /*------------------------------------------------------------
    Author:        Filip Rafalowicz
    Company:       Nike/Polsource
    Zone:          Europe
    Description:   IdentityErrorResponse
    Inputs:        -
    Test Class:    -
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    20.02.2018  Filip Rafalowicz   creation
    ------------------------------------------------------------*/
    public class IdentityErrorResponse implements COM_CalloutClientError {
        public List<Error> errors;

        public String getMessage() {
            String message = '';

            if (errors != null) {
                for (Error error : errors) {
                    message += error.message;
                }
            }

            return message;
        }

        public Integer getStatus() {
            return (errors != null && !errors.isEmpty()) ? errors[0].code : 0;
        }
    }

    /*------------------------------------------------------------
    Author:        Filip Rafalowicz
    Company:       Nike/Polsource
    Zone:          Europe
    Description:   Error
    Inputs:        -
    Test Class:    -
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    20.02.2018  Filip Rafalowicz   creation
    ------------------------------------------------------------*/
    public class Error {
        public String message;
        public Integer code;
    }

    /*------------------------------------------------------------
    Author:        Filip Rafalowicz
    Company:       Nike/Polsource
    Zone:          Europe
    Description:   UpdateProfileRequest
    Inputs:        -
    Test Class:    -
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    22.02.2018  Filip Rafalowicz   creation
    ------------------------------------------------------------*/
    public class UpdateProfileRequest {
        public ProfileName name;
        public ProfileEmails emails;
        public ProfileAddress address;
        public Measurements measurements;

        public UpdateProfileRequest(Account consumer) {
            this.name    = new ProfileName(consumer.FirstName, consumer.LastName);
            this.address = new ProfileAddress(consumer);
        }

        public UpdateProfileRequest() {}
    }

    /*------------------------------------------------------------
    Author:        Filip Rafalowicz
    Company:       Nike/Polsource
    Zone:          Europe
    Description:   ProfileName
    Inputs:        -
    Test Class:    -
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    22.02.2018  Filip Rafalowicz   creation
    ------------------------------------------------------------*/
    public class ProfileName {
        public ProfileNameLatin latin;

        public ProfileName(String firstName, String lastName) {
            this.latin = new ProfileNameLatin(firstName, lastName);
        }

        public ProfileName() {}
    }

    /*------------------------------------------------------------
    Author:        Filip Rafalowicz
    Company:       Nike/Polsource
    Zone:          Europe
    Description:   ProfileNameLatin
    Inputs:        -
    Test Class:    -
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    22.02.2018  Filip Rafalowicz   creation
    ------------------------------------------------------------*/
    public class ProfileNameLatin {
        public String given;
        public String family;

        public ProfileNameLatin(String firstName, String lastName) {
            this.given  = firstName;
            this.family = lastName;
        }

        public ProfileNameLatin() {}
    }

    /*------------------------------------------------------------
    Author:        Filip Rafalowicz
    Company:       Nike/Polsource
    Zone:          Europe
    Description:   ProfileEmails
    Inputs:        -
    Test Class:    -
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    22.02.2018  Filip Rafalowicz   creation
    ------------------------------------------------------------*/
    public class ProfileEmails {
        public ProfileEmail primary;

        public ProfileEmails() {}

        public ProfileEmails(String email) {
            this.primary = new ProfileEmail(email);
        }
    }

    /*------------------------------------------------------------
    Author:        Filip Rafalowicz
    Company:       Nike/Polsource
    Zone:          Europe
    Description:   ProfileEmail
    Inputs:        -
    Test Class:    -
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    22.02.2018  Filip Rafalowicz   creation
    ------------------------------------------------------------*/
    public class ProfileEmail {
        public String email;

        public ProfileEmail() {}

        public ProfileEmail(String email) {
            this.email = email;
        }
    }

    /*------------------------------------------------------------
    Author:        Filip Rafalowicz
    Company:       Nike/Polsource
    Zone:          Europe
    Description:   ProfileAddress
    Inputs:        -
    Test Class:    -
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    22.02.2018  Filip Rafalowicz   creation
    ------------------------------------------------------------*/
    public class ProfileAddress {
        public ProfileSingleAddress shipping;
        public ProfileSingleAddress billing;
        public ProfileSingleAddress home;

        public ProfileAddress(Account consumer) {
            if (String.isNotBlank(consumer.ShippingCountry) 
                && String.isNotBlank(consumer.ShippingCity) 
                && String.isNotBlank(consumer.ShippingStreet)
            ) {
                this.shipping = new ProfileSingleAddress(
                    consumer.ShippingCountry, 
                    consumer.ShippingPostalCode, 
                    consumer.ShippingState, 
                    consumer.ShippingCity, 
                    consumer.ShippingStreet, 
                    ADDRESS_TYPE_SHIPPING
                );
            }

            if (String.isNotBlank(consumer.BillingCountry) 
                && String.isNotBlank(consumer.BillingCity) 
                && String.isNotBlank(consumer.BillingStreet)
            ) {
                this.billing = new ProfileSingleAddress(
                    consumer.BillingCountry, 
                    consumer.BillingPostalCode,
                    consumer.BillingState,
                    consumer.BillingCity,
                    consumer.BillingStreet, 
                    ADDRESS_TYPE_BILLING
                );
            }

            if (String.isNotBlank(consumer.PersonMailingCountry) 
                && String.isNotBlank(consumer.PersonMailingCity) 
                && String.isNotBlank(consumer.PersonMailingStreet)
            ) {
                this.home = new ProfileSingleAddress(
                    consumer.PersonMailingCountry, 
                    consumer.PersonMailingPostalCode,
                    consumer.PersonMailingState,
                    consumer.PersonMailingCity,
                    consumer.PersonMailingStreet, 
                    ADDRESS_TYPE_HOME
                );
            }
        }

        public ProfileAddress() {}
    }

    /*------------------------------------------------------------
    Author:        Filip Rafalowicz
    Company:       Nike/Polsource
    Zone:          Europe
    Description:   ProfileSingleAddress
    Inputs:        -
    Test Class:    -
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    22.02.2018  Filip Rafalowicz   creation
    ------------------------------------------------------------*/
    public class ProfileSingleAddress {
        public String guid;
        public String country;
        public String code;
        public String province;
        public String locality;
        public String line1;
        public String type;
        public Boolean preferred;

        public ProfileSingleAddress(
            String country, 
            String code, 
            String province, 
            String locality, 
            String line1, 
            String type
        ) {
            this.guid      = generateGUID();
            this.country   = country;
            this.code      = code;
            this.province  = province;
            this.locality  = locality;
            this.line1     = line1;
            this.type      = type;
            this.preferred = true;
        }

        public ProfileSingleAddress() {}

        private String generateGUID() {
            Blob b      = Crypto.generateAesKey(128);
            String h    = EncodingUtil.convertToHex(b);
            String guid = h.subString(0, 8) + '-' + h.subString(8, 12) + '-' + h.subString(12, 16) + '-' + h.subString(16, 20) + '-' + h.subString(20);

            return guid;
        }
    }
}