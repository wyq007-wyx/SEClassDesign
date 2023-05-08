package com.po;

/**
 * 对应于user表的JavaBean
 * 
 * @author 23208
 *
 */
public class User {
	private int userID;// 用户ID
	private String userName;// 用户名
	private String password;// 密码
	// getter and setter

	public int getUserID() {
		return userID;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

}
