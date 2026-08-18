<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>⚡ AI Smart Meeting System</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2">
  
  <jsp:useBean id="now" class="java.util.Date" />
  <fmt:formatDate value="${now}" pattern="yyyy-MM-dd'T'HH:mm" var="currentFormattedDate" />
</head>
<body>

<div class="app-container">
  
  <div class="navbar navbar-slim">
    <div class="brand-logo">⚡ AI Smart Meeting System</div>
    <div>
      trainee1405@company.com <span class="user-badge">管理者</span>
      <button type="button" id="btn-open-group-modal" class="btn-secondary" style="margin-left: 10px; padding: 4px 10px; font-size: 8.5pt;" onclick="openGroupModal()">⚙️ グループ管理</button>
    </div>
  </div>

  <div class="main-content">
    
    <div class="action-bar action-bar-slim">
      <button type="button" id="btn-open-create-modal" class="btn-primary btn-primary-slim" onclick="openCreateModal()">＋ 新規会議を作成</button>
      
      <div class="search-container">
        <div class="search-box-group">
          <div style="position: relative; display: inline-block;">
            <input type="text" id="searchInput" class="search-box search-box-slim" 
                   placeholder="🔍 会議・タスク・キーワード検索..." value="<c:out value='${keyword}'/>" oninput="filterDashboardAll()">
            <div id="validationError" class="error-message"></div>
          </div>

          <button type="button" id="btn-execute-search" class="btn-secondary btn-secondary-slim" onclick="filterDashboardAll()">検索</button>
          <button type="button" id="btn-clear-keyword-search" class="btn-secondary btn-clear-slim" onclick="clearKeywordSearch()">クリア</button>
        </div>
      </div>
    </div>

    <div class="layout-grid">
      
      <div class="left-col">
        <div class="card">
          <div class="card-header card-header-slim">
            <span>📅 会議一覧とAI要約</span>
            <select id="monthFilterSelect" class="select-month-filter" onchange="filterDashboardAll()">
              <option value="">📅 全期間表示</option>
            </select>
          </div>
          
          <div id="meetingListArea" class="scrollable-area">
            <c:choose>
              <c:when test="${empty meetings}">
                <div style="text-align: center; color: #64748b; padding: 20px;">該当する会議は見つかりませんでした。</div>
              </c:when>
              <c:otherwise>
                <c:forEach var="m" items="${meetings}">
                  <div class="meeting-item" 
                       data-meeting-id="${m.meetingId}"
                       data-title="<c:out value='${m.title}'/>"
                       data-start-time="${m.startTime}"
                       data-attendee-emails="<c:out value='${m.attendeeEmails}'/>"
                       onclick="location.href='${pageContext.request.contextPath}/meetings/detail?id=${m.meetingId}'">
                    
                    <div style="display: flex; justify-content: space-between; align-items: center; gap: 8px; margin-bottom: 4px;">
                      
                      <div class="meeting-title" 
                           title="<c:out value='${m.title}'/>" 
                           style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis; flex: 1; min-width: 0;">
                        <c:out value="${m.title}"/>
                      </div>

                      <div style="display: flex; align-items: center; gap: 8px; flex-shrink: 0;">

                        <c:choose>
                          <c:when test="${m.startTime > currentFormattedDate}">
                            <span class="meeting-badge-future">📅 予定 (未来)</span>
                          </c:when>
                          <c:otherwise>
                            <span class="meeting-badge-ended">✅ 終了</span>
                          </c:otherwise>
                        </c:choose>

                        <div style="font-size: 8pt; display: flex; gap: 6px;">
                          <button type="button" 
                                  class="btn-edit-meeting"
                                  style="color: #0284c7; background: none; border: none; cursor: pointer; padding: 0; font-weight: bold; font-size: 8pt;" 
                                  onclick="openEditMeetingModal(event, this)">
                            [編集]
                          </button>
                          <button type="button" 
                                  class="btn-delete-meeting"
                                  style="color: #ef4444; background: none; border: none; cursor: pointer; padding: 0; font-size: 8pt;" 
                                  onclick="deleteMeeting(event, this)">
                            [削除]
                          </button>
                        </div>
                      </div>
                    </div>

                    <div class="meeting-date" style="display: flex; align-items: center; gap: 6px;">
                      <span style="white-space: nowrap;">🕒 <c:out value="${m.startTime}"/></span>
                      <span>|</span>
                      <div class="attendee-tooltip-container" title="👥 クリック/ホバーで全リスト表示">
                        👥 参加者: <c:out value="${empty m.attendeeEmails ? '未設定' : m.attendeeEmails}"/>
                        <c:if test="${not empty m.attendeeEmails}">
                          <div class="tooltip-text">
                            <strong style="color: #38bdf8; display: block; margin-bottom: 2px;">👥 全参加者メンバー:</strong>
                            <c:out value="${m.attendeeEmails}"/>
                          </div>
                        </c:if>
                      </div>
                    </div>

                    <c:choose>
                      <c:when test="${not empty m.aiSummary}">
                        <div class="ai-summary-box">
                          <span class="ai-summary-label">✨ Gemini AI要約:</span>
                          <span class="ai-summary-text"><c:out value="${m.aiSummary}"/></span>
                        </div>
                      </c:when>
                      <c:otherwise>
                        <div class="ai-summary-box ai-summary-box-empty">
                          <span style="font-weight: bold;">⚠️ 議事録・要約未作成</span>
                          <span style="font-size: 7.5pt; color: #d97706;">(クリックして議事録入力＆要約作成)</span>
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

      <div class="right-col">
        <div class="card">
          <div class="card-header card-header-slim">
            <div style="display: flex; align-items: center; gap: 6px;">
              <span id="taskHeaderTitle">☑️ 未完了タスク</span>
              
              <div class="tooltip-container">
                <span class="tooltip-icon">ℹ️</span>
                <div class="tooltip-content">
                  <div style="font-weight: bold; margin-bottom: 6px; border-bottom: 1px solid #475569; padding-bottom: 4px; color: #f8fafc;">💡 締切アラートの色ルール</div>
                  <div style="display: flex; flex-direction: column; gap: 4px; font-size: 8pt;">
                    <div>🚨 <b style="color: #fca5a5;">危険 (赤色)</b> : 締切まで 10日以内</div>
                    <div>⚠️ <b style="color: #fde047;">注意 (黄色)</b> : 締切まで 11日〜30日以内</div>
                    <div>🟢 <b style="color: #86efac;">余裕 (緑色)</b> : 締切まで 31日以上先</div>
                    <div>⚪ <b style="color: #cbd5e1;">期限なし (グレー)</b> : 締切未設定</div>
                  </div>
                </div>
              </div>
            </div>

            <span style="font-size: 8pt; font-weight: normal; color: #64748b;" id="taskCountLabel">全 <c:out value="${fn:length(tasks)}"/> 件</span>
          </div>

          <div class="task-filter-panel">
            <div class="filter-grid-row1">
              <span class="filter-label">絞り込み:</span>
              
              <select id="taskStatusFilter" class="task-filter-select" onchange="filterDashboardAll()">
                <option value="">ステータス (すべて)</option>
                <option value="TODO">🟣 TODO (未着手)</option>
                <option value="IN_PROGRESS">🟠 IN_PROGRESS (進行中)</option>
                <option value="COMPLETED">🟢 COMPLETED (完了)</option>
              </select>

              <select id="taskAssigneeFilter" class="task-filter-select" onchange="filterDashboardAll()">
                <option value="">担当者 (すべて)</option>
              </select>

              <select id="taskUrgencyFilter" class="task-filter-select" onchange="filterDashboardAll()">
                <option value="">期限 (すべて)</option>
                <option value="DANGER">🚨 危険 (10日以内)</option>
                <option value="WARNING">⚠️ 注意 (11-30日)</option>
                <option value="SAFE">🟢 余裕 (31日以上)</option>
                <option value="NONE">⚪ 期限なし</option>
              </select>
            </div>

            <div class="filter-grid-row2" style="display: flex; align-items: center; justify-content: space-between; gap: 8px;">
              <div style="display: flex; align-items: center; gap: 6px;">
                <span class="filter-label">並び替え:</span>
                <select id="taskSortSelect" class="task-filter-select task-sort-select" onchange="sortAndFilterTasks()">
                  <option value="dueDate">📅 期限が近い順</option>
                  <option value="assignee">👤 担当者順</option>
                  <option value="status">📊 ステータス順</option>
                </select>
              </div>

              <div style="display: flex; align-items: center; gap: 8px; margin-left: auto;">
                <label class="completed-toggle" style="margin: 0; white-space: nowrap;">
                  <input type="checkbox" id="showCompletedCheck" onchange="filterDashboardAll()" style="cursor: pointer; accent-color: #0284c7;">
                  <span>完了済みも表示</span>
                </label>
                <button type="button" id="btn-clear-task-filters" class="btn-secondary btn-clear-slim" 
                        style="height: 28px; padding: 0 10px; font-size: 8.5pt; line-height: 1; white-space: nowrap; flex-shrink: 0; display: inline-flex; align-items: center; justify-content: center; box-sizing: border-box;" 
                        onclick="clearTaskFilters()">クリア</button>
              </div>
            </div>
          </div>

          <div id="taskListArea" class="scrollable-area">
            <c:choose>
              <c:when test="${empty tasks}">
                <div style="text-align: center; color: #64748b; padding: 10px;">タスクはありません</div>
              </c:when>
              <c:otherwise>
                <c:forEach var="t" items="${tasks}">
                  <div class="task-row task-row-compact ${t.status == 'IN_PROGRESS' ? 'status-in-progress' : ''}" 
                       data-status="<c:out value='${t.status}'/>"
                       data-assignee="<c:out value='${empty t.assigneeName ? "未設定" : t.assigneeName}'/>"
                       data-urgency="<c:out value='${empty t.dueUrgency ? "NONE" : t.dueUrgency}'/>"
                       data-due-date="<c:out value='${empty t.dueDate ? "9999-99-99" : t.dueDate}'/>"
                       onclick="window.open('${pageContext.request.contextPath}/tasks/detail?id=${t.taskId}', '_blank')">
                    
                    <div style="flex: 1; padding-right: 8px;">
                      <div style="display: flex; align-items: center; gap: 6px; margin-bottom: 3px; flex-wrap: wrap;">
                        <div class="task-card-meeting-badge">
                          📌 <c:out value="${empty t.meetingTitle ? '未紐付け' : t.meetingTitle}"/>
                        </div>
                        
                        <div class="task-card-meta">
                          <span>担当: <c:out value="${empty t.assigneeName ? '未設定' : t.assigneeName}"/></span>
                          <span style="color: #cbd5e1;">|</span>
                          <c:choose>
                            <c:when test="${t.dueUrgency == 'DANGER'}">
                              <span class="badge-due badge-due-danger">締切: <c:out value="${t.dueDate}"/></span>
                            </c:when>
                            <c:when test="${t.dueUrgency == 'WARNING'}">
                              <span class="badge-due badge-due-warning">締切: <c:out value="${t.dueDate}"/></span>
                            </c:when>
                            <c:when test="${t.dueUrgency == 'SAFE'}">
                              <span class="badge-due badge-due-safe">締切: <c:out value="${t.dueDate}"/></span>
                            </c:when>
                            <c:otherwise>
                              <span class="badge-due badge-due-none">締切: 期限なし</span>
                            </c:otherwise>
                          </c:choose>
                        </div>
                      </div>

                      <div class="task-card-content"><c:out value="${t.taskContent}"/></div>
                    </div>

                    <c:choose>
                      <c:when test="${t.status == 'COMPLETED'}">
                        <span class="badge-status" style="background: #dcfce7; color: #15803d; align-self: center;">
                          <c:out value="${t.status}"/>
                        </span>
                      </c:when>
                      <c:otherwise>
                        <span class="badge-status" style="align-self: center;">
                          <c:out value="${t.status}"/>
                        </span>
                      </c:otherwise>
                    </c:choose>
                  </div>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="modal-create-meeting.jsp" />
<jsp:include page="modal-group-management.jsp" />

<script>
  window.onclick = function(event) {
    const meetingModal = document.getElementById('createMeetingModal');
    const groupModal = document.getElementById('groupManagementModal');
    if (event.target === meetingModal && typeof closeModal === 'function') closeModal();
    if (event.target === groupModal && typeof closeGroupModal === 'function') closeGroupModal();
  };

  function openCreateModal() {
    if (typeof resetMeetingModal === 'function') {
      resetMeetingModal();
    }
    const modal = document.getElementById('createMeetingModal');
    if (modal) {
      modal.style.display = 'flex';
    } else if (typeof openModal === 'function') {
      openModal();
    }
  }

  function openEditMeetingModal(evt, btnElem) {
    if (evt) {
      evt.stopPropagation();
      evt.preventDefault();
    }

    if (typeof resetMeetingModal === 'function') {
      resetMeetingModal();
    }

    const item = btnElem.closest('.meeting-item');
    if (!item) return;

    const meetingId = item.getAttribute('data-meeting-id');
    const title = item.getAttribute('data-title');
    const startTime = item.getAttribute('data-start-time');
    const attendeeEmails = item.getAttribute('data-attendee-emails') || '';

    const modal = document.getElementById('createMeetingModal');
    if (!modal) return;
    const form = document.getElementById('meetingForm') || modal.querySelector('form');
    if (form) {
      form.action = '${pageContext.request.contextPath}/meetings/update';
    }

    const titleText = document.getElementById('modalTitleText') || modal.querySelector('.modal-title-text');
    if (titleText) titleText.innerText = '✏️ 会議情報を編集';

    let hiddenId = document.getElementById('modalMeetingId');
    if (!hiddenId && form) {
      hiddenId = document.createElement('input');
      hiddenId.type = 'hidden';
      hiddenId.name = 'meetingId';
      hiddenId.id = 'modalMeetingId';
      form.appendChild(hiddenId);
    }
    if (hiddenId) hiddenId.value = meetingId;

    const titleInput = document.getElementById('meetingTitleInput') || modal.querySelector('[name="title"]');
    if (titleInput) titleInput.value = title || '';

    const timeInput = document.getElementById('meetingStartTimeInput') || modal.querySelector('[name="startTime"]');
    if (timeInput && startTime) {
      timeInput.value = startTime.length >= 16 ? startTime.substring(0, 16) : startTime;
    }

    const emailInput = document.getElementById('invitedMembersTextarea') || modal.querySelector('[name="attendeeEmails"]');
    if (emailInput) emailInput.value = attendeeEmails;
    const emailList = attendeeEmails.split(',').map(e => e.trim().toLowerCase()).filter(e => e !== '');

    const groupSelect = document.getElementById('groupSelect');
    if (groupSelect && groupSelect.options.length > 1) {
      let matchedGroupId = "";
      for (let i = 1; i < groupSelect.options.length; i++) {
        const option = groupSelect.options[i];
        const groupMembersAttr = option.getAttribute('data-members') || '';
        const groupMembers = groupMembersAttr.split(',').map(e => e.trim().toLowerCase()).filter(e => e !== '');
        if (groupMembers.length > 0 && groupMembers.every(gm => emailList.includes(gm))) {
          matchedGroupId = option.value;
          break;
        }
      }

      groupSelect.value = matchedGroupId;
      if (typeof updateGroupMembers === 'function') {
        updateGroupMembers();
      }
    }

    const checkboxes = modal.querySelectorAll('.member-checkbox');
    checkboxes.forEach(cb => {
      const cbEmail = cb.value.trim().toLowerCase();
      if (!cb.disabled) {
        cb.checked = emailList.includes(cbEmail);
      }
    });
    modal.style.display = 'flex';
  }

  function deleteMeeting(evt, btnElem) {
    if (evt) {
      evt.stopPropagation();
      evt.preventDefault();
    }

    const item = btnElem.closest('.meeting-item');
    if (!item) return;

    const meetingId = item.getAttribute('data-meeting-id');
    const title = item.getAttribute('data-title');
    if (!confirm('「' + title + '」を削除しますか？\n（※Googleカレンダーの予定も削除されます）')) {
      return;
    }

    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '${pageContext.request.contextPath}/meetings/delete';

    const input = document.createElement('input');
    input.type = 'hidden';
    input.name = 'meetingId';
    input.value = meetingId;

    form.appendChild(input);
    document.body.appendChild(form);
    form.submit();
  }

  function initMonthFilterOptions() {
    const selectElem = document.getElementById('monthFilterSelect');
    if (!selectElem) return;

    const monthsSet = new Set();
    document.querySelectorAll('.meeting-item').forEach(card => {
      const startTime = card.getAttribute('data-start-time');
      if (startTime && startTime.length >= 7) {
        monthsSet.add(startTime.substring(0, 7).replace('-', '/'));
      }
    });
    Array.from(monthsSet).sort().reverse().forEach(ym => {
      const option = document.createElement('option');
      option.value = ym;
      option.textContent = ym;
      selectElem.appendChild(option);
    });
  }

  function initAssigneeFilterOptions() {
    const selectElem = document.getElementById('taskAssigneeFilter');
    if (!selectElem) return;

    const assigneesSet = new Set();
    document.querySelectorAll('.task-row').forEach(card => {
      const assignee = card.getAttribute('data-assignee');
      if (assignee && assignee !== '未設定') {
        assigneesSet.add(assignee);
      }
    });
    Array.from(assigneesSet).sort().forEach(a => {
      const option = document.createElement('option');
      option.value = a;
      option.textContent = a;
      selectElem.appendChild(option);
    });
  }

  function saveFilterState() {
    const state = {
      keyword: document.getElementById('searchInput').value,
      month: document.getElementById('monthFilterSelect').value,
      status: document.getElementById('taskStatusFilter').value,
      assignee: document.getElementById('taskAssigneeFilter').value,
      urgency: document.getElementById('taskUrgencyFilter').value,
      sort: document.getElementById('taskSortSelect').value,
      showCompleted: document.getElementById('showCompletedCheck').checked
    };
    sessionStorage.setItem('dashboardFilterState', JSON.stringify(state));
  }

  function restoreFilterState() {
    const saved = sessionStorage.getItem('dashboardFilterState');
    if (!saved) return;
    try {
      const state = JSON.parse(saved);
      if (state.keyword !== undefined) document.getElementById('searchInput').value = state.keyword;
      if (state.month !== undefined) document.getElementById('monthFilterSelect').value = state.month;
      if (state.status !== undefined) document.getElementById('taskStatusFilter').value = state.status;
      if (state.assignee !== undefined) document.getElementById('taskAssigneeFilter').value = state.assignee;
      if (state.urgency !== undefined) document.getElementById('taskUrgencyFilter').value = state.urgency;
      if (state.sort !== undefined) document.getElementById('taskSortSelect').value = state.sort;
      if (state.showCompleted !== undefined) document.getElementById('showCompletedCheck').checked = state.showCompleted;
    } catch (e) {
      console.error('フィルター状態の復元に失敗しました', e);
    }
  }

  function filterDashboardAll() {
    const inputElem = document.getElementById('searchInput');
    const errorElem = document.getElementById('validationError');
    const monthSelect = document.getElementById('monthFilterSelect');
    
    const query = inputElem ? inputElem.value.toLowerCase().trim() : '';
    const selectedMonth = monthSelect ? monthSelect.value : '';
    const statusFilter = document.getElementById('taskStatusFilter').value;
    const assigneeFilter = document.getElementById('taskAssigneeFilter').value;
    const urgencyFilter = document.getElementById('taskUrgencyFilter').value;
    const showCompleted = document.getElementById('showCompletedCheck').checked;

    document.getElementById('taskHeaderTitle').innerText = showCompleted ?
      '📋 タスク一覧 (全件)' : '☑️ 未完了タスク';

    if (inputElem && inputElem.value.length > 50) {
      inputElem.classList.add('error');
      errorElem.innerText = '検索ワードは50文字以内で入力してください。（現在: ' + inputElem.value.length + '文字）';
      return;
    } else if (inputElem) {
      inputElem.classList.remove('error');
      errorElem.innerText = '';
    }

    document.querySelectorAll('.meeting-item').forEach(card => {
      const text = card.innerText.toLowerCase();
      const startTime = card.getAttribute('data-start-time') || '';
      const cardYm = startTime.substring(0, 7).replace('-', '/');

      const matchesKeyword = text.includes(query);
      const matchesMonth = (selectedMonth === '') || (cardYm === selectedMonth);

      card.style.display = (matchesKeyword && matchesMonth) ? 'block' : 'none';
    });

    let visibleCount = 0;
    document.querySelectorAll('.task-row').forEach(card => {
      const text = card.innerText.toLowerCase();
      const status = card.getAttribute('data-status');
      const assignee = card.getAttribute('data-assignee');
      const urgency = card.getAttribute('data-urgency');

      const matchesKeyword = text.includes(query);
      const matchesStatus = (!statusFilter && (showCompleted || status !== 'COMPLETED')) || (statusFilter && status === statusFilter);
      const matchesAssignee = (!assigneeFilter) || (assignee.includes(assigneeFilter));
      const matchesUrgency = (!urgencyFilter) || (urgency === urgencyFilter);

      if (matchesKeyword && matchesStatus && matchesAssignee && matchesUrgency) {
        card.style.display = 'flex';
        visibleCount++;
      } else {
        card.style.display = 'none';
      }
    });

    document.getElementById('taskCountLabel').innerText = '表示 ' + visibleCount + ' 件';
    sortAndFilterTasks();
    saveFilterState();
  }

  function sortAndFilterTasks() {
    const container = document.getElementById('taskListArea');
    const sortBy = document.getElementById('taskSortSelect').value;
    const cards = Array.from(container.querySelectorAll('.task-row'));

    cards.sort((a, b) => {
      if (sortBy === 'dueDate') {
        return a.getAttribute('data-due-date').localeCompare(b.getAttribute('data-due-date'));
      } else if (sortBy === 'assignee') {
        return a.getAttribute('data-assignee').localeCompare(b.getAttribute('data-assignee'), 'ja');
      } else if (sortBy === 'status') {
        return a.getAttribute('data-status').localeCompare(b.getAttribute('data-status'));
      }
      return 0;
    });

    cards.forEach(card => container.appendChild(card));
    saveFilterState();
  }

  function clearKeywordSearch() {
    document.getElementById('searchInput').value = '';
    filterDashboardAll();
  }

  function clearTaskFilters() {
    document.getElementById('taskStatusFilter').value = '';
    document.getElementById('taskAssigneeFilter').value = '';
    document.getElementById('taskUrgencyFilter').value = '';
    document.getElementById('taskSortSelect').value = 'dueDate';
    document.getElementById('showCompletedCheck').checked = false;
    filterDashboardAll();
  }

  document.addEventListener('DOMContentLoaded', function() {
    initMonthFilterOptions();
    initAssigneeFilterOptions();
    restoreFilterState();
    filterDashboardAll();
  });
</script>

</body>
</html>