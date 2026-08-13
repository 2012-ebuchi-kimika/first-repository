<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>📌 タスクステータス・詳細変更</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2">
</head>
<body style="background-color: #f8fafc; padding: 24px;">

<div class="task-detail-container">
  
  <!-- ヘッダー -->
  <div class="task-detail-header">
    <h2 class="task-detail-title">📌 タスクステータス・詳細変更</h2>
    <span class="task-detail-id-badge">タスクID: <c:out value="${task.taskId}"/></span>
  </div>

  <form action="${pageContext.request.contextPath}/tasks/update" method="POST" onsubmit="return validateTaskForm(event)">
    <input type="hidden" name="taskId" value="${task.taskId}">

    <!-- タスク内容 -->
    <div class="form-group task-detail-form-group">
      <label class="form-label task-detail-label">
        タスク内容 <span style="color: #ef4444;">*</span>
      </label>
      <input type="text" id="taskContent" name="taskContent" class="form-input task-detail-input-content" value="<c:out value='${task.taskContent}'/>" required>
    </div>

    <!-- 担当者選択エリア（チェックリスト ＋ 検索 ＋ 未完了数バッジ付き） -->
    <div class="form-group task-detail-assignee-box">
      <label class="form-label" style="margin-bottom: 6px; font-weight: bold; font-size: 8.5pt;">
        👤 担当者選択
      </label>
      
      <!-- リアルタイム絞り込み検索窓 -->
      <div style="margin-bottom: 8px;">
        <input type="text" id="assigneeSearchInput" class="form-input task-detail-search-input" placeholder="🔍 名前・メールで絞り込み..." oninput="filterAssigneeList()">
      </div>

      <!-- メンバーチェックリスト -->
      <div id="assigneeListContainer" class="task-detail-assignee-list">
        <c:choose>
          <c:when test="${empty users}">
            <div style="font-size: 8pt; color: #64748b; padding: 8px; text-align: center;">登録メンバーがいません</div>
          </c:when>
          <c:otherwise>
            <c:forEach var="u" items="${users}">
              <label class="assignee-item-label" data-search-text="<c:out value='${u.name}'/> <c:out value='${u.email}'/>" onmouseover="this.style.backgroundColor='#f1f5f9'" onmouseout="this.style.backgroundColor='transparent'">
                
                <!-- 左側：チェックボックス ＋ 名前 ＋ メール -->
                <span style="display: flex; align-items: center; gap: 8px;">
                  <input type="checkbox" class="assignee-checkbox" value="<c:out value='${u.email}'/>" onchange="syncAssignees()"> 
                  <span><b><c:out value="${u.name}"/></b> <span style="color: #64748b; font-size: 8pt;">(<c:out value="${u.email}"/>)</span></span>
                </span>

                <!-- 右側：未完了タスク件数バッジ -->
                <c:choose>
                  <c:when test="${u.pendingTaskCount > 0}">
                    <span class="task-detail-badge-pending">
                      ⚠️ 未完了タスク: <c:out value="${u.pendingTaskCount}"/>件
                    </span>
                  </c:when>
                  <c:otherwise>
                    <span class="task-detail-badge-none">
                      ✨ 未完了なし
                    </span>
                  </c:otherwise>
                </c:choose>

              </label>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </div>

      <!-- 選択結果連携テキストエリア -->
      <label class="form-label task-detail-email-label">
        担当者メールアドレス (複数指定する場合はカンマ「,」区切り):
      </label>
      <input type="text" id="assigneeEmailInput" name="assigneeEmail" class="form-input task-detail-email-input" value="<c:out value='${task.assigneeEmail}'/>" placeholder="選択した担当者が自動入力されます">
    </div>

    <!-- 履行期限 & 進捗ステータス 2カラム並び -->
    <div class="task-detail-grid-2col">
      
      <!-- 履行期限 -->
      <div class="form-group" style="margin: 0;">
        <label class="form-label task-detail-label">履行期限</label>
        
        <div class="task-detail-date-box">
          
          <!-- 左側：カレンダー起動エリア -->
          <div class="task-detail-date-inner">
            <span style="font-size: 11pt; margin-right: 8px; user-select: none;">📅</span>
            <input type="date" id="dueDateInput" name="dueDate" class="form-input-custom-date task-detail-date-input" value="<c:out value='${task.dueDate}'/>">
          </div>

          <!-- 右側：クリアボタン -->
          <button type="button" class="task-detail-clear-btn" onclick="clearDueDate(event)">
            ✕ クリア
          </button>

        </div>
      </div>

      <!-- 進捗ステータス -->
      <div class="form-group" style="margin: 0;">
        <label class="form-label task-detail-label">進捗ステータス <span style="color: #ef4444;">*</span></label>
        <select name="status" class="form-select task-detail-select-status" required>
          <option value="TODO" ${task.status == 'TODO' ? 'selected' : ''}>🟣 TODO (未着手)</option>
          <option value="IN_PROGRESS" ${task.status == 'IN_PROGRESS' ? 'selected' : ''}>🟠 IN_PROGRESS (進行中)</option>
          <option value="COMPLETED" ${task.status == 'COMPLETED' ? 'selected' : ''}>🟢 COMPLETED (完了)</option>
        </select>
      </div>

    </div>

    <!-- フッターエリア (左側：ナビゲーションボタン群 / 右側：アクションボタン群) -->
    <div class="task-detail-footer">
      
      <!-- 左下：会議議事録画面・ダッシュボードへの移動ナビゲーション -->
      <div class="task-detail-nav-group">
        <c:choose>
          <c:when test="${not empty task.meetingId}">
            <button type="button" 
                    class="btn-secondary task-detail-btn-meeting" 
                    onclick="goToMeetingDetail('${task.meetingId}')">
              📝 対象会議の議事録へ移動
            </button>
          </c:when>
          <c:otherwise>
            <span class="task-detail-unlinked-badge">
              📌 会議未紐付けタスク
            </span>
          </c:otherwise>
        </c:choose>

        <button type="button" 
                class="btn-secondary task-detail-btn-dashboard" 
                onclick="goToDashboard()">
          🏠 ダッシュボード
        </button>
      </div>

      <!-- 右下：アクションボタン -->
      <div class="task-detail-action-group">
        <button type="button" class="btn-secondary" onclick="history.back()">キャンセル</button>
        <button type="submit" class="btn-primary task-detail-btn-update">💾 変更を更新する</button>
      </div>

    </div>
  </form>
</div>

<script>
  // 画面初期表示時に、DBから入ってきた assigneeEmail の値とチェックボックスを同期
  document.addEventListener('DOMContentLoaded', function() {
    const initialEmailsStr = document.getElementById('assigneeEmailInput').value;
    if (initialEmailsStr) {
      const initialEmails = initialEmailsStr.split(',').map(e => e.trim());
      document.querySelectorAll('.assignee-checkbox').forEach(cb => {
        if (initialEmails.includes(cb.value)) {
          cb.checked = true;
        }
      });
    }
  });

  // クリアボタンの処理（カレンダーの起動イベント伝播を防止）
  function clearDueDate(event) {
    if (event) {
      event.stopPropagation();
      event.preventDefault();
    }
    document.getElementById('dueDateInput').value = '';
  }

  // チェックボックス操作時にテキスト入力欄へ同期
  function syncAssignees() {
    const checkedBoxes = document.querySelectorAll('.assignee-checkbox:checked');
    const emails = Array.from(checkedBoxes).map(cb => cb.value);
    document.getElementById('assigneeEmailInput').value = emails.join(', ');
  }

  // リアルタイム絞り込み検索
  function filterAssigneeList() {
    const query = document.getElementById('assigneeSearchInput').value.toLowerCase().trim();
    const items = document.querySelectorAll('.assignee-item-label');

    items.forEach(item => {
      const searchText = item.getAttribute('data-search-text').toLowerCase();
      if (searchText.includes(query)) {
        item.style.display = 'flex';
      } else {
        item.style.display = 'none';
      }
    });
  }

  // フロント側バリデーション
  function validateTaskForm(event) {
    const content = document.getElementById('taskContent').value.trim();
    if (!content) {
      alert('⚠️ タスク内容を入力してください。');
      return false;
    }
    return true;
  }

  // 対象会議の議事録へ移動する高度なナビゲーション処理
  function goToMeetingDetail(meetingId) {
    if (!meetingId) {
      alert("対象の会議IDが取得できませんでした。");
      return;
    }

    const meetingUrl = '${pageContext.request.contextPath}/meetings/detail?id=' + meetingId;

    if (window.opener && !window.opener.closed) {
      try {
        window.opener.location.href = meetingUrl;
        window.opener.focus();
        window.close();
      } catch (e) {
        window.location.href = meetingUrl;
      }
    } else {
      window.location.href = meetingUrl;
    }
  }

  // ダッシュボードへ戻る処理（親タブへ戻って自タブを閉じる）
  function goToDashboard() {
    const dashboardUrl = '${pageContext.request.contextPath}/dashboard';

    if (window.opener && !window.opener.closed) {
      try {
        window.opener.location.href = dashboardUrl;
        window.opener.focus();
        window.close();
      } catch (e) {
        window.location.href = dashboardUrl;
      }
    } else {
      window.location.href = dashboardUrl;
    }
  }
</script>

</body>
</html>