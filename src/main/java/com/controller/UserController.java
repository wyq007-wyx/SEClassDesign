package com.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.SessionAttributes;

import com.dao.UserDao;
import com.po.RemarkMessage;
import com.po.User;

@Controller
@SessionAttributes(value= {"currentUser"})
public class UserController {
	@Autowired
	private UserDao userDao;
	/**
	 * 处理登录
	 * @param user 登录表单封装成的JavaBean
	 * @param model
	 * @return
	 */
	@RequestMapping("/GetLogin.do")
	public String getLogin(User user, Model model) {
		//判断用户名密码是否匹配
		User currentUser = userDao.selectUserByNameAndPwd(user);
		if(currentUser != null) {
			//获取本人的留言
			List<RemarkMessage> list = this.userDao.getSelfRemarkMessage(currentUser.getUserID());
			//将用户信息存储在session作用域
			model.addAttribute("currentUser", currentUser);
			model.addAttribute("selfRemarkMessage", list);
			return "remarkBoard";
		}else {
			model.addAttribute("loginErrorInfo", "用户名密码不匹配，请重新登录！");
			return "loginError";
		}
	}
	/**
	 * 处理注册请求
	 * @param user
	 * @param model
	 * @return
	 */
	@RequestMapping("/GetRegister.do")
	public String getRegister(User user, Model model) {
		//判断是否发生重名
		if(userDao.selectRenamedUsers(user.getUserName()).size() == 0) {
			userDao.addUser(user);
			model.addAttribute("registerSuccessfullyInfo", "注册成功");
			return "registerSuccessfully";
		}else {
			model.addAttribute("registerErrorInfo", "注册发生重名，请重新注册");
			return "registerError";
		}
	}
}
