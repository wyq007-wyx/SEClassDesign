package com.pojo;

public class IndiceInfo {
	private Integer indice_id;//指标id
	private String indice_name;//指标名
	private Double indice_weight;//指标权重，可以为null
	private Double indice_value;//指标值，可以为null
	private Integer father_id;//父节点id
	private Integer operator_id;//算子id
	private int scheme_id;//所属体系id
	//getter and setter
	public Integer getIndice_id() {
		return indice_id;
	}
	public void setIndice_id(Integer indice_id) {
		this.indice_id = indice_id;
	}
	public String getIndice_name() {
		return indice_name;
	}
	public void setIndice_name(String indice_name) {
		this.indice_name = indice_name;
	}
	public Double getIndice_weight() {
		return indice_weight;
	}
	public void setIndice_weight(Double indice_weight) {
		this.indice_weight = indice_weight;
	}
	public Double getIndice_value() {
		return indice_value;
	}
	public void setIndice_value(Double indice_value) {
		this.indice_value = indice_value;
	}
	public Integer getFather_id() {
		return father_id;
	}
	public void setFather_id(Integer father_id) {
		this.father_id = father_id;
	}
	public Integer getOperator_id() {
		return operator_id;
	}
	public void setOperator_id(Integer operator_id) {
		this.operator_id = operator_id;
	}
	public int getScheme_id() {
		return scheme_id;
	}
	public void setScheme_id(int scheme_id) {
		this.scheme_id = scheme_id;
	}
	
	
	
}
