<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户首页</title>
    <!-- 引入 Bootstrap 样式 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/bootstrap.min.css">
    <!-- 引入自定义样式 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/common.css">
    <!-- 引入 Bootstrap 脚本 -->
    <script src="${pageContext.request.contextPath}/static/js/bootstrap.bundle.min.js"></script>
    <style>
        /* 页面整体容器，使用 Flexbox 布局 */
        .container-fluid {
            display: flex;
            min-height: 100vh;
            padding: 0;
            flex-direction: row;
        }

        /* 顶部 Banner */
        .banner {
            background-color: #343a40;
            color: white;
            padding: 15px 30px;
            border-radius: 0 0 10px 10px;
            position: fixed;
            top: 0;
            width: 100%;
            z-index: 100;
        }

        /* 留出空间，防止 Banner 覆盖内容 */
        .banner + .container-fluid {
            padding-top: 80px; /* 留出空间，防止 Banner 覆盖 */
        }

        /* 左侧导航栏 */
        .sidebar {
            background-color: #f8f9fa;
            width: 250px;
            height: 100%;
            position: fixed;
            top: 80px; /* 顶部 Banner 下方 */
            left: 0;
            padding-top: 20px;
            overflow-y: auto;
        }

        .sidebar .nav-item {
            margin: 10px 0;
        }

        .sidebar .nav-link {
            color: #343a40;
            padding: 10px 15px;
            border-radius: 5px;
        }

        .sidebar .nav-link:hover {
            background-color: #e9ecef;
        }

        /* 右侧内容区 */
        .content {
            margin-left: 250px; /* 右侧内容区域左边距 */
            margin-top: 80px; /* 距离顶部导航栏 */
            padding: 20px;
            flex: 1;
            background-color: #f4f6f9;
        }

        /* 页脚样式 */
        .footer {
            background-color: #343a40;
            color: white;
            padding: 10px 30px;
            text-align: center;
            position: fixed;
            bottom: 0;
            width: 100%;
        }
    </style>
</head>
<body>
<!-- 顶部导航栏 (Banner) -->
<jsp:include page="../common/banner.jsp" />

<div class="container-fluid">
    <!-- 左侧导航栏 -->
    <div class="sidebar">
        <ul class="nav flex-column">
            <li class="nav-item">
                <a class="nav-link ${param.page == 'user_info' ? 'active' : ''}" href="?page=user_info">用户信息</a>
            </li>
            <li class="nav-item">
                <a class="nav-link ${param.page == 'my_forms' ? 'active' : ''}" href="?page=my_forms">问卷概览</a>
            </li>
            <li class="nav-item">
                <a class="nav-link ${param.page == 'settings' ? 'active' : ''}" href="?page=settings">设置</a>
            </li>
        </ul>
    </div>

    <!-- 右侧内容区 -->
    <div class="content">
        <!-- 动态加载的页面内容 -->
        <c:choose>
            <c:when test="${param.page == 'user_info'}">
                <jsp:include page="user_info.jsp" />
            </c:when>
            <c:when test="${param.page == 'my_forms'}">
                <jsp:include page="my_forms.jsp" />
            </c:when>
            <c:when test="${param.page == 'settings'}">
                <jsp:include page="settings.jsp" />
            </c:when>
            <c:otherwise>
                <jsp:include page="my_forms.jsp" /> <!-- 默认显示问卷概览 -->
            </c:otherwise>
        </c:choose>
    </div>
</div>

<!-- 页脚 -->
<jsp:include page="../common/footer.jsp" />
</body>
</html>