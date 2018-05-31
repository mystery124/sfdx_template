@isTest
public class COM_TestHelper {

    private static String US_ISO_CODE = 'US';

    public class ContactBuilder {
        private Contact obj;

        public ContactBuilder build() {
            obj = new Contact(
                    FirstName = 'Tester',
                    LastName = 'Tester',
                    Email = 'example@example.com'
            );
            return this;
        }

        public ContactBuilder withEmail(String email) {
            obj.Email = email;
            return this;
        }

        public ContactBuilder withBirthdate(Date birthDate) {
            obj.Birthdate = birthDate;
            return this;
        }

        public ContactBuilder save() {
            insert obj;
            return this;
        }

        public Contact getRecord() {
            return obj;
        }
    }

    public class AccountBuilder {
        private Account obj;

        public AccountBuilder build() {
            RecordType personRecType = COM_RecordTypeUtils.getRecordTypeByName(Account.class, 'PERSON_ACCOUNT_RT');
            obj = new Account(
                    RecordTypeId = personRecType.Id,
                    FirstName = 'Clark',
                    LastName = 'Kent',
                    BillingCity = 'NY',
                    BillingState = 'CA',
                    BillingCountry = US_ISO_CODE,
                    BillingPostalCode = '91007',
                    BillingStreet = 'St 123',
                    ShippingCity = 'NY',
                    ShippingState = 'CA',
                    ShippingCountry = US_ISO_CODE,
                    ShippingPostalCode = '91007',
                    ShippingStreet = 'St 123'
            );

            return this;
        }

        public AccountBuilder buildPersonAccount(){
            return this.build();
        }

        public AccountBuilder withName(String val){
            obj.Name = val;
            return this;
        }

        public AccountBuilder withRecordType(RecordType rt){
            obj.RecordTypeId = rt.Id;
            return this;
        }

        public AccountBuilder save() {
            insert obj;
            return this;
        }


        public Account getRecord() {
            return obj;
        }
    }
}