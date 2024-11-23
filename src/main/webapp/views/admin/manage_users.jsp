<%@ page contentType="text/html;charset=UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户管理</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/bootstrap.min.css">
    <!-- 引入自定义样式 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/common.css">
</head>
<body>
<div class="container">
    <h2>用户管理</h2>
    <p>在这里可以查看和管理所有用户。</p>

    <!-- 用户列表 -->
    <table class="table table-bordered">
        <thead>
        <tr>
            <th>#</th>
            <th>用户名</th>
            <th>邮箱</th>
            <th>注册时间</th>
            <th>操作</th>
        </tr>
        </thead>
        <tbody>
        <!-- 假设这里使用 JSTL 渲染用户列表 -->
        <c:forEach var="user" items="${users}">
            <tr>
                <td>${user.id}</td>
                <td>${user.username}</td>
                <td>${user.email}</td>
                <td>${user.registrationDate}</td>
                <td>
                    <button class="btn btn-primary">编辑</button>
                    <button class="btn btn-danger">删除</button>
                </td>
            </tr>
        </c:forEach>
        </tbody>
    </table>
</div>
<script src="${pageContext.request.contextPath}/static/js/bootstrap.bundle.min.js"></script>
</body>
</html>
