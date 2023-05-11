package com.pojo;
/**
 * 用户的详细信息
 * @author 23208
 *
 */
public class UserInfo{
	private int user_id;
	private String username;//用户名
	private String password;//密码
	private String email;//电子邮箱
	
	public int getUser_id() {
		return user_id;
	}
	public void setUser_id(int user_id) {
		this.user_id = user_id;
	}
	public String getUsername() {
		return username;
	}
	public void setUsername(String username) {
		this.username = username;
	}
	public String getPassword() {
		return password;
	}
	public void setPassword(String password) {
		this.password = password;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	
	
	
}
