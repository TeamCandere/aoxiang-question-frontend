<%@ page contentType="text/html;charset=UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>问卷管理</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/bootstrap.min.css">
    <!-- 引入自定义样式 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/common.css">
</head>
<body>
<div class="container">
    <h2>问卷管理</h2>
    <p>在这里可以查看和管理所有问卷。</p>

    <!-- 问卷列表 -->
    <table class="table table-bordered">
        <thead>
        <tr>
            <th>#</th>
            <th>问卷标题</th>
            <th>创建时间</th>
            <th>审核状态</th>
            <th>操作</th>
        </tr>
        </thead>
        <tbody>
        <!-- 假设这里使用 JSTL 渲染问卷列表 -->
        <c:forEach var="form" items="${forms}">
            <tr>
                <td>${form.id}</td>
                <td>${form.title}</td>
                <td>${form.creationDate}</td>
                <td>${form.status}</td>
                <td>
                    <button class="btn btn-info">查看</button>
                    <button class="btn btn-success">审核</button>
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
