<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div id="groupManagementModal" class="modal-overlay" style="display: none;">
  <div class="modal-content group-modal-content">
    
    <div class="modal-header group-modal-header">
      <span class="group-modal-title" id="groupModalHeaderTitle">⚙️ 招待グループの参照・管理</span>
      <button type="button" id="btn-close-group-modal" class="modal-close-btn" onclick="closeGroupModal()">&times;</button>
    </div>
    
    <!-- 閲覧モード用の2カラムレイアウト表示エリア -->
    <div id="groupViewOnlyArea" style="display: none;">
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; min-height: 320px;">
        
        <!-- 左エリア：グループ一覧 ＆ 検索 -->
        <div class="group-col-box" style="display: flex; flex-direction: column; width: 100%; box-sizing: border-box;">
          <label class="form-label group-col-title" style="margin-bottom: 6px;">📋 登録済みグループ一覧</label>
          
          <div style="margin-bottom: 6px;">
            <input type="text" id="viewGroupSearchInput" class="form-input" 
                   placeholder="🔍 グループ名で検索..." oninput="filterViewGroupList()"
                   style="width: 100%; box-sizing: border-box; padding: 5px 8px; font-size: 8.5pt;">
          </div>

          <!-- ★ カード同士の上下間隔（縦幅）をキュッと詰めた領域 -->
          <div id="viewGroupListContainer" style="flex: 1; max-height: 280px; overflow-y: auto; padding-right: 2px; width: 100%; box-sizing: border-box;">
            <c:choose>
              <c:when test="${empty groups}">
                <div class="group-empty-msg">登録されたグループはありません</div>
              </c:when>
              <c:otherwise>
                <c:forEach var="g" items="${groups}">
                  <c:if test="${not empty g.groupName}">
                    <!-- ★ !important で縦余白とカードの厚みをコンパクトに強制適用 -->
                    <div class="group-card-item view-group-card" 
                         data-group-name="<c:out value='${g.groupName}'/>"
                         data-group-members="<c:out value='${g.members}'/>"
                         onclick="selectGroupForView(this)"
                         style="cursor: pointer; padding: 6px 10px !important; margin-bottom: 4px !important; min-height: unset !important; border: 1px solid #e2e8f0; border-left: 4px solid #0284c7; border-radius: 4px; background: #ffffff; box-shadow: 0 1px 2px rgba(0,0,0,0.02); transition: all 0.15s ease-in-out; width: 100%; box-sizing: border-box;">
                      <b style="font-size: 8.5pt; color: #0f172a; line-height: 1.2;"><c:out value="${g.groupName}"/></b>
                    </div>
                  </c:if>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </div>
        </div>

        <!-- 右エリア：選択グループの所属メンバー（日本語名 ＋ アドレス） -->
        <div class="group-col-box" style="display: flex; flex-direction: column; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 6px; padding: 10px; width: 100%; box-sizing: border-box;">
          <label class="form-label group-col-title" style="border-bottom: 2px solid #cbd5e1; padding-bottom: 4px; margin-bottom: 6px;">
            👥 所属メンバー詳細：<span id="selectedGroupNameTitle" style="color: #0284c7; font-weight: bold;">(左のグループを選択してください)</span>
          </label>

          <div id="selectedGroupMembersList" style="flex: 1; overflow-y: auto; display: flex; flex-direction: column; gap: 4px; max-height: 280px; padding-right: 2px; width: 100%; box-sizing: border-box;">
            <div style="color: #94a3b8; font-size: 8.5pt; text-align: center; padding-top: 30px;">
              👈 左エリアのグループをクリックすると<br>所属メンバーが表示されます
            </div>
          </div>
        </div>

      </div>
    </div>

    <!-- 編集モード用の3カラムレイアウトフォームエリア（管理者用：影響なし） -->
    <form id="groupForm" onsubmit="return handleAddGroup(event)" novalidate class="group-form">
      <input type="hidden" id="editingGroupId" name="groupId" value="">

      <div class="group-grid-3col" id="groupModalGrid">
        
        <div class="group-col-box" id="groupColList">
          <label class="form-label group-col-title">📋 登録済みグループ一覧</label>
          
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
          <label class="form-label group-col-title">👤 グループメンバー選択</label>
          
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
      
      <div class="modal-footer group-footer-flex" id="groupFormFooter">
        <button type="button" class="btn-secondary group-btn-close" onclick="closeGroupModal()">閉じる</button>
        <button type="submit" id="submitGroupBtn" class="btn-primary group-btn-submit">グループを追加保存</button>
      </div>
    </form>

    <!-- 閲覧モード用の閉じるフッター -->
    <div class="modal-footer" id="groupViewFooter" style="display: none; justify-content: flex-end;">
      <button type="button" class="btn-secondary" onclick="closeGroupModal()">閉じる</button>
    </div>

  </div>
</div>

<script>
  // システム全ユーザーのマッピング
  const systemUserMap = {};
  <c:forEach var="u" items="${users}">
    systemUserMap["<c:out value='${u.email}'/>".toLowerCase().trim()] = "<c:out value='${u.name}'/>";
  </c:forEach>

  function openGroupModal(canEdit) {
    const modal = document.getElementById('groupManagementModal');
    if (!modal) return;

    const isEditable = (canEdit === undefined) ? true : canEdit;
    
    const viewArea = document.getElementById('groupViewOnlyArea');
    const viewFooter = document.getElementById('groupViewFooter');
    const editForm = document.getElementById('groupForm');
    const titleElem = document.getElementById('groupModalHeaderTitle');

    if (isEditable) {
      if (viewArea) viewArea.style.display = 'none';
      if (viewFooter) viewFooter.style.display = 'none';
      if (editForm) editForm.style.display = 'block';
      if (titleElem) titleElem.innerText = '⚙️ 招待グループの編集・管理';
    } else {
      if (editForm) editForm.style.display = 'none';
      if (viewArea) viewArea.style.display = 'block';
      if (viewFooter) viewFooter.style.display = 'flex';
      if (titleElem) titleElem.innerText = '👥 招待グループ一覧（閲覧モード）';

      const firstCard = modal.querySelector('.view-group-card');
      if (firstCard) {
        selectGroupForView(firstCard);
      }
    }

    modal.style.display = 'flex';
  }

  function closeGroupModal() {
    const modal = document.getElementById('groupManagementModal');
    if (modal) modal.style.display = 'none';
  }

  function selectGroupForView(cardElem) {
    document.querySelectorAll('.view-group-card').forEach(c => {
      c.style.background = '#ffffff';
      c.style.borderColor = '#e2e8f0';
      c.style.borderLeft = '4px solid #0284c7';
      c.style.boxShadow = '0 1px 2px rgba(0,0,0,0.02)';
    });

    cardElem.style.background = '#e0f2fe';
    cardElem.style.borderColor = '#7dd3fc';
    cardElem.style.borderLeft = '4px solid #0369a1';
    cardElem.style.boxShadow = '0 1px 3px rgba(2, 132, 199, 0.1)';

    const groupName = cardElem.getAttribute('data-group-name');
    const membersStr = cardElem.getAttribute('data-group-members') || '';

    document.getElementById('selectedGroupNameTitle').innerText = groupName;

    const container = document.getElementById('selectedGroupMembersList');
    container.innerHTML = '';

    const emailList = membersStr.split(',').map(e => e.trim()).filter(e => e !== '');

    if (emailList.length === 0) {
      container.innerHTML = '<div style="color: #64748b; font-size: 8.5pt; padding: 10px;">メンバーが登録されていません</div>';
      return;
    }

    emailList.forEach(email => {
      const lowerEmail = email.toLowerCase();
      const userName = systemUserMap[lowerEmail] || '名前未設定';

      const itemHtml = 
        '<div style="background: #ffffff; padding: 5px 8px; border-radius: 4px; border: 1px solid #cbd5e1; border-left: 3px solid #38bdf8; font-size: 8.5pt; display: flex; align-items: center; justify-content: space-between; width: 100%; box-sizing: border-box;">' +
          '<span>👤 <strong style="color: #0f172a; font-size: 8.5pt;">' + escapeHtml(userName) + '</strong></span>' +
          '<span style="color: #64748b; font-size: 8pt; font-family: monospace;">' + escapeHtml(email) + '</span>' +
        '</div>';
      container.insertAdjacentHTML('beforeend', itemHtml);
    });
  }

  function filterViewGroupList() {
    const query = document.getElementById('viewGroupSearchInput').value.toLowerCase().trim();
    const cards = document.querySelectorAll('.view-group-card');
    cards.forEach(card => {
      const groupName = card.getAttribute('data-group-name').toLowerCase();
      if (groupName.includes(query)) {
        card.style.display = 'block';
      } else {
        card.style.display = 'none';
      }
    });
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

    if (!validateGroupForm(groupName, members)) return false;

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
      if (!res.ok) throw new Error('サーバーエラーが発生しました');
      return res.json();
    })
    .then(savedGroup => {
      location.reload();
    })
    .catch(err => {
      console.error(err);
      alert('保存処理に失敗しました。');
    });
    return false;
  }

  function handleEditGroupClick(btn) {
    const id = btn.getAttribute('data-group-id');
    const name = btn.getAttribute('data-group-name');
    const members = btn.getAttribute('data-group-members');
    editGroup(id, name, members);
  }

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
        location.reload();
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
    const checkedBoxes = document.getElementById('groupMemberListContainer').querySelectorAll('.group-member-checkbox:checked');
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

  function escapeHtml(str) {
    if (!str) return '';
    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#039;');
  }
</script>