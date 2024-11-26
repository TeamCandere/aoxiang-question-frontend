<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
    <script src="<c:url value='/static/js/bootstrap.js'/>" type="text/javascript" defer></script>
    <script src="<c:url value='/static/js/qrcode.min.js'/>" type="text/javascript" defer></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js" type="text/javascript"></script>

    <style>
        .centered-container {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background-color: #f9f9f9;
            padding: 20px;
        }

        .centered-form {
            width: 50%;
            max-width: 1200px;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            background-color: #ffffff;
        }

        .card-body {
            text-align: center;
        }

        .qrcode-container {
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .qrcode {
            width: 300px;
            height: 300px;
        }

        .button-group {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-top: 1.5rem;
        }

        .input-group {
            margin-bottom: 1.5rem;
            font-size: 2rem;
        }

        .input-group input {
            font-size: 1rem;
            padding: 10px;
        }

        .btn {
            padding: 10px 20px;
            font-size: 1rem;
        }

    </style>
    <title>分享邀请他人填写</title>
</head>
<body>
<div class="centered-container">
    <div class="card centered-form">
        <div class="card-body">
            <h5 class="card-title" style="font-size: 1.8rem; margin-bottom: 1rem;">分享邀请他人填写</h5>
            <form>
                <!-- 二维码区域 -->
                <div class="qrcode-container">
                    <div class="qrcode mb-3" id="qrCodeUrl"></div>
                    <small class="form-text text-muted" style="font-size: 1rem;">微信扫码或长按识别，填写内容</small>
                </div>

                <!-- 分享链接 -->
                <!-- todo -->
                <div class="input-group">
                    <span class="input-group-text">分享链接</span>
                    <input type="text" class="liainjie form-control" value="https://f.wps.cn/g/uN4WA0Bo" aria-describedby="button-addon2">
                    <button class="btn btn-primary" type="button" id="copyLinkButton">复制链接</button>
                </div>

                <!-- 按钮组 -->
                <div class="button-group">
                    <a href="#" class="btn btn-secondary"><i class="fas fa-download"></i> 下载二维码</a>
                    <a href="#" class="btn btn-secondary"><i class="fas fa-file-alt"></i> 生成二维码海报</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script type="text/javascript">
    function drawQrc() {
        let textUrl = 'https://www.csdn.net';
        new QRCode('qrCodeUrl', {
            text: textUrl,
            width: 300,  // 更大的宽度
            height: 300, // 更大的高度
            colorDark: '#000000',
            colorLight: '#ffffff',
            correctLevel: QRCode.CorrectLevel.H
        });
    }

    $(function() {
        drawQrc();
    });
</script>
</body>
</html>
