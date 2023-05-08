<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>请登录</title>
</head>
<body>

<p align="center">
<H1 align="center"><font color="black">请登录</font></H1>

<form method="post" action="GetLogin.do">
<p align="center">
用户名：
<input type="text" name="userName">
<p align="center">
密码：
<input type="password" name="password">
<p align="center">
 <input type="submit" value="登录">   
 <input type="reset" value="重置">
 </p>
 <p align="center">
 <a HREF="register.jsp">注册</a>
 </p>
</form>

</body>
</html>