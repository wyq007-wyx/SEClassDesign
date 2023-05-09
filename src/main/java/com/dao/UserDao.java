package com.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import com.pojo.QuestionInfo;
import com.pojo.UserInfo;

@Repository("userDao")
@Mapper
public interface UserDao {
	// 用于登录
	UserInfo selectUserByNameAndPwd(@Param("username") String username, @Param("password")String password);

	// 用于注册时判断重名
	List<String> selectRenamedUsers(String username);

	// 用于注册时添加用户
	int addUser(UserInfo user);

	//添加重置密码的问题信息
	int addQuestionInfo(QuestionInfo questionInfo);
	
	//获取重置密码的问题信息
	QuestionInfo selectQuestionInfo(String username);
	
	//修改密码
	int updatePassword(@Param("user_id") int user_id, @Param("password") String password);
}
