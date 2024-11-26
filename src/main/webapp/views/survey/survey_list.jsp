<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>问卷列表</title>
    <!-- 引入 Bootstrap 样式 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/bootstrap.min.css">
    <!-- 引入自定义样式 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/survey_list.css">
</head>
<body>
<div id="surveyApp" class="container mt-4">
    <!-- 标题 -->
    <h2 class="mb-3">我创建的 <span class="refresh-icon">⟳</span></h2>

    <!-- 表格 -->
    <table class="table table-borderless align-middle">
        <thead class="table-light">
        <tr>
            <th scope="col">名称</th>
            <th scope="col">收集状态</th>
            <th scope="col">最后修改</th>
            <th scope="col">审核状态</th>
            <th scope="col">其他</th>
        </tr>
        </thead>
        <tbody>
        <tr v-for="survey in paginatedSurveys" :key="survey.id">
            <td>{{ survey.name }}</td>
            <td>{{ survey.collectstatus }}</td>
            <td>{{ survey.lastModified }}</td>
            <td>{{survey.auditstatus}}</td>
            <td>
                <!-- 操作按钮 -->
                <div class="dropdown">
                    <button class="btn btn-light btn-sm custom-dropdown-toggle" type="button" id="dropdownMenuButton"
                            data-bs-toggle="dropdown" aria-expanded="false">
                        ...
                    </button>
                    <ul class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                        <li>
                            <a class="dropdown-item" href="#" @click.prevent="renameSurvey(survey.id)">重命名</a>
                        </li>
                        <li>
                            <a class="dropdown-item text-danger" href="#" @click.prevent="deleteSurvey(survey.id)">删除</a>
                        </li>
                    </ul>
                </div>

            </td>
        </tr>
        </tbody>
    </table>

    <!-- 分页组件 -->
    <nav>
        <ul class="pagination justify-content-center">
            <li class="page-item" :class="{ disabled: currentPage === 1 }">
                <button class="page-link" @click="changePage(currentPage - 1)">上一页</button>
            </li>
            <li class="page-item" v-for="page in totalPages" :key="page" :class="{ active: currentPage === page }">
                <button class="page-link" @click="changePage(page)">{{ page }}</button>
            </li>
            <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                <button class="page-link" @click="changePage(currentPage + 1)">下一页</button>
            </li>
        </ul>
    </nav>
</div>

<!-- Vue 脚本 -->
<script src="${pageContext.request.contextPath}/static/js/vue.global.js"></script>
<script>
    const app = Vue.createApp({
        data() {
            return {
                surveys: [
                    { id: 1, name: '问卷1', type: '表单', collectstatus: '未发布', lastModified: '1小时前',  auditstatus: '待审核' },
                    { id: 2, name: '问卷2', type: '问卷', collectstatus: '已发布', lastModified: '2小时前',  auditstatus: '通过' },
                    { id: 3, name: '问卷3', type: '调查', collectstatus: '未发布', lastModified: '3小时前', auditstatus: '待审核' },
                    { id: 4, name: '问卷4', type: '表单', collectstatus: '未发布', lastModified: '4小时前',  auditstatus: '驳回' },
                    { id: 5, name: '问卷5', type: '调查', collectstatus: '已发布', lastModified: '昨天',  auditstatus: '通过' },
                    { id: 6, name: '问卷6', type: '表单', collectstatus: '未发布', lastModified: '2天前',  auditstatus: '待审核' },
                    { id: 7, name: '问卷7', type: '问卷', collectstatus: '已发布', lastModified: '3天前', auditstatus: '通过' },
                    { id: 8, name: '问卷8', type: '调查', collectstatus: '未发布', lastModified: '4天前', auditstatus: '待审核' },
                    { id: 9, name: '问卷9', type: '表单', collectstatus: '未发布', lastModified: '5天前',  auditstatus: '驳回' },
                    { id: 10, name: '问卷10', type: '问卷', collectstatus: '已发布', lastModified: '6天前', auditstatus: '通过' },
                    { id: 11, name: '问卷11', type: '表单', collectstatus: '未发布', lastModified: '1周前',auditstatus: '待审核' },
                    { id: 12, name: '问卷12', type: '调查', collectstatus: '已发布', lastModified: '2周前',  auditstatus: '通过' },
                    { id: 13, name: '问卷13', type: '表单', collectstatus: '未发布', lastModified: '3周前',  auditstatus: '待审核' },
                    { id: 14, name: '问卷14', type: '问卷', collectstatus: '未发布', lastModified: '1个月前', auditstatus: '驳回' },
                    { id: 15, name: '问卷15', type: '表单', collectstatus: '已发布', lastModified: '1个月前',  auditstatus: '通过' },

                ],
                currentPage: 1,
                pageSize: 10
            };
        },
        computed: {
            totalPages() {
                return Math.ceil(this.surveys.length / this.pageSize);
            },
            paginatedSurveys() {
                const start = (this.currentPage - 1) * this.pageSize;
                const end = start + this.pageSize;
                return this.surveys.slice(start, end);
            }
        },
        methods: {
            changePage(page) {
                if (page > 0 && page <= this.totalPages) {
                    this.currentPage = page;
                }
            },
            renameSurvey(id) {
                const survey = this.surveys.find(s => s.id === id);
                const newName = prompt('请输入新名称', survey.name);
                if (newName) {
                    survey.name = newName;
                    alert('问卷名称已更新！');
                }
            },
            deleteSurvey(id) {
                if (confirm('确定要删除这份问卷吗？')) {
                    this.surveys = this.surveys.filter(s => s.id !== id);
                    alert('问卷已删除！');
                }
            }
        }
    });

    app.mount('#surveyApp');
</script>

<!-- 引入 Bootstrap 脚本 -->
<script src="${pageContext.request.contextPath}/static/js/bootstrap.bundle.min.js"></script>
</body>
</html>
