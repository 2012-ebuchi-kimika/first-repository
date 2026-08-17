<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>📝 議事録投稿 ＆ AI解析 - AI Smart Meeting System</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2">
  <!-- .docx 解析用ライブラリ mammoth.js -->
  <script src="https://cdnjs.cloudflare.com/ajax/libs/mammoth/1.6.0/mammoth.browser.min.js"></script>
</head>
<body style="background-color: #f1f5f9; margin: 0;">

<!-- ヘッダー -->
<div class="navbar">
  <div class="brand-logo">⚡ AI Smart Meeting System</div>
  <div>trainee1405@company.com <span class="user-badge">管理者</span></div>
</div>

<!-- 担当者リアルタイム候補用データリスト -->
<datalist id="assigneeCandidates">
  <option value="伊藤 (ito@company.com)"></option>
  <option value="山本 (yamamoto@company.com)"></option>
  <option value="鈴木 (suzuki@company.com)"></option>
  <option value="佐藤 (sato@company.com)"></option>
  <option value="田中 (tanaka@company.com)"></option>
  <option value="高橋 (takahashi@company.com)"></option>
</datalist>

<div class="sc03-wrapper">
  <!-- 戻るナビゲーション -->
  <div class="sc03-nav-back">
    <a href="${pageContext.request.contextPath}/dashboard" class="sc03-nav-back-link">
      ↩️ ダッシュボードへ戻る
    </a>
  </div>

  <div class="sc03-grid">
    
    <!-- 【左カラム】入力・AI設定エリア -->
    <div class="sc03-card">
      <h2 class="sc03-card-title">
        📝 議事録入力 ＆ AI解析指示
      </h2>

      <form action="${pageContext.request.contextPath}/meetings/analyze" method="POST" onsubmit="return handleAiAnalyze(event)" class="sc03-form">
        <!-- 1. 会議選択 -->
        <div class="sc03-form-group">
          <label class="sc03-label">対象の会議 <span style="color: #ef4444;">*</span></label>
          <select name="meetingId" id="meetingSelect" class="form-select" required data-testid="meeting-select" onchange="location.href='${pageContext.request.contextPath}/meetings/detail?id=' + this.value;">
            <option value="">対象の会議を選択してください</option>
            <c:forEach var="m" items="${meetings}">
              <option value="${m.meetingId}" ${m.meetingId == selectedMeetingId || m.meetingId == param.id ? 'selected' : ''}>
                <c:out value="${m.startTime}"/> - <c:out value="${m.title}"/>
              </option>
            </c:forEach>
          </select>
        </div>

        <!-- 2. 文字起こしテキスト (ドラッグ＆ドロップ対応) -->
        <div class="sc03-form-group-flex">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
            <label class="sc03-label" style="margin-bottom: 0;">文字起こしテキスト <span style="color: #ef4444;">*</span></label>
            <span id="dragHelpText" style="font-size: 7.5pt; color: #0284c7; font-weight: bold;">
              💡 ファイル (.txt, .md, .docx) をドロップして読み込めます
            </span>
          </div>
          <textarea name="transcript" id="transcriptInput" class="sc03-textarea"
                    placeholder="会議の文字起こしテキストを貼り付けるか、テキスト・Wordファイル(.docx)をここにドロップしてください...&#10;例：&#10;田中: 本日のアジェンダは待機学習の進捗についてです。&#10;佐藤: Day 3のDB設計は完了しました。" 
                    required data-testid="transcript-input"></textarea>
        </div>

        <!-- 3. ペルソナ設定 -->
        <div class="sc03-form-group">
          <label class="sc03-label">要約トーン (ペルソナ設定)</label>
          <select name="personaType" id="personaSelect" class="form-select" data-testid="persona-select">
            <option value="default">👔 標準（標準的なビジネス要約）</option>
            <option value="tsundere">🎀 ツンデレ秘書（ツンツンしながらしっかり要約）</option>
            <option value="hotblooded">🔥 熱血アニキ（熱く成果を鼓舞）</option>
            <option value="nerv">👁️ NERV司令官（冷徹かつ完結に報告）</option>
          </select>
        </div>

        <!-- AI実行ボタン -->
        <button type="submit" id="aiBtn" class="btn-primary sc03-btn-ai" data-testid="ai-summary-btn">
          ✨ Gemini APIで要約・タスクを抽出する
        </button>
      </form>
    </div>

    <!-- 【右カラム】AI解析結果 ＆ 既存タスクエリア -->
    <div class="sc03-card">
      <h2 class="sc03-card-title">
        📊 会議情報 ＆ AI解析結果
      </h2>

      <!-- 右側全体のコンテナ -->
      <div class="sc03-right-container">
        
        <!-- ① 上部：AI解析エリア -->
        <div class="sc03-ai-box">
          
          <!-- AI未実行時の表示 -->
          <div id="emptyPreview" class="sc03-empty-state" style="display: ${empty savedAiSummary ? 'flex' : 'none'};">
            <div style="font-size: 20pt; margin-bottom: 4px;">🤖</div>
            <div style="font-weight: bold; font-size: 9pt; color: #475569;">AI要約は未生成です</div>
            <div style="font-size: 8pt; margin-top: 2px; color: #64748b;">「Gemini APIで要約・タスクを抽出する」を実行すると結果が表示されます。</div>
          </div>

          <!-- AI実行後 / 保存済み要約表示エリア -->
          <div id="resultPreviewArea" class="sc03-result-area" style="display: ${not empty savedAiSummary ? 'flex' : 'none'};">
            
            <!-- AI要約カード -->
            <div class="sc03-summary-card">
              <label id="summaryCardLabel" class="sc03-summary-label">
                【✨ ${not empty savedAiSummary ? '保存済みのAI要約（編集可能）' : '生成されたAI要約（編集可能）'}】
              </label>
              <textarea id="previewSummary" 
                        class="sc03-summary-textarea"
                        oninput="syncSummaryToHidden(this.value)"><c:out value="${savedAiSummary}"/></textarea>
            </div>

            <!-- 今回検出された複数タスク編集カード -->
            <div id="newTasksContainer" class="sc03-tasks-container">
              <div class="sc03-tasks-header">
                <label style="font-size: 8.5pt; font-weight: bold; color: #15803d;">【🆕 検出タスクの事前編集・確認】</label>
                <button type="button" onclick="addTaskRow('', '', '')" class="sc03-btn-add-task">
                  ＋ タスク追加
                </button>
              </div>
              <div id="taskRowsList" class="sc03-tasks-list"></div>
            </div>

            <!-- DB保存フォーム -->
            <form action="${pageContext.request.contextPath}/meetings/save-summary" method="POST" id="saveSummaryForm" style="margin-top: 2px;">
              <input type="hidden" name="meetingId" id="saveMeetingId" value="<c:out value='${selectedMeetingId}'/>">
              <input type="hidden" name="aiSummary" id="saveAiSummary" value="<c:out value='${savedAiSummary}'/>">
              <input type="hidden" name="taskTitle" id="saveTaskTitle" value="">
              <input type="hidden" name="taskAssignee" id="saveTaskAssignee" value="">
              <input type="hidden" name="taskDueDate" id="saveTaskDueDate" value="">
              
              <button type="submit" id="saveBtn" class="btn-primary sc03-btn-save" onclick="prepareSubmitData()">
                💾 この要約と新タスクをDBに保存する
              </button>
            </form>
          </div>
        </div>

        <!-- ② 下部：この会議の登録済みタスクエリア -->
        <div class="sc03-registered-tasks-box">
          <div class="sc03-registered-tasks-header">
            <span>📌 この会議の登録済みタスク</span>
            <span class="sc03-registered-tasks-count">
              全 ${empty existingTasks ? 0 : existingTasks.size()} 件
            </span>
          </div>
          
          <div class="sc03-registered-tasks-list">
            <c:choose>
              <c:when test="${not empty existingTasks}">
                <c:forEach var="task" items="${existingTasks}">
                  <div class="sc03-task-item"
                       onclick="window.open('${pageContext.request.contextPath}/tasks/detail?id=${task.taskId}', '_blank')"
                       title="別タブでタスク詳細を開く">
                    <div>
                      <span style="font-weight: bold; color: #1e293b;">・<c:out value="${task.taskContent}"/></span>
                      <span style="font-size: 7.5pt; color: #64748b; margin-left: 4px;">
                        (担当: <c:out value="${empty task.assigneeName ? (empty task.assigneeEmail ? '未割当' : task.assigneeEmail) : task.assigneeName}"/> / 締切: <c:out value="${empty task.dueDate ? '期限なし' : task.dueDate}"/>)
                      </span>
                    </div>
                    <span style="background: ${task.status == 'COMPLETED' ? '#dcfce7' : (task.status == 'IN_PROGRESS' ? '#fef3c7' : '#f1f5f9')}; 
                                 color: ${task.status == 'COMPLETED' ? '#15803d' : (task.status == 'IN_PROGRESS' ? '#d97706' : '#64748b')}; 
                                 font-size: 7pt; font-weight: bold; padding: 2px 6px; border-radius: 4px;">
                      <c:out value="${empty task.status ? 'TODO' : task.status}"/>
                    </span>
                  </div>
                </c:forEach>
              </c:when>
              <c:otherwise>
                <div style="color: #94a3b8; font-size: 8pt; text-align: center; padding: 12px 0;">
                  登録済みのタスクはありません
                </div>
              </c:otherwise>
            </c:choose>
          </div>
        </div>

      </div>

    </div>
  </div>
</div>

<script>
  function syncSummaryToHidden(val) {
    document.getElementById('saveAiSummary').value = val;
  }

  function addTaskRow(title = '', assignee = '', dueDate = '') {
    const container = document.getElementById('taskRowsList');
    const rowId = 'task_row_' + Date.now() + '_' + Math.random().toString(36).substr(2, 4);

    const cleanTitle = title.replace(/^\d+\.\s*/, '').trim();
    const cleanAssignee = assignee.replace(/^\d+\.\s*/, '').trim();
    let cleanDate = dueDate.replace(/^\d+\.\s*/, '').trim();

    const dateMatch = cleanDate.match(/\d{4}-\d{2}-\d{2}/);
    if (dateMatch) {
      cleanDate = dateMatch[0];
    } else {
      cleanDate = '';
    }

    const rowDiv = document.createElement('div');
    rowDiv.id = rowId;
    rowDiv.className = 'task-input-row';
    rowDiv.style.cssText = 'display: flex; gap: 4px; align-items: center; background: #ffffff; padding: 4px; border: 1px solid #cbd5e1; border-radius: 4px;';

    rowDiv.innerHTML = `
      <input type="text" class="form-input row-task-title" value="\${escapeHtml(cleanTitle)}" placeholder="タスク内容" style="flex: 2; height: 32px; font-size: 8.5pt; padding: 0 8px; min-width: 0;">
      <input type="text" class="form-input row-task-assignee" list="assigneeCandidates" value="\${escapeHtml(cleanAssignee)}" placeholder="担当者 (検索/選択)" style="flex: 1; height: 32px; font-size: 8.5pt; padding: 0 8px; min-width: 0;">
      <input type="date" class="form-input row-task-date" value="\${escapeHtml(cleanDate)}" style="flex: 1; height: 32px; font-size: 8.5pt; padding: 0 6px; min-width: 0; font-family: inherit;">
      <button type="button" onclick="removeTaskRow('\${rowId}')" style="background: none; border: none; color: #ef4444; font-weight: bold; cursor: pointer; padding: 0 4px; font-size: 11pt;" title="このタスクを削除">✕</button>
    `;

    container.appendChild(rowDiv);
  }

  function removeTaskRow(rowId) {
    const row = document.getElementById(rowId);
    if (row) {
      row.remove();
    }
  }

  function escapeHtml(str) {
    if (!str) return '';
    return str.replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/'/g, '&#039;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  function prepareSubmitData() {
    const titles = [];
    const assignees = [];
    const dueDates = [];

    document.querySelectorAll('.task-input-row').forEach((row) => {
      const t = row.querySelector('.row-task-title').value.trim();
      const a = row.querySelector('.row-task-assignee').value.trim();
      let d = row.querySelector('.row-task-date').value.trim();

      const dateMatch = d.match(/\d{4}-\d{2}-\d{2}/);
      if (dateMatch) {
        d = dateMatch[0];
      } else {
        d = '';
      }

      if (t) {
        titles.push(t);
        assignees.push(a);
        dueDates.push(d);
      }
    });

    document.getElementById('saveTaskTitle').value = titles.join(' / ');
    document.getElementById('saveTaskAssignee').value = assignees.join(' / ');
    document.getElementById('saveTaskDueDate').value = dueDates.join(' / ');
  }

  function handleAiAnalyze(event) {
    event.preventDefault();
    
    const meetingId = document.getElementById('meetingSelect').value;
    const transcript = document.getElementById('transcriptInput').value;
    const persona = document.getElementById('personaSelect').value;
    const btn = document.getElementById('aiBtn');
    
    if (!meetingId) {
      alert("対象の会議を選択してください。");
      return false;
    }

    if (!transcript.trim()) {
      alert("文字起こしテキストを入力してください。");
      return false;
    }

    btn.innerText = '⏳ Gemini AIで解析中...';
    btn.disabled = true;

    document.getElementById('emptyPreview').style.display = 'none';
    document.getElementById('resultPreviewArea').style.display = 'flex';
    document.getElementById('summaryCardLabel').innerText = '【✨ 生成されたAI要約（編集可能）】';
    document.getElementById('previewSummary').value = '⏳ AI解析を実行中です...';
    document.getElementById('taskRowsList').innerHTML = '';
    document.getElementById('newTasksContainer').style.display = 'none';
    document.getElementById('saveBtn').style.display = 'none';

    const formData = new URLSearchParams();
    formData.append('meetingId', meetingId);
    formData.append('transcript', transcript);
    formData.append('personaType', persona);

    fetch('${pageContext.request.contextPath}/meetings/analyze', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: formData
    })
    .then(response => response.json())
    .then(data => {
      const summary = data.summary || "要約が生成されませんでした。";
      const rawTitle = data.taskTitle || "";
      const rawAssignee = data.taskAssignee || "";
      const rawDueDate = data.taskDueDate || "";

      document.getElementById('newTasksContainer').style.display = 'block';

      if (rawTitle && rawTitle.trim()) {
        const titles = rawTitle.split(/\\|\/|\n|(?=\d+\.\s*)/).map(s => s.trim()).filter(s => s);
        const assignees = rawAssignee.split(/\\|\/|\n/).map(s => s.trim()).filter(s => s);
        const dueDates = rawDueDate.split(/\\|\/|\n/).map(s => s.trim()).filter(s => s);

        titles.forEach((t, index) => {
          addTaskRow(t, assignees[index] || assignees[0] || '', dueDates[index] || dueDates[0] || '');
        });
      } else {
        addTaskRow('', '', '');
      }

      if (!summary.includes("⚠️")) {
        document.getElementById('saveBtn').style.display = 'block';
      }

      document.getElementById('previewSummary').value = summary;
      document.getElementById('saveMeetingId').value = meetingId;
      document.getElementById('saveAiSummary').value = summary;

      btn.innerText = '✨ Gemini APIで要約・タスクを抽出する';
      btn.disabled = false;
    })
    .catch(error => {
      console.error('Error:', error);
      document.getElementById('previewSummary').value = '⚠️ 通信処理中にエラーが発生しました。';
      btn.innerText = '✨ Gemini APIで要約・タスクを抽出する';
      btn.disabled = false;
    });

    return false;
  }

  // ★【機能拡張】ファイル (.txt, .md, .docx) のドラッグ＆ドロップ読み込み処理
  document.addEventListener('DOMContentLoaded', function() {
    const textarea = document.getElementById('transcriptInput');
    const dragHelpText = document.getElementById('dragHelpText');

    if (!textarea) return;

    // 1. ドラッグ領域に入ったとき・上にあるとき（枠線と背景色をハイライト）
    ['dragenter', 'dragover'].forEach(eventName => {
      textarea.addEventListener(eventName, function(e) {
        e.preventDefault();
        e.stopPropagation();
        textarea.style.borderColor = '#0284c7';
        textarea.style.backgroundColor = '#f0f9ff';
        if (dragHelpText) dragHelpText.innerText = '📂 ここにドロップしてテキストを読み込み';
      }, false);
    });

    // 2. ドラッグ領域から外れたとき・キャンセル時（スタイル復元）
    ['dragleave', 'drop'].forEach(eventName => {
      textarea.addEventListener(eventName, function(e) {
        e.preventDefault();
        e.stopPropagation();
        textarea.style.borderColor = '#cbd5e1';
        textarea.style.backgroundColor = '#ffffff';
        if (dragHelpText) dragHelpText.innerText = '💡 ファイル (.txt, .md, .docx) をドロップして読み込めます';
      }, false);
    });

    // 3. ドロップ時のファイル読み込み (FileReader + mammoth.js)
    textarea.addEventListener('drop', function(e) {
      const dt = e.dataTransfer;
      const files = dt.files;

      if (files && files.length > 0) {
        const file = files[0];
        const fileName = file.name.toLowerCase();

        // A. Wordファイル (.docx) の場合
        if (fileName.endsWith('.docx')) {
          const reader = new FileReader();

          reader.onload = function(loadEvent) {
            const arrayBuffer = loadEvent.target.result;

            // mammoth.js で .docx から生テキストを抽出
            mammoth.extractRawText({ arrayBuffer: arrayBuffer })
              .then(function(result) {
                insertTextToArea(result.value);
              })
              .catch(function(err) {
                console.error(err);
                alert('⚠️ .docx ファイルの解析に失敗しました。');
              });
          };

          reader.readAsArrayBuffer(file);

        // B. テキストファイル (.txt, .md など) の場合
        } else if (file.type.startsWith('text/') || fileName.endsWith('.txt') || fileName.endsWith('.md')) {
          const reader = new FileReader();

          reader.onload = function(loadEvent) {
            insertTextToArea(loadEvent.target.result);
          };

          reader.readAsText(file, 'UTF-8');

        // C. 対象外のファイル形式
        } else {
          alert('⚠️ 読み込めるのは .txt, .md, .docx ファイルのみです。');
        }
      }
    }, false);

    // テキストエリアへの挿入共通関数
    function insertTextToArea(text) {
      if (textarea.value.trim() === '') {
        textarea.value = text;
      } else {
        if (confirm('現在の入力内容をドロップしたファイルの内容で上書きしますか？\n（「キャンセル」を押すと既存テキストの末尾に追記されます）')) {
          textarea.value = text;
        } else {
          textarea.value += '\n\n' + text;
        }
      }
    }
  });
</script>

</body>
</html>