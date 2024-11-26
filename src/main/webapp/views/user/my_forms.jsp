<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>问卷概览</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/bootstrap.min.css">
    <!-- 引入自定义样式 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/common.css">
    <!-- 自定义样式 -->
    <style>
        .card {
            width: 250px;
        }

        .description {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .btn-disabled {
            background-color: #17a2b8 !important; /* 保持查看按钮的蓝色 */
            border-color: #17a2b8 !important;
            color: white !important;
            cursor: not-allowed;
        }
    </style>
    <!-- 引入 Vue -->
    <script src="${pageContext.request.contextPath}/static/js/vue.global.js"></script>
    <!-- 引入 Axios -->
    <script src="${pageContext.request.contextPath}/static/js/axios.min.js"></script>
</head>
<body>
<div class="container" id="myFormsApp" style="margin-top: 50px;">
    <h1 class="text-center mb-4">问卷概览</h1>

    <!-- 新建问卷按钮 -->
    <div class="text-right mb-3">
        <a href="${pageContext.request.contextPath}/views/survey/survey_edit_new.jsp"
           class="btn btn-primary">创建新问卷</a>
        <%--        jfoweijfowiejfoiqawejdfoijwadiofjoawiej--%>
    </div>

    <!-- 已回答问卷部分 -->
    <div>
        <h3 class="h5">已回答</h3>
        <div v-if="myResponses.length > 0" class="row">
            <div v-for="response in myResponses" :key="response.id" class="col-md-3 mb-3">
                <div class="card mx-auto">
                    <div class="card-body p-2">
                        <h5 class="card-title h6">{{ response.survey.title }}</h5>
                        <p class="card-text small description">{{ response.survey.description }}</p>
                        <ul class="list-unstyled small mb-1">
                            <li><strong>提交时间:</strong> {{ response.submittedAt || "尚未提交" }}</li>
                        </ul>
                    </div>
                    <a class="btn-primary" v-show="!response.isSubmitted"
                       :href="response.survey.fillLink" target="_blank">继续回答</a>
                </div>
            </div>
        </div>
        <p v-else class="text-muted">暂无问卷</p>

        <!-- 分页 -->
        <nav aria-label="Page navigation" class="mt-4">
            <ul class="pagination justify-content-end">
                <li class="page-item" :class="{ disabled: currentPage <= 1 }">
                    <a class="page-link" href="#" @click.prevent="changePage('answered', 'prev')">上一页</a>
                </li>
                <li class="page-item" :class="{ disabled: currentPage >= totalPages }">
                    <a class="page-link" href="#" @click.prevent="changePage('answered', 'next')">下一页</a>
                </li>
            </ul>
            <div class="text-right mt-2">第 {{ currentPage }} 页，共 {{ totalPages }} 页</div>
        </nav>
    </div>


    <!-- 已创建问卷部分 -->
    <div>
        <h3 class="h5">已创建</h3>
        <div v-if="createdSurveys.length > 0" class="row">
            <div v-for="survey in createdSurveys" :key="survey.id" class="col-md-3 mb-3">
                <div class="card mx-auto">
                    <div class="card-body p-2">
                        <h5 class="card-title h6">{{ survey.title }}</h5>
                        <p class="card-text small description">{{ survey.description }}</p>
                        <ul class="list-unstyled small mb-1">
                            <li><strong>开始时间:</strong> {{ survey.startTime }}</li>
                            <li><strong>结束时间:</strong> {{ survey.endTime }}</li>
                            <li><strong>是否公开:</strong> {{ survey.isPublic ? '是' : '否' }}</li>
                            <li><strong>登录填写:</strong> {{ survey.loginRequired ? '是' : '否' }}</li>
                            <li><strong>总答卷数:</strong> {{ survey.totalResponses }}</li>
                        </ul>
                    </div>
                    <div class="card-footer text-muted small p-1">创建于: {{ survey.createdAt }}</div>
                    <a class="btn-primary" :href="survey.shareLink" target="_blank">问卷链接</a>
                </div>
            </div>
        </div>
        <p v-else class="text-muted">暂无问卷</p>

        <!-- 分页 -->
        <nav aria-label="Page navigation" class="mt-4">
            <ul class="pagination justify-content-end">
                <li class="page-item" :class="{ disabled: currentPage1 <= 1 }">
                    <a class="page-link" href="#" @click.prevent="changePage('created', 'prev')">上一页</a>
                </li>
                <li class="page-item" :class="{ disabled: currentPage1 >= totalPages1 }">
                    <a class="page-link" href="#" @click.prevent="changePage('created', 'next')">下一页</a>
                </li>
            </ul>
            <div class="text-right mt-2">第 {{ currentPage1 }} 页，共 {{ totalPages1 }} 页</div>
        </nav>
    </div>
</div>


<script>
    const myFormsApp = Vue.createApp({
        data() {
            return {
                myResponses: [],
                createdSurveys: [],
                token: localStorage.getItem("token") // 从 localStorage 中获取 token
            };
        },
        mounted() {
            if (this.token) {
                this.fetchCreatedSurveys();
                this.fetchMyResponses();
            }
        },
        methods: {
            fetchCreatedSurveys() {
                axios.get('${pageContext.request.contextPath}/api/survey/all', {
                    params: {token: this.token}
                })
                    .then(response => {
                        if (response.data.code === 200) {
                            this.createdSurveys = response.data.data;
                            for (const survey of this.createdSurveys) {
                                axios.get('${pageContext.request.contextPath}/api/survey/share/' + survey.id, {
                                    params: {
                                        token: this.token
                                    }
                                })
                                    .then(response => {
                                        if (response.data.code === 200) {
                                            survey.shareLink = response.data.data;
                                        } else {
                                            console.error('Failed to fetch share link:', response.data.message);
                                        }
                                    })
                                    .catch(error => {
                                        console.error('Server internal error:', error);
                                    });
                            }
                        } else {
                            console.error('Failed to fetch surveys:', response.data.message);
                        }
                    })
                    .catch(error => {
                        console.error('Error fetching surveys:', error);
                    });
            },
            fetchMyResponses() {
                axios.get('${pageContext.request.contextPath}/api/response/all', {
                    params: {token: this.token}
                })
                    .then(response => {
                        if (response.data.code === 200) {
                            this.myResponses = response.data.data;
                            for (const myResp of this.myResponses) {
                                axios.get('${pageContext.request.contextPath}/api/survey/' + myResp.surveyId, {
                                    params: {
                                        token: this.token
                                    }
                                })
                                    .then(response => {
                                        if (response.data.code === 200) {
                                            myResp.survey = response.data.data;
                                            myResp.survey.fillLink = "${pageContext.request.contextPath}/views/survey/survey_fill.jsp?surveyId=" + myResp.survey.id;
                                        } else {
                                            console.error('Failed to fetch surveys:', response.data.message);
                                        }
                                    })
                                    .catch(error => {
                                        console.error('Server internal error:', error);
                                    })
                            }
                        } else {
                            console.error('Failed to fetch myResp list:', response.data.message);
                        }
                    })
                    .catch(error => {
                        console.error('Server internal error:', error);
                    });
            },
            getSurveyFillLink(surveyId) {
                return ;
            },
            getSurveyShareLink(surveyId) {

            }
        }
    });
    myFormsApp.mount('#myFormsApp');
</script>
</body>
</html>