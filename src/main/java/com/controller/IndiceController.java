package com.controller;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.aspectj.util.FileUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import com.alibaba.fastjson.JSON;
import com.dao.IndiceDao;
import com.dao.TreeDao;
import com.pojo.UserInfo;
import com.pojo.IndiceInfo;
import com.pojo.OperatorInfo;
import com.pojo.SchemeInfo;

@Controller
@RequestMapping("/RequestFromIndiceManagePage.do")
public class IndiceController {
	@Autowired
	private IndiceDao indiceDao;
	@Autowired
	private TreeDao treeDao;
	
	/**
	 * 获取所有的体系信息
	 * @param user_id 用户id
	 * @param isInstance 0：模板；1：实例
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=SchemeInfoForDisplay")
	public void getAllSchemeInfo(String user_id, String isInstance, HttpServletResponse response) throws IOException {
		try {
			List<SchemeInfo> data = this.indiceDao.selectAllSchemeInfo(Integer.parseInt(user_id), Integer.parseInt(isInstance));
			response.setContentType("text/json;charset=utf-8");
			response.getWriter().write(JSON.toJSONString(data));
		} catch (NumberFormatException e) {
			e.printStackTrace();
		}
	}

	/**
	 * 获取所有的算子
	 * 
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=getAllOperators")
	public void getAllOperators(HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=getAllOperators的url请求");
		List<OperatorInfo> data = this.indiceDao.selectAllOperator();
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
	 * 创建新体系模板
	 * 
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
		System.out.println(scheme.getScheme_name());
		List<SchemeInfo> list = this.indiceDao.selectRenamedScheme(scheme);//判断该用户下是否存在同名体系的模板或实例
		int num = 0;
		if(list.size() == 0) {//若没有同名体系
			num = this.indiceDao.insertScheme(scheme);//创建体系
			//创建该体系的根节点
			IndiceInfo root = new IndiceInfo();
			root.setFather_id(-1);
			root.setScheme_id(scheme.getScheme_id());
			indiceDao.insertIndiceInfo(root);
		}
		response.setContentType("text/json;charset=utf-8");
		if(num > 0) {
			response.getWriter().write(JSON.toJSONString(scheme.getScheme_id()));
		}else {
			response.getWriter().write(JSON.toJSONString(num));
		}
	}
	/**
	 * 创建新的体系实例
	 * @param request
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=createSchemeInstance")
	public void insertSchemeInstance(HttpServletRequest request, HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=createSchemeInstance的url请求");
		// 读取请求体中的内容
		BufferedReader br = request.getReader();
		String line = br.readLine();
		SchemeInfo scheme = JSON.parseObject(line, SchemeInfo.class);// 把JSON字符串解析为JavaBean
		List<SchemeInfo> list = this.indiceDao.selectRenamedScheme(scheme);//判断该用户下是否存在同名体系的实例
		if(list.size() == 0) {//若没有同名体系实例
			int oldScheme_id=scheme.getScheme_id();
			SchemeInfo newScheme=new SchemeInfo(scheme.getScheme_name(),scheme.getUser_id(),scheme.getIsInstance());
			indiceDao.insertScheme(newScheme);
			int newScheme_id=newScheme.getScheme_id();
			IndiceInfo root=treeDao.selectRoot(oldScheme_id, -1);
			copyScheme(root,newScheme_id,oldScheme_id,-1);
		}
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(1));
	}
	public void copyScheme(IndiceInfo indice,int newScheme_id,int oldScheme_id,int father_id) {
		int oldRootid=indice.getIndice_id();
		IndiceInfo newRoot=new IndiceInfo();
		newRoot.setScheme_id(newScheme_id);
		newRoot.setFather_id(father_id);
		treeDao.addTreeNode(newRoot);
		List<IndiceInfo> children=treeDao.selectIndiceBySystemIdAndFatherId(oldScheme_id, oldRootid);
		for(IndiceInfo child:children) {
			copyScheme(child,newScheme_id,oldScheme_id,newRoot.getIndice_id());	
		}
	}
	/**
	 * 根据体系名模糊查询
	 * 
	 * @param scheme_name
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=fuzzyQueryBySchemeName")
	public void fuzzyQueryBySchemeName(String scheme_name, String user_id, String isInstance, HttpServletResponse response)
			throws IOException {
		System.out.println("捕获到参数为request=fuzzyQueryBySchemeName的url请求");
		String like = '%' + scheme_name + '%';// 模糊查询
		List<SchemeInfo> data = this.indiceDao.selectSchemeFuzzy(like, Integer.parseInt(user_id), Integer.parseInt(isInstance));
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(data));
	}

	/**
	 * 修改体系
	 * 
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
	 * 
	 * @param request
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=deleteScheme")
	public void deleteScheme(String scheme_id, HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=changeScheme的url请求");
		this.treeDao.deleteSchemeIndice(Integer.parseInt(scheme_id));//外键约束：先删除该体系下的所有指标
		int num = this.indiceDao.deleteScheme(Integer.parseInt(scheme_id));
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(num));
	}

	/**
	 * 获取单个体系的所有指标信息
	 * 
	 * @param system_id 体系id
	 * @param user_id   用户id
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=SingleSchemeDetailInfo")
	public void getSingleSchemeDetailInfo(String scheme_id, String user_id, HttpServletResponse response)
			throws IOException {
		System.out.println("捕获到参数为request=SingleSchemeDetailInfo的url请求");
		List<IndiceInfo> data = this.indiceDao.getSingleSchemeDetailInfo(Integer.parseInt(scheme_id),
				Integer.parseInt(user_id));
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(data));
	}

	/**
	 * 删除指标
	 * 
	 * @param request
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=deleteIndice")
	public void deleteIndice(String indice_id, HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=deleteIndice的url请求");
		int num = this.indiceDao.deleteIndice(Integer.parseInt(indice_id));
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(num));
	}

	/**
	 * 创建指标
	 * 
	 * @param request
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=createIndice")
	public void createIndice(HttpServletRequest request, HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=createIndice的url请求");
		// 读取请求体中的内容
		BufferedReader br = request.getReader();
		String line = br.readLine();
		IndiceInfo indice = JSON.parseObject(line, IndiceInfo.class);// 把JSON字符串解析为JavaBean
		int num = this.indiceDao.insertIndiceInfo(indice);
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(num));
	}

	/**
	 * 修改指标
	 * 
	 * @param request
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=changeIndice")
	public void changeIndice(HttpServletRequest request, HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=changeIndice的url请求");
		// 读取请求体中的内容
		BufferedReader br = request.getReader();
		String line = br.readLine();
		IndiceInfo indice = JSON.parseObject(line, IndiceInfo.class);// 把JSON字符串解析为JavaBean
		int num = this.indiceDao.updateIndiceInfo(indice);
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(num));
	}
	/**
	 * 上传体系树文件
	 * @param file
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=uploadTreeFile")
	public void getUserImage(@RequestParam("treeFile") MultipartFile file, HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=uploadTreeXMLFile的url请求");
		String originFilename =  file.getOriginalFilename();
		System.out.println("文件名为" + originFilename + "，文件格式" + file.getContentType());
		//File treeFile = new File(originFilename);
		
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString("success"));
	}
}
