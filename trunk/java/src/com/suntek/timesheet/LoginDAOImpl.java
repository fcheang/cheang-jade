/**
 * Created at Jan 19, 2009
 */
package com.suntek.timesheet;

import java.sql.*;
import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.support.JdbcDaoSupport;

/**
 * @author Steve Cheang
 *
 */
public class LoginDAOImpl extends JdbcDaoSupport implements LoginDAO {	
	
	private static Logger logger = Logger.getLogger(LoginDAOImpl.class.getName());
	
	public User login(String userName, String password) throws DataAccessException {
		Connection con = this.getConnection();
		try{
			String sql = "select userId, password, role, assignedTo from user where userId = ? and password = ?";
	
			RowMapper mapper = new UserRowMapper();		
			JdbcTemplate template = new JdbcTemplate(this.getDataSource());
			Object[] params = new Object[] { userName, password };		
			List<User> result = template.query(sql, params, mapper);
			if (result != null && result.size() > 0){
				return (User)result.get(0);
			}else{
				return null;
			}
		}finally{
			this.releaseConnection(con);
		}
	}
	
	private class UserRowMapper implements RowMapper {
		public Object mapRow(ResultSet rs, int rowNum) throws SQLException {
			User u = new User();
			u.setUserId(rs.getString("userId"));
			u.setPassword(rs.getString("password"));
			u.setRole(rs.getString("role"));
			u.setAssignedTo(rs.getString("assignedTo"));
			return u;
		}
	}
	
}
