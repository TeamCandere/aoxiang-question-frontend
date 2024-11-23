<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>系统信息</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/bootstrap.min.css">
  <!-- 引入自定义样式 -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/common.css">
</head>
<body>
<div class="container">
  <h2>系统信息</h2>
  <p>在此显示系统的各项统计信息。</p>

  <!-- 系统统计信息 -->
  <div class="row">
    <div class="col-md-4">
      <div class="card text-white bg-primary">
        <div class="card-body">
          <h5 class="card-title">用户总数</h5>
          <p class="card-text">${statistics.totalUsers} 用户</p>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card text-white bg-success">
        <div class="card-body">
          <h5 class="card-title">问卷总数</h5>
          <p class="card-text">${statistics.totalForms} 问卷</p>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card text-white bg-info">
        <div class="card-body">
          <h5 class="card-title">审核通过问卷</h5>
          <p class="card-text">${statistics.approvedForms} 问卷</p>
        </div>
      </div>
    </div>
  </div>
</div>
<script src="${pageContext.request.contextPath}/static/js/bootstrap.bundle.min.js"></script>
</body>
</html>
