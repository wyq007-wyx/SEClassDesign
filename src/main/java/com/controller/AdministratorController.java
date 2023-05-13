package com.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import com.alibaba.fastjson.JSON;
import com.dao.AdministratorDao;
import com.pojo.*;

@Controller
@RequestMapping("/RequestFromAdminPage.do")
public class AdministratorController {
	@Autowired
	private AdministratorDao administratorDao;

	/**
	 * 获取所有的用户信息
	 * 
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=UserInfoForDisplay")
	public void getAllUsersInfo(HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=UserInfoForDisplay的url请求");
		List<UserInfo> data = this.administratorDao.selectAllUserInfo();
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(data));
	}

	/**
	 * 退出登录
	 * 
	 * @param request
	 * @throws IOException
	 */
	@RequestMapping(params = "request=logout")
	public void logout(HttpServletRequest request, HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=logout的url请求");
		// 从session作用域中删除当前用户
		HttpSession session = request.getSession();
		session.removeAttribute("currentUser");
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString("success"));
	}

	/**
	 * 根据用户名模糊查询
	 * 
	 * @param unitName
	 * @throws IOException
	 */
	@RequestMapping(params = "request=fuzzyQueryByUsername")
	public void fuzzyQueryByUserName(String username, HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=fuzzyQueryByUsername的url请求");
		String like = '%' + username + '%';// 模糊查询
		List<UserInfo> data = this.administratorDao.selectUserFuzzy(like);
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(data));
	}

	/**
	 * 管理员添加一名用户
	 * 
	 * @param unitName
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=addUserByAdmin")
	public void addUserByAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=addUserByAdmin的url请求");
		// 使用request来获取请求体中的数据，@RequestBody没有测试出来
		BufferedReader br = request.getReader();
		String line = br.readLine();
		UserInfo user = JSON.parseObject(line, UserInfo.class);// 把JSON字符串解析为JavaBean
		int num = 0;
		if(this.administratorDao.selectRenamedUsers(user.getUsername()).size() > 0) {
			num = -1;
		}else {
			num = this.administratorDao.addUser(user);// 向用户表插入一条记录，得到数据表回填的主键user_id
		}
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(num));
	}

	/**
	 * 管理员修改一名用户
	 * 
	 * @param request
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=changeUser")
	public void updateUser(/* @RequestBody UserInfo user */HttpServletRequest request, HttpServletResponse response)
			throws IOException {
		System.out.println("捕获到参数为request=changeUser的url请求");
		// 使用request来获取请求体中的数据，@RequestBody没有测试出来
		BufferedReader br = request.getReader();
		String line = br.readLine();
		UserInfo user = JSON.parseObject(line, UserInfo.class);// 把JSON字符串解析为JavaBean
		int num = this.administratorDao.updateUser(user);
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(num));
	}

	/**
	 * 管理员删除一名用户
	 * 
	 * @param request
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=deleteUserByAdmin")
	public void deleteUserByAdmin(String user_id, HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=deleteUserByAdmin的url请求");
		// 从请求体中读取出userID
		try {
			int id = Integer.parseInt(user_id);
			int num = 0;
			this.administratorDao.deleteQuestionOfUser(id);// 删除用户信息前从question表中删除其问题信息
			num = this.administratorDao.deleteUser(id);// 从用户表中删除用户记录
			response.setContentType("text/json;charset=utf-8");
			response.getWriter().write(JSON.toJSONString(num));
		} catch (NumberFormatException e) {
			e.printStackTrace();
		}
	}
}
