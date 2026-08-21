<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>ログイン - AI Smart Meeting System</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2">
  <style>
    .login-container {
      max-width: 400px;
      margin: 80px auto;
      padding: 30px;
      background: #ffffff;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    }
    .login-field { margin-bottom: 20px; }
    .login-field label { display: block; margin-bottom: 6px; font-weight: bold; font-size: 9pt; }
    .login-field input { width: 100%; padding: 8px; box-sizing: border-box; }
    .error-msg { color: #ef4444; font-size: 8.5pt; margin-bottom: 15px; }
  </style>
</head>
<body style="background-color: #f1f5f9;">

  <div class="login-container">
    <h2 style="text-align: center; margin-bottom: 20px; color: #0f172a;">⚡ ログイン</h2>

    <!-- エラーメッセージ表示エリア -->
    <c:if test="${not empty errorMessage}">
      <div class="error-msg">⚠️ <c:out value="${errorMessage}"/></div>
    </c:if>

    <form action="${pageContext.request.contextPath}/login" method="POST">
      <div class="login-field">
        <label for="email">メールアドレス</label>
        <!-- ★ value 属性を削除して初期表示を空欄に修正 -->
        <input type="email" id="email" name="email" placeholder="example@example.com" required>
      </div>

      <button type="submit" class="btn-primary" style="width: 100%; padding: 10px; font-size: 10pt;">
        ログインしてダッシュボードへ
      </button>
    </form>
  </div>

</body>
</html>