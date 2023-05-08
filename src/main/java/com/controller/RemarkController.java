package com.controller;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import com.dao.RemarkDao;
import com.po.RemarkMessage;
import com.po.User;

@Controller
public class RemarkController {
	@Autowired
	private RemarkDao remarkDao;
	/**
	 * 处理留言请求
	 * @param subject
	 * @param content
	 * @param session
	 * @param mav
	 * @return
	 */
	@RequestMapping("/GetRemark.do")
	public ModelAndView getRemark(String subject, String content, HttpSession session, ModelAndView mav) {
		//获取当前正在操作的用户
		User currentUser = (User)session.getAttribute("currentUser");
		//创建留言Bean
		RemarkMessage message = new RemarkMessage(currentUser.getUserID(), subject, content);
		//向数据库插入一条记录
		this.remarkDao.addRemarkMessage(message);
		//设置结果页面并返回数据
		mav.setViewName("remarkSuccessfully");
		mav.addObject("remarkSuccessfullyInfo", "留言成功！");
		return mav;
	}
}
