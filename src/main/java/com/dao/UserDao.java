package com.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

import com.po.RemarkMessage;
import com.po.User;
@Repository("userDao")
@Mapper
public interface UserDao {
	//用于登录
	User selectUserByNameAndPwd(User user);
	//获取本人之前的留言
	List<RemarkMessage> getSelfRemarkMessage(int userID);
	//用于注册时判断重名
	List<User> selectRenamedUsers(String userName);
	//用于注册时添加用户
	int addUser(User user);
}
