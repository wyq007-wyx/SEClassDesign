package com.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import com.pojo.IndiceInfo;
import com.pojo.SchemeInfo;
import com.pojo.UserInfo;

@Repository("indiceDao")
@Mapper
public interface IndiceDao {
	List<SchemeInfo> selectAllSchemeInfo(int user_id);
	
	int updateCurrentUserInfo(UserInfo user);
	
	int insertScheme(SchemeInfo scheme);
	
	// 根据单位名称模糊查询
	List<SchemeInfo> selectSchemeFuzzy(@Param("scheme_name") String scheme_name, @Param("user_id") int user_id);
	
	int updateSchemeInfo(SchemeInfo scheme);

	//根据体系id删除体系
	int deleteScheme(int scheme_id);

	//获取单个体系的所有指标信息
	List<IndiceInfo> getSingleSchemeDetailInfo(@Param("scheme_id") int scheme_id, @Param("user_id") int user_id);
}
