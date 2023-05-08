package com.po;

/**
 * 对应于remark数据表的JavaBean
 */
import java.text.SimpleDateFormat;
import java.util.Date;

public class RemarkMessage {
	private int userID;// 留言的用户的ID
	private String subject;// 留言主题
	private String content;// 留言内容
	private String remarkTime;// 留言时间

	public RemarkMessage() {
	}

	public RemarkMessage(int userID, String subject, String content) {
		this.userID = userID;
		this.subject = subject;
		this.content = content;
		this.remarkTime = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss").format(new Date());
	}

	public String getSubject() {
		return subject;
	}

	public void setSubject(String subject) {
		this.subject = subject;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public String getRemarkTime() {
		return remarkTime;
	}

	public void setRemarkTime(String remarkTime) {
		this.remarkTime = remarkTime;
	}

}
