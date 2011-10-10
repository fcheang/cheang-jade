package com.suntek.timesheet;

import java.util.Date;

public class Timesheet implements Comparable {

	private int employeeSeq;
	private String period = "";
	private Date date;
	private String name = "";
	private String location = "";
	private float worked = 0;
	private float overtime = 0;
	private float vacation = 0;
	private float sick = 0;
	private float floating = 0;
	private float holiday = 0;
	private float other = 0;
	private String comments = "";
	private String createdBy = "";
	
	public String getComments() {
		return comments;
	}
	
	public void setComments(String comments) {
		this.comments = comments;
	}
	
	public float getFloating() {
		return floating;
	}
	
	public void setFloating(float floating) {
		this.floating = floating;
	}
	
	public float getHoliday() {
		return holiday;
	}
	
	public void setHoliday(float holiday) {
		this.holiday = holiday;
	}
	
	public String getLocation() {
		return location;
	}
	
	public void setLocation(String location) {
		this.location = location;
	}
	
	public String getName() {
		return name;
	}
	
	public void setName(String name) {
		this.name = name;
	}
	
	public float getOther() {
		return other;
	}
	
	public void setOther(float other) {
		this.other = other;
	}
	
	public float getOvertime() {
		return overtime;
	}
	
	public void setOvertime(float overtime) {
		this.overtime = overtime;
	}
	
	public float getSick() {
		return sick;
	}
	
	public void setSick(float sick) {
		this.sick = sick;
	}
	
	public float getVacation() {
		return vacation;
	}
	
	public void setVacation(float vacation) {
		this.vacation = vacation;
	}
	
	public float getWorked() {
		return worked;
	}
	
	public void setWorked(float worked) {
		this.worked = worked;
	}

	public Date getDate() {
		return date;
	}

	public void setDate(Date date) {
		this.date = date;
	}

	public int getEmployeeSeq() {
		return employeeSeq;
	}

	public void setEmployeeSeq(int employeeSeq) {
		this.employeeSeq = employeeSeq;
	}

	public String getCreatedBy() {
		return createdBy;
	}

	public void setCreatedBy(String createdBy) {
		this.createdBy = createdBy;
	}	
	
	public String toString(){
		StringBuilder sb = new StringBuilder();
		sb.append("Timesheet:").append(" ");
		sb.append("employeeSeq=").append(employeeSeq).append(" ");
		sb.append("period=").append(period).append(" ");
		sb.append("date=").append(date).append(" ");
		sb.append("name=").append(name).append(" ");
		sb.append("location=").append(location).append(" ");
		sb.append("worked=").append(worked).append(" ");
		sb.append("overtime=").append(overtime).append(" ");
		sb.append("vacation=").append(vacation).append(" ");
		sb.append("sick=").append(sick).append(" ");
		sb.append("floating=").append(floating).append(" ");
		sb.append("holiday=").append(holiday).append(" ");
		sb.append("other=").append(other).append(" ");
		sb.append("total=").append(getTotal()).append(" ");
		sb.append("comments=").append(comments).append(" ");
		sb.append("createdBy=").append(createdBy);
		return sb.toString();
	}
	
	public int compareTo(Object o){
		Timesheet ts = (Timesheet)o;
		return this.name.compareTo(ts.name);
	}

	public void setTotal(float total){		
	}
	
	public float getTotal() {
		return worked + overtime + vacation + sick + floating + holiday + other;
	}

	public String getPeriod() {
		return period;
	}

	public void setPeriod(String period) {
		this.period = period;
	}

}
