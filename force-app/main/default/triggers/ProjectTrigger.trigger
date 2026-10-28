trigger ProjectTrigger on Project__c (before insert, before update, after update) {
    if (Trigger.isBefore) {
        ProjectTriggerHandler.beforeSave(Trigger.new, Trigger.oldMap);
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        ProjectTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}
