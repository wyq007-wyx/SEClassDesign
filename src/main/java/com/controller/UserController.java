package com.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.Random;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.SessionAttributes;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.dao.UserDao;
import com.pojo.QuestionInfo;
import com.pojo.UserInfo;
import com.util.SendEmail;

@Controller
@SessionAttributes(value = { "currentUser" })
public class UserController {
	@Autowired
	private UserDao userDao;
	private String emailCode = "";// 暂时储存邮箱验证码

	/**
	 * 处理登录请求
	 * 
	 * @param username 用户名
	 * @param password 密码
	 * @param model
	 * @return
	 */
	@RequestMapping("/GetLogin.do")
	public String getLogin(String username, String password, Model model) {
		UserInfo currentUser = this.userDao.selectUserByNameAndPwd(username, password);
		if (currentUser != null) {
			model.addAttribute("currentUser", JSONObject.toJSON(currentUser));// JavaBean转换为JSON对象，供Vue中使用
			if (username.equals("admin")) {// 管理员
				return "administratorPage";
			} else {// 普通用户
				return "indiceManagePage";
			}
		} else {
			model.addAttribute("loginErrorInfo", "用户名或密码错误，请重新登录！");
			return "loginError";
		}
	}

	/**
	 * 处理注册的请求
	 * 
	 * @param request
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping("/GetRegister.do")
	public void getRegister(HttpServletRequest request, HttpServletResponse response) throws IOException {
		System.out.println("捕获到GetRegister.do的url请求");
		// 从请求体中读出注册的用户信息
		BufferedReader br = request.getReader();
		String line = br.readLine();
		UserInfo user = JSON.parseObject(line, UserInfo.class);
		int num = 0;// 0表示注册失败
		if (userDao.selectRenamedUsers(user.getUsername()).size() > 0) {// 判断有没有重名
			num = -1;// 表示发生重名
		} else {
			if (this.userDao.addUser(user) == 1) {// 注册游客账户
				num = user.getUser_id();
			}
		}
		// 写回结果
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(num));
	}

	/**
	 * 用户录入重置密码的问题信息
	 * 
	 * @param request
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping("/GetQuestion.do")
	public void getQuestion(HttpServletRequest request, HttpServletResponse response) throws IOException {
		System.out.println("捕获到GetQuestion.do的url请求");
		// 从请求体中读出重置密码的问题信息
		BufferedReader br = request.getReader();
		String line = br.readLine();
		QuestionInfo question = JSON.parseObject(line, QuestionInfo.class);
		int num = this.userDao.addQuestionInfo(question);
		// 写回结果
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(num));
	}

	/**
	 * 处理重置密码的请求获取问题信息
	 * 
	 * @param username 用户名
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping("/RequestForQuestionInfo.do")
	public void processRequestForQuestionInfo(String username, HttpServletResponse response) throws IOException {
		System.out.println("捕获到RequestForQuestionInfo.do的url请求");
		QuestionInfo question = this.userDao.selectQuestionInfo(username);// 根据用户名获取到重置密码的问题信息
		// 写回结果
		response.setContentType("text/json;charset=utf-8");
		if (question == null) {// 判断是否查询到
			response.getWriter().write(JSON.toJSONString("null"));
		} else {
			response.getWriter().write(JSON.toJSONString(question));
		}
	}

	/**
	 * 重置密码
	 * 
	 * @param user_id  用户id
	 * @param password 密码
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping("/ResetPassword.do")
	public void resetPassword(String user_id, String password, HttpServletResponse response) throws IOException {
		System.out.println("捕获到ResetPassword.do的url请求");
		try {
			// 修改用户名密码
			int num = this.userDao.updatePassword(Integer.parseInt(user_id), password);
			// 写回结果
			response.setContentType("text/json;charset=utf-8");
			response.getWriter().write(JSON.toJSONString(num));
		} catch (NumberFormatException e) {
			e.printStackTrace();
		}
	}

	/**
	 * 检查邮箱用户名是否匹配
	 * 
	 * @param user_name
	 * @param email
	 * @param response
	 * @param model
	 * @throws IOException
	 */
	@RequestMapping("/checkUserEmail.do")
	public void checkUserAndItsEmail(String username, String email, HttpServletResponse resp) throws IOException {
		System.out.println("捕获到checkUserEmail.do的url请求");
		UserInfo user = this.userDao.selectUserByNameAndEmail(username, email);
		if (user == null) {
			resp.getWriter().write(JSON.toJSONString(0));
		} else {
			resp.getWriter().write(JSON.toJSONString(user.getUser_id()));
			String base = "0123456789ABCDEFGHIJKLMNOPQRSresp.getWriter().write(JSON.toJSONString(1));DUVWXYZabcdefghijklmnopqrsduvwxyz";
			int size = base.length();
			Random r = new Random();
			StringBuilder code = new StringBuilder();
			for (int i = 1; i <= 4; i++) {
				// 产生0到size-1的随机值
				int index = r.nextInt(size);
				// 在base字符串中获取下标为index的字符
				char c = base.charAt(index);
				// 将c放入到StringBuffer中去
				code.append(c);
			}
			this.emailCode = code.toString();
			System.out.println("生成的验证码：" + this.emailCode);
			// 实例化一个发送邮件的对象
			SendEmail mySendMail = new SendEmail();
			// 发送邮件
			mySendMail.sendMail(email, "您正在找回密码，验证码为：" + code.toString() + "\n如非本人操作，请忽略。");
		}
	}

	/**
	 * 验证邮箱验证码是否正确
	 * 
	 * @param emailCode
	 * @param resp
	 * @throws IOException
	 */
	@RequestMapping("/checkEmailCode.do")
	public void checkEmailCode(String emailCode, HttpServletResponse resp) throws IOException {
		System.out.println("输入的验证码：" + emailCode);
		if (emailCode.equals(this.emailCode)) {
			resp.getWriter().write(JSON.toJSONString(1));
		} else {
			resp.getWriter().write(JSON.toJSONString(0));
		}
	}
}
