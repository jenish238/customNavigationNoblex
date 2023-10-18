public without sharing class UserTriggerMethods {
    
    public UserTriggerMethods(){
        
    }
    
    private boolean isSyncContactUser  = false;
    private boolean isCommunityProfile(String commuProfileId){
        Map<ID, Profile> mapProfileID = new ContactTriggerMethods().getUserProfileCommunities('CA Community Login');
        System.debug('nsp: mapProfileID '+mapProfileID);
        if(mapProfileID.containsKey(commuProfileId)){
            return true;
        }
        return false;
    }
    
    public void populateContactDetailFromUserFields(List<User> newUserInfo, Map<Id,User> mapOldUserInfo){
        if(isSyncContactUser) {return;}
        isSyncContactUser  = true;     
        Map<String, User> mapUser = new Map<String, User>();

        for(User us: newUserInfo){
            User oldUser = mapOldUserInfo.get(us.Id);
            
             if((oldUser.LastName!= us.LastName || oldUser.FirstName!= us.FirstName || oldUser.Phone!= us.Phone
               || oldUser.MobilePhone!= us.MobilePhone || oldUser.Email!= us.Email
               || oldUser.Street!= us.Street || oldUser.City!= us.City
               || oldUser.State!= us.State || oldUser.PostalCode!= us.PostalCode
               || oldUser.Country!= us.Country) && isCommunityProfile(us.ProfileId)){
                mapUser.put(us.ContactId, us);
            }
        }
        
        if(!mapUser.isEmpty()){
            List<Contact> lstContactInfo = [SELECT Id,LastName, FirstName, Name, Email, MailingStreet, MailingCity, MailingState,
                                            MailingPostalCode, MailingCountry, Phone, MobilePhone
                                      		FROM Contact WHERE Id =: mapUser.keySet()];
            for(Contact con:lstContactInfo){
                if(mapUser.containsKey(con.Id)){
                    User userInfo = mapUser.get(con.Id);
                    con.LastName = userInfo.LastName;
                    con.FirstName = userInfo.FirstName;
                    con.Email = userInfo.Email;
                    con.Phone = userInfo.Phone;
                    con.MobilePhone = userInfo.MobilePhone;
                    con.MailingStreet = userInfo.Street;
                    con.MailingCity = userInfo.City;
                    con.MailingState = userInfo.State;
                    con.MailingPostalCode = userInfo.PostalCode;
                    con.MailingCountry = userInfo.Country;
                }
            }
            update lstContactInfo;			       
        }
    }
}