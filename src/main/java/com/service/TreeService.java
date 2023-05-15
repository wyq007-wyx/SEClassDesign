package com.service;


import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;
import com.alibaba.fastjson.JSON;
import com.dao.TreeDao;
import com.pojo.IndiceInfo;
import com.pojo.TreeNode;

@Service("treeService")
public class TreeService {
	@Resource
	private TreeDao treeDao;
	
	private TreeNode tree=null;
	public TreeService() {
		// TODO Auto-generated constructor stub
	}
	/**
	 * 添加一个指标节点
	 * @param indiceInfo
	 * @return
	 */
	public int addTreeNode(IndiceInfo indiceInfo) {
		int indice_id=treeDao.addTreeNode(indiceInfo);
		return indice_id;
	}
	/**
	 * @param system_id 体系id
	 * @return 返回一个体系树的JSON序列
	 */
	public String getTreeNode(int scheme_id){
		//体系树
		IndiceInfo rootInfo=treeDao.selectRoot(scheme_id,-1);
		System.out.println("rootinfo:"+rootInfo);
		if(rootInfo==null) return "";
		tree=new TreeNode(rootInfo.getIndice_name(),null,rootInfo);
		dfs(tree,scheme_id);
		String Jsontree=JSON.toJSONString(tree);
		return Jsontree;
	}
	/**
	 * 当前节点获取孩子指标列表
	 * @param infolist
	 * @return
	 */
	private List<TreeNode> getChildren(List<IndiceInfo> infolist){
		List<TreeNode> children = new ArrayList<>();
		for(IndiceInfo i:infolist) {
			TreeNode t=new TreeNode(i.getIndice_name(),null,i);
			children.add(t);
		}
		return children;
	}
	/**
	 * 更新节点信息
	 * @param node
	 * @return
	 */
	public int updateIndice(IndiceInfo node) {
		return treeDao.updateIndice(node);
	}
	/**
	 * 递归求每一个节点的孩子列表
	 * @param node
	 * @param scheme_id
	 */
	private void dfs(TreeNode node,int scheme_id) {
		List<IndiceInfo> infoList=treeDao.selectIndiceBySystemIdAndFatherId(scheme_id,node.getIndice().getIndice_id());
		node.setChildren(getChildren(infoList));
		if(node.getChildren().size() == 0) {
			return;
		}
		for(TreeNode n:node.getChildren()) {
			dfs(n, scheme_id);
		}
	}
	/**
	 * 删除指标树和它的所有指标
	 * @param scheme_id
	 * @return
	 */
	public int deleteTreeAndInDice(int sid) {
		///先删除体系下的所有指标
		int deletenums=treeDao.deleteSchemeIndice(sid);
		//再删除体系
		int deletesnums=treeDao.deleteScheme(sid);
		System.out.println(deletesnums);
		return deletenums;
	}
	/**
	 * 删除体系树上的某个节点及其子节点
	 * @param sid
	 * @return
	 */
	public int deleteTreeNode(int indice_id) {
		dfsForDelete(null, indice_id);
		return 1;
	}
	public void dfsForDelete(IndiceInfo root, int indice_id) {
		List<IndiceInfo> children;
		if(root == null) {
			children = treeDao.selectChildrenByFatherId(indice_id);
		}else {
			children = treeDao.selectChildrenByFatherId(root.getIndice_id());
		}
		for(IndiceInfo child : children) {
			dfsForDelete(child, indice_id);
		}
		if(root == null) {
			treeDao.deleteIndice(indice_id);
		}else {
			treeDao.deleteIndice(root.getIndice_id());
		}
	}
}
