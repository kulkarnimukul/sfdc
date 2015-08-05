@isTest
private class BadgePrintLogControllerTest {

    static testMethod void BadgePrintLogControllerTst() {
        
        //Inset New Account Record
        Account accobj = new Account();
        accobj.Name = 'Test_Name';
        insert accobj;
        
        
        //Inset New Event Header Record 
        Event_Header__c ehobj =New Event_Header__c();
        ehobj.Account__c = accobj.id;
        ehobj.Event_Name__c ='Test_Event_Name__c';
        ehobj.Start_Date__c= system.today();
        ehobj.End_Date__c = system.today();
        ehobj.Email_From_Address__c='test@gmail.com';
        ehobj.Event_Code__c ='12344';
        insert ehobj;
        
        // Insert New User Type Record 
        User_Type__c utobj = New User_Type__c();
        utobj.Name = 'test1';
        utobj.Active__c = 'true';
        insert utobj;
        
         User_Type__c utobj1 = New User_Type__c();
        utobj.Name = 'test2';
        utobj.Active__c = 'true';
        insert utobj1;
        
         User_Type__c utobj2 = New User_Type__c();
        utobj.Name = 'test3';
        utobj.Active__c = 'true';
        insert utobj2;
        
        // Insert New Event User Type Record 
        Event_User_Type__c eutobj = New Event_User_Type__c();
        eutobj.Event_Header__c = ehobj.Id;
        eutobj.User_Type__c = utobj.id;
        eutobj.Badge_Printing_Template_Name__c = '';
        insert eutobj;
        
        Event_User_Type__c eutobj1 = New Event_User_Type__c();
        eutobj1.Event_Header__c = ehobj.Id;
        eutobj1.User_Type__c = utobj1.id;
        eutobj1.Badge_Printing_Template_Name__c = '';
        insert eutobj1;
        
        Event_User_Type__c eutobj2 = New Event_User_Type__c();
        eutobj2.Event_Header__c = ehobj.Id;
        eutobj2.User_Type__c = utobj2.id;
        eutobj2.Badge_Printing_Template_Name__c = '';
        insert eutobj2;
        
        
        //Insert New Contact Record 
        Contact conobj = new Contact();
        conobj.AccountId = accobj.Id;
        conobj.LastName = 'Test_LastName';
        conobj.Phone = '74224';
        conobj.Email = 'eps1234@gmail.com'; 
        insert conobj;
        
        //Insert New Event User 
        Event_User__c euobj = new Event_User__c();
        euobj.Account__c = accobj.id;
        euobj.AccountContact__c =conobj.id;
        euobj.User_Type__c =utobj.Id;
        euobj.Event_Header__c = ehobj.id;
        euobj.isActive__c = true;
        insert euobj; 
        
        // Insert Bandge Printin log 
            Badge_Printing_Log__c bplobj =new   Badge_Printing_Log__c();
            bplobj.Event_ID__c = ehobj.Id;
            bplobj.Roles__c='test1;test3;';
            //insert bplobj;
            
           
            
            
      BadgePrintLogController bplc = new BadgePrintLogController(new ApexPages.standardController(bplobj));
      bplc.values();
      bplc.selectclick();
      bplc.unselectclick();
      bplc.getunSelectedValues();
      bplc.getSelectedValues();
      bplc.Save();
      
     
    }
}