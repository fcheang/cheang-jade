package
{
	[Bindable]
	[RemoteClass(alias="com.suntek.timesheet.Timesheet")]
	public class Timesheet
	{
		public function Timesheet()
		{
		}

		public var employeeSeq:int;
		
		public var date:Date;
		
		public var period:String;
		
		public var name:String;

		public var location:String;		
		
		public var worked:Number;

		public var overtime:Number;

		public var vacation:Number;

		public var sick:Number;
		
		public var floating:Number;
		
		public var holiday:Number;
		
		public var other:Number;
		
		public var comments:String;
		
		public var createdBy:String;
		
		public var total:Number;
		
		public function toString():String {
			var str:String = "Timesheet: employeeSeq="+employeeSeq+", period="+period+
			", date="+date+", name="+name+", location="+location+
			", worked="+worked+", overtime="+overtime+
			", vacation="+vacation+", sick="+sick+", floating="+floating+
			", holiday="+holiday+", other="+other+
			", comments="+comments+", createdBy="+createdBy+", total="+total;
			return str;			
		}

	}

}
