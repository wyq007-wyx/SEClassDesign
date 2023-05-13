package com.pojo;

import java.util.List;

public class TreeNode {
	private String name;//体系树节点名称
	private List<TreeNode> children;//节点孩子列表
	private IndiceInfo indice;//体系树节点其他信息
	
	public IndiceInfo getIndice() {
		return indice;
	}
	public void setIndice(IndiceInfo indice) {
		this.indice = indice;
	}
	public TreeNode(String name, List<TreeNode> children, IndiceInfo indice) {
		super();
		this.name = name;
		this.children = children;
		this.indice = indice;
	}
	public TreeNode() {
		//super();
	}
	public TreeNode(String name, List<TreeNode> children) {
		this.name = name;
		this.children = children;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public List<TreeNode> getChildren() {
		return children;
	}
	public void setChildren(List<TreeNode> children) {
		this.children = children;
	}
	@Override
	public String toString() {
		return "TreeNode [name=" + name + ", children=" + children + ", indice=" + indice + "]";
	}
	
	
	
	
}
