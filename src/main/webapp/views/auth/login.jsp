<%--
  Created by IntelliJ IDEA.
  User: ASUS
  Date: 2024/11/23
  Time: 23:58
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>用户登录</title>
    <link rel="stylesheet" href="https://cdn.staticfile.org/twitter-bootstrap/4.3.1/css/bootstrap.min.css">
    <style>
        body {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            margin: 0;
            background: url("${ctx}/static/img/image.png");
            background-size: cover;
        }
        h2 {
            text-align: center;
        }
        .toast-container {
            position: fixed;
            top: 30px;
            left: 50%;
            transform: translateX(-50%);
            z-index: 1050;
        }
        .login {
            position: relative;
            margin-top: auto; /* 确保主要内容区域占据剩余空间 */
            width: 100%;
            max-width: 1300px;
            height: 600px;
            margin-left: auto;
            margin-right: auto;
            background-color: #fff;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-radius: 10px;
            box-shadow: #00000017 1px 1px 10px;
        }
        .login .right {
            flex: 50%;
        }
        .login .left {
            flex: 50%;
            text-align: center;
        }
        .login-btn {
            width: 100%;
            margin-top: 20px;
        }
        .form-group {
            margin-top: 30px;
        }
        a {
            float: right;
            color: rgb(126, 126, 126);
        }
        a:hover {
            color: #000;
            text-decoration: none;
        }
        footer {
            margin-top: auto; /* 确保页脚推到底部 */
            padding: 10px 0;
            text-align: center;
            background-color: #f8f9fa;
        }
    </style>
</head>
<body>
<!-- 顶部导航栏 (Banner) -->
<jsp:include page="../common/banner.jsp" />
<div id="app" class="container mt-5">
    <div class="login">
        <div class="left"></div>
        <div class="right">
            <div class="row justify-content-center">
                <div class="col-md-6">
                    <h2>用户登录</h2>
                    <form @submit.prevent="submitLogin">
                        <div class="form-group">
                            <label for="username"><b>用户名</b></label>
                            <input type="text" class="form-control" v-model="username" id="username" required placeholder="请输入用户名">
                        </div>
                        <div class="form-group">
                            <label for="password"><b>密码</b></label>
                            <input type="password" class="form-control" v-model="password" id="password" required placeholder="请输入密码">
                        </div>
                        <button type="submit" class="btn btn-primary login-btn">登录</button>
                        <a href="${ctx}/views/auth/register.jsp">没有账号？去注册</a>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <div id="toastContainer" class="toast-container">
        <div class="toast justify-content-center text-white bg-danger border-0" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="d-flex">
                <div class="toast-body">
                    {{ errorMessage }}
                </div>
            </div>
        </div>
    </div>
</div>
<!-- 页脚 -->
<footer>
    <jsp:include page="../common/footer.jsp" />
</footer>

<!-- 引入 Vue.js 和 Axios -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/3.2.12/vue.global.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
<script src="https://cdn.staticfile.org/jquery/3.2.1/jquery.min.js"></script>
<script src="https://cdn.staticfile.org/twitter-bootstrap/4.3.1/js/bootstrap.min.js"></script>
<script>
    const app = Vue.createApp({
        data() {
            return {
                username: '',
                password: '',
                errorMessage: '',
                showLogin: true
            };
        },
        methods: {
            submitLogin() {
                axios.post('${ctx}/api/user/login', {
                    username: this.username,
                    password: this.password
                })
                    .then(response => {
                        if (response.data.code === 200) {
                            localStorage.setItem("token", response.data.data);
                            this.checkUserTypeAndRedirect(response.data.data);
                        } else {
                            this.showErrorMessage('用户名或密码错误');
                        }
                    })
                    .catch(() => {
                        this.showErrorMessage('服务器错误，请稍后再试');
                    });
            },

            showErrorMessage(message) {
                this.errorMessage = message;
                const toastElList = Array.from(document.querySelectorAll('.toast'));
                toastElList.forEach(toastEl => {
                    const toast = new bootstrap.Toast(toastEl, { delay: 3000 });
                    toast.show();
                });
            },

            checkUserTypeAndRedirect(token) {
                axios.post('${ctx}/api/user/profile', "token=" + localStorage.getItem("token"))
                    .then(response => {
                        if (response.data.code === 200) {
                            if (response.data.data.role === "Admin") {
                                window.location.href = '${ctx}/views/admin/admin_home.jsp';  // 登录成功，跳转至首页
                            } else {
                                window.location.href = '${ctx}/views/user/user_home.jsp';  // 登录成功，跳转至首页
                            }
                        } else {
                            this.showErrorMessage(response.data.msg);
                        }
                    })
                    .catch(() => {
                        this.showErrorMessage('服务器错误，请稍后再试');
                    });
            }
        }
    });
    app.mount('#app');
</script>
</body>
</html>