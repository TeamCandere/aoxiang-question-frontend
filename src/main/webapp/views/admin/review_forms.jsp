<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>问卷管理</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/bootstrap.min.css">
    <!-- 引入自定义样式 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/common.css">
    <!-- 自定义样式 -->
    <style>
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
<div class="container" id="reviewSurveyApp" style="margin-top: 50px;">
    <h2 class="text-center mb-5">问卷管理</h2>
    <p class="text-center">在这里可以查看和管理所有问卷。</p>

    <!-- 问卷列表 -->
    <table class="table table-bordered">
        <thead>
        <tr>
            <th>#</th>
            <th>问卷标题</th>
            <th>创建时间</th>
            <th>审核状态</th>
            <th>提交状态</th>
            <th>操作</th>
        </tr>
        </thead>
        <tbody>
        <tr v-for="(survey, index) in surveys" :key="survey.id">
            <td>{{ index + 1 }}</td>
            <td>{{ survey.title }}</td>
            <td>{{ survey.createdAt }}</td>
            <td>{{ survey.isChecked ? '已审核' : '未审核' }}</td>
            <td>{{ survey.isSubmitted ? '已提交' : '未提交' }}</td>
            <td>
                <button
                        class="btn btn-info"
                        @click="viewSurvey(survey.id)"
                        :class="{ 'btn-disabled': !survey.isSubmitted }"
                        :title="!survey.isSubmitted ? '问卷未提交' : ''"
                >
                    查看
                </button>
                <button
                        class="btn btn-success"
                        @click="checkSurvey(survey.id)"
                        :disabled="!survey.isSubmitted || survey.isChecked"
                        :title="!survey.isSubmitted ? '问卷未提交' : survey.isChecked ? '问卷已审核' : ''"
                >
                    审核
                </button>
                <button class="btn btn-danger" @click="deleteSurvey(survey.id)">删除</button>
            </td>
        </tr>
        </tbody>
    </table>
</div>
<script src="${pageContext.request.contextPath}/static/js/bootstrap.bundle.min.js"></script>
<script>
    const reviewSurveyApp = Vue.createApp({
        data() {
            return {
                surveys: [],
                token: localStorage.getItem("token") // 从 localStorage 中获取 token
            };
        },
        mounted() {
            if (this.token) {
                this.fetchSurveys();
            }
        },
        methods: {
            fetchSurveys() {
                axios.get('${pageContext.request.contextPath}/api/survey/all', {
                    params: {token: this.token}
                })
                    .then(response => {
                        if (response.data.code === 200) {
                            this.surveys = response.data.data;
                        } else {
                            console.error('Failed to fetch surveys:', response.data.message);
                        }
                    })
                    .catch(error => {
                        console.error('Error fetching surveys:', error);
                    });
            },
            viewSurvey(surveyId) {
                axios.get('${pageContext.request.contextPath}/api/survey/' + surveyId, {
                    params: {token: this.token}
                })
                    .then(response => {
                        if (response.data.code === 200) {
                            alert('查看问卷：' + response.data.data.title);
                            this.fetchSurveys(); // 刷新问卷列表
                        } else {
                            alert('查看失败: ' + response.data.message);
                        }
                    })
                    .catch(error => {
                        console.error('Error checking survey:', error);
                    });
            },
            checkSurvey(surveyId) {
                axios.post('${pageContext.request.contextPath}/api/survey/check/' + surveyId, {
                    token: this.token
                })
                    .then(response => {
                        if (response.data.code === 200) {
                            alert('成功审核问卷。');
                            this.fetchSurveys(); // 刷新问卷列表
                        } else {
                            alert('审核失败: ' + response.data.message);
                        }
                    })
                    .catch(error => {
                        console.error('Error checking survey:', error);
                    });
            },
            deleteSurvey(surveyId) {
                if (confirm('确定要删除此问卷吗？')) {
                    axios.get('${pageContext.request.contextPath}/api/survey/remove/' + surveyId, {
                        params: {
                            token: this.token
                        }
                    })
                        .then(response => {
                            if (response.data.code === 200) {
                                alert('成功删除问卷。');
                                this.fetchSurveys(); // 刷新问卷列表
                            } else {
                                alert('删除失败: ' + response.data.message);
                            }
                        })
                        .catch(error => {
                            console.error('Error deleting survey:', error);
                        });
                }
            }
        }
    });

    reviewSurveyApp.mount('#reviewSurveyApp');
</script>
</body>
</html>