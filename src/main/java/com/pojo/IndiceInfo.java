package com.pojo;

public class IndiceInfo {
	private Integer indice_id;//指标id
	private String indice_name;//指标名称
	private Double indice_weight;//指标权重
	private Double indice_value;//指标值
	private Integer  father_id;//指标父节点
	private Integer operator_id;//指标算子
	private int scheme_id;//指标所属体系
	
	
	
	
	public IndiceInfo() {
	}
	public IndiceInfo(String indice_name, Double indice_weight, Double indice_value, Integer father_id,
			Integer operator_id, int scheme_id) {
		this.indice_name = indice_name;
		this.indice_weight = indice_weight;
		this.indice_value = indice_value;
		this.father_id = father_id;
		this.operator_id = operator_id;
		this.scheme_id = scheme_id;
	}
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
	@Override
	public String toString() {
		return "IndiceInfo [indice_id=" + indice_id + ", indice_name=" + indice_name + ", indice_weight="
				+ indice_weight + ", indice_value=" + indice_value + ", father_id=" + father_id + ", operator_id="
				+ operator_id + ", system_id=" + scheme_id + "]";
	}
	public void display() {
		System.out.println("[indice_id:"+indice_id+",indice_name:"+indice_name+"]");
	}
	
}
