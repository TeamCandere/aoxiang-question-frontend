<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户管理</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/bootstrap.min.css">
    <!-- 引入自定义样式 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/common.css">
    <!-- 引入 Vue -->
    <script src="${pageContext.request.contextPath}/static/js/vue.global.js"></script>
    <!-- 引入 Axios -->
    <script src="${pageContext.request.contextPath}/static/js/axios.min.js"></script>
</head>
<body>
<div class="container" id="userManagerApp" style="margin-top: 50px;">
    <h2 class="text-center mb-5">用户管理</h2>
    <p class="text-center">在这里可以查看和管理所有用户。</p>

    <!-- 用户列表 -->
    <table class="table table-bordered">
        <thead>
        <tr>
            <th>#</th>
            <th>用户名</th>
            <th>邮箱</th>
            <th>注册时间</th>
            <th>操作</th>
        </tr>
        </thead>
        <tbody>
        <tr v-for="(user, index) in users" :key="user.id">
            <td>{{ index + 1 }}</td>
            <td>{{ user.username }}</td>
            <td>{{ user.email }}</td>
            <td>{{ formatDateTime(user.createdAt) }}</td>
            <td>
                <button class="btn btn-primary" @click="editUser(user.id)">编辑</button>
                <button class="btn btn-danger" @click="deleteUser(user.id)">删除</button>
            </td>
        </tr>
        </tbody>
    </table>
</div>
<script src="${pageContext.request.contextPath}/static/js/bootstrap.bundle.min.js"></script>
<script>
    const userManagerApp = Vue.createApp({
        data() {
            return {
                users: [],
                token: localStorage.getItem("token") // 从 localStorage 中获取 token
            };
        },
        mounted() {
            if (this.token) {
                this.fetchUsers();
            }
        },
        methods: {
            fetchUsers() {
                axios.get('${pageContext.request.contextPath}/api/user/all', {
                    params: { token: this.token }
                })
                    .then(response => {
                        if (response.data.code === 200) {
                            this.users = response.data.data;
                        } else {
                            console.error('Failed to fetch users:', response.data.message);
                        }
                    })
                    .catch(error => {
                        console.error('Error fetching users:', error);
                    });
            },
            formatDateTime(dateTime) {
                return new Date(dateTime).toLocaleString();
            },
            editUser(userId) {
                // 这里可以实现编辑用户的逻辑
                alert(`编辑用户 ID: ${userId}`);
                // 可以跳转到编辑用户的页面或者弹出模态框显示编辑表单
            },
            deleteUser(userId) {
                if (confirm('确定要删除此用户吗？')) {
                    axios.post('${pageContext.request.contextPath}/api/user/delete/' + userId, {
                        token: this.token
                    })
                        .then(response => {
                            if (response.data.code === 200) {
                                alert('成功删除用户。');
                                this.fetchUsers(); // 刷新用户列表
                            } else {
                                alert('删除失败: ' + response.data.message);
                            }
                        })
                        .catch(error => {
                            console.error('Error deleting user:', error);
                        });
                }
            }
        }
    });

    userManagerApp.mount('#userManagerApp');
</script>
</body>
</html>