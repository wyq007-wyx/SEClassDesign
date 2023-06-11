package com.pojo;

import java.util.Date;

import com.alibaba.fastjson.annotation.JSONField;

public class Result {
	private int id;// 主键
	private int scheme_id;// 指标所属体系id
	private String indice_name;// 指标名
	private double indice_value;// 计算值
	private int groupId;// 分组
	 @JSONField(format = "yyyy-MM-dd HH:mm:ss") // 在时间属性上面加上该注解，前端可以自动解析
	 private Date exec_time;// 计算时间

	public Result() {
	}
	
	

	public Result(int scheme_id, String indice_name, double indice_value, int groupId, Date exec_time) {
		super();
		this.scheme_id = scheme_id;
		this.indice_name = indice_name;
		this.indice_value = indice_value;
		this.groupId = groupId;
		this.exec_time = exec_time;
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

	public String getIndice_name() {
		return indice_name;
	}

	public void setIndice_name(String indice_name) {
		this.indice_name = indice_name;
	}

	public double getIndice_value() {
		return indice_value;
	}

	public void setIndice_value(double indice_value) {
		this.indice_value = indice_value;
	}

	public int getGroupId() {
		return groupId;
	}

	public void setGroupId(int groupId) {
		this.groupId = groupId;
	}

	public Date getExec_time() {
		return exec_time;
	}

	public void setExec_time(Date exec_time) {
		this.exec_time = exec_time;
	}

	

}