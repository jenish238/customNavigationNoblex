public without sharing class ContactTriggerMethods {
    private boolean isSyncContactUser  = false;
    public static final string PROFILE_USER_COMMUNITY = 'CA Community Login';
    
    public void populateUserDetailFromContactFields(List<Contact> newConInfo, Map<Id,Contact> mapOldConInfo){
        if(isSyncContactUser) {return;}
        isSyncContactUser = true;  
        Map<String, Contact> mapContact = new Map<String, Contact>();
        
        Map<Id,Profile> profileIds = getUserProfileCommunities(PROFILE_USER_COMMUNITY);
        
        for(Contact con: newConInfo){
            Contact oldCon = mapOldConInfo.get(con.Id); 
             if(oldCon.LastName!= con.LastName || oldCon.FirstName!= con.FirstName
               || oldCon.Phone!= con.Phone
               || oldCon.MobilePhone!= con.MobilePhone || oldCon.Email!= con.Email
               || oldCon.MailingStreet!= con.MailingStreet || oldCon.MailingCity!= con.MailingCity
               || oldCon.MailingState!= con.MailingState || oldCon.MailingPostalCode!= con.MailingPostalCode
               || oldCon.MailingCountry!= con.MailingCountry){
                mapContact.put(con.Id, con);
            }
        }
        
        if(!mapContact.isEmpty()){
            List<User> lstUserInfo = [SELECT Id,ContactId, LastName, FirstName, Name, Email, Street, City, State, PostalCode, 
                                      		Country, Phone, MobilePhone
                                      FROM User 
                                      WHERE ContactId = :mapContact.keySet()
                                      AND profileId in:profileIds.Keyset()];
            
            for(User user:lstUserInfo){
                if(mapContact.containsKey(user.ContactId)){
                    Contact getInfo = mapContact.get(user.ContactId);
                    user.LastName = getInfo.LastName;
                    user.FirstName = getInfo.FirstName;
                    user.Email = getInfo.Email;
                    user.Phone = getInfo.Phone;
                    user.MobilePhone = getInfo.MobilePhone;
                    user.Street = getInfo.MailingStreet;
                    user.City = getInfo.MailingCity;
                    user.State = getInfo.MailingState;
                    user.PostalCode = getInfo.MailingPostalCode;
                    user.Country = getInfo.MailingCountry;
                }
            }
            System.debug('List User <<<'+lstUserInfo);
            update lstUserInfo;
			          
        }
    }
   
    public Map<ID, Profile> getUserProfileCommunities(String profileName){
        return new Map<ID, Profile>([SELECT id, Name FROM Profile WHERE Name = :profileName LIMIT 1]);
    }
}