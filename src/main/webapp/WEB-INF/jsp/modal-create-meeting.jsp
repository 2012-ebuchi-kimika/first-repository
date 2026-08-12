<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- ① 新規会議作成モーダル (SCR-02) -->
<div id="createMeetingModal" class="modal-overlay">
  <div class="modal-content" style="max-width: 860px; width: 90%; padding: 20px 24px;">
    <div class="modal-header" style="margin-bottom: 16px;">
      <span style="font-size: 13pt; font-weight: bold;">📅 新規会議を作成</span>
      <button type="button" class="modal-close-btn" onclick="closeModal()">&times;</button>
    </div>
    
    <form action="${pageContext.request.contextPath}/meetings/create" method="POST">
      
      <!-- 左右2カラムグリッド -->
      <div style="display: grid; grid-template-columns: 1fr 1.1fr; gap: 16px; align-items: start;">
        
        <!-- 左カラム：基本情報 -->
        <div style="display: flex; flex-direction: column; gap: 8px;">
          
          <!-- 1. 会議タイトルブロック -->
          <div class="form-group" style="background-color: #f8fafc; padding: 10px 12px; border-radius: 6px; border: 1px solid #e2e8f0; margin: 0;">
            <label class="form-label" style="font-size: 8.5pt; font-weight: bold; margin-bottom: 4px; display: block;">
              会議タイトル <span style="color: #ef4444;">*</span>
            </label>
            <input type="text" name="title" class="form-input" placeholder="例：週次進捗確認ミーティング" required data-testid="meeting-title-input" style="padding: 6px 10px; background-color: #ffffff;">
          </div>
          
          <!-- 2. 開催日時ブロック -->
          <div class="form-group" style="background-color: #f8fafc; padding: 10px 12px; border-radius: 6px; border: 1px solid #e2e8f0; margin: 0;">
            <label class="form-label" style="font-size: 8.5pt; font-weight: bold; margin-bottom: 4px; display: block;">
              開催日時 <span style="color: #ef4444;">*</span>
            </label>
            <input type="datetime-local" name="startTime" class="form-input" required data-testid="meeting-datetime-input" style="padding: 6px 10px; background-color: #ffffff;">
          </div>

          <!-- 3. 招待グループ選択ブロック（★DB動的連携へ修正） -->
          <div class="form-group" style="background-color: #f8fafc; padding: 10px 12px; border-radius: 6px; border: 1px solid #e2e8f0; margin: 0;">
            <label class="form-label" style="font-size: 8.5pt; font-weight: bold; margin-bottom: 4px; display: block;">
              招待グループ <span style="font-size: 7.5pt; color: #64748b; font-weight: normal;">(任意)</span>
            </label>
            <select name="groupId" id="groupSelect" class="form-select" data-testid="group-select-checkbox" onchange="updateGroupMembers()" style="padding: 6px 10px; background-color: #ffffff;">
              <option value="" data-members="">グループを選択しない（個人で招待）</option>
              <c:forEach var="g" items="${groups}">
                <c:if test="${not empty g.groupName}">
                  <option value="${g.groupId}" data-members="<c:out value='${g.members}'/>">
                    <c:out value="${g.groupName}"/>
                  </option>
                </c:if>
              </c:forEach>
            </select>
            
            <!-- 👥 選択グループのメンバー一覧表示 -->
            <div id="memberListDisplay" style="margin-top: 6px; font-size: 7.5pt; color: #475569; display: none; background-color: #ffffff; padding: 6px 10px; border-radius: 4px; border: 1px solid #cbd5e1;">
              👥 <b>グループメンバー:</b> <span id="memberNames"></span>
            </div>
          </div>

        </div>

        <!-- 右カラム：個別参加メンバー選択 ＋ Google Meet URL自動発行 -->
        <div style="display: flex; flex-direction: column; gap: 8px;">
          
          <!-- 1. 個別参加メンバー追加ブロック -->
          <div class="form-group" style="background-color: #f8fafc; padding: 12px; border-radius: 6px; border: 1px solid #e2e8f0; margin: 0;">
            <label class="form-label" style="margin-bottom: 6px; font-weight: bold; font-size: 8.5pt;">
              👤 個別参加メンバー追加
            </label>
            
            <!-- リアルタイム検索窓 -->
            <div style="margin-bottom: 8px;">
              <input type="text" id="memberSearchInput" class="form-input" placeholder="🔍 名前・メールで絞り込み..." oninput="filterMemberList()" style="padding: 5px 8px; font-size: 8pt; width: 100%; box-sizing: border-box; background-color: #ffffff;">
            </div>

            <!-- DB(usersテーブル)データ動的表示エリア -->
            <div id="memberListContainer" style="max-height: 110px; overflow-y: auto; background: #ffffff; border: 1px solid #cbd5e1; border-radius: 4px; padding: 6px; display: flex; flex-direction: column; gap: 4px; margin-bottom: 8px;">
              <c:choose>
                <c:when test="${empty users}">
                  <div style="font-size: 8pt; color: #64748b; padding: 8px; text-align: center;">登録メンバーがいません</div>
                </c:when>
                <c:otherwise>
                  <c:forEach var="u" items="${users}">
                    <label class="member-item-label" data-search-text="<c:out value='${u.name}'/> <c:out value='${u.email}'/>" style="font-size: 8pt; cursor: pointer; display: flex; align-items: center; justify-content: space-between; padding: 3px 4px; border-radius: 3px;">
                      <span>
                        <input type="checkbox" class="member-checkbox" value="<c:out value='${u.email}'/>" onchange="syncSelectedMembers()"> 
                        <c:out value="${u.name}"/> (<c:out value="${u.email}"/>)
                      </span>
                      <span class="group-badge" id="badge-<c:out value='${u.email}'/>" style="font-size: 7pt; color: #ef4444; font-weight: bold; display: none;">（グループ参加済み）</span>
                    </label>
                  </c:forEach>
                </c:otherwise>
              </c:choose>
            </div>

            <!-- 登録予定メンバー一覧 -->
            <label class="form-label" style="font-size: 7.5pt; color: #475569; margin-bottom: 2px;">参加予定全メンバー一覧 (カンマ区切り):</label>
            <textarea name="invitedMembers" id="invitedMembersTextarea" class="form-input" style="height: 48px; font-size: 8pt; resize: vertical; background-color: #ffffff;" placeholder="グループメンバーおよび選択した個人が自動入力されます"></textarea>
          </div>

          <!-- 2. Google Meet URL 自動発行ブロック -->
          <div class="form-group" style="background-color: #f8fafc; padding: 10px; border-radius: 6px; border: 1px solid #e2e8f0; margin: 0;">
            <button type="button" class="btn-secondary" style="width: 100%; background-color: #0284c7; color: white; border: none; margin-bottom: 6px; padding: 7px 0; font-size: 8.5pt;" data-testid="meet-create-btn" onclick="generateMeetUrl()">
              Google Meet URL を自動発行して送信
            </button>
            <div style="font-size: 8pt; color: #475569;">
              発行結果 Meet URL: 
              <a href="#" id="meetUrlDisplay" target="_blank" style="color: #0284c7; font-weight: bold; text-decoration: underline;">未発行</a>
              <input type="hidden" name="meetUrl" id="meetUrlInput" value="">
            </div>
          </div>

        </div>

      </div>
      
      <!-- フッターボタンエリア -->
      <div class="modal-footer" style="margin-top: 16px; padding-top: 12px; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 8px;">
        <button type="button" class="btn-secondary" onclick="closeModal()">キャンセル</button>
        <button type="submit" name="actionType" value="saveOnly" class="btn-secondary" style="background-color: #e2e8f0; color: #0f172a;">保存</button>
        <button type="submit" name="actionType" value="goToDetail" class="btn-primary">保存して要約作成へ</button>
      </div>
    </form>
  </div>
</div>

<script>
  function openModal() {
    const modal = document.getElementById('createMeetingModal');
    if (modal) modal.style.display = 'flex';
  }

  function closeModal() {
    const modal = document.getElementById('createMeetingModal');
    if (modal) modal.style.display = 'none';
  }

  // ★選択されたグループの option から `data-members` を動的に読み取って制御
  function updateGroupMembers() {
    const selectElem = document.getElementById('groupSelect');
    const selectedOption = selectElem.options[selectElem.selectedIndex];
    const displayArea = document.getElementById('memberListDisplay');
    const namesElem = document.getElementById('memberNames');
    
    const membersAttr = selectedOption ? selectedOption.getAttribute('data-members') : '';
    const groupEmails = membersAttr ? membersAttr.split(',').map(e => e.trim()).filter(e => e !== '') : [];

    if (groupEmails.length > 0) {
      namesElem.innerText = groupEmails.join(', ');
      displayArea.style.display = 'block';
    } else {
      displayArea.style.display = 'none';
    }

    // 個別選択リストの連動（グループに含まれるメールはチェック＆固定表示）
    document.querySelectorAll('.member-checkbox').forEach(cb => {
      const email = cb.value;
      const badge = document.getElementById('badge-' + email);

      if (groupEmails.includes(email)) {
        cb.checked = true;
        cb.disabled = true;
        if (badge) badge.style.display = 'inline';
      } else {
        cb.disabled = false;
        if (badge) badge.style.display = 'none';
      }
    });

    syncSelectedMembers();
  }

  function syncSelectedMembers() {
    const selectElem = document.getElementById('groupSelect');
    const selectedOption = selectElem.options[selectElem.selectedIndex];
    const membersAttr = selectedOption ? selectedOption.getAttribute('data-members') : '';
    const groupEmails = membersAttr ? membersAttr.split(',').map(e => e.trim()).filter(e => e !== '') : [];

    const checkedBoxes = document.querySelectorAll('.member-checkbox:checked:not(:disabled)');
    const individualEmails = Array.from(checkedBoxes).map(cb => cb.value);

    const allEmails = Array.from(new Set([...groupEmails, ...individualEmails]));
    document.getElementById('invitedMembersTextarea').value = allEmails.join(', ');
  }

  function filterMemberList() {
    const query = document.getElementById('memberSearchInput').value.toLowerCase().trim();
    const items = document.querySelectorAll('.member-item-label');

    items.forEach(item => {
      const searchText = item.getAttribute('data-search-text').toLowerCase();
      if (searchText.includes(query)) {
        item.style.display = 'flex';
      } else {
        item.style.display = 'none';
      }
    });
  }

  function generateMeetUrl() {
    const randomStr = Math.random().toString(36).substring(2, 5) + '-' + 
                      Math.random().toString(36).substring(2, 6) + '-' + 
                      Math.random().toString(36).substring(2, 5);
    const generatedUrl = 'https://meet.google.com/' + randomStr;
    
    const displayElem = document.getElementById('meetUrlDisplay');
    const inputElem = document.getElementById('meetUrlInput');
    
    if (displayElem && inputElem) {
      displayElem.href = generatedUrl;
      displayElem.innerText = generatedUrl;
      inputElem.value = generatedUrl;
    }
  }
</script>