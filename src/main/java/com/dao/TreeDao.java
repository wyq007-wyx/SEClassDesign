package com.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import com.pojo.IndiceInfo;

@Repository("treeDao")
@Mapper
public interface TreeDao {
	//查找根节点
	IndiceInfo selectRoot(@Param("scheme_id")int scheme_id,@Param("root_id")int indice_id);
	//查找子节点
	List<IndiceInfo> selectIndiceBySystemIdAndFatherId(@Param("scheme_id")int scheme_id,@Param("father_id")int father_id);
	//真正的查找子节点
	List<IndiceInfo> selectChildrenByFatherId(int father_id);
	//添加子节点
	int addTreeNode(IndiceInfo indiceInfo);
	//更新节点
	int updateIndice(IndiceInfo node);
	//根据体系id删除体系
	int deleteScheme(int scheme_id);
	//删除体系下的所有指标
	int deleteSchemeIndice(@Param("scheme_id") int scheme_id);
	//删除一个指标
	int deleteIndice(int indice_id);
	//删除子指标
	int deleteChildren(int indice_id);
}
