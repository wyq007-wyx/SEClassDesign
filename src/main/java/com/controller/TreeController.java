package com.controller;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import com.alibaba.fastjson.JSON;
import com.dao.IndiceDao;
import com.mysql.fabric.Response;
import com.pojo.IndiceInfo;
import com.pojo.SchemeInfo;
import com.service.TreeService;

@Controller
public class TreeController {
	@Resource
	private TreeService treeService;
	
	@Resource
	private IndiceDao indiceDao;
	
	/**
	 * 处理获取体系树的请求
	 * @return
	 * @throws IOException 
	 */
	@RequestMapping("/getSystemTree.do")
	public String getSystemTree(String scheme_id, Model model) throws IOException {
		int sid=Integer.parseInt(scheme_id);
		String jsontree=treeService.getTreeNode(sid);
		model.addAttribute("jsontree", jsontree);
		return "indextree";
	}
	/**
	 * 添加体系树节点
	 * @param request
	 * @param response
	 * @throws IOException
	 */
	@RequestMapping("/addTreeNode.do")
	public void addTreeNode(HttpServletRequest request,HttpServletResponse response) throws IOException {
		//System.out.println("执行了addTreeNode.do");
		BufferedReader br=request.getReader();
		String line=br.readLine();
		IndiceInfo indiceInfo=JSON.parseObject(line, IndiceInfo.class);
		//System.out.println(indiceInfo);
		int ret=-1;
		ret=treeService.addTreeNode(indiceInfo);
		System.out.println("新增的树节点:"+ret);
		response.setContentType("text/json;charset=utf-8");
		response.getWriter().write(JSON.toJSONString(indiceInfo.getIndice_id()));
	}
	
	/**
	 * 更新体系树
	 * @param request
	 * @param response
	 * @throws IOException
	 */
	 @RequestMapping("/updateSystemTree.do")
     public void updateSystemTree(HttpServletRequest request,HttpServletResponse response) throws IOException {
         BufferedReader br=request.getReader();
         String line = br.readLine();
         IndiceInfo node = JSON.parseObject(line,IndiceInfo.class);
         //System.out.println(node.getIndice_name());
         int num = treeService.updateIndice(node);
         System.out.println(num);
         if(num > 0) {
                 response.getWriter().write("success");
         }else {
                 response.getWriter().write("fail");
         }

     }
	 /**
	  * 删除体系树和他的所有指标
	  * @param scheme_id
	  */
	 @RequestMapping("/deleteSystemTree.do")
	 public String deleteSystemTree(String scheme_id) {
		 int sid=Integer.parseInt(scheme_id);//获取体系id
		 int deletenums=treeService.deleteTreeAndInDice(sid);
		 return "indiceManagePage";
	 }
	 /**
	  * 删除体系树上的某个节点及其子节点
	  * @param indice_id
	  * @throws IOException 
	  */
	 @RequestMapping("/deleteNode.do")
	 public void deleteNode(String indice_id, HttpServletResponse response) throws IOException {
		 int id=Integer.parseInt(indice_id);//获取结点id
		 int ret=treeService.deleteTreeNode(id);
		 response.setContentType("text/json;charset=utf-8");
		 response.getWriter().write(JSON.toJSONString(ret));
	 }
	 
	 /**
	  * 导出体系树
	  * @param indice_id
	  * @throws IOException 
	  */
	 @RequestMapping("/exportScheme.do")
	 public void exportScheme(HttpServletRequest request, HttpServletResponse response) throws IOException {
		 System.out.println("捕获到了exportScheme.do的url请求");
		 BufferedReader br=request.getReader();
         String line = br.readLine();
		 int sid=Integer.parseInt(line);
		 System.out.println("sid:"+sid);
		 String jsontree=treeService.getTreeNode(sid);	//获取json串
		 response.setContentType("text/json;charset=utf-8");
		 response.getWriter().write(JSON.toJSONString(jsontree));
	 }
}