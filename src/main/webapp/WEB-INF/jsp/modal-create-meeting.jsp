<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- ① 新規会議作成モーダル (SCR-02) -->
<div id="createMeetingModal" class="modal-overlay">
  <div class="modal-content">
    <div class="modal-header">
      <span>📅 新規会議を作成</span>
      <button type="button" class="modal-close-btn" onclick="closeModal()">&times;</button>
    </div>
    
    <form action="${pageContext.request.contextPath}/meetings/create" method="POST">
      <div class="form-group">
        <label class="form-label">会議タイトル <span style="color: #ef4444;">*</span></label>
        <input type="text" name="title" class="form-input" placeholder="例：週次進捗確認ミーティング" required data-testid="meeting-title-input">
      </div>
      
      <div class="form-group">
        <label class="form-label">開催日時 <span style="color: #ef4444;">*</span></label>
        <input type="datetime-local" name="startTime" class="form-input" required data-testid="meeting-datetime-input">
      </div>
      
      <!-- 招待グループ選択 -->
      <div class="form-group">
        <label class="form-label">招待グループ <span style="color: #ef4444;">*</span></label>
        <select name="groupId" id="groupSelect" class="form-select" required data-testid="group-select-checkbox" onchange="updateGroupMembers()">
          <option value="">グループを選択してください</option>
          <option value="dev">開発チーム (3名)</option>
          <option value="pm">PMチーム (2名)</option>
        </select>
        
        <!-- 👥 選択グループのメンバー一覧 -->
        <div id="memberListDisplay" style="margin-top: 6px; font-size: 8pt; color: #475569; display: none; background-color: #f8fafc; padding: 6px 10px; border-radius: 4px; border: 1px solid #e2e8f0;">
          👥 <b>対象メンバー:</b> <span id="memberNames"></span>
        </div>
      </div>

      <!-- Google Meet URL 自動発行エリア -->
      <div class="form-group" style="background-color: #f8fafc; padding: 12px; border-radius: 6px; border: 1px solid #e2e8f0; margin-top: 16px;">
        <button type="button" class="btn-secondary" style="width: 100%; background-color: #0284c7; color: white; border: none; margin-bottom: 8px;" data-testid="meet-create-btn" onclick="generateMeetUrl()">
          Google Meet URL を自動発行して送信
        </button>
        <div style="font-size: 8.5pt; color: #475569;">
          発行結果 Meet URL: 
          <a href="#" id="meetUrlDisplay" target="_blank" style="color: #0284c7; font-weight: bold; text-decoration: underline;">未発行</a>
          <input type="hidden" name="meetUrl" id="meetUrlInput" value="">
        </div>
      </div>
      
      <!-- フッター：「保存」と「保存して要約作成へ」の2つのボタン -->
      <div class="modal-footer" style="margin-top: 20px; display: flex; justify-content: flex-end; gap: 8px;">
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

  // グループデータ（ダミー）
  const groupMembers = {
    'dev': 'dev-tanaka@company.com, dev-sato@company.com, dev-suzuki@company.com',
    'pm': 'pm-yamada@company.com, pm-watanabe@company.com'
  };

  // 招待グループ選択時のメンバー表示
  function updateGroupMembers() {
    const selectElem = document.getElementById('groupSelect');
    const displayArea = document.getElementById('memberListDisplay');
    const namesElem = document.getElementById('memberNames');
    
    const selectedVal = selectElem.value;
    
    if (selectedVal && groupMembers[selectedVal]) {
      namesElem.innerText = groupMembers[selectedVal];
      displayArea.style.display = 'block';
    } else {
      displayArea.style.display = 'none';
    }
  }

  // Meet URL生成
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