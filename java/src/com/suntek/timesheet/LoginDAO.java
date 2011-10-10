/**
 * Created at Jan 19, 2009
 */
package com.suntek.timesheet;

import org.springframework.dao.DataAccessException;

/**
 * @author Steve Cheang
 *
 */
public interface LoginDAO {

	public User login(String userName, String password) throws DataAccessException;
}
