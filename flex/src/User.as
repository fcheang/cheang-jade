package
{
	[Bindable]
	[RemoteClass(alias="com.suntek.timesheet.User")]	
	public class User
	{
		public function User()
		{
		}

		public var userId:String;
		public var password:String;
		public var role:String;
		public var assignedTo:String;

	}
}