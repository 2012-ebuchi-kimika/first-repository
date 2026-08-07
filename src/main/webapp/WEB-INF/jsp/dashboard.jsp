<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>⚡ AI Smart Meeting System</title>
  <!-- 共通レイアウトCSSの読み込み -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  
  <!-- 現在時刻（現在日時の比較用）を取得 -->
  <jsp:useBean id="now" class="java.util.Date" />
  <fmt:formatDate value="${now}" pattern="yyyy-MM-dd'T'HH:mm" var="currentFormattedDate" />
</head>
<body>

<div class="app-container">
  <div class="navbar">
    <div class="brand-logo">⚡ AI Smart Meeting System</div>
    <div>
      trainee1405@company.com <span class="user-badge">管理者</span>
      <!-- ⚙️ グループ管理ボタン -->
      <button type="button" class="btn-secondary" style="margin-left: 10px; padding: 4px 10px; font-size: 8.5pt;" onclick="openGroupModal()">⚙️ グループ管理</button>
    </div>
  </div>

  <div class="main-content">
    <div class="action-bar">
      <!-- 新規会議作成ボタン -->
      <button type="button" class="btn-primary" onclick="openModal()">＋ 新規会議を作成</button>
      
      <div class="search-container">
        <form action="${pageContext.request.contextPath}/dashboard" method="GET" class="search-box-group" onsubmit="validateForm(event)">
          <input type="hidden" name="showAll" value="${showAll}">
          
          <!-- 入力欄とエラー吹き出し -->
          <div style="position: relative; display: inline-block;">
            <input type="text" id="searchInput" name="keyword" class="search-box" 
                   placeholder="🔍 会議・キーワード検索..." value="<c:out value='${keyword}'/>" oninput="checkInputValidation()">
            
            <div id="validationError" class="error-message"></div>
          </div>

          <button type="submit" class="btn-secondary">検索</button>
          <a href="${pageContext.request.contextPath}/dashboard" class="btn-secondary" style="background-color: #f1f5f9;">クリア</a>
        </form>
      </div>
    </div>

    <div class="layout-grid">
      <!-- 左カラム：会議一覧 -->
      <div class="left-col">
        <div class="card">
          <div class="card-header">
            <span>📅 直近の会議とAI要約</span>
            <c:choose>
              <c:when test="${showAll}">
                <a href="${pageContext.request.contextPath}/dashboard?keyword=${keyword}&showAll=false" 
                   style="font-size: 8.5pt; color: #0284c7; text-decoration: none;">↩️ 直近のみ表示に戻す</a>
              </c:when>
              <c:otherwise>
                <a href="${pageContext.request.contextPath}/dashboard?keyword=${keyword}&showAll=true" 
                   style="font-size: 8.5pt; color: #64748b; text-decoration: none;">📜 過去の会議もすべて表示</a>
              </c:otherwise>
            </c:choose>
          </div>
          
          <div id="meetingListArea" class="scrollable-area">
            <c:choose>
              <c:when test="${empty meetings}">
                <div style="text-align: center; color: #64748b; padding: 20px;">該当する会議は見つかりませんでした。</div>
              </c:when>
              <c:otherwise>
                <c:forEach var="m" items="${meetings}">
                  <!-- 会議カードクリックで SCR-03 議事録詳細画面へ遷移 -->
                  <div class="meeting-item" onclick="location.href='${pageContext.request.contextPath}/meetings/detail?id=${m.meetingId}'">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                      <div class="meeting-title"><c:out value="${m.title}"/></div>
                      
                      <!-- 未来日時判定バッジ -->
                      <c:choose>
                        <c:when test="${m.startTime > currentFormattedDate}">
                          <span style="background-color: #fef3c7; color: #d97706; border: 1px solid #fde68a; padding: 2px 8px; border-radius: 12px; font-size: 7.5pt; font-weight: bold;">
                            📅 予定 (未来)
                          </span>
                        </c:when>
                        <c:otherwise>
                          <span style="background-color: #f1f5f9; color: #64748b; border: 1px solid #e2e8f0; padding: 2px 8px; border-radius: 12px; font-size: 7.5pt; font-weight: bold;">
                            ✅ 終了
                          </span>
                        </c:otherwise>
                      </c:choose>
                    </div>

                    <div class="meeting-date">
                      🕒 <c:out value="${m.startTime}"/> | ペルソナ: <c:out value="${empty m.personaType ? '標準' : m.personaType}"/>
                    </div>

                    <!-- AI要約の有無による表示分岐 -->
                    <c:choose>
                      <c:when test="${not empty m.aiSummary}">
                        <div class="ai-summary-box">
                          <b>✨ Gemini AI要約</b><br>
                          <c:out value="${m.aiSummary}"/>
                        </div>
                      </c:when>
                      <c:otherwise>
                        <div class="ai-summary-box" style="background-color: #fffbebfb; border: 1.5px dashed #f59e0b; color: #b45309; text-align: center; padding: 8px 12px;">
                          <b>⚠️ 議事録・要約未作成</b><br>
                          <span style="font-size: 8pt; color: #d97706;">クリックして議事録入力＆AI要約を生成</span>
                        </div>
                      </c:otherwise>
                    </c:choose>
                  </div>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </div>

      <!-- 右カラム：未完了タスク -->
      <div class="right-col">
        <div class="card">
          <div class="card-header">
            ☑️ 未完了タスク <span>全 <c:out value="${fn:length(tasks)}"/> 件</span>
          </div>
          <div id="taskListArea" class="scrollable-area">
            <c:choose>
              <c:when test="${empty tasks}">
                <div style="text-align: center; color: #64748b; padding: 10px;">未完了タスクはありません</div>
              </c:when>
              <c:otherwise>
                <c:forEach var="t" items="${tasks}">
                  <c:if test="${t.status != 'COMPLETED'}">
                    <div class="task-row" onclick="location.href='${pageContext.request.contextPath}/tasks'">
                      <div style="flex: 1; padding-right: 8px;">
                        <div style="font-size: 7.5pt; color: #0284c7; background-color: #f0f9ff; padding: 2px 6px; border-radius: 4px; display: inline-block; margin-bottom: 4px; border: 1px solid #bae6fd;">
                          📌 <c:out value="${empty t.meetingTitle ? '未紐付け' : t.meetingTitle}"/>
                        </div>
                        <div style="font-weight: bold; font-size: 9.5pt;"><c:out value="${t.taskContent}"/></div>
                        <div style="font-size: 8pt; color: #64748b; margin-top: 4px;">
                          担当: <c:out value="${empty t.assigneeEmail ? '未設定' : t.assigneeEmail}"/> | 
                          <span class="badge-due">締切: <c:out value="${empty t.dueDate ? '期限なし' : t.dueDate}"/></span>
                        </div>
                      </div>
                      <span class="badge-status"><c:out value="${t.status}"/></span>
                    </div>
                  </c:if>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- モーダルファイルのインクルード -->
<jsp:include page="modal-create-meeting.jsp" />
<jsp:include page="modal-group-management.jsp" />

<script>
  // 共通背景クリックでモーダルを閉じる処理
  window.onclick = function(event) {
    const meetingModal = document.getElementById('createMeetingModal');
    const groupModal = document.getElementById('groupManagementModal');
    if (event.target === meetingModal && typeof closeModal === 'function') closeModal();
    if (event.target === groupModal && typeof closeGroupModal === 'function') closeGroupModal();
  };

  // 検索バリデーション
  function checkInputValidation() {
    const inputElem = document.getElementById('searchInput');
    const errorElem = document.getElementById('validationError');
    const value = inputElem.value;

    if (value.length > 50) {
      inputElem.classList.add('error');
      errorElem.innerText = '検索ワードは50文字以内で入力してください。（現在: ' + value.length + '文字）';
      return false;
    } else {
      inputElem.classList.remove('error');
      errorElem.innerText = '';
      return true;
    }
  }

  function validateForm(event) {
    if (!checkInputValidation()) {
      event.preventDefault();
    }
  }
</script>

</body>
</html>