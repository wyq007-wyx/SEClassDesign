package com.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import com.alibaba.fastjson.JSON;
import com.dao.IndiceDao;
import com.pojo.UserInfo;
import com.pojo.IndiceInfo;
import com.pojo.SchemeInfo;

@Controller
@RequestMapping("/RequestFromIndiceManagePage.do")
public class IndiceController {
	@Autowired
	private IndiceDao indiceDao;
	
	@RequestMapping(params = "request=SchemeInfoForDisplay")
	public void getAllSchemeInfo(String user_id, HttpServletResponse response) throws IOException {
		try {
			List<SchemeInfo> data = this.indiceDao.selectAllSchemeInfo(Integer.parseInt(user_id));
			response.setContentType("text/json;charset=utf-8");
			response.getWriter().write(JSON.toJSONString(data));
		}catch(NumberFormatException e) {
			e.printStackTrace();
		}
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
		request.getSession().removeAttribute("currentUser");
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString("success"));
	}
	/**
	 * 用户修改自己的信息
	 * 
	 * @param request
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=changeCurrentUser")
	public void updateCurrentUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=changeCurrentUser的url请求");
		// 读取请求体中的内容
		BufferedReader br = request.getReader();
		String line = br.readLine();
		UserInfo user = JSON.parseObject(line, UserInfo.class);// 把JSON字符串解析为JavaBean
		int num = this.indiceDao.updateCurrentUserInfo(user);
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(num));
	}
	/**
	 * 创建新体系
	 * @param request
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=createNewScheme")
	public void insertScheme(HttpServletRequest request, HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=createNewScheme的url请求");
		// 读取请求体中的内容
		BufferedReader br = request.getReader();
		String line = br.readLine();
		SchemeInfo scheme = JSON.parseObject(line, SchemeInfo.class);// 把JSON字符串解析为JavaBean
		int num = this.indiceDao.insertScheme(scheme);
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(num));
	}
	
	/**
	 * 根据体系名模糊查询
	 * @param scheme_name
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=fuzzyQueryBySchemeName")
	public void fuzzyQueryBySchemeName(String scheme_name, String user_id, HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=fuzzyQueryBySchemeName的url请求");
		String like = '%' + scheme_name + '%';// 模糊查询
		List<SchemeInfo> data = this.indiceDao.selectSchemeFuzzy(like, Integer.parseInt(user_id));
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(data));
	}
	/**
	 * 修改体系
	 * @param request
	 * @param response
	 * @throws IOException 
	 */
	@RequestMapping(params = "request=changeScheme")
	public void changeScheme(HttpServletRequest request, HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=changeScheme的url请求");
		// 读取请求体中的内容
		BufferedReader br = request.getReader();
		String line = br.readLine();
		SchemeInfo scheme = JSON.parseObject(line, SchemeInfo.class);// 把JSON字符串解析为JavaBean
		int num = this.indiceDao.updateSchemeInfo(scheme);
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(num));
	}
	
	/**
	 * 删除体系
	 * @param request
	 * @param response
	 * @throws IOException 
	 */
	@RequestMapping(params = "request=deleteScheme")
	public void deleteScheme(String scheme_id, HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=changeScheme的url请求");
		int num = this.indiceDao.deleteScheme(Integer.parseInt(scheme_id));
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(num));
	}
	/**
	 * 获取单个体系的所有指标信息
	 * @param system_id 体系id
	 * @param user_id 用户id
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=SingleSchemeDetailInfo")
	public void getSingleSchemeDetailInfo(String scheme_id, String user_id, HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=SingleSchemeDetailInfo的url请求");
		List<IndiceInfo> data = this.indiceDao.getSingleSchemeDetailInfo(Integer.parseInt(scheme_id), Integer.parseInt(user_id));
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(data));
	}
}
