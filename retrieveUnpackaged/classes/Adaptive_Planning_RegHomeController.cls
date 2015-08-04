public without sharing class Adaptive_Planning_RegHomeController 
{
    public Contact con{get;set;}
    public Registration__c reg{get;set;}
    public EEG_RegistrationUtility eegRegistrationUtility;
    public Adaptive_Planning_Utility adaplanningUtility;
    public EEG_SiteProperties siteProperty;
    
    public String userName{get;set;}
    public String password{get;set;}
    public String regPassword{get;set;}
    public String regConfirmPassword{get;set;}
    public String promoCode{get;set;}
    public reCAPTCHA captcha{get;set;}
    public Boolean captchaResponse {get; private set;} { captchaResponse = false; }
    
     /*
        Change Password Method Variables START. 
    */ 
    public string newPassword {get;set;}
    public string verifyNewPassword {get;set;}
    public string oldpassword {get;set;}
    /*
        Change Password Method Variables END.
    */ 
    
    public boolean showRegister {get;set;}
    public boolean showLogin {get;set;}
    
    public String contactId {get;set;}
    
    String loginSuccessPageURL = (Page.Adaptive_Planning_WPF_RegPageOne).getUrl(); 
    
    
   public Adaptive_Planning_RegHomeController ()
    {
        con = new Contact();
        reg = new Registration__c(); 
        captcha = new reCAPTCHA();     
        eegRegistrationUtility = new EEG_RegistrationUtility();
        adaplanningUtility = new Adaptive_Planning_Utility('Adaptive_Planning_WPF');
        siteProperty = adaplanningUtility.siteProperty;
        showRegister = true;
        showLogin = false;
        
    }
    public void initUtility(){
        if(Apexpages.currentPage().getUrl().containsIgnoreCase((Page.Adaptive_Planning_WPF_RegistrationHome).getUrl() ) ){
            adaplanningUtility = new Adaptive_Planning_Utility('Adaptive_Planning_WPF');
            siteProperty = adaplanningUtility.siteProperty;
        }
        else if(Apexpages.currentPage().getUrl().containsIgnoreCase((Page.Adaptive_Planning_WWSKO_RegistrationHome).getUrl() ) ){
            adaplanningUtility = new Adaptive_Planning_Utility('Adaptive_Planning_WWSKO');
            siteProperty = adaplanningUtility.siteProperty; 
        }
    }
    public void validateUser()
    {
        
        if(!eegRegistrationUtility.isValidText(regPassword) || !eegRegistrationUtility.isValidText(regConfirmPassword))
        {
            ApexPages.Message msgx = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Please_Enter_Required_Information);
            ApexPages.addMessage(msgx);
        }
        else if(regPassword != regConfirmPassword)
        {
            ApexPages.Message msgx = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Password_and_Confirm_Password_Should_be_the_Same);
            ApexPages.addMessage(msgx);
        }
        else if(eegRegistrationUtility.isExistingUser(eegRegistrationUtility.getUserName(con.email,siteProperty.SITE_USER_SUFFIX))){
            ApexPages.Message msgx = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Adaptive_Planning_User_Name_Exist_Please_Login_Or_Reset_Password);
            ApexPages.addMessage(msgx);
        }
        //Validate ReCaptcha
        System.debug('captcha.challenge: '+ captcha.challenge+', captcha.response: '+ captcha.response);
        captchaResponse = captcha.verify(); 
        if(!captchaResponse)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.EEG_Incorrect_Captcha_Code_Please_try_again));
        }
        /*//Registrants are not allowed to register with the Email domain which is in the Email Blackout List.
        if(eegRegistrationUtility.isValidText(con.email))
        {
            //For ******Programertain emails are allowed for Registration. So we are using "Email Black List" object for email WhiteList as well (with reverse check).
            if(!eegRegistrationUtility.isWhiteListedEmailAddress(siteProperty.EVENT_ID, con.email))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Seagate_Exe_Email_Domain_is_Blocked));
        }*/
    }
    
    public Pagereference registerUserFromWPF(){
        return registerUser(Page.Adaptive_Planning_WPF_RegistrationHome,(Page.Adaptive_Planning_WPF_RegPageOne).getUrl());  
    }
    
    public Pagereference registerUserFromWWSKO(){
    	con.Company_Name__c = 'Adaptive Planning';
        return registerUser(Page.Adaptive_Planning_WWSKO_RegistrationHome,(Page.Adaptive_Planning_WWSKO_RegPageOne).getUrl());
    }
    
    public PageReference registerUser(PageReference requestedPageRef,String loginSuccessPageURL) 
    {
        //showError = true;
        try
        {
           if(adaplanningUtility.ADAPTIVE_PLANNING_SITE_PROPERTIES_ARE_MISSING != null)
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, adaplanningUtility.ADAPTIVE_PLANNING_SITE_PROPERTIES_ARE_MISSING));
           validateUser();
        }
        catch(Exception e)
        {   
            //In case of any error reset the captcha code.
            captchaResponse = false;
            System.Debug('UnExpected Error while validating the User information =: '+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'UnExpected Error!'));
            return null;
        }
        Savepoint sp;
        
        if(ApexPages.hasMessages())
        {
            //In case of any error reset the captcha code.
            captchaResponse = false;
            return eegRegistrationUtility.pageRedirect(requestedPageRef, false);
        }
        
        Contact conExisting;
        Registration__c regExisting;
        string userId;
        // Check if contact is already uploaded in SF database.
        conExisting = eegRegistrationUtility.getContactFromEmail(con.email, siteProperty.ACCOUNT_ID); 
        
        try{
            
            system.debug('Calling Create user');
                
            // Create a savepoint Before User creation.
            sp = Database.setSavepoint();
                
            userId = eegRegistrationUtility.createUser(siteProperty.ACCOUNT_ID, con.email, regPassword, siteProperty.SITE_USER_SUFFIX, con.firstname, con.lastname, con.Company_Name__c);
        }catch(Exception e)
        {
            //In case of any error reset the captcha code.
            captchaResponse = false;
            // Rollback User creation.
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'UnExpected Error!'));
            return null;
        }
        
        if(conExisting <> null){
            regExisting = eegRegistrationUtility.getRegistrationFromEventIdContactId(siteProperty.EVENT_ID,conExisting.id); 
            if(regExisting == null)
                contactId = conExisting.Id;
        }else{
                contactId = eegRegistrationUtility.getPortalUserContactId(userId);
        }
        
        if(regExisting == null){
            try{
            	reg.PromoCode_Applied__c = promocode;
                eegRegistrationUtility.createRegistration(siteProperty.EVENT_ID, contactId, reg, userId, 'Saved for Later', adaplanningUtility.ADAPTIVE_PLANNING_REG_NAME_PREFIX, con.firstName, con.lastName);
                System.Debug('userId '+userId); 
            }catch(Exception e)
            {
                // Rollback User and Registration creation.
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'UnExpected Error!'));
                return null;
            }   
        }
        else
        {
            regExisting.Status__c = 'Saved for Later';
            regExisting.Attendee_Type__c = reg.Attendee_Type__c;
            upsert regExisting;
        }
        
        if(!ApexPages.hasMessages())
        {
            
            userName = con.email;
            password = regPassword;
            return loginUser(requestedPageRef,loginSuccessPageURL);
        }
        else
        {
            //In case of any error reset the captcha code.
            captchaResponse = false;
            //Possible exceptions are (Password is weak or Duplicate login found)
            return null;   
        }
    }
    
    public Pagereference loginUserFromWPF(){
        
        return loginUser(Page.Adaptive_Planning_WPF_RegistrationHome,(Page.Adaptive_Planning_WPF_RegPageOne).getUrl()); 
    }
    
    public Pagereference loginUserFromWWSKO(){
            
        return loginUser(Page.Adaptive_Planning_WWSKO_RegistrationHome,(Page.Adaptive_Planning_WWSKO_RegPageOne).getUrl());
    }
    
    
    public PageReference loginUser(PageReference requestedPageRef,String loginSuccessPageURL)
    {
        //PageReference requestedPageRef = Page.Adaptive_Planning_WPF_RegistrationHome;
        return eegRegistrationUtility.loginUser(userName, password, siteProperty.SITE_USER_SUFFIX, requestedPageRef, loginSuccessPageURL);
    }
    
    public PageReference forgotPassword()
    {
        PageReference successPageReference = Page.Adaptive_Planning_WWSKO_PassConfirm;
        return eegRegistrationUtility.forgotPassword(userName, siteProperty.SITE_USER_SUFFIX, successPageReference);
    }
    
    public PageReference forgotPasswordPartner()
    {
        PageReference successPageReference = Page.Adaptive_Planning_WPF_ForgotPassConfirm;
        return eegRegistrationUtility.forgotPassword(userName, siteProperty.SITE_USER_SUFFIX, successPageReference);
    }
    
    public PageReference changePassword()
    {
        return eegRegistrationUtility.changePassword(newPassword, verifyNewPassword, oldpassword);
    }
    
    public void rerenderOnRegister(){
        showRegister = true;
        showLogin = false;
    }
    public void rerenderOnLogin(){
        showLogin = true;
        showRegister = false;
    }

}