<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- ② ⚙️ 招待グループ管理モーダル -->
<div id="groupManagementModal" class="modal-overlay">
  <div class="modal-content" style="max-width: 1080px; width: 92%; padding: 20px 24px;">
    <div class="modal-header" style="margin-bottom: 16px;">
      <span style="font-size: 13pt; font-weight: bold;">⚙️ 招待グループの管理</span>
      <button type="button" class="modal-close-btn" onclick="closeGroupModal()">&times;</button>
    </div>
    
    <form id="groupForm" onsubmit="return handleAddGroup(event)" novalidate>
      <input type="hidden" id="editingGroupId" name="groupId" value="">

      <!-- 3カラム（左・中・右）横並びグリッドレイアウト -->
      <div style="display: grid; grid-template-columns: 1fr 0.9fr 1.1fr; gap: 16px; align-items: stretch;">
        
        <!-- 【左カラム】：登録済みグループ一覧 -->
        <div style="background-color: #f8fafc; padding: 12px; border-radius: 6px; border: 1px solid #e2e8f0;">
          <label class="form-label" style="font-size: 8.5pt; font-weight: bold; margin-bottom: 8px; display: block;">
            📋 登録済みグループ一覧
          </label>
          
          <div id="registeredGroupList" style="max-height: 220px; overflow-y: auto; display: flex; flex-direction: column; gap: 8px;">
            <c:choose>
              <c:when test="${empty groups}">
                <div id="noGroupMsg" style="font-size: 8pt; color: #64748b; padding: 8px; text-align: center;">登録されたグループはありません</div>
              </c:when>
              <c:otherwise>
                <c:forEach var="g" items="${groups}">
                  <c:if test="${not empty g.groupName}">
                    <div class="group-card-item" id="group-card-${g.groupId}" style="background: #ffffff; border: 1px solid #cbd5e1; border-radius: 4px; padding: 8px;">
                      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
                        <b style="font-size: 8.5pt; color: #0f172a;" class="group-name-text">・<c:out value="${g.groupName}"/></b>
                        <div style="display: flex; gap: 6px;">
                          <button type="button" style="color: #0284c7; background: none; border: none; font-size: 7.5pt; cursor: pointer; font-weight: bold; padding: 0;" onclick="editGroup(${g.groupId}, '<c:out value="${g.groupName}"/>', '<c:out value="${g.members}"/>')">[編集]</button>
                          <button type="button" style="color: #ef4444; background: none; border: none; font-size: 7.5pt; cursor: pointer; padding: 0;" onclick="deleteGroup(${g.groupId}, '<c:out value="${g.groupName}"/>')">[削除]</button>
                        </div>
                      </div>
                      <div style="font-size: 7.5pt; color: #64748b; line-height: 1.3; word-break: break-all;" class="group-members-text">
                        <c:out value="${g.members}"/>
                      </div>
                    </div>
                  </c:if>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </div>
        </div>

        <!-- 【中央カラム】：グループ名設定・新規/編集切り替え -->
        <div style="background-color: #f8fafc; padding: 12px; border-radius: 6px; border: 1px solid #e2e8f0; display: flex; flex-direction: column; justify-content: space-between;">
          <div>
            <div style="margin-bottom: 12px; border-bottom: 1px solid #e2e8f0; padding-bottom: 8px;">
              <div style="display: flex; align-items: center; justify-content: space-between; gap: 8px; flex-wrap: wrap;">
                <div style="display: flex; align-items: center; gap: 6px;">
                  <span id="formModeTitle" style="font-size: 8.5pt; font-weight: bold; color: #0f172a;">➕ 新規グループ作成</span>
                  <span id="targetGroupBadge" style="display: none; font-size: 7.5pt; background-color: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd; padding: 1px 6px; border-radius: 4px; font-weight: bold;"></span>
                </div>
              </div>
              <div id="resetModeArea" style="display: none; margin-top: 4px;">
                <button type="button" style="font-size: 7.5pt; color: #0284c7; background: none; border: none; cursor: pointer; text-decoration: underline; padding: 0; display: inline-flex; align-items: center; gap: 2px;" onclick="resetGroupForm()">
                  ↩️ 新規作成モードに戻る
                </button>
              </div>
            </div>

            <div class="form-group" style="margin-bottom: 8px;">
              <label class="form-label" style="font-size: 8.0pt;">グループ名 <span style="color: #ef4444;">*</span></label>
              <input type="text" id="newGroupName" name="groupName" class="form-input" placeholder="例：インフラチーム" style="padding: 6px 10px; font-size: 8.5pt; background-color: #ffffff;">
            </div>
          </div>

          <div style="font-size: 7.5pt; color: #64748b; line-height: 1.4; background: #ffffff; padding: 8px; border-radius: 4px; border: 1px solid #cbd5e1;">
            💡 <b>使い方</b><br>
            ・左の [編集] を押すと既存グループのメンバーを変更できます。<br>
            ・右側でメンバーにチェックを入れて保存してください。
          </div>
        </div>

        <!-- 【右カラム】：メンバー選択 -->
        <div style="background-color: #f8fafc; padding: 12px; border-radius: 6px; border: 1px solid #e2e8f0;">
          <label class="form-label" style="margin-bottom: 6px; font-weight: bold; font-size: 8.5pt;">
            👤 グループメンバー選択
          </label>
          
          <div style="margin-bottom: 8px;">
            <input type="text" id="groupMemberSearchInput" class="form-input" placeholder="🔍 名前・メールで絞り込み..." oninput="filterGroupMemberList()" style="padding: 5px 8px; font-size: 8pt; width: 100%; box-sizing: border-box; background-color: #ffffff;">
          </div>

          <div id="groupMemberListContainer" style="max-height: 110px; overflow-y: auto; background: #ffffff; border: 1px solid #cbd5e1; border-radius: 4px; padding: 6px; display: flex; flex-direction: column; gap: 4px; margin-bottom: 8px;">
            <c:choose>
              <c:when test="${empty users}">
                <div style="font-size: 8pt; color: #64748b; padding: 8px; text-align: center;">登録メンバーがいません</div>
              </c:when>
              <c:otherwise>
                <c:forEach var="u" items="${users}">
                  <label class="group-member-item-label" data-search-text="<c:out value='${u.name}'/> <c:out value='${u.email}'/>" style="font-size: 8pt; cursor: pointer; display: flex; align-items: center; justify-content: space-between; padding: 3px 4px; border-radius: 3px;">
                    <span>
                      <input type="checkbox" class="group-member-checkbox" value="<c:out value='${u.email}'/>" onchange="syncGroupMembers()"> 
                      <c:out value="${u.name}"/> (<c:out value="${u.email}"/>)
                    </span>
                  </label>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </div>

          <label class="form-label" style="font-size: 7.5pt; color: #475569; margin-bottom: 2px;">登録予定メンバー一覧 (カンマ区切り): <span style="color: #ef4444;">*</span></label>
          <textarea id="newGroupMembers" name="members" class="form-input" style="height: 44px; font-size: 8pt; resize: vertical; background-color: #ffffff;" placeholder="選択したメンバーが自動入力されます"></textarea>
        </div>

      </div>
      
      <!-- フッターボタンエリア -->
      <div class="modal-footer" style="margin-top: 16px; padding-top: 12px; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 8px;">
        <button type="button" class="btn-secondary" onclick="closeGroupModal()">閉じる</button>
        <button type="submit" id="submitGroupBtn" class="btn-primary" style="background-color: #0284c7; font-size: 8.5pt;">
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

  // ★ JSP(フロントエンド)バリデーションチェック関数
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

  // ★ 送信処理ハンドラー（バリデーション通過時のみFetch通信実行）
  function handleAddGroup(event) {
    event.preventDefault();

    const editingId = document.getElementById('editingGroupId').value;
    const groupName = document.getElementById('newGroupName').value.trim();
    const members = document.getElementById('newGroupMembers').value.trim();

    // ★ フロント側バリデーション実行（違反時はここでストップ）
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
        // 既存カード更新
        const existingCard = document.getElementById('group-card-' + editingId);
        if (existingCard) {
          existingCard.querySelector('.group-name-text').innerText = '・' + savedGroup.groupName;
          existingCard.querySelector('.group-members-text').innerText = savedGroup.members;
        }
      } else {
        // 新規カード先頭追加
        const newHtml = `
          <div class="group-card-item" id="group-card-\${savedGroup.groupId}" style="background: #ffffff; border: 1px solid #cbd5e1; border-radius: 4px; padding: 8px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
              <b style="font-size: 8.5pt; color: #0f172a;" class="group-name-text">・\${escapeHtml(savedGroup.groupName)}</b>
              <div style="display: flex; gap: 6px;">
                <button type="button" style="color: #0284c7; background: none; border: none; font-size: 7.5pt; cursor: pointer; font-weight: bold; padding: 0;" onclick="editGroup(\${savedGroup.groupId}, '\${escapeHtml(savedGroup.groupName)}', '\${escapeHtml(savedGroup.members)}')">[編集]</button>
                <button type="button" style="color: #ef4444; background: none; border: none; font-size: 7.5pt; cursor: pointer; padding: 0;" onclick="deleteGroup(\${savedGroup.groupId}, '\${escapeHtml(savedGroup.groupName)}')">[削除]</button>
              </div>
            </div>
            <div style="font-size: 7.5pt; color: #64748b; line-height: 1.3; word-break: break-all;" class="group-members-text">
              \${escapeHtml(savedGroup.members)}
            </div>
          </div>
        `;
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

  // ★ 非同期での削除処理
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

  function escapeHtml(str) {
    if (!str) return '';
    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#039;');
  }
</script>