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
  <!-- 引入 Vue -->
  <script src="${pageContext.request.contextPath}/static/js/vue.global.js"></script>
  <!-- 引入 Axios -->
  <script src="${pageContext.request.contextPath}/static/js/axios.min.js"></script>
  <style>
    .highlighted-data {
      color: #FF5733; /* 显眼的颜色 */
      font-weight: bold; /* 加粗字体 */
    }
  </style>
</head>
<body>
<div class="container" id="infoApp" style="margin-top: 50px;">
  <h2 class="text-center mb-5">系统信息</h2>
  <p class="text-center">在此显示系统的各项统计信息。</p>

  <!-- 系统统计信息 -->
  <div class="row justify-content-center">
    <div class="col-md-4 mb-4">
      <div class="card text-white bg-primary h-100">
        <div class="card-body d-flex flex-column justify-content-center align-items-center">
          <h5 class="card-title mb-3">用户总数</h5>
          <p class="card-text display-4"><span class="highlighted-data">{{ statistics.totalUsers }}</span> 用户</p>
        </div>
      </div>
    </div>
    <div class="col-md-4 mb-4">
      <div class="card text-white bg-success h-100">
        <div class="card-body d-flex flex-column justify-content-center align-items-center">
          <h5 class="card-title mb-3">问卷总数</h5>
          <p class="card-text display-4"><span class="highlighted-data">{{ statistics.totalSurveys }}</span> 问卷</p>
        </div>
      </div>
    </div>
    <div class="col-md-4 mb-4">
      <div class="card text-white bg-info h-100">
        <div class="card-body d-flex flex-column justify-content-center align-items-center">
          <h5 class="card-title mb-3">审核通过问卷</h5>
          <p class="card-text display-4"><span class="highlighted-data">{{ statistics.approvedSurveys }}</span> 问卷</p>
        </div>
      </div>
    </div>
  </div>
</div>
<script src="${pageContext.request.contextPath}/static/js/bootstrap.bundle.min.js"></script>
<script>
  const infoApp = Vue.createApp({
    data() {
      return {
        statistics: {
          totalUsers: 0,
          totalSurveys: 0,
          approvedSurveys: 0
        },
        token: localStorage.getItem("token") // 从 localStorage 中获取 token
      };
    },
    mounted() {
      if (this.token) {
        this.fetchSystemStatistics(this.token);
      }
    },
    methods: {
      fetchSystemStatistics(token) {
        axios.post('${pageContext.request.contextPath}/api/statistics', "token=" + token)
                .then(response => {
                  if (response.data.code === 200) {
                    this.statistics = response.data.data;
                  } else {
                    console.error('Failed to fetch system statistics:', response.data.message);
                  }
                })
                .catch(error => {
                  console.error('Error fetching system statistics:', error);
                });
      }
    }
  });

  infoApp.mount('#infoApp');
</script>
</body>
</html>