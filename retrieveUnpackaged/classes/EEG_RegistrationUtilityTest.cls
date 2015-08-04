/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.  
 *        
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *  
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *  
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)
/*This class is used to test the following Classes
    1. EEG_RegistrationUtility
    2. EEG_RegistrationHelperTest
*/
private class EEG_RegistrationUtilityTest{
    static PriceBookEntry pricbk; 
    
    static testMethod void EEG_RegistrationUtility_And_EEG_RegistrationHelperTest_Test() 
    {
        String STANDARD_PRICEBOOK_NAME = 'Standard Price Book';
        EEG_RegistrationUtility eegRegUtility = new EEG_RegistrationUtility();
        Test.startTest();       
        Event_Header__c event = EEG_RegistrationHelperTest.createNewEvent('Test Event');
        
        //Test "isPromocodeRequiredForRegistrationForTheAttendeeType" method.
        Event_Attendee_Type_Configuration__c attTypeConf = EEG_RegistrationHelperTest.createNewAttendeeTypeConfiguration(event.Id, 'Customer', false);
        Event_Attendee_Type_Configuration__c attTypeConf1 = EEG_RegistrationHelperTest.createNewAttendeeTypeConfiguration(event.Id, 'Partner', true);
        
        eegRegUtility.isPromocodeRequiredForRegistrationForTheAttendeeType(event.Id, 'Customer');
        eegRegUtility.isPromocodeRequiredForRegistrationForTheAttendeeType(event.Id, 'Partner');
        
        eegRegUtility.isPromocodeRequiredForEmailOrEmailDomain(event.Id, 'email', false);
        
        //Test "isValidPromoCodeForTheAttendeeType" method.
        Product2 prod  = EEG_RegistrationHelperTest.createNewProduct(event.Id, 'promocode0000', 'Registration', 'Amount', 20, 'Customer');
        prod.Conference_Type__c = 'Client';
        update prod;
        Product2 prod1 = EEG_RegistrationHelperTest.createNewProduct(event.Id, 'promocode0001', 'PromoCode', 'Amount', 20, null); 
        prod1.Attendee_Type_Special__c  = '';
        update prod1;
        Product2 prod2 = EEG_RegistrationHelperTest.createNewProduct(event.Id, 'promocode0000', 'Workshop', 'Amount', 20, 'Customer');
         
        //Product2 prod1 = EEG_RegistrationHelperTest.createNewProduct(event.Id, 'promocode0001', 'PromoCode', 'Amount', 20, 'Customer');  
        
            
        testPromoCodeMethodes(prod1,eegRegUtility,STANDARD_PRICEBOOK_NAME,event.id); 
        testPromoCodeMethodes(prod2,eegRegUtility,STANDARD_PRICEBOOK_NAME,event.id); 
        //testUpdateUser(eegRegUtility);
         
        eegRegUtility.isValidPromoCodeForTheAttendeeType(event.Id, 'promocode0001', 'Customer');  
        eegRegUtility.isValidPromoCodeForTheAttendeeType(event.Id, null, 'Customer');     
        
        eegRegUtility.isValidPromoCodeForAttendeeTypeConfType(event.Id, 'promocode0001', 'priceBookName', 'Customer', 'Client');
        eegRegUtility.isValidPromoCodeForAttendeeTypeConfType(event.Id, 'promocode0001', 'priceBookName', null, 'Client');
        eegRegUtility.isValidPromoCodeForAttendeeTypeConfType(event.Id, 'promocode0001', 'priceBookName', 'Customer', null);
        eegRegUtility.isValidPromoCodeForAttendeeTypeConfType(event.Id, 'promocode0001', 'priceBookName', null, null);
        
        //Test "isValidPromoCode" method.
        eegRegUtility.isValidPromoCode(event.Id, 'promocode0001');
        eegRegUtility.isValidPromoCode(event.Id, null);
        eegRegUtility.isValidPromoCodeForAttendeeTypeConfTypeAttTypeSpec(event.id,'promocode0001','priceBookName','Workshop','Workshop','Speaker');
        //Test "isBlackListedEmailDomain" method.  
        Event_Email_Black_List__c emailBlackList = EEG_RegistrationHelperTest.createNewEmailBlackList(event.Id, '@gmail.com');
        eegRegUtility.isBlackListedEmailDomain(event.Id, 'test@gmail.com');
        event.Execute_Black_White_List_Validation__c = true;
        update event;
        eegRegUtility.isBlackListedEmailDomain(event.Id, 'test@yahoo.com');
        eegRegUtility.isWhiteListedEmailDomain(event.Id, 'test@yahoo.com');
        //Test "isWhiteListedEmailAddress" method.
        Event_Email_Black_List__c emailWhiteList = EEG_RegistrationHelperTest.createNewEmailBlackList(event.Id, 'test@gmail.com');
        eegRegUtility.isWhiteListedEmailAddress(event.Id, 'test@gmail.com');
        eegRegUtility.isWhiteListedEmailAddress(event.Id, 'test@yahoo.com');
        eegRegUtility.isWhiteListedEmailAddress(event.Id, null);
        
        
        //Test "isAttendeeTypeWhiteOrBlackListed" method.
        Event_Attendee_Type_Configuration__c attTypeConfWhiteBlack = EEG_RegistrationHelperTest.createNewAttendeeTypeConfiguration(event.Id, 'Attendee', false);
        eegRegUtility.isAttendeeTypeWhiteOrBlackListed(event.Id, 'Attendee', 'test@yahoo.com');
        attTypeConfWhiteBlack.Whitelist_Blacklist__c = 'WhiteList';
        upsert attTypeConfWhiteBlack;
        //Event_Email_Black_List__c emailWhiteAndBlackList = EEG_RegistrationHelperTest.createNewEmailBlackList(event.Id, 'test@gmail.com');
        eegRegUtility.isAttendeeTypeWhiteOrBlackListed(event.Id, 'Attendee', 'test@gmail.com');
        attTypeConfWhiteBlack.Whitelist_Blacklist__c = 'BlackList';
        upsert attTypeConfWhiteBlack;
        eegRegUtility.isAttendeeTypeWhiteOrBlackListed(event.Id, 'Attendee', 'test@yahoo.com');
        eegRegUtility.isAttendeeTypeWhiteOrBlackListed(event.Id, 'Attendee', null);
        eegRegUtility.isAttendeeTypeWhiteOrBlackListed(event.Id, 'Unknown', null);
        
        //Test "createUser" method. Which also executes "getContactFromEmail".
        Account acc = EEG_RegistrationHelperTest.createNewAccount('Test Account Name');
        String customerPortalUserId = eegRegUtility.createUser(acc.Id, 'test'+Math.round(Math.random()*Math.pow(10, 7))+'@salesforce.com.event.1', 'Password!123%SFDC', '.eventSuffix.1', 'firstname', 'lastname', 'company');
        
        //Test "loginUser" method.
        PageReference requestedPageRef;
        eegRegUtility.loginUser('username', 'password', 'programUserSuffix', requestedPageRef, 'successPageURL');
        eegRegUtility.loginUser('', '', 'programUserSuffix', requestedPageRef, 'successPageURL');
        
        //Test "forgotPassword" method.
        eegRegUtility.forgotPassword('username', 'programUserSuffix',requestedPageRef);
        eegRegUtility.forgotPassword('', 'programUserSuffix',requestedPageRef);
        String externalUserName = 'tests@mail.com';
        
        
        //Test "changePassword" method.
        eegRegUtility.changePassword('newPassword', 'newPassword','oldpassword');
        eegRegUtility.changePassword('', 'verifyNewPassword','oldpassword');
        eegRegUtility.changePassword('newPassword', 'verifyNewPassword','oldpassword');
         eegRegUtility.changePassword('newPassword', 'newPassword',null);
         eegRegUtility.isValidText('Test');
         
         
        String accountIds = acc.id;
         eegRegUtility.getSFDCPortalUserNameUsingExternalUserName(accountIds,externalUserName);
        //Test "createRegistration" method.
        Registration__c reg;
        Contact contact = EEG_RegistrationHelperTest.createNewContact(acc.id, 'FName', 'LName', 'test'+Math.round(Math.random()*Math.pow(10, 7))+'@salesforce.com.event.1');
        reg = eegRegUtility.createRegistration(event.Id, contact.Id, reg, UserInfo.getUserId(), 'Saved for Later', 'TestReg', 'contactFirstName', 'contactLastName');
        
        //Test "createOpportunity" method.
        
        Opportunity opp = eegRegUtility.createOpportunity(event.Id, acc.Id, reg.Id, 'eventName', 'USD', STANDARD_PRICEBOOK_NAME, 'contactFirstName', 'contactLastName');
        
        //Test "createOpportunity" method.      
        pricbk = EEG_RegistrationHelperTest.createNewPriceBookEntry(STANDARD_PRICEBOOK_NAME, prod.Id, 'USD', 450);
       
       try{ 
        pricbk =  EEG_RegistrationHelperTest.createNewPriceBookEntry(STANDARD_PRICEBOOK_NAME, prod1.Id, 'USD', 450);
       }
       catch(Exception e){
        
         
       }   
       pricbk = EEG_RegistrationHelperTest.createNewPriceBookEntry(STANDARD_PRICEBOOK_NAME+'Junk', prod1.Id, 'USD', 450);
       
        List<OpportunityLineItem> opptyLineItems1 = eegRegUtility.createOpportunityLineItems(event.Id, STANDARD_PRICEBOOK_NAME, opp.Id, '', 'promocode0001', ''); 
        List<OpportunityLineItem> opptyLineItems2 = eegRegUtility.createOpportunityLineItems(event.Id, STANDARD_PRICEBOOK_NAME, opp.Id, '', 'promocode0001', 'Registration');
        
              
        //testOpportunityLineItemsMethods(eegRegUtility,opp,opptyLineItems1);
        //Test "getOpportunityLineItems" method.
        eegRegUtility.getOpportunityLineItems(reg.Id);        
        
          
        //Test "sendEmail" method.
        List<String> ccEmailAddressList = new List<String>();ccEmailAddressList.add('test@test.com.c1');
        List<String> bccEmailAddressList = new List<String>();bccEmailAddressList.add('test@test.com.c1');
        eegRegUtility.sendEmail(contact.Id, reg.Id, '000000000000000000', '000000000000000000', ccEmailAddressList, bccEmailAddressList, false);
        eegRegUtility.sendEmailWithAttachment(contact.Id, reg.Id,  '000000000000000000', '000000000000000000', ccEmailAddressList, bccEmailAddressList, false, blob.valueof('Attachment'), 'testfileName');
        
        //Test "getContactFromEmail" method.
        eegRegUtility.getContactFromEmail('emailunavailable@email.com.test', acc.Id);
        eegRegUtility.getContactFromEmail(contact.Email, acc.Id);
        
        //Test "getProfileId" method.
        eegRegUtility.getProfileId('System Administrator');
        eegRegUtility.getProfileId('System AdministratorJUNK');
        
        //Test "getPortalUserContactId" method.
        eegRegUtility.getPortalUserContactId('JUNKContactId');
        eegRegUtility.getPortalUserContactId(customerPortalUserId);
        
        //Test "getPortalUserAccount" method.
        eegRegUtility.getPortalUserAccount(customerPortalUserId);
        eegRegUtility.getPortalUserAccount('JUNKUserId');
        
        //Test "isExistingUser" method.
        eegRegUtility.isExistingUser('JUNKUserName');
        eegRegUtility.isExistingUser(UserInfo.getUserName());
        
        //Test "getUserName" method.
        eegRegUtility.getUserName('JUNKUserName@test.com', 'test.com');
        
        //Test "getEventInfo" method.
        eegRegUtility.getEventInfo('');
        eegRegUtility.getEventInfo('JUNKEventId');
        eegRegUtility.getEventInfo(event.id);
        
        //Test "getCurrencySymbol" method.
        eegRegUtility.getCurrencySymbol('JUNKCurrency');
        eegRegUtility.getCurrencySymbol('USD');
        
        
        //Test "pageRedirect" method.
        PageReference pg = new PageReference('TestURL');
        eegRegUtility.pageRedirect(pg, true);
        eegRegUtility.pageRedirect(null, true);
        
        //Test "rerenderPaymentCreditcard" method.
        eegRegUtility.rerenderPaymentCreditcard('methodOfPayment');
        eegRegUtility.rerenderPaymentCreditcard(null);
        
        //Test "getOpportunityLineItems" method.
        eegRegUtility.getOpportunityLineItems(reg.Id);
        
        //Test "updateUser" method.
        
        //Test.startTest();
        //EEG_RegistrationUtility.updateUser(customerPortalUserId,'System Administrator');
       // Test.stopTest();
        
        EEG_RegistrationHelperTest.createNewPayment(reg.Id, 'Registration');
        EEG_RegistrationHelperTest.createNewAttachment(reg.Id);
        
        //Test "encode" method.
        eegRegUtility.encode('');
        eegRegUtility.encode('TestText');
        //Test "encode" method.
        eegRegUtility.decode('');
        eegRegUtility.decode(eegRegUtility.encode('TestText'));
        
        List<String> optionList = new List<String>();
        optionList.add('Test1');
        optionList.add('Test2');
        
        eegRegUtility.getNumberOfRegistrationsForCompanyName(event.Id,'Customer');
        eegRegUtility.getNumberOfRegistrations(event.Id,'Customer');
        
        
        //Test "SelectOptions" method.
        eegRegUtility.getSelectOptions(optionList);
        
        //Test "getCheckInDatesFromAttendeeType" method
        attTypeConf.Available_Check_In_Date__c = '11/2/2013'; 
        update attTypeConf;
        eegRegUtility.getCheckInDatesFromAttendeeType(event.Id,'Customer');
        
        //Test "get Account from Contact" method
        eegRegUtility.getContactAccount(contact.Id);
        String eventid = event.id;
        //Test "get Registration From EventId & ContactId"  method
        eegRegUtility.getRegistrationFromEventIdContactId(eventId,contact.Id);
        
        //Test "createContact"  method
        eegRegUtility.createContact(acc.Id, 'testCreatecontactjive@test.jiveeeg.com','firstname', 'lastname', 'company');
        
        //Test "insertRegistrationErrorLog"  method
        eegRegUtility.insertRegistrationErrorLog(reg.Id, 'error');
        String strr = 'Testy';
        eegRegUtility.insertEventErrorLog(event.Id,'error',strr);
        Registration_Group__c reggroup = new Registration_Group__c();
           reggroup.name='Testing';
           reggroup.Event__c =event.id;
           reggroup.Booth_Sponsorship_Level__c='Platinum EC';
           insert reggroup;
        
        String accountid=acc.id;
        
        String regid = reggroup.id;
        String eventname = event.name;
        
       eegRegUtility.createOpportunityForRegistrationGroup(eventid,accountId, regid,eventname,'', 'STANDARD_PRICEBOOK_NAME', 'Testing');
        eegRegUtility.removeSiteSuffix('userNameInput','programUserSuffix');
        //Test "redirectToLandingPage"  method
        eegRegUtility.getNumberOfDays(eventid);
        PageReference pageRef = Page.EEG_Override_Registration_Delete_Button;
        Test.setCurrentPage(pageRef);
        eegRegUtility.redirectToLandingPage(Page.EEG_Override_Registration_Delete_Button, Page.EEG_Override_Registration_Delete_Button); 
        eegRegUtility.getRegistrationFromEventListContactId(optionList,contact.id);
        event.Is_Registration_Closed__c =true;
        event.Registration_End_Date_Time__c = system.now();
        update event;
        eegRegUtility.getRegistrationGroup(reggroup.id);
        eegRegUtility.getRegGroupOpportunityLineItem(reggroup.id);
        //eegRegUtility.isRegistrationClosed(eventid);
        
        eegRegUtility.getAllProduct('Additional Service', 'Catering Breakfast',event.id);
        eegRegUtility.getRegistrationChildRecords(regid,eventname);
        eegRegUtility.getMultipleLodgingRecords(regid);
        eegRegUtility.fetchRegAndcheckIfDeclined(event.id,contact.email);
        eegRegUtility.getAllGroupRegList(reggroup.id,reg.Id,true);
        
        eegRegUtility.getContactSharedParticipantList(event.id);
        
           
        Test.stopTest();
         
        eegRegUtility.getRegGroupFromRegistration(reg.Id);
        eegRegUtility.getSalesRepDetails(event.id,'All', 'promocode0000');
        List<String> emailList = new List<String>();
        emailList.add('test'+Math.round(Math.random()*Math.pow(10, 7))+'@salesforce.com.event.1');
        eegRegUtility.getContactsFromEmailList(emailList,accountId);
    }  
     static testMethod void TestEEG_RegistrationUtility() 
    {   
        Map<String,OpportunityLineItem> PBE_OldLineItemMap = new Map<String,OpportunityLineItem>();
        Map<String,OpportunityLineItem> PBE_NewLineItemMap = new Map<String,OpportunityLineItem>();
        Test.startTest();       
        
        EEG_RegistrationUtility eegRegUtility = new EEG_RegistrationUtility();
        //Test "getOpportunityLineItems" method        
        Account account= EEG_RegistrationHelperTest.createNewAccount('Test Account Name');        
           
        Event_Header__c event = EEG_RegistrationHelperTest.createNewEvent('Test Event');
        
        Registration_Group__c reggroup = new Registration_Group__c();
        reggroup.name='Testing';
        reggroup.Event__c =event.id;
        reggroup.Booth_Sponsorship_Level__c='Platinum EC';
        insert reggroup;
        
        Contact contact = EEG_RegistrationHelperTest.createNewContact(account.id, 'FName1', 'LName1', 'test'+Math.round(Math.random()*Math.pow(10, 7))+'@salesforce.com.event.2');
        Registration__c reg;   
            
        reg = eegRegUtility.createRegistration(event.Id, contact.Id, reg, UserInfo.getUserId(), 'Saved for Later', 'TestReg', 'contactFirstName', 'contactLastName');
        Registration_Invite__c regInvite = new Registration_Invite__c(Registration__c = REG.ID,Last_Name__c ='PETER');
        insert regInvite; 
        //get standard pricebook
        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        Product2 prd = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',Product_Type__c = 'productType',productCode = 'productType', isActive = true,Order_Of_Display__c = 5,Start_Date__c = system.today()-1,End_Date__c = system.today()+1);
        insert prd;
        
        PricebookEntry pbe = new PricebookEntry (Product2ID=prd.id,Pricebook2ID = standardPb.id,UnitPrice=50, isActive=true);
        insert pbe; 
        
        Opportunity opp = new Opportunity (Name='Opp1',StageName='Stage 0 - Lead Handed Off',CloseDate=Date.today(),Pricebook2Id = pbe.Pricebook2Id, AccountId = account.id, Registration__c = reg.Id,Registration_Group__c = reggroup.id);
        insert opp;        
        
        OpportunityLineItem lineItem = new OpportunityLineItem (Product_Type__c = 'Registration',OpportunityID=opp.id,PriceBookEntryID=pbe.id, quantity=4,totalprice=200);
        insert lineItem;
        PBE_OldLineItemMap.put(lineItem.PriceBookEntryID,lineItem);
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (Product_Type__c = 'Workshop',OpportunityID=opp.id,PriceBookEntryID=pbe.id, quantity=4,totalprice=200);
        insert lineItem1;
        PBE_NewLineItemMap.put(lineItem1.PriceBookEntryID,lineItem);
        
        OpportunityLineItem lineItem2 = new OpportunityLineItem (Product_Type__c = 'PromoCode',OpportunityID=opp.id,PriceBookEntryID=pbe.id, quantity=4,totalprice=200);
        insert lineItem2;
        
        OpportunityLineItem lineItem3 = new OpportunityLineItem (Product_Type__c = 'Event Sponsorship',OpportunityID=opp.id,PriceBookEntryID=pbe.id, quantity=4,totalprice=200);
        insert lineItem3;
        
        OpportunityLineItem lineItem4 = new OpportunityLineItem (Product_Type__c = 'Additional Event Sponsorship',OpportunityID=opp.id,PriceBookEntryID=pbe.id, quantity=4,totalprice=200);
        insert lineItem4;
        
        OpportunityLineItem lineItem5 = new OpportunityLineItem (Product_Type__c = 'Staff Registration Fee',OpportunityID=opp.id,PriceBookEntryID=pbe.id, quantity=4,totalprice=200);
        insert lineItem5;
        
        OpportunityLineItem lineItem6 = new OpportunityLineItem (Product_Type__c = 'Booth',OpportunityID=opp.id,PriceBookEntryID=pbe.id, quantity=4,totalprice=200);
        insert lineItem6;
        
        eegRegUtility.getEffectiveOppLineItems(PBE_OldLineItemMap,PBE_NewLineItemMap);     
        eegRegUtility.getOppLineItemsForDelete(PBE_OldLineItemMap,PBE_NewLineItemMap);             
        eegRegUtility.getOpportunityLineItems(reg.Id);
        
        eegRegUtility.round(null);
        eegRegUtility.round(2.0); 
        eegRegUtility.getAge(null, null);
        eegRegUtility.getAge(System.today(), System.today());
        eegRegUtility.getAllRegistrationInvites(reg.id);
        DateTime dt = system.now();
        eegRegUtility.isAfterCutoffDate(dt);
        
        String Recordtype = 'Registration Record Type';
        system.debug('Recordtype'+Recordtype);
        eegRegUtility.getRecordTypeId(Recordtype); 
        Map<String,String> keyValueMap = new Map<String,String>();
        eegRegUtility.createSelectoptionList(keyValueMap);
        List<String> selectvalues = new List<String>();
        selectvalues.add(Recordtype);
        eegRegUtility.getStringForMultiSelectField(selectvalues);
        
        eegRegUtility.getStringFromMultiSelectWithMap(Recordtype,keyValueMap);
        
        eegRegUtility.getRegistrationGroup(reggroup.id);
        eegRegUtility.getRegGroupOpportunityLineItem(reggroup.id);
        eegRegUtility.isWhitelistedUserName('test@test1.com.sy.c1', event.Id,'sy.c1');
        EEG_RegistrationUtility.activityWrapperClass activityWrapper = new EEG_RegistrationUtility.activityWrapperClass();
        activityWrapper.activityChk1 =false;
        activityWrapper.activityChk2 =false;
        activityWrapper.validateActivity('Ride','Deep Sea Fishing', event.Id);
        activityWrapper.decrementAndIncrementActivityProductCount(prd,true,prd);
        eegRegUtility.createSelectOptionFromList(selectvalues);
        Integer intt = 10;
        String productType = 'productType';
        String externalUserName = 'tests@mail.com';
        String accountId = account.id;
        String eventId = event.id;
        Set<Id> productIds = new Set<Id>();
        productIds.add(prd.id);
        EEG_RegistrationUtility.ProductWrapperClass eegRegUtilityProduct = new EEG_RegistrationUtility.ProductWrapperClass(prd);
        EEG_RegistrationUtility.ProductWrapperClass eegRegUtilityProducts = new EEG_RegistrationUtility.ProductWrapperClass(prd,intt);
        List<EEG_RegistrationUtility.ProductWrapperClass> ListeegRegUtilityProducts = new List<EEG_RegistrationUtility.ProductWrapperClass>();
        
        ListeegRegUtilityProducts.add(eegRegUtilityProduct);
        ListeegRegUtilityProducts.add(eegRegUtilityProducts);
        eegRegUtility.makeProductWrapperReadOnly(ListeegRegUtilityProducts,productType);
        eegRegUtility.makeProductWrapperDropDown(ListeegRegUtilityProducts,productType);
        eegRegUtility.getAllPriceBookEntries(productIds,productType);
        eegRegUtility.getSFDCPortalUserNameUsingExternalUserName(accountId,externalUserName);
        eegRegUtility.getProductAttendeeType(eventId,productType);
        reg.Status__c = 'Registered';
        reg.Share_Contact_Information__c = 'Yes';
        update reg;
        eegRegUtility.getContactSharedParticipantList(event.id);
       
        Test.stopTest();
    }
    
    /*Modified By-:Sourav Nema
      Description-:Test code for isValidPromoCode and getPromoCodeProductDetails method of EEG_RegistrationUtility Class
      */
    
     static void testPromoCodeMethodes(Product2 prod1,EEG_RegistrationUtility eegRegUtility,string standard_pricebook,Id eventId){
        
        Account account= EEG_RegistrationHelperTest.createNewAccount('Test Account Name');        
        
        Event_Header__c event = EEG_RegistrationHelperTest.createNewEvent('Test Event');
        
        EEG_SiteProperties siteProperty = new EEG_SiteProperties('Test123');
            siteProperty.ACCOUNT_ID = account.id;
            siteProperty.EVENT_ID = event.id;
            siteProperty.SITE_USER_SUFFIX = 'test.c1';
        
        list<string> product2List = new list<string>();
        product2List.add('test');
        prod1.IsActive = true; 
        prod1.Start_Date__c = Date.today();
        prod1.End_Date__c = Date.today();
        prod1.Attendee_Type__c ='Manger';
        prod1.Child_Start_Age__c =1;
        prod1.Child_End_Age__c =10;
        //prod1.Attendee_Type__c = 
        update prod1;
        Product2 prod2 = new Product2();
        prod2.Name = 'test';
        prod2.IsActive = true; 
        prod2.Start_Date__c = Date.today();
        prod2.End_Date__c = Date.today();
        prod2.Event__c = eventId;
        prod2.ProductCode = 'promocode0001';
        prod2.Product_Type__c = 'PromoCode';
        
        //prod2.Attendee_Type__c ='Manger';
        insert prod2;
        //product2List.add( prod1.Name);
        PricebookEntry pbe; 
        PricebookEntry pbe1;
        try{
            pbe  = EEG_RegistrationHelperTest.createNewPriceBookEntry(standard_pricebook,prod1.id,'USD',3000);
            pbe1  = EEG_RegistrationHelperTest.createNewPriceBookEntry(standard_pricebook,prod2.id,'USD',3000); 
           }
        catch(Exception e){
            
        
          }   
          eegRegUtility.isValidPromoCode(eventId,'promocode0001',pbe.id);
          eegRegUtility.isValidPromoCode(eventId,'promocode0001',pbe1.id);
          eegRegUtility.isValidPromoCodeForTheAttendeeTypeNew(eventId,'promocode0001',pbe.id,'Manger');
         
         //when promotion code null  
           eegRegUtility.isValidPromoCode(eventId,null,pbe.id);
           eegRegUtility.isValidPromoCodeForTheAttendeeTypeNew(eventId,null,pbe.id,'Manger');
          
         //Test getPromoCodeProductDetails
          
           eegRegUtility.getPromoCodeProductDetails(eventId,'promocode0001');
           eegRegUtility.getPromoCodeProductDetails(eventId,'promo%^&code0001');  
           eegRegUtility.getPromoCodeProduct(eventId, 'promocode0001','Product type',true);       
         
           
        //Test createOpportunityLineItemList
           List<OpportunityLineItem>oLineItemList = eegRegUtility.createOpportunityLineItemList(eventId, standard_pricebook, prod1.Attendee_Type__c, product2List, prod1.Product_Type__c);
           eegRegUtility.createOpportunityLineItemList(eventId, standard_pricebook,null, product2List, prod1.Product_Type__c);          
           eegRegUtility.createOpportunityLineItemListForGuest(eventId,standard_pricebook, prod1.Attendee_Type__c,product2List,prod1.Product_Type__c,6);
           eegRegUtility.createOpportunityLineItemListV2(eventId, standard_pricebook, prod1.Attendee_Type__c, 'Full Conference', product2List, prod1.Product_Type__c);
           eegRegUtility.createMapOfLineItem(oLineItemList);
           
           
           
     }
     
        
     //Test code for OpportunityLineItem and Opportunity Related Methods
     
    /* Static void testOpportunityLineItemsMethods(EEG_RegistrationUtility eegRegUtility,Opportunity opp,list<OpportunityLineItem> opptyLineItems1){
        
        eegRegUtility.upsertOpportunityLineItems(opp,opptyLineItems1);
        eegRegUtility.getProducts(opptyLineItems1);
        eegRegUtility.createMapOfLineItem(opptyLineItems1); 
        eegRegUtility.getExisitingOppLineItem(opp.id);
        
     }*/
    
    //Test isExistingUser Method()  
  /*  static testMethod void isExistingUser(){
        
        EEG_RegistrationUtility regUtility = new EEG_RegistrationUtility();
        regUtility.isExistingUser(UserInfo.getName());
        
    }*/
    
    //Test getEventInfo method
   /* static testMethod void getEventInfo(){
       List<Site_Properties__c> prpt = Site_Properties__c.getall().values();
       EEG_RegistrationUtility regUtility = new EEG_RegistrationUtility();
       regUtility.getEventInfo(prpt[0].Event_Id__c);  
      
     }*/
     
        
     //Test compare method method
     static testMethod void validateAllowedBackdoorRegistrtaion() {
      Test.startTest();       
     
      Account acc = new Account (Name = 'newAcc1'); 
      insert acc;   
      Contact con = new Contact (
        AccountId = acc.id,
        FirstName = 'sourav',
        LastName = 'portalTestUser',
        email ='newUser@yahoo.com'
       
        );
        insert con; 
      //Create Event
            Event_Header__c event =New Event_Header__c();
            event.Account__c = acc.id;
            event.Event_Name__c ='Critix';
            event.Start_Date__c= system.today();
            event.End_Date__c = system.today().addDays(10);
            event.Email_From_Address__c='eegmaster@yopmail.com';
            event.Event_Code__c ='CRT456';  
            event.Program_Number__c='5654';
            event.Program_Type__c='cType';         
            insert event;
            
          //Create Registration__c 
          Registration__c reg = new Registration__c(Registrant__c = con.id,Event__c=event.id);          
          insert reg;
          EEG_SiteProperties eegSiteProperties =  new EEG_SiteProperties('Name');
          Payment__c pay= New Payment__c();
          Pay.Amount__c=500;
          pay.Amount_Charged__c=400;
          pay.ConversionRate__c = 1;
          pay.Registration__c = reg.id;
          //pay.Amount_Due_in_USD__c = 500;
          insert pay;
          
          EEG_RegistrationUtility regUtility = new EEG_RegistrationUtility();
          regUtility.validateAllowedBackdoorRegistrtaion(event.id, acc.id,con.Email);
          regUtility.clearGusetValues(reg);
          regUtility.createUserV1(acc.id,con,'password','ProgramSuffix');
          regUtility.createRegistrationV1(event.id,con,reg,UserInfo.getUserId(),'Saved for Later','Suffix');
          regUtility.processPayPalPayment(reg,pay,true);
          regUtility.getParentTransactions(pay);
          //regUtility.registerUser(con,reg,eegSiteProperties,'Password',Page.EEG_Override_Registration_Delete_Button,true);
          
          //regUtility.registerUser(con,reg,eegSiteProperties,'Password',Page.EEG_Override_Registration_Delete_Button,false);
         
           Test.stopTest();
     }
     
     //Test clearGusetValues Method
     static testMethod void clearGusetValues() {
        
      Account acc = new Account (Name = 'newAcc1'); 
      insert acc;   
      Contact con = new Contact (
        AccountId = acc.id,
        FirstName = 'sourav',
        LastName = 'portalTestUser',
        email ='newUser@yahoo.com'
       
        );
        insert con; 
      //Create Event
            Event_Header__c event =New Event_Header__c();
            event.Account__c = acc.id;
            event.Event_Name__c ='Critix';
            event.Start_Date__c= system.today();
            event.End_Date__c = system.today().addDays(10);
            event.Email_From_Address__c='eegmaster@yopmail.com';
            event.Event_Code__c ='CRT456';  
            event.Program_Number__c='5654';
            event.Program_Type__c='cType';         
            insert event;
            
          //Create Registration__c 
          Registration__c reg = new Registration__c(Registrant__c = con.id,Event__c=event.id);          
          insert reg;         
          EEG_RegistrationUtility regUtility = new EEG_RegistrationUtility();
          regUtility.clearGusetValues(reg);
     }
     
     
     
     
     //Test OppLineItem inner class
     static testMethod void testOppLineItemConstructor(){
        EEG_RegistrationUtility eegRegUtility = new EEG_RegistrationUtility();
        Boolean boolen;
        Test.startTest();       
        
        Account account= EEG_RegistrationHelperTest.createNewAccount('Test Account Name');        
        
        Event_Header__c event = EEG_RegistrationHelperTest.createNewEvent('Test Event');
        
        Contact contact = EEG_RegistrationHelperTest.createNewContact(account.id, 'FName1', 'LName1', 'test'+Math.round(Math.random()*Math.pow(10, 7))+'@salesforce.com.event.2');
        Registration__c reg;  
        
        Payment__c pay= New Payment__c();
        Pay.Amount__c=500;
        pay.Amount_Charged__c=400;
        pay.ConversionRate__c = 1;
        //pay.Amount_Due_in_USD__c = 500;
        decimal totalamount=eegRegUtility.getCalculatedAmount(Pay); 
        insert pay;
        
        Paypal_Transaction_History__c PTH = new Paypal_Transaction_History__c();
        PTH.Payment__c=pay.id;
        PTH.Credit_Card_Number_Last_Four_Digits__c ='6798';
        insert PTH;
           
        reg = eegRegUtility.createRegistration(event.Id, contact.Id, reg, UserInfo.getUserId(), 'Saved for Later', 'TestReg', 'contactFirstName', 'contactLastName');
        //reg.Attending_Event__c = 'No';
        //update reg;
        
        Registration_Invite__c regInvite = new Registration_Invite__c(Registration__c = REG.ID,Last_Name__c ='PETER');
        insert regInvite;
        
        EEG_SiteProperties siteProperty = new EEG_SiteProperties('Test123');
        siteProperty.ACCOUNT_ID = account.id;
        siteProperty.EVENT_ID = event.id;
        siteProperty.SITE_USER_SUFFIX = 'test.c1';
        
          
        //get standard pricebook
        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        Product2 prd = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true,Discount_Type__c= 'Registration And Activity Fee');
        insert prd;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true,Discount_Type__c= 'Percentage',Discount_Percentage__c= 10,Product_Type__c = 'PromoCode');
        insert prd1;
        
        Product2 prd2 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true,Discount_Type__c= 'Registration Fee Only',Product_Type__c = 'PromoCode');
        insert prd2;
        
        Product2 prd3 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true,Discount_Type__c= 'Registration Workshop',Product_Type__c = 'PromoCode');
        insert prd3;
        
        Product2 prd4 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true,Discount_Type__c= 'Registration Activity And Rental Fee',Product_Type__c = 'PromoCode');
        insert prd4;
        
        Product2 prd5 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true,Discount_Type__c= 'All',Product_Type__c = 'PromoCode');
        insert prd5;
        
        PricebookEntry pbe = new PricebookEntry (Product2ID=prd.id,Pricebook2ID = standardPb.id,UnitPrice=50, isActive=true);
        insert pbe; 
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID = standardPb.id,UnitPrice=50, isActive=true);
        insert pbe1; 
        
        PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd2.id,Pricebook2ID = standardPb.id,UnitPrice=50, isActive=true);
        insert pbe2; 
        
        PricebookEntry pbe3 = new PricebookEntry (Product2ID=prd3.id,Pricebook2ID = standardPb.id,UnitPrice=50, isActive=true);
        insert pbe3; 
        
        PricebookEntry pbe4 = new PricebookEntry (Product2ID=prd4.id,Pricebook2ID = standardPb.id,UnitPrice=50, isActive=true);
        insert pbe4; 
        
        PricebookEntry pbe5 = new PricebookEntry (Product2ID=prd5.id,Pricebook2ID = standardPb.id,UnitPrice=50, isActive=true);
        insert pbe5; 
        
        Opportunity opp = new Opportunity (Name='Opp1',StageName='Stage 0 - Lead Handed Off',CloseDate=Date.today(),Pricebook2Id = pbe.Pricebook2Id, AccountId = account.id, Registration__c = reg.Id);
        insert opp;        
        
        OpportunityLineItem lineItem0 = new OpportunityLineItem (Product_Type__c = 'Registration',OpportunityID=opp.id,PriceBookEntryID=pbe.id, quantity=4,UnitPrice=100);
        insert lineItem0;
                   
        OpportunityLineItem lineItem1 = new OpportunityLineItem (Product_Type__c = 'Workshop',OpportunityID=opp.id,PriceBookEntryID=pbe.id, quantity=4,UnitPrice=200);
        insert lineItem1;
       
        
        OpportunityLineItem lineItem2 = new OpportunityLineItem (Product_Type__c = 'Guest Event',OpportunityID=opp.id,PriceBookEntryID=pbe.id, quantity=4,UnitPrice=200);
        insert lineItem2;
        
        OpportunityLineItem lineItem3 = new OpportunityLineItem (Product_Type__c = 'Hotel',OpportunityID=opp.id,PriceBookEntryID=pbe.id, quantity=4,totalprice=200,Description ='abcdf');
        insert lineItem3;
        
        OpportunityLineItem lineItem4 = new OpportunityLineItem (Product_Type__c = 'Additional Service',OpportunityID=opp.id,PriceBookEntryID=pbe.id, quantity=4,totalprice=200);
        insert lineItem4;
        OpportunityLineItem lineItem5 = new OpportunityLineItem (Product_Type__c = 'PromoCode',OpportunityID=opp.id,PriceBookEntryID=pbe.id, quantity=4,UnitPrice=200);
        insert lineItem5;
        
        OpportunityLineItem lineItem6 = new OpportunityLineItem (Product_Type__c = 'PromoCode',OpportunityID=opp.id,PriceBookEntryID=pbe1.id, quantity=4,UnitPrice=200);
        insert lineItem6;
        
        OpportunityLineItem lineItem7 = new OpportunityLineItem (Product_Type__c = 'PromoCode',OpportunityID=opp.id,PriceBookEntryID=pbe2.id, quantity=4,UnitPrice=200);
        insert lineItem7;
        
        OpportunityLineItem lineItem8 = new OpportunityLineItem (Product_Type__c = 'Activity',OpportunityID=opp.id,PriceBookEntryID=pbe.id, quantity=4,UnitPrice=200);
        insert lineItem8;
        
        OpportunityLineItem lineItem9 = new OpportunityLineItem (Product_Type__c = 'Rental Fee',OpportunityID=opp.id,PriceBookEntryID=pbe.id, quantity=4,UnitPrice=200);
        insert lineItem9;
        
        OpportunityLineItem lineItem10 = new OpportunityLineItem (Product_Type__c = 'PromoCode',OpportunityID=opp.id,PriceBookEntryID=pbe3.id, quantity=4,UnitPrice=200);
        insert lineItem10;
        
        OpportunityLineItem lineItem11 = new OpportunityLineItem (Product_Type__c = 'PromoCode',OpportunityID=opp.id,PriceBookEntryID=pbe4.id, quantity=4,UnitPrice=200);
        insert lineItem11;
        
        OpportunityLineItem lineItem12 = new OpportunityLineItem (Product_Type__c = 'PromoCode',OpportunityID=opp.id,PriceBookEntryID=pbe5.id, quantity=4,UnitPrice=200);
        insert lineItem12;
        
        EEG_RegistrationUtility.opportunityLineItemWrapperclass  eegregutyoppline = new EEG_RegistrationUtility.opportunityLineItemWrapperclass();
        EEG_RegistrationUtility.OppLineItem lineItemInnerClass0 = new  EEG_RegistrationUtility.OppLineItem(lineItem0);
        EEG_RegistrationUtility.OppLineItem lineItemInnerClass1 = new  EEG_RegistrationUtility.OppLineItem(lineItem1);
        EEG_RegistrationUtility.OppLineItem lineItemInnerClass2 = new  EEG_RegistrationUtility.OppLineItem(lineItem2);
        EEG_RegistrationUtility.OppLineItem lineItemInnerClass3 = new  EEG_RegistrationUtility.OppLineItem(lineItem3);
        EEG_RegistrationUtility.OppLineItem lineItemInnerClass4 = new  EEG_RegistrationUtility.OppLineItem(lineItem4);
        EEG_RegistrationUtility.OppLineItem lineItemInnerClass5 = new  EEG_RegistrationUtility.OppLineItem(lineItem5);
        EEG_RegistrationUtility.OppLineItem lineItemInnerClass6 = new  EEG_RegistrationUtility.OppLineItem(lineItem6);
        EEG_RegistrationUtility.OppLineItem lineItemInnerClass7 = new  EEG_RegistrationUtility.OppLineItem(lineItem7);
        EEG_RegistrationUtility.OppLineItem lineItemInnerClass8 = new  EEG_RegistrationUtility.OppLineItem(lineItem8);
        EEG_RegistrationUtility.OppLineItem lineItemInnerClass9 = new  EEG_RegistrationUtility.OppLineItem(lineItem9);
        EEG_RegistrationUtility.OppLineItem lineItemInnerClass10 = new  EEG_RegistrationUtility.OppLineItem(lineItem10);
        EEG_RegistrationUtility.OppLineItem lineItemInnerClass11 = new  EEG_RegistrationUtility.OppLineItem(lineItem11);
        EEG_RegistrationUtility.OppLineItem lineItemInnerClass12 = new  EEG_RegistrationUtility.OppLineItem(lineItem12);
        
        lineItemInnerClass1.compareTo(lineItemInnerClass0);
        lineItemInnerClass3.compareTo(lineItemInnerClass1);  
        lineItemInnerClass3.compareTo(lineItemInnerClass2); 
        lineItemInnerClass1.compareTo(lineItemInnerClass3);
        lineItemInnerClass3.compareTo(lineItemInnerClass5);  
        lineItemInnerClass3.compareTo(lineItemInnerClass6);
        lineItemInnerClass3.compareTo(lineItemInnerClass7);
        eegregutyoppline.registrationDescription = 'Testing';
        eegregutyoppline.registrationAmount = 100.00;
        eegregutyoppline.workshopDescription  = 'Testing';
        eegregutyoppline.workshopAmount = 100.00;
        EEG_RegistrationUtility.PaypalTransactionHistory EEGRegPaypal = new EEG_RegistrationUtility.PaypalTransactionHistory(PTH);
        
        EEG_PaypalProcessorWebservice.TransactionOutputDetails eegtrans = new EEG_PaypalProcessorWebservice.TransactionOutputDetails();   
        boolen=eegRegUtility.isPaymentProcessed(eegtrans);
        //eegRegUtility.paypalPalProcessOnline(pay);
        //eegRegUtility.paypalPalProcessOnlineMultiCurrency(pay);
        eegRegUtility.getCalculatedAmountMultiCurrency(pay);
        eegRegUtility.createPaypalTransactionHistory(reg,pay,eegtrans);
        eegRegUtility.createPaypalTransactionHistorytMultiCurrency(reg,pay,eegtrans);  
        
        
        eegRegUtility.isPaymentProcessed(eegtrans);
        
        List<EEG_RegistrationUtility.OppLineItem> optlineItems = New List<EEG_RegistrationUtility.OppLineItem> ();
        optlineItems.add(lineItemInnerClass1);
        optlineItems.add(lineItemInnerClass2);
        optlineItems.add(lineItemInnerClass5);
        optlineItems.add(lineItemInnerClass0);
        optlineItems.add(lineItemInnerClass6);
        optlineItems.add(lineItemInnerClass7);
        optlineItems.add(lineItemInnerClass8);
        optlineItems.add(lineItemInnerClass9);
        optlineItems.add(lineItemInnerClass10);
        optlineItems.add(lineItemInnerClass11);
        optlineItems.add(lineItemInnerClass12);
        
        decimal totalamt=eegRegUtility.getTotalAmount(optlineItems);
        
        List<EEG_RegistrationUtility.OppLineItem> optlineItemsPromo = eegRegUtility.processPromoCode(optlineItems);
        String productType = 'Activity';
        String userid = userinfo.getuserid();
        String profileid = userinfo.getprofileid();
        Integer intt = 10;
        EEG_RegistrationUtility EEGRegUty = new EEG_RegistrationUtility();
        EEGRegUty.processGuestCharge(optlineItems,productType);
        EEGRegUty.revertGuestCharge(optlineItems,productType);
        EEGRegUty.processChildCharge(optlineItems,productType,intt);
        //eegRegUtility.isAlreadyReferredBytheSameContact(null, null, null);
        eegRegUtility.isAlreadyReferredBytheSameContact(account.id, contact, contact);
        
        
        Contact_Referral__c CR = new Contact_Referral__c(Referred_By__c=contact.id,Referred_Contact__c=contact.id); insert CR;
        eegRegUtility.getContactReferralDetails(null);
        eegRegUtility.getContactReferralDetails(CR.id);
        eegRegUtility.splitMultiSelectPicklist('Testing');
        eegRegUtility.getconReferral(CR, CR);
        eegRegUtility.getManagerDetails(contact.id, event.id);
        eegRegUtility.getAllLodgings(reg.id);
        String accountidd = account.id;
        eegRegUtility.createContactV1(accountidd,contact);
        String strr = 'Testy';
        String regg = reg.id;
        String eventt= event.id;
        Decimal age = 10.3;
        String Username= 'Test@mail.com';
        List<String> applicableProducts = new List<String>();
        applicableProducts.add(strr);
        String attendeeType  = 'attendeeType';
        reCAPTCHA captcha = new reCAPTCHA();
        EEG_InhouseCaptchaController eegCaptcha = new EEG_InhouseCaptchaController();
        eegRegUtility.createOpportunityLineItemListForGuest(eventt,'Pricebookname','attendeetype',applicableProducts,'producttype',age);
        eegRegUtility.createOpportunityLineItemListV3(eventt,'priceBookName','attendeeType','conferenceType',applicableProducts,'productType','currencyIsoCode');
        eegRegUtility.createOpportunityLineItemListV4(eventt,'priceBookName','attendeeType','conferenceType',applicableProducts,'PromoCode','currencyIsoCode','Speaker');
        eegRegUtility.registerUser(contact,reg,siteProperty,'Test1234','Test1234',true,null,null,true,true,'Whitelist',strr,event,true,captcha,eegCaptcha);
        eegRegUtility.registerUser(contact,reg,siteProperty,'Test1234','Test1234',true,null,null,true,true,'Blacklist',strr,event,true,captcha,eegCaptcha);
        EEG_RegistrationUtility.ProductInvoiceClass EEGRegUProduct = new EEG_RegistrationUtility.ProductInvoiceClass();
        eegRegUtility.updateInvoice(regg,attendeeType,strr,siteProperty,applicableProducts,null);
        eegRegUtility.processPayPalPaymentMultiCurrency(reg,pay,true);
        EEG_RegistrationUtility.DropdownWrapperClass eegRegUtilityDrop = new EEG_RegistrationUtility.DropdownWrapperClass('eventname','label','default');
        List<EEG_RegistrationUtility.DropdownWrapperClass> ListeegRegUtilityDrop = new List<EEG_RegistrationUtility.DropdownWrapperClass>();
        ListeegRegUtilityDrop.add(eegRegUtilityDrop);
        eegRegUtility.getStoredValuesSet('Account');
        Map<String,String> mapOfValueLabel = new Map<String,String>();
        mapOfValueLabel.put('test',attendeeType);
        Set<String> storedValues = new Set<String>();
        storedValues.add(attendeeType);
        eegRegUtility.createWrapperList(mapOfValueLabel,storedValues,'default');
        eegRegUtility.getAllProducts(producttype,attendeetype,eventt);
        eegRegUtility.getSelectedDropdoenValues(ListeegRegUtilityDrop);
        eegRegUtility.getDefaultValue(true);
        eegRegUtility.getRegistrationGroupFromName(eventt,attendeetype);
        eegRegUtility.createOpportunityLineItemListV4(eventt,'priceBookName','attendeeType','',applicableProducts,'PromoCode','currencyIsoCode','Speaker');
        try{
        
        eegRegUtility.createDeleteOpportunityLineItems(EEGRegUProduct,siteProperty,contact,reg,opp);
        }
        catch(exception e){}
        eegRegUtility.getReferredByNameForEmailDomain(eventt,attendeeType,Username);
        Payment__c pay1= New Payment__c();
        eegRegUtility.getCalculatedAmountMultiCurrency(pay1);
       /* Test.startTest();
        EEG_RegistrationUtility.updateUser(userid,profileid);
        Test.stopTest();*/
        eegRegUtility.createReferralPromoCode(siteProperty,'promocode0001','attendeeType','Full Conference',10,'Percentage',10.0,20);
        Test.stopTest();
     }
       
    /*
        test method for getAwardNominee method
    */
    static testMethod void testgetAwardNomineeTest(){
    Test.startTest(); 
    Decimal d;
    List<Id> lstguestIds = new List<Id>();
    EEG_RegistrationUtility eegRegUtility = new EEG_RegistrationUtility();
    Account account= EEG_RegistrationHelperTest.createNewAccount('Test Account Name');        
        
    Event_Header__c event = EEG_RegistrationHelperTest.createNewEvent('Test Event');
    event.Registration_End_Date_Time__c = system.now();
    event.Registration_Start_Date_Time__c = system.now();
    event.Cfp_Close_Date__c = system.now();
    event.Cfp_Open_Date__c  = system.now();
    event.Src_Open_Date__c = system.now();
    event.Src_Close_Date__c= system.now();
    update event;
    
    Contact contact = EEG_RegistrationHelperTest.createNewContact(account.id, 'FName1', 'LName1', 'test'+Math.round(Math.random()*Math.pow(10, 7))+'@salesforce.com.event.2');
    Contact contact1 = EEG_RegistrationHelperTest.createNewContact(account.id, 'FName11', 'LName11', 'test'+Math.round(Math.random()*Math.pow(10, 7))+'@salesforces.com.event.2');
    Registration__c reg;   
        
    reg = eegRegUtility.createRegistration(event.Id, contact.Id, reg, UserInfo.getUserId(), 'Saved for Later', 'TestReg', 'contactFirstName', 'contactLastName');

    
    
    Product2 prod  = EEG_RegistrationHelperTest.createNewProduct(event.Id, 'promocode0000', 'Activity', 'Amount', 20, 'Customer');
    
    List<Product2> ListProd = new List<Product2>();
    
    Product2 prd = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true,Discount_Type__c= 'Registration And Activity Fee');
       
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true,Discount_Type__c= 'Percentage',Discount_Percentage__c= 10,Product_Type__c = 'PromoCode');
        ListProd.add(prd1);
        insert prd1;
    eegRegUtility.createProductNameDescriptionMap(ListProd);
    eegRegUtility.createProductOrderByNameMap(ListProd);
    List<SelectOption> unsortedList = new  List<SelectOption>();
    unsortedList.add(new SelectOption('','--None--'));    
    Decimal decc = 10;
    String Strrr = '3';
    Map<Decimal,String> orderOptionValueMap = new Map<Decimal,String>();
    orderOptionValueMap.put(decc, strrr);
    eegRegUtility.sortSelectOptionList(unsortedList,orderOptionValueMap,true);
    //Datetime dt = new Datetime();
    Guest__c Guest = new Guest__c();
    guest.Type__c = 'Guest';
    guest.Registration__c = reg.id;
    insert Guest;
   
    lstguestIds.add(Guest.id);
    
    Lodging__c lod = new Lodging__c ();
    lod.Registration__c = reg.Id;
    lod.Room_Type_PickList__c = 'ROH';
    lod.Guest__c = Guest.id;
    insert lod;
    
    Registration_Group__c regGroup = new Registration_Group__c();
            regGroup.name = 'Test1234';
            regGroup.Event__c = event.id;
            regGroup.Company_Name__c = 'Test1234';
            insert regGroup;

    Registration_Group_Member__c regMember = new Registration_Group_Member__c();
            regMember.Registration__c = reg.id;
            regMember.Registration_Group__c = regGroup.id;
            insert regMember;
    
    Air_Travel__c airTravel = new Air_Travel__c(); 
    airTravel.Departure_Date__c = system.today(); 
    airTravel.Arrival_Date__c = system.today();
    airTravel.Do_You_Need_Visa__c = 'Yes';
    airTravel.Guest__c = Guest.id;
    airTravel.Registration__c = reg.id;
    insert airTravel; 
    
    Activity__c activity = new Activity__c();
    activity.Activity_Choice__c = 'test';
    activity.Additional_Comments__c = 'test1234';
    activity.Registration__c = reg.id;
    activity.Guest__c = guest.id;
    insert activity;
    
                        
    Award_Nomination__c  awardNominee = new Award_Nomination__c();
    awardNominee.First_Name__c = 'testFname';
    awardNominee.Last_Name__c = 'testLname';
    awardNominee.Registration__c = reg.id;
    insert awardNominee;
    
    Attachment attach = new Attachment();
    attach.ParentId = awardNominee.id;
    attach.Description = 'test';
    attach.name = 'test';
    attach.Body = blob.valueOf('abc');
    insert attach;
    
    Attachment attach1 = new Attachment();
    //attach1.ParentId = reg.id;
    attach1.Description = 'test';
    attach1.name = 'test';
    attach1.Body = blob.valueOf('abc');
    //insert attach1;
    
    Payment__c pay= New Payment__c();
        Pay.Amount__c=500;
        pay.Amount_Charged__c=400;
        pay.Registration__c = reg.id;
        decimal totalamount=eegRegUtility.getCalculatedAmount(Pay); 
        insert pay;
        
    Paypal_Transaction_History__c PTH = new Paypal_Transaction_History__c();
        PTH.Payment__c=pay.id;
        PTH.Credit_Card_Number_Last_Four_Digits__c ='6798';
        PTH.Transaction_Result__c = 'Approved';
    
    eegRegUtility.getAwardNominee(reg.id,awardNominee.id);
    eegRegUtility.getAllAwardNominees(reg.Id);
    eegRegUtility.getGuestAirTravelRecords(lstguestIds);
    eegRegUtility.getGuestLodgingRecords(lstguestIds);
    eegRegUtility.getGuestActivities(lstguestIds);
    eegRegUtility.incrementProductCount(prod);
    eegRegUtility.decrementProductCount(prod);
    eegRegUtility.isProductAvailable(event.Id,'Activity','promocode0000',null,true,true);
    eegRegUtility.clearHotelRecord(lod);
    eegRegUtility.fetchAtachment(awardNominee.id,'test');
    eegRegUtility.isValidDate(system.now());
    eegRegUtility.isValidDate(null);
    eegRegUtility.getEmailTemplateId('');
    eegRegUtility.saveAttachment(attach1,'test',reg.id,reg.ownerId);
    eegRegUtility.getAllAtachments(reg.Id,'test');
    eegRegUtility.getUpdatedContact(contact,contact);
    eegRegUtility.isEventItemsOpen(event.Id, 'Registration');
    eegRegUtility.isEventItemsClosed(event.Id,'Registration');
    eegRegUtility.isEventItemsOpen(event.Id, 'Src');
    eegRegUtility.isEventItemsClosed(event.Id,'Src');
    eegRegUtility.isEventItemsOpen(event.Id, 'Cfp');
    eegRegUtility.isEventItemsClosed(event.Id,'Cfp');
    eegRegUtility.getAllAtachments(reg.Id);
    eegRegUtility.getEventAttendeeTypeConfiguration(event.Id,'Attendee','test.com',true);
    String  regGroupid = regGroup.id;
    eegRegUtility.getAllRegGroupMembers(regGroupid);
    List<Paypal_Transaction_History__c> paypalTrans = new List<Paypal_Transaction_History__c>();
    paypalTrans.add(PTH);
    insert paypalTrans;
    eegRegUtility.getPaypalHistoryRecords(reg);
    paypalTrans = eegRegUtility.getPayPalHistory(reg);
    d = eegRegUtility.getTotalFromPayPalHistory(paypalTrans, 'Credit-Refund');
    eegRegUtility.getRegistrationGroupMemberRecord('regId');
    String regid = reg.id;
    String reggroupmemid = regMember.id;
    String eventt = event.id;
    List<String> allowedFileTypeList = new List<String>();
    allowedFileTypeList.add(regid);
    Registration_Group__c regGroups = new Registration_Group__c();
    eegRegUtility.createRegistrationGroup(reggroups,eventt);
    eegRegUtility.createRegistrationGroupMember(regid,reggroupid);
    eegRegUtility.getEventCountrySetting(eventt,'attendeetype');
    eegRegUtility.getEventCountryCurrencySetting(eventt,'United States');
    eegRegUtility.getProductRegistrationGroup('producttype',reggroupid,eventt);
    try{
    eegRegUtility.validateAttachment(attach1,allowedFileTypeList,5454545,'Please Enter','Please Enter');
    }catch(exception e){}
    eegRegUtility.getConversionRateFromCurrencyIsoCode('USD');
    eegRegUtility.populateEmergencyContactDetailsForGuest(contact,contact1);
    contact.Is_Emergency_Info_Same__c = true;
    update contact;
    eegRegUtility.populateEmergencyContactDetailsForGuest(contact,contact1);
    eegRegUtility.checkProductCapacity(event.id,'productType',allowedFileTypeList);
    Map<String,boolean> mapStringBool = new Map<String,boolean>();
    mapStringBool.put('Testing',true);
    eegRegUtility.getValueFromMap('Testing',mapStringBool);
    eegRegUtility.getAllAwardNominationSubmittedByUser(UserInfo.getUserId());
    Test.stopTest();
    }
     
     
     //test upsertGuest method
     
     static testmethod void UpsertGuestTest()
     {
        EEG_RegistrationUtility eegRegUtility = new EEG_RegistrationUtility();
        Guest__c newguest = New Guest__c();
        Contact con= New Contact();
        Registration__c reg = New Registration__c();
        newguest= eegRegUtility.upsertGuest(newguest, String.valueof(con.Id) , String.valueof(reg.id),'Guest','Mr.','GuestFirstName','GuestLastName');
     }
     
     // test getCalculatedAmount and paypalPalProcessOnlinemethod
     static testmethod void TestPaymentMethods()
     {
        EEG_RegistrationUtility eegRegUtility = new EEG_RegistrationUtility();
        Payment__c pay= New Payment__c();
        Pay.Amount__c=500;
        pay.Amount_Charged__c=400;
        decimal totalamount=eegRegUtility.getCalculatedAmount(Pay);
      /*  If(eegRegUtility.paypalPalProcessOnline(Pay))
            system.debug('PayPal Success');
        else
            system.debug('PayPal not Success');*/
        
     }
     
     static testmethod void ERC_MethodsTest()
     {
      
        EEG_RegistrationUtility eegRegUtility = new EEG_RegistrationUtility();
        eegRegUtility.getRSVP_Requests('eventId','exhibitorLevel');
        eegRegUtility.getExistingParticipants('eventId','regId');       
        
        eegRegUtility.getGroupMamberRegistrations(null, null, true);
        eegRegUtility.getGroupMamberRegistrations(null, null, false);
     } 
     
     
     static testMethod void TestEEG_RegistrationUtilityNew()
    {
        Test.startTest();
        
        Account accObj = new Account( Name = 'Test New Account');
        insert accObj;
        
        Contact conObj = new Contact( AccountId = accObj.id,FirstName = 'TestFirstCon', LastName = 'TestLast', Email = 'test@test.com',
                                      company_name__c = 'TestCompanyName', External_User_Name__c = 'TestUserName'                                     
                                    );
        insert conObj;
        
        List<String> eventIdList = new List<String>();
        Event_Header__c eventObj = new Event_Header__c( Account__c = accObj.id, Event_Name__c ='EEG DEMO', Start_Date__c= system.today() + 10,
                                                        End_Date__c = system.today().addDays(10), Email_From_Address__c='eegmaster@yopmail.com',
                                                        Event_Code__c ='Brocade123', Program_Number__c='5654', Program_Type__c='Type'
                                                      );
        insert eventObj;
        
        eventIdList.add(eventObj.id);   

        Event_Email_Black_List__c eventBlackListObj = new Event_Email_Black_List__c( Event__c = eventObj.id, Black_List_Email_Domain__c = 'test@test.com');
        insert eventBlackListObj;
        
        Event_Attendee_Type_Configuration__c eventAttTypeConfObj = new Event_Attendee_Type_Configuration__c( Event__c = eventObj.id, 
                                                                                                             Attendee_Type__c = 'TestAttendeeType',
                                                                                                             Is_Promocode_required__c = true,
                                                                                                             Email_Email_domain__c = 'test@test.com',
                                                                                                             Number_of_Registrations_Allowed__c = 5,
                                                                                                             Company_Name__c = 'TestCompanyName',
                                                                                                             Available_Check_In_Date__c = '11/1/2013'
                                                                                                            );
        insert eventAttTypeConfObj;
        
        Registration__c regObj1 = new Registration__c ( Registrant__c = conObj.id, Status__c = 'Attended', Company_Name__c = 'TestReg Company',
                                                        Name = 'Autodesk_OTC' + ' - FN' + ' - LN', Event__c = eventObj.id
                                                     );
        insert regObj1;
        
        Registration_Group__c regGrpObj = new Registration_Group__c( Name='TestRegGrp Name', Event__c = eventObj.id, 
                                                                     Booth_Sponsorship_Level__c='Platinum EC',
                                                                     Exhibitor_Level__c = 'Platinum'
                                                                   );
        insert regGrpObj;
        
        Registration_Invite__c regInviteObj = new Registration_Invite__c( Registration__c = regObj1.id, First_Name__c = 'TestFirstName');
        insert regInviteObj;
        
        Guest__c guestObj = new Guest__c( Type__c = 'Guest', Registration__c = regObj1.id
                                        );
        insert guestObj;
        List<Id> lstguestIds = new List<Id>();
        //lstguestIds.add(guestObj.id);
        
        Lodging__c lodObj = new Lodging__c ( Registration__c = regObj1.Id, Room_Type_PickList__c = 'ROH', Guest__c = guestObj.id
                                           );
        insert lodObj;
        
        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        system.debug('###TestPricebookname:: '+standardPb.name);

        DateTime dateTimeVal = system.now()- 10;
        DateTime dateTimeVal1 = system.now()+ 10;
        
        Product2 prodObj = new Product2 ( Name='Test Product Entry 1', Description='Test Product Entry 1', ProductCode = 'ABC', isActive = true,
                                          Product_Type__c = 'PromoCode', Event_Sponorship__c = 'EC Welcome Reception', Attendee_Type__c = 'Guest',
                                          Booth_Sponsorship_Level__c = 'Gold', Start_Date__c = dateTimeVal, End_Date__c = dateTimeVal1,
                                          Product_Size__c = 1, Event__c = eventObj.id, Conference_Type__c = 'Full Conference'
                                     );
        insert prodObj;
        
        PricebookEntry pbe1 = new PricebookEntry ( Product2ID=prodObj.id, Pricebook2ID=standardPb.id, UnitPrice=50, isActive=true);
        insert pbe1;
        
        Opportunity oppObj = new Opportunity ( Name='Opp1',registration__c = regObj1.id,StageName='Stage 0 - Lead Handed Off',
                                             CloseDate=Date.today(), Pricebook2Id = pbe1.Pricebook2Id, AccountId = accObj.id);
        insert oppObj;
        
        OpportunityLineItem oppLineItemObj = new OpportunityLineItem ( Product_Type__c='Registration',OpportunityID=oppObj.id,
                                                                       PriceBookEntryID=pbe1.id, quantity=4, totalprice=200);
        insert oppLineItemObj;
        
        Attachment attachObj = new Attachment( ParentId = regObj1.id, Description = 'TestDesc', Name = 'TestName', Body = blob.valueOf('abc')
                                            );
        insert attachObj;
        
        Award_Nomination__c awardNominationObj = new Award_Nomination__c( Registration__c = regObj1.id
                                                                        );
        insert awardNominationObj;
        
        
        
        EEG_RegistrationUtility eegRegUtilityObj = new EEG_RegistrationUtility();
        //eegRegUtilityObj.getGuestAirTravelRecords(lstguestIds);
        //eegRegUtilityObj.getGuestActivities(lstguestIds);
        //eegRegUtilityObj.getGuestLodgingRecords(lstguestIds);
        eegRegUtilityObj.isPromocodeRequiredForRegistrationForTheAttendeeType(eventObj.id,'TestAttendeeType');
        eegRegUtilityObj.isPromocodeRequiredForRegistrationForTheAttendeeType(eventObj.id,'TestAttendee');
        eegRegUtilityObj.isPromocodeRequiredForRegistrationForTheAttendeeType(null,'TestAttendeeType');
        
        eegRegUtilityObj.isPromocodeRequiredForEmailOrEmailDomain(eventObj.id,'test@test.com',true);
        eegRegUtilityObj.isPromocodeRequiredForEmailOrEmailDomain(null,'test@test.com',true);
        
        eegRegUtilityObj.isValidPromoCodeForTheAttendeeType(eventObj.id,'ABC','Guest');
        eegRegUtilityObj.isValidPromoCodeForTheAttendeeType(null,null,'Guest');
        
        eegRegUtilityObj.isValidPromoCode(eventObj.id,'ABC');
        eegRegUtilityObj.isValidPromoCode(null,null);
        
        Product2 prodObj1 = new Product2 ( Name='Test Product Entry 1', Description='Test Product Entry 1', ProductCode = 'ABC', isActive = true,
                                          Product_Type__c = 'PromoCode', Event_Sponorship__c = 'EC Welcome Reception', Attendee_Type__c = 'Guest',
                                          Booth_Sponsorship_Level__c = 'Gold', Start_Date__c = dateTimeVal, End_Date__c = dateTimeVal1,
                                          Product_Size__c = -1, Event__c = eventObj.id, Conference_Type__c = 'Full Conference'
                                     );
        insert prodObj1;        
        
        eegRegUtilityObj.isValidPromoCode(eventObj.id,'ABC','Standard Price Book');
        eegRegUtilityObj.isValidPromoCode(eventObj.id,'ABC','test');
        eegRegUtilityObj.isValidPromoCode(null,null,null); 

        eegRegUtilityObj.isValidPromoCodeForAttendeeTypeConfType(eventObj.id,'ABC','Standard Price Book','Guest','Full Conference');
        eegRegUtilityObj.isValidPromoCodeForAttendeeTypeConfType(eventObj.id,'ABC','test','Guest','Full Conference');
        eegRegUtilityObj.isValidPromoCodeForAttendeeTypeConfType(null,null,'Standard Price Book','','');
        eegRegUtilityObj.isValidPromoCodeForAttendeeTypeConfType(null,null,'Standard Price Book','Guest','');
        eegRegUtilityObj.isValidPromoCodeForAttendeeTypeConfType(null,null,'Standard Price Book','','Full Conference');

        eegRegUtilityObj.getPromoCodeProductDetails(eventObj.id,'ABC');
        eegRegUtilityObj.getPromoCodeProductDetails(eventObj.id,'');
        
        eegRegUtilityObj.getRegistrationFromEventIdContactId(eventObj.id,conObj.id);
        eegRegUtilityObj.getRegistrationFromEventIdContactId(eventObj.id,null);
        
        eegRegUtilityObj.getRegistrationFromEventListContactId(eventIdList,conObj.id);
        eegRegUtilityObj.getRegistrationFromEventListContactId(eventIdList,null);
        
        eegRegUtilityObj.isBlackListedEmailDomain(eventObj.id,'test@test.com');
        eegRegUtilityObj.isBlackListedEmailDomain(eventObj.id,'test.com');
        eegRegUtilityObj.isBlackListedEmailDomain(eventObj.id,'');
        
        eegRegUtilityObj.isWhiteListedEmailDomain(eventObj.id,'test@test.com');
        eegRegUtilityObj.isWhiteListedEmailDomain(eventObj.id,'test.com');
        eegRegUtilityObj.isWhiteListedEmailDomain(eventObj.id,'');
        
        eegRegUtilityObj.isWhiteListedEmailAddress(eventObj.id,'test@test.com');
        eegRegUtilityObj.isWhiteListedEmailAddress(eventObj.id,'test.com');
        eegRegUtilityObj.isWhiteListedEmailAddress(eventObj.id,'');
        
        eegRegUtilityObj.isAttendeeTypeWhiteOrBlackListed(eventObj.id,'TestAttendeeType','test@test.com');
        eventAttTypeConfObj.Whitelist_Blacklist__c = 'Whitelist';
        update eventAttTypeConfObj;  
        eegRegUtilityObj.isAttendeeTypeWhiteOrBlackListed(eventObj.id,'TestAttendeeType','test@test.com');
        eventAttTypeConfObj.Whitelist_Blacklist__c = 'Blacklist';
        update eventAttTypeConfObj;  
        eegRegUtilityObj.isAttendeeTypeWhiteOrBlackListed(eventObj.id,'TestAttendeeType','test@test.com');
        eegRegUtilityObj.isAttendeeTypeWhiteOrBlackListed(null,'TestAttendeeType','test@test.com');
        eegRegUtilityObj.isAttendeeTypeWhiteOrBlackListed(null,'','');
        
        String customerPortalUserId = eegRegUtilityObj.createUser(accObj.id,'test@test.com','test12345','.eventSuffix.1','TestFirstName','TestLastName','TestCompany');
        eegRegUtilityObj.createUser(accObj.id,'testcon@test.com','test12345','.eventSuffix.1','TestFirstName','TestLastName','TestCompany');
        
        eegRegUtilityObj.createUserV1(accObj.id,conObj,'test12345','.eventSuffix.1');
        conObj.email = '';
        update conObj;
        eegRegUtilityObj.createUserV1(accObj.id,conObj,'test12345','.eventSuffix.1');
        
        eegRegUtilityObj.getNumberOfRegistrationsForCompanyName(eventObj.id,'TestCompanyName');
        eegRegUtilityObj.getNumberOfRegistrationsForCompanyName(eventObj.id,null);
        
        eegRegUtilityObj.getNumberOfRegistrations(eventObj.id,'TestCompanyName');
        
        eegRegUtilityObj.getNumberOfDays(eventObj.id);
        eegRegUtilityObj.getNumberOfDays(null);
        
        PageReference requestedPageRef = Page.F5_ISC_RegistrationHome;
        eegRegUtilityObj.loginUser('Test@username.com','Testpass123','.eventSuffix.1',requestedPageRef,'successPageURL');
        eegRegUtilityObj.loginUser('','','.eventSuffix.1',requestedPageRef,'successPageURL');
        
        eegRegUtilityObj.forgotPassword('Test@username.com','.eventSuffix.1',requestedPageRef);
        eegRegUtilityObj.forgotPassword('','.eventSuffix.1',requestedPageRef);
        
        eegRegUtilityObj.changePassword('test12345','test12345','testold12345');
        eegRegUtilityObj.changePassword('','','testold12345');
        eegRegUtilityObj.changePassword('test12345','test1234','testold12345');
        
        Registration__c regObjNew = new Registration__c();
        eegRegUtilityObj.createRegistration(eventObj.id,conObj.id,regObjNew,UserInfo.getUserId(),'Registered','Test','TestFirstName','TestLastName');
        eegRegUtilityObj.createRegistration(eventObj.id,conObj.id,null,UserInfo.getUserId(),'Registered','Test','TestFirstName','TestLastName');
        
        eegRegUtilityObj.createRegistrationV1(eventObj.id,conObj,regObjNew,UserInfo.getUserId(),'Registered','Test');
        eegRegUtilityObj.createRegistrationV1(eventObj.id,conObj,null,UserInfo.getUserId(),'Registered','Test');
        
        eegRegUtilityObj.createOpportunity(eventObj.id,accObj.id,regObj1.id,'TestEventName',null,'Standard Price Book','TestFirstName','TestLastName');
        
        eegRegUtilityObj.createOpportunityForRegistrationGroup(eventObj.id,accObj.id,regGrpObj.id,'TestEventName',null,'Standard Price Book','TestGroupName');
        
        eegRegUtilityObj.createOpportunityLineItems(eventObj.id,'Standard Price Book',oppObj.id,'','ABC','TestAttendeeType');
        eegRegUtilityObj.createOpportunityLineItems(eventObj.id,'Standard Price Book',oppObj.id,'','ABC','');
        
        List<String> ccEmailAddressList = new List<String>();ccEmailAddressList.add('test@test.com.c1');
        List<String> bccEmailAddressList = new List<String>();bccEmailAddressList.add('test@test.com.c1');
        eegRegUtilityObj.sendEmail(conObj.Id, regObj1.Id, '000000000000000000', '000000000000000000', ccEmailAddressList, bccEmailAddressList, false);
        eegRegUtilityObj.sendEmailWithAttachment(conObj.Id, regObj1.Id,  '000000000000000000', '000000000000000000', ccEmailAddressList, bccEmailAddressList, false, blob.valueof('Attachment'), 'TestfileName');
        
        eegRegUtilityObj.getEmailTemplateId('');
        
        eegRegUtilityObj.getUserName('TestUserName@test.com','.eventSuffix.1');
        eegRegUtilityObj.removeSiteSuffix('TestUserName@test.com','.eventSuffix.1');
        
        eegRegUtilityObj.getProfileId('System Administrator');
        
        eegRegUtilityObj.getPortalUserAccount(customerPortalUserId);
        
        eegRegUtilityObj.getPortalUserAccount(customerPortalUserId);
        
        eegRegUtilityObj.getContactAccount(conObj.id);
        eegRegUtilityObj.getCurrencySymbol('USD');
        eegRegUtilityObj.pageRedirect(requestedPageRef,true);
        
        eegRegUtilityObj.rerenderPaymentCreditcard('Contact me for payment');
        eegRegUtilityObj.rerenderPaymentCreditcard('TestPayment');
        
        eegRegUtilityObj.getOpportunityLineItems(regObj1.id);
        oppLineItemObj.Product_Type__c='Workshop';
        update oppLineItemObj;
        eegRegUtilityObj.getOpportunityLineItems(regObj1.id);
        
        eegRegUtilityObj.decode('');
        eegRegUtilityObj.decode(eegRegUtilityObj.encode('TestText'));
        
        
        
        List<String> optionList = new List<String>();
        optionList.add('Test1');
        optionList.add('Test2');
        eegRegUtilityObj.getSelectOptions(optionList);
        eegRegUtilityObj.getCheckInDatesFromAttendeeType(eventObj.id,'TestAttendeeType');
        eegRegUtilityObj.insertRegistrationErrorLog(regObj1.id,'TestError');
        eegRegUtilityObj.insertEventErrorLog(eventObj.id,'TestError','TestType');
        eegRegUtilityObj.redirectToLandingPage(Page.EEG_Override_Registration_Delete_Button, Page.EEG_Override_Registration_Delete_Button);
        
        List<String> prodList = new List<String>();
        Product2 prodObj2 = new Product2 ( Name='Test Product Entry 1', Description='Test Product Entry 1', ProductCode = 'ABC', isActive = true,
                                          Product_Type__c = 'PromoCode', Event_Sponorship__c = 'EC Welcome Reception', Attendee_Type__c = 'Guest',
                                          Booth_Sponsorship_Level__c = 'Gold', Start_Date__c = dateTimeVal, End_Date__c = dateTimeVal1, Child_End_Age__c = 30,
                                          Product_Size__c = 1, Event__c = eventObj.id, Conference_Type__c = 'Full Conference', Child_Start_Age__c = 20
                                     );
        insert prodObj2;
        
        Product2 prodObj3 = new Product2 ( Name='Test Product Entry 1', Description='Test Product Entry 1', ProductCode = 'ABC', isActive = true,
                                          Product_Type__c = 'Registration', Event_Sponorship__c = 'EC Welcome Reception', Attendee_Type__c = 'Guest',
                                          Booth_Sponsorship_Level__c = 'Gold', Start_Date__c = dateTimeVal, End_Date__c = dateTimeVal1, Child_End_Age__c = 30,
                                          Product_Size__c = 1, Event__c = eventObj.id, Conference_Type__c = 'Full Conference', Child_Start_Age__c = 20
                                     );
        insert prodObj3;
        
        PricebookEntry pbe2 = new PricebookEntry ( Product2ID=prodObj2.id, Pricebook2ID=standardPb.id, UnitPrice=50, isActive=true);
        insert pbe2;
        
        PricebookEntry pbe3 = new PricebookEntry ( Product2ID=prodObj3.id, Pricebook2ID=standardPb.id, UnitPrice=50, isActive=true);
        insert pbe3;
        
        prodList.add(prodObj2.ProductCode); 
        prodList.add(prodObj3.ProductCode);         
        eegRegUtilityObj.createOpportunityLineItemList(eventObj.id,'Standard Price Book','Guest',prodList,'PromoCode');
        eegRegUtilityObj.createOpportunityLineItemList(eventObj.id,'Standard Price Book','Guest',prodList,'Registration');
        eegRegUtilityObj.createOpportunityLineItemList(eventObj.id,'Standard Price Book','',prodList,'PromoCode');
        
        eegRegUtilityObj.createOpportunityLineItemList(eventObj.id,'Standard Price Book','Guest',prodList,'Workshops');
        eegRegUtilityObj.createOpportunityLineItemList(eventObj.id,'Standard Price Book','',prodList,'Workshops');
        
        eegRegUtilityObj.createOpportunityLineItemListV2(eventObj.id,'Standard Price Book','Guest','Full Conference',prodList,'PromoCode');
        eegRegUtilityObj.createOpportunityLineItemListV2(eventObj.id,'Standard Price Book','','Full Conference',prodList,'PromoCode');
        eegRegUtilityObj.createOpportunityLineItemListV2(eventObj.id,'Standard Price Book','Guest','',prodList,'PromoCode');
        eegRegUtilityObj.createOpportunityLineItemListV2(eventObj.id,'Standard Price Book','','',prodList,'PromoCode');
        
        eegRegUtilityObj.createOpportunityLineItemListV2(eventObj.id,'Standard Price Book','Guest','Full Conference',prodList,'Registration');
        eegRegUtilityObj.createOpportunityLineItemListV2(eventObj.id,'Standard Price Book','','Full Conference',prodList,'Registration');
        eegRegUtilityObj.createOpportunityLineItemListV2(eventObj.id,'Standard Price Book','Guest','',prodList,'Registration');
        eegRegUtilityObj.createOpportunityLineItemListV2(eventObj.id,'Standard Price Book','','',prodList,'Registration');
        
        eegRegUtilityObj.createOpportunityLineItemListForGuest(eventObj.id,'Standard Price Book','Guest',prodList,'PromoCode',25);
        eegRegUtilityObj.createOpportunityLineItemListForGuest(eventObj.id,'Standard Price Book','',prodList,'PromoCode',25);
        eegRegUtilityObj.createOpportunityLineItemListForGuest(eventObj.id,'Standard Price Book','Guest',prodList,'PromoCode',25);
        eegRegUtilityObj.createOpportunityLineItemListForGuest(eventObj.id,'Standard Price Book','',prodList,'PromoCode',25);
        
        eegRegUtilityObj.createOpportunityLineItemListForGuest(eventObj.id,'Standard Price Book','Guest',prodList,'Registration',25);
        //eegRegUtilityObj.createOpportunityLineItemListForGuest(eventObj.id,'Standard Price Book','',prodList,'Registration',25);
        //eegRegUtilityObj.createOpportunityLineItemListForGuest(eventObj.id,'Standard Price Book','Guest',prodList,'Registration',25);
        //eegRegUtilityObj.createOpportunityLineItemListForGuest(eventObj.id,'Standard Price Book','',prodList,'Registration',25);
        
        eegRegUtilityObj.getAllRegistrationInvites(regObj1.id);
        eegRegUtilityObj.clearGusetValues(regObj1);
        eegRegUtilityObj.clearGusetValues(null);
        eegRegUtilityObj.clearHotelRecord(lodObj);
        //eegRegUtilityObj.validateAllowedBackdoorRegistrtaion(eventObj.id,accobj.id,'test@test.com');
        conObj.email = 'test@test.com';
        update conObj;
        //eegRegUtilityObj.validateAllowedBackdoorRegistrtaion(eventObj.id,accobj.id,'test@test.com');
        
        eegRegUtilityObj.getAge(Date.today(), Date.today()+20);
        
        //eegRegUtilityObj.fetchAtachment(regObj1.id,'TestDesc');
        
        eegRegUtilityObj.isValidDate(dateTimeVal);
        eegRegUtilityObj.isValidDate(null);
        test.stopTest();
        //eegRegUtilityObj.getAllAwardNominees(regObj1.id);
        //eegRegUtilityObj.getAwardNominee(regObj1.id,awardNominationObj.id);
    }
    
    static testMethod void testRegisterUserMethod(){
        
        Account account= EEG_RegistrationHelperTest.createNewAccount('Test Account Name');        
        
        Event_Header__c event = EEG_RegistrationHelperTest.createNewEvent('Test Event');
        
       
        Contact contact = EEG_RegistrationHelperTest.createNewContact(account.id, 'FName1', 'LName1', 'test'+Math.round(Math.random()*Math.pow(10, 7))+'@salesforce.com.event.2');
        
        Event_Email_Black_List__c eventBlackListObj = new Event_Email_Black_List__c( Event__c = event.id, Black_List_Email_Domain__c = 'test'+Math.round(Math.random()*Math.pow(10, 7))+'@salesforce.com.event.2');
        insert eventBlackListObj;
        EEG_RegistrationUtility eegRegUtility = new EEG_RegistrationUtility();
        Registration__c reg;
        reg =  eegRegUtility.createRegistration(event.id,contact.id,reg,UserInfo.getUserId(),'Registered','Test','TestFirstName','TestLastName');  
        
        reg.Attending_Event__c =  'No';
        update reg;
        
        Payment__c pay= New Payment__c();
        Pay.Amount__c=500;
        pay.Amount_Charged__c=400;
        pay.ConversionRate__c = 1;
        //pay.Amount_Due_in_USD__c = 500;
        decimal totalamount=eegRegUtility.getCalculatedAmount(Pay); 
        insert pay;
        
        EEG_SiteProperties siteProperty = new EEG_SiteProperties('Test123');
        siteProperty.ACCOUNT_ID = account.id;
        siteProperty.EVENT_ID = event.id;
        siteProperty.SITE_USER_SUFFIX = 'test.c1';
        
        
        reCAPTCHA captcha = new reCAPTCHA();
        EEG_InhouseCaptchaController eegCaptcha = new EEG_InhouseCaptchaController();
       
        eegRegUtility.registerUser(contact,reg,siteProperty,'Test1234','Test1234',true,null,Page.Autodesk_OTC_Home,true,true,null,'Testy',event,true,captcha,eegCaptcha);
        eegRegUtility.registerUser(contact,reg,siteProperty,'Test1234','Test1234',true,null,null,true,true,null,'Testy',event,true,captcha,eegCaptcha);
        eegRegUtility.registerUser(contact,reg,siteProperty,'Test1234','Test1234',true,null,null,true,true,'Whitelist','Testy',event,true,captcha,eegCaptcha);
        eegRegUtility.registerUser(contact,reg,siteProperty,'Test1234','Test1234',true,null,null,true,true,'Blacklist','Testy',event,true,captcha,eegCaptcha);
        
        
        eegRegUtility.registerUser(contact,reg,siteProperty,'Test1234','Test1234',true,null,null,true,true,'Whitelist','Testy',event,true,captcha,eegCaptcha);
        eegRegUtility.registerUser(contact,reg,siteProperty,null,'Test1234',true,null,null,true,true,'Whitelist','Testy',event,true,captcha,eegCaptcha);
        eegRegUtility.registerUser(contact,reg,siteProperty,'Test1234','Test12',true,null,null,true,true,'Whitelist','Testy',event,true,captcha,eegCaptcha);
        
    }
    
    static testMethod void EEG_RegistrationUtility_UnitTest() 
    {
        Test.starttest();
        Account accObj = new Account( Name = 'Test New Account');
        insert accObj;
        
        Contact conObj = new Contact( AccountId = accObj.id,FirstName = 'TestFirstCon', LastName = 'TestLast', Email = 'test@test.com',company_name__c = 'TestCompanyName' );
        insert conObj;
        
        List<String> eventIdList = new List<String>();
        Event_Header__c eventObj = new Event_Header__c( Account__c = accObj.id, Event_Name__c ='EEG DEMO', Start_Date__c= system.today(),End_Date__c = system.today().addDays(10), Email_From_Address__c='eegmaster@yopmail.com',Event_Code__c ='Brocade123', Program_Number__c='5654', Program_Type__c='Type');
        insert eventObj;
        eventIdList.add(eventObj.id);
        
        Event_Attendee_Type_Configuration__c eventAttTypeConfObj = new Event_Attendee_Type_Configuration__c( Event__c = eventObj.id, Attendee_Type__c = 'TestAttendeeType', Is_Promocode_required__c = true,
        Email_Email_domain__c = 'test@test.com', Number_of_Registrations_Allowed__c = 5, Company_Name__c = 'TestCompanyName', Available_Check_In_Date__c = '11/1/2013');
        insert eventAttTypeConfObj;
        
        Registration__c regObj = new Registration__c ( Registrant__c = conObj.id, Status__c = 'Attended', Company_Name__c = 'TestReg Company', Name = 'Autodesk_OTC' + ' - FN' + ' - LN', Event__c = eventObj.id);
        insert regObj;
        
        Registration_Group__c regGrpObj = new Registration_Group__c( Name='TestRegGrp Name', Event__c = eventObj.id, Booth_Sponsorship_Level__c='Platinum EC',Exhibitor_Level__c = 'Platinum');
        insert regGrpObj;
        
        Registration_Invite__c regInviteObj = new Registration_Invite__c( Registration__c = regObj.id, First_Name__c = 'TestFirstName');
        insert regInviteObj;
        
        Guest__c guestObj = new Guest__c( Type__c = 'Guest', Registration__c = regObj.id
                                        );
        insert guestObj;
        List<Id> lstguestIds = new List<Id>();
        //lstguestIds.add(guestObj.id);
        
        Lodging__c lodObj = new Lodging__c ( Registration__c = regObj.Id, Room_Type_PickList__c = 'ROH', Guest__c = guestObj.id
                                           );
        insert lodObj;
        
        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        DateTime dateTimeVal = system.now()- 10;
        DateTime dateTimeVal1 = system.now()+ 10;
        
        Product2 prodObj = new Product2 ( Name='Test Product Entry 1', Description='Test Product Entry 1', ProductCode = 'ABC', isActive = true,
                                          Product_Type__c = 'PromoCode', Event_Sponorship__c = 'EC Welcome Reception', Attendee_Type__c = 'Guest',
                                          Booth_Sponsorship_Level__c = 'Gold', Start_Date__c = dateTimeVal, End_Date__c = dateTimeVal1,
                                          Product_Size__c = 1, Event__c = eventObj.id, Conference_Type__c = 'Full Conference'
                                     );
        insert prodObj;          
       
        PricebookEntry pbe1 = new PricebookEntry ( Product2ID=prodObj.id, Pricebook2ID=standardPb.id, UnitPrice=50, isActive=true);
        insert pbe1;
        
        Opportunity oppObj = new Opportunity ( Name='Opp1',registration__c = regObj.id,StageName='Stage 0 - Lead Handed Off',
                                             CloseDate=Date.today(), Pricebook2Id = pbe1.Pricebook2Id, AccountId = accObj.id);
        insert oppObj;
        
        OpportunityLineItem oppLineItemObj = new OpportunityLineItem ( Product_Type__c='PromoCode',OpportunityID=oppObj.id,
                                                                       PriceBookEntryID=pbe1.id, quantity=4, totalprice=200,
                                                                       Description = 'Test opp Desc',Promo_Code__c = 'ABC',
                                                                       Status__c = 'Approved'
                                                                       );
        insert oppLineItemObj;
        
        Attachment attachObj = new Attachment( ParentId = regObj.id, Description = 'TestDesc', Name = 'TestName', Body = blob.valueOf('abc')
                                            );
        insert attachObj;
        
        Award_Nomination__c awardNominationObj = new Award_Nomination__c( Registration__c = regObj.id
                                                                        );
        insert awardNominationObj;        
        
        EEG_RegistrationUtility eegRegUtilityObj = new EEG_RegistrationUtility();
        eegRegUtilityObj.isPromocodeRequiredForRegistrationForTheAttendeeType(eventObj.id,'TestAttendeeType');
        eegRegUtilityObj.isPromocodeRequiredForRegistrationForTheAttendeeType(eventObj.id,'TestAttendee');
        eegRegUtilityObj.isPromocodeRequiredForRegistrationForTheAttendeeType(null,'TestAttendeeType');
        
        eegRegUtilityObj.isPromocodeRequiredForEmailOrEmailDomain(eventObj.id,'test@test.com',true);
        eegRegUtilityObj.isPromocodeRequiredForEmailOrEmailDomain(null,'test@test.com',true);
        
        eegRegUtilityObj.isValidPromoCodeForTheAttendeeType(eventObj.id,'ABC','Guest');
        eegRegUtilityObj.isValidPromoCodeForTheAttendeeType(null,null,'Guest');
        
        eegRegUtilityObj.isValidPromoCode(eventObj.id,'ABC');
        eegRegUtilityObj.isValidPromoCode(null,null);
        
        eegRegUtilityObj.isValidPromoCode(eventObj.id,'ABC','Standard Price Book');
        eegRegUtilityObj.isValidPromoCode(eventObj.id,'ABC','test');
        eegRegUtilityObj.isValidPromoCode(null,null,null); 

        eegRegUtilityObj.isValidPromoCodeForAttendeeTypeConfType(eventObj.id,'ABC',standardPb.name,'Guest','Full Conference');
        eegRegUtilityObj.isValidPromoCodeForAttendeeTypeConfType(eventObj.id,'ABC','test','Guest','Full Conference');
        eegRegUtilityObj.isValidPromoCodeForAttendeeTypeConfType(null,null,standardPb.name,'','');
        eegRegUtilityObj.isValidPromoCodeForAttendeeTypeConfType(null,null,standardPb.name,'Guest','');
        eegRegUtilityObj.isValidPromoCodeForAttendeeTypeConfType(null,null,standardPb.name,'','Full Conference');

        eegRegUtilityObj.getPromoCodeProductDetails(eventObj.id,'ABC');
        eegRegUtilityObj.getPromoCodeProductDetails(eventObj.id,'');
        
        eegRegUtilityObj.getPromoCodeProduct(eventObj.id,'ABC','PromoCode',true);
        eegRegUtilityObj.getPromoCodeProduct(eventObj.id,'','PromoCode',true);
        
        eegRegUtilityObj.isValidPromoCodeForTheAttendeeTypeNew(eventObj.id,'ABC',standardPb.name,'TestAttendeeType');
        eegRegUtilityObj.isValidPromoCodeForTheAttendeeTypeNew(eventObj.id,'',standardPb.name,'TestAttendeeType');
        
        eegRegUtilityObj.getRegistrationFromEventIdContactId(eventObj.id,conObj.id);
        eegRegUtilityObj.getRegistrationFromEventIdContactId(eventObj.id,null);
        
        eegRegUtilityObj.getRegistrationFromEventListContactId(eventIdList,conObj.id);
        eegRegUtilityObj.getRegistrationFromEventListContactId(eventIdList,null);
        
        eegRegUtilityObj.isBlackListedEmailDomain(eventObj.id,'test@test.com');
        eegRegUtilityObj.isBlackListedEmailDomain(eventObj.id,'test.com');
        eegRegUtilityObj.isBlackListedEmailDomain(eventObj.id,'');
        
        eegRegUtilityObj.isWhiteListedEmailDomain(eventObj.id,'test@test.com');
        eegRegUtilityObj.isWhiteListedEmailDomain(eventObj.id,'test.com');
        eegRegUtilityObj.isWhiteListedEmailDomain(eventObj.id,'');
        
        eegRegUtilityObj.isWhiteListedEmailAddress(eventObj.id,'test@test.com');
        eegRegUtilityObj.isWhiteListedEmailAddress(eventObj.id,'test.com');
        eegRegUtilityObj.isWhiteListedEmailAddress(eventObj.id,'');
        
        eegRegUtilityObj.isAttendeeTypeWhiteOrBlackListed(eventObj.id,'TestAttendeeType','test@test.com');
        eventAttTypeConfObj.Whitelist_Blacklist__c = 'Whitelist';
        update eventAttTypeConfObj;  
        eegRegUtilityObj.isAttendeeTypeWhiteOrBlackListed(eventObj.id,'TestAttendeeType','test@test.com');
        eventAttTypeConfObj.Whitelist_Blacklist__c = 'Blacklist';
        update eventAttTypeConfObj;  
        eegRegUtilityObj.isAttendeeTypeWhiteOrBlackListed(eventObj.id,'TestAttendeeType','test@test.com');
        eegRegUtilityObj.isAttendeeTypeWhiteOrBlackListed(null,'TestAttendeeType','test@test.com');
        eegRegUtilityObj.isAttendeeTypeWhiteOrBlackListed(null,'','');
        
                
        eegRegUtilityObj.getNumberOfRegistrationsForCompanyName(eventObj.id,'TestCompanyName');
        eegRegUtilityObj.getNumberOfRegistrationsForCompanyName(eventObj.id,null);
        
        eegRegUtilityObj.getNumberOfRegistrations(eventObj.id,'TestCompanyName');
        
        eegRegUtilityObj.getNumberOfDays(eventObj.id);
        eegRegUtilityObj.getNumberOfDays(null);
        
        PageReference requestedPageRef = Page.F5_ISC_RegistrationHome;
        eegRegUtilityObj.loginUser('Test@username.com','Testpass123','.eventSuffix.1',requestedPageRef,'successPageURL');
        eegRegUtilityObj.loginUser('','','.eventSuffix.1',requestedPageRef,'successPageURL');
        
        eegRegUtilityObj.forgotPassword('Test@username.com','.eventSuffix.1',requestedPageRef);
        eegRegUtilityObj.forgotPassword('','.eventSuffix.1',requestedPageRef);
        
        eegRegUtilityObj.changePassword('test12345','test12345','testold12345');
        eegRegUtilityObj.changePassword('','','testold12345');
        eegRegUtilityObj.changePassword('test12345','test1234','testold12345');
        
        Registration__c regObjNew = new Registration__c();
        eegRegUtilityObj.createRegistration(eventObj.id,conObj.id,regObjNew,UserInfo.getUserId(),'Registered','Test','TestFirstName','TestLastName');
        eegRegUtilityObj.createRegistration(eventObj.id,conObj.id,null,UserInfo.getUserId(),'Registered','Test','TestFirstName','TestLastName');
        
        eegRegUtilityObj.createRegistrationV1(eventObj.id,conObj,regObjNew,UserInfo.getUserId(),'Registered','Test');
        eegRegUtilityObj.createRegistrationV1(eventObj.id,conObj,null,UserInfo.getUserId(),'Registered','Test');
        
        eegRegUtilityObj.createOpportunity(eventObj.id,accObj.id,regObj.id,'TestEventName',null,'Standard Price Book','TestFirstName','TestLastName');
        
        eegRegUtilityObj.createOpportunityForRegistrationGroup(eventObj.id,accObj.id,regGrpObj.id,'TestEventName',null,'Standard Price Book','TestGroupName');
        
        List<OpportunityLineItem> opptyLineItems1 = eegRegUtilityObj.createOpportunityLineItems(eventObj.id,'Standard Price Book',oppObj.id,'','ABC','TestAttendeeType');
         List<OpportunityLineItem> opptyLineItems2 = eegRegUtilityObj.createOpportunityLineItems(eventObj.id,'Standard Price Book',oppObj.id,'','ABC','');
        
        eegRegUtilityObj.upsertOpportunityLineItems(oppObj,opptyLineItems1);
        eegRegUtilityObj.getProducts(opptyLineItems1);
        eegRegUtilityObj.createMapOfLineItem(opptyLineItems1); 
        eegRegUtilityObj.getExisitingOppLineItem(oppObj.id);
        
        String customerPortalUserId = eegRegUtilityObj.createUser(accObj.id,'test@test.com','test12345','.eventSuffix.1','TestFirstName','TestLastName','TestCompany');
        eegRegUtilityObj.createUser(accObj.id,'testcon@test.com','test12345','.eventSuffix.1','TestFirstName','TestLastName','TestCompany');
        
        eegRegUtilityObj.createUserV1(accObj.id,conObj,'test12345','.eventSuffix.1');
        conObj.email = '';
        update conObj;
        eegRegUtilityObj.createUserV1(accObj.id,conObj,'test12345','.eventSuffix.1');
        
        List<String> ccEmailAddressList = new List<String>();ccEmailAddressList.add('test@test.com.c1');
        List<String> bccEmailAddressList = new List<String>();bccEmailAddressList.add('test@test.com.c1');
        eegRegUtilityObj.sendEmail(conObj.Id, regObj.Id, '000000000000000000', '000000000000000000', ccEmailAddressList, bccEmailAddressList, false);
        eegRegUtilityObj.sendEmailWithAttachment(conObj.Id, regObj.Id,  '000000000000000000', '000000000000000000', ccEmailAddressList, bccEmailAddressList, false, blob.valueof('Attachment'), 'TestfileName');
       
        eegRegUtilityObj.getProfileId('System Administrator');
        
        eegRegUtilityObj.getPortalUserAccount(customerPortalUserId);
        
        eegRegUtilityObj.getPortalUserAccount(customerPortalUserId);
        
        eegRegUtilityObj.getContactAccount(conObj.id);
        eegRegUtilityObj.getCurrencySymbol('USD');
        eegRegUtilityObj.pageRedirect(requestedPageRef,true);
        
        eegRegUtilityObj.rerenderPaymentCreditcard('Contact me for payment');
        eegRegUtilityObj.rerenderPaymentCreditcard('TestPayment');
        
        eegRegUtilityObj.getOpportunityLineItems(regObj.id);
        oppLineItemObj.Product_Type__c='Workshop';
        update oppLineItemObj;
        eegRegUtilityObj.getOpportunityLineItems(regObj.id);
        
        eegRegUtilityObj.decode('');
        eegRegUtilityObj.decode(eegRegUtilityObj.encode('TestText'));
        test.stopTest();
    }
    
    static testMethod void EEG_RegistrationUtility_UnitTest1() 
    {
        test.startTest();
        Account accObj = new Account( Name = 'Test New Account');
        insert accObj;
        
        Contact conObj = new Contact( AccountId = accObj.id,FirstName = 'TestFirstCon', LastName = 'TestLast', Email = 'test@test.com',
                                      company_name__c = 'TestCompanyName'                                      
                                    );
        insert conObj;
        
        List<String> eventIdList = new List<String>();
        Event_Header__c eventObj = new Event_Header__c( Account__c = accObj.id, Event_Name__c ='EEG DEMO', Start_Date__c= system.today(),
                                                        End_Date__c = system.today().addDays(10), Email_From_Address__c='eegmaster@yopmail.com',
                                                        Event_Code__c ='Brocade123', Program_Number__c='5654', Program_Type__c='Type'
                                                      );
        insert eventObj;
        eventIdList.add(eventObj.id);
        
        Event_Attendee_Type_Configuration__c eventAttTypeConfObj = new Event_Attendee_Type_Configuration__c( Event__c = eventObj.id, 
                                                                                                             Attendee_Type__c = 'TestAttendeeType',
                                                                                                             Is_Promocode_required__c = true,
                                                                                                             Email_Email_domain__c = 'test@test.com',
                                                                                                             Number_of_Registrations_Allowed__c = 5,
                                                                                                             Company_Name__c = 'TestCompanyName',
                                                                                                             Available_Check_In_Date__c = '11/1/2013'
        
                                                                                                );
        insert eventAttTypeConfObj;
        
        Registration__c regObj = new Registration__c ( Registrant__c = conObj.id, Status__c = 'Attended', Company_Name__c = 'TestReg Company',
                                                        Name = 'Autodesk_OTC' + ' - FN' + ' - LN', Event__c = eventObj.id
                                                     );
        insert regObj;
        
        Registration_Group__c regGrpObj = new Registration_Group__c( Name='TestRegGrp Name', Event__c = eventObj.id, 
                                                                     Booth_Sponsorship_Level__c='Platinum EC',
                                                                     Exhibitor_Level__c = 'Platinum'
                                                                   );
        insert regGrpObj;
        
        Registration_Invite__c regInviteObj = new Registration_Invite__c( Registration__c = regObj.id, First_Name__c = 'TestFirstName');
        insert regInviteObj;
        
        Guest__c guestObj = new Guest__c( Type__c = 'Guest', Registration__c = regObj.id
                                        );
        insert guestObj;
        List<Id> lstguestIds = new List<Id>();
        //lstguestIds.add(guestObj.id);
        
        Lodging__c lodObj = new Lodging__c ( Registration__c = regObj.Id, Room_Type_PickList__c = 'ROH', Guest__c = guestObj.id
                                           );
        insert lodObj;
        
        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        DateTime dateTimeVal = system.now()- 10;
        DateTime dateTimeVal1 = system.now()+ 10;
        
        Product2 prodObj = new Product2 ( Name='Test Product Entry 1', Description='Test Product Entry 1', ProductCode = 'ABC', isActive = true,
                                          Product_Type__c = 'PromoCode', Event_Sponorship__c = 'EC Welcome Reception', Attendee_Type__c = 'Guest',
                                          Booth_Sponsorship_Level__c = 'Gold', Start_Date__c = dateTimeVal, End_Date__c = dateTimeVal1,
                                          Product_Size__c = 1, Event__c = eventObj.id, Conference_Type__c = 'Full Conference'
                                     );
        insert prodObj;          
       
        PricebookEntry pbe1 = new PricebookEntry ( Product2ID=prodObj.id, Pricebook2ID=standardPb.id, UnitPrice=50, isActive=true);
        insert pbe1;
        
        Opportunity oppObj = new Opportunity ( Name='Opp1',registration__c = regObj.id,StageName='Stage 0 - Lead Handed Off',
                                             CloseDate=Date.today(), Pricebook2Id = pbe1.Pricebook2Id, AccountId = accObj.id);
        insert oppObj;
        
        OpportunityLineItem oppLineItemObj = new OpportunityLineItem ( Product_Type__c='PromoCode',OpportunityID=oppObj.id,
                                                                       PriceBookEntryID=pbe1.id, quantity=4, totalprice=200,
                                                                       Description = 'Test opp Desc',Promo_Code__c = 'ABC',
                                                                       Status__c = 'Approved'
                                                                       );
        insert oppLineItemObj;
        
        Attachment attachObj = new Attachment( ParentId = regObj.id, Description = 'TestDesc', Name = 'TestName', Body = blob.valueOf('abc')
                                            );
        insert attachObj;
        
        Award_Nomination__c awardNominationObj = new Award_Nomination__c( Registration__c = regObj.id
                                                                        );
        insert awardNominationObj;        
        
        EEG_RegistrationUtility eegRegUtilityObj = new EEG_RegistrationUtility();
               
        List<String> prodList = new List<String>();
        Product2 prodObj2 = new Product2 ( Name='Test Product Entry 1', Description='Test Product Entry 1', ProductCode = 'ABC', isActive = true,
                                          Product_Type__c = 'PromoCode', Event_Sponorship__c = 'EC Welcome Reception', Attendee_Type__c = 'Guest',
                                          Booth_Sponsorship_Level__c = 'Gold', Start_Date__c = dateTimeVal, End_Date__c = dateTimeVal1, Child_End_Age__c = 30,
                                          Product_Size__c = 1, Event__c = eventObj.id, Conference_Type__c = 'Full Conference', Child_Start_Age__c = 20
                                     );
        insert prodObj2;
        
        Product2 prodObj3 = new Product2 ( Name='Test Product Entry 1', Description='Test Product Entry 1', ProductCode = 'ABC', isActive = true,
                                          Product_Type__c = 'Registration', Event_Sponorship__c = 'EC Welcome Reception', Attendee_Type__c = 'Guest',
                                          Booth_Sponsorship_Level__c = 'Gold', Start_Date__c = dateTimeVal, End_Date__c = dateTimeVal1, Child_End_Age__c = 30,
                                          Product_Size__c = 1, Event__c = eventObj.id, Conference_Type__c = 'Full Conference', Child_Start_Age__c = 20
                                     );
        insert prodObj3;
        
        PricebookEntry pbe2 = new PricebookEntry ( Product2ID=prodObj2.id, Pricebook2ID=standardPb.id, UnitPrice=50, isActive=true);
        insert pbe2;
        
        PricebookEntry pbe3 = new PricebookEntry ( Product2ID=prodObj3.id, Pricebook2ID=standardPb.id, UnitPrice=50, isActive=true);
        insert pbe3;
        
        prodList.add(prodObj2.ProductCode); 
        prodList.add(prodObj3.ProductCode);         
        eegRegUtilityObj.createOpportunityLineItemList(eventObj.id,'Standard Price Book','Guest',prodList,'PromoCode');
        eegRegUtilityObj.createOpportunityLineItemList(eventObj.id,'Standard Price Book','Guest',prodList,'Registration');
        eegRegUtilityObj.createOpportunityLineItemList(eventObj.id,'Standard Price Book','',prodList,'PromoCode');
        
        eegRegUtilityObj.createOpportunityLineItemList(eventObj.id,'Standard Price Book','Guest',prodList,'Workshops');
        eegRegUtilityObj.createOpportunityLineItemList(eventObj.id,'Standard Price Book','',prodList,'Workshops');
        
        eegRegUtilityObj.createOpportunityLineItemListV2(eventObj.id,'Standard Price Book','Guest','Full Conference',prodList,'PromoCode');
        eegRegUtilityObj.createOpportunityLineItemListV2(eventObj.id,'Standard Price Book','','Full Conference',prodList,'PromoCode');
        eegRegUtilityObj.createOpportunityLineItemListV2(eventObj.id,'Standard Price Book','Guest','',prodList,'PromoCode');
        eegRegUtilityObj.createOpportunityLineItemListV2(eventObj.id,'Standard Price Book','','',prodList,'PromoCode');
        
        eegRegUtilityObj.createOpportunityLineItemListV2(eventObj.id,'Standard Price Book','Guest','Full Conference',prodList,'Registration');
        eegRegUtilityObj.createOpportunityLineItemListV2(eventObj.id,'Standard Price Book','','Full Conference',prodList,'Registration');
        eegRegUtilityObj.createOpportunityLineItemListV2(eventObj.id,'Standard Price Book','Guest','',prodList,'Registration');
        eegRegUtilityObj.createOpportunityLineItemListV2(eventObj.id,'Standard Price Book','','',prodList,'Registration');
        
        eegRegUtilityObj.createOpportunityLineItemListForGuest(eventObj.id,'Standard Price Book','Guest',prodList,'PromoCode',25);
        eegRegUtilityObj.createOpportunityLineItemListForGuest(eventObj.id,'Standard Price Book','',prodList,'PromoCode',25);
        eegRegUtilityObj.createOpportunityLineItemListForGuest(eventObj.id,'Standard Price Book','Guest',prodList,'PromoCode',25);
        eegRegUtilityObj.createOpportunityLineItemListForGuest(eventObj.id,'Standard Price Book','',prodList,'PromoCode',25);
        
        eegRegUtilityObj.createOpportunityLineItemListForGuest(eventObj.id,'Standard Price Book','Guest',prodList,'Registration',25);
        eegRegUtilityObj.createOpportunityLineItemListForGuest(eventObj.id,'Standard Price Book','',prodList,'Registration',25);
        eegRegUtilityObj.createOpportunityLineItemListForGuest(eventObj.id,'Standard Price Book','Guest',prodList,'Registration',25);
        eegRegUtilityObj.createOpportunityLineItemListForGuest(eventObj.id,'Standard Price Book','',prodList,'Registration',25); 
        test.stopTest();       
    }
    
    static testMethod void EEG_RegistrationUtility_UnitTest2() 
    {
        Account accObj = new Account( Name = 'Test New Account');
        insert accObj;
        
        Contact conObj = new Contact( AccountId = accObj.id,FirstName = 'TestFirstCon', LastName = 'TestLast', Email = 'test@test.com',
                                      company_name__c = 'TestCompanyName'                                      
                                    );
        insert conObj;
        
        List<String> eventIdList = new List<String>();
        Event_Header__c eventObj = new Event_Header__c( Account__c = accObj.id, Event_Name__c ='EEG DEMO', Start_Date__c= system.today(),
                                                        End_Date__c = system.today().addDays(10), Email_From_Address__c='eegmaster@yopmail.com',
                                                        Event_Code__c ='Brocade123', Program_Number__c='5654', Program_Type__c='Type'
                                                      );
        insert eventObj;
        eventIdList.add(eventObj.id);
        
        Event_Attendee_Type_Configuration__c eventAttTypeConfObj = new Event_Attendee_Type_Configuration__c( Event__c = eventObj.id, 
                                                                                                             Attendee_Type__c = 'TestAttendeeType',
                                                                                                             Is_Promocode_required__c = true,
                                                                                                             Email_Email_domain__c = 'test@test.com',
                                                                                                             Number_of_Registrations_Allowed__c = 5,
                                                                                                             Company_Name__c = 'TestCompanyName',
                                                                                                             Available_Check_In_Date__c = '11/1/2013'
        
                                                                                                );
        insert eventAttTypeConfObj;
        
        Registration__c regObj = new Registration__c ( Registrant__c = conObj.id, Status__c = 'Attended', Company_Name__c = 'TestReg Company',
                                                        Name = 'Autodesk_OTC' + ' - FN' + ' - LN', Event__c = eventObj.id
                                                     );
        insert regObj;
        
        Registration_Group__c regGrpObj = new Registration_Group__c( Name='TestRegGrp Name', Event__c = eventObj.id, 
                                                                     Booth_Sponsorship_Level__c='Platinum EC',
                                                                     Exhibitor_Level__c = 'Platinum', Company_Name__c ='TestCompanyName'
                                                                   );
        insert regGrpObj;
        
        Registration_Invite__c regInviteObj = new Registration_Invite__c( Registration__c = regObj.id, First_Name__c = 'TestFirstName');
        insert regInviteObj;
        
        Guest__c guestObj = new Guest__c( Type__c = 'Guest', Registration__c = regObj.id
                                        );
        insert guestObj;
        List<Id> lstguestIds = new List<Id>();
        //lstguestIds.add(guestObj.id);
        
        Lodging__c lodObj = new Lodging__c ( Registration__c = regObj.Id, Room_Type_PickList__c = 'ROH', Guest__c = guestObj.id
                                           );
        insert lodObj;
        
        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        DateTime dateTimeVal = system.now()- 10;
        DateTime dateTimeVal1 = system.now()+ 10;
        
        Product2 prodObj = new Product2 ( Name='Test Product Entry 1', Description='Test Product Entry 1', ProductCode = 'ABC', isActive = true,
                                          Product_Type__c = 'PromoCode', Event_Sponorship__c = 'EC Welcome Reception', Attendee_Type__c = 'Guest',
                                          Booth_Sponsorship_Level__c = 'Gold', Start_Date__c = dateTimeVal, End_Date__c = dateTimeVal1,
                                          Product_Size__c = 1, Event__c = eventObj.id, Conference_Type__c = 'Full Conference'
                                     );
        insert prodObj;
        
        PricebookEntry pbe1 = new PricebookEntry ( Product2ID=prodObj.id, Pricebook2ID=standardPb.id, UnitPrice=50, isActive=true);
        insert pbe1;
        
        Opportunity oppObj = new Opportunity ( Name='Opp1',registration__c = regObj.id,StageName='Stage 0 - Lead Handed Off',
                                             CloseDate=Date.today(), Pricebook2Id = pbe1.Pricebook2Id, AccountId = accObj.id);
        insert oppObj;
        
        OpportunityLineItem oppLineItemObj = new OpportunityLineItem ( Product_Type__c='PromoCode',OpportunityID=oppObj.id,
                                                                       PriceBookEntryID=pbe1.id, quantity=4, totalprice=200,
                                                                       Description = 'Test opp Desc',Promo_Code__c = 'ABC',
                                                                       Status__c = 'Approved'
                                                                       );
        insert oppLineItemObj;
        
        Attachment attachObj = new Attachment( ParentId = regObj.id, Description = 'TestDesc', Name = 'TestName', Body = blob.valueOf('abc')
                                            );
        insert attachObj;
        
        Award_Nomination__c awardNominationObj = new Award_Nomination__c( Registration__c = regObj.id
                                                                        );
        insert awardNominationObj;   
        
        Topic__c tpc = new Topic__c();
        tpc.Event__c = eventObj.Id;
        tpc.Role__c = 'Technical';
        tpc.Title__c = 'Test Title';
        insert tpc;
        
        Session__c sss = new Session__c();
        sss.Event__c = eventObj.id;
        sss.role__c = 'Technical';
        sss.Topic__c = tpc.Id;
        sss.Start_Time__c = system.today();
        sss.Max_Enrolled_Session_Occurrence_Allowed__c=10;
        insert sss;
        
        Session_Group__c sessionGrp = new Session_Group__c();
        sessionGrp.Event__c = eventObj.id;
        sessionGrp.Name = 'Test';
        insert sessionGrp;       
        
        Session__c ss = new Session__c();
        ss.Event__c = eventObj.id;
        ss.role__c = 'Technical';
        ss.Topic__c = tpc.Id;
        ss.Start_Time__c = system.today();
        ss.Max_Enrolled_Session_Occurrence_Allowed__c=10;
        ss.Min_Parent_Session_Enrollment_Required__c= 0;
        ss.Parent_Session__c =sss.id;
        ss.Session_Group__c = sessionGrp.id;
        insert ss;
             
        Session_Occurrence__c sessionoccur = new Session_Occurrence__c();
        sessionoccur.Session__c=ss.id;
        sessionoccur.Status__c = 'Active';
        sessionoccur.Start_Time__c=system.today();
        sessionoccur.End_Time__c = system.today();
        sessionoccur.Roles_For_Which_Session_Not_Mandatory__c = 'Ethernet';
        sessionoccur.Capacity__c = 0;   
        sessionoccur.External_Session_Code__c = 'Testing1234';
        insert sessionoccur;   
        
        List<Session_Participant__c> Listsp1 = new List<Session_Participant__c>();
        Session_Participant__c sp1 = new Session_Participant__c();
        sp1.Session_Occurrence__c = sessionoccur.Id;        
        sp1.Registration__c = regObj.Id;
        sp1.Status__c ='Enrolled';
        //sp1.Manually_Created__c = true;
        Listsp1.add(sp1);
        insert Listsp1;  
        
        EEG_RegistrationUtility eegRegUtilityObj = new EEG_RegistrationUtility();
        List<String> applicableProducts = new List<String>();
        applicableProducts.add('TestPro');
        EEG_SiteProperties siteProperty = new EEG_SiteProperties('Test123');
        siteProperty.ACCOUNT_ID = accObj.id;
        siteProperty.EVENT_ID = eventObj.id;
        siteProperty.SITE_USER_SUFFIX = 'test.c1';
        
        reCAPTCHA captcha = new reCAPTCHA();
        EEG_InhouseCaptchaController eegCaptcha = new EEG_InhouseCaptchaController();
        
        eegRegUtilityObj.registerUser(conObj,regObj,siteProperty,'Test1234','Test1234',true,null,null,true,true,'Whitelist','TestPro',eventObj,true,captcha,eegCaptcha);
        eegRegUtilityObj.registerUser(conObj,regObj,siteProperty,'Test1234','Test1234',true,null,null,true,true,'Blacklist','TestPro',eventObj,true,captcha,eegCaptcha);
        
        eegRegUtilityObj.getAllProducts('Promocode','TestAttendeeType',eventObj.id);
        EEG_RegistrationUtility.ProductInvoiceClass EEGRegUProduct = new EEG_RegistrationUtility.ProductInvoiceClass();
        eegRegUtilityObj.updateInvoice(regObj.id,'TestAttendeeType','Full Conference',siteProperty,applicableProducts,'USD');
        eegRegUtilityObj.getAllRegistrationInvites(regObj.id);
        try{
            eegRegUtilityObj.createDeleteOpportunityLineItems(EEGRegUProduct,siteProperty,conObj,regObj,oppObj);
        } catch(exception e){}
        eegRegUtilityObj.getReferredByNameForEmailDomain(eventObj.id,'TestAttendeeType','test@test.com');
        Payment__c pay1= New Payment__c();
        eegRegUtilityObj.getCalculatedAmountMultiCurrency(pay1);
        eegRegUtilityObj.clearGusetValues(regObj);
        eegRegUtilityObj.clearGusetValues(null);
        eegRegUtilityObj.clearHotelRecord(lodObj);
        eegRegUtilityObj.validateAllowedBackdoorRegistrtaion(eventObj.id,accobj.id,conObj.email);
        
        eegRegUtilityObj.getStoredValuesSet('Account');
        Map<String,String> mapOfValueLabel = new Map<String,String>();
        mapOfValueLabel.put('test','TestAttendeeType');
        Set<String> storedValues = new Set<String>();
        storedValues.add('TestAttendeeType');
        eegRegUtilityObj.createWrapperList(mapOfValueLabel,storedValues,'default');
        EEG_RegistrationUtility.DropdownWrapperClass eegRegUtilityDrop = new EEG_RegistrationUtility.DropdownWrapperClass('eventname','label','default');
        List<EEG_RegistrationUtility.DropdownWrapperClass> ListeegRegUtilityDrop = new List<EEG_RegistrationUtility.DropdownWrapperClass>();
        ListeegRegUtilityDrop.add(eegRegUtilityDrop);
        eegRegUtilityObj.getSelectedDropdoenValues(ListeegRegUtilityDrop);
        eegRegUtilityObj.getDefaultValue(true);
        eegRegUtilityObj.getRegistrationGroupFromName(eventObj.id,'TestCompanyName');
        Registration_Group__c regGroupNewObj = new Registration_Group__c();
        eegRegUtilityObj.createRegistrationGroup(regGroupNewObj,eventObj.id);
        eegRegUtilityObj.createRegistrationGroupMember(regObj.id,regGrpObj.id);
        eegRegUtilityObj.getEventCountrySetting(eventObj.id,'TestAttendeeType');
        eegRegUtilityObj.getEventCountryCurrencySetting(eventObj.id,'United States');
        eegRegUtilityObj.getProductRegistrationGroup('PromoCode',regGrpObj.id,eventObj.id);
        
        Attachment attach1 = new Attachment();
    
        attach1.Description = 'test';
        attach1.name = 'test';
        attach1.Body = blob.valueOf('abc');
        //insert attach1;
        
        List<String> allowedFileTypeList = new List<String>();
        allowedFileTypeList.add('.txt');
        try{
            eegRegUtilityObj.validateAttachment(attach1,allowedFileTypeList,5454545,'Please Enter','Please Enter');
        }catch(exception e){}
        eegRegUtilityObj.getConversionRateFromCurrencyIsoCode('USD');
        Contact conNewObj = EEG_RegistrationHelperTest.createNewContact(accObj.id, 'FName1', 'LName1', 'test'+Math.round(Math.random()*Math.pow(10, 7))+'@salesforce.com.event.2');
        Contact conNewObj1 = EEG_RegistrationHelperTest.createNewContact(accObj.id, 'FName11', 'LName11', 'test'+Math.round(Math.random()*Math.pow(10, 7))+'@salesforces.com.event.2');
        
        Contact_Referral__c cr = new Contact_Referral__c();
        cr.Email__c = 'a@b.com';
        
        eegRegUtilityObj.populateEmergencyContactDetailsForGuest(conNewObj,conNewObj1);
        conNewObj.Is_Emergency_Info_Same__c = true;
        update conNewObj;
        eegRegUtilityObj.populateEmergencyContactDetailsForGuest(conNewObj,conNewObj1);
        eegRegUtilityObj.getEventAttendeeTypeConfiguration(null,'TestAttendeeType','test@test.com',true);
        eegRegUtilityObj.getEventAttendeeTypeConfiguration(eventObj.id,'TestAttendeeType','test@test.com',true);
        eegRegUtilityObj.getAwardNominee(regObj.id,awardNominationObj.id);
        eegRegUtilityObj.getAllAwardNominees(regObj.Id);
        eegRegUtilityObj.getGuestAirTravelRecords(lstguestIds);
        eegRegUtilityObj.getGuestLodgingRecords(lstguestIds);
        eegRegUtilityObj.getGuestActivities(lstguestIds);
        eegRegUtilityObj.incrementProductCount(prodObj);
        eegRegUtilityObj.decrementProductCount(prodObj);
        eegRegUtilityObj.isProductAvailable(eventObj.id,'Activity','promocode0000',null,true,true);
        eegRegUtilityObj.fetchAtachment(awardNominationObj.id,'test');
        eegRegUtilityObj.isValidDate(system.now());
        eegRegUtilityObj.isValidDate(null);
        eegRegUtilityObj.isEventItemsOpen(eventObj.id, 'Registration');
        eegRegUtilityObj.isEventItemsClosed(eventObj.id,'Registration');
        eegRegUtilityObj.isEventItemsOpen(eventObj.id, 'Src');
        eegRegUtilityObj.isEventItemsClosed(eventObj.id,'Src');
        eegRegUtilityObj.isEventItemsOpen(eventObj.id, 'Cfp');
        eegRegUtilityObj.isEventItemsClosed(eventObj.id,'Cfp');
        eegRegUtilityObj.getAllAtachments(regObj.id);       
        //eegRegUtilityObj.isAlreadyReferredBytheSameContact(null, null, null);
        eegRegUtilityObj.isAlreadyReferredBytheSameContact(accObj.id, conNewObj, conNewObj1);
        eegRegUtilityObj.fetchRegAndcheckIfDeclined(eventObj.id,conNewObj.email);
        eegRegUtilityObj.isContactReferralExist(accObj.id, conNewObj,cr);
        eegRegUtilityObj.insertSessionErrorLog(eventObj.id,regObj.id,sessionoccur.id,'Testing','Type');
        eegRegUtilityObj.getProductListFromSessions(Listsp1,eventObj.id);
        
    }
    
    static testMethod void EEG_RegistrationUtility_UnitTest3() 
    {
        test.startTest();
        Account accObj = new Account( Name = 'Test New Account');
        insert accObj;
        
        Contact conObj = new Contact( AccountId = accObj.id,FirstName = 'TestFirstCon', LastName = 'TestLast', Email = 'test@test.com',
                                      company_name__c = 'TestCompanyName'                                      
                                    );
        insert conObj;
        
        List<String> eventIdList = new List<String>();
        Event_Header__c eventObj = new Event_Header__c( Account__c = accObj.id, Event_Name__c ='EEG DEMO', Start_Date__c= system.today(),
                                                        End_Date__c = system.today().addDays(10), Email_From_Address__c='eegmaster@yopmail.com',
                                                        Event_Code__c ='Brocade123', Program_Number__c='5654', Program_Type__c='Type'
                                                      );
        insert eventObj;
        eventIdList.add(eventObj.id);
        
        Event_Attendee_Type_Configuration__c eventAttTypeConfObj = new Event_Attendee_Type_Configuration__c( Event__c = eventObj.id, 
                                                                                                             Attendee_Type__c = 'TestAttendeeType',
                                                                                                             Is_Promocode_required__c = true,
                                                                                                             Email_Email_domain__c = 'test@test.com',
                                                                                                             Number_of_Registrations_Allowed__c = 5,
                                                                                                             Company_Name__c = 'TestCompanyName',
                                                                                                             Available_Check_In_Date__c = '11/1/2013'
        
                                                                                                );
        insert eventAttTypeConfObj;
        
        Registration__c regObj = new Registration__c ( Registrant__c = conObj.id, Status__c = 'Attended', Company_Name__c = 'TestReg Company',
                                                        Name = 'Autodesk_OTC' + ' - FN' + ' - LN', Event__c = eventObj.id
                                                     );
        insert regObj;
        
        Registration_Group__c regGrpObj = new Registration_Group__c( Name='TestRegGrp Name', Event__c = eventObj.id, 
                                                                     Booth_Sponsorship_Level__c='Platinum EC',
                                                                     Exhibitor_Level__c = 'Platinum'
                                                                   );
        insert regGrpObj;
        
        Registration_Invite__c regInviteObj = new Registration_Invite__c( Registration__c = regObj.id, First_Name__c = 'TestFirstName');
        insert regInviteObj;
        
        Guest__c guestObj = new Guest__c( Type__c = 'Guest', Registration__c = regObj.id
                                        );
        insert guestObj;
        List<Id> lstguestIds = new List<Id>();
        //lstguestIds.add(guestObj.id);
        
        Lodging__c lodObj = new Lodging__c ( Registration__c = regObj.Id, Room_Type_PickList__c = 'ROH', Guest__c = guestObj.id
                                           );
        insert lodObj;
        
        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        DateTime dateTimeVal = system.now()- 10;
        DateTime dateTimeVal1 = system.now()+ 10;
        
        Product2 prodObj = new Product2 ( Name='Test Product Entry 1', Description='Test Product Entry 1', ProductCode = 'ABC', isActive = true,
                                          Product_Type__c = 'PromoCode', Event_Sponorship__c = 'EC Welcome Reception', Attendee_Type__c = 'Guest',
                                          Booth_Sponsorship_Level__c = 'Gold', Start_Date__c = dateTimeVal, End_Date__c = dateTimeVal1,
                                          Product_Size__c = 1, Event__c = eventObj.id, Conference_Type__c = 'Full Conference'
                                     );
        insert prodObj;          
       
        PricebookEntry pbe1 = EEG_RegistrationHelperTest.createNewPriceBookEntry('Standard Price Book',prodObj.id,'USD',3000);
        pbe1.isActive=true;
        update pbe1;
        
        Opportunity oppObj = new Opportunity ( Name='Opp1',registration__c = regObj.id,StageName='Stage 0 - Lead Handed Off',
                                             CloseDate=Date.today(), Pricebook2Id = pbe1.Pricebook2Id, AccountId = accObj.id);
        insert oppObj;
        
        OpportunityLineItem oppLineItemObj = new OpportunityLineItem ( Product_Type__c='PromoCode',OpportunityID=oppObj.id,
                                                                       PriceBookEntryID=pbe1.id, quantity=4, totalprice=200,
                                                                       Description = 'Test opp Desc',Promo_Code__c = 'ABC',
                                                                       Status__c = 'Approved'
                                                                       );
        insert oppLineItemObj;
        
        OpportunityLineItem lineItem0 = new OpportunityLineItem (Product_Type__c = 'Registration',OpportunityID=oppObj.id,PriceBookEntryID=pbe1.id, quantity=4,UnitPrice=100);
        insert lineItem0;
                
        Map<String,OpportunityLineItem> PBE_OldLineItemMap = new Map<String,OpportunityLineItem>();
        Map<String,OpportunityLineItem> PBE_NewLineItemMap = new Map<String,OpportunityLineItem>();
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (Product_Type__c = 'Workshop',OpportunityID=oppObj.id,PriceBookEntryID=pbe1.id, quantity=4,UnitPrice=200);
        insert lineItem1;
        PBE_OldLineItemMap.put(lineItem1.PriceBookEntryID,lineItem1);
       
        
        OpportunityLineItem lineItem2 = new OpportunityLineItem (Product_Type__c = 'Guest Event',OpportunityID=oppObj.id,PriceBookEntryID=pbe1.id, quantity=4,UnitPrice=200);
        insert lineItem2;
        PBE_NewLineItemMap.put(lineItem2.PriceBookEntryID,lineItem1);
        
        OpportunityLineItem lineItem3 = new OpportunityLineItem (Product_Type__c = 'Hotel',OpportunityID=oppObj.id,PriceBookEntryID=pbe1.id, quantity=4,totalprice=200,Description ='abcdf');
        insert lineItem3;
        
        Email_Blast_Request__c emailReqObj = new Email_Blast_Request__c(Event__c = eventObj.id, IsActive__c=true,
                                                                        IsUsedInRegistrationForm__c = true,
                                                                        Exhibitor_Level__c = 'Paltinum'
                                                                        );
        insert emailReqObj;
        
        Participant__c  partcipantObj = new Participant__c (RSVP_Request__c = emailReqObj.id, Registration__c = regObj.id);
        insert partcipantObj;
        
        Contact_Referral__c CR = new Contact_Referral__c( Referred_By__c=conObj.id,Referred_Contact__c=conObj.id); 
        insert CR;
        
        
                
        
        EEG_RegistrationUtility.opportunityLineItemWrapperclass  eegregutyoppline = new EEG_RegistrationUtility.opportunityLineItemWrapperclass();
        EEG_RegistrationUtility.OppLineItem lineItemInnerClass0 = new  EEG_RegistrationUtility.OppLineItem(lineItem0);
        EEG_RegistrationUtility.OppLineItem lineItemInnerClass1 = new  EEG_RegistrationUtility.OppLineItem(lineItem1);
        EEG_RegistrationUtility.OppLineItem lineItemInnerClass2 = new  EEG_RegistrationUtility.OppLineItem(lineItem2);
         EEG_RegistrationUtility.OppLineItem lineItemInnerClass3 = new  EEG_RegistrationUtility.OppLineItem(lineItem3);
        
        lineItemInnerClass1.compareTo(lineItemInnerClass0);
        lineItemInnerClass3.compareTo(lineItemInnerClass1);  
        lineItemInnerClass3.compareTo(lineItemInnerClass2); 
        lineItemInnerClass1.compareTo(lineItemInnerClass3);
        
        Attachment attachObj = new Attachment( ParentId = regObj.id, Description = 'TestDesc', Name = 'TestName', Body = blob.valueOf('abc')
                                            );
        insert attachObj;
        
        Attachment attach1 = new Attachment();
        //attach1.ParentId = reg.id;
        attach1.Description = 'test';
        attach1.name = 'test';
        attach1.Body = blob.valueOf('abc');
        //insert attach1;
        
        Award_Nomination__c awardNominationObj = new Award_Nomination__c( Registration__c = regObj.id
                                                                        );
        insert awardNominationObj;  
        EEG_RegistrationUtility eegRegUtilityObj = new EEG_RegistrationUtility();
        Payment__c pay= New Payment__c();
        Pay.Amount__c=500;
        pay.Amount_Charged__c=400;
        pay.ConversionRate__c = 1;
        //pay.Amount_Due_in_USD__c = 500;
        decimal totalamount=eegRegUtilityObj.getCalculatedAmount(Pay); 
        insert pay;
        
        Paypal_Transaction_History__c PTH = new Paypal_Transaction_History__c();
        PTH.Payment__c=pay.id;
        PTH.Credit_Card_Number_Last_Four_Digits__c ='6798';
        insert PTH;
        
        eegRegUtilityObj.getEmailTemplateId('');
        
        eegRegUtilityObj.getUserName('TestUserName@test.com','.eventSuffix.1');
        eegRegUtilityObj.removeSiteSuffix('TestUserName@test.com','.eventSuffix.1');
        
        List<String> optionList = new List<String>();
        optionList.add('Test1');
        optionList.add('Test2');
        eegRegUtilityObj.removeNullValuesFromList(optionList);
        eegRegUtilityObj.getSelectOptions(optionList);
        eegRegUtilityObj.getCheckInDatesFromAttendeeType(eventObj.id,'TestAttendeeType');
        eegRegUtilityObj.insertRegistrationErrorLog(regObj.id,'TestError');
        eegRegUtilityObj.insertEventErrorLog(eventObj.id,'TestError','TestType');
        eegRegUtilityObj.redirectToLandingPage(Page.EEG_Override_Registration_Delete_Button, Page.EEG_Override_Registration_Delete_Button);
        
        
        Boolean boolen;
        EEG_RegistrationUtility.PaypalTransactionHistory EEGRegPaypal = new EEG_RegistrationUtility.PaypalTransactionHistory(PTH);
        
        EEG_PaypalProcessorWebservice.TransactionOutputDetails eegtrans = new EEG_PaypalProcessorWebservice.TransactionOutputDetails();   
        boolen=eegRegUtilityObj.isPaymentProcessed(eegtrans);
        //eegRegUtilityObj.paypalPalProcessOnline(pay);
        //eegRegUtilityObj.paypalPalProcessOnlineMultiCurrency(pay);
        eegRegUtilityObj.getCalculatedAmountMultiCurrency(pay);
        eegRegUtilityObj.createPaypalTransactionHistory(regObj,pay,eegtrans);
        eegRegUtilityObj.createPaypalTransactionHistorytMultiCurrency(regObj,pay,eegtrans); 
        
        eegRegUtilityObj.isPaymentProcessed(eegtrans);
        
        List<EEG_RegistrationUtility.OppLineItem> optlineItems = New List<EEG_RegistrationUtility.OppLineItem> ();
        optlineItems.add(lineItemInnerClass1);
        optlineItems.add(lineItemInnerClass2);      
        
        eegRegUtilityObj.processGuestCharge(optlineItems,'PromoCode');
        eegRegUtilityObj.revertGuestCharge(optlineItems,'PromoCode');
        Integer intt = 10;
        eegRegUtilityObj.processChildCharge(optlineItems,'PromoCode',intt);
        
        Guest__c newguest = New Guest__c();
        Contact con= New Contact();
        Registration__c reg = New Registration__c();
        newguest= eegRegUtilityObj.upsertGuest(newguest, String.valueof(con.Id) , String.valueof(reg.id),'Guest','Mr.','GuestFirstName','GuestLastName');
        
        eegRegUtilityObj.deletePreviousAttachments('test',regObj.Id);
        eegRegUtilityObj.saveAttachment(attach1,'test',regObj.id,regObj.ownerId);
        List<Paypal_Transaction_History__c> paypalTrans = new List<Paypal_Transaction_History__c>();
        paypalTrans.add(PTH);
        //insert paypalTrans;
        eegRegUtilityObj.getPaypalHistoryRecords(regObj);
        paypalTrans = eegRegUtilityObj.getPayPalHistory(regObj);
        Decimal d = eegRegUtilityObj.getTotalFromPayPalHistory(paypalTrans, 'Credit-Refund');
        eegRegUtilityObj.getRegistrationGroupMemberRecord(regObj.id);
        
        eegRegUtilityObj.getRSVP_Requests(eventObj.id,regGrpObj.Exhibitor_Level__c);
        eegRegUtilityObj.getExistingParticipants(eventObj.id,regObj.id); 
        eegRegUtilityObj.getAllRegGroupMembers(regGrpObj.id);
        eegRegUtilityObj.getGroupMamberRegistrations(null, null, true);
        eegRegUtilityObj.getGroupMamberRegistrations(null, null, false);
        eegRegUtilityObj.getContactReferralDetails(null);
        eegRegUtilityObj.getContactReferralDetails(CR.id);
        eegRegUtilityObj.getUpdatedContact(conObj,conObj);
        eegRegUtilityObj.getManagerDetails(conObj.id, eventObj.id);
        eegRegUtilityObj.getAllLodgings(regObj.id);
        eegRegUtilityObj.splitMultiSelectPicklist('Testing');
        eegRegUtilityObj.getconReferral(CR, CR);
        eegRegUtilityObj.round(null);
        eegRegUtilityObj.round(2.0); 
        eegRegUtilityObj.getAge(null, null);
        eegRegUtilityObj.getAge(System.today(), System.today());
        eegRegUtilityObj.getAllRegistrationInvites(regObj.id);
        DateTime dt = system.now();
        eegRegUtilityObj.isAfterCutoffDate(dt);
        eegRegUtilityObj.isBeforeCutoffDate(dt);
        String Recordtype = 'Registration Record Type';
        system.debug('Recordtype'+Recordtype);
        eegRegUtilityObj.getRecordTypeId(Recordtype); 
        Map<String,String> keyValueMap = new Map<String,String>();
        eegRegUtilityObj.createSelectoptionList(keyValueMap);
        List<String> selectvalues = new List<String>();
        selectvalues.add(Recordtype);
        eegRegUtilityObj.getStringForMultiSelectField(selectvalues);
        
        eegRegUtilityObj.getStringFromMultiSelectWithMap(Recordtype,keyValueMap);
        
        eegRegUtilityObj.getStringFromMultiSelectWithMap(Recordtype,keyValueMap);
        
        eegRegUtilityObj.getRegistrationGroup(regGrpObj.id);
        eegRegUtilityObj.getRegGroupOpportunityLineItem(regGrpObj.id);
        eegRegUtilityObj.isWhitelistedUserName('test@test1.com.sy.c1', eventObj.id,'sy.c1');
        EEG_RegistrationUtility.activityWrapperClass activityWrapper = new EEG_RegistrationUtility.activityWrapperClass();
        activityWrapper.activityChk1 =false;
        activityWrapper.activityChk2 =false;
        activityWrapper.validateActivity('Ride','Deep Sea Fishing', eventObj.Id);
        activityWrapper.decrementAndIncrementActivityProductCount(prodObj,true,prodObj);
        eegRegUtilityObj.createSelectOptionFromList(selectvalues);
        Integer intt1 = 10;        
        String externalUserName = 'tests@mail.com';
        eegRegUtilityObj.getContactFromExternalUserName(externalUserName ,accobj.id);
        Set<Id> productIds = new Set<Id>();
        productIds.add(prodObj.id);
        EEG_RegistrationUtility.ProductWrapperClass eegRegUtilityProduct = new EEG_RegistrationUtility.ProductWrapperClass(prodObj);
        EEG_RegistrationUtility.ProductWrapperClass eegRegUtilityProducts = new EEG_RegistrationUtility.ProductWrapperClass(prodObj,intt1);
        List<EEG_RegistrationUtility.ProductWrapperClass> ListeegRegUtilityProducts = new List<EEG_RegistrationUtility.ProductWrapperClass>();
        
        ListeegRegUtilityProducts.add(eegRegUtilityProduct);
        ListeegRegUtilityProducts.add(eegRegUtilityProducts);
        eegRegUtilityObj.makeProductWrapperReadOnly(ListeegRegUtilityProducts,'PromoCode');
        eegRegUtilityObj.makeProductWrapperDropDown(ListeegRegUtilityProducts,'PromoCode');
        eegRegUtilityObj.getAllPriceBookEntries(productIds,'PromoCode');
        eegRegUtilityObj.getSFDCPortalUserNameUsingExternalUserName(accObj.id,externalUserName);
        eegRegUtilityObj.getSFDCPortalUserUsingUserNameOrExternalUserName(null, externalUserName, '.eventSuffix.1');
        eegRegUtilityObj.getSFDCPortalUserUsingUserNameOrExternalUserName(accObj.id, externalUserName, '.eventSuffix.1');
        eegRegUtilityObj.getProductAttendeeType(eventObj.id,'PromoCode');
        eegRegUtilityObj.getAllProduct('Additional Service', 'Catering Breakfast',eventObj.id);
        eegRegUtilityObj.getRegistrationChildRecords(regObj.id,eventObj.name);
        eegRegUtilityObj.getMultipleLodgingRecords(regObj.id);
        List<Product2> ListProd = new List<Product2>();
        ListProd.add(prodObj);
        eegRegUtilityObj.createProductNameDescriptionMap(ListProd);
        eegRegUtilityObj.createProductOrderByNameMap(ListProd);
        List<SelectOption> unsortedList = new  List<SelectOption>();
        unsortedList.add(new SelectOption('','--None--'));    
        Decimal decc = 10;
        String Strrr = '3';
        Map<Decimal,String> orderOptionValueMap = new Map<Decimal,String>();
        orderOptionValueMap.put(decc, strrr);
        eegRegUtilityObj.sortSelectOptionList(unsortedList,orderOptionValueMap,true);
        eegRegUtilityObj.processPayPalPayment(regObj,pay,true);
        eegRegUtilityObj.processPayPalPaymentMultiCurrency(regObj,pay,true);
        
        eegRegUtilityObj.getEffectiveOppLineItems(PBE_OldLineItemMap,PBE_NewLineItemMap);     
        eegRegUtilityObj.getOppLineItemsForDelete(PBE_OldLineItemMap,PBE_NewLineItemMap);  
        
        Contact c = new Contact();
        c = conObj;
        
        eegRegUtilityObj.getReferralContactDetails(conObj, conObj.AccountId);
        eegRegUtilityObj.submitReferral(conObj,cr,conObj.AccountId,eventObj.id,'Web');
        
        upsert c;
        eegRegUtilityObj.submitReferral(conObj,cr,conObj.AccountId,eventObj.id,'Web');
        
        
        regObj.PromoCode_Applied__c = 'Test1234';
        update regObj;
        
        eegRegUtilityObj.processDonationCharge(optlineItems,'Producttype','100.00');
        eegRegUtilityObj.getDiscountAmountForRegAndWorkshop(100.00,110.00,10,10);
        eegRegUtilityObj.getDiscountAmountForRegAndWorkshop(100.00,110.00,10);
        
        test.stopTest();
    }
}