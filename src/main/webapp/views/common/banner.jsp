<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <!-- 引入 Bootstrap 样式 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/bootstrap.min.css">
    <!-- 引入自定义样式 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/common.css">
    <!-- 引入 Vue -->
    <script src="${pageContext.request.contextPath}/static/js/vue.global.js"></script>
    <!-- 引入 Bootstrap 脚本 -->
    <script src="${pageContext.request.contextPath}/static/js/bootstrap.bundle.min.js"></script>
</head>
<body>

<!-- Vue.js 实例 -->
<div id="app">
    <!-- Banner -->
    <div class="banner d-flex justify-content-between align-items-center">
        <!-- 左侧：网站名和当前版块 -->
        <div class="flex-grow-1">
            <h1>问卷系统</h1>
            <p class="lead">管理员控制台</p>
        </div>

        <!-- 中间：版块按钮 -->
        <div class="text-center">
            <div class="btn-group" role="group">
                <!-- 判断用户是否登录 -->
                <template v-if="isLoggedIn">
                    <!-- 如果已登录，根据用户类型显示按钮 -->
                    <template v-if="userType === 'admin'">
                        <a href="/adminDashboard" class="btn btn-outline-light btn-sm">查看管理面板</a>
                        <a href="/manageUsers" class="btn btn-outline-light btn-sm">用户管理</a>
                        <a href="/approveForms" class="btn btn-outline-light btn-sm">审核问卷</a>
                    </template>
                    <template v-else>
                        <!-- 普通用户版块按钮 -->
                        <a href="/userDashboard" class="btn btn-outline-light btn-sm">查看我的问卷</a>
                        <a href="/submitForm" class="btn btn-outline-light btn-sm">提交问卷</a>
                    </template>
                </template>

                <!-- 游客版块按钮 -->
                <template v-else>
                    <a href="/login" class="btn btn-outline-light btn-sm">登录</a>
                    <a href="/register" class="btn btn-outline-light btn-sm">注册</a>
                </template>
            </div>
        </div>

        <!-- 右侧：用户头像和欢迎信息 -->
        <div class="d-flex align-items-center ms-3">
            <template v-if="isLoggedIn">
                <img :src="avatarUrl" alt="用户头像" class="user-avatar">
                <span class="ms-2">欢迎, {{ username }}!</span>
            </template>
            <template v-else>
                <span>欢迎, 游客!</span>
            </template>
        </div>
    </div>
</div>

<!-- Vue.js 代码 -->
<script>
    new Vue({
        el: '#app',
        data: {
            isLoggedIn: false,
            userType: 'guest',
            username: '游客',
            avatarUrl: 'https://via.placeholder.com/40'
        },
        mounted() {
            // 假设用户未登录
            this.isLoggedIn = false;
            this.userType = 'guest';
            this.username = '游客';
            this.avatarUrl = 'https://via.placeholder.com/40';
        }
    });
</script>

</body>
</html>