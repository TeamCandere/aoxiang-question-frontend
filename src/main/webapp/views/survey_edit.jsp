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
<body>
<div id="app" class="container mt-4">
    <div class="row">
        <!-- 左侧导航栏 -->
        <div class="col-md-3 sidebar" style="height: 500px; display: flex; flex-direction: column; justify-content: center;">
            <!-- 添加各个题型的按钮 -->
            <div class="mb-3">
                <div class="col-6 mb-3">
                    <button type="button" class="btn btn-primary w-100" @click="addQuestion('single-choice')">添加单选题</button>
                </div>
                <div class="col-6 mb-3">
                    <button type="button" class="btn btn-primary w-100" @click="addQuestion('multi-choice')">添加多选题</button>
                </div>
                <div class="col-6 mb-3">
                    <button type="button" class="btn btn-primary w-100" @click="addQuestion('text-input')">添加填空题</button>
                </div>
                <div class="col-6 mb-3">
                    <button type="button" class="btn btn-primary w-100" @click="addQuestion('image-question')">添加图片题</button>
                </div>
            </div>
        </div>

        <!-- 主要内容区域 -->
        <div class="col-md-9 main-content mx-auto" style="min-height: 400px; display: flex; flex-direction: column; justify-content: flex-start;">
            <h1 class="text-center mb-4">问卷编辑页面</h1>
            <form @submit.prevent="submitForm">
                <div class="mb-3">
                    <label for="description" class="form-label">请输入表单描述</label>
                    <textarea v-model="description" class="form-control" id="description" rows="3"></textarea>
                </div>
                <div v-for="(question, index) in questions" :key="index" class="mb-3">
                    <!-- 各个问题类型的表单项 -->
                    <div v-if="question.type === 'single-choice'">
                        <label :for="'single-choice-' + index">单选题标题:</label>
                        <input v-model="question.title" type="text" class="form-control" :id="'single-choice-' + index">
                        <div v-for="(option, optionIndex) in question.options" :key="optionIndex" class="mb-2">
                            <input v-model="question.options[optionIndex]" type="text" class="form-control me-2" placeholder="选项">
                            <button type="button" class="btn btn-danger btn-sm" @click="removeOption(index, optionIndex)">删除</button>
                        </div>
                        <button type="button" class="btn btn-success btn-sm" @click="addOption(index)">添加选项</button>
                    </div>

                    <div v-else-if="question.type === 'multi-choice'">
                        <label :for="'multi-choice-' + index">多选题标题:</label>
                        <input v-model="question.title" type="text" class="form-control" :id="'multi-choice-' + index">
                        <div v-for="(option, optionIndex) in question.options" :key="optionIndex" class="mb-2">
                            <input v-model="question.options[optionIndex]" type="text" class="form-control me-2" placeholder="选项">
                            <button type="button" class="btn btn-danger btn-sm" @click="removeOption(index, optionIndex)">删除</button>
                        </div>
                        <button type="button" class="btn btn-success btn-sm" @click="addOption(index)">添加选项</button>
                    </div>

                    <!-- 填空题 -->
                    <div v-else-if="question.type === 'text-input'">
                        <label :for="'text-input-' + index">填空题标题:</label>
                        <select v-model="question.inputType" class="form-select" :id="'text-input-type-' + index">
                            <option value="phone">手机号</option>
                            <option value="id-card">身份证号</option>
                            <option value="email">邮箱</option>
                        </select>
                        <input v-model="question.value" type="text" class="form-control" :id="'text-input-' + index">
                    </div>

                    <!-- 图片题 -->
                    <div v-else-if="question.type === 'image-question'">
                        <label :for="'image-question-' + index">图片题标题:</label>
                        <input v-model="question.title" type="text" class="form-control" :id="'image-question-' + index">
                        <input v-model="question.image" type="file" class="form-control" :id="'image-upload-' + index">
                    </div>
                </div>

                <button type="submit" class="btn btn-primary float-end">提交</button>
            </form>
        </div>
    </div>
</div>


<!-- Vue 脚本 -->
<script>
    const app = Vue.createApp({
        data() {
            return {
                description: '',
                questions: []
            };
        },
        methods: {
            addQuestion(type) {
                const question = {
                    type,
                    title: ''
                };

                if (type === 'single-choice' || type === 'multi-choice') {
                    question.options = ['选项1', '选项2'];
                } else if (type === 'text-input') {
                    question.inputType = 'phone';
                    question.value = '';  // 添加 value 属性
                } else if (type === 'image-question') {
                    question.image = null;  // 添加 image 属性
                }

                this.questions.push(question);
            },
            addOption(index) {
                this.questions[index].options.push('');
            },
            removeOption(index, optionIndex) {
                this.questions[index].options.splice(optionIndex, 1);
            },
            submitForm() {
                console.log('Description:', this.description);
                console.log('Questions:', this.questions);
                // 这里可以添加提交表单的逻辑，例如发送到服务器
            }
        }
    });

    app.mount('#app');
</script>

<!-- 引入 Bootstrap 脚本 -->
<script src="${pageContext.request.contextPath}/static/js/bootstrap.bundle.min.js"></script>
</body>
</html>
