<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- ② ⚙️ グループ管理モーダル -->
<div id="groupManagementModal" class="modal-overlay">
  <div class="modal-content" style="max-width: 520px;">
    <div class="modal-header">
      <span>⚙️ 招待グループの管理</span>
      <button type="button" class="modal-close-btn" onclick="closeGroupModal()">&times;</button>
    </div>
    
    <div style="padding: 16px;">
      <!-- 登録済みグループ表示エリア -->
      <label class="form-label"><b>登録済みグループ一覧</b></label>
      <div id="registeredGroupList" style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 6px; padding: 10px; margin-bottom: 16px; max-height: 140px; overflow-y: auto;">
        <div style="font-size: 8.5pt; margin-bottom: 8px; padding-bottom: 6px; border-bottom: 1px dashed #cbd5e1;">
          <div style="display: flex; justify-content: space-between;">
            <b>・開発チーム (3名)</b>
            <span style="color: #ef4444; cursor: pointer; font-size: 7.5pt;">[削除]</span>
          </div>
          <span style="color: #64748b; font-size: 8pt;">dev-tanaka@company.com, dev-sato@company.com, dev-suzuki@company.com</span>
        </div>
        <div style="font-size: 8.5pt;">
          <div style="display: flex; justify-content: space-between;">
            <b>・PMチーム (2名)</b>
            <span style="color: #ef4444; cursor: pointer; font-size: 7.5pt;">[削除]</span>
          </div>
          <span style="color: #64748b; font-size: 8pt;">pm-yamada@company.com, pm-watanabe@company.com</span>
        </div>
      </div>

      <hr style="border: none; border-top: 1px solid #e2e8f0; margin: 16px 0;">

      <!-- 新規グループ追加フォーム -->
      <form action="${pageContext.request.contextPath}/groups/create" method="POST" onsubmit="return handleAddGroup(event)">
        <div class="form-group">
          <label class="form-label">新規グループ名 <span style="color: #ef4444;">*</span></label>
          <input type="text" id="newGroupName" name="groupName" class="form-input" placeholder="例：インフラチーム" required>
        </div>
        
        <!-- 💡 メンバー追加（1件ずつ選択して追加できるdatalist付きフォーム） -->
        <div class="form-group">
          <label class="form-label">メンバー追加（入力で候補を表示）</label>
          <div style="display: flex; gap: 6px;">
            <input type="email" id="memberCandidateInput" list="emailCandidates" class="form-input" placeholder="名前またはメールを入力..." style="font-size: 8.5pt;">
            <button type="button" class="btn-secondary" style="white-space: nowrap; font-size: 8pt;" onclick="addMemberFromInput()">追加</button>
          </div>

          <!-- 自動補完候補（datalist） -->
          <datalist id="emailCandidates">
            <option value="dev-tanaka@company.com">田中太郎 (開発部)</option>
            <option value="dev-sato@company.com">佐藤花子 (開発部)</option>
            <option value="dev-suzuki@company.com">鈴木一郎 (開発部)</option>
            <option value="pm-yamada@company.com">山田次郎 (PM)</option>
            <option value="pm-watanabe@company.com">渡辺美咲 (PM)</option>
            <option value="infra-takahashi@company.com">高橋健二 (インフラ)</option>
          </datalist>
        </div>

        <div class="form-group">
          <label class="form-label">登録予定メンバー一覧（カンマ区切り） <span style="color: #ef4444;">*</span></label>
          <textarea id="newGroupMembers" name="members" class="form-input" style="height: 60px; font-size: 8.5pt;" placeholder="上記の検索から追加、または直接カンマ区切りで入力" required></textarea>
        </div>
        
        <div class="modal-footer" style="margin-top: 16px; padding: 0;">
          <button type="button" class="btn-secondary" onclick="closeGroupModal()">閉じる</button>
          <button type="submit" class="btn-primary" style="font-size: 8.5pt;">グループを追加保存</button>
        </div>
      </form>
    </div>
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

  // datalist候補からTextAreaへメールアドレスを追加する処理
  function addMemberFromInput() {
    const inputElem = document.getElementById('memberCandidateInput');
    const textareaElem = document.getElementById('newGroupMembers');
    const val = inputElem.value.trim();

    if (!val) return;

    if (textareaElem.value.trim() === '') {
      textareaElem.value = val;
    } else {
      // 既に登録済みでなければ追加
      const currentList = textareaElem.value.split(',').map(e => e.trim());
      if (!currentList.includes(val)) {
        textareaElem.value = textareaElem.value.trim() + ', ' + val;
      }
    }
    inputElem.value = ''; // 入力欄をクリア
  }

  // フロントでの簡易グループ追加デモ
  function handleAddGroup(event) {
    const name = document.getElementById('newGroupName').value;
    const members = document.getElementById('newGroupMembers').value;
    
    if (name && members) {
      alert('グループ「' + name + '」を追加しました！（画面リロード時にリセットされます）');
      closeGroupModal();
    }
    return false; // バックエンド連携前のため送信中断
  }
</script>