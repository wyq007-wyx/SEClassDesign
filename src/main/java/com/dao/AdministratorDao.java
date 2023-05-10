package com.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

import com.pojo.*;

@Repository("administratorDao")
@Mapper
public interface AdministratorDao {

	// 从用户表中查询所有用户的信息
	List<UserInfo> selectAllUserInfo();

	// 根据单位名称模糊查询
	List<UserInfo> selectUserFuzzy(String username);

	// 用于注册时判断重名
	List<String> selectRenamedUsers(String username);
	
	// 管理员添加一名用户信息，由管理员创建的，默认角色是工作人员
	int addUser(UserInfo user);

	// 修改用户信息
	int updateUser(UserInfo userInfo);

	// 删除用户信息前从question表中删除其问题信息
	int deleteQuestionOfUser(int user_id);

	// 删除用户信息
	int deleteUser(int user_id);

}
