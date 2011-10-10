package
{
	[Bindable]
	[RemoteClass(alias="com.suntek.timesheet.Employee")]	
	public class Employee
	{
		public function Employee()
		{
		}

		public var employeeSeq:int;
		public var firstName:String;
		public var middleName:String;
		public var lastName:String;
		public var title:String;
		public var fullName:String;
		
		public function toString():String {
			var str:String = "Employee: employeeSeq="+employeeSeq+", firstName="+firstName+
			", middleName="+middleName+", lastName="+lastName+", title="+title+
			", fullName="+fullName;
			return str;			
		}		
	}
}