<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div id="createMeetingModal" class="modal-overlay">
  <div class="modal-content modal-content-large">
    
    <div class="modal-header modal-header-large">
      <span class="modal-title-text" id="modalTitleText">📅 新規会議を作成</span>
      <button type="button" id="btn-close-meeting-modal" class="modal-close-btn" onclick="closeModal()">&times;</button>
    </div>
    
    <form action="${pageContext.request.contextPath}/meetings/create" id="meetingForm" method="POST" class="modal-body-form">
      
      <div class="modal-body-grid">
        
        <div class="modal-column">
          
          <div class="form-group modal-form-block">
            <label class="form-label modal-label-bold">
              会議タイトル <span style="color: #ef4444;">*</span>
            </label>
            <input type="text" name="title" id="meetingTitleInput" class="form-input modal-input-full" placeholder="例：週次進捗確認ミーティング" required data-testid="meeting-title-input">
          </div>
          
          <div class="form-group modal-form-block">
            <label class="form-label modal-label-bold">
              開催日時 <span style="color: #ef4444;">*</span>
            </label>
            <input type="datetime-local" name="startTime" id="meetingStartTimeInput" class="form-input modal-input-full" required data-testid="meeting-datetime-input" style="font-family: inherit;">
          </div>

          <div class="form-group modal-form-block-flex">
            <label class="form-label modal-label-bold">
              招待グループ <span style="font-size: 8pt; color: #64748b; font-weight: normal;">(任意)</span>
            </label>
            <select name="groupId" id="groupSelect" class="form-select modal-input-full" data-testid="group-select-checkbox" onchange="updateGroupMembers()">
              <option value="" data-members="">グループを選択しない（個人で招待）</option>
              <c:forEach var="g" items="${groups}">
                <c:if test="${not empty g.groupName}">
                  <option value="${g.groupId}" data-members="<c:out value='${g.members}'/>">
                    <c:out value="${g.groupName}"/>
                  </option>
                </c:if>
              </c:forEach>
            </select>
            
            <div id="memberListDisplay" class="modal-members-display" style="display: none;">
              👥 <b>グループメンバー:</b> <span id="memberNames"></span>
            </div>
          </div>

        </div>

        <div class="modal-column-flex">
          
          <div class="form-group modal-form-block-flex">
            <label class="form-label" style="margin-bottom: 8px; font-weight: bold; font-size: 9.5pt; color: #334155;">
              👤 個別参加メンバー追加
            </label>
            
            <div style="margin-bottom: 10px;">
              <input type="text" id="memberSearchInput" class="form-input modal-search-input" placeholder="🔍 名前・メールで絞り込み..." oninput="filterMemberList()">
            </div>

            <div id="memberListContainer" class="modal-checkbox-list">
              <c:choose>
                <c:when test="${empty users}">
                  <div style="font-size: 8.5pt; color: #64748b; padding: 12px; text-align: center;">登録メンバーがいません</div>
                </c:when>
                <c:otherwise>
                  <c:forEach var="u" items="${users}">
                    <label class="member-item-label" data-search-text="<c:out value='${u.name}'/> <c:out value='${u.email}'/>" onmouseover="this.style.backgroundColor='#f1f5f9'" onmouseout="this.style.backgroundColor='transparent'">
                      <span>
                        <input type="checkbox" class="member-checkbox" value="<c:out value='${u.email}'/>" onchange="syncSelectedMembers()" style="margin-right: 6px;"> 
                        <c:out value="${u.name}"/> (<c:out value="${u.email}"/>)
                      </span>
                      <span class="group-badge" id="badge-<c:out value='${u.email}'/>" style="font-size: 7.5pt; color: #ef4444; font-weight: bold; display: none;">（グループ参加済み）</span>
                    </label>
                  </c:forEach>
                </c:otherwise>
              </c:choose>
            </div>

            <label class="form-label" style="font-size: 8pt; color: #475569; margin-bottom: 4px; font-weight: bold;">参加予定全メンバー一覧 (カンマ区切り):</label>
            <textarea name="attendeeEmails" id="invitedMembersTextarea" class="form-input modal-textarea-full" placeholder="グループメンバーおよび選択した個人が自動入力されます"></textarea>
          </div>

          <div class="form-group modal-form-block">
            <button type="button" id="btn-generate-meet-url" class="btn-secondary modal-btn-meet" data-testid="meet-create-btn" onclick="generateMeetUrl()">
              Google Meet URL を自動発行して送信
            </button>
            <div style="font-size: 8.5pt; color: #475569;">
              発行結果 Meet URL: 
              <a href="#" id="meetUrlDisplay" target="_blank" style="color: #0284c7; font-weight: bold; text-decoration: underline;">未発行</a>
              <input type="hidden" name="meetUrl" id="meetUrlInput" value="">
            </div>
          </div>

        </div>

      </div>
      
      <div class="modal-footer modal-footer-flex">
        <button type="button" id="btn-cancel-meeting" class="btn-secondary modal-btn-cancel" onclick="closeModal()">キャンセル</button>
        <button type="submit" id="btn-save-meeting" name="actionType" value="saveOnly" class="btn-secondary modal-btn-save">保存</button>
        <button type="submit" id="btn-save-go-detail" name="actionType" value="goToDetail" class="btn-primary modal-btn-primary-action">保存して要約作成へ</button>
      </div>
    </form>
  </div>
</div>

<script>
  function resetMeetingModal() {
    const modal = document.getElementById('createMeetingModal');
    if (!modal) return;

    const form = document.getElementById('meetingForm');
    if (form) {
      form.reset();
      form.action = '${pageContext.request.contextPath}/meetings/create';
    }

    const titleText = document.getElementById('modalTitleText');
    if (titleText) titleText.innerText = '📅 新規会議を作成';

    const hiddenId = document.getElementById('modalMeetingId');
    if (hiddenId) hiddenId.remove();

    const groupSel = document.getElementById('groupSelect');
    if (groupSel) groupSel.value = '';

    const displayArea = document.getElementById('memberListDisplay');
    if (displayArea) displayArea.style.display = 'none';

    const namesElem = document.getElementById('memberNames');
    if (namesElem) namesElem.innerText = '';

    document.querySelectorAll('.member-checkbox').forEach(cb => {
      cb.checked = false;
      cb.disabled = false;
    });
    document.querySelectorAll('.group-badge').forEach(badge => {
      badge.style.display = 'none';
    });

    const textarea = document.getElementById('invitedMembersTextarea');
    if (textarea) textarea.value = '';

    const meetDisplay = document.getElementById('meetUrlDisplay');
    if (meetDisplay) {
      meetDisplay.href = '#';
      meetDisplay.innerText = '未発行';
    }
    const meetInput = document.getElementById('meetUrlInput');
    if (meetInput) meetInput.value = '';
  }

  function openModal() {
    resetMeetingModal();
    const modal = document.getElementById('createMeetingModal');
    if (modal) modal.style.display = 'flex';
  }

  function closeModal() {
    const modal = document.getElementById('createMeetingModal');
    if (modal) modal.style.display = 'none';
  }

  function updateGroupMembers() {
    const selectElem = document.getElementById('groupSelect');
    if (!selectElem) return;
    
    const selectedOption = selectElem.options[selectElem.selectedIndex];
    const displayArea = document.getElementById('memberListDisplay');
    const namesElem = document.getElementById('memberNames');
    
    const membersAttr = (selectedOption && selectedOption.value) ? selectedOption.getAttribute('data-members') : '';
    const groupEmails = membersAttr 
      ? membersAttr.split(',').map(e => e.trim().toLowerCase()).filter(e => e !== '') 
      : [];

    if (groupEmails.length > 0 && displayArea && namesElem) {
      namesElem.innerText = groupEmails.join(', ');
      displayArea.style.display = 'block';
    } else if (displayArea) {
      displayArea.style.display = 'none';
      if (namesElem) namesElem.innerText = '';
    }

    document.querySelectorAll('.member-checkbox').forEach(cb => {
      const email = cb.value.trim().toLowerCase();
      const badge = document.getElementById('badge-' + cb.value);

      if (groupEmails.length > 0 && groupEmails.includes(email)) {
        cb.checked = true;
        cb.disabled = true;
        if (badge) badge.style.display = 'inline';
      } else {
        cb.disabled = false;
        cb.checked = false;
        if (badge) badge.style.display = 'none';
      }
    });
    syncSelectedMembers();
  }

  function syncSelectedMembers() {
    const selectElem = document.getElementById('groupSelect');
    const selectedOption = (selectElem && selectElem.value) ? selectElem.options[selectElem.selectedIndex] : null;
    const membersAttr = selectedOption ? selectedOption.getAttribute('data-members') : '';
    const groupEmails = membersAttr ? membersAttr.split(',').map(e => e.trim()).filter(e => e !== '') : [];

    const checkedBoxes = document.querySelectorAll('.member-checkbox:checked:not(:disabled)');
    const individualEmails = Array.from(checkedBoxes).map(cb => cb.value.trim());
    const allEmails = Array.from(new Set([...groupEmails, ...individualEmails]));
    const textarea = document.getElementById('invitedMembersTextarea');
    if (textarea) textarea.value = allEmails.join(', ');
  }

  function filterMemberList() {
    const input = document.getElementById('memberSearchInput');
    if (!input) return;
    const query = input.value.toLowerCase().trim();
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