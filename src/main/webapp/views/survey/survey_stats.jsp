<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
  Created by IntelliJ IDEA.
  User: lenovo
  Date: 2024-11-23
  Time: 16:50
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>问卷数据页面</title>
    <!-- 引入 Bootstrap 样式 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/bootstrap.min.css">
</head>
<body>
<div id="app" class="container my-5">
    <!-- 页面标题 -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h3>{{survey?.title||'问卷标题'}}</h3>
        <button class="btn btn-success">导出表单</button>
    </div>

    <!-- 切换栏 -->
    <ul class="nav nav-tabs">
        <li class="nav-item">
            <button class="nav-link active" id="data-statistics-tab" data-bs-toggle="tab"
                    data-bs-target="#data-statistics">数据统计
            </button>
        </li>
        <li class="nav-item">
            <button class="nav-link" id="response-details-tab" data-bs-toggle="tab" data-bs-target="#response-details">
                答卷详情
            </button>
        </li>
    </ul>

    <!-- 内容切换区域 -->
    <div class="tab-content mt-3">
        <!-- 数据统计 -->
        <div class="tab-pane fade show active" id="data-statistics">
            <!-- 遍历问题 -->
            <div v-for="(question, index) in questions" :key="index" class="mb-5">
                <h3>{{ index + 1 }}. {{ question.title || '未命名题目' }}</h3>

                <!-- 数据表格 -->
                <table class="table table-bordered mt-3">
                    <thead>
                    <tr>
                        <th>序号</th>
                        <th>内容</th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr v-for="(answer, i) in question.answers" :key="i">
                        <td>{{ i + 1 }}</td>
                        <td>{{ answer.content }}</td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- 答卷详情 -->
        <div class="tab-pane fade" id="response-details">
            <div class="text-center p-5 border">
                <p class="text-muted">暂无答卷</p>
                <button class="btn btn-primary">邀请填写</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/3.2.12/vue.global.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
<script src="https://cdn.staticfile.org/jquery/3.2.1/jquery.min.js"></script>
<script src="https://cdn.staticfile.org/twitter-bootstrap/4.3.1/js/bootstrap.min.js"></script>
<!-- 引入 Bootstrap JS 和 Vue.js -->
<script src="https://unpkg.com/vue@3.2.47/dist/vue.global.js"></script>
<script src="<c:url value="/static/js/bootstrap.bundle.js"/>"></script>
<script>
    document.addEventListener('DOMContentLoaded', () => {
        const app = Vue.createApp({
            data() {
                return {
                    questions: [
                        {
                            type: 'single-choice',
                            title: '性别',
                            data: ['男', '女']
                        },
                        {
                            type: 'multi-choice',
                            title: '兴趣爱好',
                            data: ['阅读', '旅游', '游戏']
                        },
                        {
                            type: 'text-input',
                            title: '自我介绍',
                            data: ['我喜欢编程', '我喜欢旅行', '我热爱音乐']
                        },
                        {
                            type: 'phone-number',
                            title: '手机号码',
                            data: ['13800138000', '13900139000']
                        },
                        {
                            type: 'id-number',
                            title: '身份证号',
                            data: ['110101199001011234', '120101198901012345']
                        },
                        {
                            type: 'email',
                            title: '邮箱地址',
                            data: ['example1@example.com', 'example2@example.com']
                        }
                    ],
                    survey: null,
                    token: localStorage.getItem("token") // 从 localStorage 中获取 token
                };
            },
            mounted() {
                if (this.token) {
                    this.fetchSurveyInfo(this.token);
                }
            },
            methods: {
                fetchSurveyInfo(token) {
                    axios.post('${pageContext.request.contextPath}/api/survey/${param.surveyId}', "token=" + token)
                        .then(response => {
                            if (response.data.code === 200) {
                                this.survey = response.data.data;
                                this.fetchQuestions(this.survey.id, this.token);
                            } else {
                                console.error('Failed to fetch survey info:', response.data.message);
                            }
                        })
                        .catch(error => {
                            console.error('Error fetching survey info:', error)
                        });
                },
                fetchQuestions(surveyId, token) {
                    axios.post('${pageContext.request.contextPath}/api/question/all', "token=" + token + "&surveyId=" + surveyId)
                        .then(response => {
                            if (response.data.code === 200) {
                                this.questions = response.data.data;
                                for (const question of this.questions) {
                                    this.fetchAnswers(question, this.token);
                                }
                            } else {
                                console.error('Failed to fetch survey info:', response.data.message);
                            }
                        })
                        .catch(error => {
                            console.error('Error fetching questions of survey:', error)
                        });
                },
                fetchAnswers(question, token) {
                    axios.post('${pageContext.request.contextPath}/api/answer/all', "token=" + token + "&questionId=" + question.id)
                        .then(response => {
                            if (response.data.code === 200) {
                                question.answers = response.data.data;
                            } else {
                                console.error('Failed to fetch answers:', response.data.message);
                            }
                        })
                        .catch(error => {
                            console.error('Error fetching answers of question:', error)
                        });
                }
            }
        });

        app.mount('#app');
    });
</script>
</body>
</html>
