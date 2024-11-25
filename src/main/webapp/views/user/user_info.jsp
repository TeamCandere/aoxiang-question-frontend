<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>个人信息</title>
  <link rel="stylesheet" href="https://cdn.staticfile.org/twitter-bootstrap/4.3.1/css/bootstrap.min.css">
  <script src="https://cdn.staticfile.org/jquery/3.2.1/jquery.min.js"></script>
  <script src="https://cdn.staticfile.org/twitter-bootstrap/4.3.1/js/bootstrap.min.js"></script>
</head>
<body>
<div id="userInfoApp">
  <div class="user">
    <div class="bannar">
      <div class="out">
        <div class="left">
          <div class="img"></div>
          <div class="username">${userData.username}</div>
        </div>
      </div>
    </div>
    <div class="user-info" style="width: 40%;">
      <div class="info"><h5>个人信息</h5></div>
      <form action="/user/modifyProfile" method="post">
        <div class="item">
          <label for="username">用户名：</label>
          <input type="text" class="form-control" id="username" name="username" value="${userData.username}">
        </div>
        <div class="item">
          <label for="password">密码：</label>
          <input type="password" class="form-control" id="password" name="password" value="${userData.password}">
        </div>
        <div class="item">
          <label for="email">邮箱：</label>
          <input type="email" class="form-control" id="email" name="email" value="${userData.email}">
        </div>
        <div class="item">
          <label for="phone">手机号：</label>
          <input type="text" class="form-control" id="phone" name="phone" value="${userData.phone}">
        </div>
        <div class="button">
          <button type="submit" class="btn btn-success">确认</button>
          <button type="reset" class="btn btn-light cancel">重置</button>
        </div>
      </form>
    </div>
  </div>
</div>
</body>
</html>
