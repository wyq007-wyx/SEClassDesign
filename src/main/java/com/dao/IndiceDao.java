package com.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import com.pojo.IndiceInfo;
import com.pojo.OperatorInfo;
import com.pojo.SchemeInfo;
import com.pojo.UserInfo;

@Repository("indiceDao")
@Mapper
public interface IndiceDao {
	//获取所有的体系信息
	List<SchemeInfo> selectAllSchemeInfo(int user_id);
	//获取所有的算子信息
	List<OperatorInfo> selectAllOperator();
	//修改当前用户信息
	int updateCurrentUserInfo(UserInfo user);
	//新增体系
	int insertScheme(SchemeInfo scheme);
	
	// 根据单位名称模糊查询
	List<SchemeInfo> selectSchemeFuzzy(@Param("scheme_name") String scheme_name, @Param("user_id") int user_id);
	
	int updateSchemeInfo(SchemeInfo scheme);

	//根据体系id删除体系
	int deleteScheme(int scheme_id);

	//获取单个体系的所有指标信息
	List<IndiceInfo> getSingleSchemeDetailInfo(@Param("scheme_id") int scheme_id, @Param("user_id") int user_id);

	//删除一个指标
	int deleteIndice(int indice_id);
}
