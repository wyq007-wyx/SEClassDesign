package com.controller;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.dao.IndiceDao;
import com.pojo.IndiceInfo;
import com.pojo.TreeNode;
import com.pojo.UserInfo;
import com.service.TreeService;
import com.util.Util;

@Controller
public class TreeController {
	@Resource
	private TreeService treeService;

	@Resource
	private IndiceDao indiceDao;

	/**
	 * 处理获取体系树的请求
	 * 
	 * @return
	 * @throws IOException
	 */
	@RequestMapping("/getSystemTree.do")
	public String getSystemTree(String scheme_id, Model model) throws IOException {
		int sid = Integer.parseInt(scheme_id);
		String jsontree = treeService.getTreeNode(sid);
		model.addAttribute("jsontree", jsontree);
		return "indextree";
	}

	/**
	 * 添加体系树节点
	 * 
	 * @param request
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping("/addTreeNode.do")
	public void addTreeNode(HttpServletRequest request, HttpServletResponse response) throws IOException {
		// System.out.println("执行了addTreeNode.do");
		BufferedReader br = request.getReader();
		String line = br.readLine();
		IndiceInfo indiceInfo = JSON.parseObject(line, IndiceInfo.class);
		// System.out.println(indiceInfo);
		int ret = -1;
		ret = treeService.addTreeNode(indiceInfo);
		System.out.println("新增的树节点:" + ret);
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(indiceInfo.getIndice_id()));
	}

	/**
	 * 更新体系树
	 * 
	 * @param request
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping("/updateSystemTree.do")
	public void updateSystemTree(HttpServletRequest request, HttpServletResponse response) throws IOException {
		BufferedReader br = request.getReader();
		String line = br.readLine();
		IndiceInfo node = JSON.parseObject(line, IndiceInfo.class);
		// System.out.println(node.getIndice_name());
		int num = treeService.updateIndice(node);
		System.out.println(num);
		if (num > 0) {
			response.getWriter().write("success");
		} else {
			response.getWriter().write("fail");
		}

	}

	/**
	 * 删除体系树和他的所有指标
	 * 
	 * @param scheme_id
	 */
	@RequestMapping("/deleteSystemTree.do")
	public String deleteSystemTree(String scheme_id) {
		int sid = Integer.parseInt(scheme_id);// 获取体系id
		treeService.deleteTreeAndInDice(sid);
		return "indiceManagePage";
	}

	/**
	 * 删除体系树上的某个节点及其子节点
	 * 
	 * @param indice_id
	 * @throws IOException
	 */
	@RequestMapping("/deleteNode.do")
	public void deleteNode(String indice_id, HttpServletResponse response) throws IOException {
		int id = Integer.parseInt(indice_id);// 获取结点id
		int ret = treeService.deleteTreeNode(id);
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(ret));
	}

	/**
	 * 导出体系树
	 * 
	 * @param indice_id
	 * @throws IOException
	 */
	@RequestMapping("/exportScheme.do")
	public void exportScheme(HttpServletRequest request, HttpServletResponse response) throws IOException {
		System.out.println("捕获到了exportScheme.do的url请求");
		BufferedReader br = request.getReader();
		String line = br.readLine();
		int sid = Integer.parseInt(line);
		System.out.println("sid:" + sid);
		String jsontree = treeService.getTreeNode(sid); // 获取json串
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(jsontree));
	}

	/**
	 * 检查实例合法性：权重和，算子是否配置完全
	 * 
	 * @param scheme_id
	 * @param resp
	 * @throws IOException
	 */
	@RequestMapping("/checkInstance.do")
	public void checkInstanceValid(String scheme_id, HttpServletResponse resp) throws IOException {
		System.out.println("捕获到checkInstanceValid.do");
		int sid = Integer.parseInt(scheme_id);
		String ret = treeService.checkInstanceValid(sid);
		System.out.println("ret:" + ret);
		resp.setContentType("text/json;charset=utf-8");
		resp.getWriter().write(JSON.toJSONString(ret));
	}
	/**
	 * 接收前端上传的文件
	 * @param file 前端上传的文件
	 * @param scheme_id 体系id
	 * @param response 响应
	 * @throws Exception
	 */
	@RequestMapping("/executeTree.do")
	public void executeTree(@RequestParam("treeFile") MultipartFile file, String scheme_id, HttpServletRequest request, HttpServletResponse response) throws Exception {
		String originFilename = file.getOriginalFilename();//获取源文件名称
		File dataFile = new File(originFilename);
		file.transferTo(dataFile);
		//从session作用域中取出当前登录用户
		JSONObject currentUser = (JSONObject) (request.getSession().getAttribute("currentUser"));
		UserInfo user = JSON.parseObject(currentUser.toString(), UserInfo.class);
		int user_id = user.getUser_id();
		List<List<IndiceInfo>> retList=new ArrayList<>();
		List<TreeNode> treeList=this.treeService.getTreeList(dataFile, Integer.parseInt(scheme_id), user_id,retList);
		response.setContentType("text/json;charset=utf-8");
		if(treeList == null) {
			response.getWriter().write(JSON.toJSONString(-1));
		}else {
			List<String> strList = new ArrayList<>();//所有树形结果
			List<String> table=new ArrayList<>();//所有列表结果
			for(TreeNode node : treeList){
				strList.add(JSON.toJSONString(node));
			}
			for(List<IndiceInfo> ans:retList) {
				List<String> indiceList=new ArrayList<>();
		        for(IndiceInfo indice:ans) {
		    	   indiceList.add(JSON.toJSONString(indice));
		        }
		        table.add(JSON.toJSONString(indiceList));
			}
			String scheme_name = this.indiceDao.selectScheme_nameByScheme_id(Integer.parseInt(scheme_id));
			this.treeService.writeIntoExcel(treeList, Util.getCalcResultPath(request), scheme_name, user_id);//结果写入文件
			response.getWriter().write(JSON.toJSONString(strList));
			System.out.println(JSON.toJSONString(table));
			request.getSession().setAttribute("tableData", JSON.toJSONString(table));
		}
	}

	@RequestMapping("/getSchemeName.do")
	public void getSchemeName(String scheme_id,HttpServletResponse response) throws IOException {
		String scheme_name=indiceDao.selectScheme_nameByScheme_id(Integer.parseInt(scheme_id));
		response.getWriter().write(scheme_name);
	}
}