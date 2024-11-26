<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>问卷填写页面</title>
    <!-- 引入 Bootstrap 样式 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/bootstrap.min.css">
    <!-- 引入 Vue -->
    <script src="${ctx}/static/js/vue.global.js"></script>
    <script src="<c:url value="/static/js/axios.min.js"/>"></script>
</head>
<body style="margin: 0; display: flex; justify-content: center; align-items: center; height: 100vh; background-color: #f8f9fa;">
<div id="appSurveyFill" class="container"
     style="max-width: 800px; background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1); margin:5%;">
    <h1 class="text-center mb-4" style="margin:3%">{{ survey.title || '测试问卷填写页面' }}</h1>
    <form @submit.prevent="submitForm">
        <div class="mb-3">
            <p id="description" class="form-control-plaintext">{{ survey.description || '请填写以下问卷内容' }}</p>
        </div>

        <!-- 遍历显示题目 -->
        <div v-for="(question, index) in questions" :key="index" class="mb-3 border p-3 rounded">
            <h5>{{ index + 1 }}. {{ question.content }}</h5>

            <!-- 根据问题类型显示对应输入框 -->
            <%--            <div v-if="question.type === 'text-input'">--%>
            <input v-model="question.value" type="text" class="form-control" placeholder="请输入答案">
            <%--            </div>--%>

            <%--            <div v-if="question.type === 'single-choice'">--%>
            <%--                <div v-for="(option, optionIndex) in question.options" :key="optionIndex" class="form-check">--%>
            <%--                    <input v-model="question.value" :value="option" class="form-check-input" type="radio" :id="'radio-' + index + '-' + optionIndex">--%>
            <%--                    <label class="form-check-label" :for="'radio-' + index + '-' + optionIndex">{{ option }}</label>--%>
            <%--                </div>--%>
            <%--            </div>--%>

            <%--            <div v-if="question.type === 'multi-choice'">--%>
            <%--                <div v-for="(option, optionIndex) in question.options" :key="optionIndex" class="form-check">--%>
            <%--                    <input v-model="question.value" :value="option" class="form-check-input" type="checkbox" :id="'checkbox-' + index + '-' + optionIndex">--%>
            <%--                    <label class="form-check-label" :for="'checkbox-' + index + '-' + optionIndex">{{ option }}</label>--%>
            <%--                </div>--%>
            <%--            </div>--%>

            <%--            <div v-if="question.type === 'phone-number'">--%>
            <%--                <input v-model="question.value" type="text" class="form-control" placeholder="请输入11位手机号">--%>
            <%--                <p v-if="!isValidPhoneNumber(question.value)" class="text-danger mt-1">手机号必须为11位数字</p>--%>
            <%--            </div>--%>

            <%--            <div v-if="question.type === 'id-number'">--%>
            <%--                <input v-model="question.value" type="text" class="form-control" placeholder="请输入有效身份证号">--%>
            <%--                <p v-if="!isValidIdNumber(question.value)" class="text-danger mt-1">身份证号格式不正确</p>--%>
            <%--            </div>--%>

            <%--            <div v-if="question.type === 'email'">--%>
            <%--                <input v-model="question.value" type="email" class="form-control" placeholder="请输入有效邮箱">--%>
            <%--                <p v-if="!isValidEmail(question.value)" class="text-danger mt-1">邮箱格式不正确</p>--%>
            <%--            </div>--%>
        </div>

        <button type="submit" class="btn btn-primary w-100">提交问卷</button>
    </form>
</div>

<script>
    const appSurveyFill = Vue.createApp({
        data() {
            return {
                survey: {},
                questions: [],

                token: localStorage.getItem("token") // 从 localStorage 中获取 token
            };
        },
        methods: {
            getQuestionType(type) {
                const types = {
                    'single-choice': '单选题',
                    'multi-choice': '多选题',
                    'text-input': '填空题',
                    'phone-number': '手机号题',
                    'id-number': '身份证题',
                    'email': '邮箱题'
                };
                return types[type] || '未知题型';
            },
            isValidPhoneNumber(value) {
                return /^[0-9]{11}$/.test(value);
            },
            isValidIdNumber(value) {
                return /^[0-9]{15}$|^[0-9]{17}[0-9Xx]$/.test(value);
            },
            isValidEmail(value) {
                return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
            },
            loadSurvey() {
                // 检查是否有 token
                if (!this.token) {
                    alert('未登录或登录已过期，请重新登录');
                    window.location.href = `${ctx}/views/login.jsp`; // 跳转到登录页面
                    return;
                }

                // 向后端请求问卷数据
                axios.get("${ctx}/api/survey/" + this.surveyId, {
                    params: {
                        token: this.token // 将 token 作为参数传递
                    }
                })
                    .then(response => {
                        if (response.data.code === 200) {
                            this.survey = response.data.data; // 加载问卷内容
                            this.loadQuestions();
                        } else {
                            alert('问卷加载失败：' + response.data.msg);
                        }
                    })
                    .catch(error => {
                        console.error('加载问卷失败', error);
                        alert('加载问卷失败，请稍后重试');
                    });
            },
            loadQuestions() {
                // 向后端请求问题数据
                axios.get("${ctx}/api/question/all", {
                    params: {
                        surveyId: this.surveyId,
                        token: this.token // 将 token 作为参数传递
                    }
                })
                    .then(response => {
                        if (response.data.code === 200) {
                            this.questions = response.data.data; // 加载问卷内容
                            for (const question of this.questions) {
                                question.value = '';
                            }
                        } else {
                            alert('问卷加载失败：' + response.data.msg);
                        }
                    })
                    .catch(error => {
                        console.error('加载问卷失败', error);
                        alert('加载问卷失败，请稍后重试');
                    });
            },
            submitForm() {
                // 校验表单数据
                // if (this.survey.questions.some(q => q.type === 'phone-number' && !this.isValidPhoneNumber(q.value))) {
                //     alert('请检查手机号题的格式是否正确');
                //     return;
                // }
                // if (this.survey.questions.some(q => q.type === 'id-number' && !this.isValidIdNumber(q.value))) {
                //     alert('请检查身份证题的格式是否正确');
                //     return;
                // }
                // if (this.survey.questions.some(q => q.type === 'email' && !this.isValidEmail(q.value))) {
                //     alert('请检查邮箱题的格式是否正确');
                //     return;
                // }

                // 提交表单数据
                axios.get(`${ctx}/api/response/create`, {
                    params: {
                        surveyId: this.survey.id,
                        token: this.token // 提交时包含 token
                    }
                })
                    .then(response => {
                        if (response.data.code === 200) {
                            <%--window.location.href = `${ctx}/views/user/user_home.jsp`; // 跳转到成功页面--%>
                            this.submitAnswers(response.data.data);
                        } else {
                            alert('提交失败：' + response.data.msg);
                        }
                    })
                    .catch(error => {
                        console.error('提交问卷失败', error);
                        alert('提交问卷失败，请稍后重试');
                    });
            },
            submitAnswers(responseId) {
                for (const question of this.questions) {
                    axios.get(`${ctx}/api/answer/fill`, {
                        params: {
                            responseId: responseId,
                            token: this.token,
                            questionId: question.id,
                            content: question.value
                        }
                    })
                        .then(response => {
                            if (response.data.code === 200) {
                                this.submitResponse(responseId);
                            } else {
                                alert('提交失败：' + response.data.msg);
                            }
                        })
                        .catch(error => {
                            console.error('提交问卷失败', error);
                            alert('提交问卷失败，请稍后重试');
                        });
                }
            },
            submitResponse(responseId) {
                axios.get(`${ctx}/api/response/submit/` + responseId, {
                    params: {
                        token: this.token
                    }
                })
                    .then(response => {
                        if (response.data.code === 200) {
                            alert('问卷填写成功！');
                            window.location.href = `${ctx}/views/user/user_home.jsp`; // 跳转到成功页面
                        } else {
                            alert('提交失败：' + response.data.msg);
                        }
                    })
                    .catch(error => {
                        console.error('提交问卷失败', error);
                        alert('提交问卷失败，请稍后重试');
                    });
            }
        },
        mounted() {
            // 页面加载完成后调用加载问卷的方法
            // const urlParams = new URLSearchParams(window.location.search);
            // this.surveyId = urlParams.get("surveyId");
            this.surveyId = '${param.surveyId}';


            if (!this.surveyId) {
                alert("问卷 ID 不存在");
                return;
            }
            this.loadSurvey();
        }
    });

    appSurveyFill.mount('#appSurveyFill');
</script>


<!-- 引入 Bootstrap 脚本 -->
<script src="${pageContext.request.contextPath}/static/js/bootstrap.bundle.min.js"></script>
</body>
</html>
