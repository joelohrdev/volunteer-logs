public with sharing class VolunteerLogController {

    public class VolunteerLogException extends Exception {}

    @AuraEnabled(cacheable=true)
    public static List<Volunteer_Log__c> getLogs() {
        List<Volunteer_Log__c> logs = [
            SELECT Id, Activity_Date__c, Hours__c, Notes__c, Status__c
            FROM Volunteer_Log__c
            WITH USER_MODE
            ORDER BY Activity_Date__c DESC
            LIMIT 50
        ];
        return logs;
    }

    @AuraEnabled
    public static Id addLog(Date activityDate, Decimal hours, String notes) {
        if (activityDate == null || hours == null || hours <= 0) {
            throw new VolunteerLogException('Date and a positive hours value are required.');
        }

        Volunteer_Log__c log = new Volunteer_Log__c(
            Activity_Date__c = activityDate,
            Hours__c = hours,
            Notes__c = notes,
            Status__c = 'Submitted'
        );

        // Strip fields the running user can't actually edit, rather than
        // trusting client input to respect FLS.
        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.CREATABLE, new List<Volunteer_Log__c>{ log }
        );

        try {
            insert decision.getRecords();
        } catch (DmlException e) {
            throw new VolunteerLogException('Failed to save log: ' + e.getMessage());
        }

        return decision.getRecords()[0].Id;
    }

}