/**
 * Created at Jan 19, 2009
 */
package com.suntek.timesheet;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;

import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.UncategorizedSQLException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.BeanPropertySqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.support.JdbcDaoSupport;
import org.apache.log4j.Logger;


/**
 * @author Steve Cheang
 *
 */
public class TimesheetDAOImpl extends JdbcDaoSupport implements TimesheetDAO {

	private static Logger logger = Logger.getLogger(TimesheetDAOImpl.class.getName());
	private static DateFormat  df = DateFormat.getDateInstance(DateFormat.SHORT);
	
	private List<ViewMapping> getViewMapping(String user) throws DataAccessException {
		Connection con = this.getConnection();
		String sql = 
			"SELECT v.employeeSeq, v.location, concat(e.lastName, ', ', e.firstName, ' ', e.title) as name "+
			"FROM viewMapping v, user u, employee e "+
			"WHERE u.userId = ? and u.employeeViewSeq = v.employeeViewSeq "+
			"and v.employeeSeq = e.employeeSeq "+
			"ORDER BY e.lastName";
		PreparedStatement pstmt;
		ResultSet rs;
		List<ViewMapping> vms = new ArrayList<ViewMapping>();
		ViewMapping vm = null;
		try{
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, user);
			rs = pstmt.executeQuery();
			while (rs.next()){
				vm = new ViewMapping();
				vm.setEmployeeSeq(rs.getInt(1));
				vm.setLocation(rs.getString(2));
				vm.setEmployeeName(rs.getString(3));
				vms.add(vm);
			}
			return vms;
		}catch(SQLException e){
			logger.error("Problem executing "+sql+" for user "+user);
			throw new UncategorizedSQLException("getManagedEmployee", sql, e);
		}finally{
			this.releaseConnection(con);
		}		
	}
	
	public List<Timesheet> findAll(String user, String role, Date currDate) throws DataAccessException {
		String sql = 
			"SELECT t.employeeSeq, t.date, concat(e.lastName, ', ', e.firstName, ' ', e.title) as name, t.location, t.worked, t.overtime, "+
			"t.vacation, t.sick, t.floating, t.holiday, t.other, t.comments "+ 
			"from timesheet t, viewMapping v, user u, employee e "+
			"where u.userId = ? and "+
			"u.employeeViewSeq = v.employeeViewSeq and "+
			"v.employeeSeq = t.employeeSeq and v.location = t.location and "+
			"t.employeeSeq = e.employeeSeq "+
			"and t.date = ?";
		
		List<Timesheet> retVals = new ArrayList<Timesheet>();				
		List<ViewMapping> mappings = getViewMapping(user);		
		
		RowMapper mapper = new TimesheetRowMapper();		
		JdbcTemplate template = new JdbcTemplate(this.getDataSource());
		Object[] params = new Object[] { user, currDate };		
		List<Timesheet> result = template.query(sql, params, mapper);
		
		retVals.addAll(result);
		
		boolean found = false;
		for (ViewMapping vm : mappings){
			for (Timesheet ts : result){
				if (ts.getName().equals(vm.getEmployeeName()) && ts.getLocation().equals(vm.getLocation())){
					found = true;
					break;
				}
			}
			if (!found){
				Timesheet ts = new Timesheet();
				ts.setEmployeeSeq(vm.getEmployeeSeq());
				ts.setLocation(vm.getLocation());
				ts.setDate(currDate);
				ts.setName(vm.getEmployeeName());
				ts.setCreatedBy(user);
				retVals.add(ts);
			}
			found = false;
		}
		Collections.sort(retVals);
		if (logger.isDebugEnabled()){
			logger.debug("findAll( "+user+", "+role+", "+currDate+") = "+retVals.size());
			for (Timesheet ts : retVals){
				logger.debug(ts);
			}
		}
		return retVals;
	}
		
	public Timesheet find(int employeeSeq, String location, Date date){
		String sql =
			"SELECT t.employeeSeq, t.date, concat(e.lastName, ', ', e.firstName, ' ', e.title) as name, t.location, t.worked, t.overtime, "+
			"t.vacation, t.sick, t.floating, t.holiday, t.other, t.comments "+
			"FROM timesheet t, employee e "+
			"WHERE t.employeeSeq = e.employeeSeq and t.employeeSeq = ? and t.date = ? and t.location = ?";
		RowMapper mapper = new TimesheetRowMapper();		
		JdbcTemplate template = new JdbcTemplate(this.getDataSource());
		Object[] params = new Object[] { employeeSeq, date, location };
		List result = template.query(sql, params, mapper);
		if (result.size() > 0){
			if (logger.isDebugEnabled()){
				logger.debug("find( "+employeeSeq+", "+location+", "+date+") = "+result.get(0));
			}
			return (Timesheet)result.get(0);
		}else{
			if (logger.isDebugEnabled()){
				logger.debug("find( "+employeeSeq+", "+location+", "+date+") = null");
			}
			return null;
		}
	}
	
	public int createOrUpdateTimesheet(Timesheet ts){
		Timesheet timesheet = find(ts.getEmployeeSeq(), ts.getLocation(), ts.getDate());
		if (timesheet != null){
			return updateTimesheet(ts);
		}else{
			return createTimesheet(ts);
		}
	}
	
	public int updateTimesheet(Timesheet ts){
		String updateTimesheetSql = 
			"UPDATE timesheet SET worked=:worked, overtime=:overtime, vacation=:vacation, "+
			"sick=:sick, floating=:floating, holiday=:holiday, other=:other, "+
			"comments=:comments, createdBy=:createdBy "+
			"WHERE employeeSeq=:employeeSeq and date=:date and location=:location";
		NamedParameterJdbcTemplate template = new NamedParameterJdbcTemplate(this.getDataSource());
		SqlParameterSource namedParameters = new BeanPropertySqlParameterSource(ts);
		int numUpdated = template.update(updateTimesheetSql, namedParameters);
		if (logger.isDebugEnabled()){
			logger.debug("updateTimesheet( "+ts+" ) = "+numUpdated);
		}
		return numUpdated;
	}
	
	public int createTimesheet(Timesheet ts){
		String createTimesheetSql = 
			"INSERT into timesheet ("+
			"employeeSeq, location, date, worked, overtime, vacation, sick, floating, holiday, other, comments, createdBy) " +
			"VALUES ("+
			":employeeSeq, :location, :date, :worked, :overtime, :vacation, :sick, :floating, :holiday, :other, :comments, :createdBy)";
		NamedParameterJdbcTemplate template = new NamedParameterJdbcTemplate(this.getDataSource());
		SqlParameterSource namedParameters = new BeanPropertySqlParameterSource(ts);
		int numUpdated = template.update(createTimesheetSql, namedParameters);
		if (logger.isDebugEnabled()){
			logger.debug("createTimesheet( "+ts+" )  = "+numUpdated);
		}
		return numUpdated;		
	}
	
	public List<Timesheet> generateReport(String user, Date fromDate, Date toDate){
		String sql = 
			"SELECT t.employeeSeq, concat(e.lastName, ', ', e.firstName, ' ', e.title) as name, t.location, "+
			"sum(t.worked) as worked, sum(t.overtime) as overtime, sum(t.vacation) as vacation, sum(t.sick) as sick, sum(t.floating) as floating, "+
			"sum(t.holiday) as holiday, sum(t.other) as other "+
			"from timesheet t, viewMapping v, user u, employee e "+
			"where u.userId = ? and "+
			"u.employeeViewSeq = v.employeeViewSeq and "+
			"v.employeeSeq = t.employeeSeq and v.location = t.location and "+
			"t.employeeSeq = e.employeeSeq "+
			"and t.date between ? and ? "+
			"group by employeeSeq, name, location";			
						
		List<Timesheet> retVals = new ArrayList<Timesheet>();						
		
		RowMapper mapper = new ReportRowMapper();		
		JdbcTemplate template = new JdbcTemplate(this.getDataSource());
		Object[] params = new Object[] { user, fromDate, toDate };		
		List<Timesheet> result = template.query(sql, params, mapper);
		
		retVals.addAll(result);
		
		boolean found = false;
		List<ViewMapping> mappings = getViewMapping(user);		
		for (ViewMapping vm : mappings){
			for (Timesheet ts : result){
				if (ts.getName().equals(vm.getEmployeeName()) && ts.getLocation().equals(vm.getLocation())){
					found = true;
					break;
				}
			}
			if (!found){
				Timesheet ts = new Timesheet();
				ts.setEmployeeSeq(vm.getEmployeeSeq());
				ts.setLocation(vm.getLocation());
				ts.setName(vm.getEmployeeName());
				ts.setCreatedBy(user);
				retVals.add(ts);
			}
			found = false;
		}
		
		Collections.sort(retVals);
		
		String period = df.format(fromDate)+" - "+df.format(toDate);
		for (Timesheet ts : retVals){
			ts.setPeriod(period);
		}
		
		if (logger.isDebugEnabled()){
			logger.debug("findAll( "+user+", "+fromDate+", "+toDate+" ) = "+retVals.size());
			for (Timesheet ts : retVals){
				logger.debug(ts);
			}
		}
		return retVals;
	}
	
	public List<Employee> getAllEmployee(String user){
		String sql = 
			"select distinct e.employeeSeq, e.lastName, e.middleName, e.firstName, e.title "+
			"from employee e, viewMapping vm, user u "+
			"where u.userId = ? and u.employeeViewSeq = vm.employeeViewSeq and vm.employeeSeq = e.employeeSeq "+
			"order by lastName, firstName";
									
		RowMapper mapper = new EmployeeRowMapper();		
		JdbcTemplate template = new JdbcTemplate(this.getDataSource());
		Object[] params = new Object[] { user };		
		List<Employee> result = template.query(sql, params, mapper);		
		return result;		
	}

	public List<Timesheet> generateEmployeeReport(String user, Date fromDate, Date toDate, Employee emp){
		String sql = 
			"SELECT t.date, t.location, t.worked, t.overtime, t.vacation, t.sick, t.floating, t.holiday, t.other "+ 
			"from timesheet t, viewMapping v, user u, employee e "+
			"where u.userId = ? and "+
			"u.employeeViewSeq = v.employeeViewSeq and "+
			"v.employeeSeq = t.employeeSeq and v.location = t.location and "+
			"t.employeeSeq = e.employeeSeq "+
			"and t.date between ? and ? "+
			"and t.employeeSeq = ? "+
			"order by t.date ";
						
		RowMapper mapper = new EmpReportRowMapper();		
		JdbcTemplate template = new JdbcTemplate(this.getDataSource());
		Object[] params = new Object[] { user, fromDate, toDate, emp.getEmployeeSeq() };		
		List<Timesheet> result = template.query(sql, params, mapper);				
		return result;		
	}
	
	private class EmpReportRowMapper implements RowMapper {
		public Object mapRow(ResultSet rs, int rowNum) throws SQLException {
			Timesheet ts = new Timesheet();
			ts.setDate(rs.getDate("date"));
			ts.setLocation(rs.getString("location"));
			ts.setWorked(rs.getFloat("worked"));
			ts.setOvertime(rs.getFloat("overtime"));
			ts.setVacation(rs.getFloat("vacation"));
			ts.setSick(rs.getFloat("sick"));
			ts.setFloating(rs.getFloat("floating"));
			ts.setHoliday(rs.getFloat("holiday"));
			ts.setOther(rs.getFloat("other"));		
			return ts;
		}
	}	
	
	private class ReportRowMapper implements RowMapper {
		public Object mapRow(ResultSet rs, int rowNum) throws SQLException {
			Timesheet ts = new Timesheet();
			ts.setEmployeeSeq(rs.getInt("employeeSeq"));
			ts.setName(rs.getString("name"));
			ts.setLocation(rs.getString("location"));
			ts.setWorked(rs.getFloat("worked"));
			ts.setOvertime(rs.getFloat("overtime"));
			ts.setVacation(rs.getFloat("vacation"));
			ts.setSick(rs.getFloat("sick"));
			ts.setFloating(rs.getFloat("floating"));
			ts.setHoliday(rs.getFloat("holiday"));
			ts.setOther(rs.getFloat("other"));		
			return ts;
		}
	}

	private class TimesheetRowMapper implements RowMapper {
		public Object mapRow(ResultSet rs, int rowNum) throws SQLException {
			Timesheet ts = new Timesheet();
			ts.setEmployeeSeq(rs.getInt("employeeSeq"));
			ts.setDate(rs.getDate("date"));
			ts.setName(rs.getString("name"));
			ts.setLocation(rs.getString("location"));
			ts.setWorked(rs.getFloat("worked"));
			ts.setOvertime(rs.getFloat("overtime"));
			ts.setVacation(rs.getFloat("vacation"));
			ts.setSick(rs.getFloat("sick"));
			ts.setFloating(rs.getFloat("floating"));
			ts.setHoliday(rs.getFloat("holiday"));
			ts.setOther(rs.getFloat("other"));
			ts.setComments(rs.getString("comments"));		
			return ts;
		}
	}
	
	private class EmployeeRowMapper implements RowMapper {
		public Object mapRow(ResultSet rs, int rowNum) throws SQLException {
			Employee e = new Employee();
			e.setEmployeeSeq(rs.getInt("employeeSeq"));
			e.setLastName(rs.getString("lastName"));
			e.setMiddleName(rs.getString("middleName"));
			e.setFirstName(rs.getString("firstName"));
			e.setTitle(rs.getString("title"));
			e.setFullName(e.getLastName()+", "+e.getFirstName()+" "+e.getTitle());
			return e;
		}
	}
	
}
