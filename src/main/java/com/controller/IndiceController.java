package com.controller;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.dao.IndiceDao;
import com.dao.ResultDao;
import com.dao.TreeDao;
import com.pojo.UserInfo;
import com.util.Util;
import com.pojo.IndiceInfo;
import com.pojo.OperatorInfo;
import com.pojo.Result;
import com.pojo.SchemeInfo;

@Controller
@RequestMapping("/RequestFromIndiceManagePage.do")
public class IndiceController {
	@Autowired
	private IndiceDao indiceDao;
	@Autowired
	private TreeDao treeDao;
	@Autowired
	private ResultDao resultDao;

	/**
	 * 获取所有的体系信息
	 * 
	 * @param user_id    用户id
	 * @param isInstance 0：模板；1：实例
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=SchemeInfoForDisplay")
	public void getAllSchemeInfo(String user_id, String isInstance, HttpServletResponse response) throws IOException {
		try {
			List<SchemeInfo> data = this.indiceDao.selectAllSchemeInfo(Integer.parseInt(user_id),
					Integer.parseInt(isInstance));
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
	 * 获取一名用户的所有的算子
	 * @param user_id 用户id
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=getUserOperators")
	public void getUserOperators(String user_id, HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=getUserOperators的url请求");
		List<OperatorInfo> data = this.indiceDao.selectUserOperators(Integer.parseInt(user_id));
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(data));
	}
	/**
	 * 获取一名用户没有的算子
	 * @param user_id 用户id
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=getUserNotHaveOperators")
	public void getUserNotHaveOperators(String user_id, HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=getUserNotHaveOperators的url请求");
		List<OperatorInfo> data = this.indiceDao.selectUserNotHaveOperators(Integer.parseInt(user_id));
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(data));
	}
	/**
	 * 为用户增添算子
	 * @param user_id 用户id
	 * @param selectedAddOps 要增添的算子的id
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=addUserOperators")
	public void addUserOperators(String user_id, String selectedAddOps, HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=addUserOperators的url请求");
		int id = Integer.parseInt(user_id);
		List<Integer> list = JSONObject.parseArray(selectedAddOps, Integer.class);//解析出要删除的用户的算子
		int num = this.indiceDao.addUserOperators(id, list);
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(num));
	}
	/**
	 * 删除用户的算子
	 * @param user_id 用户id
	 * @param selectedDelOps 用户选中的要删除算子
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping(params = "request=deleteUserOperators")
	public void deleteUserOperators(String user_id, String selectedDelOps, HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=deleteUserOperators的url请求");
		int id = Integer.parseInt(user_id);
		List<OperatorInfo> list = JSONObject.parseArray(selectedDelOps, OperatorInfo.class);//解析出要删除的用户的算子
		List<OperatorInfo> existedList=this.indiceDao.selectUsedOperators(id);
		int num=0;
		for(OperatorInfo op:list) {
			if(existedList.contains(op)) {
				num=-1;
			}
		}
		if(num!=-1) {
			 num = this.indiceDao.deleteUserOperators(id, list);
		}
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(num));
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
		List<SchemeInfo> list = this.indiceDao.selectRenamedScheme(scheme);// 判断该用户下是否存在同名体系的模板或实例
		int num = 0;
		if (list.size() == 0) {// 若没有同名体系
			num = this.indiceDao.insertScheme(scheme);// 创建体系
			// 创建该体系的根节点
			IndiceInfo root = new IndiceInfo();
			root.setFather_id(-1);
			root.setIndice_name("root");
			root.setScheme_id(scheme.getScheme_id());
			indiceDao.insertIndiceInfo(root);
		}
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(num > 0 ? scheme.getScheme_id() : num));
	}

	/**
	 * 创建新的体系实例
	 * 
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
		List<SchemeInfo> list = this.indiceDao.selectRenamedScheme(scheme);// 判断该用户下是否存在同名体系的实例
		if (list.size() == 0) {// 若没有同名体系实例
			int oldScheme_id = scheme.getScheme_id();
			SchemeInfo newScheme = new SchemeInfo(scheme.getScheme_name(), scheme.getUser_id(), scheme.getIsInstance());
			indiceDao.insertScheme(newScheme);
			int newScheme_id = newScheme.getScheme_id();
			IndiceInfo root = treeDao.selectRoot(oldScheme_id, -1);
			copyScheme(root, newScheme_id, oldScheme_id, -1);
		}
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(1));
	}

	public void copyScheme(IndiceInfo indice, int newScheme_id, int oldScheme_id, int father_id) {
		int oldRootid = indice.getIndice_id();
		IndiceInfo newRoot = new IndiceInfo();
		newRoot.setScheme_id(newScheme_id);
		newRoot.setIndice_name(indice.getIndice_name());
		newRoot.setFather_id(father_id);
		treeDao.addTreeNode(newRoot);
		List<IndiceInfo> children = treeDao.selectIndiceBySystemIdAndFatherId(oldScheme_id, oldRootid);
		for (IndiceInfo child : children) {
			copyScheme(child, newScheme_id, oldScheme_id, newRoot.getIndice_id());
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
	public void fuzzyQueryBySchemeName(String scheme_name, String user_id, String isInstance,
			HttpServletResponse response) throws IOException {
		System.out.println("捕获到参数为request=fuzzyQueryBySchemeName的url请求");
		String like = '%' + scheme_name + '%';// 模糊查询
		List<SchemeInfo> data = this.indiceDao.selectSchemeFuzzy(like, Integer.parseInt(user_id),
				Integer.parseInt(isInstance));
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
		List<SchemeInfo> list = this.indiceDao.selectRenamedScheme(scheme);// 判断该用户下是否存在同名体系的模板或实例
		int num = -1;
		if(list.size() == 0) {//若没有重名体系
			num = this.indiceDao.updateSchemeInfo(scheme);
		}
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
		this.treeDao.deleteSchemeIndice(Integer.parseInt(scheme_id));// 外键约束：先删除该体系下的所有指标
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
		IndiceInfo fatherIndice = this.indiceDao.selectIndiceInfoByIndice_id(indice.getFather_id(), indice.getScheme_id());
		int num = -1;
		if(fatherIndice != null) {
			num = this.indiceDao.insertIndiceInfo(indice);
		}
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
		int num = -1;
		if(indice.getFather_id() != -1) {//若不是根节点，需要判断父节点是否存在
			IndiceInfo fatherIndice = this.indiceDao.selectIndiceInfoByIndice_id(indice.getFather_id(), indice.getScheme_id());
			if(fatherIndice != null) {
				num = this.indiceDao.updateIndiceInfo(indice);
			}
		}else {
			num = this.indiceDao.updateIndiceInfo(indice);
		}
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(num));
	}

	/**
	 * 上传体系树文件
	 * 
	 * @param file
	 * @param response
	 * @throws IOException
	 * @throws DocumentException
	 */
	@RequestMapping(params = "request=uploadTreeFile")
	public void getTreeFile(@RequestParam("treeFile") MultipartFile file, String user_id, HttpServletResponse response)
			throws IOException, DocumentException {
		System.out.println("捕获到参数为request=uploadTreeXMLFile的url请求");
		String originFilename = file.getOriginalFilename();// 获取源文件名称
		String originFileType = file.getContentType();// 获取源文件类型
		System.out.println("文件名为" + originFilename + "，文件格式" + originFileType);
		String scheme_name = originFilename.substring(0, originFilename.lastIndexOf("."));// 文件名即是体系名
		// 创建新体系
		SchemeInfo scheme = new SchemeInfo(scheme_name, Integer.parseInt(user_id), 0);
		List<SchemeInfo> list = this.indiceDao.selectRenamedScheme(scheme);// 判断该用户下是否存在同名体系的模板
		String callback = null;
		if (list.size() == 0) {// 若没有同名体系
			if (this.indiceDao.insertScheme(scheme) == 1) {// 创建体系
				int scheme_id = scheme.getScheme_id();// 获取回填的indice_id
				// 文件转换
				File treeFile = new File(originFilename);
				file.transferTo(treeFile);
				if (originFileType.equals("application/json")) {// json文件
					this.parseJSONFile(treeFile, scheme_id);
					callback = "JSON文件解析成功！";
				} else if (originFileType.equals("text/xml")) {// xml文件
					this.parseXMLFile(treeFile, scheme_id);
					callback = "XML文件解析成功！";
				} else {
					callback = "文件格式错误！";
				}
			} else {
				callback = "错误！体系创建失败";
			}
		} else {
			callback = "错误！存在同名体系";
		}
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(callback));
	}

	/**
	 * 解析XML文件
	 * 
	 * @param file      XML文件
	 * @param scheme_id 体系id
	 * @throws DocumentException
	 */
	public void parseXMLFile(File file, int scheme_id) throws DocumentException {
		SAXReader reader = new SAXReader();
		Document document = reader.read(file);
		Element root = document.getRootElement();// 获取根节点
		dfsForParseXML(root, -1, scheme_id);// 解析XML文件
	}

	/**
	 * 用于解析XML文件的DFS
	 * 
	 * @param node      结点
	 * @param father_id 父节点id
	 * @param scheme_id 所属体系id
	 */
	public void dfsForParseXML(Element node, int father_id, int scheme_id) {
		String node_name = node.elementText("name");// 获取节点name标签的值
		IndiceInfo indice = new IndiceInfo();
		indice.setIndice_name(node_name);
		indice.setFather_id(father_id);
		indice.setScheme_id(scheme_id);
		this.indiceDao.insertIndiceInfo(indice);// 插入一条记录
		Element childrenElement = node.element("children");// 获取节点的children标签
		if (childrenElement == null) {// 若没有孩子
			return;
		}
		// 遍历children标签下的所有孩子
		List<Element> children = childrenElement.elements();
		for (Element child : children) {
			dfsForParseXML(child, indice.getIndice_id(), scheme_id);
		}
	}

	/**
	 * 解析JSON文件
	 * 
	 * @param file      JSON文件
	 * @param scheme_id 体系id
	 */
	public void parseJSONFile(File file, int scheme_id) {
		BufferedReader br = null;
		try {// 读取JSON文件内容
			br = new BufferedReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8));
			String line;
			StringBuilder sb = new StringBuilder();
			while ((line = br.readLine()) != null) {
				sb.append(line);
			}
			JSONObject root = JSONObject.parseObject(sb.toString());// 解析出根节点
			this.dfsForParseJSON(root, -1, scheme_id);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * 用于解析JSON文件的DFS
	 * 
	 * @param node      结点
	 * @param father_id 父节点id
	 * @param scheme_id 体系id
	 */
	public void dfsForParseJSON(JSONObject node, int father_id, int scheme_id) {
		String node_name = (String) node.get("name");// 获取节点name标签的值
		IndiceInfo indice = new IndiceInfo();
		indice.setIndice_name(node_name);
		indice.setFather_id(father_id);
		indice.setScheme_id(scheme_id);
		this.indiceDao.insertIndiceInfo(indice);// 插入一条记录
		JSONArray children = (JSONArray) node.get("children");
		if (children == null) {// 若没有孩子
			return;
		}
		// 遍历children标签下的所有孩子
		for (int i = 0; i < children.size(); i++) {
			this.dfsForParseJSON(children.getJSONObject(i), indice.getIndice_id(), scheme_id);
		}
	}
	/**
	 * 获取服务器保存的计算结果
	 * @param request
	 * @param response
	 * @throws FileNotFoundException
	 * @throws IOException
	 */
	@RequestMapping(params = "request=downloadCalResult")
	public void downloadCalResult(HttpServletRequest request, HttpServletResponse response) throws FileNotFoundException, IOException {
		String filepath = Util.getCalcResultPath(request);//获取文件保存路径
		JSONObject currentUser = (JSONObject) (request.getSession().getAttribute("currentUser"));
		UserInfo user = JSON.parseObject(currentUser.toString(), UserInfo.class);
		int user_id = user.getUser_id();
		int scheme_id = Integer.parseInt(request.getParameter("scheme_id"));//获取体系id
		String scheme_name = this.indiceDao.selectScheme_nameByScheme_id(scheme_id);//根据体系id查询体系名称
		String filename = scheme_name + "-" + user_id + ".xls";
		// 保存在本地磁盘中的文件
		File file = new File(filepath, filename);
		/*
		 * 1. response.setContentType:使客户端浏览器，区分不同种类的数据
		 * 并根据不同的MIME调用浏览器内不同的程序嵌入模块来处理相应的数据。 2.
		 * application/octet-stream表示返回二进制流，表示不知道下载文件类型，具有通用性
		 */
		response.setContentType("application/octet-stream");
		/*
		 * Content-Disposition:文件下载时会告诉浏览器要下载的文件名称和类型 URLEncoder.encode:防止中文文件名乱码
		 */
		response.setHeader("Content-Disposition", "attachment;filename=" + URLEncoder.encode(file.getName(), "UTF-8"));

		// 使用工具类直接将文件的字节复制到响应输出流中
		FileCopyUtils.copy(new FileInputStream(file), response.getOutputStream());
	}
	
	/**
	 * 
	 * @param request
	 * @param response
	 * @param scheme_id
	 * @throws IOException
	 */
	@RequestMapping(params = "request=getAllResultTime")
	public void getAllResultTime(HttpServletResponse response, String scheme_id) throws IOException {
		System.out.println("getTimeRequest");
		List<Date> dateList = resultDao.selectTimeBySchemeId(Integer.parseInt(scheme_id));
		
		List<String> timeList = new ArrayList<>();
		
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		for(Date d: dateList) {
			timeList.add(sdf.format(d));
		}
		
		response.getWriter().write(JSON.toJSONString(timeList));
	}
	
	/**
	 * 
	 * @param response
	 * @param scheme_id
	 * @param time
	 * @throws IOException
	 * @throws NumberFormatException
	 * @throws ParseException
	 */
	@RequestMapping(params = "request=getResult")
	public void getAllResultTime(HttpServletResponse response, String scheme_id, String exec_time) throws IOException, NumberFormatException, ParseException {
		System.out.println("getResultRequest");
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		List<Result> resList = resultDao.selectResultBySchemeIdANDTime(Integer.parseInt(scheme_id), sdf.parse(exec_time));
		
		List<String> strResList = new ArrayList<>();
		Map<Integer,List<Result>> map = new HashMap<>();
		
		for(Result res:resList) {
			if(map.containsKey(res.getGroupId())) {
				map.get(res.getGroupId()).add(res);
			}else {
				List<Result> list = new ArrayList<>();
				list.add(res);
				map.put(res.getGroupId(), list);
			}
		}
		
		for(int i : map.keySet()) {
			List<Result> tmpList = map.get(i);
			
			List<String> strList = new ArrayList<>();
			for(Result r:tmpList) {
				strList.add(JSON.toJSONString(r));
			}
			strResList.add(JSON.toJSONString(strList));
		}
		
		response.getWriter().write(JSON.toJSONString(strResList));
	}
}
