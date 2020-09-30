/********************************************************************************************
* @Author:       Accenture IDC 
* @Date:         21/JUL/2020
* @Description: This controller for to prepare layout -- Extension of createCaseForm.cmp [AURA] 
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
* @Test Class Name :  LightningRecordEditFormControllerTest
***********************************************************************************************/
public class LightningRecordEditFormController {
    /********************************************************************************************
* @Author:       Accenture IDC 
* @Date:         21/JUL/2020
* @Description: This method to prepare layout based on the Profile,Object & RecordType -- Extension of createCaseForm.cmp [AURA] 
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
* @Test Class Name :  LightningRecordEditFormControllerTest
***********************************************************************************************/
    @AuraEnabled 
    public static List<LayoutSection> getPageLayoutFields(String sObjectName,String profileName, String recordTypeName) {
        List<ExceptionLog__c> eLogList = new List<ExceptionLog__c>();
		/** USE CUSTOM METADATA TO STORE THE MAPPING BETWEEN LAYOUT,PROFILE AND SOBJECT AS CURRENTLY MD OPERATION ON LAYOUT IS NOT AVAIALBLE**/
        List<Case_Layout_Setting__mdt> layoutName = [SELECT Assigned_Case_Layout__c FROM Case_Layout_Setting__mdt WHERE ProfileName__c =:profileName AND RecordTypeName__c=:recordTypeName AND sObjectName__c=:sObjectName];
        List<String> layoutNames = new List<String>();
        List<LayoutSection> lstSections = new List<LayoutSection>();
        if(layoutName.size()>0 && !layoutName.isEmpty()){
            layoutNames.add(layoutName[0].Assigned_Case_Layout__c);
            
            try {
                List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, layoutNames);
                Metadata.Layout contLayout = (Metadata.Layout) components.get(0);
                for( Metadata.LayoutSection ls : contLayout.layoutSections ) {
                    
                    LayoutSection section = new LayoutSection( ls.label, ls.layoutColumns.size() );
                    List<LayoutColumn> lstColumns = new List<LayoutColumn>();
                    Integer maxFieldsInColumn = 0;
                    for( Metadata.LayoutColumn lc : ls.layoutColumns ) {
                        
                        LayoutColumn column = new LayoutColumn();
                        if( lc.layoutItems != null ) { 
                            if( maxFieldsInColumn < lc.layoutItems.size() ) {
                                maxFieldsInColumn = lc.layoutItems.size();
                            }
                            for( Metadata.LayoutItem li : lc.layoutItems ) {
                                if(li.behavior == Metadata.UiBehavior.Edit || li.behavior == Metadata.UiBehavior.Required){
                                    column.lstFields.add( new LayoutField( li ) );
                                }
                            }
                        }
                        if( column.lstFields.size() > 0 ) {
                            lstColumns.add( column );
                        }
                    }
                    if( maxFieldsInColumn > 0 ) {
                        for( Integer i = 0; i < maxFieldsInColumn; i++ ) {
                            for( Integer j = 0; j < lstColumns.size(); j++ ){
                                if( lstColumns[j].lstFields.size() > i ) {
                                    section.lstFields.add( lstColumns[j].lstFields[i] );    
                                }    
                                else {
                                    section.lstFields.add( new LayoutField() );
                                }
                            }    
                        }    
                    }
                    if(section.lstFields.size()>1){
                        lstSections.add( section );
                    }
                }
            }
            catch( Exception e ){
				/**
                ExceptionLog__c eLog = new ExceptionLog__c();
                eLog.ErrorMessage__c = e.getMessage();
                eLog.ErrorType__c = e.getTypeName();
                eLog.StackTrace__c = e.getMessage();
                eLog.LineNumber__c = String.valueOf(e.getLineNumber());
                eLogList.add(eLog);
				**/                
            }
            //Database.insert(eLogList);
            return lstSections;
        }
        else{
			//Feed something in the empty else block as per Log need.
			/**
            ExceptionLog__c eLog = new ExceptionLog__c();
            eLog.ErrorMessage__c = 'Check Case_Layout_Setting__mdt Custom Metadata With Current RecordType,Profile,sObject Matching Records';
            eLog.ErrorType__c = 'LightningRecordEditFormController Apex Error';
            eLogList.add(eLog);
            Database.insert(eLogList);
            return NULL;
			**/
        }
    }
    /********************************************************************************************
* @Author:       Accenture IDC 
* @Date:         21/JUL/2020
* @Description: Inner class to prepare Layout Sections
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
* @Test Class Name :  LightningRecordEditFormControllerTest
***********************************************************************************************/  
    public class LayoutSection {   
        @AuraEnabled public String label;
        @AuraEnabled public List<LayoutField> lstFields;
        @AuraEnabled public Integer totalColumns;
        /**Constructor to Intialize the LayoutSection*/ 
        public LayoutSection( String label, Integer totalColumns ) {
            this.label = label;
            this.totalColumns = totalColumns;
            this.lstFields = new List<LayoutField>();
        }
    }
    /********************************************************************************************
* @Author:       Accenture IDC 
* @Date:         21/JUL/2020
* @Description: Inner class to prepare Layout Columns
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
* @Test Class Name :  LightningRecordEditFormControllerTest
***********************************************************************************************/    
    private class LayoutColumn {
        private List<LayoutField> lstFields;    
        /**Constructor to Intialize the LayoutColumn*/ 
        public LayoutColumn() {
            this.lstFields = new List<LayoutField>();
        }
    }
    /********************************************************************************************
* @Author:       Accenture IDC 
* @Date:         21/JUL/2020
* @Description: Inner class to prepare Layout Fields
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
* @Test Class Name :  LightningRecordEditFormControllerTest
***********************************************************************************************/      
    public class LayoutField {
        @AuraEnabled public String fieldName;
        @AuraEnabled public Boolean isRequired;
        @AuraEnabled public Boolean isReadOnly;
        /**Constructor to Intialize the LayoutField*/ 
        public LayoutField() {}
        /**Parametrized Constructor to Intialize the LayoutField*/ 
        public LayoutField( Metadata.LayoutItem li ) {
            
            this.fieldName = li.field;
            if( li.behavior == Metadata.UiBehavior.Required ) {
                this.isRequired = true;
            }
            else if( li.behavior == Metadata.UiBehavior.ReadOnly ) {
                this.isReadOnly = true;
            }    
        }
    }
}