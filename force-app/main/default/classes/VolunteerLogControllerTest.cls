@isTest
private class VolunteerLogControllerTest {

    @isTest
    static void testAddLog_success() {
        Test.startTest();
        Id newId = VolunteerLogController.addLog(Date.today(), 3.5, 'Food bank shift');
        Test.stopTest();

        Volunteer_Log__c result = [SELECT Hours__c, Status__c FROM Volunteer_Log__c WHERE Id = :newId];
        System.assertEquals(3.5, result.Hours__c);
        System.assertEquals('Submitted', result.Status__c);
    }

    @isTest
    static void testAddLog_invalidHours_throws() {
        Boolean threw = false;
        try {
            VolunteerLogController.addLog(Date.today(), -1, 'Bad data');
        } catch (VolunteerLogController.VolunteerLogException e) {
            threw = true;
        }
        System.assertEquals(true, threw, 'Expected validation exception for negative hours');
    }

    @isTest
    static void testGetLogs_returnsData() {
        insert new Volunteer_Log__c(Activity_Date__c = Date.today(), Hours__c = 2, Status__c = 'Submitted');
        Test.startTest();
        List<Volunteer_Log__c> logs = VolunteerLogController.getLogs();
        Test.stopTest();
        System.assertEquals(1, logs.size());
    }
}