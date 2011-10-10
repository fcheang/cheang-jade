// ActionScript file
import mx.collections.*;
import mx.controls.Alert;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.events.CalendarLayoutChangeEvent;
import mx.events.ValidationResultEvent;
import mx.printing.*;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.validators.Validator;

  
private var user:String;
private var pswd:String;
private var role:String;
private var assignedTo:String;

private var USER:String = 'User';
private var MANAGER:String = 'Manager';
private var HR_MANAGER:String = 'HR Manager';

[Bindable]
private var tsAC:ArrayCollection;

[Bindable]
private var tsReportAC:ArrayCollection;

[Bindable]
private var empAC:ArrayCollection;

[Bindable]
private var empReportAC:ArrayCollection;


private function useDate(eventObj:CalendarLayoutChangeEvent):void {	
	var selectedDate:Date = eventObj.currentTarget.selectedDate;
	var today:Date = new Date();
	
	// Make sure selectedDate is not null.
	if (selectedDate == null) {
		return;
	}
	timesheetRO.findAll(user, role, eventObj.currentTarget.selectedDate);
	this.currentState = "summary";
	trace("role = "+role);
	trace("selectedDate = "+selectedDate);
	trace("today = "+today);
	if (role == HR_MANAGER){
			updateTSBtn.enabled = true;					
			trace("HR Manager: enable updateBtn");		
	}else{
		if (sameDate(selectedDate, today)){
			updateTSBtn.enabled = true;					
			trace("same date: enable updateBtn");
		}else{
			updateTSBtn.enabled = false;					
			trace("disable updateBtn");
		}		
	}
}

private function sameDate(d1:Date, d2:Date):Boolean {
	if (d1.date == d2.date && d1.month == d2.month && d1.fullYear == d2.fullYear){
		return true;
	}else{
		return false;
	}
}

private function showOrHideDetailPanel():void {
	if (timesheetDG.selectedItem != null){
		this.currentState = "";
		validateForm();
	}else{
		this.currentState = "summary";
	}
}

private function updateTimesheet(ts:Timesheet):void{
	updateTSBtn.enabled = false;
	ts.date = currDateDF.selectedDate;
	ts.createdBy = user;
	timesheetRO.createOrUpdateTimesheet(ts);
}

private function genericFaultHandler(event:FaultEvent):void {
	Alert.show(event.fault.faultString, "Error");
}

private function loginResultHandler(event:ResultEvent):void {
	var r:Object = event.result;
	if (r != null){
		var u:User = User(r);		
		user = u.userId;
		pswd = u.password;		
		role = u.role;
		assignedTo = u.assignedTo;
		currentState="summary";
		mainPanel.title = assignedTo;
		timesheetRO.findAll(user, role, currDateDF.selectedDate);
		timesheetRO.getAllEmployee(user);
	}else{
		Alert.show("Login failed! Please enter a valid User ID and Password!", "Error");
	}			
	loginB.enabled = true;
}	

private function getAllEmployeeResultHandler(event:ResultEvent):void {
	var r:Object = event.result;
	if (r != null){
		empAC = ArrayCollection(r);
		//trace("empAC.size = "+empAC.length);
		//for each (var emp:Employee in empAC){
		//	trace("emp = "+emp.toString());
		//}
	}else{
		Alert.show("No employees found!", "Error");
	}
}

private function tsFindAllResultHandler(event:ResultEvent):void {
	var r:Object = event.result;
	if (r != null){
		tsAC = ArrayCollection(r);
		//trace("tsFindAllResultHandler.event.result = "+r.toString());
	}else{
		Alert.show("No timesheets found!", "Error");
	}	
}

private function tsReportResultHandler(event:ResultEvent):void {
	var r:Object = event.result;
	if (r != null){
		tsReportAC = ArrayCollection(r);
		if (tsReportAC.length == 0){
			Alert.show("No timesheet entries found!", "Error");			
		}
	}else{
		Alert.show("No report entries found!", "Error");
	}	
}

private function empReportResultHandler(event:ResultEvent):void {
	var r:Object = event.result;
	if (r != null){
		empReportAC = ArrayCollection(r);
		if (empReportAC.length == 0){
			Alert.show("No timesheet entries found!", "Error");			
		}		
	}else{
		Alert.show("No report entries found!", "Error");
	}	
}


private function tsUpdateResultHandler(event:ResultEvent):void {
 	updateTSBtn.enabled = true;
 	
	var r:Object = event.result;
	var numUpdated:int;
	if (r != null){
		numUpdated = int(r);
		Alert.show(numUpdated+" record updated!");
	}else{
		Alert.show("Update failed! Please try again.", "Error");
	}
}

private function login():void{
	loginB.enabled = false;
	loginRO.login(useridTI.text, pswdTI.text);				
}

private function logout():void
{
	useridTI.text = "";
	pswdTI.text = "";
	
	if (currDateDF != null){
		currDateDF.selectedDate = new Date();	
	}
	tsAC = null;
	
	if (reportStartDateDF != null){
		reportStartDateDF.selectedDate = null;
	}
	if (reportEndDateDF != null){
		reportEndDateDF.selectedDate = null;
	}
	tsReportAC = null;

	empAC = null;
	if (empRptStartDateDF != null){
		empRptStartDateDF.selectedDate = null;
	}
	if (empRptEndDateDF != null){
		empRptEndDateDF.selectedDate = null;
	}
	empReportAC = null;
	
	tn.selectedIndex = 0;
	
	currentState="login";		
	loginB.enabled = true;
	/*
	tn.selectedIndex = 0;
	var ref:URLRequest = new URLRequest("javascript:location.reload(true)"); 
    navigateToURL(ref, "_self"); 
    */
}		

// Form validation
[Bindable]
public var formIsValid:Boolean = false;

// Holds a reference to the currently focussed 
// control on the form.
private var focussedFormControl:DisplayObject;
                      
// Validate the form
private function validateForm():void 
{                    
    // Mark the form as valid to start with                
    formIsValid = true;            

    // Run each validator in turn, using the isValid() 
    // helper method and update the value of formIsValid
    // accordingly.
    validate(workedTIValidator);   
    validate(overtimeTIValidator);
    validate(vacationTIValidator);
    validate(sickTIValidator);
    validate(floatingTIValidator);
    validate(holidayTIValidator);
    validate(otherTIValidator);             
	
	// update total hours
	if (formIsValid){
		var wkHr:Number = parseFloat(workedTI.text);
		var ovHr:Number = parseFloat(overtimeTI.text);
		var vaHr:Number = parseFloat(vacationTI.text);
		var siHr:Number = parseFloat(sickTI.text);
		var flHr:Number = parseFloat(floatingTI.text);
		var hoHr:Number = parseFloat(holidayTI.text);
		var otHr:Number = parseFloat(otherTI.text);
		var totalHr:Number = wkHr + ovHr + vaHr + siHr + flHr + hoHr + otHr;
		totalTI.text = formatDecimalValue(totalHr);
	}
}
 
 // Helper method. Performs validation on a passed Validator instance.
 // Validator is the base class of all Flex validation classes so 
 // you can pass any validation class to this method.  
 private function validate(validator:Validator):Boolean
 {                
    // Get a reference to the component that is the
    // source of the validator.
     var validatorSource:DisplayObject = validator.source as DisplayObject;
    
    // Suppress events if the current control being validated is not
    // the currently focussed control on the form. This stops the user
    // from receiving visual validation cues on other form controls.
    var suppressEvents:Boolean = false;
    
    // Carry out validation. Returns a ValidationResultEvent.
    // Passing null for the first parameter makes the validator 
    // use the property defined in the property tag of the
    // <mx:Validator> tag.
    var event:ValidationResultEvent = validator.validate(null, suppressEvents); 
                    
    // Check if validation passed and return a boolean value accordingly.
    var currentControlIsValid:Boolean = (event.type == ValidationResultEvent.VALID);
     
    // Update the formIsValid flag
    formIsValid = formIsValid && currentControlIsValid;
     
    return currentControlIsValid;
}

private function formatDecimalValue(obj:Object):String {
	if (obj is Number){
		var str:String = Number(obj).toFixed(2);
		var i:int = str.indexOf(".");
		if (str.substring(i+1, str.length) == "00"){
			return str.substring(0, i);
		}else{
			return str;
		}
	}else{
		return String(obj);
	}
}
  
private function decimalLabelFunction(item:Object, column:DataGridColumn):String {
	var cell:Object = item[column.dataField];
	return formatDecimalValue(cell);
}

private function formatDate(item:Object, column:DataGridColumn):String {
	var cell:Object = item[column.dataField];
	return dateFormatter.format(cell);
}

private function generateReport():void{
	if (reportStartDateDF.selectedDate == null){
		Alert.show("Missing report start date! Please select the \"From\" date for the report.", "Warning");
		return;
	}
	if (reportEndDateDF.selectedDate == null){
		Alert.show("Missing report end date! Please select the \"To\" date for the report!", "Warning");
		return;
	}
	timesheetRO.generateReport(user, reportStartDateDF.selectedDate, reportEndDateDF.selectedDate);	
}

private function generateEmployeeReport():void{
	if (empRptStartDateDF.selectedDate == null){
		Alert.show("Missing report start date! Please select the \"From\" date for the report.", "Warning");
		return;
	}
	if (empRptEndDateDF.selectedDate == null){
		Alert.show("Missing report end date! Please select the \"To\" date for the report!", "Warning");
		return;
	}
	timesheetRO.generateEmployeeReport(user, empRptStartDateDF.selectedDate, empRptEndDateDF.selectedDate, empRptCB.selectedItem);	
}


public function printTsReport():void {
	if (tsReportAC == null || tsReportAC.length <= 0){
		Alert.show("Nothing to print! Please generate the report first.", "Warning");
		return;
	}
	
    // Create a FlexPrintJob instance.
    var printJob:FlexPrintJob = new FlexPrintJob();
    
    // Start the print job.
    if (printJob.start()) {
        // Create a FormPrintView control 
        // as a child of the application.
        var thePrintView:FormPrintView = new FormPrintView();
        addChild(thePrintView);
        
        // Set the print view properties.
        thePrintView.width = printJob.pageWidth;
        thePrintView.height = printJob.pageHeight;
        thePrintView.prodTotal = tsReportAC.length;

        thePrintView.header.title.text = "Timesheet Report for " + assignedTo;
        thePrintView.header.period.text = "Period: " + dateFormatter.format(reportStartDateDF.selectedDate) + " to " + dateFormatter.format(reportEndDateDF.selectedDate);
        
        // Set the data provider of the FormPrintView 
        // component's DataGrid to be the data provider of 
        // the displayed DataGrid.
        thePrintView.myDataGrid.dataProvider = reportDG.dataProvider;
        
        
        // Create a single-page image.
        thePrintView.showPage("single");
        
        // If the print image's DataGrid can hold all the  
        // data provider's rows, add the page to the print job. 
        if (!thePrintView.myDataGrid.validNextPage) {
            printJob.addObject(thePrintView);
        } else {
	        // Otherwise, the job requires multiple pages.        	
            // Create the first page and add it to the print job.
            thePrintView.showPage("first");
            printJob.addObject(thePrintView);
            thePrintView.pageNumber++;
            
            // Loop through the following code 
            // until all pages are queued.
            while(true) {
                // Move the next page of data to the top of 
                // the PrintDataGrid.
                thePrintView.myDataGrid.nextPage();

                // Try creating a last page.
                thePrintView.showPage("last");  

                // If the page holds the remaining data, or if 
                // the last page was completely filled by the last  
                // grid data, queue it for printing.
                // Test if there is data for another 
                // PrintDataGrid page.
                if(!thePrintView.myDataGrid.validNextPage) {
                    // This is the last page; 
                    // queue it and exit the print loop.
                    printJob.addObject(thePrintView);
                    break;
                } else {
	                // This is not the last page. Queue a middle page.                 	
                    thePrintView.showPage("middle");
                    printJob.addObject(thePrintView);
                    thePrintView.pageNumber++;
                }
            }
        }
        // All pages are queued; remove the FormPrintView 
        // control to free memory.
        removeChild(thePrintView);
    }
    // Send the job to the printer.
    printJob.send();
}

public function printEmpReport():void {
	if (empReportAC == null || empReportAC.length <= 0){
		Alert.show("Nothing to print! Please generate the report first.", "Warning");
		return;
	}
	
    // Create a FlexPrintJob instance.
    var printJob:FlexPrintJob = new FlexPrintJob();
    
    // Start the print job.
    if (printJob.start()) {
        // Create a FormPrintView control 
        // as a child of the application.
        var thePrintView:EmpReportPrintView = new EmpReportPrintView();
        addChild(thePrintView);
        
        // Set the print view properties.
        thePrintView.width = printJob.pageWidth;
        thePrintView.height = printJob.pageHeight;
        thePrintView.prodTotal = empReportAC.length;

        thePrintView.header.title.text = "Employee: " + Employee(empRptCB.selectedItem).fullName;
        thePrintView.header.period.text = "Period: " + dateFormatter.format(empRptStartDateDF.selectedDate) + " to " + dateFormatter.format(empRptEndDateDF.selectedDate);
        
        // Set the data provider of the FormPrintView 
        // component's DataGrid to be the data provider of 
        // the displayed DataGrid.
        thePrintView.myDataGrid.dataProvider = empReportDG.dataProvider;
        
        
        // Create a single-page image.
        thePrintView.showPage("single");
        
        // If the print image's DataGrid can hold all the  
        // data provider's rows, add the page to the print job. 
        if (!thePrintView.myDataGrid.validNextPage) {
            printJob.addObject(thePrintView);
        } else {
	        // Otherwise, the job requires multiple pages.        	
            // Create the first page and add it to the print job.
            thePrintView.showPage("first");
            printJob.addObject(thePrintView);
            thePrintView.pageNumber++;
            
            // Loop through the following code 
            // until all pages are queued.
            while(true) {
                // Move the next page of data to the top of 
                // the PrintDataGrid.
                thePrintView.myDataGrid.nextPage();

                // Try creating a last page.
                thePrintView.showPage("last");  

                // If the page holds the remaining data, or if 
                // the last page was completely filled by the last  
                // grid data, queue it for printing.
                // Test if there is data for another 
                // PrintDataGrid page.
                if(!thePrintView.myDataGrid.validNextPage) {
                    // This is the last page; 
                    // queue it and exit the print loop.
                    printJob.addObject(thePrintView);
                    break;
                } else {
	                // This is not the last page. Queue a middle page.                 	
                    thePrintView.showPage("middle");
                    printJob.addObject(thePrintView);
                    thePrintView.pageNumber++;
                }
            }
        }
        // All pages are queued; remove the FormPrintView 
        // control to free memory.
        removeChild(thePrintView);
    }
    // Send the job to the printer.
    printJob.send();
}
