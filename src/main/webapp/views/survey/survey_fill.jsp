<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>问卷填写页面</title>
    <!-- 引入 Bootstrap 样式 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/bootstrap.min.css">
    <!-- 引入 Vue -->
    <script src="${pageContext.request.contextPath}/static/js/vue.global.js"></script>
</head>
<body style="margin: 0; display: flex; justify-content: center; align-items: center; height: 100vh; background-color: #f8f9fa;">
<div id="app" class="container" style="max-width: 800px; background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1); margin:5%;">
    <h1 class="text-center mb-4" style="margin:3%">{{ survey.title || '测试问卷填写页面' }}</h1>
    <form @submit.prevent="submitForm">
        <div class="mb-3">
            <p id="description" class="form-control-plaintext">{{ survey.description || '请填写以下问卷内容' }}</p>
        </div>

        <!-- 遍历显示题目 -->
        <div v-for="(question, index) in questions" :key="index" class="mb-3 border p-3 rounded">
            <h5>{{ index + 1 }}. {{ question.title || getQuestionType(question.type) }}</h5>

            <!-- 根据问题类型显示对应输入框 -->
            <div v-if="question.type === 'text-input'">
                <input v-model="question.value" type="text" class="form-control" placeholder="请输入答案">
            </div>

            <div v-if="question.type === 'single-choice'">
                <div v-for="(option, optionIndex) in question.options" :key="optionIndex" class="form-check">
                    <input v-model="question.value" :value="option" class="form-check-input" type="radio" :id="'radio-' + index + '-' + optionIndex">
                    <label class="form-check-label" :for="'radio-' + index + '-' + optionIndex">{{ option }}</label>
                </div>
            </div>

            <div v-if="question.type === 'multi-choice'">
                <div v-for="(option, optionIndex) in question.options" :key="optionIndex" class="form-check">
                    <input v-model="question.value" :value="option" class="form-check-input" type="checkbox" :id="'checkbox-' + index + '-' + optionIndex">
                    <label class="form-check-label" :for="'checkbox-' + index + '-' + optionIndex">{{ option }}</label>
                </div>
            </div>

            <div v-if="question.type === 'phone-number'">
                <input v-model="question.value" type="text" class="form-control" placeholder="请输入11位手机号">
                <p v-if="!isValidPhoneNumber(question.value)" class="text-danger mt-1">手机号必须为11位数字</p>
            </div>

            <div v-if="question.type === 'id-number'">
                <input v-model="question.value" type="text" class="form-control" placeholder="请输入有效身份证号">
                <p v-if="!isValidIdNumber(question.value)" class="text-danger mt-1">身份证号格式不正确</p>
            </div>

            <div v-if="question.type === 'email'">
                <input v-model="question.value" type="email" class="form-control" placeholder="请输入有效邮箱">
                <p v-if="!isValidEmail(question.value)" class="text-danger mt-1">邮箱格式不正确</p>
            </div>
        </div>

        <button type="submit" class="btn btn-primary w-100">提交问卷</button>
    </form>
</div>

<script>
    const app = Vue.createApp({
        data() {
            return {
                survey: {
                    title: '用户满意度调查问卷', // 示例标题
                    description: '请根据您的实际情况填写以下问卷内容。'
                },
                questions: [
                    { type: 'single-choice', title: '你的性别是？', value: '', options: ['男', '女'] },
                    { type: 'multi-choice', title: '你喜欢的水果？', value: [], options: ['苹果', '香蕉', '橘子'] },
                    { type: 'text-input', title: '请简单介绍你自己', value: '' },
                    { type: 'phone-number', title: '请输入你的手机号', value: '' },
                    { type: 'id-number', title: '请输入你的身份证号', value: '' },
                    { type: 'email', title: '请输入你的邮箱', value: '' }
                ]
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
                alert('问卷提交成功！');
                console.log('问卷结果:', this.questions);
            }
        }
    });

    app.mount('#app');
</script>

<!-- 引入 Bootstrap 脚本 -->
<script src="${pageContext.request.contextPath}/static/js/bootstrap.bundle.min.js"></script>
</body>
</html>
