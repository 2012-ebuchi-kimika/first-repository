<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div id="groupManagementModal" class="modal-overlay">
  <div class="modal-content group-modal-content">
    
    <div class="modal-header group-modal-header">
      <span class="group-modal-title">⚙️ 招待グループの管理</span>
      <button type="button" id="btn-close-group-modal" class="modal-close-btn" onclick="closeGroupModal()">&times;</button>
    </div>
    
    <form id="groupForm" onsubmit="return handleAddGroup(event)" novalidate class="group-form">
      <input type="hidden" id="editingGroupId" name="groupId" value="">

      <div class="group-grid-3col">
        
        <div class="group-col-box">
          <label class="form-label group-col-title">
            📋 登録済みグループ一覧
          </label>
          
          <div id="registeredGroupList" class="group-registered-list">
            <c:choose>
              <c:when test="${empty groups}">
                <div id="noGroupMsg" class="group-empty-msg">登録されたグループはありません</div>
              </c:when>
              <c:otherwise>
                <c:forEach var="g" items="${groups}">
                  <c:if test="${not empty g.groupName}">
                    <div class="group-card-item" id="group-card-${g.groupId}">
                      <div class="group-card-header">
                        <b class="group-name-text group-card-title">・<c:out value="${g.groupName}"/></b>
                        <div class="group-action-btns">
                          <!-- data-* 属性で安全に保持 -->
                          <button type="button" 
                                  class="group-btn-edit" 
                                  data-group-id="${g.groupId}" 
                                  data-group-name="<c:out value='${g.groupName}'/>" 
                                  data-group-members="<c:out value='${g.members}'/>" 
                                  onclick="handleEditGroupClick(this)">[編集]</button>
                          
                          <button type="button" 
                                  class="group-btn-delete" 
                                  data-group-id="${g.groupId}" 
                                  data-group-name="<c:out value='${g.groupName}'/>" 
                                  onclick="handleDeleteGroupClick(this)">[削除]</button>
                        </div>
                      </div>
                      <div class="group-members-text">
                        <c:out value="${g.members}"/>
                      </div>
                    </div>
                  </c:if>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </div>
        </div>

        <div class="group-col-center">
          <div>
            <div class="group-center-header">
              <div class="group-center-header-flex">
                <div style="display: flex; align-items: center; gap: 8px;">
                  <span id="formModeTitle" class="group-mode-title">➕ 新規グループ作成</span>
                  <span id="targetGroupBadge" class="group-target-badge"></span>
                </div>
              </div>
              <div id="resetModeArea" style="display: none; margin-top: 8px;">
                <button type="button" id="btn-reset-group-mode" class="group-reset-btn" onclick="resetGroupForm()">
                  ↩️ 新規作成モードに戻る
                </button>
              </div>
            </div>

            <div class="form-group" style="margin-bottom: 16px;">
              <label class="form-label" style="font-size: 9.5pt; font-weight: bold; margin-bottom: 6px; display: block;">グループ名 <span style="color: #ef4444;">*</span></label>
              <input type="text" id="newGroupName" name="groupName" class="form-input group-input-full" placeholder="例：インフラチーム">
            </div>
          </div>

          <div class="group-guide-box">
            💡 <b>使い方ガイド</b><br>
            ・左の [編集] ボタンを押すと既存グループのメンバー構成を修正できます。<br>
            ・右のカラムで追加したいメンバーにチェックを入れて保存してください。
          </div>
        </div>

        <div class="group-col-box">
          <label class="form-label group-col-title">
            👤 グループメンバー選択
          </label>
          
          <div style="margin-bottom: 12px;">
            <input type="text" id="groupMemberSearchInput" class="form-input group-member-search" placeholder="🔍 名前・メールで絞り込み..." oninput="filterGroupMemberList()">
          </div>

          <div id="groupMemberListContainer" class="group-member-checkbox-list">
            <c:choose>
              <c:when test="${empty users}">
                <div style="font-size: 9pt; color: #64748b; padding: 16px; text-align: center;">登録メンバーがいません</div>
              </c:when>
              <c:otherwise>
                <c:forEach var="u" items="${users}">
                  <label class="group-member-item-label" data-search-text="<c:out value='${u.name}'/> <c:out value='${u.email}'/>" onmouseover="this.style.backgroundColor='#f1f5f9'" onmouseout="this.style.backgroundColor='transparent'">
                    <span>
                      <input type="checkbox" class="group-member-checkbox" value="<c:out value='${u.email}'/>" onchange="syncGroupMembers()" style="transform: scale(1.1); margin-right: 6px;"> 
                      <c:out value="${u.name}"/> (<c:out value="${u.email}"/>)
                    </span>
                  </label>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </div>

          <label class="form-label" style="font-size: 8.5pt; color: #475569; margin-bottom: 6px; font-weight: bold;">登録予定メンバー一覧 (カンマ区切り): <span style="color: #ef4444;">*</span></label>
          <textarea id="newGroupMembers" name="members" class="form-input group-textarea-full" placeholder="選択したメンバーが自動入力されます"></textarea>
        </div>

      </div>
      
      <div class="modal-footer group-footer-flex">
        <button type="button" id="btn-close-group-modal-footer" class="btn-secondary group-btn-close" onclick="closeGroupModal()">閉じる</button>
        <button type="submit" id="submitGroupBtn" class="btn-primary group-btn-submit">
          グループを追加保存
        </button>
      </div>
    </form>
  </div>
</div>

<script>
  function openGroupModal() {
    const modal = document.getElementById('groupManagementModal');
    if (modal) modal.style.display = 'flex';
  }

  function closeGroupModal() {
    const modal = document.getElementById('groupManagementModal');
    if (modal) modal.style.display = 'none';
  }

  function validateGroupForm(groupName, members) {
    if (!groupName) {
      alert('⚠️ グループ名を入力してください。');
      document.getElementById('newGroupName').focus();
      return false;
    }

    if (groupName.length > 50) {
      alert('⚠️ グループ名は50文字以内で入力してください。（現在: ' + groupName.length + '文字）');
      document.getElementById('newGroupName').focus();
      return false;
    }

    if (!members) {
      alert('⚠️ グループメンバーを最低1名選択（または入力）してください。');
      document.getElementById('newGroupMembers').focus();
      return false;
    }

    return true;
  }

  function handleAddGroup(event) {
    event.preventDefault();

    const editingId = document.getElementById('editingGroupId').value;
    const groupName = document.getElementById('newGroupName').value.trim();
    const members = document.getElementById('newGroupMembers').value.trim();

    if (!validateGroupForm(groupName, members)) {
      return false;
    }

    const payload = {
      groupId: editingId ? parseInt(editingId) : null,
      groupName: groupName,
      members: members
    };

    fetch('${pageContext.request.contextPath}/api/groups/save', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    })
    .then(res => {
      if (!res.ok) {
        throw new Error('サーバーエラーが発生しました');
      }
      return res.json();
    })
    .then(savedGroup => {
      const noMsg = document.getElementById('noGroupMsg');
      if (noMsg) noMsg.style.display = 'none';

      const container = document.getElementById('registeredGroupList');

      if (editingId) {
        const existingCard = document.getElementById('group-card-' + editingId);
        if (existingCard) {
          existingCard.querySelector('.group-name-text').innerText = '・' + savedGroup.groupName;
          existingCard.querySelector('.group-members-text').innerText = savedGroup.members;
          
          const editBtn = existingCard.querySelector('.group-btn-edit');
          if (editBtn) {
            editBtn.setAttribute('data-group-name', savedGroup.groupName);
            editBtn.setAttribute('data-group-members', savedGroup.members);
          }
        }
      } else {
        const newHtml = 
          '<div class="group-card-item" id="group-card-' + savedGroup.groupId + '">' +
            '<div class="group-card-header">' +
              '<b class="group-name-text group-card-title">・' + escapeHtml(savedGroup.groupName) + '</b>' +
              '<div class="group-action-btns">' +
                '<button type="button" class="group-btn-edit" data-group-id="' + savedGroup.groupId + '" data-group-name="' + escapeHtml(savedGroup.groupName) + '" data-group-members="' + escapeHtml(savedGroup.members) + '" onclick="handleEditGroupClick(this)">[編集]</button>' +
                '<button type="button" class="group-btn-delete" data-group-id="' + savedGroup.groupId + '" data-group-name="' + escapeHtml(savedGroup.groupName) + '" onclick="handleDeleteGroupClick(this)">[削除]</button>' +
              '</div>' +
            '</div>' +
            '<div class="group-members-text">' +
              escapeHtml(savedGroup.members) +
            '</div>' +
          '</div>';
        container.insertAdjacentHTML('afterbegin', newHtml);
      }

      resetGroupForm();
    })
    .catch(err => {
      console.error(err);
      alert('保存処理に失敗しました。');
    });
    return false;
  }

  // data-* 属性から値を安全に取得して編集処理へ
  function handleEditGroupClick(btn) {
    const id = btn.getAttribute('data-group-id');
    const name = btn.getAttribute('data-group-name');
    const members = btn.getAttribute('data-group-members');
    editGroup(id, name, members);
  }

  // data-* 属性から値を安全に取得して削除処理へ
  function handleDeleteGroupClick(btn) {
    const id = btn.getAttribute('data-group-id');
    const name = btn.getAttribute('data-group-name');
    deleteGroup(id, name);
  }

  function deleteGroup(groupId, groupName) {
    if (!confirm('グループ「' + groupName + '」を削除してもよろしいですか？')) return;
    fetch('${pageContext.request.contextPath}/api/groups/' + groupId, {
      method: 'DELETE'
    })
    .then(res => {
      if (res.ok) {
        const card = document.getElementById('group-card-' + groupId);
        if (card) card.remove();
      } else {
        alert('削除処理に失敗しました。');
      }
    })
    .catch(err => console.error(err));
  }

  function editGroup(id, name, membersStr) {
    document.getElementById('editingGroupId').value = id;
    document.getElementById('newGroupName').value = name;
    
    document.getElementById('formModeTitle').innerText = '✏️ グループ編集';
    const badge = document.getElementById('targetGroupBadge');
    badge.innerText = name;
    badge.style.display = 'inline-block';
    
    document.getElementById('resetModeArea').style.display = 'block';
    document.getElementById('submitGroupBtn').innerText = '変更を更新保存';
    const membersArray = membersStr ? membersStr.split(',').map(m => m.trim()) : [];
    document.querySelectorAll('.group-member-checkbox').forEach(cb => {
      cb.checked = membersArray.includes(cb.value);
    });

    syncGroupMembers();
  }

  function resetGroupForm() {
    document.getElementById('editingGroupId').value = '';
    document.getElementById('newGroupName').value = '';
    
    document.getElementById('formModeTitle').innerText = '➕ 新規グループ作成';
    document.getElementById('targetGroupBadge').style.display = 'none';
    document.getElementById('resetModeArea').style.display = 'none';
    document.getElementById('submitGroupBtn').innerText = 'グループを追加保存';

    document.querySelectorAll('.group-member-checkbox').forEach(cb => {
      cb.checked = false;
    });
    syncGroupMembers();
  }

  function syncGroupMembers() {
    const checkedBoxes = document.querySelectorAll('.group-member-checkbox:checked');
    const emails = Array.from(checkedBoxes).map(cb => cb.value);
    document.getElementById('newGroupMembers').value = emails.join(', ');
  }

  function filterGroupMemberList() {
    const query = document.getElementById('groupMemberSearchInput').value.toLowerCase().trim();
    const items = document.querySelectorAll('.group-member-item-label');
    items.forEach(item => {
      const searchText = item.getAttribute('data-search-text').toLowerCase();
      if (searchText.includes(query)) {
        item.style.display = 'flex';
      } else {
        item.style.display = 'none';
      }
    });
  }

  // ★ 修正箇所: JSPエラーを防ぐため正規表現スラッシュ(/)を補正して構文エラーを完全解消
  function escapeHtml(str) {
    if (!str) return '';
    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#039;');
  }
</script>