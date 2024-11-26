<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>个人信息</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/bootstrap.min.css">
    <!-- 引入自定义样式 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/common.css">
    <!-- 引入 Vue -->
    <script src="${pageContext.request.contextPath}/static/js/vue.global.js"></script>
    <!-- 引入 Axios -->
    <script src="${pageContext.request.contextPath}/static/js/axios.min.js"></script>
    <style>
        .user {
            display: flex;
            flex-direction: column;
            align-items: center;
            margin-top: 50px;
        }

        .bannar {
            background-color: #343a40;
            color: white;
            padding: 20px;
            border-radius: 10px;
            width: 100%;
            max-width: 600px;
            text-align: center;
        }

        .img {
            width: 100px;
            height: 100px;
            background-color: #ccc;
            border-radius: 50%;
            margin: 0 auto 10px;
        }

        .username {
            font-size: 24px;
            font-weight: bold;
        }

        .user-info {
            margin-top: 20px;
            width: 100%;
            max-width: 600px;
        }

        .info {
            text-align: center;
            margin-bottom: 20px;
        }

        .item {
            margin-bottom: 15px;
        }

        .button {
            display: flex;
            justify-content: space-between;
        }
    </style>
</head>
<body>
<div id="userInfoApp">
    <div class="user">
        <div class="bannar">
            <div class="out">
                <div class="left">
                    <div class="img"></div>
                    <div class="username">{{ userData.username }}</div>
                </div>
            </div>
        </div>
        <div class="user-info" style="width: 40%;">
            <div class="info">
                <h5>个人信息</h5>
                <div class="item">
                    <label for="username">用户名：</label>
                    <span> {{userData?.displayName || '用户名'}} </span>
                </div>
                <div class="item">
                    <label for="email">邮箱：</label>
                    <span> {{userData?.email || '邮箱'}} </span>
                </div>
                <div class="item">
                    <label for="phone">手机号：</label>
                    <span> {{userData?.phone || '手机号'}} </span>
                </div>
            </div>
            <form @submit.prevent="submitForm">
                <div class="item">
                    <label for="username">用户名：</label>
                    <input type="text" class="form-control" id="username" v-model="newData.displayName">
                </div>
                <div class="item">
                    <label for="old-password">旧密码：</label>
                    <input type="password" class="form-control" id="old-password" v-model="newData.oldPassword">
                </div>
                <div class="item">
                    <label for="new-password">新密码：</label>
                    <input type="password" class="form-control" id="new-password" v-model="newData.newPassword">
                </div>
                <div class="item">
                    <label for="email">邮箱：</label>
                    <input type="email" class="form-control" id="email" v-model="newData.email">
                </div>
                <div class="item">
                    <label for="phone">手机号：</label>
                    <input type="text" class="form-control" id="phone" v-model="newData.phone">
                </div>
                <div class="button">
                    <button type="submit" class="btn btn-success">确认</button>
                    <button type="button" class="btn btn-light" @click="fetchUserData">刷新</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    const userInfoApp = Vue.createApp({
        data() {
            return {
                userData: null,
                newData: {
                    displayName: '',
                    oldPassword: '',
                    newPassword: '',
                    email: '',
                    phone: ''
                }
            };
        },
        methods: {
            fetchUserData() {
                axios.get('api/user/profile', {
                    params: {token: this.token}
                })
                    .then(response => {
                    if (response.data.code === 200) {
                        this.userData = response.data.data;
                    } else {
                        console.error('Error fetching user data (user/profile)');
                        this.showErrorMessage('获取用户信息错误');
                    }
                })
                    .catch(() => {
                        this.showErrorMessage('服务器错误，请稍后再试');
                    })
            },
            submitForm() {
                if (this.userData.password !== this.newData.oldPassword) {
                    alert('旧密码错误！');
                    return;
                }
                axios.post('api/user/modify', {
                    params: {
                        token: this.token
                    },
                    newData: this.newData
                })
                    .then(response => {
                            if (response.data.code === 200) {
                                alert('个人信息修改成功！');
                                this.fetchUserData();
                            } else {
                                alert('个人信息修改失败：' + response.data.msg);
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
                    const toast = new bootstrap.Toast(toastEl, { delay: 3000 });
                    toast.show();
                });
            }
        },
        mounted() {
            this.originalData = {...this.userData}; // 保存原始数据
        }
    });

    userInfoApp.mount('#userInfoApp');
</script>
</body>
</html>