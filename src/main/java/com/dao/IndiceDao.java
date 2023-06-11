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
	// 获取所有的体系信息
	List<SchemeInfo> selectAllSchemeInfo(@Param("user_id") int user_id, @Param("isInstance") int isInstance);

	// 根据id查询体系信息
	SchemeInfo selectSchemeInfoById(int scheme_id);

	// 获取所有的算子信息
	List<OperatorInfo> selectAllOperator();

	// 获取一个用户的所有的算子信息
	List<OperatorInfo> selectUserOperators(int user_id);

	//为一名用户增添多个算子
	int addUserOperators(@Param("user_id") int user_id, @Param("list") List<Integer> selectedAddOps);
	
	//删除一名用户的多个算子
	int deleteUserOperators(@Param("user_id") int user_id, @Param("list") List<OperatorInfo> selectedDelOps);
	
	//根据用户id查询用户在实例中已使用的算子
	List<Integer> selectUsedOperators(int user_id);
	
	// 获取一名用户没有的算子
	List<OperatorInfo> selectUserNotHaveOperators(int user_id);

	// 修改当前用户信息
	int updateCurrentUserInfo(UserInfo user);

	// 插入前判断该用户下是否存在同名体系
	List<SchemeInfo> selectRenamedScheme(SchemeInfo scheme);

	// 新增体系
	int insertScheme(SchemeInfo scheme);

	// 根据体系名称模糊查询
	List<SchemeInfo> selectSchemeFuzzy(@Param("scheme_name") String scheme_name, @Param("user_id") int user_id,
			@Param("isInstance") int isInstance);

	int updateSchemeInfo(SchemeInfo scheme);

	// 根据体系id删除体系
	int deleteScheme(int scheme_id);

	// 获取单个体系的所有指标信息
	List<IndiceInfo> getSingleSchemeDetailInfo(@Param("scheme_id") int scheme_id, @Param("user_id") int user_id);

	// 删除一个指标
	int deleteIndice(int indice_id);

	// 创建一个指标
	int insertIndiceInfo(IndiceInfo indice);

	// 更新一个指标
	int updateIndiceInfo(IndiceInfo indice);

	// 根据指标id、体系id查询指标
	IndiceInfo selectIndiceInfoByIndice_id(@Param("indice_id") int indice_id, @Param("scheme_id") int scheme_id);

	// 根据体系id查询体系名称
	String selectScheme_nameByScheme_id(int scheme_id);
}
