<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>📌 タスクステータス・詳細変更</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2">
  <style>
    /* 標準の右側カレンダーアイコンを透過させて左側に重ねる設定 */
    .form-input-custom-date::-webkit-calendar-picker-indicator {
        position: absolute;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        opacity: 0;
        cursor: pointer;
    }
  </style>
</head>
<body style="background-color: #f8fafc; padding: 24px;">

<div style="max-width: 900px; margin: 0 auto; background: #ffffff; padding: 24px; border-radius: 12px; border: 1px solid #e2e8f0; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);">
  
  <!-- ヘッダー -->
  <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; margin-bottom: 20px;">
    <h2 style="font-size: 13pt; margin: 0; color: #0f172a;">📌 タスクステータス・詳細変更</h2>
    <span style="font-size: 8.5pt; color: #64748b; background: #f1f5f9; padding: 2px 8px; border-radius: 4px;">タスクID: <c:out value="${task.taskId}"/></span>
  </div>

  <form action="${pageContext.request.contextPath}/tasks/update" method="POST" onsubmit="return validateTaskForm(event)">
    <input type="hidden" name="taskId" value="${task.taskId}">

    <!-- タスク内容 -->
    <div class="form-group" style="margin-bottom: 16px;">
      <label class="form-label" style="font-size: 8.5pt; font-weight: bold; margin-bottom: 6px; display: block;">
        タスク内容 <span style="color: #ef4444;">*</span>
      </label>
      <input type="text" id="taskContent" name="taskContent" class="form-input" value="<c:out value='${task.taskContent}'/>" style="padding: 8px 12px; font-size: 9pt;" required>
    </div>

    <!-- 担当者選択エリア（チェックリスト ＋ 検索 ＋ 未完了数バッジ付き） -->
    <div class="form-group" style="background-color: #f8fafc; padding: 14px; border-radius: 6px; border: 1px solid #e2e8f0; margin-bottom: 16px;">
      <label class="form-label" style="margin-bottom: 6px; font-weight: bold; font-size: 8.5pt;">
        👤 担当者選択
      </label>
      
      <!-- リアルタイム絞り込み検索窓 -->
      <div style="margin-bottom: 8px;">
        <input type="text" id="assigneeSearchInput" class="form-input" placeholder="🔍 名前・メールで絞り込み..." oninput="filterAssigneeList()" style="padding: 6px 10px; font-size: 8.5pt; width: 100%; box-sizing: border-box; background-color: #ffffff;">
      </div>

      <!-- ★ メンバーチェックリスト（max-height を 260px に拡大） -->
      <div id="assigneeListContainer" style="max-height: 260px; overflow-y: auto; background: #ffffff; border: 1px solid #cbd5e1; border-radius: 4px; padding: 8px; display: flex; flex-direction: column; gap: 6px; margin-bottom: 10px;">
        <c:choose>
          <c:when test="${empty users}">
            <div style="font-size: 8pt; color: #64748b; padding: 8px; text-align: center;">登録メンバーがいません</div>
          </c:when>
          <c:otherwise>
            <c:forEach var="u" items="${users}">
              <label class="assignee-item-label" data-search-text="<c:out value='${u.name}'/> <c:out value='${u.email}'/>" style="font-size: 8.5pt; cursor: pointer; display: flex; align-items: center; justify-content: space-between; padding: 6px 8px; border-radius: 4px; transition: background-color 0.2s;" onmouseover="this.style.backgroundColor='#f1f5f9'" onmouseout="this.style.backgroundColor='transparent'">
                
                <!-- 左側：チェックボックス ＋ 名前 ＋ メール -->
                <span style="display: flex; align-items: center; gap: 8px;">
                  <input type="checkbox" class="assignee-checkbox" value="<c:out value='${u.email}'/>" onchange="syncAssignees()"> 
                  <span><b><c:out value="${u.name}"/></b> <span style="color: #64748b; font-size: 8pt;">(<c:out value="${u.email}"/>)</span></span>
                </span>

                <!-- 右側：未完了タスク件数バッジ -->
                <c:choose>
                  <c:when test="${u.pendingTaskCount > 0}">
                    <span style="font-size: 7.5pt; background-color: #fef2f2; color: #dc2626; border: 1px solid #fecaca; padding: 2px 8px; border-radius: 12px; font-weight: bold;">
                      ⚠️ 未完了タスク: <c:out value="${u.pendingTaskCount}"/>件
                    </span>
                  </c:when>
                  <c:otherwise>
                    <span style="font-size: 7.5pt; background-color: #f0fdf4; color: #166534; border: 1px solid #bbf7d0; padding: 2px 8px; border-radius: 12px; font-weight: bold;">
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
      <label class="form-label" style="font-size: 7.5pt; color: #475569; margin-bottom: 4px; display: block;">
        担当者メールアドレス (複数指定する場合はカンマ「,」区切り):
      </label>
      <input type="text" id="assigneeEmailInput" name="assigneeEmail" class="form-input" value="<c:out value='${task.assigneeEmail}'/>" style="font-size: 8.5pt; background-color: #ffffff; padding: 6px 10px;" placeholder="選択した担当者が自動入力されます">
    </div>

    <!-- 履行期限 & 進捗ステータス 2カラム並び -->
    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px;">
      
      <!-- 履行期限 -->
      <div class="form-group" style="margin: 0;">
        <label class="form-label" style="font-size: 8.5pt; font-weight: bold; margin-bottom: 6px; display: block;">履行期限</label>
        
        <div style="display: flex; align-items: center; justify-content: space-between; background-color: #ffffff; border: 1px solid #cbd5e1; border-radius: 8px; padding: 0 10px; height: 38px; box-sizing: border-box;">
          
          <!-- 左側：カレンダー起動エリア -->
          <div style="position: relative; display: flex; align-items: center; flex: 1; height: 100%;">
            <span style="font-size: 11pt; margin-right: 8px; user-select: none;">📅</span>
            <input type="date" id="dueDateInput" name="dueDate" class="form-input-custom-date" value="<c:out value='${task.dueDate}'/>" style="border: none; outline: none; background: transparent; padding: 0; font-size: 8.5pt; width: 100%; color: #0f172a; cursor: pointer;">
          </div>

          <!-- 右側：クリアボタン -->
          <button type="button" onclick="clearDueDate(event)" style="background: none; border: none; color: #94a3b8; font-size: 8pt; cursor: pointer; padding: 2px 6px; border-radius: 4px; white-space: nowrap; font-weight: bold; z-index: 10;" onmouseover="this.style.color='#ef4444'" onmouseout="this.style.color='#94a3b8'">
            ✕ クリア
          </button>

        </div>
      </div>

      <!-- 進捗ステータス -->
      <div class="form-group" style="margin: 0;">
        <label class="form-label" style="font-size: 8.5pt; font-weight: bold; margin-bottom: 6px; display: block;">進捗ステータス <span style="color: #ef4444;">*</span></label>
        <select name="status" class="form-select" style="padding: 6px 10px; font-size: 8.5pt;" required>
          <option value="TODO" ${task.status == 'TODO' ? 'selected' : ''}>🟣 TODO (未着手)</option>
          <option value="IN_PROGRESS" ${task.status == 'IN_PROGRESS' ? 'selected' : ''}>🟠 IN_PROGRESS (進行中)</option>
          <option value="COMPLETED" ${task.status == 'COMPLETED' ? 'selected' : ''}>🟢 COMPLETED (完了)</option>
        </select>
      </div>

    </div>

    <!-- フッターエリア (左側：ナビゲーションボタン群 / 右側：アクションボタン群) -->
    <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid #e2e8f0; padding-top: 16px;">
      
      <!-- 左下：会議議事録画面・ダッシュボードへの移動ナビゲーション -->
      <div style="display: flex; gap: 8px; align-items: center;">
        <c:choose>
          <c:when test="${not empty task.meetingId}">
            <a href="${pageContext.request.contextPath}/meetings/detail?id=${task.meetingId}" 
               class="btn-secondary" style="font-size: 8.5pt; padding: 0 12px; height: 36px; text-decoration: none; color: #0284c7; background-color: #f0f9ff; border: 1px solid #bae6fd; font-weight: bold;">
              📝 対象会議の議事録へ移動
            </a>
          </c:when>
          <c:otherwise>
            <span style="font-size: 8pt; color: #94a3b8; background-color: #f1f5f9; padding: 6px 10px; border-radius: 6px; border: 1px solid #e2e8f0;">
              📌 会議未紐付けタスク
            </span>
          </c:otherwise>
        </c:choose>

        <a href="${pageContext.request.contextPath}/dashboard" 
           class="btn-secondary" style="font-size: 8.5pt; padding: 0 12px; height: 36px; text-decoration: none; color: #475569; background-color: #f1f5f9; border: 1px solid #cbd5e1;">
          🏠 ダッシュボード
        </a>
      </div>

      <!-- 右下：アクションボタン -->
      <div style="display: flex; gap: 10px;">
        <button type="button" class="btn-secondary" onclick="history.back()">キャンセル</button>
        <button type="submit" class="btn-primary" style="background-color: #0284c7; font-size: 9pt;">💾 変更を更新する</button>
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
</script>

</body>
</html>