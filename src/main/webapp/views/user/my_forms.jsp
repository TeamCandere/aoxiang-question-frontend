<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="true" %>
<html>
<head>
    <meta charset="UTF-8">
    <title>问卷概览</title>
    <link
            rel="stylesheet"
            href="https://cdn.staticfile.org/twitter-bootstrap/4.3.1/css/bootstrap.min.css"
    />
</head>
<style>
    .card {
        width: 250px;
    }
    .description {
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
</style>
<body>
<div class="container my-4">
    <h1 class="text-center mb-4">问卷概览</h1>

    <!-- 新建问卷按钮 -->
    <div class="text-right mb-3">
        <a href="/survey/create" class="btn btn-primary">创建新问卷</a>
    </div>

    <!-- 已回答问卷部分 -->
    <div>
        <h3 class="h5">已回答</h3>
        <c:if test="${not empty surveyList}">
            <div class="row">
                <c:forEach var="survey" items="${surveyList}">
                    <div class="col-md-3 mb-3">
                        <div class="card mx-auto">
                            <c:if test="${not empty survey.backgroundUrl}">
                                <img src="${survey.backgroundUrl}" class="card-img-top" alt="背景图片" width="250" height="125" style="object-fit: cover;" />
                            </c:if>
                            <div class="card-body p-2">
                                <h5 class="card-title h6">${survey.title}</h5>
                                <p class="card-text small description">${survey.description}</p>
                                <ul class="list-unstyled small mb-1">
                                    <li><strong>开始时间:</strong> ${survey.startTime}</li>
                                    <li><strong>结束时间:</strong> ${survey.endTime}</li>
                                </ul>
                            </div>
                            <div class="card-footer text-muted small p-1">创建于: ${survey.createdAt}</div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:if>
        <c:if test="${empty surveyList}">
            <p class="text-muted">暂无问卷</p>
        </c:if>

        <!-- 分页 -->
        <nav aria-label="Page navigation" class="mt-4">
            <ul class="pagination justify-content-end">
                <c:if test="${currentPage > 1}">
                    <li class="page-item">
                        <a class="page-link" href="?page=${currentPage - 1}">上一页</a>
                    </li>
                </c:if>
                <c:if test="${currentPage < totalPages}">
                    <li class="page-item">
                        <a class="page-link" href="?page=${currentPage + 1}">下一页</a>
                    </li>
                </c:if>
            </ul>
            <div class="text-right mt-2">第 ${currentPage} 页，共 ${totalPages} 页</div>
        </nav>
    </div>

    <!-- 已创建问卷部分 -->
    <div>
        <h3 class="h5">已创建</h3>
        <c:if test="${not empty surveyListCreated}">
            <div class="row">
                <c:forEach var="survey" items="${surveyListCreated}">
                    <div class="col-md-3 mb-3">
                        <div class="card mx-auto">
                            <c:if test="${not empty survey.backgroundUrl}">
                                <img src="${survey.backgroundUrl}" class="card-img-top" alt="背景图片" width="250" height="125" style="object-fit: cover;" />
                            </c:if>
                            <div class="card-body p-2">
                                <h5 class="card-title h6">${survey.title}</h5>
                                <p class="card-text small description">${survey.description}</p>
                                <ul class="list-unstyled small mb-1">
                                    <li><strong>开始时间:</strong> ${survey.startTime}</li>
                                    <li><strong>结束时间:</strong> ${survey.endTime}</li>
                                    <li><strong>是否公开:</strong> ${survey.isPublic ? '是' : '否'}</li>
                                    <li><strong>登录填写:</strong> ${survey.loginRequired ? '是' : '否'}</li>
                                    <li><strong>总答卷数:</strong> ${survey.totalResponses}</li>
                                </ul>
                            </div>
                            <div class="card-footer text-muted small p-1">创建于: ${survey.createdAt}</div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:if>
        <c:if test="${empty surveyListCreated}">
            <p class="text-muted">暂无问卷</p>
        </c:if>

        <!-- 分页 -->
        <nav aria-label="Page navigation" class="mt-4">
            <ul class="pagination justify-content-end">
                <c:if test="${currentPage1 > 1}">
                    <li class="page-item">
                        <a class="page-link" href="?page=${currentPage1 - 1}">上一页</a>
                    </li>
                </c:if>
                <c:if test="${currentPage1 < totalPages1}">
                    <li class="page-item">
                        <a class="page-link" href="?page=${currentPage1 + 1}">下一页</a>
                    </li>
                </c:if>
            </ul>
            <div class="text-right mt-2">第 ${currentPage1} 页，共 ${totalPages1} 页</div>
        </nav>
    </div>
</div>
</body>
</html>
