package com.pojo;

public class SchemeInfo {
	private int scheme_id;
	private String scheme_name;//体系名
	private int user_id;//用户id
	private int isInstance;//是否是实例
	
	public SchemeInfo() {
	}
	public SchemeInfo(String scheme_name, int user_id, int isInstance) {
		this.scheme_name = scheme_name;
		this.user_id = user_id;
		this.isInstance = isInstance;
	}
	//getter and setter
	public int getScheme_id() {
		return scheme_id;
	}
	public void setScheme_id(int scheme_id) {
		this.scheme_id = scheme_id;
	}
	public String getScheme_name() {
		return scheme_name;
	}
	public void setScheme_name(String scheme_name) {
		this.scheme_name = scheme_name;
	}
	public int getUser_id() {
		return user_id;
	}
	public void setUser_id(int user_id) {
		this.user_id = user_id;
	}
	public int getIsInstance() {
		return isInstance;
	}
	public void setIsInstance(int isInstance) {
		this.isInstance = isInstance;
	}
}
