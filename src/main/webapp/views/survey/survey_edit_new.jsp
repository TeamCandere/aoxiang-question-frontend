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
            <button type="button" class="btn btn-primary mb-3"
                    style="width: 65%; margin-top: 7px; margin-bottom: 7px;"
                    @click="addQuestion('single-choice')">
                添加单选题
            </button>
            <button type="button" class="btn btn-primary mb-3"
                    style="width: 65%; margin-top: 7px; margin-bottom: 7px;"
                    @click="addQuestion('multi-choice')">
                添加多选题
            </button>
            <button type="button" class="btn btn-primary mb-3"
                    style="width: 65%; margin-top: 7px; margin-bottom: 7px;"
                    @click="addQuestion('text-input')">
                添加填空题
            </button>
            <button type="button" class="btn btn-primary mb-3"
                    style="width: 65%; margin-top: 7px; margin-bottom: 7px;"
                    @click="addQuestion('phone-number')">
                添加手机号题
            </button>
            <button type="button" class="btn btn-primary mb-3"
                    style="width: 65%; margin-top: 7px; margin-bottom: 7px;"
                    @click="addQuestion('id-number')">
                添加身份证题
            </button>
            <button type="button" class="btn btn-primary mb-3"
                    style="width: 65%; margin-top: 7px; margin-bottom: 7px;"
                    @click="addQuestion('email')">
                添加邮箱题
            </button>
        </div>

        <div class="mb-3" style="width: 65%;">
            <label for="startDate">收集起始日期：</label>
            <input type="date" id="startDate" name="startDate" v-model="startDate" required class="form-control">
        </div>
        <div class="mb-3" style="width: 65%;">
            <label for="endDate">收集截止日期：</label>
            <input type="date" id="endDate" name="endDate" required class="form-control">
        </div>
        <button type="submit" class="btn btn-primary" style="width: 65%;">保存设置</button>
    </div>



    <!-- 右侧内容区域 -->
    <div class="col-md-9 main-content"
         style="height: 100%; overflow-y: auto; padding: 20px;">
        <h1 class="text-center mb-4">问卷编辑页面</h1>
        <form @submit.prevent="submitForm">
            <div class="mb-3">
                <label for="description" class="form-label">请输入表单描述</label>
                <textarea v-model="description" class="form-control" id="description" rows="3"></textarea>
            </div>

            <!-- 遍历显示题目 -->
            <div v-for="(question, index) in questions" :key="index" class="mb-3 border p-3 rounded">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <h5>{{ index + 1 }}. {{ question.title || getQuestionType(question.type) }}</h5>
                    <button type="button" class="btn btn-danger btn-sm" @click="removeQuestion(index)">删除题目</button>
                </div>

                <!-- 各个问题类型的表单项 -->
                <div v-if="['single-choice', 'multi-choice', 'text-input', 'phone-number', 'id-number', 'email'].includes(question.type)">
                    <label :for="'title-' + index">题目标题:</label>
                    <input v-model="question.title" type="text" class="form-control" :id="'title-' + index">
                </div>

                <div v-if="question.type === 'text-input'">
                    <label :for="'input-' + index">回答区域:</label>
                    <input v-model="question.value" type="text" class="form-control" :id="'input-' + index" placeholder="请输入你的答案">
                </div>

                <div v-if="question.type === 'single-choice' || question.type === 'multi-choice'">
                    <div v-for="(option, optionIndex) in question.options" :key="optionIndex" class="mb-2">
                        <input v-model="question.options[optionIndex]" type="text" class="form-control me-2" placeholder="选项">
                        <button type="button" class="btn btn-danger btn-sm" @click="removeOption(index, optionIndex)">删除选项</button>
                    </div>
                    <button type="button" class="btn btn-success btn-sm" @click="addOption(index)">添加选项</button>
                </div>

                <div v-if="question.type === 'phone-number'">
                    <label :for="'phone-number-' + index">请输入手机号:</label>
                    <input v-model="question.value" type="text" class="form-control" :id="'phone-number-' + index" placeholder="请输入11位手机号">
                    <p v-if="!isValidPhoneNumber(question.value)" class="text-danger mt-1">手机号必须为11位数字</p>
                </div>

                <div v-if="question.type === 'id-number'">
                    <label :for="'id-number-' + index">请输入身份证号:</label>
                    <input v-model="question.value" type="text" class="form-control" :id="'id-number-' + index" placeholder="请输入有效身份证号">
                    <p v-if="!isValidIdNumber(question.value)" class="text-danger mt-1">身份证号格式不正确</p>
                </div>

                <div v-if="question.type === 'email'">
                    <label :for="'email-' + index">请输入邮箱:</label>
                    <input v-model="question.value" type="email" class="form-control" :id="'email-' + index" placeholder="请输入有效邮箱">
                    <p v-if="!isValidEmail(question.value)" class="text-danger mt-1">邮箱格式不正确</p>
                </div>
            </div>

            <button type="submit" class="btn btn-primary float-end">保存并发布</button>
        </form>
    </div>
</div>
</body>



<script>
    const app = Vue.createApp({
        data() {
            return {
                description: '',
                questions: [] // 用于存储所有问题的数组
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
            addQuestion(type) {
                const question = { type, title: '', value: '' };

                if (type === 'single-choice' || type === 'multi-choice') {
                    question.options = ['选项1', '选项2'];
                }

                this.questions.push(question);
            },
            removeQuestion(index) {
                this.questions.splice(index, 1);
            },
            addOption(index) {
                this.questions[index].options.push('');
            },
            removeOption(index, optionIndex) {
                this.questions[index].options.splice(optionIndex, 1);
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
            submitForm() {
                console.log('Description:', this.description);
                console.log('Questions:', this.questions);

                if (this.questions.some(q => q.type === 'phone-number' && !this.isValidPhoneNumber(q.value))) {
                    alert('请检查手机号题的格式是否正确');
                    return;
                }

                if (this.questions.some(q => q.type === 'id-number' && !this.isValidIdNumber(q.value))) {
                    alert('请检查身份证题的格式是否正确');
                    return;
                }

                if (this.questions.some(q => q.type === 'email' && !this.isValidEmail(q.value))) {
                    alert('请检查邮箱题的格式是否正确');
                    return;
                }

                alert('表单提交成功！');
            }
        }
    });

    app.mount('#app');
</script>

<!-- 引入 Bootstrap 脚本 -->
<script src="${pageContext.request.contextPath}/static/js/bootstrap.bundle.min.js"></script>

</html>
