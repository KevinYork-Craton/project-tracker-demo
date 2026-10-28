/**
 * Logic for ProjectTrigger. Kept out of the trigger so it can be tested and reused.
 *  - Blocks a negative Budget.
 *  - Stamps Completed Date when Status becomes Completed; clears it if Status moves back.
 *  - Creates a close-out Task for the owner when a Project is completed.
 */
public with sharing class ProjectTriggerHandler {
    public static final String STATUS_COMPLETED = 'Completed';

    public static void beforeSave(List<Project__c> projects, Map<Id, Project__c> oldMap) {
        for (Project__c p : projects) {
            if (p.Budget__c != null && p.Budget__c < 0) {
                p.Budget__c.addError('Budget cannot be negative.');
            }
            if (p.Status__c == STATUS_COMPLETED && p.Completed_Date__c == null) {
                p.Completed_Date__c = Date.today();
            } else if (p.Status__c != STATUS_COMPLETED) {
                p.Completed_Date__c = null;
            }
        }
    }

    public static void afterUpdate(List<Project__c> projects, Map<Id, Project__c> oldMap) {
        List<Task> tasks = new List<Task>();
        for (Project__c p : projects) {
            if (becameCompleted(p, oldMap.get(p.Id))) {
                tasks.add(new Task(
                    WhatId = p.Id,
                    OwnerId = p.OwnerId,
                    Subject = 'Close-out review: ' + p.Name,
                    ActivityDate = Date.today().addDays(7),
                    Priority = 'Normal',
                    Status = 'Not Started'
                ));
            }
        }
        if (!tasks.isEmpty()) {
            insert tasks;
        }
    }

    private static Boolean becameCompleted(Project__c newRec, Project__c oldRec) {
        return newRec.Status__c == STATUS_COMPLETED && oldRec.Status__c != STATUS_COMPLETED;
    }
}
