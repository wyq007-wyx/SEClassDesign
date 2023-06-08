package com.pojo;

import java.util.Date;

import com.alibaba.fastjson.annotation.JSONField;

public class Result {
	private int id;// 主键
	private int scheme_id;// 指标所属体系id
	private String name;// 指标名
	private double value;// 计算值
	private int groupId;// 分组
	 @JSONField(format = "yyyy-MM-dd HH:mm:ss") // 在时间属性上面加上该注解，前端可以自动解析
	 private Date time;// 计算时间

	public Result() {
	}

	public Result(int id, int scheme_id, String name, double value, int groupId, Date time) {
		this.id = id;
		this.scheme_id = scheme_id;
		this.name = name;
		this.value = value;
		this.groupId = groupId;
		this.time = time;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getScheme_id() {
		return scheme_id;
	}

	public void setScheme_id(int scheme_id) {
		this.scheme_id = scheme_id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public double getValue() {
		return value;
	}

	public void setValue(double value) {
		this.value = value;
	}

	public int getGroupId() {
		return groupId;
	}

	public void setGroupId(int groupId) {
		this.groupId = groupId;
	}

	public Date getTime() {
		return time;
	}

	public void setTime(Date time) {
		this.time = time;
	}

	public Result(int scheme_id, String name, double value, int groupId, Date time) {
		super();
		this.scheme_id = scheme_id;
		this.name = name;
		this.value = value;
		this.groupId = groupId;
		this.time = time;
	}

}