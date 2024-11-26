<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>问卷编辑页面</title>
    <!-- 引入 Bootstrap 样式 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/bootstrap.min.css">
    <!-- 引入 Vue -->
    <script src="${pageContext.request.contextPath}/static/js/vue.global.js"></script>
</head>
<body style="margin: 0; display: flex; justify-content: center; align-items: flex-start;">
<div id="app" class="container" style="width: 100%; max-width: 1200px; display: flex; height: 100vh;">
    <!-- 左侧导航栏 -->
    <div class="col-md-3 sidebar"
         style="height: 100%; display: flex; flex-direction: column; justify-content: center; align-items: center; position: sticky; top: 0; background-color: #f8f9fa; padding: 10px; border-right: 1px solid #ddd;">
        <div class="mb-3" style="width: 100%; display: flex; flex-direction: column; align-items: center;">
            <%--            <button type="button" class="btn btn-primary mb-3"--%>
            <%--                    style="width: 65%; margin-top: 7px; margin-bottom: 7px;"--%>
            <%--                    @click="addQuestion('single-choice')">--%>
            <%--                添加单选题--%>
            <%--            </button>--%>
            <%--            <button type="button" class="btn btn-primary mb-3"--%>
            <%--                    style="width: 65%; margin-top: 7px; margin-bottom: 7px;"--%>
            <%--                    @click="addQuestion('multi-choice')">--%>
            <%--                添加多选题--%>
            <%--            </button>--%>
            <button type="button" class="btn btn-primary mb-3"
                    style="width: 65%; margin-top: 7px; margin-bottom: 7px;"
                    @click="createQuestion(this.token, '填空题')">
                添加填空题
            </button>
            <%--            <button type="button" class="btn btn-primary mb-3"--%>
            <%--                    style="width: 65%; margin-top: 7px; margin-bottom: 7px;"--%>
            <%--                    @click="addQuestion('phone-number')">--%>
            <%--                添加手机号题--%>
            <%--            </button>--%>
            <%--            <button type="button" class="btn btn-primary mb-3"--%>
            <%--                    style="width: 65%; margin-top: 7px; margin-bottom: 7px;"--%>
            <%--                    @click="addQuestion('id-number')">--%>
            <%--                添加身份证题--%>
            <%--            </button>--%>
            <%--            <button type="button" class="btn btn-primary mb-3"--%>
            <%--                    style="width: 65%; margin-top: 7px; margin-bottom: 7px;"--%>
            <%--                    @click="addQuestion('email')">--%>
            <%--                添加邮箱题--%>
            <%--            </button>--%>
        </div>

        <div class="mb-3" style="width: 65%;">
            <label for="startDate">收集起始日期：</label>
            <input type="date" v-model="startDate" id="startDate" name="startDate" v-model="startDate" required
                   class="form-control">
        </div>
        <div class="mb-3" style="width: 65%;">
            <label for="endDate">收集截止日期：</label>
            <input type="date" v-model="endDate" id="endDate" name="endDate" required class="form-control">
        </div>
<%--        <button type="submit" class="btn btn-primary" style="width: 65%;">保存设置</button>--%>
    </div>


    <!-- 右侧内容区域 -->
    <div class="col-md-9 main-content"
         style="height: 100%; overflow-y: auto; padding: 20px;">
        <h1 class="text-center mb-4">问卷编辑页面</h1>
        <form @submit.prevent="submitForm">
            <div class="mb-3">
                <label for="title" class="form-label">请输入表单标题</label>
                <textarea v-model="this.survey.title" class="form-control" id="title" rows="3"></textarea>
            </div>
            <div class="mb-3">
                <label for="description" class="form-label">请输入表单描述</label>
                <textarea v-model="this.survey.description" class="form-control" id="description" rows="3"></textarea>
            </div>

            <!-- 遍历显示题目 -->
            <div v-for="(question, index) in questions" :key="index" class="mb-3 border p-3 rounded">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <h5>{{ index + 1 }}. {{ question.title || '问题' }}</h5>
                    <button type="button" class="btn btn-danger btn-sm" @click="removeQuestion(question.id,this.token)">
                        删除题目
                    </button>
                </div>

                <!-- 各个问题类型的表单项 -->
                <div>
                    <label :for="'title-' + index">题目标题:</label>
                    <input v-model="question.content" type="text" class="form-control" :id="'title-' + index">
                </div>

                <!--文本类型问题-->
                <div>
                    <label :for="'input-' + index">回答区域:</label>
                    <input readonly type="text" class="form-control" :id="'input-' + index"
                           placeholder="请输入你的答案">
                </div>

                <%--                <div v-if="question.type === 'single-choice' || question.type === 'multi-choice'">--%>
                <%--                    <div v-for="(option, optionIndex) in question.options" :key="optionIndex" class="mb-2">--%>
                <%--                        <input v-model="question.options[optionIndex]" type="text" class="form-control me-2"--%>
                <%--                               placeholder="选项">--%>
                <%--                        <button type="button" class="btn btn-danger btn-sm" @click="removeOption(index, optionIndex)">--%>
                <%--                            删除选项--%>
                <%--                        </button>--%>
                <%--                    </div>--%>
                <%--                    <button type="button" class="btn btn-success btn-sm" @click="addOption(index)">添加选项</button>--%>
                <%--                </div>--%>

                <%--                <div v-if="question.type === 'phone-number'">--%>
                <%--                    <label :for="'phone-number-' + index">请输入手机号:</label>--%>
                <%--                    <input v-model="question.value" type="text" class="form-control" :id="'phone-number-' + index"--%>
                <%--                           placeholder="请输入11位手机号">--%>
                <%--                    <p v-if="!isValidPhoneNumber(question.value)" class="text-danger mt-1">手机号必须为11位数字</p>--%>
                <%--                </div>--%>

                <%--                <div v-if="question.type === 'id-number'">--%>
                <%--                    <label :for="'id-number-' + index">请输入身份证号:</label>--%>
                <%--                    <input v-model="question.value" type="text" class="form-control" :id="'id-number-' + index"--%>
                <%--                           placeholder="请输入有效身份证号">--%>
                <%--                    <p v-if="!isValidIdNumber(question.value)" class="text-danger mt-1">身份证号格式不正确</p>--%>
                <%--                </div>--%>

                <%--                <div v-if="question.type === 'email'">--%>
                <%--                    <label :for="'email-' + index">请输入邮箱:</label>--%>
                <%--                    <input v-model="question.value" type="email" class="form-control" :id="'email-' + index"--%>
                <%--                           placeholder="请输入有效邮箱">--%>
                <%--                    <p v-if="!isValidEmail(question.value)" class="text-danger mt-1">邮箱格式不正确</p>--%>
                <%--                </div>--%>
            </div>

            <button type="submit" class="btn btn-primary float-end">保存并发布</button>
        </form>
    </div>
</div>
</body>

<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
<script src="https://cdn.staticfile.org/jquery/3.2.1/jquery.min.js"></script>
<script>
    const app = Vue.createApp({
        data() {
            return {
                startDate: '1970-01-01',
                endDate: '2099-01-01',
                description: '',
                token: localStorage.getItem('token'),
                survey: {

                },
                questions: [] // 用于存储所有问题的数组
            };
        },
        methods: {
            // getQuestionType(type) {
            //     const types = {
            //         'single-choice': '单选题',
            //         'multi-choice': '多选题',
            //         'text-input': '填空题',
            //         'phone-number': '手机号题',
            //         'id-number': '身份证题',
            //         'email': '邮箱题'
            //     };
            //     return types[type] || '未知题型';
            // },
            createQuestion(token, content) {
                axios.get('${pageContext.request.contextPath}/api/question/create', {
                        params: {
                            token: token,
                            surveyId: this.survey.id
                        }
                    }
                )
                    .then(response => {
                        if (response.data.code === 200) {
                            console.log('问题创建成功。');
                            const questionId = response.data.data;
                            this.editQuestion(questionId, content, token);
                        } else {
                            alert('问题创建失败：' + response.data.msg);
                        }
                    })
                    .catch(() => {
                        this.showErrorMessage('服务器错误，请稍后再试');
                    });
            },
            editQuestion(questionId, content, token) {
                axios.post('${pageContext.request.contextPath}/api/question/edit', {
                    token: token,
                    content: content,
                    questionId: questionId
                }).then(response => {
                    if (response.data.code === 200) {
                        console.log('问题修改成功。');
                        this.fetchQuestion(questionId, token);
                    } else {
                        alert('修改问题失败：' + response.data.msg);
                    }
                }).catch(error => alert('服务器错误，请稍后再试'));
            },
            fetchQuestion(questionId, token) {
                axios.get('${pageContext.request.contextPath}/api/question/' + questionId, {
                    params: {
                        token: token
                    }
                }).then(response => {
                    if (response.data.code === 200) {
                        console.log('问题获取成功。');
                        this.addOrUpdate(response.data.data);
                    } else {
                        alert('修改问题失败：' + response.data.msg);
                    }
                }).catch(error => alert('服务器错误，请稍后再试'));
            },
            removeQuestion(questionId, token) {
                axios.get('${pageContext.request.contextPath}/api/question/delete/' + questionId, {
                    params: {
                        token: token
                    }
                }).then(response => {
                    if (response.data.code === 200) {
                        console.log('问题删除成功。');
                        this.questions = this.questions.filter(question => question.id !== questionId);
                    } else {
                        alert('删除问题失败：' + response.data.msg);
                    }
                }).catch(error => alert('服务器错误，请稍后再试'));
            },
            addOrUpdate(question) {
                const index = this.questions.findIndex(q => q.id === question.id);

                if (index !== -1) {
                    // 更新现有问题
                    this.questions[index] = {...this.questions[index], ...question};
                } else {
                    // 添加新问题
                    this.questions.push(question);
                }
            }
            ,
            // addOption(index) {
            //     this.questions[index].options.push('');
            // },
            // removeOption(index, optionIndex) {
            //     this.questions[index].options.splice(optionIndex, 1);
            // },
            isValidPhoneNumber(value) {
                return /^[0-9]{11}$/.test(value);
            },
            isValidIdNumber(value) {
                return /^[0-9]{15}$|^[0-9]{17}[0-9Xx]$/.test(value);
            },
            isValidEmail(value) {
                return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
            },
            fetchSurvey(surveyId) {
                axios.get("${pageContext.request.contextPath}/api/survey/" + surveyId, {
                    params: {
                        token: this.token
                    }
                })
                    .then(response => {
                        if (response.data.code === 200) {
                            this.survey = response.data.data;
                        } else {
                            console.log("get survey failed");
                            alert("问卷获取失败：" + response.data.msg);
                        }
                    })
                    .catch(() => {
                        this.showErrorMessage('服务器错误，请稍后再试');
                    })
            },
            submitForm() {
                console.log('Description:', this.description);
                console.log('Questions:', this.questions);

                // if (this.questions.some(q => q.type === 'phone-number' && !this.isValidPhoneNumber(q.value))) {
                //     alert('请检查手机号题的格式是否正确');
                //     return;
                // }
                //
                // if (this.questions.some(q => q.type === 'id-number' && !this.isValidIdNumber(q.value))) {
                //     alert('请检查身份证题的格式是否正确');
                //     return;
                // }
                //
                // if (this.questions.some(q => q.type === 'email' && !this.isValidEmail(q.value))) {
                //     alert('请检查邮箱题的格式是否正确');
                //     return;
                // }

                for (const question of this.questions) {
                    this.editQuestion(question.id, question.content, this.token);
                }
                const sd = new Date(this.startDate);
                const ed = new Date(this.endDate);
                ed.setHours(23);
                ed.setMinutes(59);
                ed.setSeconds(59);
                const startTime = this.formatDateWithTimezone(sd);
                const endTime = this.formatDateWithTimezone(ed);
                this.survey.startTime = startTime;
                this.survey.endTime = endTime;
                this.submitSurvey(this.survey, this.token);
            },
            submitSurvey(survey, token) {
                axios.post("${pageContext.request.contextPath}/api/survey/edit/" + survey.id,
                     {
                        token: token,
                        title: survey.title,
                        description: survey.description,
                        startTime: survey.startTime,
                        endTime: survey.endTime
                    }
                )
                    .then(response => {
                        if (response.data.code === 200) {

                            axios.get("${pageContext.request.contextPath}/api/survey/submit/" + survey.id,
                                {
                                    params:{
                                        token :token
                                    }
                                }
                            ).then(response => {
                                if(response.data.code === 200){
                                    alert('问卷提交成功！');
                                }else{
                                    alert('问卷提交失败：' + response.data.msg);
                                }
                            }).catch(error => {
                                alert('服务器错误，请稍后重试');
                            })
                        } else {
                            console.log("submit survey failed");
                            alert("问卷提交失败：" + response.data.msg);
                        }
                    })
                    .catch(() => {
                        this.showErrorMessage('服务器错误，请稍后再试');
                    })
            },

            createSurvey(token) {
                axios.get('${pageContext.request.contextPath}/api/survey/create', {
                        params: {
                            token: token
                        }
                    }
                )
                    .then(response => {
                        if (response.data.code === 200) {
                            this.fetchSurvey(response.data.data);
                            console.log('问卷创建成功。');
                        } else {
                            alert('问卷创建失败：' + response.data.msg);
                        }
                    })
                    .catch(() => {
                        this.showErrorMessage('服务器错误，请稍后再试');
                    });
            },
        showErrorMessage(message) {
            this.errorMessage = message;
            const toastElList = Array.from(document.querySelectorAll('.toast'));
            toastElList.forEach(toastEl => {
                const toast = new bootstrap.Toast(toastEl, {delay: 3000});
                toast.show();
            });
        },
        formatDateWithTimezone(date) {
            // 获取年月日
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, "0"); // 月份从0开始，需加1
            const day = String(date.getDate()).padStart(2, "0");

            // 获取时分秒
            const hours = String(date.getHours()).padStart(2, "0");
            const minutes = String(date.getMinutes()).padStart(2, "0");
            const seconds = String(date.getSeconds()).padStart(2, "0");

            // 假设时区偏移为 +08:00
            const timezoneOffset = "+08:00"; // 这里假设是中国标准时间

            // 拼接为带时区的时间格式
            return year + "-" + month + "-" + day + "T" + hours + ":" + minutes + ":" + seconds + timezoneOffset;
        },
        },
        mounted() {
            if (this.token) {
                this.createSurvey(this.token);
            }
        }
    });

    app.mount('#app');
</script>

<!-- 引入 Bootstrap 脚本 -->
<script src="${pageContext.request.contextPath}/static/js/bootstrap.bundle.min.js"></script>

</html>
