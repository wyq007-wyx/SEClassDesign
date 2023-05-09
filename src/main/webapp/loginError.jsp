<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <!-- 在线引入最新样式 -->
    <link rel="stylesheet" href="https://unpkg.com/element-ui/lib/theme-chalk/index.css">
    <title>重新登录</title>
</head>

<body>
    <div id="app">
    </div>
    <!-- import Vue before Element -->
    <!-- <script src="js/vue.js"></script> -->
    <script src="https://unpkg.com/vue@2/dist/vue.js"></script>
    <!-- import JavaScript -->
    <!-- <script src="element-ui/lib/index.js"></script> -->
    <script src="https://unpkg.com/element-ui/lib/index.js"></script>
    <script>
        new Vue({
            el: '#app',
            mounted() {
                let msg = "${requestScope.loginErrorInfo}";
                this.$alert(msg, '错误', {
                    confirmButtonText: '确定',
                    callback: action => {
                        window.location.href = "http://localhost:2008/SEClassDesign/login.jsp";
                    }
                });
            }
        })
    </script>
</body>

</html>