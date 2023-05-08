<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, com.po.RemarkMessage" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>请留言</title>
</head>
<body>

<p align="center">
<H1 align="center"><font color="black">请留言</font></H1>

<form method="post" action="GetRemark.do">
<p align="center">
留言主题：
<input type="text" name="subject">
<p align="center">
留言内容：
<textarea rows="5" cols="20" name="content"></textarea>
<p align="center">
 <input type="submit" value="提交">   
 <input type="reset" value="重置">
 </p>
 <p align="center">
 </p>
</form>
<div style="margin-top:60px; margin-left: 43%;">
<table border="1" cellpadding = "10">
<caption>我的往期留言</caption>
<tr>
<th>留言时间</th>
<th>主题</th>
<th>内容</th>
</tr>
<% 
//从request作用域中取出存放的本人的留言信息
List<RemarkMessage> list = (List<RemarkMessage>) request.getAttribute("selfRemarkMessage");
for(RemarkMessage message : list)
{
%>
<tr align="center">
<td><%=message.getRemarkTime() %></td>
<td><%=message.getSubject() %></td>
<td><%=message.getContent() %></td>
</tr>
<%
}
%>
</table>
</div>
</body>
</html>