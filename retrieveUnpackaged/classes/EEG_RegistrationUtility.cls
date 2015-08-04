/*
        THIS CLASS HAS REUSABLE METHODS
        THE METHODS IN THIS CLASS ARE USED FOR MORE THAN ON PROGRAM
        DO NOT MAKE HERE WHICH ARE PROGRAM SPECIFIC, 
        IF YOU WANT TO MAKE PROGRAM SPECIFIC CHANGES COPY METHODS FROM HERE AND PASTE IT IN PROGRAM SPECIFIC CONTROLLERS AND MAKE REQUIRED CHANGES THERE.
*/
public without sharing class EEG_RegistrationUtility 
{
    
    /*
        1. Validation Methods Start Here
    */
    public boolean isPromocodeRequiredForRegistrationForTheAttendeeType(String eventId, String attendeeType)
    {
        if(isValidText(eventId) && isValidText(attendeeType))
        {
            List<Event_Attendee_Type_Configuration__c>  attendeeConfigList = [SELECT Id FROM Event_Attendee_Type_Configuration__c WHERE Event__c =: eventId AND Attendee_Type__c =: attendeeType AND Is_Promocode_required__c =: true limit 1];
            if(attendeeConfigList.size() != 0)
                return true;
            else
                return false;
        }
        else
        return false;
    }

    
    public boolean isPromocodeRequiredForEmailOrEmailDomain(String eventId, String email, boolean isEmailDomain)
    {
        if(isValidText(eventId) && isValidText(email))
        {
            String emailOrEmailDomain;
            if(isEmailDomain && email.contains('@') && email.split('@').size() >1)
            {
                emailOrEmailDomain = email.split('@').get(1);
            }
            else
            {
                emailOrEmailDomain = email; 
            }
            List<Event_Attendee_Type_Configuration__c>  attendeeConfigList = [SELECT Id FROM Event_Attendee_Type_Configuration__c WHERE Event__c =: eventId AND Email_Email_domain__c =: emailOrEmailDomain AND Is_Promocode_required__c =: true limit 1];
            if(attendeeConfigList.size() != 0)
                return true;
            else
                return false;
        }
        else
        return false;
    }
    
    public boolean isValidPromoCodeForTheAttendeeType(String eventId, String appliedPromocode, String attendeeType)
    {
        boolean isValid = false;
        System.debug('eventId ==> '+eventId);
        System.debug('appliedPromocode ==> '+appliedPromocode);
        System.debug('attendeeType ==> '+attendeeType);
        
        try
        {
            if (appliedPromocode == null)
            {
                appliedPromocode = '';
            }
            
            List<Product2> productList = [SELECT Id, ProductCode, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND ProductCode =: appliedPromocode.trim() and Product_Type__c =: 'PromoCode' and isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE' AND Attendee_Type__c includes (:attendeeType) AND (Product_Size__c =: null OR Product_Size__c > 0)];
            if(productList.size() != 0)
            {
                isValid = true;
            }
            else
            isValid = false;
        }
        catch(Exception e)
        {
            isValid = false;
        }
        return isValid;
        
    }
    
    public boolean isValidPromoCode(String eventId, String appliedPromocode)
    {
        boolean isValid = false;
        System.debug('eventId ==> '+eventId);
        System.debug('appliedPromocode ==> '+appliedPromocode);
        
        try
        {
            if (appliedPromocode == null)
            {
                appliedPromocode = '';
            }
            
            List<Product2> productList = [SELECT Id, ProductCode, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND ProductCode =: appliedPromocode.trim() and Product_Type__c =: 'PromoCode' and isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE' AND (Product_Size__c =: null OR Product_Size__c > 0)];
            if(productList.size() != 0)
            {
                isValid = true;
            }
            else
            isValid = false;
        }
        catch(Exception e)
        {
            isValid = false;
        }
        return isValid;
    }
    /*
        This method will validate if promo code is valid or not.
        It will check -
            a) Active Product for that event
            b) Product is present in configured price book
            c) Product size is greater than zero.
        It will return error message if any of the above condition fails, otheresise it will return null.                
    */
    public String isValidPromoCode(String eventId, String appliedPromocode,String priceBookName)
    {
        
        String errorMsg = null; 
        System.debug('eventId ==> '+eventId);
        System.debug('appliedPromocode ==> '+appliedPromocode);
        
        try
        {
            if (appliedPromocode == null)
            {
                appliedPromocode = '';
            }
            
            List<Product2> productList = [SELECT Id, ProductCode, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND ProductCode =: appliedPromocode.trim() and Product_Type__c =: 'PromoCode' and isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE' /*AND (Product_Size__c =: null OR Product_Size__c > 0)*/];
            if(productList.size() != 0)
            {
                Product2 prod = productList.get(0);
                if(prod.Product_Size__c <= 0 ){
                    errorMsg = System.Label.EEG_PromoCode_Validation_Error_Capacity_Full;
                }
                else{
                    List<PricebookEntry> pentry = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.Id AND Pricebook2.Name =: priceBookName]; 
                    if(pentry.size() == 0 ){
                        errorMsg = System.Label.EEG_PromoCode_Validation_Error_Invalid_PromoCode;
                    }
                }
            }
            else{
                errorMsg = System.Label.EEG_PromoCode_Validation_Error_Invalid_PromoCode;
            }
        }
        catch(Exception e)
        {
            errorMsg = System.Label.EEG_PromoCode_Validation_Error_Invalid_PromoCode;
        }
        return errorMsg;
    }
    public String isValidPromoCodeForAttendeeTypeConfType(String eventId, String appliedPromocode,String priceBookName,String attendeeType,String conferenceType)
    {
        
        String errorMsg = null; 
        System.debug('eventId ==> '+eventId);
        System.debug('appliedPromocode ==> '+appliedPromocode);
        
        try
        {
            if (appliedPromocode == null)
            {
                appliedPromocode = '';
            }
            List<Product2> productList = new List<Product2>();
            
            if(isValidText(attendeeType) && isValidText(conferenceType)){
                productList = [SELECT Id, ProductCode, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND ProductCode =: appliedPromocode.trim() and Product_Type__c =: 'PromoCode' and isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE' AND Attendee_Type__c includes (:attendeeType) AND Conference_Type__c includes (:conferenceType) ]; 
            }
            else if(isValidText(attendeeType))
            {
                productList = [SELECT Id, ProductCode, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND ProductCode =: appliedPromocode.trim() and Product_Type__c =: 'PromoCode' and isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE' AND Attendee_Type__c includes (:attendeeType) AND Conference_Type__c = null]; 
            }
            else if(isValidText(conferenceType)){
                productList = [SELECT Id, ProductCode, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND ProductCode =: appliedPromocode.trim() and Product_Type__c =: 'PromoCode' and isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE' AND Conference_Type__c includes (:conferenceType) AND Attendee_Type__c = null]; 
            }
            else 
            {
                productList = [SELECT Id, ProductCode, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND ProductCode =: appliedPromocode.trim() and Product_Type__c =: 'PromoCode' and isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE' /*AND (Product_Size__c =: null OR Product_Size__c > 0)*/];
            }
            if(productList.size() != 0)
            {
                Product2 prod = productList.get(0);
                if(prod.Product_Size__c <= 0 ){
                    errorMsg = System.Label.EEG_PromoCode_Validation_Error_Capacity_Full;
                }
                else{
                    List<PricebookEntry> pentry = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.Id AND Pricebook2.Name =: priceBookName]; 
                    if(pentry.size() == 0 ){
                        errorMsg = System.Label.EEG_PromoCode_Validation_Error_Invalid_PromoCode;
                    }
                }
            }
            else{
                errorMsg = System.Label.EEG_PromoCode_Validation_Error_Invalid_PromoCode;
            }
        }
        catch(Exception e)
        {
            errorMsg = System.Label.EEG_PromoCode_Validation_Error_Invalid_PromoCode;
        }
        return errorMsg;
    }
    public String isValidPromoCodeForAttendeeTypeConfTypeAttTypeSpec(String eventId, String appliedPromocode,String priceBookName,String attendeeType,String conferenceType,String attendeeTypeSpecial)
    {
        
        String errorMsg = null; 
        try
        {
            if (appliedPromocode == null)
            {
                appliedPromocode = '';
            }
            List<Product2> productList = new List<Product2>();
            
            if(isValidText(attendeeType) && isValidText(conferenceType)){
                productList = [SELECT Id, ProductCode, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND ProductCode =: appliedPromocode.trim() and Product_Type__c =: 'PromoCode' and isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE' AND Attendee_Type__c includes (:attendeeType) AND Conference_Type__c includes (:conferenceType) AND Attendee_Type_Special__c includes (:attendeeTypeSpecial)]; 
            }
            else if(isValidText(attendeeType))
            {
                productList = [SELECT Id, ProductCode, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND ProductCode =: appliedPromocode.trim() and Product_Type__c =: 'PromoCode' and isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE' AND Attendee_Type__c includes (:attendeeType) AND Conference_Type__c = null AND Attendee_Type_Special__c includes (:attendeeTypeSpecial)]; 
            }
            else if(isValidText(conferenceType)){
                productList = [SELECT Id, ProductCode, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND ProductCode =: appliedPromocode.trim() and Product_Type__c =: 'PromoCode' and isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE' AND Conference_Type__c includes (:conferenceType) AND Attendee_Type__c = null AND Attendee_Type_Special__c includes (:attendeeTypeSpecial)]; 
            }
            else 
            {
                productList = [SELECT Id, ProductCode, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND ProductCode =: appliedPromocode.trim() and Product_Type__c =: 'PromoCode' and isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE' AND Attendee_Type_Special__c includes (:attendeeTypeSpecial)/*AND (Product_Size__c =: null OR Product_Size__c > 0)*/];
            }
            if(productList.size() != 0)
            {
                Product2 prod = productList.get(0);
                if(prod.Product_Size__c <= 0 ){
                    errorMsg = System.Label.EEG_PromoCode_Validation_Error_Capacity_Full;
                }
                else{
                    List<PricebookEntry> pentry = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.Id AND Pricebook2.Name =: priceBookName]; 
                    if(pentry.size() == 0 ){
                        errorMsg = System.Label.EEG_PromoCode_Validation_Error_Invalid_PromoCode;
                    }
                }
            }
            else{
                errorMsg = System.Label.EEG_PromoCode_Validation_Error_Invalid_PromoCode;
            }
        }
        catch(Exception e)
        {
            errorMsg = System.Label.EEG_PromoCode_Validation_Error_Invalid_PromoCode;
        }
        return errorMsg;
    }
    
    /*
        Thsi method will return the Product Details of a given PromoCode.
    */
    public Product2 getPromoCodeProductDetails(String eventId, String appliedPromocode){
        System.debug('eventId ==> '+eventId);
        System.debug('appliedPromocode ==> '+appliedPromocode);
        
        if(isValidText(appliedPromocode))
        {
            List<Product2> productList = [SELECT Id, Name, ProductCode, Discount_Type__c,Product_Size_Initial__c FROM Product2 WHERE Event__c =: eventId AND ProductCode =: appliedPromocode.trim() and Product_Type__c =: 'PromoCode' and isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE' ];
            if(productList.size() != 0)
            {
                return productList.get(0);
            }
        }
       return null;
    }
 
    public Registration__c getRegistrationFromEventIdContactId(String eventId,Id contactId)
    {
        system.debug('ttttttt'+isValidText(eventId)+isValidText(contactId));
        if(isValidText(eventId) && isValidText(contactId)) 
        {            
            List<Registration__c> existingRegistrations = [Select Id,Allow_Backdoor_Registration__c,Is_Approved__c,Event__c,Status__c,Registrant__c,Registrant__r.FirstName,Registrant__r.LastName,Registrant__r.Email, Attendee_Type__c,Exhibitor_Level__c, PromoCode_Applied__c From Registration__c Where Registrant__c = :contactId AND Event__c = :eventId limit 1];
            if(existingRegistrations.size() > 0)
            return existingRegistrations[0];
        }
       return null;
    }
    
    public Registration__c getRegistrationFromEventListContactId(List<String> eventIdList,Id contactId)
    {
        if(eventIdList != null && eventIdList.size() > 0 && isValidText(contactId)) 
        {            
            List<Registration__c> existingRegistrations = [Select Id,Allow_Backdoor_Registration__c,Event__c,Status__c,Registrant__c,Attendee_Type__c,Exhibitor_Level__c From Registration__c Where Registrant__c = :contactId AND Event__c IN :eventIdList limit 1];
            if(existingRegistrations.size() > 0)
            return existingRegistrations[0];
        }
       return null;
    }
    /*
        Registrants are not allowed to register with the Email domain which is in the Email Blackout List.
        Return TRUE if it is BlackListed Otherwise returns FALSE.
    */
   
    public boolean isBlackListedEmailDomain(String eventId, String email)
    {
        if(isValidText(eventId) && isValidText(email))
        {
            email = email.deleteWhitespace();
            for(Event_Email_Black_List__c eb : [SELECT Black_List_Email_Domain__c FROM Event_Email_Black_List__c WHERE Event__c =: eventId AND Black_List_Email_Domain__c != null AND (Type__c =: null OR Type__c ='Blacklist')])
            {
                if(email.split('@') != null && email.split('@').size() >= 2){
                    String userDomain = email.split('@')[1];
                    if(userDomain != null && userDomain.toLowerCase() == eb.Black_List_Email_Domain__c.toLowerCase())
                    {
                        return true;
                    }
                }
            }
           return false;
        }
        else
        return true;
    }
    
    /*
        Registrants are allowed to register with the Email domain which is in the Email White List.
        Return TRUE if it is WhiteListed Otherwise returns FALSE.
    */
   
    public boolean isWhiteListedEmailDomain(String eventId, String email)
    {
        if(isValidText(eventId) && isValidText(email))
        {
            email = email.deleteWhitespace();
            for(Event_Email_Black_List__c eb : [SELECT Black_List_Email_Domain__c FROM Event_Email_Black_List__c WHERE Event__c =: eventId AND Black_List_Email_Domain__c != null AND (Type__c =: null OR Type__c ='Whitelist')])
            {
                if((email.toLowerCase()).contains(eb.Black_List_Email_Domain__c.toLowerCase()))
                {
                    return true;
                }
            }
           return false;
        }
        else
        return true;
    }
    
    /*
        Registrants are only allowed if their email address is available in Email Black/White List Table.
        Return TRUE if it is WhiteListed Otherwise returns FALSE.
    */
   
    public boolean isWhiteListedEmailAddress(String eventId, String email)
    {
        if(isValidText(eventId) && isValidText(email))
        {
            email = email.deleteWhitespace();
            for(Event_Email_Black_List__c eb : [SELECT Black_List_Email_Domain__c FROM Event_Email_Black_List__c WHERE Event__c =: eventId AND Black_List_Email_Domain__c =: email  AND (Type__c =: null OR Type__c ='Whitelist') limit 1])
            {
                return true;
            }
            return false;
        }
        else
        return false;
    }
    
    /*
        This method is used to check white/black listing of email address based on Attendee Type.
        Return TRUE if Attendee Type is WhiteListed and Email is not present in Event Email Black / White List.
        Return TRUE if Attendee Type is BlackListed and Email is present in Event Email Black / White List. 
        Otherwise returns FALSE
    */
    public boolean isAttendeeTypeWhiteOrBlackListed(String eventId, String attendeeType, String email)
    {
        if(isValidText(attendeeType) && isValidText(email))
        {
            for(Event_Attendee_Type_Configuration__c eatc : [SELECT Whitelist_Blacklist__c FROM Event_Attendee_Type_Configuration__c Where  Event__c =: eventId AND Attendee_Type__c =: attendeeType limit 1])
            {
                if(eatc.Whitelist_Blacklist__c == 'Whitelist')
                {
                    return !isWhiteListedEmailAddress(eventId, email);
                }
                else if(eatc.Whitelist_Blacklist__c == 'Blacklist')
                {
                    return isBlackListedEmailDomain(eventId, email);
                }
                else
                {
                    return false;
                }
            }
            return false;
        }
        else
        return false;
    }
       
    /*
        1. Validation Methods End Here
    */
    
    
    /*
        2. Registration, Login, Forgot & Change Password Methods Start Here.
    */
    //Create a new user
    public String createUser(String accountId, String email, String password, String programUserSuffix, String firstname, String lastname, String company)
    {
        System.Debug('createUser :');
        String userId = '';
        
        User u = new User();
        u.username = getUserName(email, programUserSuffix);
        u.Email = email.toLowerCase();
        u.Alias = getAlias(firstname,lastname);
        u.FirstName = firstname;
        u.LastName = lastname;
        u.CompanyName = company; 
        u.CommunityNickname=firstname + String.valueOf(Crypto.getRandomInteger());
        //It is important to create the user with Pacific Time Zone. By defaul user gets created with the Site default users time zone which is GMT which causes some issue in Scheduler & Product(payment page) display logic. 
        u.TimeZoneSidKey = 'America/Los_Angeles';
        
        /*
            1. If your Program is using more than one Customer Profile's then use a separate @future update method available in this class ("@future static void updateUser(String userId, String profileId)").
            2. Site.createPortalUser method will always use the Profile Name mentioned in the ustomer Portal settings
            
        */
        
        Contact contactToUse = getContactFromEmail(email, accountId);
        if(contactToUse != null)
        {
            u.ContactId = contactToUse.Id;
        }
        else{
            Contact createdContact = createContact(accountId,email,firstname,lastname,company);
            if(createdContact != null)
            {
                u.ContactId = createdContact.Id;
            }
        }
        System.Debug('u.ContactId : '+u.ContactId);
        
        userId = Site.createPortalUser(u, AccountId, password);
        
        System.Debug('userId ::'+userId);
        return userId;
    }
    
    //Create a new user
    public String createUserV1(String accountId, Contact con, String password, String programUserSuffix)
    {
        System.Debug('createUser :');
        String userId = '';
        system.debug('~~~~~~~~~~~~~~~~~~~~~~' + con);
        User u = new User();
        u.username = getUserName(con.Email, programUserSuffix);
        u.Email = con.Email.toLowerCase();
        u.Alias = getAlias(con.FirstName,con.LastName);
        u.FirstName = con.FirstName;
        u.LastName = con.LastName;
        //It is important to create the user with Pacific Time Zone. By defaul user gets created with the Site default users time zone which is GMT which causes some issue in Scheduler & Product(payment page) display logic. 
        u.TimeZoneSidKey = 'America/Los_Angeles';
        
        if(con.Company_Name__c != null)
        {
            u.CompanyName = con.Company_Name__c;    
        }
         
        u.CommunityNickname = con.FirstName + String.valueOf(Crypto.getRandomInteger());
        
        if(con.External_User_Name__c != null)
        {
            u.External_User_Name__c = con.External_User_Name__c;    
        }
        
        /*
            1. If your Program is using more than one Customer Profile's then use a separate @future update method available in this class ("@future static void updateUser(String userId, String profileId)").
            2. Site.createPortalUser method will always use the Profile Name mentioned in the ustomer Portal settings
            
        */
        
        Contact contactToUse = getContactFromEmail(con.Email, accountId);
        if(contactToUse != null)
        {
            u.ContactId = contactToUse.Id;
        }
        else{
            Contact createdContact = createContactV1(accountId, con);
            if(createdContact != null)
            {
                u.ContactId = createdContact.Id;
            }
        }
        System.Debug('u.ContactId : '+u.ContactId);
        
        userId = Site.createPortalUser(u, AccountId, password);
        
        System.Debug('userId ::'+userId);
        return userId;
    }
    @future static void updateUser(String userId, String profileId)
    {
        User updateuser = [SELECT Id, ProfileId FROM User WHERE Id =: userId];
        updateuser.ProfileId = profileId;
        update updateuser;
    }
    
    public Integer getNumberOfRegistrationsForCompanyName(String eventid,String companyname)
    {   
     List<Event_Attendee_Type_Configuration__c>  lstRegistrations = [Select Number_of_Registrations_Allowed__c from Event_Attendee_Type_Configuration__c where Event__c =:eventid AND Company_Name__c =: companyname];
     if(lstRegistrations.size()>0 && lstRegistrations[0].Number_of_Registrations_Allowed__c !=null)
        return Integer.valueOf(lstRegistrations[0].Number_of_Registrations_Allowed__c);
     else
        return null;    
    }
    
    public Integer getNumberOfRegistrations(String eventid,String companyname)
    {
     Integer AlreadyRegister = [Select count() from Registration__c where Event__c = :eventid AND (Status__c = 'Registered' OR Status__c = 'Attended') AND Registrant_Company_Name__c=:companyname];
     return AlreadyRegister;
    }
    
    //Calculate Days between event start date and todays date.
    public Integer getNumberOfDays(String eventId){
        Event_Header__c event = new Event_Header__c();
        date TodayDate = system.today();
        event = getEventInfo(eventId);
        if(event != null && event.Start_Date__c != null && system.today() < event.Start_Date__c)
        {
            return TodayDate.daysBetween(event.Start_Date__c);
        }
        else
        {
            return 0;
        }                                                                                                                                                                   
    }
    
    //login user
    public PageReference loginUser(String username, String password, String programUserSuffix, PageReference requestedPageRef, String successPageURL)
    {
        if(!isValidText(username))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Please_Enter_the_User_Name));
        }
        if(!isValidText(password))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Please_Enter_the_Password));
        }
        
        if(ApexPages.hasMessages())
        {
            return pageRedirect(requestedPageRef, false);
        }
        else
        {
             System.debug('successPageURL :  '+successPageURL);
             try
             {
                return Site.login(getUserName(username.trim(), programUserSuffix), password, successPageURL);
             }
             catch(Exception e)
             {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
                return null;
             }
        }
    }
    
    //Forgot Password method
    public PageReference forgotPassword(String username, String programUserSuffix, PageReference successPageReference)
    {
      if(!isValidText(username))
      {
           system.debug('****forgotPassword username: ' + username);
           system.debug('****forgotPassword programUserSuffix: ' + programUserSuffix);
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Please_Enter_the_Email_Address);
           ApexPages.addMessage(msg);
           return null;
      }
      
      String exactUserName = getUserName(username, programUserSuffix);  
      boolean success = Site.forgotPassword(exactUserName);
      
      if (success)      
      return pageRedirect(successPageReference, true);
      
      return null;
    }
    
    //Change Password Method
    public PageReference changePassword(String newPassword, String verifyNewPassword, String oldpassword)
    {
        PageReference cpPage;
        if(!isValidText(newPassword) || !isValidText(verifyNewPassword))
        {
           ApexPages.Message msgx = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Please_Fill_in_all_Values);
           ApexPages.addMessage(msgx);
           return null;
        }
        else if(newPassword != verifyNewPassword)
        {
            ApexPages.Message msgx = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.New_And_Verify_Password_should_be_the_same);
            ApexPages.addMessage(msgx);
            return null;
        }
        else
        {
           try
           {
                cpPage = Site.changePassword(newPassword, verifyNewPassword, oldpassword);
                System.Debug('cpPage '+cpPage);
                //Use the standard error message
                /*if(null == cpPage)
                {
                    ApexPages.Message msgx = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Password_is_Weak);
                    ApexPages.addMessage(msgx);
                    return null;
                }*/
           }
           catch(Exception e)
           {
                ApexPages.Message msgx = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
                ApexPages.addMessage(msgx);
                return null;
           }  
           return cpPage;
        }
    } 
    /*
        2. Registration, Login, Forgot & Change Password Methods End Here.
    */
    
    
    /*
        3. Create Registration Specific Records(Registration, Opportunities etc) Start here.
    */
    public Registration__c createRegistration(String eventId, String contactId, Registration__c reg, String ownerId, String regStatus, String regNamePrefix, String contactFirstName, String contactLastName)
    {
        /*
            Sample Parameter values.
            regNamePrefix = 'Box User' (r.Name = 'Box User' + ' - ' + firstName + ' - ' + lastName;).
            regStatus = 'Saved for Later' (r.Status__c = 'Saved for Later').  
        */
        if(reg == null)
        reg = new Registration__c();
        
        System.debug('Registration:: ==>> '+reg);
        
        reg.Name = regNamePrefix + ' - ' + contactFirstName + ' ' + contactLastName;    
        reg.Event__c = eventId;
        reg.Registrant__c = contactId;
         /*Customer portal users must own the Registration Record, so that Apex send email can use Registration Id as a "RelatedToId", 
        If the record is not owned by the person who created it then Send email with "RelatedToId" = RegistrationId will fail. */
        reg.OwnerId = ownerId;
        reg.Status__c = regStatus;
        insert reg;  
        
        return reg;  
    }
    
    public Registration__c createRegistrationV1(String eventId, Contact con, Registration__c reg, String ownerId, String regStatus, String regNamePrefix)
    {
        /*
            Sample Parameter values.
            regNamePrefix = 'Box User' (r.Name = 'Box User' + ' - ' + firstName + ' - ' + lastName;).
            regStatus = 'Saved for Later' (r.Status__c = 'Saved for Later').  
        */
        if(reg == null)
        reg = new Registration__c();
        
        System.debug('Registration:: ==>> '+reg);
        
        reg.Name = regNamePrefix + ' - ' + con.FirstName + ' ' + con.LastName;    
        reg.Event__c = eventId;
        reg.Registrant__c = con.Id;
         /*Customer portal users must own the Registration Record, so that Apex send email can use Registration Id as a "RelatedToId", 
        If the record is not owned by the person who created it then Send email with "RelatedToId" = RegistrationId will fail. */
        reg.OwnerId = ownerId;
        reg.Status__c = regStatus;
        upsert reg;  
        
        return reg;  
    }
    
    public Opportunity createOpportunity(String eventId, String accountId, String registrationId, String eventName, String currencyISOCode, String priceBookName, String contactFirstName, String contactLastName)
    {
        Opportunity opp = new Opportunity();
        String priceBookId;
        try
        {
            List<PriceBook2> priceBook = [Select Id from PriceBook2 Where Name=: priceBookName];
            if(priceBook.size() != 0)
            priceBookId = priceBook[0].Id;
            
            if(priceBookId != null)
            opp.Pricebook2Id = priceBookId;
        }
        catch(Exception e)
        {
            System.Debug('e.getmessage() '+e.getmessage());
        }
        if(currencyISOCode != null)
        opp.CurrencyIsoCode = currencyISOCode;
        
        opp.AccountId = accountId;
        opp.Registration__c = registrationId;
        opp.CloseDate = System.today() + 180 ;
        opp.Event_ID__c = eventId;
        opp.Name = eventName + ' - Registration Oppty - ' +  contactFirstName + ' ' + contactLastName;
        opp.StageName = 'Prospecting';
        opp.Type = 'Registration';
        insert opp;
        
        return opp;
    }
    
    public Opportunity createOpportunityForRegistrationGroup(String eventId, String accountId, String registrationId, String eventName, String currencyISOCode, String priceBookName, String groupName)
    {
        Opportunity opp = new Opportunity();
        String priceBookId;
        try
        {
            List<PriceBook2> priceBook = [Select Id from PriceBook2 Where Name=: priceBookName];
            if(priceBook.size() != 0)
            priceBookId = priceBook[0].Id;
            
            if(priceBookId != null)
            opp.Pricebook2Id = priceBookId;
        }
        catch(Exception e)
        {
            System.Debug('e.getmessage() '+e.getmessage());
        }
        if(currencyISOCode != null)
        opp.CurrencyIsoCode = currencyISOCode;
        
        opp.AccountId = accountId;
        opp.Registration_Group__c = registrationId;
        opp.CloseDate = System.today() + 180 ;
        opp.Event_ID__c = eventId;
        opp.Name = eventName + ' - Registration Group Oppty - ' +  groupName;
        opp.StageName = 'Prospecting';
        opp.Type = 'Registration';
        insert opp;
        
        return opp;
    }
    
    /*
      Create opportunityLine items
      Promocode and AttendeeRelationship parameters are optional.
    */
    public List<OpportunityLineItem> createOpportunityLineItems(String eventId, String priceBookname, String opptyId, String OpptyCurrencyISOCode, String PromoCodeApplied, String attendeeRelationship)
    {
      List<OpportunityLineItem> optyLineItemList = new List<OpportunityLineItem>();
      List<PricebookEntry> pricebookEntryList;
      Product2 promoCodeProduct = new Product2();
      
      if(!isValidText(OpptyCurrencyISOCode))  OpptyCurrencyISOCode = 'USD';
      
      if(isValidText(attendeeRelationship))
        pricebookEntryList = [SELECT Id, Product2.Product_Type__c, Product2.Description, Product2.Product_Size__c, UnitPrice FROM PricebookEntry WHERE CurrencyISOCode =: OpptyCurrencyISOCode AND Product2Id IN (SELECT Id FROM Product2 WHERE Event__c =: eventId AND isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE' AND( (Product_Type__c= : 'Registration' AND Attendee_Type__c includes (:attendeeRelationship)) OR (Product_Type__c= : 'PromoCode' AND ProductCode = : PromoCodeApplied AND Attendee_Type__c includes (:attendeeRelationship) AND (Product_Size__c =: null OR Product_Size__c > 0)))) AND Pricebook2.Name =: priceBookname];
        else
        pricebookEntryList = [SELECT Id, Product2.Product_Type__c, Product2.Description, Product2.Product_Size__c, UnitPrice FROM PricebookEntry WHERE CurrencyISOCode =: OpptyCurrencyISOCode AND Product2Id IN (SELECT Id FROM Product2 WHERE Event__c =: eventId AND isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE' AND( (Product_Type__c= : 'Registration') OR (Product_Type__c= : 'PromoCode' AND ProductCode = : PromoCodeApplied AND (Product_Size__c =: null OR Product_Size__c > 0)))) AND Pricebook2.Name =: priceBookname];
        
        if(pricebookEntryList != null)
        {
          for(PricebookEntry pentry : pricebookEntryList)
          {
            if(pentry.Product2.Product_Type__c == 'Registration' || pentry.Product2.Product_Type__c == 'PromoCode')
            {
              OpportunityLineItem optyLineItem = new OpportunityLineItem();
          optyLineItem.PricebookEntryId = pentry.Id;
              optyLineItem.OpportunityId = opptyId;
              optyLineItem.UnitPrice = pentry.UnitPrice;
              optyLineItem.Description = pentry.Product2.Description;
              optyLineItem.Product_Type__c = pentry.Product2.Product_Type__c;
              optyLineItem.Quantity = 1.0;
              optyLineItemList.add(optyLineItem);
              
              if(pentry.Product2.Product_Type__c == 'PromoCode')
              promoCodeProduct = pentry.Product2;
            }
          }
          
        if(optyLineItemList.size() != 0)
        {
          Database.SaveResult[] srList = Database.Insert(optyLineItemList, false);
          for(Database.SaveResult sr : srList)
          {
            if (sr.isSuccess()) 
            {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted Opportunity Line Items');
            }
            else 
            {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) 
                {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Opportunity Line Item fields that affected this error: ' + err.getFields());
                }
            }
          }
        }
        
        if(promoCodeProduct.Product_Size__c != null)
        {
          promoCodeProduct.Product_Size__c = promoCodeProduct.Product_Size__c - 1;
          Database.update(promoCodeProduct, false);
        }
        }
        
        return optyLineItemList;
    }
    /*
        3. Create Registration Specific Records(Registration, Opportunities etc) End here.
    */
    
    
    
    /*
        4. Email methods Start here.
    */
    public void sendEmail(String targetObjectId, String setWhatId, String OrgWideEmailAddressId, String emailTemplateId, List<String> ccEmailAddressList, List<String> bccEmailAddressList, boolean setSaveAsActivity)
    {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();   
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(emailTemplateId);
        email.setTargetObjectId(targetObjectId);
        
        if(setWhatId != null)
        email.setWhatId(setWhatId);
        
        if(ccEmailAddressList != null && ccEmailAddressList.size() > 0)
        email.setCcAddresses(ccEmailAddressList);
        if(bccEmailAddressList != null && bccEmailAddressList.size() > 0)
        email.setBccAddresses(bccEmailAddressList);
        email.setSaveAsActivity(setSaveAsActivity);
        
        email.setOrgWideEmailAddressId(OrgWideEmailAddressId);  
        emailList.add(email);
        //Do not send email if this method is called by a test class.
        if(!Test.isRunningTest())
        Messaging.sendEmail(emailList);
    }
    public void sendEmailWithAttachment(String targetObjectId, String setWhatId, String OrgWideEmailAddressId, String emailTemplateId, List<String> ccEmailAddressList, List<String> bccEmailAddressList, boolean setSaveAsActivity,Blob attachment,String fileName)
    {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();   
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(emailTemplateId);
        email.setTargetObjectId(targetObjectId);
        
        if(setWhatId != null)
        email.setWhatId(setWhatId);
        
        if(ccEmailAddressList != null && ccEmailAddressList.size() > 0)
        email.setCcAddresses(ccEmailAddressList);
        if(bccEmailAddressList != null && bccEmailAddressList.size() > 0)
        email.setBccAddresses(bccEmailAddressList);
        email.setSaveAsActivity(setSaveAsActivity);
        
        email.setOrgWideEmailAddressId(OrgWideEmailAddressId); 
        
        // Create the email attachment
        Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
        fileAttachment.setFileName(fileName);
        fileAttachment.setBody(attachment);
        
        fileAttachment.setInline(false);
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {fileAttachment});
         
        emailList.add(email);
        //Do not send email if this method is called by a test class.
        if(!Test.isRunningTest())
        Messaging.sendEmail(emailList);
    }
    public string getEmailTemplateId(String emailTemplateDevName)
    {
        List<EmailTemplate> etList = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: emailTemplateDevName AND ISActive =: true limit 1];
        
        if(etList.size() > 0)
        {
            return etList.get(0).Id;
        }else
        {
            return null;
        }
    }
    
    /*
        4. Email methods End here.
    */
    
    
    /*
        5. Misc methods Start here.
    */
    
    /*
        Method Name: getUserName
        Input:  john.smith@gmail.com
        Output: john.smith@gmail.com.programSuffix (Example: john.smith@gmail.com.box, john.smith@gmail.com.AU etc..)
    */
    public String getUserName(String userNameInput, String programUserSuffix)
    {
        String usernameOutput;
        if(isValidtext(userNameInput) && isValidtext(programUserSuffix))
        {
            userNameInput = userNameInput.trim();
            programUserSuffix = programUserSuffix.trim();
            
            if(userNameInput.toLowerCase().endsWith(programUserSuffix.toLowerCase()))
            usernameOutput = userNameInput;
            else
            usernameOutput = userNameInput+programUserSuffix;
        } 
        
        return usernameOutput;
        
    }
    
    /*
        Method Name: removeSiteSuffix
        Input:  john.smith@gmail.com.programSuffix (Example: john.smith@gmail.com.box, john.smith@gmail.com.AU etc..)
        Output: john.smith@gmail.com 
    */
    public String removeSiteSuffix(String userNameInput, String programUserSuffix)
    {
        String usernameOutput;
        if(isvalidtext(userNameInput) && isvalidtext(programUserSuffix))
        {
            userNameInput = userNameInput.deleteWhitespace();
            if(userNameInput.toLowerCase().endsWith(programUserSuffix.toLowerCase()))
            usernameOutput = userNameInput.removeEndIgnoreCase(programUserSuffix);
            else
            usernameOutput = userNameInput;
        } 
        
        return usernameOutput;
        
    }
    
    /*
        Return If it is a valid Text
    */
    public boolean isValidText(String fieldValue)
    {
        if(fieldValue == null || fieldValue.trim().equals('')) 
            return false;
    
        return true;
    }
    
    public String getAlias(String fname, String lname)
    {
        String al = '';
        
        if(isValidtext(fname))
        al = fname.substring(0,1);
         
        String lal = lname.length()< 3 ? lname : lname.substring(0,3);
        al = al + lal;
    
        return al;  
    }
    
    public Contact getContactFromEmail(String email, String accountId)
    {
        if(email != null && email != '') 
        {   
            Contact con = new Contact();
            email = email.toLowerCase();
            
            List<Contact> existingContacts = [SELECT Email,Id,firstname,lastname,Company_Name__c,External_User_Name__c FROM Contact where Email = : email and AccountId=: accountId limit 1];
            if(existingContacts.size() > 0)
            {
                con = existingContacts[0];
                return con;
            }                   
        }
        return null;
    }
    
    public Contact getContactFromId(String id, String accountId)
    {
        if(id != null && id != '') 
        {   
            Contact con = new Contact();
            
            List<Contact> existingContacts = [SELECT Email,Id,firstname,lastname,Company_Name__c,External_User_Name__c,OwnerId FROM Contact where Id = : id and AccountId=: accountId limit 1];
            if(existingContacts.size() > 0)
            {
                con = existingContacts[0];
                return con;
            }                   
        }
        return null;
    }
  
    public List<Contact> getContactsFromEmailList(List<String> emailList, String accountId)
    {
        if(emailList != null && emailList.size() > 0 && isValidText(accountId) ) 
        {   
            return [SELECT Email,Id,firstname,lastname,Phone,Company_Name__c FROM Contact where Email IN : emailList AND AccountId=: accountId ];
        }
        return new List<Contact>();
    }
    
    public String getProfileId(String profileName)
    {
        String profileId;
        System.Debug('profileName =>> '+profileName);
        
        if(profileName != null && profileName != '')
        {
            List<Profile> profileList = [SELECT Id FROM Profile WHERE Name =: profileName];
            if(profileList.size() != 0)
            profileId = profileList.get(0).Id;
        }
        return profileId;
    }
    
    public String getPortalUserContactId(String userId)
    {
        List<User> us = [Select Id,ContactId from User where Id =: userId LIMIT 1];
        if(us.size() > 0 && us[0].ContactId != null)
        {
            return us[0].ContactId;
        }
        else
            return null;    
    }
    
    public Account getPortalUserAccount(String userId)
    {
        List<Contact> conts = [SELECT Id,Account.Id, Account.OwnerId From Contact where Id = : getPortalUserContactId(userId)];
        
        if(conts.size()>0 && conts[0].Account != null)
            return conts[0].Account;
        else
            return null;    
    }
    
    public Account getContactAccount(String contactId)
    {
        List<Contact> conts = [SELECT Id,Account.Id, Account.OwnerId From Contact where Id = : contactId];
        
        if(conts.size()>0 && conts[0].Account != null)
            return conts[0].Account;
        else
            return null;    
    }
    
    public boolean isExistingUser(String userName)
    {
        if(isValidText(userName)) 
        {   
            List<User> existingUsers = [SELECT Id FROM User WHERE UserName = : userName limit 1];
            if(existingUsers.size() > 0)
            return true;
            else
            return false;                   
        }
        return false;
    }
    
    public Event_Header__c getEventInfo(String eventId)
    {
        List<Event_Header__c> eventList = [ SELECT Id, Name, Event_Name__c, Event_Code__c, CurrencyIsoCode,Session_Enabled__c, Start_Date__c, End_Date__c, Is_Registration_Closed__c,Registration_End_Date_Time__c,Is_Hotel_Dates_are_Locked__c,Is_Air_Request_Dates_are_Locked__c,
                                                    Src_Open_Date__c,Erc_Open_Date__c,Cfp_Open_Date__c,Cfp_Close_Date__c,Cfp_ReadOnly_Date__c,Src_ReadOnly_Date__c,Maximum_Abstracts_Allowed__c,Attachment_Allowed_File_Types__c,Is_Black_White_List_Enabled__c,
                                                    Process_Payment_Using_Paypal__c,ERC_Close_Date__c,Use_Currency_Specific_Paypal_Credentials__c,Captcha_Type__c,Default_Checkin_Date__c,Default_Check_Out_Date__c,Registration_Start_Date_Time__c,Src_Close_Date__c,
                                                    Partner_System_User_Name__c,Partner_System_Password__c,Execute_Black_White_List_Validation__c,Process_Credit_Refund_Using_Paypal__c,SessionControllerClassName__c,
                                                    Account__c, Ignore_Meeting_participant_conflicts__c 
                                            From Event_Header__c where Id = : eventId];
        
        if(eventList.size() >0)
            return eventList[0];
        else
            return null;    
    }
    
    public String getCurrencySymbol(String currencyCode)
    {
      Map<String, String> CurrencyCode_Symbol_MAP = new Map<String, String> 
                                                                    { 
                                                                     'USD' => '$',
                                                                     'EUR' => '€',
                                                                     'AUD' => 'A$',
                                                                     'GBP' => '£'
                                                                    };
      if(currencyCode != null && CurrencyCode_Symbol_MAP.get(currencyCode) != null)
      return CurrencyCode_Symbol_MAP.get(currencyCode);
      else
      return '$';                                                               
    }
    
    public PageReference pageRedirect(PageReference pg, boolean setRedirect)
    {
        if(pg != null)
        {
            pg.setRedirect(setRedirect);
            return pg;
        }
        else
        return null;
    }
    
    public boolean rerenderPaymentCreditcard(String methodOfPayment)
    {
        if(methodOfPayment == null || methodOfPayment == System.Label.Contact_me_for_payment)
        return false;
        else
        return true;
    }
    
    public opportunityLineItemWrapperclass getOpportunityLineItems(String registrationId)
    {
        opportunityLineItemWrapperclass optyLineItemWrapper = new opportunityLineItemWrapperclass();
        optyLineItemWrapper.totalAmount = 0;
        optyLineItemWrapper.isAmountDue = false;
        optyLineItemWrapper.showWorkshopSection = false;
        optyLineItemWrapper.showPromocodeSection = false;
        
        List<OpportunityLineItem> OpportunityLineItemList = new List<OpportunityLineItem>();
        List<Opportunity> opptys = [SELECT Id, (Select Id, Product_Type__c, UnitPrice, Description from OpportunityLineItems) FROM Opportunity WHERE Registration__c = : registrationId];
        if(opptys.size()>0)
        {
            if(opptys[0].OpportunityLineItems != null && opptys[0].OpportunityLineItems.size() != 0)
            {
                for(OpportunityLineItem opli : opptys[0].OpportunityLineItems)
                {
                    if(opli.Product_Type__c == 'Registration')
                    {
                        optyLineItemWrapper.totalAmount += opli.UnitPrice;
                        optyLineItemWrapper.registrationAmount = opli.UnitPrice;
                        optyLineItemWrapper.registrationDescription = opli.Description;
                    }
                    else if(opli.Product_Type__c == 'Workshop')
                    {
                        optyLineItemWrapper.totalAmount += opli.UnitPrice;
                        optyLineItemWrapper.workshopAmount = opli.UnitPrice;
                        optyLineItemWrapper.workshopDescription = opli.Description;
                        
                        optyLineItemWrapper.showWorkshopSection = true;
                    }
                    else if(opli.Product_Type__c == 'PromoCode')
                    {
                        optyLineItemWrapper.totalAmount -= opli.UnitPrice;
                        optyLineItemWrapper.promocodeAmount = opli.UnitPrice;
                        optyLineItemWrapper.promocodeDescription = opli.Description;
                        
                        optyLineItemWrapper.showPromocodeSection = true;
                    }
                }
                
                if(optyLineItemWrapper.totalAmount > 0)
                optyLineItemWrapper.isAmountDue = true;
            }
        }
        
        return optyLineItemWrapper;
   }
   /*
    Supporting class for "getOpportunityLineItems" method.
   */
   public class opportunityLineItemWrapperclass
   {
        public String registrationDescription {get;set;}
        public Decimal registrationAmount {get;set;}
        
        public String workshopDescription {get;set;}
        public Decimal workshopAmount {get;set;}
        
        public String promocodeDescription {get;set;}
        public Decimal promocodeAmount {get;set;}
        
        public Decimal totalAmount {get;set;}
        public boolean isAmountDue {get;set;}
        
        public boolean showWorkshopSection {get;set;}
        public boolean showPromocodeSection {get;set;}
   }
    /*
        5. Misc methods End here.
    */
    
    /*  
        Simple Encoding Method.
        This methods can be used to encode Salesforce Id's in Unauthenticated Page URL's. Call this method from PageRedirect method.
    */
    public String encode(String input)
    {
        if(isValidText(input))
        return EncodingUtil.base64Encode(Blob.valueOf(input));
        return null;
    }
    
    /*  
        Simple Decoding Method.
        This methods can be used to decode Salesforce Id's in Unauthenticated Page URL's. Call this method from Page onload.
    */
    public String decode(String input)
    {
        if(isValidText(input))
        {
            Blob urlDecode = EncodingUtil.base64Decode(input);
            return urlDecode.toString();
        }
        return null;
    }
    
     /* 6. get amount to be processed via PayPal */
    
    public Decimal getCalculatedAmount(Payment__c pay)
    {
        Decimal totalDebitAmount = 0;
        Decimal totalCreditAmount = 0;
        Decimal totalAmounttobeCharged = 0;
        Decimal totalAmountCharged;// = 0;
        
        system.debug('~~~~~~~~~~~~pay:' + pay);
        if(pay != null ) 
        {   
            
            if(pay.Id <> null)
            {
                Payment__c paymentObj = [Select id, Amount__c,Amount_Charged__c From Payment__c p WHERE id =: pay.Id limit 1];  
                system.debug('myamount: ' + paymentObj.Amount__c + 'paymentObj.Amount_Charged__c: ' + paymentObj.Amount_Charged__c);
                system.debug('~~~~~~~~~~~~paymentObj:' + paymentObj);
                totalAmountCharged = paymentObj.Amount_Charged__c;
            }
            if(totalAmountCharged <> null)
            {
                totalAmounttobeCharged = pay.Amount__c - totalAmountCharged;    
            }
            else
            {
                totalAmounttobeCharged = pay.Amount__c;
            }
        }
        system.debug('my_grandtotal: ' + totalAmounttobeCharged);
        return totalAmounttobeCharged;
    }
     /* 6. get amount to be processed via PayPal using  Amount__c/ConversionRate__c OR pay.Amount_Due_in_USD__c.*/
    
    public Decimal getCalculatedAmountMultiCurrency(Payment__c pay)
    {
        Decimal totalDebitAmount = 0;
        Decimal totalCreditAmount = 0;
        Decimal totalAmounttobeCharged = 0;
        Decimal totalAmountCharged;// = 0;
        Payment__c paymentObj;
        Decimal AmountDueinUSD;
        List<Payment__c> pmtObjList = new List<Payment__c>(); 
        if(pay != null ) 
        {   
            System.debug('pay.Id  ===>>> '+pay.Id);
            if(pay.Id <> null)
            {
                paymentObj = [Select id, Amount__c,Amount_Charged__c,Amount_Due_in_USD__c,ConversionRate__c From Payment__c p WHERE id =: pay.Id limit 1];  
                totalAmountCharged = paymentObj.Amount_Charged__c;
                AmountDueinUSD = paymentObj.Amount_Due_in_USD__c;
            }
            else{
                System.debug('pay.CurrencyIsoCode  ===>>> '+pay.CurrencyIsoCode);
                //Logic to calculate conversion rate:
                if(pay.CurrencyIsoCode == 'USD')
                    pay.ConversionRate__c = 1.0;
                else{
                    List<CurrencyType> ct = [Select IsoCode,ConversionRate From CurrencyType Where IsActive = true AND IsoCode=:pay.CurrencyIsoCode];
                    if(ct.size()>0)
                        pay.ConversionRate__c = ct[0].ConversionRate;
                }
                IF((pay.Amount__c != null && pay.Amount__c!=0) && (pay.ConversionRate__c != null && pay.ConversionRate__c != 0))
                AmountDueinUSD = round(pay.Amount__c/pay.ConversionRate__c); //round this number(2 decimal points)
                else
                AmountDueinUSD = pay.Amount__c;
            }
            
            
            
            if(totalAmountCharged <> null)
            {
                totalAmounttobeCharged = round((paymentObj.Amount__c - totalAmountCharged)/paymentObj.ConversionRate__c); //round this number(2 decimal points)  
            }
            else
            {
                totalAmounttobeCharged = AmountDueinUSD;
            }
        }
        return totalAmounttobeCharged;
    }

 // process online paypal transaction
 public EEG_PaypalProcessorWebservice.TransactionOutputDetails paypalPalProcessOnline(Payment__c payment, boolean refundCredit)
 {
    //boolean isOk = true;
    EEG_PaypalProcessorWebservice.TransactionInputDetails transactionInputDetails = new EEG_PaypalProcessorWebservice.TransactionInputDetails();
    transactionInputDetails.paymentRecordId = payment.Id;
    transactionInputDetails.paymentRecord = payment;
    transactionInputDetails.amount = getCalculatedAmount(payment);
    
    //This method does charge Amounts in Different Currencies, Populate the CurrencyISOCode that is used to charge.
    if(isValidtext(payment.CurrencyIsoCode)) 
    transactionInputDetails.currencyIsoCode = payment.CurrencyIsoCode;
        
    system.debug('paymentid:'+ payment.Id + ' transactionInputDetails.amount:' + transactionInputDetails.amount);
    if(transactionInputDetails.amount > 0)
    {
        transactionInputDetails.description = '';
        transactionInputDetails.transactionType = 'Debit-Charge';
        
        EEG_EventPaymentProcessor paymentProcessor = new EEG_EventPaymentProcessor(); 
        EEG_PaypalProcessorWebservice.TransactionOutputDetails  transactionOutputDetails = paymentProcessor.doDirectPayment(transactionInputDetails);
        
        return  transactionOutputDetails;
    }
    else if(transactionInputDetails.amount < 0 && refundCredit)
    {
        transactionInputDetails.description = '';
        transactionInputDetails.transactionType = 'Credit-Refund';
        transactionInputDetails.amount = (-transactionInputDetails.amount);
        
        List<Paypal_Transaction_History__c> parentTransactions = getParentTransactions(payment);
        if(parentTransactions.size() == 1)
        {
            transactionInputDetails.parentTransactionId = parentTransactions.get(0).Id; 
        }
        else
        {
            return null;        
        }
        
        
        EEG_EventPaymentProcessor paymentProcessor = new EEG_EventPaymentProcessor(); 
        EEG_PaypalProcessorWebservice.TransactionOutputDetails  transactionOutputDetails = paymentProcessor.doDirectPayment(transactionInputDetails);
        
        return  transactionOutputDetails;

    }
    //system.debug('isOk: ' + isOk);
    //return isOk;
    return null;
}   

public List<Paypal_Transaction_History__c> getParentTransactions(Payment__c payment)
{
    if(payment != null && payment.Id != null)
    {
        return [SELECT Id FROM Paypal_Transaction_History__c WHERE Payment__c = :payment.Id AND Transaction_Type__c = 'Debit-Charge' AND Transaction_Id__c != null AND Transaction_Result__c = 'Approved'];
    }
    return new List<Paypal_Transaction_History__c>();
}

// process online paypalMultiCurrency transaction using  Amount__c/ConversionRate__c OR pay.Amount_Due_in_USD__c.
 public EEG_PaypalProcessorWebservice.TransactionOutputDetails paypalPalProcessOnlineMultiCurrency(Payment__c payment, boolean refundCredit)
 {
    //boolean isOk = true;
    EEG_PaypalProcessorWebservice.TransactionInputDetails transactionInputDetails = new EEG_PaypalProcessorWebservice.TransactionInputDetails();
    transactionInputDetails.paymentRecordId = payment.Id;
    transactionInputDetails.paymentRecord = payment;
    transactionInputDetails.amount = getCalculatedAmountMultiCurrency(payment);
    
    //This method does charge Amounts in USD always(using conversion rate). 
    transactionInputDetails.currencyIsoCode = 'USD';
        
    system.debug('paymentid:'+ payment.Id + ' transactionInputDetails.amount:' + transactionInputDetails.amount);
    if(transactionInputDetails.amount > 0)
    {
        transactionInputDetails.description = '';
        transactionInputDetails.transactionType = 'Debit-Charge';
        
        EEG_EventPaymentProcessor paymentProcessor = new EEG_EventPaymentProcessor(); 
        EEG_PaypalProcessorWebservice.TransactionOutputDetails  transactionOutputDetails = paymentProcessor.doDirectPayment(transactionInputDetails);
        
        return  transactionOutputDetails;
    }
    else if(transactionInputDetails.amount < 0 && refundCredit)
    {
        transactionInputDetails.description = '';
        transactionInputDetails.transactionType = 'Credit-Refund';
        transactionInputDetails.amount = (-transactionInputDetails.amount);
        
        List<Paypal_Transaction_History__c> parentTransactions = getParentTransactions(payment);
        if(parentTransactions.size() == 1)
        {
            transactionInputDetails.parentTransactionId = parentTransactions.get(0).Id; 
        }
        else
        {
            return null;        
        }
        
        EEG_EventPaymentProcessor paymentProcessor = new EEG_EventPaymentProcessor(); 
        EEG_PaypalProcessorWebservice.TransactionOutputDetails  transactionOutputDetails = paymentProcessor.doDirectPayment(transactionInputDetails);
        
        return  transactionOutputDetails;

    }
    return null;
}

public boolean isPaymentProcessed(EEG_PaypalProcessorWebservice.TransactionOutputDetails transactionOutputDetails)
{
    boolean isOk = true;
    if(isvalidText(transactionOutputDetails.VALIDATION_ERROR_MESSAGE)) //Process validation Error Messages.
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, transactionOutputDetails.VALIDATION_ERROR_MESSAGE));
        system.debug('transactionOutputDetails.VALIDATION_ERROR_MESSAGE message: ' + transactionOutputDetails.VALIDATION_ERROR_MESSAGE);
        isOk = false;
        //return false;
    }
    
    else if(isvalidText(transactionOutputDetails.PAYPAL_TRANSACTIONREJECTED_EXTERNALUSER_ERRORMESSAGE)) //Process System and Paypal Error Messages.
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, transactionOutputDetails.PAYPAL_TRANSACTIONREJECTED_EXTERNALUSER_ERRORMESSAGE));
        system.debug('transactionOutputDetails.PAYPAL_TRANSACTIONREJECTED_EXTERNALUSER_ERRORMESSAGE ' + transactionOutputDetails.PAYPAL_TRANSACTIONREJECTED_EXTERNALUSER_ERRORMESSAGE);
       isOk = false;
       //return false;
    }
    system.debug('isOk: ' + isOk);
    return isOk;
}
public void createPaypalTransactionHistory(Registration__c regRecord,Payment__c payment,EEG_PaypalProcessorWebservice.TransactionOutputDetails transactionOutputDetails)
{
    try{
        Registration__c reg = [Select   id,Registrant__r.FirstName,Registrant__r.LastName,Event__r.Name,Event__r.Event_Name__c,Registrant__c
                                            From Registration__c Where id = :regRecord.Id limit 1];
        Paypal_Transaction_History__c paypalTransaction = new Paypal_Transaction_History__c();
        paypalTransaction.Payment__c = payment.Id;
        paypalTransaction.Amount_Processed__c = payment.Amount__c;//getCalculatedAmount(payment);
        paypalTransaction.Transaction_Id__c = transactionOutputDetails.TRANSACTIONID;
        paypalTransaction.Transaction_Result__c = transactionOutputDetails.RESPMSG;
        paypalTransaction.Paypal_Raw_Response__c = transactionOutputDetails.RAWRESPONSE;
        
        //This method does charge Amounts in Different Currencies, Populate the CurrencyISOCode that is used to charge.
        if(isValidtext(payment.CurrencyIsoCode)) 
        paypalTransaction.CurrencyIsoCode = payment.CurrencyIsoCode;
        
        paypalTransaction.Transaction_Type__c = 'Debit-Charge';
        
        //comment1 is used to capture Event Details
        paypalTransaction.Comment_1__c = reg.Event__r.Name + ' - ' + reg.Event__r.Event_Name__c;
        //comment2 is used to capture Who(EEG User) submitted for Who(Registrant-Contact)
        paypalTransaction.Comment_2__c = 'Submitted For Registrant: '+ reg.Registrant__r.FirstName + ' ' + reg.Registrant__r.LastName + ' (' +reg.Registrant__c+') and Submitted by: '+UserInfo.getUserName()+ ' ('+UserInfo.getUserId() + ').';
        //description is used to capture the Payment reason (Registration fee, Workshop fee, etc..)
        paypalTransaction.Description__c = '';
        
        if(payment.Card_Number_Encrypted__c != null && payment.Card_Number_Encrypted__c.length() >=4)
        paypalTransaction.Credit_Card_Number_Last_Four_Digits__c = payment.Card_Number_Encrypted__c.substring(payment.Card_Number_Encrypted__c.length()-4);
        paypalTransaction.System_Error__c = transactionOutputDetails.SYSTEMERROR;
        
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.allowFieldTruncation = true;
        paypalTransaction.setOptions(dmlOptions);
        insert paypalTransaction;
    }
    catch(Exception e)
    {
        system.debug('Exception while creating Paypal Transaction History record  ' + e.getMessage() );
    }
    
}

/**
    METHOD NAME :   createPaypalTransactionHistorytMultiCurrency
    This reusable method is used to create Paypal transaction Histry using  Amount__c/ConversionRate__c OR pay.Amount_Due_in_USD__c.
 */
public void createPaypalTransactionHistorytMultiCurrency(Registration__c regRecord,Payment__c payment,EEG_PaypalProcessorWebservice.TransactionOutputDetails transactionOutputDetails)
{
    try{
        Registration__c reg = [Select   id,Registrant__r.FirstName,Registrant__r.LastName,Event__r.Name,Event__r.Event_Name__c,Registrant__c
                                            From Registration__c Where id = :regRecord.Id limit 1];
        
        Decimal amountCharged = 0;
        if(payment.Id <> null)
        {
            Payment__c paymentObj = [Select id, Amount__c,Amount_Charged__c,Amount_Due_in_USD__c From Payment__c p WHERE id =: payment.Id limit 1];
            amountCharged = paymentObj.Amount_Due_in_USD__c;
        }
        else
        amountCharged = payment.Amount__c;
        
        Paypal_Transaction_History__c paypalTransaction = new Paypal_Transaction_History__c();
        paypalTransaction.Payment__c = payment.Id;
        paypalTransaction.Amount_Processed__c = amountCharged;
        paypalTransaction.Transaction_Id__c = transactionOutputDetails.TRANSACTIONID;
        paypalTransaction.Transaction_Result__c = transactionOutputDetails.RESPMSG;
        paypalTransaction.Paypal_Raw_Response__c = transactionOutputDetails.RAWRESPONSE;
        
        //This method does charge Amounts in USD always(using conversion rate). 
        paypalTransaction.CurrencyIsoCode = 'USD';
        
        paypalTransaction.Transaction_Type__c = 'Debit-Charge';
        
        //comment1 is used to capture Event Details
        paypalTransaction.Comment_1__c = reg.Event__r.Name + ' - ' + reg.Event__r.Event_Name__c;
        //comment2 is used to capture Who(EEG User) submitted for Who(Registrant-Contact)
        paypalTransaction.Comment_2__c = 'Submitted For Registrant: '+ reg.Registrant__r.FirstName + ' ' + reg.Registrant__r.LastName + ' (' +reg.Registrant__c+') and Submitted by: '+UserInfo.getUserName()+ ' ('+UserInfo.getUserId() + ').';
        //description is used to capture the Payment reason (Registration fee, Workshop fee, etc..)
        paypalTransaction.Description__c = '';
        
        if(payment.Card_Number_Encrypted__c != null && payment.Card_Number_Encrypted__c.length() >=4)
        paypalTransaction.Credit_Card_Number_Last_Four_Digits__c = payment.Card_Number_Encrypted__c.substring(payment.Card_Number_Encrypted__c.length()-4);
        paypalTransaction.System_Error__c = transactionOutputDetails.SYSTEMERROR;
        
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.allowFieldTruncation = true;
        paypalTransaction.setOptions(dmlOptions);
        insert paypalTransaction;
    }
    catch(Exception e)
    {
        
    }
    
}
    
    public SelectOption[] getSelectOptions(List<String> optionList) 
    {   
        SelectOption[] options = new SelectOption[]{};
        
        options.add(new SelectOption('', '--None--'));
        
        if(optionList <> null){
            for (String optionVal : optionList) 
            {
                options.add(new SelectOption(optionVal, optionVal));
            }   
        }
        
        return options;   
    }
    
    public List<String> getCheckInDatesFromAttendeeType(String eventId, String attendeeType){
        List<String> checkIndates; 
        try{
            Event_Attendee_Type_Configuration__c attendeeConfig = [ Select Available_Check_In_Date__c 
                                                                    From Event_Attendee_Type_Configuration__c 
                                                                    Where Event__c = :eventId
                                                                    AND Attendee_Type__c = :attendeeType
                                                                    limit 1];
            if(attendeeConfig <> null){
                checkIndates = new List<String>();
                if(attendeeConfig.Available_Check_In_Date__c <> null){
                    checkIndates = attendeeConfig.Available_Check_In_Date__c.split(';');
                }
            }   
        }catch(Exception e){
            
        }
        
        return checkIndates;
    }
    /*
        This method is used to create contact. This method will map custom fields such as Company.
    */
    public Contact createContact(String accountId, String email,String firstname, String lastname, String company){
        Contact con = new Contact();
        con.FirstName = firstname;
        con.LastName = lastname;
        con.AccountId = accountId;
        con.Email = email;
        con.Company_Name__c = company;
        try{
            insert con;
            return con;
        }catch(Exception e){
            
        }
        return null;
        
    }
    public Contact createContactV1(String accountId, Contact con){
        if(con == null)
        {
            con = new Contact();    
        }
        con.AccountId = accountId;
        
        try{
            upsert con;
            return con;
        }catch(Exception e){
            
        }
        return null;
        
    }
    
    /*
        Methid Name: insertRegistrationErrorLog
        Comments: Generic method to log "Registration Specific Errors.
    */
    public void insertRegistrationErrorLog(String regId, String error)
    {
        if(regId != null)
        {
            EEG_Partner_Sync_Error_Log__c syncErrorLog = new EEG_Partner_Sync_Error_Log__c();
            //Truncate excessive amount of value before insert.
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.allowFieldTruncation = true;
            
            syncErrorLog.Registration__c = regId;
            syncErrorLog.Error__c = error;
            syncErrorLog.setOptions(dml);
            Database.Insert(syncErrorLog, false);
        }
    }
    
    /*
        Methid Name: insertEventErrorLog
        Comments: Generic method to log "Event Specific Errors.
    */
    public void insertEventErrorLog(String eventId, String error,String Type)
    {
        if(eventId != null)
        {
            EEG_Partner_Sync_Error_Log__c syncErrorLog = new EEG_Partner_Sync_Error_Log__c();
            //Truncate excessive amount of value before insert.
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.allowFieldTruncation = true;
            
            syncErrorLog.Event__c = eventId;
            syncErrorLog.Error__c = error;
            if(Type !=null)
                syncErrorLog.Type__c = Type;
            syncErrorLog.setOptions(dml);
            Database.Insert(syncErrorLog, false);
        }
    }
    /*
        Methid Name: insertSessionErrorLog
        Comments: Generic method to log Errors.
    */
    public void insertSessionErrorLog(String eventId, String regId, String sessOccId, String error,String Type)
    {
        if(eventId != null || regId != null || sessOccId != null)
        {
            EEG_Partner_Sync_Error_Log__c syncErrorLog = new EEG_Partner_Sync_Error_Log__c();
            //Truncate excessive amount of value before insert.
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.allowFieldTruncation = true;
            
            syncErrorLog.Event__c = eventId;
            syncErrorLog.Registration__c = regId;
            syncErrorLog.Session_Occurrence__c = sessOccId;
            syncErrorLog.Error__c = error;
            if(Type !=null)
                syncErrorLog.Type__c = Type;
            syncErrorLog.setOptions(dml);
            Database.Insert(syncErrorLog, false);
        }
    }
    /*
        METHOD NAME: redirectToLandingPage
        COMMENTS:    If the user is already Logged in, then take the users directly to the Landing page instead of Login Page.
                     If User hasn't Logged in then Site Unathenticate profile is used to render the page.
                     Userinfo.getUserType() = 'Guest' for Site Unauthenticated user.
    */
    public Pagereference redirectToLandingPage(PageReference requestedLoginPage, PageReference desiredLandingPage)
    {
        PageReference pg;
        
        //Make sure, Logged in user is not a Site Unauthenticated user by checking Userinfo.getUserType() != 'Guest'.
        if(Userinfo.getUserType() <> 'Guest' && Userinfo.getUserType() <> 'Standard' && Apexpages.currentPage() != null && Apexpages.currentPage().getUrl() != null && requestedLoginPage != null && desiredLandingPage != null)
        {
            //If the below condition is not satisfied then the user will stay on the requested page(pageRedirect will not redirect the page).
            if(Apexpages.currentPage().getUrl().containsIgnoreCase( (requestedLoginPage).getUrl() ))
            {
                pg = desiredLandingPage;    
            }
        }
        return pageRedirect(pg, true);
    }
   /*
        Reusable Methods for Creating Opportunity and LineItems.
        These methods should be called while submitting registration. 
   */ 
   
   //This is a Wrapper class used to store Opportunity LineItems & it's order of display..
   public class OppLineItem implements Comparable
   {
        public String productName{get;set;}
        public Decimal listPrice {get;set;}
        public OpportunityLineItem opLine{get;set;}
        public String productType{get;set;}
        public Integer sortOrder {get;set;}
        
        
        public OppLineItem(OpportunityLineItem opLineObj)
        {
            this.opLine = opLineObj;
            this.productName =opLineObj.Description;
            this.listPrice = opLineObj.UnitPrice;
            this.productType = opLineObj.Product_Type__c;
            
            
            if(opLineObj.Product_Type__c == 'Registration')
            {
                this.sortOrder = 1;
            }
            else if(opLineObj.Product_Type__c == 'Workshop')
            {
                this.sortOrder = 2;
            }
            else if(opLineObj.Product_Type__c == 'Guest Event')
            {
                this.sortOrder = 3;
            }
            else if(opLineObj.Product_Type__c == 'Hotel')
            {
                this.sortOrder = 4;
            }
            else if(opLineObj.Product_Type__c == 'Additional Service')
            {
                this.sortOrder = 5;
            }
            else if(opLineObj.Product_Type__c == 'Activity')
            {
                this.sortOrder = 6;
            }
            
            else if(opLineObj.Product_Type__c == 'Booth')
            {
                this.sortOrder = 7;
            }
            else if(opLineObj.Product_Type__c == 'Event Sponsorship')
            {
                this.sortOrder = 8;
            }
            else if(opLineObj.Product_Type__c == 'Additional Event Sponsorship')
            {
                this.sortOrder = 9;
            }
             else if(opLineObj.Product_Type__c == 'Staff Registration Fee')
            {
                this.sortOrder = 10;
            }
            else if(opLineObj.Product_Type__c == 'Rental Fee')
            {
                this.sortOrder = 11;
            }
            else if(opLineObj.Product_Type__c == 'PromoCode')
            {
                this.sortOrder = 12;
            }
            
        }
        
        public Integer compareTo(Object o2)
        {
            if(sortOrder < ((OppLineItem)o2).sortOrder)
            {
                return -1;
            }
            else if(sortOrder > ((OppLineItem)o2).sortOrder)
            {
                return 1;
            }
            else
            {
                if(productName != null && ((OppLineItem)o2).productName != null)
                {
                    return productName.compareTo(((OppLineItem)o2).productName);    
                }
                else
                {
                    return -1;
                }
            }
        }
    }
    
    /*
        This method will return Product name when passed promocode along with Event Id and Attendee Type. 
    */
    /*public String getProductNameFromPromoCode(String eventId,String attendeeType,String promocode)
    {
        List<Product2>  lstProducts =   [Select Name FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE'
                                        AND ( Product_Type__c=  'PromoCode' 
                                        AND ProductCode = :promocode 
                                        AND Attendee_Type__c includes (:attendeeType) 
                                        AND (Product_Size__c = null OR Product_Size__c > 0)
                                        )];
        if(lstProducts.size() > 0)
        {
            return lstProducts.get(0).Name;
        }
        else
        {
            return null;
        }                                       
    }*/
    /*
        Pass List of OpportunityLineItems to this method. It will store it in Database. 
    */
    public void upsertOpportunityLineItems(Opportunity opp,List<OpportunityLineItem> optyLineItemList)
    {
        /*
            Opportunity Line Items will be updated if atleast one of the line items are updated(Except Registration & promocode because we dont allow/want People to change these items once Registration is completed & people should be able to retain the earlybird/discount etc... amount).
        */
        boolean isUpsertNeeded = false;
        if(optyLineItemList.size() != 0)
        {
            for(OpportunityLineItem oppLine: optyLineItemList)
            {
                if(oppLine.OpportunityId == null)
                {
                    system.debug('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<eegreg');
                    isUpsertNeeded = true;
                    oppLine.OpportunityId = opp.Id; 
                }
            }
            if(isUpsertNeeded)
            {
                //Database.upsert(optyLineItemList, false);
                Database.UpsertResult[] urList = Database.upsert(optyLineItemList, false);
                system.debug('<<<<urList'+urList);
            }
        }
    }
    
    /*
        Method used to return existing Opp LineItems in Map<Product,OppLineItem> format 
    */
    public Map<String,OpportunityLineItem>  getExisitingOppLineItem(String oppId)
    {
        return createMapOfLineItem(getExisitingOppLineItem(oppId,null));
    }
    
    /*
        This method will return existing Opp LineItems for passed product Type
    */
    public List<OpportunityLineItem> getExisitingOppLineItem(String oppId,String productType)
    {
        List<OpportunityLineItem> existingOptlineItemRecords;
        if(productType == null)
        {
            existingOptlineItemRecords = [Select Id,OpportunityId,PricebookEntry.Product2.Description,Product_Type__c,PricebookEntry.Product2.Name, 
                                                                UnitPrice,ListPrice,TotalPrice,Description,PricebookEntry.Product2Id,Quantity,Status__c,Promo_Code__c,
                                                                PricebookEntry.Product2.Conference_Type__c
                                                                From OpportunityLineItem 
                                                                Where OpportunityId =: oppId 
                                                                ];  
        }
        else
        {
            existingOptlineItemRecords = [Select Id,OpportunityId,PricebookEntry.Product2.Description,Product_Type__c,PricebookEntry.Product2.Name, 
                                                                UnitPrice,ListPrice,TotalPrice,Description,PricebookEntry.Product2Id,Quantity,Status__c,Promo_Code__c,
                                                                PricebookEntry.Product2.Conference_Type__c
                                                                From OpportunityLineItem 
                                                                Where OpportunityId =: oppId 
                                                                AND (Product_Type__c=: productType)];
        }
        return existingOptlineItemRecords;
    }
    
    /*
        This method creates Opp LineItem records without saving them to DB.
        
        This will be deprecated once it is no longer used by any programs. Please use the updated v2
        of this method in future programs, as it requires an additional parameter.
    */
     public List<OpportunityLineItem> createOpportunityLineItemList(String eventId,String priceBookName,String attendeeType,List<String> productsInput,String productType)
    {
        List<OpportunityLineItem> optyLineItemList = new List<OpportunityLineItem>();
        Product2 promoCodeProduct = new Product2();
        List<String> products = new List<String>();
         
        /*
            "products" List can have Promocode Product Name/Code, Guest Product, Work shop Product, etc.. (anything Except Registration Product).
            Remove Null values from "productsInput" List to avoid Products with NULL Promocodes being returned by SOQL query.
        */
        if(productsInput != null)
        {
            for(String prod : productsInput)
            {
                //It is important to check Null Values.
                if(isValidText(prod))
                products.add(prod);
            }
        }
        System.debug('productType ===>>> '+productType);
        
        Set<Id> pIds = new Set<Id>();
        //If the Product type is Promocode then make sure it is either Unlimited or Size > 0 before adding it to the query.
        if(productType == 'PromoCode' && products.size() != 0)
        {
            List<Product2> prodList = new List<Product2>();
            //The below query will be executed If a Promocode is available for certain Attendee types only. 
            if(isValidText(attendeeType))
            {
                prodList = [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND ( Product_Type__c=  'PromoCode' AND (Name IN :products OR ProductCode IN :products) AND Attendee_Type__c includes (:attendeeType) AND (Product_Size__c = null OR Product_Size__c > 0))];
            }
            else //The below query will be executed If a Promocode is available for All Attendee types. 
            {
                prodList = [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE'AND ( Product_Type__c=  'PromoCode' AND (Name IN :products OR ProductCode IN :products) AND (Product_Size__c = null OR Product_Size__c > 0))]; 
            }
            
            for(Product2 prd : prodList)
            {
                pIds.add(prd.Id);
            }
        }
        else //Query Registrtion, Workshop, Guest, etc....(anything Except Promocode Product).
        {
            if(isValidText(attendeeType)){
                for(Product2 prd : [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND Attendee_Type__c includes (:attendeeType)
                                    AND Product_Type__c= :productType])
                {
                    pIds.add(prd.Id);
                    
                }
            } else {
                for(Product2 prd : [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE'
                                    AND Product_Type__c= :productType])
                {
                    pIds.add(prd.Id);
                    
                }
            }
        }
        
        System.debug('pIds.size() ===>>> '+pIds.size());
        
        List<PricebookEntry> pentryList = new List<PricebookEntry>();
        if(pIds.size() != 0)
        {
            //Two different queries are used to avoid Products with NULL Promocodes being returned by SOQL query.
            //"products" List can have Promocode Product Name/Code, Guest Product, Work shop Product, etc.. (anything Except Registration Product).
            if(products.size() != 0)
            {
                pentryList = [SELECT Id, Product2.Name, Product2.Product_Type__c, Product2.Description, UnitPrice,Product2.ProductCode FROM PricebookEntry WHERE Product2Id IN : pIds AND Pricebook2.Name =: priceBookName AND (Product2.Product_Type__c = 'Registration' OR Product2.Name IN :products OR Product2.ProductCode IN :products)];
            }
            else
            {
                pentryList = [SELECT Id, Product2.Name, Product2.Product_Type__c, Product2.Description, UnitPrice,Product2.ProductCode FROM PricebookEntry WHERE Product2Id IN : pIds AND Pricebook2.Name =: priceBookName AND (Product2.Product_Type__c = 'Registration')];
            }
        }
        
        System.debug('pentryList.size() ===>>> '+pentryList.size());
        
        for(PricebookEntry pentry : pentryList)
        {
            OpportunityLineItem optyLineItem = new OpportunityLineItem();
            optyLineItem.PricebookEntryId = pentry.Id;
            //optyLineItem.OpportunityId = opp.id;
            optyLineItem.UnitPrice = pentry.UnitPrice;
            optyLineItem.Description = pentry.Product2.Description;
            optyLineItem.Product_Type__c = pentry.Product2.Product_Type__c;
            optyLineItem.Quantity = 1.0;
            optyLineItem.Promo_Code__c = pentry.Product2.ProductCode;
            optyLineItemList.add(optyLineItem);
        }
        return optyLineItemList;
    }
    
    /*
        This method creates Opp LineItem records without saving them to DB.
        
        Version 2: Also requires conferenceType as a parameter.
    */
    public List<OpportunityLineItem> createOpportunityLineItemListV2(String eventId,String priceBookName,String attendeeType,String conferenceType,List<String> productsInput,String productType)
    {
        List<OpportunityLineItem> optyLineItemList = new List<OpportunityLineItem>();
        Product2 promoCodeProduct = new Product2();
        List<String> products = new List<String>();
         
        /*
            "products" List can have Promocode Product Name/Code, Guest Product, Work shop Product, etc.. (anything Except Registration Product).
            Remove Null values from "productsInput" List to avoid Products with NULL Promocodes being returned by SOQL query.
        */
        if(productsInput != null)
        {
            for(String prod : productsInput)
            {
                //It is important to check Null Values.
                if(isValidText(prod))
                products.add(prod);
            }
        }
        System.debug('productType ===>>> '+productType);
        
        Set<Id> pIds = new Set<Id>();
        //If the Product type is Promocode then make sure it is either Unlimited or Size > 0 before adding it to the query.
        if(productType == 'PromoCode' && products.size() != 0)
        {
            List<Product2> prodList = new List<Product2>();
            //The below query will be executed If a Promocode is available for certain Attendee types only. 
            if(isValidText(attendeeType) && isValidText(conferenceType)){
                prodList = [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND ( Product_Type__c=  'PromoCode' AND (Name IN :products OR ProductCode IN :products) AND Attendee_Type__c includes (:attendeeType) AND Conference_Type__c includes (:conferenceType) AND (Product_Size__c = null OR Product_Size__c > 0))];
            }
            else if(isValidText(attendeeType))
            {
                prodList = [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND ( Product_Type__c=  'PromoCode' AND (Name IN :products OR ProductCode IN :products) AND Attendee_Type__c includes (:attendeeType) AND Conference_Type__c = null AND (Product_Size__c = null OR Product_Size__c > 0))];
            }
            else if(isValidText(conferenceType)){
                prodList = [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND ( Product_Type__c=  'PromoCode' AND (Name IN :products OR ProductCode IN :products) AND Conference_Type__c includes (:conferenceType) AND Attendee_Type__c = null AND (Product_Size__c = null OR Product_Size__c > 0))];
            }
            else //The below query will be executed If a Promocode is available for All Attendee types. 
            {
                prodList = [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE'AND ( Product_Type__c=  'PromoCode' AND (Name IN :products OR ProductCode IN :products) AND (Product_Size__c = null OR Product_Size__c > 0))]; 
            }
            
            for(Product2 prd : prodList)
            {
                pIds.add(prd.Id);
            }
        }
        else //Query Registrtion, Workshop, Guest, etc....(anything Except Promocode Product).
        {
            if(isValidText(attendeeType) && isValidText(conferenceType)){
                for(Product2 prd : [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND Attendee_Type__c includes (:attendeeType) AND Conference_Type__c includes (:conferenceType)
                                    AND Product_Type__c= :productType])
                {
                    pIds.add(prd.Id);
                    
                }
            }
            else if(isValidText(attendeeType)){
                for(Product2 prd : [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND Attendee_Type__c includes (:attendeeType) AND Conference_Type__c = null
                                    AND Product_Type__c= :productType])
                {
                    pIds.add(prd.Id);
                    
                }
            }
            else if(isValidText(conferenceType)){
                for(Product2 prd : [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND Conference_Type__c includes (:conferenceType) and Attendee_Type__c = null
                                    AND Product_Type__c= :productType])
                {
                    pIds.add(prd.Id);
                    
                }
            }
            else {
                for(Product2 prd : [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE'
                                    AND Product_Type__c= :productType])
                {
                    pIds.add(prd.Id);
                    
                }
            }
        }
        
        System.debug('pIds.size() ===>>> '+pIds.size());
        
        List<PricebookEntry> pentryList = new List<PricebookEntry>();
        if(pIds.size() != 0)
        {
            //Two different queries are used to avoid Products with NULL Promocodes being returned by SOQL query.
            //"products" List can have Promocode Product Name/Code, Guest Product, Work shop Product, etc.. (anything Except Registration Product).
            if(products.size() != 0)
            {
                pentryList = [SELECT Id, Product2.Name, Product2.Product_Type__c, Product2.Description, UnitPrice,Product2.ProductCode FROM PricebookEntry WHERE Product2Id IN : pIds AND Pricebook2.Name =: priceBookName AND (Product2.Product_Type__c = 'Registration' OR Product2.Name IN :products OR Product2.ProductCode IN :products)];
            }
            else
            {
                pentryList = [SELECT Id, Product2.Name, Product2.Product_Type__c, Product2.Description, UnitPrice,Product2.ProductCode FROM PricebookEntry WHERE Product2Id IN : pIds AND Pricebook2.Name =: priceBookName AND (Product2.Product_Type__c = 'Registration')];
            }
        }
        
        System.debug('pentryList.size() ===>>> '+pentryList.size());
        
        for(PricebookEntry pentry : pentryList)
        {
            OpportunityLineItem optyLineItem = new OpportunityLineItem();
            optyLineItem.PricebookEntryId = pentry.Id;
            //optyLineItem.OpportunityId = opp.id;
            optyLineItem.UnitPrice = pentry.UnitPrice;
            optyLineItem.Description = pentry.Product2.Description;
            optyLineItem.Product_Type__c = pentry.Product2.Product_Type__c;
            optyLineItem.Quantity = 1.0;
            optyLineItem.Promo_Code__c = pentry.Product2.ProductCode;
            optyLineItemList.add(optyLineItem);
        }
        return optyLineItemList;
    }
    /*
        This method creates Opp LineItem records without saving them to DB.
        
        Version 3: Also requires currency code as a parameter.
    */
    public List<OpportunityLineItem> createOpportunityLineItemListV3(String eventId,String priceBookName,String attendeeType,String conferenceType,List<String> productsInput,String productType,String currencyIsoCode)
    {
        List<OpportunityLineItem> optyLineItemList = new List<OpportunityLineItem>();
        Product2 promoCodeProduct = new Product2();
        List<String> products = new List<String>();
         
        /*
            "products" List can have Promocode Product Name/Code, Guest Product, Work shop Product, etc.. (anything Except Registration Product).
            Remove Null values from "productsInput" List to avoid Products with NULL Promocodes being returned by SOQL query.
        */
        if(productsInput != null)
        {
            for(String prod : productsInput)
            {
                //It is important to check Null Values.
                if(isValidText(prod))
                products.add(prod);
            }
        }
        System.debug('productType ===>>> '+productType);
        
        Set<Id> pIds = new Set<Id>();
        
        //Default Currency ISO Code is USD if input ISO code is null.
        if(!isValidText(currencyIsoCode))  currencyIsoCode = 'USD';
        
        //If the Product type is Promocode then make sure it is either Unlimited or Size > 0 before adding it to the query.
        if(productType == 'PromoCode' && products.size() != 0)
        {
            List<Product2> prodList = new List<Product2>();
            //The below query will be executed If a Promocode is available for certain Attendee types only. 
            if(isValidText(attendeeType) && isValidText(conferenceType)){
                prodList = [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND ( Product_Type__c=  'PromoCode' AND (Name IN :products OR ProductCode IN :products) AND Attendee_Type__c includes (:attendeeType) AND Conference_Type__c includes (:conferenceType) AND (Product_Size__c = null OR Product_Size__c > 0))];
            }
            else if(isValidText(attendeeType))
            {
                prodList = [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND ( Product_Type__c=  'PromoCode' AND (Name IN :products OR ProductCode IN :products) AND Attendee_Type__c includes (:attendeeType) AND Conference_Type__c = null AND (Product_Size__c = null OR Product_Size__c > 0))];
            }
            else if(isValidText(conferenceType)){
                prodList = [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND ( Product_Type__c=  'PromoCode' AND (Name IN :products OR ProductCode IN :products) AND Conference_Type__c includes (:conferenceType) AND Attendee_Type__c = null AND (Product_Size__c = null OR Product_Size__c > 0))];
            }
            else //The below query will be executed If a Promocode is available for All Attendee types. 
            {
                prodList = [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE'AND ( Product_Type__c=  'PromoCode' AND (Name IN :products OR ProductCode IN :products) AND (Product_Size__c = null OR Product_Size__c > 0))]; 
            }
            
            for(Product2 prd : prodList)
            {
                pIds.add(prd.Id);
            }
        }
        else //Query Registrtion, Workshop, Guest, etc....(anything Except Promocode Product).
        {
            if(isValidText(attendeeType) && isValidText(conferenceType)){
                for(Product2 prd : [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND Attendee_Type__c includes (:attendeeType) AND Conference_Type__c includes (:conferenceType)
                                    AND Product_Type__c= :productType])
                {
                    pIds.add(prd.Id);
                    
                }
            }
            else if(isValidText(attendeeType)){
                for(Product2 prd : [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND Attendee_Type__c includes (:attendeeType) AND Conference_Type__c = null
                                    AND Product_Type__c= :productType])
                {
                    pIds.add(prd.Id);
                    
                }
            }
            else if(isValidText(conferenceType)){
                for(Product2 prd : [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND Conference_Type__c includes (:conferenceType) and Attendee_Type__c = null
                                    AND Product_Type__c= :productType])
                {
                    pIds.add(prd.Id);
                    
                }
            }
            else {
                for(Product2 prd : [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE'
                                    AND Product_Type__c= :productType])
                {
                    pIds.add(prd.Id);
                    
                }
            }
        }
        
        System.debug('pIds.size() ===>>> '+pIds.size());
        
        List<PricebookEntry> pentryList = new List<PricebookEntry>();
        if(pIds.size() != 0)
        {
            //Two different queries are used to avoid Products with NULL Promocodes being returned by SOQL query.
            //"products" List can have Promocode Product Name/Code, Guest Product, Work shop Product, etc.. (anything Except Registration Product).
            
            if(products.size() != 0)
            {                
                pentryList = [SELECT Id, Product2.Name, Product2.Product_Type__c, Product2.Description, UnitPrice,Product2.ProductCode FROM PricebookEntry WHERE Product2Id IN : pIds AND Pricebook2.Name =: priceBookName AND (Product2.Product_Type__c = 'Registration' OR Product2.Name IN :products OR Product2.ProductCode IN :products) AND CurrencyIsoCode=:currencyIsoCode];                
            }
            else
            {
                pentryList = [SELECT Id, Product2.Name, Product2.Product_Type__c, Product2.Description, UnitPrice,Product2.ProductCode FROM PricebookEntry WHERE Product2Id IN : pIds AND Pricebook2.Name =: priceBookName AND (Product2.Product_Type__c = 'Registration') AND CurrencyIsoCode=:currencyIsoCode];
            }
        }
        
        System.debug('pentryList.size() ===>>> '+pentryList.size());
        
        for(PricebookEntry pentry : pentryList)
        {
            OpportunityLineItem optyLineItem = new OpportunityLineItem();
            optyLineItem.PricebookEntryId = pentry.Id;
            //optyLineItem.OpportunityId = opp.id;
            optyLineItem.UnitPrice = pentry.UnitPrice;
            optyLineItem.Description = pentry.Product2.Description;
            optyLineItem.Product_Type__c = pentry.Product2.Product_Type__c;
            optyLineItem.Quantity = 1.0;
            optyLineItem.Promo_Code__c = pentry.Product2.ProductCode;
            optyLineItemList.add(optyLineItem);
        }
        return optyLineItemList;
    }
    /*
        This method creates Opp LineItem records without saving them to DB.
        
        Version 4: Also requires Attendee Type Special as a parameter.
    */
    public List<OpportunityLineItem> createOpportunityLineItemListV4(String eventId,String priceBookName,String attendeeType,String conferenceType,List<String> productsInput,String productType,String currencyIsoCode,String attendeeTypeSpecial)
    {
        List<OpportunityLineItem> optyLineItemList = new List<OpportunityLineItem>();
        Product2 promoCodeProduct = new Product2();
        List<String> products = new List<String>();
         
        /*
            "products" List can have Promocode Product Name/Code, Guest Product, Work shop Product, etc.. (anything Except Registration Product).
            Remove Null values from "productsInput" List to avoid Products with NULL Promocodes being returned by SOQL query.
        */
        if(productsInput != null)
        {
            for(String prod : productsInput)
            {
                //It is important to check Null Values.
                if(isValidText(prod))
                products.add(prod);
            }
        }
        System.debug('productType ===>>> '+productType);
        
        Set<Id> pIds = new Set<Id>();
        
        //Default Currency ISO Code is USD if input ISO code is null.
        if(!isValidText(currencyIsoCode))  currencyIsoCode = 'USD';
        
        //If the Product type is Promocode then make sure it is either Unlimited or Size > 0 before adding it to the query.
        if(productType == 'PromoCode' && products.size() != 0)
        {
            List<Product2> prodList = new List<Product2>();
            //The below query will be executed If a Promocode is available for certain Attendee types only. 
            if(isValidText(attendeeType) && isValidText(conferenceType)){
                prodList = [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND ( Product_Type__c=  'PromoCode' AND (Name IN :products OR ProductCode IN :products) AND Attendee_Type__c includes (:attendeeType) AND Conference_Type__c includes (:conferenceType) AND Attendee_Type_Special__c includes (:attendeeTypeSpecial) AND (Product_Size__c = null OR Product_Size__c > 0))];
            }
            else if(isValidText(attendeeType))
            {
                prodList = [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND ( Product_Type__c=  'PromoCode' AND (Name IN :products OR ProductCode IN :products) AND Attendee_Type__c includes (:attendeeType) AND Conference_Type__c = null AND Attendee_Type_Special__c includes (:attendeeTypeSpecial) AND (Product_Size__c = null OR Product_Size__c > 0))];
            }
            else if(isValidText(conferenceType)){
                prodList = [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND ( Product_Type__c=  'PromoCode' AND (Name IN :products OR ProductCode IN :products) AND Conference_Type__c includes (:conferenceType) AND Attendee_Type__c = null AND Attendee_Type_Special__c includes (:attendeeTypeSpecial) AND (Product_Size__c = null OR Product_Size__c > 0))];
            }
            else //The below query will be executed If a Promocode is available for All Attendee types. 
            {
                prodList = [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE'AND ( Product_Type__c=  'PromoCode' AND (Name IN :products OR ProductCode IN :products) AND Attendee_Type_Special__c includes (:attendeeTypeSpecial) AND (Product_Size__c = null OR Product_Size__c > 0))]; 
            }
            
            for(Product2 prd : prodList)
            {
                pIds.add(prd.Id);
            }
        }
        else //Query Registrtion, Workshop, Guest, etc....(anything Except Promocode Product).
        {
            if(isValidText(attendeeType) && isValidText(conferenceType)){
                for(Product2 prd : [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND Attendee_Type__c includes (:attendeeType) AND Conference_Type__c includes (:conferenceType)
                                    AND Product_Type__c= :productType AND Attendee_Type_Special__c includes (:attendeeTypeSpecial)])
                {
                    pIds.add(prd.Id);
                    
                }
            }
            else if(isValidText(attendeeType)){
                for(Product2 prd : [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND Attendee_Type__c includes (:attendeeType) AND Conference_Type__c = null
                                    AND Product_Type__c= :productType AND Attendee_Type_Special__c includes (:attendeeTypeSpecial)])
                {
                    pIds.add(prd.Id);
                    
                }
            }
            else if(isValidText(conferenceType)){
                for(Product2 prd : [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND Conference_Type__c includes (:conferenceType) and Attendee_Type__c = null
                                    AND Product_Type__c= :productType AND Attendee_Type_Special__c includes (:attendeeTypeSpecial)])
                {
                    pIds.add(prd.Id);
                    
                }
            }
            else {
                for(Product2 prd : [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE'
                                    AND Product_Type__c= :productType AND Attendee_Type_Special__c includes (:attendeeTypeSpecial)])
                {
                    pIds.add(prd.Id);
                    
                }
            }
        }
        
        System.debug('pIds.size() ===>>> '+pIds.size());
        
        List<PricebookEntry> pentryList = new List<PricebookEntry>();
        if(pIds.size() != 0)
        {
            //Two different queries are used to avoid Products with NULL Promocodes being returned by SOQL query.
            //"products" List can have Promocode Product Name/Code, Guest Product, Work shop Product, etc.. (anything Except Registration Product).
            if(products.size() != 0)
            {
                pentryList = [SELECT Id, Product2.Name, Product2.Product_Type__c, Product2.Description, UnitPrice,Product2.ProductCode FROM PricebookEntry WHERE Product2Id IN : pIds AND Pricebook2.Name =: priceBookName AND (Product2.Product_Type__c = 'Registration' OR Product2.Name IN :products OR Product2.ProductCode IN :products) AND CurrencyIsoCode=:currencyIsoCode];
            }
            else
            {
                pentryList = [SELECT Id, Product2.Name, Product2.Product_Type__c, Product2.Description, UnitPrice,Product2.ProductCode FROM PricebookEntry WHERE Product2Id IN : pIds AND Pricebook2.Name =: priceBookName AND (Product2.Product_Type__c = 'Registration') AND CurrencyIsoCode=:currencyIsoCode];
            }
        }
        
        System.debug('pentryList.size() ===>>> '+pentryList.size());
        
        for(PricebookEntry pentry : pentryList)
        {
            OpportunityLineItem optyLineItem = new OpportunityLineItem();
            optyLineItem.PricebookEntryId = pentry.Id;
            //optyLineItem.OpportunityId = opp.id;
            optyLineItem.UnitPrice = pentry.UnitPrice;
            optyLineItem.Description = pentry.Product2.Description;
            optyLineItem.Product_Type__c = pentry.Product2.Product_Type__c;
            optyLineItem.Quantity = 1.0;
            optyLineItem.Promo_Code__c = pentry.Product2.ProductCode;
            optyLineItemList.add(optyLineItem);
        }
        return optyLineItemList;
    }   
   
    
    /*
        This method creates Opp LineItem records without saving them to DB for Guest records.
    */
     public List<OpportunityLineItem> createOpportunityLineItemListForGuest(String eventId,String priceBookName,String attendeeType,List<String> productsInput,String productType,Decimal age)
    {
        List<OpportunityLineItem> optyLineItemList = new List<OpportunityLineItem>();
        Product2 promoCodeProduct = new Product2();
        List<String> products = new List<String>();
         
        /*
            "products" List can have Promocode Product Name/Code, Guest Product, Work shop Product, etc.. (anything Except Registration Product).
            Remove Null values from "productsInput" List to avoid Products with NULL Promocodes being returned by SOQL query.
        */
        if(productsInput != null)
        {
            for(String prod : productsInput)
            {
                //It is important to check Null Values.
                if(isValidText(prod))
                products.add(prod);
            }
        }
        
        Set<Id> pIds = new Set<Id>();
        //If the Product type is Promocode then make sure it is either Unlimited or Size > 0 before adding it to the query.
        if(productType == 'PromoCode' && products.size() != 0)
        {
            List<Product2> prodList = new List<Product2>();
            //The below query will be executed If a Promocode is available for certain Attendee types only. 
            if(isValidText(attendeeType))
            {
                prodList = [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND ( Product_Type__c=  'PromoCode' AND (Name IN :products OR ProductCode IN :products) AND Attendee_Type__c includes (:attendeeType) AND (Product_Size__c = null OR Product_Size__c > 0))];
            }
            else //The below query will be executed If a Promocode is available for All Attendee types. 
            {
                prodList = [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND ( Product_Type__c=  'PromoCode' AND (Name IN :products OR ProductCode IN :products) AND (Product_Size__c = null OR Product_Size__c > 0))];    
            }
            
            for(Product2 prd : prodList)
            {
                pIds.add(prd.Id);
            }
        }
        else //Query Registrtion, Workshop, Guest, etc....(anything Except Promocode Product).
        {
            for(Product2 prd : [Select Id, Product_Type__c, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE'
                                AND Product_Type__c= :productType 
                                AND (Child_Start_Age__c = null OR Child_Start_Age__c <= :age)
                                AND (Child_End_Age__c = null OR Child_End_Age__c >= :age)])
            {
                
                pIds.add(prd.Id);
                
            }
        }
        
        List<PricebookEntry> pentryList = new List<PricebookEntry>();
        if(pIds.size() != 0)
        {
            //Two different queries are used to avoid Products with NULL Promocodes being returned by SOQL query.
            //"products" List can have Promocode Product Name/Code, Guest Product, Work shop Product, etc.. (anything Except Registration Product).
            if(products.size() != 0)
            {
                pentryList = [SELECT Id, Product2.Name, Product2.Product_Type__c, Product2.Description, UnitPrice,Product2.ProductCode FROM PricebookEntry WHERE Product2Id IN : pIds AND Pricebook2.Name =: priceBookName AND (Product2.Product_Type__c = 'Registration' OR Product2.Name IN :products OR Product2.ProductCode IN :products)];
                
            }
            else
            {
                pentryList = [SELECT Id, Product2.Name, Product2.Product_Type__c, Product2.Description, UnitPrice,Product2.ProductCode FROM PricebookEntry WHERE Product2Id IN : pIds AND Pricebook2.Name =: priceBookName AND (Product2.Product_Type__c = 'Registration')];
            }
        }
        
        for(PricebookEntry pentry : pentryList)
        {
            OpportunityLineItem optyLineItem = new OpportunityLineItem();
            optyLineItem.PricebookEntryId = pentry.Id;
            //optyLineItem.OpportunityId = opp.id;
            optyLineItem.UnitPrice = pentry.UnitPrice;
            optyLineItem.Description = pentry.Product2.Description;
            optyLineItem.Product_Type__c = pentry.Product2.Product_Type__c;
            optyLineItem.Quantity = 1.0;
            optyLineItem.Promo_Code__c = pentry.Product2.ProductCode;
            optyLineItemList.add(optyLineItem);
        }
        return optyLineItemList;
    }
    /*
        This method will create Map<Product,OppLineItem> when passed List<OppLineItem>
    */
    public Map<String,OpportunityLineItem> createMapOfLineItem(List<OpportunityLineItem> oppLineItems)
    {
        Map<String,OpportunityLineItem> productOppLineItem = new Map<String,OpportunityLineItem>(); 
        if(oppLineItems.size() > 0)
        {
            for(OpportunityLineItem oppLIObj : oppLineItems)
            {
                if(oppLIObj.PricebookEntryId != null)
                productOppLineItem.put(oppLIObj.PricebookEntryId,oppLIObj); 
            }
        }
        return productOppLineItem;
    }
    
    /*
        Pass two arguments to this method of Map<String,OpportunityLineItem> format.
        First argument is map of OppLineItems in DB
        Second argument is map of new applicable OppLineItems.
    */
    public List<OpportunityLineItem> getEffectiveOppLineItems(Map<String,OpportunityLineItem> oldMap ,Map<String,OpportunityLineItem> newMap)
    {
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        Set<String> setOfPromoCodes = new Set<String>();
        if(oldMap.size() > 0)
        {
            /*
                From Old Opportunity Line items, Only retain the following Items,
                1. Registration & Promocode (Because Promocode size can be 0 for returning users, we still want to display the Promocode discount in the Invoice page(s)).
                2. Any Items that are remain unchanged(Items that are available in Both Old & new Map).
                
                From New Opportunity Line items, Add Items that are newly added (we already added any Items that are remain unchanged(Items that are available in Both Old & new Map)).
            */
            for(OpportunityLineItem oppLIObj : oldMap.values())
            {
                //1. Registration & Promocode (Because Promocode size can be 0 for returning users, we still want to display the Promocode discount in the Invoice page(s)).
                if(oppLIObj.Product_Type__c == 'PromoCode')
                    setOfPromoCodes.add(oppLIObj.Promo_Code__c);
                
                if(oppLIObj.Product_Type__c == 'Registration' || oppLIObj.Product_Type__c == 'PromoCode')
                {
                    oppLineItems.add(oppLIObj);
                    continue;
                }
                //2. Any Items that are remain unchanged(Items that are available in Both Old 7 new Map).
                if(newMap.containskey(oppLIObj.PricebookEntryId))
                {
                    oppLineItems.add(oppLIObj);
                }
                
            }
        }
        if(newMap.size() > 0)
        {
            for(OpportunityLineItem oppLIObj : newMap.values())
            {
                //rom New Opportunity Line items, Add Items that are newly added (we already added any Items that are remain unchanged(Items that are available in Both Old & new Map)).
                if(!oldMap.containskey(oppLIObj.PricebookEntryId))
                {
                    //If opportunity line already created for promocode then skip this..
                    if(oppLIObj.Product_Type__c == 'PromoCode'  && setOfPromoCodes.contains(oppLIObj.Promo_Code__c) )
                        continue;
                    else
                    oppLineItems.add(oppLIObj);
                    
                }
            }   
        }
        
        return  oppLineItems;
    }
    
    /*
        This method will return List of OppLineItems which should be deleted.
        We don't delete registration & promocode Line Items (because we dont allow/want People to change these items once Registration is completed & people should be able to retain the earlybird/discount etc... amount).
    */
    public List<OpportunityLineItem> getOppLineItemsForDelete(Map<String,OpportunityLineItem> oldMap ,Map<String,OpportunityLineItem> newMap)
    {
        List<OpportunityLineItem> deleteOppLIList = new List<OpportunityLineItem>();
        if(oldMap.size() > 0)
        {
            for(OpportunityLineItem oppLIObj : oldMap.values())
            {
                //We don't delete registration & promocode Line Items (because we dont allow/want People to change these items once Registration is completed & people should be able to retain the earlybird/discount etc... amount).
                if(oppLIObj.Product_Type__c == 'Registration' || oppLIObj.Product_Type__c == 'PromoCode')
                {
                    continue;
                }
                if(oppLIObj.PricebookEntryId != null && !newMap.containskey(oppLIObj.PricebookEntryId))
                    deleteOppLIList.add(oppLIObj);
            }
        }
        return  deleteOppLIList;
    }
    
    public List<OppLineItem> getProducts(List<OpportunityLineItem> oppLineItemList)
    {
        List<OppLineItem> optlineItems = new List<OppLineItem>();
        if(oppLineItemList != null && oppLineItemList.size() > 0)
        {
            for(OpportunityLineItem oppLIObj : oppLineItemList)
            {
                optlineItems.add(new EEG_RegistrationUtility.OppLineItem(oppLIObj));
            }
            optlineItems.sort();    
        }
        return optlineItems;
    }
    
    /*
        This method will Calculate the Sum of Opportunity Line items Based on Product Type.
    */
    public Decimal getTotalAmount(List<OppLineItem> oppLineItemList)
    {
        Decimal totalamount = 0.0;
        for(OppLineItem oppLIObj : oppLineItemList)
        {
            if(oppLIObj.productType == 'Registration' || oppLIObj.productType == 'Workshop' || oppLIObj.productType == 'Guest Event')
            {
                totalamount += oppLIObj.listPrice;
            }
            else if(oppLIObj.productType == 'PromoCode')
            {
                totalamount -= oppLIObj.listPrice;
            }
            else //Ipdatethis else logic if the "Amount" shouldn't be added for a given Product Type in the future.
            {
                totalamount += oppLIObj.listPrice;
            }
        }
        return totalamount;
    }
    
    // This method will return List of all Registration Invite records for passed registration Id
    public List<Registration_Invite__c> getAllRegistrationInvites(String regId)
    {
        return [Select Message__c,Last_Name__c,First_Name__c,Email__c From Registration_Invite__c Where Registration__c = :regId];
    }
    
    /*
        This method will Clear the Guest fields on Registration Object if "Are you bringing Guest?" Changes from "Yes" to "No".
    */
    public Registration__c clearGusetValues(Registration__c reg)
    {
        if(reg <> null)
        {
            reg.Guest_Event__c = null;
            reg.Guest_Salutation_Picklist__c = null;
            reg.Guest_First_Name__c = null;
            reg.Guest_Last_Name__c = null;
            reg.Guest_Meal_Request__c = null;
            return reg;
        }
        return reg;
    }
    
    /*
        This method will Clear the Hotel fields on Hotel Object if "Do you need Hotel Accomodation?" Changes from "Yes" to "No".
    */ 
    public Lodging__c clearHotelRecord(Lodging__c lod)
    {
        if(lod <> null)
        {
            lod.Check_In_Date1__c = null;
            lod.Check_out_Date2__c = null;
            lod.Bed_Type_Picklist__c = null;
            lod.Additional_Instructions__c = null;
            
        }
        return lod;
    }
    
    /*
        This method will check if user is allowed to register / login after registration close date.
        
    */
    public boolean validateAllowedBackdoorRegistrtaion(String eventId,String accountId,String email)
    {
        System.debug('email ==> '+email);
        if(isValidText(email))
        {
            Contact con = getContactFromEmail(email,accountId);
            System.debug('con ==> '+con);
            if(con <> null)
            {
                Registration__c reg = getRegistrationFromEventIdContactId(eventId,con.Id);
                System.debug('reg ==> '+reg);
                if(reg <> null)
                {
                    if(reg.Allow_Backdoor_Registration__c)
                    {
                        return true;
                    }
                    return false;
                }
                else 
                    return false;
            }
            else 
                return false;
        }
        else
         return false;
    }
    
    /*
        This method retuns the output value with 2 decimal places
        input : 12, 12.000, 12.0
        output: 12.00
        
    */
    public decimal round(decimal input)
    {
        if(input != null)
        return input.divide(1, 2, System.RoundingMode.UP);
        else
        return input;
    }
    
    /*
        This method retuns the age using given Start and end times
        1.
        input : 11/11/2011, 11/11/2013
        output: 1
        
        2.
        input : 11/11/2011, 11/12/2013
        output: 2
        
    */
    public Integer getAge(Date startDate, Date endDate)
    {
        if(startDate <> null && endDate <> null)
        {
            system.debug('startDate ==>> ' + startDate);
            system.debug('endDate ==>> ' + endDate);
            return Integer.Valueof(startDate.daysBetween(endDate) / 365.2425);  
        }
        else
        {
            return 0; 
        }
    }
     // Fetch products for Activity
    public Map<String,List<Product2>> getProducts(String eventId, String productType, boolean checkProductSize, boolean checkCurrentActiveRegPrd)
    {
        System.debug('eventId ==> '+eventId);
        Map<String,List<Product2>> mapActivityCapacity = new Map<String,List<Product2>>();
        
        try
        {
            List<Product2> productList;
            if(checkProductSize && checkCurrentActiveRegPrd)
            productList = [SELECT Id, ProductCode,Name, Product_Size__c,Child_Start_Age__c,Child_End_Age__c FROM Product2 WHERE Event__c =: eventId and Product_Type__c =: productType and isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE' AND (Product_Size__c =: null OR Product_Size__c > 0)];
            
            else if(checkProductSize && !checkCurrentActiveRegPrd)
            productList = [SELECT Id, ProductCode,Name, Product_Size__c,Child_Start_Age__c,Child_End_Age__c FROM Product2 WHERE Event__c =: eventId and Product_Type__c =: productType and isActive =: true AND (Product_Size__c =: null OR Product_Size__c > 0)];
            
            else if(!checkProductSize && checkCurrentActiveRegPrd)
            productList = [SELECT Id, ProductCode,Name, Product_Size__c,Child_Start_Age__c,Child_End_Age__c FROM Product2 WHERE Event__c =: eventId and Product_Type__c =: productType and isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE'];
            
            else //Do not check Product Size & isCurrentActiveRegPrd__c = 'TRUE' IF checkProductSize = false.
            productList = [SELECT Id, ProductCode,Name, Product_Size__c,Child_Start_Age__c,Child_End_Age__c FROM Product2 WHERE Event__c =: eventId and Product_Type__c =: productType and isActive =: true];
            
            if(productList != null)
            {
                for(Product2 prod : productList)
                {
                    List<Product2> prodList = mapActivityCapacity.get(prod.Name);
                    if(prodList == null)
                    {
                        prodList = new List<Product2>();    
                    }
                    prodList.add(prod);
                    mapActivityCapacity.put(prod.Name,prodList);
                }
            }
        }
        catch(Exception e)
        {
            
        }
        system.debug('~~~~~~~~~~~~' + mapActivityCapacity);
        return mapActivityCapacity;
        
    }
    
    /*
        Method Name: isProductAvailable
        Description: This method Checks if a given ProductName is available for the provided criteria's.(Primarily used to check and control the inventory of Activity Products)
    */
    
    public Product2 isProductAvailable(String eventId, String productType, String productName,Integer age, boolean checkProductSize, boolean checkCurrentActiveRegPrd)
    {
        system.debug('~~~~~~~~~~~~' + age);
        system.debug('~~~~~~~~~~~~' + productType);
        Map<String,List<Product2>> mapActivityCapacity = new Map<String,List<Product2>>();
        
        //Method Syntax: getProducts(String eventId, String productType, boolean checkProductSize, boolean checkCurrentActiveRegPrd)
        mapActivityCapacity = getProducts(eventId, productType, checkProductSize, checkCurrentActiveRegPrd);
         system.debug('~~~~~~~~~~~~' + mapActivityCapacity);
         List<Product2> products;
        if(isValidText(productName))
        {
            products = mapActivityCapacity.get(productName);
        }
        system.debug('~~~~~~~~~~~~' + productName);
        system.debug('~~~~~~~~~~~~' + products);
        
        if(products <> null)
        {
            for(Product2 prod : products)
            {
                system.debug('~~~~~~~~~~~~123456' + prod.Child_Start_Age__c+prod.Child_End_Age__c);
                if( (prod.Child_Start_Age__c == null || prod.Child_Start_Age__c <= age) && (prod.Child_End_Age__c == null || prod.Child_End_Age__c >= age) )
                 {
                    system.debug('<<<<<<<<!@!@!@!@IN FIRST IF');
                    if(checkProductSize)
                    {
                        system.debug('<<<<<<<<!@!@!@!@IN Second IF');
                        if(prod.Product_Size__c == null || prod.Product_Size__c > 0)
                        {
                            system.debug('<<<<<<<<!@!@!@!@IN Third IF');
                            return prod;
                        }//else will return null.
                    }
                    else
                    {
                        return prod;
                    }
                    
                }
            }
            return null;    
        }
        else
        {
            return null;    
        }
    }
    
    /*
        Method Name: decrementProductCount
        Description: Used to control the product Inventory.
    */
    
    public void decrementProductCount(Product2 prod)
    {
        if(prod <> null && prod.Product_Size__c != null && prod.Product_Size__c >0)
        {
            prod.Product_Size__c = prod.Product_Size__c - 1;
            List<Product2> prodList = new List<Product2>();
            prodList.add(prod);
            Database.Update(prodList, false); 
        }
    }
    
    /*
        Method Name: incrementProductCount
        Description: Used to control the product Inventory.
    */
    
    public void incrementProductCount(Product2 prod)
    {
        if(prod <> null && prod.Product_Size__c != null)
        {
            prod.Product_Size__c = prod.Product_Size__c + 1;
            List<Product2> prodList = new List<Product2>();
            prodList.add(prod);
            Database.Update(prodList, false); 
        }
    }
    /*
        Description: Methods use to fetch guest related records.
    */
    public List<Air_Travel__c> getGuestAirTravelRecords(List<Id> guestId){
        return [select Air_Seating_Preference__c,Departure_City__c,Preferred_Arrival_Date__c,Airport_Request__c,Airline_Request__c,Arrival_Transfer_Needed__c,
                                    Extend_Trip__c,Frequent_Fly_Carrier_1__c,Frequent_Flyer_Number_1__c,Preferred_Departure_Date__c,Departure_Transfer_Needed__c,
                                    Frequent_Fly_Carrier_2__c,Frequent_Flyer_Number_2__c,Same_Itinerary__c,Additional_Comments__c,
                                    Frequent_Fly_Carrier_3__c,Frequent_Fly_Carrier_4__c,Frequent_Flyer_Carrier_3_Other__c,
                                    Frequent_Flyer_Carrier_4_Other__c,Field_for_Itinerary__c,Will_You_Need_Air_Reservation__c,Frequent_Flyer_Number_3__c,
                                    Frequent_Flyer_Number_4__c,Air_Special_Meal__c,Air_Special_Meal_Comments__c,Frequent_Flyer_Carrier_Other_1__c,Frequent_Flyer_Carrier_Other_2__c, Arrival_Comments__c 
                                    from Air_Travel__c where Guest__c IN : guestId ];
    }
    
    public List<Activity__c> getGuestActivities(List<Id> guestId){
        return [select Gender_Choice__c,Do_you_need_equipments__c,Do_you_prefer_right_or_left_handed__c,
                                        Shoes_Needed__c,Shoe_Size__c,Participating_in_the_group_activity__c,Activity_Choice_2__c,Activity_Choice__c,Preferred_Appointment_Time__c,Activity_Date__c,Additional_Comments__c,Do_you_need_equipments_2__c,Do_you_prefer_right_or_left_handed_2__c,Gender_Choice_2__c,Preferred_Appointment_Time_2__c,Shoe_Size_2__c,Shoes_Needed_2__c,
                                        Shoe_Size_Other_1__c,Activity_Choice_Sub_Type__c,Shoe_Size_Other_2__c,Activity_Choice_2_Sub_Type__c,Will_You_Be_Attend_Additional_Activity__c
                                        from Activity__c where Guest__c IN :guestId  ];
    }
    public List<Lodging__c> getGuestLodgingRecords(List<Id> guestId){
        return [select Id,Bed_Type_Picklist__c,  Hotel_Comments__c,Check_In_Date1__c, Check_out_Date2__c,Room_type_Preference__c from Lodging__c where Guest__c IN :guestId ];
  }
  
  /*
    REUSABLE METHODS FOR CFP
  */
    public Attachment fetchAtachment(String parentId,String description)
    {
        Attachment attach;
        List<Attachment> atts = new List<Attachment>();
        atts = [Select Id, ParentId, Name, ContentType, Body, BodyLength, OwnerId, Description From Attachment 
                                                WHERE ParentId =: parentId AND Description = :description Order by CreatedDate DESC limit 1 ];
        if(atts != null && atts.size() > 0){
            attach = atts[0];
        }else{
            attach = null;
        }
        return attach;                                          
    }
    public boolean isValidDate(Datetime dt)
    {
        if(dt == null)
            return false;
        else
            return true;
    }
    public boolean isAfterCutoffDate(Datetime cutoff){
        if(cutoff != null){
            Datetime nowGMT = Datetime.now();
            Datetime cutoffGMT = Datetime.newInstanceGmt(cutoff.dateGmt(), cutoff.timeGmt());
            if(nowGMT >= cutoffGMT){
                return true;
            } else {
                return false;
            }
        } else { return false; }
    }
    public boolean isBeforeCutoffDate(Datetime cutoff){
        if(cutoff != null){
            Datetime nowGMT = Datetime.now();
            Datetime cutoffGMT = Datetime.newInstanceGmt(cutoff.dateGmt(), cutoff.timeGmt());
            
            if(nowGMT <= cutoffGMT){
                return false;
            } else {
                return true;
            }
        } else { return false; }
    }
    /*
        REUSABLE METHODS FOR Award Nomination
    */
    public List<Award_Nomination__c> getAllAwardNominees(String regId)
    {
        List<Award_Nomination__c> lstAwardsNominees = new List<Award_Nomination__c>();
        if(regId != null)
            lstAwardsNominees = [ Select First_Name__c,Last_Name__c,Reason_For_Nomination__c,Registration__c
                                  From Award_Nomination__c 
                                  Where Registration__c =: regId order by createddate Asc];  
        return lstAwardsNominees;
    }  
    public Award_Nomination__c getAwardNominee(String regId,String awardNomineeId)
    {
        Award_Nomination__c AwardNominee = [Select First_Name__c,Last_Name__c,Reason_For_Nomination__c,Registration__c 
                                            From Award_Nomination__c 
                                            Where Registration__c =: regId 
                                            AND id=:awardNomineeId];  
        return AwardNominee;
    }
    
    public List<Award_Nomination__c> getAllAwardNominationSubmittedByUser(String userId)
    {
        List<Award_Nomination__c> lstAwardsNominees = new List<Award_Nomination__c>();
        if(userId != null)
            lstAwardsNominees = [ Select Id, Nominator__c, Nominee_Name__c, Type__c, Quarter__c, Area__c, Reason_For_Nomination__c
                                  From Award_Nomination__c 
                                  Where Nominator__c =: userId order by createddate Asc];  
        return lstAwardsNominees;
    }
    
    public Guest__c upsertGuest(Guest__c guest,String contactId, String regId,String guestType,String guestPrefix,String contactFirstName, String contactLastName)
    {
        if(guest == null)
            guest = new Guest__c();
        
        System.debug('Guest:: ==>> '+guest);
        
        guest.Contact__c = contactId;
        guest.Registration__c = regId;
        guest.status__c = 'Created';
        guest.Type__c = guestType;
        guest.Name = guestPrefix+'- '+contactFirstName+' - '+contactLastName;
        upsert guest;
        
        return guest;  
    }
    public Product2 getPromoCodeProduct(String eventId, String appliedPromocode,String productType,boolean checkCurrentActiveRegPrd){
        System.debug('eventId ==> '+eventId);
        System.debug('appliedPromocode ==> '+appliedPromocode);
        List<Product2> productList;
        if(isValidText(appliedPromocode))
        {
            if(checkCurrentActiveRegPrd)
                productList = [SELECT Id, Name,Product_Size__c, ProductCode, Discount_Type__c FROM Product2 WHERE Event__c =: eventId AND ProductCode =: appliedPromocode.trim() and Product_Type__c =: productType and isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE'];
            else //Do not check Product Size & isCurrentActiveRegPrd__c = 'TRUE' IF checkProductSize = false.
                productList = [SELECT Id, Name,Product_Size__c, ProductCode, Discount_Type__c FROM Product2 WHERE Event__c =: eventId AND ProductCode =: appliedPromocode.trim() and Product_Type__c =: productType and isActive =: true];
            
            if(productList.size() != 0)
            {
                return productList.get(0);
            }
        }
       return null;
    }
    
    // New method for promo-code enabled login
    public String isValidPromoCodeForTheAttendeeTypeNew(String eventId, String appliedPromocode,String priceBookName, String attendeeType)
    {
        
        String errorMsg = null; 
        System.debug('eventId ==> '+eventId);
        System.debug('appliedPromocode ==> '+appliedPromocode);
        System.debug('Attendee Type ==> '+attendeeType);
        
        try
        {
            if (appliedPromocode == null)
            {
                appliedPromocode = '';
            }
            
            List<Product2> productList = [SELECT Id, ProductCode, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND ProductCode =: appliedPromocode.trim() and Product_Type__c =: 'PromoCode' and isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE' AND Attendee_Type__c includes (:attendeeType) /*AND (Product_Size__c =: null OR Product_Size__c > 0)*/];
            if(productList.size() != 0)
            {
                Product2 prod = productList.get(0);
                if(prod.Product_Size__c <= 0 ){
                    errorMsg = System.Label.EEG_PromoCode_Validation_Error_Capacity_Full;
                }
                else{
                    List<PricebookEntry> pentry = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.Id AND Pricebook2.Name =: priceBookName]; 
                    if(pentry.size() == 0 ){
                        errorMsg = System.Label.EEG_PromoCode_Validation_Error_Invalid_PromoCode;
                    }
                }
            }
            else{
                errorMsg = System.Label.EEG_PromoCode_Validation_Error_Invalid_PromoCode;
            }
        }
        catch(Exception e)
        {
            errorMsg = System.Label.EEG_PromoCode_Validation_Error_Invalid_PromoCode;
        }
        return errorMsg;
    }
    
    // New method for checking Registration Number as a Promocode.
    public Boolean isValidReferralCode(EEG_SiteProperties siteProperty, String regId, String appliedPromocode, String attendeeTypesOfReferredRegistrations, String attendeeType, String conferenceType)
    {
        
        String errorMsg = isValidPromoCodeForAttendeeTypeConfType(siteProperty.EVENT_ID, appliedPromocode, siteProperty.PRICEBOOK_NAME, attendeeType, conferenceType);
        
        if(isValidText(errorMsg))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
            return false;
        }
        
        
        Boolean isError = false;
        List<String> attendeeTypesOfReferredRegistrationsList = new List<String>();
        List<Registration__c> refferedRegistration;
        List<Registration__c> registrationsUsingReferredCode; 
        
        System.debug('eventId ==> '+siteProperty.EVENT_ID);
        System.debug('appliedPromocode ==> '+appliedPromocode);
        System.debug('Attendee Type ==> '+attendeeType);
        
        try
        {
            if (appliedPromocode == null)
            {
                appliedPromocode = '';
            }
            
            List<Product2> productList = new List<Product2>();
            Product2 prod;
            
			productList = [SELECT Id, ProductCode, Product_Size__c, isReferralCode__c FROM Product2 WHERE Event__c =: siteProperty.EVENT_ID AND ProductCode =: appliedPromocode.trim() and Product_Type__c =: 'PromoCode' and isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE' limit 1];
            
            if(productList.size() > 0)
            {
            	prod = productList.get(0);	
            }
            else
            {
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.EEG_PromoCode_Validation_Error_Invalid_PromoCode));
            	return false;
            }
            
            if(!prod.isReferralCode__c)
            {
            	return true;
            }
            
            if(isValidText(attendeeTypesOfReferredRegistrations))
            {
            	attendeeTypesOfReferredRegistrationsList = attendeeTypesOfReferredRegistrations.split(';');
            }
            else
            {
            	attendeeTypesOfReferredRegistrationsList = null;
            }
            
            
            
            // Check if applied referral code is valid 'Registration Number' for certain attendee types and that registrtaion is not using any promo code.
            if(attendeeTypesOfReferredRegistrationsList != null)
            {
	            refferedRegistration = [Select Id 
										From Registration__c
										Where Event__c =: siteProperty.EVENT_ID
										AND Attendee_Type__c IN :attendeeTypesOfReferredRegistrationsList 
										AND Registration_Id__c = :appliedPromocode
										AND PromoCode_Applied__c = null
										limit 1];	
            }
            else
            {
            	refferedRegistration = [Select Id 
										From Registration__c
										Where Event__c =: siteProperty.EVENT_ID
										AND Registration_Id__c = :appliedPromocode
										AND PromoCode_Applied__c = null
										limit 1];
            }
            
            system.debug('~~~~~~~~~~~~~~~~~~~refferedRegistration' + refferedRegistration);
            
            
            // Referral code is not valid, return false...
            if(refferedRegistration.size() == 0)
            {
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.EEG_PromoCode_Validation_Error_Invalid_PromoCode));
            	return false;
            }
            
            // Referral code is valid, check if any other registrtaions are usnig the same referral code...
            
            if(regId != null)
            {
	            registrationsUsingReferredCode = [SELECT Id, PromoCode_Applied__c,Attendee_Type__c, Event__c 
		 												FROM Registration__c 
		 												WHERE Event__c =: siteProperty.EVENT_ID 
		 												AND PromoCode_Applied__c =: appliedPromocode.trim()
		 												AND Id != :regId];		
            }
            else
            {
            	registrationsUsingReferredCode = [SELECT Id, PromoCode_Applied__c,Attendee_Type__c, Event__c 
	 												FROM Registration__c 
	 												WHERE Event__c =: siteProperty.EVENT_ID 
	 												AND PromoCode_Applied__c =: appliedPromocode.trim()];	
            }
            
            
			// Check if 'Referral code' capacity is reached or not, if reached return false...
			if(prod.Product_Size__c != null && registrationsUsingReferredCode.size() >= prod.Product_Size__c)
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.EEG_PromoCode_Validation_Error_Invalid_PromoCode));
				return false;
			}		         
        }
        catch(Exception e)
        {
        		system.debug('~~~~~~~~~~~~~~~~~~~refferedRegistration' + refferedRegistration);
        		system.debug('~~~~~~~~~~~~~~~~~~~Error' + e.getMessage() );
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.EEG_PromoCode_Validation_Error_Invalid_PromoCode));
				return false;
        }
        return true;
    }
    
    //Use this method to Double the activity product list price if bring guest is yes
    public  List<EEG_RegistrationUtility.OppLineItem> processGuestCharge(List<EEG_RegistrationUtility.OppLineItem> optlineItems,String productType){
        //List<Id> productIds = new List<Id>();
        //decimal registrationAmount = 0.00, workshopAmount = 0.00, guestAmount = 0.00, regAndWorkshopTotal = 0.00,regAndActivityTotal=0.0;
        for(EEG_RegistrationUtility.OppLineItem oppLineItem : optlineItems){
            
            if(oppLineItem.productType == productType)
            {
                if(oppLineItem.opline.Quantity!=2){
                    oppLineItem.listPrice = 2*oppLineItem.listPrice;
                    oppLineItem.opline.Quantity = 2;
                    oppLineItem.opline.UnitPrice = oppLineItem.listPrice;
                }
            }
            
        }
        return optlineItems;
    }
    //Use this method to revert activity product list price if bring guest is No
    public  List<EEG_RegistrationUtility.OppLineItem> revertGuestCharge(List<EEG_RegistrationUtility.OppLineItem> optlineItems,String productType){
        //List<Id> productIds = new List<Id>();
        //decimal registrationAmount = 0.00, workshopAmount = 0.00, guestAmount = 0.00, regAndWorkshopTotal = 0.00,regAndActivityTotal=0.0;
        for(EEG_RegistrationUtility.OppLineItem oppLineItem : optlineItems){
            
            if(oppLineItem.productType == productType)
            {
                if(oppLineItem.opline.Quantity == 2){
                    oppLineItem.listPrice = oppLineItem.listPrice/2;
                    oppLineItem.opline.Quantity = 1;
                    oppLineItem.opline.UnitPrice = oppLineItem.listPrice;
                }
            }
            
        }
        return optlineItems;
    }
    public  List<EEG_RegistrationUtility.OppLineItem> processChildCharge(List<EEG_RegistrationUtility.OppLineItem> optlineItems,String productType,Integer noOfChild){
        List<Id> productIds = new List<Id>();
        decimal registrationAmount = 0.00, workshopAmount = 0.00, guestAmount = 0.00, regAndWorkshopTotal = 0.00,regAndActivityTotal=0.0;
        
        for(EEG_RegistrationUtility.OppLineItem oppLineItem : optlineItems){
            
            if(oppLineItem.productType == productType)
            {
                oppLineItem.listPrice = noOfChild*oppLineItem.listPrice;
            }
            
        }
        return optlineItems;
    }        
    public  List<EEG_RegistrationUtility.OppLineItem> processPromoCode(List<EEG_RegistrationUtility.OppLineItem> optlineItems){
        List<Id> productIds = new List<Id>();
        decimal registrationAmount = 0.00, workshopAmount = 0.00, guestAmount = 0.00, regAndWorkshopTotal = 0.00,regAndActivityTotal=0.0,rentalFee=0.00,guestEventFee=0.0,boothFee=0.0;
        
        for(EEG_RegistrationUtility.OppLineItem oppLineItem : optlineItems){
            if(oppLineItem.productType == 'PromoCode')
            {
                productIds.add(oppLineItem.opLine.PricebookEntryId);
                
            }
            else if(oppLineItem.productType == 'Registration')
            {
                registrationAmount = registrationAmount +   oppLineItem.listPrice;
                regAndWorkshopTotal += registrationAmount;
            }
            else if(oppLineItem.productType == 'Workshop')
            {
                workshopAmount = workshopAmount +   oppLineItem.listPrice;
                regAndWorkshopTotal += workshopAmount;
            }
            else if(oppLineItem.productType == 'Activity')
            {
                regAndActivityTotal = regAndActivityTotal +   oppLineItem.listPrice;
                //regAndActivityTotal += registrationAmount;        
            }
            else if(oppLineItem.productType == 'Rental Fee')
            {
                rentalFee = rentalFee +   oppLineItem.listPrice;
                //regAndActivityTotal += registrationAmount;        
            }
            else if(oppLineItem.productType == 'Guest Event')
            {
                guestEventFee = guestEventFee + oppLineItem.listPrice;
                //regAndActivityTotal += registrationAmount;        
            }
            else if(oppLineItem.productType == 'Booth')
            {
                boothFee = boothFee + oppLineItem.listPrice;
                //regAndActivityTotal += registrationAmount;        
            }
        }
        
        if(productIds.size() > 0){
            //Fetch those products not having discount type as Amount 
            List<PricebookEntry> lstProds = [SELECT Id,Product2.Discount_Type__c, Product2.Discount_Percentage__c, Product2.ProductCode FROM PricebookEntry WHERE Id IN : productIds AND Product2.Discount_Type__c != 'Amount'];
            //List<PricebookEntry> lstProds = [SELECT Id,Product2.Discount_Type__c, Product2.Discount_Percentage__c, Product2.ProductCode FROM PricebookEntry WHERE Id IN : productIds];
            Map<Id,PricebookEntry> mapProduct = new Map<Id,PricebookEntry>(); 
            for(PricebookEntry prod : lstProds)
            {
                mapProduct.put(prod.id,prod);   
            }
            if(mapProduct.keyset().size() > 0)
            {
                boolean isSpecialPromoCode = false;
                for(EEG_RegistrationUtility.OppLineItem oppLineItem : optlineItems)
                {
                    PricebookEntry prod = mapProduct.get(oppLineItem.opLine.PricebookEntryId);
                    if(prod <> null)
                    {   
                        if(prod.Product2.Discount_Type__c == 'Percentage')
                            {
                                if(regAndWorkshopTotal != null && prod.Product2.Discount_Percentage__c != null)
                                {
                                    if(prod.Product2.Discount_Percentage__c >100)
                                        prod.Product2.Discount_Percentage__c = 100;
                                    
                                    decimal percentageDiscountAmount = round(regAndWorkshopTotal * prod.Product2.Discount_Percentage__c /100);
                                    oppLineItem.opLine.UnitPrice = percentageDiscountAmount;
                                    oppLineItem.listPrice = round(percentageDiscountAmount);
                                }
                                else if(boothFee!=null && prod.Product2.Discount_Percentage__c != null){
                                    if(prod.Product2.Discount_Percentage__c >100)
                                        prod.Product2.Discount_Percentage__c = 100;
                                    
                                    decimal percentageDiscountAmount = round(boothFee * prod.Product2.Discount_Percentage__c /100);
                                    oppLineItem.opLine.UnitPrice = percentageDiscountAmount;
                                    oppLineItem.listPrice = round(percentageDiscountAmount);
                                }
                            }
                            
                         else if(prod.Product2.Discount_Type__c == 'Percentage - Reg Fee Only')
                            {
                                if(registrationAmount != null && prod.Product2.Discount_Percentage__c != null)
                                {
                                    if(prod.Product2.Discount_Percentage__c >100)
                                    prod.Product2.Discount_Percentage__c = 100;
                                    
                                    decimal percentageDiscountAmount = round(registrationAmount * prod.Product2.Discount_Percentage__c /100);
                                    oppLineItem.opLine.UnitPrice = percentageDiscountAmount;
                                    oppLineItem.listPrice = round(percentageDiscountAmount);
                                }
                            }   
                            
                                
                        else if(prod.Product2.Discount_Type__c == 'Registration Fee Only')
                            {
                                oppLineItem.opLine.UnitPrice = registrationAmount;
                                oppLineItem.listPrice = round(registrationAmount);
                            }
                        else if(prod.Product2.Discount_Type__c == 'Registration And Activity Fee')
                            {
                                oppLineItem.opLine.UnitPrice = regAndActivityTotal+registrationAmount;
                                oppLineItem.listPrice = round(regAndActivityTotal+registrationAmount);
                            }   
                        else if(prod.Product2.Discount_Type__c == 'Registration Workshop')
                            {
                                oppLineItem.opLine.UnitPrice = registrationAmount + workshopAmount;
                                oppLineItem.listPrice = round(registrationAmount + workshopAmount);
                            }
                        else if(prod.Product2.Discount_Type__c == 'Registration Activity And Rental Fee')
                            {
                                oppLineItem.opLine.UnitPrice = registrationAmount + regAndActivityTotal +rentalFee;
                                oppLineItem.listPrice = round(registrationAmount + regAndActivityTotal +rentalFee);
                            }
                            
                        else if(prod.Product2.Discount_Type__c == 'Registration With or Without Workshop')
                        {
                            oppLineItem.opLine.UnitPrice = registrationAmount + workshopAmount;
                            oppLineItem.listPrice = round(registrationAmount + workshopAmount);
                        }
                        else if(prod.Product2.Discount_Type__c == 'Workshop Only')
                        {
                            oppLineItem.opLine.UnitPrice = workshopAmount;
                            oppLineItem.listPrice  = round(workshopAmount);
                        }
                        else if(prod.Product2.Discount_Type__c == 'Guest Only')
                        {
                            oppLineItem.opLine.UnitPrice = guestAmount;
                            oppLineItem.listPrice  = round(guestAmount);
                        } 
                            
                        else if(prod.Product2.Discount_Type__c == 'All')
                            {
                                oppLineItem.opLine.UnitPrice = registrationAmount + regAndActivityTotal +rentalFee+ workshopAmount+guestEventFee;
                                oppLineItem.listPrice = round(registrationAmount + regAndActivityTotal +rentalFee+ workshopAmount+ guestEventFee);
                            }          
                    }
                }
             }
             //If Discount Type is "Amount & Registration Fee is Zero then make the Promocode Fee Zero.
             else if(registrationAmount == 0.00)
             {
                List<PricebookEntry> lstProdsAmt = [SELECT Id,Product2.Discount_Type__c, Product2.Discount_Percentage__c, Product2.ProductCode FROM PricebookEntry WHERE Id IN : productIds AND Product2.Discount_Type__c = 'Amount'];
                Map<Id,PricebookEntry> mapProductAmt = new Map<Id,PricebookEntry>(); 
                for(PricebookEntry prod : lstProdsAmt)
                {
                    mapProductAmt.put(prod.id,prod);   
                }
                if(mapProductAmt.keyset().size() > 0)
                {
                    for(EEG_RegistrationUtility.OppLineItem oppLineItem : optlineItems)
                    {
                        PricebookEntry prod = mapProductAmt.get(oppLineItem.opLine.PricebookEntryId);
                        if(prod <> null)
                        {
                            oppLineItem.opLine.UnitPrice = registrationAmount;
                            oppLineItem.listPrice = round(registrationAmount);
                        }
                    }
                }    
             } 
        }
        return optlineItems;
    }
    
    //Use this method to apply donation amount
    public  List<EEG_RegistrationUtility.OppLineItem> processDonationCharge(List<EEG_RegistrationUtility.OppLineItem> optlineItems,String productType,String donationAmount){
        for(EEG_RegistrationUtility.OppLineItem oppLineItem : optlineItems){
            
            if(oppLineItem.productType == productType)
            {
                if(donationAmount !=null)
                    oppLineItem.listPrice = decimal.valueof(donationAmount);
            }
       }
        return optlineItems;
    }
    
    /*
        Method Name: getDiscountAmountForRegAndWorkshop
        Description: Used to calculate discount amount for registration and workshop fee.   
    */
    public  decimal getDiscountAmountForRegAndWorkshop(decimal registrationAmount,decimal workshopAmount,Integer registrationDiscount,Integer workshopDiscount){
        decimal discountAmount = 0.00;
        
        if(registrationAmount != null && registrationAmount > 0)
        {
            discountAmount = registrationAmount * registrationDiscount/100;
        }
        if(workshopAmount != null && workshopAmount > 0)
        {
            discountAmount += workshopAmount * workshopDiscount /100;
        }
        return discountAmount;
    }         
    
    /*
        Method Name: getDiscountAmountForRegAndWorkshop
        Description: Used to calculate discount amount for registration and workshop fee as per slot rate.   
    */
    public  decimal getDiscountAmountForRegAndWorkshop(decimal registrationAmount,decimal workshopAmount,Integer flatRateDiscount){
        decimal totalAmount = 0.00;
        
        if(registrationAmount != null && registrationAmount > 0)
        {
            totalAmount = registrationAmount;
        }
        if(workshopAmount != null && workshopAmount > 0)
        {
            totalAmount += workshopAmount;
        }
        if(totalAmount > 0 && flatRateDiscount != null && flatRateDiscount > 0)
        {
            if(flatRateDiscount > totalAmount)
            return 0.00;
            
            totalAmount = round(totalAmount - flatRateDiscount);
        }
            
        return totalAmount;
    } 
    
    /*
       Reusable attchment methods
    */
    public void saveAttachment(Attachment attach,String description,String parentId,String ownerId)
    {
        if(attach.Body != null && attach.Name != null)
        {
            deletePreviousAttachments(description,parentId);
            system.debug('~~~~~~~~~~~~~' + attach);
            attach.ParentId = parentId;
            attach.Description = description;
            /*
            //IMPORTANT:
            //Do not assign Registraion(or Other Parent Object record) Owner Id to Attachment OwnerId field. If Registraion(or Other Parent Object record) is owned by an internal user & attachment is being uploaded by an External user then it will throw the following error message. So just Leave the OwnerId Blank, The person who creates the Attachment record will own the record.
            //System.DmlException: Insert failed. First exception on row 0; first error: INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY, insufficient access rights on cross-reference id: []
            
            if(ownerId != null)
            attach.OwnerId = ownerId;*/
            insert attach;
        }
    }
    public void deletePreviousAttachments(String description,String parentId){
        List<Attachment> atts = getAllAtachments(parentId,description);
        if(atts <> null){
            Database.delete(atts,false);
        }
    }
    public List<Attachment> getAllAtachments(String parentId, String description){
        List<Attachment> atts = new List<Attachment>();
        atts = [Select Id, ParentId, Name, ContentType, Body, BodyLength, OwnerId, Description From Attachment 
                                                WHERE ParentId =: parentId AND Description = :description];
        if(atts != null && atts.size() > 0){
            return atts;    
        }else{
            return null;
        }
    }
    public List<Attachment> getAllAtachments(String parentId){
        List<Attachment> atts = new List<Attachment>();
        atts = [Select Id, ParentId, Name, ContentType, Body, BodyLength, OwnerId, Description From Attachment 
                                                WHERE ParentId =: parentId];
        if(atts != null && atts.size() > 0){
            return atts;    
        }else{
            return null;
        }
    }    
    
    /*
            This method will return total amount for Credit-Refund listed under Paypal_Transaction_History__c
    */
 public List<Paypal_Transaction_History__c> getPayPalHistory(Registration__c reg)
 {
    if(reg != null)
    {
        return  [SELECT Amount_Processed__c,Name,Payment__c,CreatedDate,LastModifiedDate,Transaction_Type__c  
                 FROM Paypal_Transaction_History__c 
                 Where Payment__r.Registration__c = :reg.Id 
                        AND Transaction_Result__c = 'Approved'];        
    }
    else
    {
        return null;
    }
 }
 
 public class PaypalTransactionHistory
 {
    public Paypal_Transaction_History__c  transHistory {get;set;}
    public DateTime historyDate  {get;set;}
    
    public String historyDateFormatted {get{
            return  EEG_SessionsUtility.formatDateTime(historyDate, 'EEEE, MMMM d');
    }set;}
    
    public PaypalTransactionHistory(Paypal_Transaction_History__c  historyObj)
    {
        this.transHistory = historyObj;
        this.historyDate = historyObj.CreatedDate;
    }
 }
 public List<PaypalTransactionHistory> getPaypalHistoryRecords(Registration__c reg)
 {
    List<PaypalTransactionHistory> transactionHistoryList = new List<PaypalTransactionHistory>();
    if(reg != null)
    {
        List<Paypal_Transaction_History__c> paypalRefundTrans =  [SELECT Amount_Processed__c,Name,Payment__c,CreatedDate,LastModifiedDate,Transaction_Type__c 
                                                                 FROM Paypal_Transaction_History__c 
                                                                 Where Payment__r.Registration__c = :reg.Id 
                                                                        AND Transaction_Result__c = 'Approved'
                                                                 Order by CreatedDate];
        
        if(paypalRefundTrans.size() > 0)
        {
            for(Paypal_Transaction_History__c transHistObj : paypalRefundTrans)
            {
                transactionHistoryList.add(new PaypalTransactionHistory(transHistObj));
            }
        }                                                                              
    }
    return transactionHistoryList;
 }
 public Decimal getTotalFromPayPalHistory(List<Paypal_Transaction_History__c> paypalTrans, String transactionType)
 {
    Decimal total = 0;
    if(paypalTrans.size() > 0)
    {
        for(Paypal_Transaction_History__c trans : paypalTrans)
        {
            if(trans.Transaction_Type__c == transactionType)
            {
                total = total + trans.Amount_Processed__c;  
            }
            
        }
    }
    return total;
 }
 
 public List<Email_Blast_Request__c> getRSVP_Requests (String eventId,String exhibitorLevel)
 {
    return [Select Name From Email_Blast_Request__c Where Event__c =: eventId AND 
                                   IsActive__c=true and IsUsedInRegistrationForm__c=true and Exhibitor_Level__c=: exhibitorLevel];  
 }
 
 public List<Participant__c> getExistingParticipants(String eventId,String regId)
 {
    return [Select id,Name,RSVP_Request__c,RSVP_Request__r.Event__c From Participant__c 
            Where Registration__c =: regId AND RSVP_Request__r.Event__c=: eventId]; 
 }
 
 public Registration_Group_Member__c getRegistrationGroupMemberRecord(String regId)
 {
    List<Registration_Group_Member__c> regGrpMemList = [Select Registration_Group__c, Registration__c From  Registration_Group_Member__c 
                                                        Where Registration__c = :regId ];
    if(regGrpMemList.size() > 0)
    {
        return regGrpMemList.get(0);
    }
    else
    {
        return null;
    }                                                           
 }
 
 public List<Registration_Group_Member__c> getAllRegGroupMembers(String groupId)
 {
    return [Select id,Registration_Group__c,Registration__c, Registration__r.Registrant__r.FirstName, Registration__r.Registrant__r.LastName,
            Registration__r.Registrant__r.Email, Registration__r.Registrant__r.Phone 
            From  Registration_Group_Member__c 
            Where Registration_Group__c=:groupId]; 
 }
 
 public List<Registration__c> getGroupMamberRegistrations(set<ID> regList, set<ID> loggedInRegId, boolean includeLoggedInUserRegistration)
 {
    if(includeLoggedInUserRegistration != null && includeLoggedInUserRegistration)
    return  [SELECT Id,Name,Status__c,Registrant__r.firstname,Registrant__r.lastname,Registrant__r.Email,Registrant__c, Will_You_Need_Hotel_Accommodations__c FROM Registration__c WHERE ID IN : regList order by Createddate asc];
    else
    return  [SELECT Id,Name,Status__c,Registrant__r.firstname,Registrant__r.lastname,Registrant__r.Email,Registrant__c, Will_You_Need_Hotel_Accommodations__c FROM Registration__c WHERE ID IN : regList and ID NOT IN : loggedInRegId order by Createddate asc];
 }
 
 /*
        Thsi method will return TRUE if the person is already referred by the same Person.
 */
    public boolean isAlreadyReferredBytheSameContact(String accountId, Contact referredByContact, Contact referredContact)
    {
        if(isValidText(accountId) && referredByContact != null && referredContact != null)
        {
            for(Contact_Referral__c CR : [SELECT Id FROM Contact_Referral__c WHERE Referred_By__r.AccountId =: accountId AND Referred_By__r.Email =: referredByContact.Email AND Referred_Contact__r.Email =: referredContact.Email limit 1])
            {
                return true;
            }
        }
        return false;
    }
 
 /*
        Thsi method will return the details of "Contact Referral", "Referred By" & "Submitted By" records using "Contact Referral ID".
 */
    public Contact_Referral__c getContactReferralDetails(String contactReferralId)
    {
        if(isValidText(contactReferralId))
        {
            for(Contact_Referral__c contactReferral : [SELECT Product__c,Additional_Details__c,Benefits__c,Categories__c,Project_Overview__c, Stage_of_Project__c,
                                                       Referred_By__r.Id, Referred_By__r.FirstName, Referred_By__r.Lastname, Referred_By__r.email, Referred_By__r.Company_Name__c, Referred_By__r.Title, Referred_By__r.MobilePhone,
                                                       Referred_Contact__r.Id, Referred_Contact__r.FirstName, Referred_Contact__r.Lastname, Referred_Contact__r.email, Referred_Contact__r.Company_Name__c, Referred_Contact__r.Title, Referred_Contact__r.MobilePhone,
                                                       First_Name__c,Last_Name__c,Email__c,Company_Name__c
                                                       FROM Contact_Referral__c WHERE Id =: contactReferralId])
            {
                return contactReferral;
            }
        }
        return null;
    }
    
 /*
    This method will return manager details
 */
 public Registration__c getManagerDetails(String contactId, String eventId)
 {
    List<Registration__c> regList = [Select id, Workshop_Location__c, Name,  Registrant__r.LastName, Registrant__r.FirstName
                                    From Registration__c 
                                    Where Registrant__r.Id = :contactId 
                                    AND Event__c = :eventId];
        
    if(regList.size() > 0)
    {
        return regList.get(0);
    }
    else
    {
        return null;
    }
 }
 /*
    This method will return all lodging records for user
 */
 public List<Lodging__c> getAllLodgings(String regId)
 {
    return [Select id, Status__c, Workshop_Location__c, Check_in_Date__c, Check_out_Date__c 
                From Lodging__c Where Registration__c = :regId];
 }
 
 /*
    This method will return Semicolon separated Multi Picklist values in a form that can be used to filter Multi-Picklist values using Multi-Picklist Values in a SOQL Query.
    Input:  Platinum;Gold;Silver
    Output: 'Platinum','Gold','Silver'
    NOTE: SOQL INCLUDES doesn't Support List. In only supports string Hence Dynamic SOQL has to be used to filter Multi-Picklist values using Multi-Picklist Values.
 */
 public String splitMultiSelectPicklist(String multiSelect)
 {
    if(isValidText(multiSelect))
    {
        String multiSelectSOQLString;
        multiSelectSOQLString = '';
        boolean first = true;
        for(String value : multiSelect.split(';'))
        {
           if(first) 
           multiSelectSOQLString += '\''+String.escapeSingleQuotes(value)+'\'';
           else
           multiSelectSOQLString += ',\''+String.escapeSingleQuotes(value)+'\'';
           
           first = false;
        }
        System.debug('**** multiSelectSOQLString  ===>>> '+multiSelectSOQLString);
        return multiSelectSOQLString; 
    }
    else
    {
        return null;
    }
 }
/*
    update Nominee & nominator records with their respective new values     
*/
 public Contact getUpdatedContact(Contact conExisting,Contact conNew){
    conExisting.firstname = conNew.firstName;
    conExisting.lastname = conNew.LastName;
    conExisting.Company_Name__c = conNew.Company_Name__c;
    conExisting.Title = conNew.Title;
    conExisting.MobilePhone = conNew.MobilePhone;
    upsert conExisting;
    
    return conExisting; 
 }
/*
    update conReferral record with the new values
*/  
 public Contact_Referral__c getconReferral(Contact_Referral__c conRef,Contact_Referral__c conReferral){
    conRef.Additional_Details__c = conReferral.Additional_Details__c;
    conRef.Benefits__c = conReferral.Benefits__c;
    conRef.Categories__c = conReferral.Categories__c;
    conRef.Project_Overview__c = conReferral.Project_Overview__c;
    conRef.Product__c = conReferral.Product__c;
    conRef.Stage_of_Project__c = conReferral.Stage_of_Project__c;
    update conRef;
    
    return conRef; 
 }
 
 /*
    This reusable method will return TRUE if -
    start date of event item is reached 
    
    Otherwise it will return FALSE.
    
    If Fields are NULL then Returns TRUE.
 */
 
 public boolean isEventItemsOpen(String eventId,String Type){
    Boolean isOpen = true;
    Event_Header__c event = getEventInfo(eventId);
    if(event!=null){
        if(Type == 'Registration'){
            if(event.Registration_Start_Date_Time__c!=null){
                return isBeforeCutoffDate(event.Registration_Start_Date_Time__c);
            }
        }
        if(Type == 'Cfp'){
            if(event.Cfp_Open_Date__c!=null){
                if(event.Cfp_Open_Date__c >= system.now())
                    return isBeforeCutoffDate(event.Cfp_Open_Date__c);  
            }
        }
        if(Type == 'Src'){
            if(event.Src_Open_Date__c!=null){
                if(event.Src_Open_Date__c >= system.now())
                    return isBeforeCutoffDate(event.Src_Open_Date__c);  
            }
        }
    }
    return isOpen;
 }
 /*
    This reusable method will return TRUE if -
    end date of event item is passed
    
    Otherwise it will return FALSE.
    If Fields are NULL then Returns FALSE.
 */
 public boolean isEventItemsClosed(String eventId,String Type){
    Boolean isClosed = false;
    Event_Header__c event = getEventInfo(eventId);
    if(event != null){
        if(Type == 'Registration'){
            if(event.Registration_End_Date_Time__c!=null){
                return isAfterCutoffDate(event.Registration_End_Date_Time__c);  
            }
        }
        if(Type == 'Cfp'){
            if(event.Cfp_Close_Date__c!=null){
                if(event.Cfp_Close_Date__c <= system.now())
                    return isAfterCutoffDate(event.Cfp_Close_Date__c);  
            }
        }
        if(Type == 'Src'){
            if(event.Src_Close_Date__c!=null){
                return isAfterCutoffDate(event.Src_Close_Date__c);
            }
        }
        if(Type == 'Erc'){
            if(event.Erc_Close_Date__c!=null){
                return isAfterCutoffDate(event.Erc_Close_Date__c);
            }
        }
    }
    return isClosed;
 }
 /*
    This reusable method used to get recordType id from recordTypeName
 */
 public String getRecordTypeId(String recordTypeName){
         List<RecordType> lstRecordType;
        if(recordTypeName != null)
        {
            lstRecordType = [Select id from RecordType where DeveloperName =: recordTypeName limit 1];
            if(lstRecordType.size()>0)
                return lstRecordType[0].id;
            else
                return null;    
        }   
        return null;
            
    } 
    
 /*
    Reusable methods related to dynamic checkbox starts here.
 */

 /*
    Method Name : createSelectoptionList
    This method will return list of selectoptions.
    Pass Map of <key,value> pair
    Use this method if Display value is different than db value
 */    
 public List<SelectOption> createSelectoptionList(Map<String,String> keyValueMap)
 {
    List<SelectOption> tempSelectOptionList = new List<SelectOption>();
    for(String key : keyValueMap.keySet())
    {
        if(isValidText(key) && isValidText(keyValueMap.get(key)))
        tempSelectOptionList.add(new SelectOption(key,keyValueMap.get(key)));
    }
    
    return tempSelectOptionList;
 }
 /*
    Method Name : createSelectOptionFromList
    This method will return list of selectoptions.
    Pass list of vaalues
    Use this method if Display value is same as db value
 */    
 public List<SelectOption> createSelectOptionFromList(List<String> valueList)
 {
    List<SelectOption> tempSelectOptionList = new List<SelectOption>();
    if(valueList != null)
    {
        for(String val : valueList)
        {
            if(isValidText(val))
            tempSelectOptionList.add(new SelectOption(val,val));
        }
    }
    
    return tempSelectOptionList;
 }
 /*
    Method Name : getStringForMultiSelectField
    This method will convert list of values into single string to store in Multi-Select field
 */
 public String getStringForMultiSelectField(List<String> selectedValues)
 {
    String finalValue;
    if(selectedValues != null)
    {
        for(String str : selectedValues)
        {
          if(isValidText(str))
          {
            if(finalValue == null)
            {
                finalValue = str;
            }
            else
            {
                finalValue = finalValue +';' + str; 
            }
          }  
        }
    }
    return finalValue;
 }
 /*
    Method Name : getStringFromMultiSelectWithMap
    This method will convert Multi-select field value to list of String based on Map passed.
 */
 public List<String> getStringFromMultiSelectWithMap(String multiSelectValue, Map<String,String> mapOfKeyValue)
 {
    List<String> storedValues = new List<String>();
    if(multiSelectValue != null)
    {
        List<String> selectedKey = new List<String>();
        selectedKey = multiSelectValue.split(';');
        for(String str : selectedKey)
        {
            if(isValidText(str))
            storedValues.add(mapOfKeyValue.get(str));
        }
    }
    return storedValues;
 }   
 /*
    Reusable methods related to dynamic checkbox ends here.
 */
 
 /*
    Reusable method to get registration group record..
 */
 public Registration_Group__c getRegistrationGroup(String registrationGroupId){
    List<Registration_Group__c> lstRegistrationGroup = [Select Registration_Group_SFDC_Id__c,Name,Will_You_Be_Introducing_New_Products__c,Product_Name__c,Exhibitor_Level__c,
                    Booth_Type__c,Booth_Sponsorship_Level__c,Ala_Carte_Sponsorships__c,Event_Sponorship__c,Business_Address_Line1__c,
                    Business_Address_Line2__c,Business_City__c,Company_Name__c,Business_Zip_Code__c,Business_Country__c,Business_State__c,Company_Description__c,Reference_Number__c,
                    (SELECT Id,Card_Type__c,Card_Number_Encrypted__c,Expiration_Month__c,Expiration_Year__c,Name__c,CreatedDate,Amount__c,Amount_Charged__c,Name,
                                           Registration__c,Usage_Type__c,Method_of_Payment__c,General_Comments__c
                                                FROM Payment__r)
                    from Registration_Group__c where id=:registrationGroupId];
            
            if(lstRegistrationGroup.size()>0)
                return lstRegistrationGroup[0];
            else
                return null;    
   }
   
   /*
    Reusable method to get Opportunity related to registration group record..
   */
   public List<EEG_RegistrationUtility.OppLineItem> getRegGroupOpportunityLineItem(String registrationGroupId){
        List<EEG_RegistrationUtility.OppLineItem> OptlineItems = new List<EEG_RegistrationUtility.OppLineItem>();
        
        List<Opportunity> lstOppRegistrationGrp = [Select Id From Opportunity Where Registration_Group__c =: registrationGroupId limit 1];
        
        if(lstOppRegistrationGrp.size()>0){
            List<OpportunityLineItem> tempOPLineItem  = new List<OpportunityLineItem>();
            tempOPLineItem.addAll(getExisitingOppLineItem(lstOppRegistrationGrp[0].Id,'Event Sponsorship'));
            List<OpportunityLineItem> tempAdditionalOPLineItem  = new List<OpportunityLineItem>();
            tempAdditionalOPLineItem = getExisitingOppLineItem(lstOppRegistrationGrp[0].Id,'Additional Event Sponsorship');
            if(tempAdditionalOPLineItem.size() > 0)
            {
                for(OpportunityLineItem oppLI : tempAdditionalOPLineItem)
                {
                    if(oppLI.Status__c == 'Approved')
                    {
                        tempOPLineItem.add(oppLI);
                    }
                }
            }
            tempOPLineItem.addAll(getExisitingOppLineItem(lstOppRegistrationGrp[0].Id,'Staff Registration Fee'));
            tempOPLineItem.addAll(getExisitingOppLineItem(lstOppRegistrationGrp[0].Id,'Booth'));
            optlineItems = getProducts(tempOPLineItem);
        }  
       return optlineItems;
   }
   /*
    Reusable method to chaeck whether username is whitelisted or not
   */
   public Boolean isWhitelistedUserName(String username,String eventId,String siteUserSuffix){
    boolean isValidUsername = true;
    if(isValidText(username))
        {
            //For ******Programertain emails are allowed for Registration. So we are using "Email Black List" object for email WhiteList as well (with reverse check).
            username = removeSiteSuffix(userName, siteUserSuffix);
            if(!isWhiteListedEmailAddress(eventId,username))
                isValidUsername = false;                            
        }
   return isValidUsername;
   }
   /*
    Reusable for activity inventory control..
   */ 
   public class activityWrapperClass{
    public Boolean activityChk1{get;set;} 
    public Boolean activityChk2{get;set;}
    public String previousActivityDay1{get;set;}
    public String previousActivityDay2{get;set;}
    EEG_RegistrationUtility eegRegUtility;
    Product2 previouslySelectedAttendeeActivityProduct;
    Product2 selectedAttendeeActivityProduct1,selectedAttendeeActivityProduct2;
    
    public activityWrapperClass(){
        eegRegUtility = new EEG_RegistrationUtility();
        activityChk1 = true; 
        activityChk2 = true;
    } 
    public Boolean validateActivity(String activityChoice1,String activityChoice2,String eventId){ 
        if(activityChoice1 != null){
            selectedAttendeeActivityProduct1 = isActivityAvailable(activityChoice1,'day 1',true,eventId);
                if(previousActivityDay1 <> activityChoice1)
                {
                    if(selectedAttendeeActivityProduct1 == null)
                    {   
                        activityChk1 = false;
                    }
                }   
        }
        if(activityChoice2 != null){
            selectedAttendeeActivityProduct2 = isActivityAvailable(activityChoice2,'day 2',true,eventId);
                if(previousActivityDay2 <> activityChoice2)
                {
                    if(selectedAttendeeActivityProduct2 == null)
                    {
                        this.activityChk2 = false;
                    }
                }   
        }
        if(!activityChk1 || !activityChk2)
            return false;
        else{
            if(previousActivityDay1 <> activityChoice1)
            {
                previouslySelectedAttendeeActivityProduct = isActivityAvailable(previousActivityDay1,'day 1',false,eventId);    
                decrementAndIncrementActivityProductCount(selectedAttendeeActivityProduct1, true, previouslySelectedAttendeeActivityProduct);
            }
            if(previousActivityDay2 <> activityChoice2)
            {
                system.debug('<<<<<<<!@!@1'+previousActivityDay2+'<<<<<activityChoice2::'+activityChoice2);
                previouslySelectedAttendeeActivityProduct = isActivityAvailable(previousActivityDay2,'day 2',false,eventId);         
                system.debug('<<<<<$$%$%'+previouslySelectedAttendeeActivityProduct+'<>>>>>>selectedAttendeeActivityProduct2'+selectedAttendeeActivityProduct2);
                decrementAndIncrementActivityProductCount(selectedAttendeeActivityProduct2, true, previouslySelectedAttendeeActivityProduct);
            }
        }
        return true;    
    }
    public Product2 isActivityAvailable(String activity,String daySuffix,boolean checkProductSize,String eventId)
    {
        
        Product2 prd = eegRegUtility.isProductAvailable(eventId, 'Activity',activity + ' - '+daySuffix,null,checkProductSize, false);
        return prd;
        
    }
    public void decrementAndIncrementActivityProductCount(Product2 activityProduct, boolean decrementProductSize, Product2 previouslySelectedActivityProduct)
    {
        if(decrementProductSize)
            eegRegUtility.decrementProductCount(activityProduct);
        if(previouslySelectedActivityProduct != null)
            eegRegUtility.incrementProductCount(previouslySelectedActivityProduct);
    }   
   }
   // Fetches all products with given Product Type and SubType
   public List<Product2> getAllProduct(string ProductType, string ProductSubType, string eventID) {
            
        List<Product2> ProductList = new List<Product2>();
        System.debug('-------- ProductSubType'+ProductSubType);
        System.debug('-------- ProductType'+ProductType);
        System.debug('-------- eventID'+eventID);
        if(isValidText(ProductSubType) && isValidText(ProductType) && isValidText(eventID))
        {
            ProductList = [select id, Name,Product_Type__c,Product_Sub_Type__c,Event__c,Description,Order_Of_Display__c from Product2 where Product_Type__c=:ProductType
                      AND Product_Sub_Type__c=:ProductSubType  AND Event__c=: eventID AND isActive =: true];
        }
        
        else if(isValidText(ProductType) && isValidText(eventID))
        {
            ProductList = [select id, Name,Product_Type__c,Product_Sub_Type__c,Event__c,Description,Order_Of_Display__c from Product2 where Product_Type__c=:ProductType
                          AND Event__c=: eventID AND isActive =: true];
        }
        System.debug('-------- ProductList'+ProductList);
        return ProductList;
    }
    // Fetches all products with given Product Type and Attendee Type and event
    public List<Product2> getAllProducts(string ProductType, string attendeeType, string eventID) {
            
        List<Product2> ProductList = new List<Product2>();
        if(isValidText(attendeeType) && isValidText(ProductType) && isValidText(eventID))
        {
            ProductList = [Select Id, Product_Type__c,Order_Of_Display__c, Product_Size__c,Event__c,Description, Name FROM Product2 WHERE Event__c =: eventID 
                                  AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND Product_Type__c =: ProductType AND Attendee_Type__c includes (:attendeeType)];
        }
        return ProductList;
    }
    
    public Registration__c getRegistrationChildRecords(String registrationId,String usageType){
        List<Registration__c> lstReg = [Select id,(select id from Lodgings__r),(Select id from Payment__r where Usage_Type__c=:usageType) from Registration__c where id=:registrationId];
        if(lstReg.size()>0)
        return lstReg.get(0);
        else
        return null;        
    }
 
 public Map<String,String> createProductNameDescriptionMap(List<Product2> productList)
 {
    Map<String,String> mapProductNameDescription = new Map<String,String>();
    
    if(productList != null && productList.size() > 0)
    {
        for(Product2 prod : productList) 
        {
            mapProductNameDescription.put(prod.Name,prod.Description);
        }
    }
    return mapProductNameDescription;
 }
 public Map<Decimal,String> createProductOrderByNameMap(List<Product2> productList)
 {
    Map<Decimal,String> mapProductOrderByName = new Map<Decimal,String>();
    
    if(productList != null && productList.size() > 0)
    {
        for(Product2 prod : productList) 
        {
            mapProductOrderByName.put(prod.Order_Of_Display__c,prod.Name);
        }
    }
    return mapProductOrderByName;
 }
 public List<Lodging__c> getMultipleLodgingRecords(String regId)
 {
    return [SELECT Id, Name, Additional_Instructions__c, Bed_Type_Picklist__c, Room_type_Preference__c, Hotel_Comments__c, Additional_User_Hotel_Comments__c, Check_In_Date1__c,
            Check_out_Date2__c,Hotel_Assigned__c,Registration__c, Room_Type__c, Meal_Preference__c 
    FROM Lodging__c 
    WHERE Registration__c = : regId AND Has_Multiple_Hotel_Reservations__c = true];
 }
 
 /*
    METHOD NAME - sortSelectOptionList
    METHOD DESCRIPTION - Reusable method to sort list of Selectoption.
    INPUT - 1) Unsorted list of SelectOption
            2) Map of <order,itemValue> as <key,value> pair
            
 */
    
 public List<SelectOption> sortSelectOptionList(List<SelectOption> unsortedList, Map<Decimal,String> orderOptionValueMap, boolean isFirstValueDefault)
 {
    List<SelectOption> sortedSelectOptionList = new List<SelectOption>();
    
    if(!isFirstValueDefault)
    {
        sortedSelectOptionList.add(new SelectOption('','--None--'));    
    }
    
    
    Set<SelectOption> selectOptionWithOrder = new Set<SelectOption>();
    
    if(orderOptionValueMap.size() > 0)
    {
        for(Integer i=1; i<= orderOptionValueMap.size() ; i++)
        {
            String str = orderOptionValueMap.get(i);
            if(str == null)
            {
                continue;
            }
            for(SelectOption tempOtion : unsortedList)
            {
                if(tempOtion.getValue() == str)
                {
                    sortedSelectOptionList.add(tempOtion);
                    selectOptionWithOrder.add(tempOtion);
                }   
            }
        }   
    }
    for(SelectOption tempSO : unsortedList)
    {
        if(!selectOptionWithOrder.contains(tempSO))
        {
            sortedSelectOptionList.add(tempSO); 
        }
    }
    
    return sortedSelectOptionList;
 }
 
 /**
    METHOD NAME :   validateUser
    This reusable method is user to
    1. Validate Passwords
    2. Existing User
    3. Email Blck or Whitelist validation.  
 */
 public Pagereference validateUser(EEG_SiteProperties siteProperty, Contact con, String regPassword, String regConfirmPassword, boolean createPortalUser, String createPortalUserErrorMessage, String validateEmailBlackOrWhiteList, String validateEmailBlackOrWhiteListErrorMessage, Event_Header__c event, Boolean validateCaptcha, reCAPTCHA captcha, EEG_InhouseCaptchaController eegCaptcha)
 {
    if(!isValidText(regPassword) || !isValidText(regConfirmPassword))
    {
        ApexPages.Message msgx = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Please_Enter_Required_Information);
        ApexPages.addMessage(msgx);
        return null;
    }
    else if(regPassword != regConfirmPassword)
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Password_and_Confirm_Password_Should_be_the_Same));
        return null;
    }
    
    if(createPortalUser)
    {
        /*
            Check if user name alreday exists for the program.
        */    
        if(isExistingUser(getUserName(con.email,siteProperty.SITE_USER_SUFFIX)))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, createPortalUserErrorMessage));
            return null;
        }   
    }
    /*
        "Email Black List" and "Email White List" validation.
    */
    if(isValidText(validateEmailBlackOrWhiteList))
    {
        if(validateEmailBlackOrWhiteList == 'Whitelist')
        {
                if(!isWhiteListedEmailDomain(siteProperty.EVENT_ID, con.email))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, validateEmailBlackOrWhiteListErrorMessage));
                    return null;
                }
        }
        if(validateEmailBlackOrWhiteList == 'Blacklist')
        {
                if(isBlackListedEmailDomain(siteProperty.EVENT_ID, con.email))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, validateEmailBlackOrWhiteListErrorMessage));
                    return null;
                }
        }
    }
    /*
        Validate captcha code
    */
    if(validateCaptcha)
    {
        if(event != null)
        {
            if(event.Captcha_Type__c == 'Recaptcha' && captcha != null)
            {
                System.debug('captcha.challenge: '+ captcha.challenge+', captcha.response: '+ captcha.response);
                Boolean captchaResponse = captcha.verify(); 
                if(!captchaResponse)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.EEG_Incorrect_Captcha_Code_Please_try_again));
                }
            }
            else if(event.Captcha_Type__c == 'EEG Captcha'  && eegCaptcha != null)
            {
                System.debug('eegCaptcha.challange: '+ eegCaptcha.challange+', eegCaptcha.response: '+ eegCaptcha.response);
                if(!eegCaptcha.validate())
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.EEG_Incorrect_Captcha_Code_Please_try_again));
                }
            }
        }
    }
    
    return null;
 }
 
 /**
    METHOD NAME :   registerUser
    This reusable method will be used to create/update Contact, Registrtaion & Portal User records.
    INPUT Parameters :  Following parameters will be passed to this method based on program specific requirement -
                        1) Contact
                        2) Registration
                        3) Site Property 
                        4) Password
                        5) Confirm Password
                        6) createPortalUser (boolean value to create portal user or not)
                        7) createPortalUserErrorMessage (String value to display Custom Error message if the user already exist in SFDC)
                        8) notAttendingSuccessPage (Page to which user will be redirected if not attending)
                        9) isContactPrePopulated (If contact is pre-populated in SF DB pass true)
                        10) validateUser (pass true, if we need to perform user validation (password , existing user, etc..))
                        11) validateEmailBlackOrWhiteList (String Value: Pass "Whitelist" or  "Blacklist" if we need to perform whiteList or BlackList validation)
                        12) validateEmailBlackOrWhiteListErrorMessage (String value to display Custom Error message if the user email address or domain is blacklisted or whitelisted)
 */
 public Pagereference registerUser(Contact con, Registration__c reg, EEG_SiteProperties siteProperty, String regPassword, String regConfirmPassword, Boolean createPortalUser, String createPortalUserErrorMessage, PageReference notAttendingSuccessPage, Boolean isContactPrePopulated, Boolean validateUser,String validateEmailBlackOrWhiteList,String validateEmailBlackOrWhiteListErrorMessage, Event_Header__c event, Boolean validateCaptcha, reCAPTCHA captcha, EEG_InhouseCaptchaController eegCaptcha)
 {
    Contact conExisting;
    Registration__c regExisting;
    string userId,contactId;
    Savepoint sp;
    String EMAIL_BLACK_OR_WHITELIST_ERROR_MESSAGE = System.Label.EEG_Email_Domain_is_Blocked;
    String USERNAME_EXISTS_ERROR_MESSAGE = System.Label.EEG_User_Name_Exist_Please_Login_Or_Reset_Password;
    
    //Override Generic Error Messages if needed.
    if(isValidText(validateEmailBlackOrWhiteListErrorMessage))
    {
        EMAIL_BLACK_OR_WHITELIST_ERROR_MESSAGE = validateEmailBlackOrWhiteListErrorMessage;
    }
    if(isValidText(createPortalUserErrorMessage))
    {
        USERNAME_EXISTS_ERROR_MESSAGE = createPortalUserErrorMessage;
    }
    
    if(validateUser)
    {
        /*
        Method SYNTAX: public Pagereference validateUser(EEG_SiteProperties siteProperty, Contact con, String regPassword, String regConfirmPassword, boolean createPortalUser, String createPortalUserErrorMessage, String validateEmailBlackOrWhiteList, String validateEmailBlackOrWhiteListErrorMessage)
        This reusable method is user to
        1. Validate Passwords
        2. Existing User
        3. Email Blck or Whitelist validation.  
        */
        validateUser(siteProperty, con, regPassword, regConfirmPassword, createPortalUser, USERNAME_EXISTS_ERROR_MESSAGE, validateEmailBlackOrWhiteList, validateEmailBlackOrWhiteListErrorMessage, event, validateCaptcha, captcha, eegCaptcha);
        
        if(ApexPages.hasMessages())
        {
           return pageRedirect(Apexpages.currentPage(), false);
        }   
    }
    
    /*
        Check if contact is present in DB
    */
    
    conExisting = getContactFromEmail(con.email, siteProperty.ACCOUNT_ID);
    if(conExisting <> null)
    {
        /*
            Store SF id of existing contact, this will be used to create registration record
        */
        contactId = conExisting.Id;
        con.Id =  conExisting.Id;
        /*
            Check if registrtaion is present in DB
        */
        regExisting = getRegistrationFromEventIdContactId(siteProperty.EVENT_ID,conExisting.id); 
        if(regExisting != null)
        {
            reg.Id = regExisting.Id;
        }
    }
   
   /*
        If user is not going to attend event -
            1) Check if contact is present in DB
            2) If not, create new one
            3) Upsert registrtaion record
            4) After success, redirect user to passed page url.
    */
    
    if(notAttendingSuccessPage != null && reg.Attending_Event__c == 'No')
    {
        
        if(isContactPrePopulated)
        {
            if(conExisting == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, EMAIL_BLACK_OR_WHITELIST_ERROR_MESSAGE));
                return null;
            }  
        }
        if(conExisting == null)
        {
            conExisting = createContactV1(siteProperty.ACCOUNT_ID, con);
        }
        
        createRegistrationV1(siteProperty.EVENT_ID, conExisting, reg, Userinfo.getUserId(), 'Declined', siteProperty.NAME_PREFIX);
            
        PageReference pg = notAttendingSuccessPage;          
        pg.getParameters().put('cid',encode(conExisting.Id));
        return pageRedirect(pg, true);
    }
    
    /*
        For some programs, we must have contact record pre-populated in SF DB.
        If contact record is not present, throw error.
    */
    if(isContactPrePopulated)
    {
        if(conExisting == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, EMAIL_BLACK_OR_WHITELIST_ERROR_MESSAGE));
            return null;
        }   
        else
        {
            con = conExisting;
        }
    }
    
    if(createPortalUser)
    {
        /*
            Create portal user.
        */
        try
        {
            system.debug('Calling Create user');
            // Create a savepoint Before User creation.
            sp = Database.setSavepoint();
            userId = createUserV1(siteProperty.ACCOUNT_ID, con, regPassword, siteProperty.SITE_USER_SUFFIX);
            System.Debug('---userId :'+userId);
            
            
            if(ApexPages.hasMessages())
            {
                Database.rollback(sp);
                //if any error occur make contact id as null..
                //In order to avoid this error system.security.NoAccessException: Update access denied for Contact we make contact id null ..
                if(con.id != null)
                    con.id = null; 
                //if(conExisting.id!=null)
                    //conExisting.id = null;
                    
            }
        }
        catch(Exception e)
        {
            // Rollback User creation.
            Database.rollback(sp);
            system.debug('Error while creating user - ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.EEG_Registration_Error));
            return null;
        }   
    }
    else
    {
        userId = UserInfo.getUserId();
        conExisting = createContactV1(siteProperty.ACCOUNT_ID, con);
        /*if(conExisting == null)
        {
            conExisting = createContactV1(siteProperty.ACCOUNT_ID, con);
        }*/ 
    }
    
    
    
    if(contactId == null && userId != null)
    {
        contactId = getPortalUserContactId(userId);
        con = getContactFromEmail(con.email, siteProperty.ACCOUNT_ID);
        
    }
    

    /*
        If registration record is not present in DB, create new one.
        If present, update existing.
    */ 
    
    if(userId != null)
    {
        try
        {
            System.Debug('---userId :'+userId); 
            createRegistrationV1(siteProperty.EVENT_ID, con, reg, userId, 'Saved for Later', siteProperty.NAME_PREFIX);
            
            return null;
        }
        catch(Exception e)
        {
            // Rollback User and Registration creation.
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.EEG_Registration_Error));
            return null;
        }   
    }
    else
    {
         return null;
    }
      
 }
 /**
    METHOD NAME :   processPayPalPayment
    This reusable method is used to process paypal payment  
 */
 public boolean processPayPalPayment(Registration__c reg, Payment__c payment, boolean processPaypal)
 {
    EEG_PaypalProcessorWebservice.TransactionOutputDetails transactionOutputDetails;
    boolean insertPaypalTransactionHistory = false;
    
    boolean refundCredit = false;
    Event_Header__c event = getEventInfo(reg.Event__c);
    if(event != null){
        refundCredit = event.Process_Credit_Refund_Using_Paypal__c;
    } 

    
    if(processPaypal)
    {
        transactionOutputDetails = paypalPalProcessOnline(payment,refundCredit); 
        if(transactionOutputDetails <> null)
        {
            insertPaypalTransactionHistory = true;
            boolean paypalResult = isPaymentProcessed(transactionOutputDetails);
            if(!paypalResult)
            {
                return false;
            }
            else
            {
                payment.Amount_Charged__c = payment.Amount__c;  
            }       
        }
    }
    if(payment.Id <> null)
    {
        insertPaypalTransactionHistory = false;
    }
    upsert payment;
    if(insertPaypalTransactionHistory)
    {
        createPaypalTransactionHistory(reg,payment,transactionOutputDetails);
    }
    return true;
 }
 /**
    METHOD NAME :   processPayPalPaymentMultiCurrency
    This reusable method is used to process paypal payment using  Amount__c/ConversionRate__c OR pay.Amount_Due_in_USD__c.
 */
 public boolean processPayPalPaymentMultiCurrency(Registration__c reg, Payment__c payment, boolean processPaypal)
 {
    EEG_PaypalProcessorWebservice.TransactionOutputDetails transactionOutputDetails;
    boolean insertPaypalTransactionHistory = false;
    
    boolean refundCredit = false;
    Event_Header__c event = getEventInfo(reg.Event__c);
    if(event != null){
        refundCredit = event.Process_Credit_Refund_Using_Paypal__c;
    } 
    
    if(processPaypal)
    {
        transactionOutputDetails = paypalPalProcessOnlineMultiCurrency(payment,refundCredit); 
        if(transactionOutputDetails <> null)
        {
            insertPaypalTransactionHistory = true;
            boolean paypalResult = isPaymentProcessed(transactionOutputDetails);
            if(!paypalResult)
            {
                return false;
            }
            else
            {
                payment.Amount_Charged__c = payment.Amount__c;  
            }       
        }
    }
    if(payment.Id <> null)
    {
        insertPaypalTransactionHistory = false;
    }
    upsert payment;
    if(insertPaypalTransactionHistory)
    {
        createPaypalTransactionHistorytMultiCurrency(reg,payment,transactionOutputDetails);
    }
    return true;
 }
 /**
    CLASS NAME :    ProductInvoiceClass
    This class is used to store variables necessary for creating Opportunity Line Items & total amount, generally used on payment page.     
 */
 public class ProductInvoiceClass
 {
    public List<EEG_RegistrationUtility.OppLineItem> optlineItems {get;set;}
    public Decimal totalAmount {get;set;}
    public Map<String,OpportunityLineItem> prodOppLineItemMap {get;set;}
    public Map<String,OpportunityLineItem> newProdOppLineItemMap {get;set;}
    
    public ProductInvoiceClass()
    {
        List<EEG_RegistrationUtility.OppLineItem> optlineItems = new List<EEG_RegistrationUtility.OppLineItem>();
        Decimal totalAmount=0;
        Map<String,OpportunityLineItem> prodOppLineItemMap = new Map<String,OpportunityLineItem>();
        Map<String,OpportunityLineItem> newProdOppLineItemMap = new Map<String,OpportunityLineItem>();  
    }
 }
 
 /**
    METHOD NAME :   updateInvoice
    This reusable method will create necessary Opportunity Line Item records.   
 */
 public ProductInvoiceClass updateInvoice(String regId, String attendeeType, String confType, EEG_SiteProperties siteProperty, List<String> applicableProducts,String currencyIsoCode)
 {
    ProductInvoiceClass productInvoice = new ProductInvoiceClass();
    
    List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
    List<OpportunityLineItem> existingOptlineItemRecords = new List<OpportunityLineItem>();
    List<Opportunity> opptys;
    Boolean createRegistrationOppLI = false;
    productInvoice.prodOppLineItemMap = new Map<String,OpportunityLineItem>();
    productInvoice.newProdOppLineItemMap = new Map<String,OpportunityLineItem>();
    
    // Retrieve existing opprtunity LineItems
    try
    {
        opptys = [Select Id,Registration__c from Opportunity where Registration__c = : regId];
        if(opptys.size()>0)
        {
            productInvoice.prodOppLineItemMap = getExisitingOppLineItem(opptys[0].Id);
            
            if(getExisitingOppLineItem(opptys[0].Id,'Registration').size() == 0)
            {
                createRegistrationOppLI = true;
            }
        }
        else
        {
            createRegistrationOppLI = true;
        }
    }
    catch(Exception e){}
            
    // If LineItem with ProductType == 'Registration' is not present, then create new one
    
    if(createRegistrationOppLI)
    {
        oppLineItems = createOpportunityLineItemListV3(siteProperty.EVENT_ID,siteProperty.PRICEBOOK_NAME,attendeeType,confType,null,'Registration',currencyIsoCode);
    }
    else
    {
        oppLineItems = new List<OpportunityLineItem>(); 
    }
    
            
    System.debug('============= oppLineItems '+oppLineItems);
        
    oppLineItems.addAll(createOpportunityLineItemListV3(siteProperty.EVENT_ID,siteProperty.PRICEBOOK_NAME,attendeeType,confType,applicableProducts,'Workshop',currencyIsoCode));
    oppLineItems.addAll(createOpportunityLineItemListV3(siteProperty.EVENT_ID,siteProperty.PRICEBOOK_NAME,attendeeType,confType,applicableProducts,'Guest Event',currencyIsoCode));
    oppLineItems.addAll(createOpportunityLineItemListV3(siteProperty.EVENT_ID,siteProperty.PRICEBOOK_NAME,attendeeType,confType,applicableProducts,'PromoCode',currencyIsoCode));
    
    
    System.debug('============= oppLineItems '+oppLineItems);
    productInvoice.newProdOppLineItemMap = createMapOfLineItem(oppLineItems);
    productInvoice.optlineItems = getProducts(getEffectiveOppLineItems(productInvoice.prodOppLineItemMap, productInvoice.newProdOppLineItemMap));
    productInvoice.optlineItems = processPromoCode(productInvoice.optlineItems);
    productInvoice.totalamount = getTotalAmount(productInvoice.optlineItems);
    
    return productInvoice;
 }
 /**
    METHOD NAME :   createDeleteOpportunityLineItems
    This reusable method will create or delete Opportunity Line Item records created using updateInvoice method.    
 */
 public void createDeleteOpportunityLineItems(ProductInvoiceClass productInvoice, EEG_SiteProperties siteProperty, Contact con, Registration__c reg, Opportunity opp)
 { 
    List<OpportunityLineItem> upsertLineItem = new List<OpportunityLineItem>();
    
    if(opp == null)
    {
        opp = createOpportunity(siteProperty.EVENT_ID, siteProperty.ACCOUNT_ID, reg.id, siteProperty.NAME_PREFIX, null, siteProperty.PRICEBOOK_NAME,con.FirstName,con.LastName);
    }
    
    for(OppLineItem opLi : productInvoice.optlineItems)
    {
        upsertLineItem.add(opLi.opLine);
    }
    upsertOpportunityLineItems(opp,upsertLineItem);
    
    List<OpportunityLineItem> deleteOppLIList = getOppLineItemsForDelete(productInvoice.prodOppLineItemMap, productInvoice.newProdOppLineItemMap);
    
    if(deleteOppLIList.size() > 0)
    {
        Database.delete(deleteOppLIList,false);
    }
 }
 
 public String getReferredByNameForEmailDomain(String eventId, String attendeeType, String userName)
 {
    if(isValidText(eventId) && isValidText(attendeeType) && isValidText(userName))
    {
        String emailDomain = userName.split('@').get(1);
        List<Event_Attendee_Type_Configuration__c>  attendeeConfigList = [SELECT Id,Referred_By__c FROM Event_Attendee_Type_Configuration__c WHERE Event__c =: eventId AND Attendee_Type__c =: attendeeType AND Company_Name__c =: emailDomain limit 1];
        if(attendeeConfigList.size() != 0)
        {
            return attendeeConfigList.get(0).Referred_By__c;
        }
        else
            return null;
    }
    else
    return null;
 }
 
 public List<PricebookEntry> getAllPriceBookEntries(Set<Id> productIds,String PricebookName) 
 {
    List<PricebookEntry> allPricebookEntries;
    if(isValidText(PricebookName) && productIds != null && productIds.size() > 0) {
        allPricebookEntries = [Select unitprice,Product2Id from PricebookEntry where Product2Id IN:productIds AND Pricebook2.Name=:PricebookName];
        return allPricebookEntries;
    }
    else {
        return null;
    }
 }
 
 /*
 Method Name: getSFDCPortalUserNameUsingExternalUserName
 Description: Used to get SFDC user name using External user name.
 */
 public String getSFDCPortalUserNameUsingExternalUserName(String accountId, String externalUserName) 
 {
    if(isValidText(accountId) && isValidText(externalUserName)) 
    {
        List<User> userList = [SELECT Id, UserName FROM User WHERE Contact.AccountId =: accountId AND External_User_Name__c =: externalUserName];
        if(userList.size() != 0)
        return userList[0].UserName;
        else
        return null;
    }
    else 
    {
        return null;
    }
 }
 
 /*
 Method Name: getSFDCPortalUserUsingUserNameOrExternalUserName
 Description: Used to get SFDC user name using External user name.
 */
 public User getSFDCPortalUserUsingUserNameOrExternalUserName(String accountId, String userNameOrExternalUserName, String programUserSuffix) 
 {
    if(isValidText(accountId) && isValidText(userNameOrExternalUserName) && isValidText(programUserSuffix)) 
    {
        String sfdcUserName = getUserName(userNameOrExternalUserName.trim(), programUserSuffix);
        List<User> userList = [SELECT Id, UserName, External_User_Name__c FROM User WHERE Contact.AccountId =: accountId AND (UserName =: sfdcUserName OR External_User_Name__c =: userNameOrExternalUserName)];
        if(userList.size() != 0)
        return userList[0];
        else
        return null;
    }
    else 
    {
        return null;
    }
 }
 
 /*
 Method Name: getProductAttendeeType
 Description: This method returns the Attendee type of Product whose promocode is passed as parameter
 */
 
 public String getProductAttendeeType(String eventId, String productCode)
 {
    List<Product2> ProductList = new List<Product2>();
    if(isValidText(eventId) && isValidText(productCode))
    {
        ProductList = [select id,Attendee_Type__c from Product2 where ProductCode =: productCode AND Product_Type__c=:'PromoCode' 
                       AND Event__c=: eventId AND isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE'];
    }
    if(ProductList != null && ProductList.size() > 0) 
    {
        return ProductList[0].Attendee_Type__c;
    }
    else 
    {
        return null;
    }
 }
 
 
 /**
    CLASS NAME :    ProductWrapperClass
    This class is used to store variables related to products which will be displayed on page for user selection.   
 */
 public class ProductWrapperClass implements Comparable
 {
    public Product2 product{get;set;}
    public boolean selected {get;set;}
    public String productName{get;set;}
    public integer count{get;set;}
    public String productDescription{get;set;}
    public decimal Price{get;set;}
    public Integer sortOrder {get;set;}
    public Boolean readOnly {get;set;}
    public Boolean isDropDown {get;set;}
    public List<SelectOption> dropdownValues {get;set;}
    public String selectedDropdownValue {get;set;}
    
    public ProductWrapperClass(Product2 p) 
    {
        system.debug('~~~~~~~~~~~~~~p'+ p );
        product = p;
        selected = false;
        selectedDropdownValue = 'No';
        productName = p.Name;
        productDescription = p.Description;
        count = this.count;
        System.debug('--->>> count'+ count);
        if(p.Order_Of_Display__c!=null)
            this.sortOrder = Integer.valueof(p.Order_Of_Display__c);
        else
            this.sortOrder = 0;
        
        dropdownValues = new List<SelectOption>();
        dropdownValues.add(new SelectOption('','--None--'));
        dropdownValues.add(new SelectOption('Yes','Yes'));
        dropdownValues.add(new SelectOption('No','No'));
        
    }
    
    public ProductWrapperClass(Product2 p,integer cnt) 
    {
        system.debug('~~~~~~~~~~~~~~p'+ p );
        product = p;
        selected = true;
        selectedDropdownValue = 'Yes';
        productName = p.Name;
        productDescription = p.Description;
        count = cnt;
        System.debug('--->>> count'+ count);
        if(p.Order_Of_Display__c!=null)
            this.sortOrder = Integer.valueof(p.Order_Of_Display__c);
        else
            this.sortOrder = 0;
            
        dropdownValues = new List<SelectOption>();
        dropdownValues.add(new SelectOption('','--None--'));
        dropdownValues.add(new SelectOption('Yes','Yes'));
        dropdownValues.add(new SelectOption('No','No'));            
    }
    
    public Integer compareTo(Object o2)
    {
        if(sortOrder < ((ProductWrapperClass)o2).sortOrder)
        {
            return -1;
        }
        else if(sortOrder > ((ProductWrapperClass)o2).sortOrder)
        {
            return 1;
        }
        else
            return 0;
    }
 }
 
 public List<ProductWrapperClass> makeProductWrapperReadOnly(List<ProductWrapperClass> products, String productType)
 {
    if(products != null)
    {
        for(ProductWrapperClass prod : products)
        {
            if(prod.product.Product_Type__c == productType)
            {
                prod.readOnly = true;
                prod.selected = true;
            }
        }   
    }
    return products;
 }
 public List<ProductWrapperClass> makeProductWrapperDropDown(List<ProductWrapperClass> products, String productType)
 {
    if(products != null)
    {
        for(ProductWrapperClass prod : products)
        {
            if(prod.product.Product_Type__c == productType)
            {
                prod.isDropDown = true;
            }
        }   
    }
    return products;
 }
 /*
    CLASS NAME-:DropdownWrapperClass
    wrapper class use to create radio buttons,checkboxes of multiselect fields..
 */
 public class DropdownWrapperClass
    {
        public String eventName{get;set;}
        public String eventLabel{get;set;}
        public List<SelectOption> dropdownValues {get;set;}
        public String selectedDropdownValue {get;set;}
        public Integer sortOrder {get;set;}
        public DropdownWrapperClass(String eventName, String label, String defaultVal)
        {
            dropdownValues = new List<SelectOption>();
            dropdownValues.add(new SelectOption('','--None--'));
            dropdownValues.add(new SelectOption('Yes','Yes'));
            dropdownValues.add(new SelectOption('No','No'));
            this.eventName = eventName;
            this.eventLabel = label;
            this.selectedDropdownValue = defaultVal;
        }
    }
 /*
    Reusable method-:makes set of string from field value..
 */ 
 public Set<String> getStoredValuesSet(String fieldVal)
 {
    Set<String> storedValues = new Set<String>();
    if(fieldVal != null)
    {
        List<String> storedValuesList = new List<String>();
        storedValuesList = fieldVal.split(';');
        storedValues.addAll(storedValuesList);  
    }
    return storedValues;
 }
 
 /*
    Reusable method-: for creating list of DropdownWrapperClass.
 */
 public List<DropdownWrapperClass> createWrapperList(Map<String,String> mapOfValueLabel, Set<String> storedValues, String defaultVal)
 {
    List<DropdownWrapperClass> eventWrapperList = new List<DropdownWrapperClass>();
    
    for(String event : mapOfValueLabel.keySet())
    {
        if(storedValues != null && storedValues.size() > 0)
        {
            if(storedValues.contains(event))
            {
                eventWrapperList.add(new DropdownWrapperClass(event,mapOfValueLabel.get(event),'Yes'));
            }
            else
            {
                eventWrapperList.add(new DropdownWrapperClass(event,mapOfValueLabel.get(event),defaultVal));
            }   
        }
        else
        {
            eventWrapperList.add(new DropdownWrapperClass(event,mapOfValueLabel.get(event),defaultVal));
        }
    }
    //eventWrapperList.sort();
    return eventWrapperList;
 }
 /*
    Reusable method use to get selected values from wrapper class list..
 */
 public List<String> getSelectedDropdoenValues(List<DropdownWrapperClass> eventlist)
 {
    List<String> selectList = new List<String>();
    for(DropdownWrapperClass event : eventlist)
    {
        if(event.selectedDropdownValue == 'Yes')
        {
            selectList.add(event.eventName);
        }
    }
    return selectList;
 }
 /*
    Reusable method use to get default value from fieldvalue.
 */
 public String getDefaultValue(Boolean fieldVal)
 {
    if(fieldVal)
    {
        return 'No';
    } 
    else
    {
        return null;
    }
 }  
 
 // Reusable method which returns the Registration Group whose Comany name = passed parameter string 
 public Registration_Group__c getRegistrationGroupFromName(String eventId,String companyName) 
 {
    List<Registration_Group__c> lstRegistrationGroup;
    if(isValidText(eventId) && isValidText(companyName))
    {
        lstRegistrationGroup = [Select Name,Company_URL__c,Booth_Sponsorship_Level__c,Business_Address_Line1__c,Exhibitor_Level__c,
                    Business_Address_Line2__c,Business_City__c,Company_Name__c,Business_Zip_Code__c,Business_Country__c,Business_State__c,
                    Company_Description__c,Reference_Number__c  from Registration_Group__c 
                    where Event__c =: eventId AND Company_Name__c = : companyName]; 
        system.debug('-------lstRegistrationGroup:  '+lstRegistrationGroup); 
    }
    
    if(lstRegistrationGroup!=null && lstRegistrationGroup.size()>0)
    {
        return lstRegistrationGroup[0]; 
    }
    else 
    {
        return null;
    }
 }
 
 // Reusable method that creates Registration Group Record
 public Registration_Group__c createRegistrationGroup(Registration_Group__c RegGroup, string eventId)
 {
     if(isValidText(eventId) && RegGroup!=null)
     {
         RegGroup.Event__c = eventId;
         insert RegGroup;
         return RegGroup;
     }
     else 
     {
         return null;
     }
 }
 
 // Reusable method that creates registration group member record
 public Registration_Group_Member__c createRegistrationGroupMember(string regID,String regGrpID)
 {
     
     Registration_Group_Member__c regGroupMember;
     
     if(isValidText(regID) && isValidText(regGrpID))
     {
         regGroupMember = new Registration_Group_Member__c();
         regGroupMember.Registration__c = regID;
         regGroupMember.Registration_Group__c = regGrpID;
         upsert regGroupMember;
         system.debug('-------regGroupMember:  '+regGroupMember);
         return regGroupMember;
     }
     else
         return null;
 }
 /*
    Reusable method for getting event country setting..
 */
 public Event_Country_Settings__c getEventCountrySetting(String eventId,String country){
    if(isValidText(eventId) && isValidText(country)){
        List<Event_Country_Settings__c> eventCountrySetting = [Select country__c,CurrencyIsoCode 
                from Event_Country_Settings__c where Event__c=:eventId AND country__c=:country];
        if(eventCountrySetting.size()>0)
         return eventCountrySetting.get(0);
        else
         return null;
    }
    return null;                                                                                                                                           
 }
 
 /*
    Reusable method for getting event country Currency setting..
    Return USD if settings not found for the given country.
 */
 public String getEventCountryCurrencySetting(String eventId,String country){
    System.debug('eventId  ===>>> '+eventId);
    System.debug('country  ===>>> '+country);
    if(isValidText(eventId) && isValidText(country)){
        List<Event_Country_Settings__c> eventCountrySetting = [Select country__c,CurrencyIsoCode 
                from Event_Country_Settings__c where Event__c=:eventId AND country__c=:country];
        
        System.debug('eventCountrySetting  ===>>> '+eventCountrySetting);
        
        if(eventCountrySetting.size()>0)
         return eventCountrySetting[0].CurrencyIsoCode;
        else
         return 'USD';
    }
    return 'USD';                                                                                                                                           
 }
 
 
     // Returns Product list for perticular Registration group passed as parameter
     public List<Product2> getProductRegistrationGroup(string ProductType, string registrationGroupID, string eventID) 
    {
        List<Product2> ProductList = new List<Product2>();
        System.debug('-------- registrationGroupID'+registrationGroupID);
        System.debug('-------- ProductType'+ProductType);
        System.debug('-------- eventID'+eventID);
        if(isValidText(registrationGroupID) && isValidText(ProductType) && isValidText(eventID))
        {
            ProductList = [select id, Name,Product_Type__c,Product_Sub_Type__c,Event__c,Product_Size__c,Description,Order_Of_Display__c from Product2 where Product_Type__c=:ProductType
                      AND Registration_Group__c =:registrationGroupID  AND Event__c=: eventID AND isActive =: true AND isCurrentActiveRegPrd__c =: 'true'];
            System.debug('-------- ProductList'+ProductList);
            
        }
        if(ProductList != null && ProductList.size() > 0) 
        {
            return ProductList; 
        }
        else
            return null;
    }      
   
   // This method validates the attachments for valid types and size passed as a parameter.
   public boolean validateAttachment(Attachment att, List<String> allowedFileTypeList, integer allowedBodyLenght,String fileTypeErrorMsg,String fileSizeErrorMsg) 
   {
        boolean validFileType;
        boolean validFileSize;
        String fileTypeErrMsg = System.Label.EEG_File_type_is_not_Supported;
        String fileSizeErrMsg = System.Label.EEG_File_size_is_larger_than_5_MB;
        
        if(isvalidtext(fileTypeErrorMsg))
            fileTypeErrMsg = fileTypeErrorMsg;
        if(isvalidtext(fileSizeErrorMsg))
            fileSizeErrMsg = fileSizeErrorMsg; 
        /*String[] allowedFileTypeList;
        Event_Header__c event;
                
        if(eventID != null) 
        {
            event = getEventInfo(eventID);
            if(event != null && event.ERC_Attachment_Allowed_File_Types__c != null)
            allowedFileTypeList = event.ERC_Attachment_Allowed_File_Types__c.split(';');
            
        }*/
        
        if(att.Name == null && att.Body == null) 
        {
            return false;
        }
        
        // Validating File types
        if(allowedFileTypeList != null && allowedFileTypeList.size() != 0)
        {
            //if(allowedFileTypeList.contains(att.contentType))
            for(String allowedFileType : allowedFileTypeList) 
            {
                System.debug('---->>allowedFileType '+allowedFileType );
                System.debug('---->>content Type '+att.contentType.toLowercase());
                if((att.contentType.toLowercase()).contains(allowedFileType.toLowercase()))
                {
                    validFileType = true;
                    break;
                }
            }
            if (validFileType != true)
            {
                validFileType = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, fileTypeErrMsg));
                System.debug('---->>Error in Type validation, return null');
            }
        }
        // Validating File size
        if(allowedBodyLenght  != null)
        {
            if(att.BodyLength <= allowedBodyLenght )
            {
                validFileSize = true;
            }
            else 
            {
                validFileSize = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, fileSizeErrMsg));
                System.debug('---->>Error in Size validation, return null');
                
            }
        }
       
        if(ApexPages.hasMessages())
        {
            System.debug('---->>Error in validation, return null');
            return false;
        }
        else
            return true;
  }
  
  //Returns Current Conversion Rate for the given CurrencyISOCode
  public decimal getConversionRateFromCurrencyIsoCode(String currencyIsoCode)
  {
    if(isValidtext(currencyIsoCode))
    {
        List<CurrencyType> ct = [Select IsoCode,ConversionRate From CurrencyType Where IsActive = true AND IsoCode=:currencyIsoCode];
        if(ct.size()>0)
        {
            return round(ct[0].ConversionRate);
        }
    }
    return 1.0; 
  }
  
  // Reusable method to prepoluate Emergency contact details from Contact to Guest Contact object.
  public Contact populateEmergencyContactDetailsForGuest(Contact con, Contact guestConObj)
  {
    if(con.Is_Emergency_Info_Same__c == true && con!=null)
    {
          guestConObj.Emergency_Contact_Name__c = con.Emergency_Contact_Name__c;
          guestConObj.Emergency_Contact_Phone_Number__c = con.Emergency_Contact_Phone_Number__c;
          guestConObj.Emergency_Contact_Relationship__c = con.Emergency_Contact_Relationship__c;
      }
      else 
      {
          guestConObj.Emergency_Contact_Name__c = '';
          guestConObj.Emergency_Contact_Phone_Number__c = '';
          guestConObj.Emergency_Contact_Relationship__c = '';
      }
      return guestConObj; 
  }
  
  public Event_Attendee_Type_Configuration__c getEventAttendeeTypeConfiguration(String eventId, String attendeeType, String userName,boolean isEmailDomain) 
  {
    if(isValidText(eventId) && isValidText(userName) && isValidText(attendeeType))
    {
        String emailOrEmailDomain;
        if(isEmailDomain && userName.contains('@') && userName.split('@').size() >1)
        {
            emailOrEmailDomain = userName.split('@').get(1);
        }
        else
        {
            emailOrEmailDomain = userName;  
        }
        List<Event_Attendee_Type_Configuration__c>  attendeeConfigList = [SELECT Id,Referred_By__c,Referred_By_Role__c FROM Event_Attendee_Type_Configuration__c WHERE Event__c =: eventId AND Attendee_Type__c =: attendeeType AND Email_Email_domain__c =: emailOrEmailDomain  limit 1];
        if(attendeeConfigList.size() != 0)
            return attendeeConfigList[0];
        else
            return null;
    }
    else
        return null;
  }  
    
  
  // Gets referral contact details for Refer a Friend Page.
  public contact getReferralContactDetails(Contact conReferredBy, string accountId)
  {
        Contact conReferral;
        List<Contact_Referral__c> conReferralList = new List<Contact_Referral__c>();
        if(conReferredBy !=null && accountId !=null ) {
            if(conReferredBy != null)
            conReferralList = [select id,Referred_Contact__c,Referred_Contact__r.Email FROM Contact_Referral__c WHERE Referred_By__c =: conReferredBy.id];
        
            if(conReferralList != null && conReferralList.size() >0 ){
                
                conReferral = getContactFromId(conReferralList[0].Referred_Contact__c, accountId);
                System.debug('-------- conReferral :'+conReferral);
            }
        }       
        return conReferral;
    }
    
    /*
        This method will return TRUE if the person is already referred by the same Person.
        
 */
    public boolean isContactReferralExist(String accountId, Contact referredByContact, Contact_Referral__c conRef)
    {
        if(isValidText(accountId) && referredByContact != null && conRef != null)
        {
            for(Contact_Referral__c CR : [SELECT Id FROM Contact_Referral__c WHERE Referred_By__r.AccountId =: accountId AND Referred_By__r.Email =: referredByContact.Email AND Email__c =: conRef.Email__c limit 1])
            {
                return true;
            }
        }
        return false;
    }
    
    // Create Contact Referral record for given contacts. Used in refer a friend functionality 
    public boolean submitReferral( Contact conReferredBy, Contact_Referral__c conRef, String accountId, string eventId,String source)
    {
        //Contact_Referral__c objCR = new Contact_Referral__c();
        /*
            Here we have changed logic.we are not using referred contact anymore as we got "inactive user error while creating contact"
            so intead of using referred contact use contact referral..and fields from contact referral object.. 
        */
        boolean isSuccess = false;
            
        try 
        {   
            if(isValidText(accountId) && isValidText(eventId) && conReferredBy != null && conRef != null && conReferredBy.email != null && conRef.Email__c != null)
            {
                
               boolean alreadyReferred = isContactReferralExist(accountId, conReferredBy, conRef);
               if(!alreadyReferred) 
               {
                    Contact existingConReferredBy = getContactFromEmail(conReferredBy.email,accountId);
                    
                    if(existingConReferredBy == null) 
                    {
                        conReferredBy.AccountId = accountId;
                        upsert conReferredBy;
                    }
                    else
                    {
                        conReferredBy.id = existingConReferredBy.id;
                    }
                    
                    /*
                        Here we have changed logic.we are not using referred contact anymore as we got "inactive user error while creating contact"
                        so intead of using referred contact use contact referral..and fields from contact referral object.. 
                    */
        
                    /*Contact existingConReferral = getContactFromEmail(conReferral.email,accountId);
                    System.debug('-------- existingConReferral :'+existingConReferral);
                    
                    if(existingConReferral == null) 
                    {
                        conReferral.AccountId = accountId;
                        upsert conReferral;
                    }
                    else
                    {
                        conReferral.id = existingConReferral.id;
                    }*/
                    
                    conRef.Referred_By__c = conReferredBy.id;
                    //objCR.Referred_Contact__c = conReferral.id;
                    conRef.Event__c = eventId;
                    if(isValidText(source))
                    conRef.Source__c = source;
                  
                    upsert conRef;
                    
                    isSuccess = true;
               }
               else
                isSuccess = true;
            }
           
        }
        catch(exception e) 
        { 
            isSuccess = false;
        }   
            
            return isSuccess;
    }
    /*
    Method Name: fetchRegAndcheckIfDeclined
    Description: Used to check whether registration is Declined.if Declined throw an error message.
    */
    public boolean fetchRegAndcheckIfDeclined(String eventId,String email)
    {
        boolean isRegDeclined = false;
        if(isValidText(email) && isValidText(eventId))
        {
            List<Registration__c> regList = [Select id, Status__c, Will_You_Need_Hotel_Accommodations__c From Registration__c Where Event__c =: eventId AND Registrant__r.Email =:email];
            if(regList.size() > 0)
            {
                Registration__c fetchRegistrationBeforeLogin = regList.get(0);
                
                if(isValidText(fetchRegistrationBeforeLogin.Status__c) && fetchRegistrationBeforeLogin.Status__c.equalsIgnoreCase('Declined'))
                {
                    isRegDeclined = true;
                }
            }   
        }
        return isRegDeclined;
    }
    
    /*
    Method Name: getRegGroupFromRegistration
    Description: Used to get registration group record related to particular registration.
    */
    
    public Registration_Group__c getRegGroupFromRegistration(String registrationId){
        if(isValidText(registrationId)){
            List<Registration_Group__c> lstRegistrationGroup = [Select Id,Name,Group_Registration_Admin__r.registrant__r.email from Registration_Group__c where Group_Registration_Admin__c =: registrationId];
            if(lstRegistrationGroup.size()>0){
                return lstRegistrationGroup.get(0);
            }
            else
                return null;
        }
        else                                 
        return null;
    }
    
    /*
    Method Name: getAllGroupRegList
    Description: Used to get all registrations from registration group.
    */
    
    public List<Registration__c> getAllGroupRegList(String registrationGroupId,String registrationId,boolean includeLoggedInUserRegistration){
        Set<ID> regIds = new Set<ID>();
        Set<ID> loggedInRegId = new Set<ID>();
        List<Registration__c> allGroupRegList = new List<Registration__c>();
        
        if(registrationId != null)
            loggedInRegId.add(registrationId);  
        
        if(isValidText(registrationGroupId))
        {
            List<Registration_Group_Member__c> regGrpMemList = getAllRegGroupMembers(registrationGroupId);
            if(regGrpMemList.size()>0)
            {
                for(Registration_Group_Member__c RGM : regGrpMemList) 
                {
                    regIds.add(RGM.Registration__c);
                }   
            } 
        }
        if(regIds!=null && regIds.size()>0) 
        {
                allGroupRegList = getGroupMamberRegistrations(regIds,loggedInRegId, includeLoggedInUserRegistration);
        }
        return allGroupRegList;
    }
    
    public List<Registration__c> getContactSharedParticipantList(String eventId){
        system.debug('ttttttt'+isValidText(eventId));
        if(isValidText(eventId)) 
        {            
            List<Registration__c> shareParticipantList = [ Select Id, Event__c, Status__c, Registrant__c, 
                                                           Registrant__r.FirstName, Registrant__r.LastName, 
                                                           Registrant__r.Email, Registrant_Company_Name__c,
                                                           Share_Contact_Information__c,
                                                           Attendee_Type__c, Exhibitor_Level__c 
                                                           From Registration__c 
                                                           Where Event__c =: eventId
                                                           AND (Status__c = 'Registered' OR Status__c = 'Attended') 
                                                           AND Share_Contact_Information__c = 'Yes' AND is_test__c = false order by  Registrant__r.LastName, Registrant__r.FirstName
                                                         ];
            if(shareParticipantList.size() > 0)
                return shareParticipantList;
        }
       return null;
    }
    
    /*
        Method Name: getSalesRepDetails
        Description: This method provide the Referred Details to the Registration based upon the Promocode used.
    */
    
    public Event_Attendee_Type_Configuration__c getSalesRepDetails(String eventId, String attendeeType, String promoCode){
    if(isValidText(eventId) && isValidText(attendeeType) && isValidText(promoCode)){
        List<Event_Attendee_Type_Configuration__c>  attendeeConfigList = [ SELECT Id, Referred_By__c, Referred_By_Role__c,
                                                                           Referred_By_Geo__c, Referred_By_Manager_Name__c,
                                                                           Promocode__c, Attendee_Type__c, Event__c
                                                                           FROM Event_Attendee_Type_Configuration__c 
                                                                           WHERE Event__c =: eventId 
                                                                           AND Attendee_Type__c =: attendeeType 
                                                                           AND Promocode__c =: promoCode limit 1];
        if(attendeeConfigList.size() != 0)
            return attendeeConfigList[0];
        else
            return null;
    }
    else
        return null;
    }
    
    public Contact getContactFromExternalUserName(String externalUserName, String accountId){
        if(isValidText(externalUserName) && isValidText(accountId)) {   
            Contact con = new Contact();
            
            List<Contact> existingContacts = [ SELECT Email, Id, firstname, lastname, Company_Name__c, External_User_Name__c 
                                               FROM Contact 
                                               where External_User_Name__c =: externalUserName 
                                               and AccountId=: accountId limit 1];
            if(existingContacts.size() > 0) {
                con = existingContacts[0];
                return con;
            }                   
        }
        return null;
    }
    
         
     public List<String> getProductListFromSessions(List<Session_Participant__c> sessionParticipants, String eventId)
     {
        List<String> productCodeList = new List<String>();
        List<String> sessionExternalCodes = new List<String>();
        
        if(sessionParticipants.size() > 0)
        {
            for(Session_Participant__c sessionpart : sessionParticipants)
            {
                if(sessionpart.Session_Occurrence__r.External_Session_Code__c != null)
                {
                    sessionExternalCodes.add(sessionpart.Session_Occurrence__r.External_Session_Code__c);   
                }
            }   
            
            if(sessionExternalCodes.size() > 0)
            {
                List<Product2> prodList = [Select Id, ProductCode, Name FROM Product2 WHERE Event__c =: eventId AND External_Session_Code__c IN :sessionExternalCodes ];
                
                if(prodList.size() > 0)
                {
                    for(Product2 prod : prodList)
                    {
                        productCodeList.add(prod.Name);  
                    }
                }
            }
        }
        
        return productCodeList;
     }
    
    /*
    METHOD NAME-: removeNullValuesFromList()
    Input:
            1. inputlist - List of string.
            
    DESCRIPTION-: This method is used to remove null values from list of string. 
    */ 
    
    public List<String> removeNullValuesFromList(List<String> inputlist)
    {
        List<String> outputlist;
        
        if(inputlist != null && inputlist.size() > 0)
        {
            outputlist = new List<String>(); 
            for(String input : inputlist)
            {
                if(isValidText(input))
                    outputlist.add(input);
            }
        }
        return outputlist;
    }
    
    
    /*
    METHOD NAME-: checkProductCapacity()
    Input:
            1. eventId - Event Id.
            2. productType - Product Type.
            3. products - list of product names.
            
    DESCRIPTION-: This method will return the map of product name as key and product availability as value. 
    */ 
     
    public Map<String,boolean> checkProductCapacity(String eventId, String productType, List<String> products)
    {
        Map<String,boolean> productAvailabilityMap = new Map<String,boolean>();
        
        List<String> productlist = removeNullValuesFromList(products);
        
        Set<String> productSet = new Set<String>();
         
        if(isValidText(eventId) && productlist != null && productlist.size() > 0)
        {
            /*
                a. Add All product names into the productSet.
                b. If there are no opportunity line items available for the given product then return "TRUE"(Product hasn't reached the capacity) 
                c. If there are opportunity line items available for the given product then remove the name from the Set and compare the Product Size with Opportunity Line item count 
                   and return either "TRUE"(Product hasn't reached the capacity) or "FALSE" (Product has reached the capacity)
            */
            //a. Add All product names into the productSet.
            productSet.addAll(productlist);
            
            List<OpportunityLineItem>  opplineitemList = [SELECT Id,Product_Type__c,OpportunityId,product2.name,product2.Product_Size__c 
                                                         FROM OpportunityLineItem
                                                         WHERE OpportunityLineItem.Opportunity.Registration__r.Event__c =  :eventId
                                                         AND (Opportunity.Registration__r.Status__c = 'Registered' OR Opportunity.Registration__r.Status__c = 'Attended')
                                                         AND Opportunity.Registration__r.Is_test__c = false
                                                         AND Product2.Product_Type__c = :productType
                                                         AND Product2.name IN :productlist];
            
            if(opplineitemList.size() > 0)
            {
                Map<String,Integer> productUsedMap = new Map<String,Integer>();
                Map<String,Integer> productCapacityMap = new Map<String,Integer>();
                
                for(OpportunityLineItem oppLI : opplineitemList)
                {
                    /* c. If there are opportunity line items available for the given product then remove the name from the Set and compare the Product Size with Opportunity Line item count 
                       and return either "TRUE"(Product hasn't reached the capacity) or "FALSE" (Product has reached the capacity) */
                    productSet.remove(oppLI.Product2.name);
                    
                    /*
                        Iterate opportunity line items to get no of times product used 
                    */
                    Integer usedCount = productUsedMap.get(oppLI.Product2.name);
                    
                    if(usedCount == null)
                        usedCount = 0;
                    usedCount++;
                    productUsedMap.put(oppLI.Product2.name, usedCount);
                    
                    if(oppLI.Product2.Product_Size__c == null)
                        productCapacityMap.put(oppLI.Product2.name, Integer.valueOf(0));                                                        
                    productCapacityMap.put(oppLI.Product2.name, Integer.valueOf((oppLI.Product2.Product_Size__c)));
                }
                
                system.debug('*************productUsedMap.size()' + productUsedMap.size());
                system.debug('*************productUsedMap' + productUsedMap);
                system.debug('*************productCapacityMap.size()' + productCapacityMap.size());
                system.debug('*************productCapacityMap' + productCapacityMap);
                
                
                if(productUsedMap.size() > 0 && productCapacityMap.size() > 0)
                {
                    for(String product : productUsedMap.keyset())
                    {
                        if(productUsedMap.get(product) >= productCapacityMap.get(product))
                            productAvailabilityMap.put(product, false);
                        else
                            productAvailabilityMap.put(product, true);
                    }
                }
            }
            //b. If there are no opportunity line items available for the given product then return "TRUE"(Product hasn't reached the capacity)  
            for(String product : productSet)
            {
                productAvailabilityMap.put(product, true);
            }
            
        }
        return productAvailabilityMap;
    }
    
    /*
    METHOD NAME-: getValueFromMap()
    Input:
            1. keyToSearch - String for which value is needed.
            2. inputmap - .
            
    DESCRIPTION-: This method will return true if the value from <key,value> pair if  
    */
    public boolean getValueFromMap(String keyToSearch, Map<String,boolean> inputmap)
    {
        if(isValidText(keyToSearch) && inputmap.size() > 0)
        {
            for(String varkey : inputmap.keyset())
            {
                if(varkey.equalsIgnoreCase(keyToSearch))
                    return inputmap.get(varkey);
            }
        }
        
        return false;
    }
    
    /*public String getGiftCode(String eventId, String attendeeType, String preferredGiftCode)
    {
        System.debug('eventId ==> '+eventId);
        System.debug('attendeeType ==> '+attendeeType);
        
        List<String> statusList = new List<String>();
        statusList.add('Registered');
        statusList.add('Attended');
        
        List<Product2> productList;
        Map<String,Integer> giftCodeUsedCountMap = new Map<String,Integer>();
        
         
        try
        {
            if(preferredGiftCode != null)
            {
                productList = [SELECT Id, ProductCode, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND Product_Type__c =: 'GiftCode' and isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE' AND Attendee_Type__c includes (:attendeeType) AND (Product_Size__c =: null OR Product_Size__c > 0) AND ProductCode =: preferredGiftCode];
            }
            else
            {
                productList = [SELECT Id, ProductCode, Product_Size__c FROM Product2 WHERE Event__c =: eventId AND Product_Type__c =: 'GiftCode' and isActive =: true AND isCurrentActiveRegPrd__c = 'TRUE' AND Attendee_Type__c includes (:attendeeType) AND (Product_Size__c =: null OR Product_Size__c > 0)];    
            }
            system.debug('~~~~~~~~~~~~~~~~productList.size()' + productList.size());
            system.debug('~~~~~~~~~~~~~~~~productList' + productList); 
        
            if(productList.size() != 0)
            {
                List<AggregateResult> regRecords = [SELECT Gift_Card__c,count(Id) FROM Registration__c Where Event__c = :eventId  AND Attendee_Type__c = :attendeeType AND Status__c IN :statusList AND Gift_Card__c != null Group by Gift_Card__c];
                system.debug('~~~~~~~~~~~~~~~~regRecords.size()' + regRecords.size());
                system.debug('~~~~~~~~~~~~~~~~regRecords' + regRecords);
                
                for(AggregateResult ar : regRecords)
                {
                    giftCodeUsedCountMap.put(String.valueOf(ar.get('Gift_Card__c')), Integer.valueOf(ar.get('expr0')));
                }
                
                system.debug('~~~~~~~~~~~~~~~~giftCodeUsedCountMap' + giftCodeUsedCountMap);    
                
                for(Product2 productRecord : productList)
                {
                    
                    // If Gift Code is used for Registration...check the no. of Registrations using that Gift Code with Product Size
                    if(giftCodeUsedCountMap.containsKey(productRecord.ProductCode) &&  productRecord.Product_Size__c <= giftCodeUsedCountMap.get(productRecord.ProductCode))
                    {
                        continue;
                        
                    }
                    else
                    {
                        return productRecord.ProductCode;
                    }
                }
                
                return null;   
            }
            else
                return null;
        }
        catch(Exception e)
        {
            return null;
        }
        return null;
        
    }*/
    
    
 public void createReferralPromoCode(EEG_SiteProperties siteProperty, String promoCodeVal, String attendeeType, String confType, Decimal unitPrice, String discountType, Decimal discountValue, Integer productSize  )
 {
	List<PricebookEntry> pentryList = new List<PricebookEntry>();
	Product2 prod = new Product2();
	Product2 regProd = new Product2();
	try
	{
		if(isValidText(attendeeType) && isValidText(confType)){
            for(Product2 prd : [Select Id, Product_Type__c, Start_Date__c, End_Date__c  FROM Product2 WHERE Event__c =: siteProperty.EVENT_ID AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND Attendee_Type__c includes (:attendeeType) AND Conference_Type__c includes (:confType)
                                AND Product_Type__c= 'Registration' limit 1])
            {
                regProd = prd;
            }
        }
        else if(isValidText(attendeeType)){
            for(Product2 prd : [Select Id, Product_Type__c, Start_Date__c, End_Date__c FROM Product2 WHERE Event__c =: siteProperty.EVENT_ID AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND Attendee_Type__c includes (:attendeeType) AND Conference_Type__c = null
                                AND Product_Type__c= 'Registration' limit 1])
            {
                regProd = prd;
            }
        }
        else if(isValidText(confType)){
            for(Product2 prd : [Select Id, Product_Type__c, Start_Date__c, End_Date__c  FROM Product2 WHERE Event__c =: siteProperty.EVENT_ID AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE' AND Conference_Type__c includes (:confType) and Attendee_Type__c = null
                                AND Product_Type__c= 'Registration' limit 1])
            {
                regProd = prd;
            }
        }
        else {
            for(Product2 prd : [Select Id, Product_Type__c, Start_Date__c, End_Date__c FROM Product2 WHERE Event__c =: siteProperty.EVENT_ID AND isActive = true AND isCurrentActiveRegPrd__c = 'TRUE'
                                AND Product_Type__c= 'Registration' limit 1])
            {
                regProd = prd;
            }
        }
		
		List<Product2> productList = [SELECT Id, Name   FROM Product2 WHERE Event__c =: siteProperty.EVENT_ID AND ProductCode =: promoCodeVal.trim() and Product_Type__c =: 'PromoCode' and isActive =: true  AND Start_Date__c<=:regProd.Start_Date__c AND End_Date__c>=:regProd.End_Date__c AND Attendee_Type__c includes (:attendeeType) AND Conference_Type__c includes (:confType) AND isReferralCode__c =: true];
        if(productList.size()>0){
            system.debug('~~~~~~~~~~~~~ Product already exist.');
            return;
        }
        
		
		List<Pricebook2> stdPriceBookList = [select id from Pricebook2 where Name='Standard Price Book' limit 1];
		List<Pricebook2> eventPriceBookList = [select id from Pricebook2 where Name= :siteProperty.PRICEBOOK_NAME limit 1];
		prod.Name = siteProperty.NAME_PREFIX + ' - Registration Referral code';
		prod.Description = siteProperty.NAME_PREFIX + ' - Registration Referral code';
		prod.ProductCode = promoCodeVal;
		prod.Event__c = siteProperty.EVENT_ID;
	    prod.IsActive = true;
	    prod.Product_Type__c = 'PromoCode';
	    prod.product_size__c = productSize;
	    prod.Product_Size_Initial__c = productSize;
	    prod.isReferralCode__c = true;
	    
	    if(regProd != null)
	    {
	    	prod.Start_Date__c = regProd.Start_Date__c;
	    	prod.End_Date__c = regProd.End_Date__c;
	    }
	    
	    if(attendeeType != null)
	    	prod.Attendee_Type__c = attendeeType;
	    if(confType != null)
	    	prod.Conference_Type__c = confType; 
	    
	    prod.Discount_Type__c = discountType;
	    
	    if(discountType == 'Percentage')
	    {
	    	prod.Discount_Percentage__c = discountValue; 
	    }
	    else if(discountType == 'Amount')
	    {
	    	prod.Discount_Amount__c = discountValue;
	    } 
	    upsert prod;
	    
	    if(stdPriceBookList.size()>0)
	    {
			PricebookEntry pribookentry = new PricebookEntry();
	        pribookentry.Pricebook2Id = stdPriceBookList[0].id;
	        pribookentry.Product2Id = prod.id;
	        if(unitPrice != null)
	            pribookentry.UnitPrice = unitPrice;
	        else
	            pribookentry.UnitPrice = 0;
	        pribookentry.IsActive = true;
	        insert pribookentry;
	    
	        if(eventPriceBookList != null && eventPriceBookList.size() >0 )
	        {    
				pribookentry = new PricebookEntry();
	            pribookentry.Pricebook2Id = eventPriceBookList[0].Id;
	            pribookentry.Product2Id = prod.id;
	            if(unitPrice != null)
	                pribookentry.UnitPrice = unitPrice;
	            else
	                pribookentry.UnitPrice = 0;
	            pribookentry.IsActive = true;
	            insert pribookentry;
	        }   
	    }
	}
	catch(Exception e){}
 }
}