({
    doInit: function( component, event, helper ) {
        var objName = component.get("v.sObjectName");
        var profileName = component.get("v.profileName");
        var recordType = component.get("v.recordTypeDeveloperName");
        var rec = component.get("v.ParentCaseRecord");
        component.set("v.UpdatedCaseRecord", rec);
        var action = component.get("c.getPageLayoutFields");
        action.setParams({
            sObjectName : objName,
            profileName : profileName,
            recordTypeName : recordType
        })
		action.setCallback(this, function(response) {
        	var state = response.getState();
			if (state === "SUCCESS") {
                component.set("v.layoutSections", response.getReturnValue() );
                console.log( response.getReturnValue() );
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
				console.log( errors );
            }
        });
        
        $A.enqueueAction(action);
    },
    handleLoad : function(component, event, helper) {
    	component.set("v.showSpinner", false);   
    },
    handleChange : function(component, event, helper) {
       event.preventDefault();
       var fieldName = event.getSource().get("v.fieldName");
       var value = event.getSource().get("v.value");
       var recInfo = component.get("v.UpdatedCaseRecord");
       recInfo[fieldName] = value
       component.set("v.UpdatedCaseRecord", recInfo)
    }
})