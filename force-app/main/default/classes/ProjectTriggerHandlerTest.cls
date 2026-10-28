@IsTest
private class ProjectTriggerHandlerTest {
    @IsTest
    static void completingProjectStampsDateAndCreatesTask() {
        Project__c p = new Project__c(Name = 'Test Project', Status__c = 'New', Budget__c = 1000);
        insert p;

        Test.startTest();
        p.Status__c = 'Completed';
        update p;
        Test.stopTest();

        p = [SELECT Completed_Date__c FROM Project__c WHERE Id = :p.Id];
        Assert.areEqual(Date.today(), p.Completed_Date__c, 'Completed Date should be stamped');

        List<Task> tasks = [SELECT Subject, ActivityDate FROM Task WHERE WhatId = :p.Id];
        Assert.areEqual(1, tasks.size(), 'One close-out task expected');
        Assert.areEqual(Date.today().addDays(7), tasks[0].ActivityDate);
    }

    @IsTest
    static void reopeningProjectClearsCompletedDate() {
        Project__c p = new Project__c(Name = 'Reopen', Status__c = 'Completed');
        insert p;
        Assert.isNotNull([SELECT Completed_Date__c FROM Project__c WHERE Id = :p.Id].Completed_Date__c);

        p.Status__c = 'In Progress';
        update p;
        Assert.isNull([SELECT Completed_Date__c FROM Project__c WHERE Id = :p.Id].Completed_Date__c);
    }

    @IsTest
    static void updatingAlreadyCompletedProjectDoesNotCreateAnotherTask() {
        Project__c p = new Project__c(Name = 'Done', Status__c = 'New');
        insert p;
        p.Status__c = 'Completed';
        update p;
        p.Budget__c = 500;
        update p;
        Assert.areEqual(1, [SELECT COUNT() FROM Task WHERE WhatId = :p.Id]);
    }

    @IsTest
    static void negativeBudgetIsRejected() {
        Project__c p = new Project__c(Name = 'Bad Budget', Budget__c = -1);
        Database.SaveResult sr = Database.insert(p, false);
        Assert.isFalse(sr.isSuccess(), 'Negative budget should fail');
        Assert.isTrue(sr.getErrors()[0].getMessage().contains('Budget cannot be negative'));
    }
}
