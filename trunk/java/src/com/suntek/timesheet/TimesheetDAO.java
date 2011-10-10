/**
 * Created at Jan 19, 2009
 */
package com.suntek.timesheet;

import java.util.Date;
import java.util.List;

/**
 * @author Steve Cheang
 *
 */
public interface TimesheetDAO {

	public List<Timesheet> findAll(String user, String role, Date currDate);
	
	public Timesheet find(int employeeSeq, String location, Date date);
	
	public int createOrUpdateTimesheet(Timesheet ts);
	
	public int updateTimesheet(Timesheet ts);
	
	public int createTimesheet(Timesheet ts);
	
	public List<Timesheet> generateReport(String user, Date fromDate, Date toDate);
	
	public List<Employee> getAllEmployee(String user);
	
	public List<Timesheet> generateEmployeeReport(String user, Date fromDate, Date toDate, Employee emp);
}
