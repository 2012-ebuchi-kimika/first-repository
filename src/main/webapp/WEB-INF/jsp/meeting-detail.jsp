<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>📝 議事録投稿 ＆ AI解析 - AI Smart Meeting System</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body style="background-color: #f1f5f9; margin: 0;">

<!-- ヘッダー -->
<div class="navbar">
  <div class="brand-logo">⚡ AI Smart Meeting System</div>
  <div>trainee1405@company.com <span class="user-badge">管理者</span></div>
</div>

<div class="sc03-wrapper">
  <!-- 戻るナビゲーション -->
  <div style="margin-bottom: 16px;">
    <a href="${pageContext.request.contextPath}/dashboard" style="text-decoration: none; color: #0284c7; font-size: 9pt; font-weight: bold; display: inline-flex; align-items: center; gap: 4px;">
      ↩️ ダッシュボードへ戻る
    </a>
  </div>

  <div class="sc03-grid">
    <!-- 【左カラム】入力・AI設定エリア -->
    <div class="sc03-card">
      <h2 style="font-size: 13pt; margin: 0 0 20px 0; color: #0f172a; border-bottom: 2px solid #e2e8f0; padding-bottom: 10px;">
        📝 議事録入力 ＆ AI解析指示
      </h2>

      <form action="${pageContext.request.contextPath}/meetings/analyze" method="POST" onsubmit="return handleAiAnalyze(event)" style="display: flex; flex-direction: column; flex: 1;">
        <!-- 1. 会議選択 -->
        <div class="sc03-form-group">
          <label class="sc03-label">対象の会議 <span style="color: #ef4444;">*</span></label>
          <select name="meetingId" id="meetingSelect" class="sc03-select" required data-testid="meeting-select" onchange="location.href='${pageContext.request.contextPath}/meetings/detail?id=' + this.value;">
            <option value="">対象の会議を選択してください</option>
            <c:forEach var="m" items="${meetings}">
              <option value="${m.meetingId}" ${m.meetingId == selectedMeetingId || m.meetingId == param.id ? 'selected' : ''}>
                <c:out value="${m.startTime}"/> - <c:out value="${m.title}"/>
              </option>
            </c:forEach>
          </select>
        </div>

        <!-- 2. 文字起こしテキスト -->
        <div class="sc03-form-group" style="flex: 1; display: flex; flex-direction: column;">
          <label class="sc03-label">文字起こしテキスト <span style="color: #ef4444;">*</span></label>
          <textarea name="transcript" id="transcriptInput" class="sc03-textarea" style="flex: 1; min-height: 280px;"
                    placeholder="会議の文字起こしテキストを貼り付けてください...&#10;例：&#10;田中: 本日のアジェンダは待機学習の進捗についてです。&#10;佐藤: Day 3のDB設計は完了しました。&#10;田中: 了解です。では次回までにFastAPIの基盤作成をお願いします。（担当: sato@company.com、期限: 8/20）" 
                    required data-testid="transcript-input"></textarea>
        </div>

        <!-- 3. ペルソナ設定 -->
        <div class="sc03-form-group" style="margin-top: 12px;">
          <label class="sc03-label">要約トーン (ペルソナ設定)</label>
          <select name="personaType" id="personaSelect" class="sc03-select" data-testid="persona-select">
            <option value="default">👔 標準（標準的なビジネス要約）</option>
            <option value="tsundere">🎀 ツンデレ秘書（ツンツンしながらしっかり要約）</option>
            <option value="hotblooded">🔥 熱血アニキ（熱く成果を鼓舞）</option>
            <option value="nerv">👁️ NERV司令官（冷徹かつ完結に報告）</option>
          </select>
        </div>

        <!-- AI実行ボタン -->
        <button type="submit" id="aiBtn" class="btn-primary" style="width: 100%; padding: 12px; font-size: 10pt; background-color: #0284c7; margin-top: 8px;" data-testid="ai-summary-btn">
          ✨ Gemini APIで要約・タスクを抽出する
        </button>
      </form>
    </div>

    <!-- 【右カラム】AI解析結果 ＆ 既存タスクエリア (1:1 均等配置) -->
    <div class="sc03-card">
      <h2 style="font-size: 13pt; margin: 0 0 16px 0; color: #0f172a; border-bottom: 2px solid #e2e8f0; padding-bottom: 10px;">
        📊 会議情報 ＆ AI解析結果
      </h2>

      <div style="display: flex; flex-direction: column; flex: 1; gap: 16px; min-height: 0;">
        
        <!-- ① 上部：AI解析ステータス ＆ 結果表示エリア (比率 1) -->
        <div style="flex: 1; min-height: 0; display: flex; flex-direction: column;">
          
          <!-- AI未実行（保存済み要約なし）時の表示 -->
          <div id="emptyPreview" class="sc03-empty-state" style="flex: 1; display: ${empty savedAiSummary ? 'flex' : 'none'}; flex-direction: column; justify-content: center; align-items: center; box-sizing: border-box;">
            <div style="font-size: 22pt; margin-bottom: 6px;">🤖</div>
            <div style="font-weight: bold; font-size: 9.5pt;">AI要約は未生成です</div>
            <div style="font-size: 8.5pt; margin-top: 4px; color: #64748b; text-align: center;">左側から「Gemini APIで要約・タスクを抽出する」を実行するとここに生成結果が表示されます。</div>
          </div>

          <!-- AI実行後、または保存済み要約がある場合の表示エリア -->
          <div id="resultPreviewArea" style="display: ${not empty savedAiSummary ? 'block' : 'none'}; flex: 1; overflow-y: auto; padding-right: 4px; min-height: 0;">
            <!-- AI要約カード -->
            <div style="background-color: #f0f9ff; border: 1px solid #bae6fd; border-radius: 8px; padding: 12px; margin-bottom: 12px;">
              <label id="summaryCardLabel" style="font-size: 8.5pt; font-weight: bold; color: #0369a1; display: block; margin-bottom: 4px;">
                【✨ ${not empty savedAiSummary ? '保存済みのAI要約' : '生成されたAI要約'}】
              </label>
              <div id="previewSummary" style="background: #ffffff; border: 1px solid #e0f2fe; padding: 10px; border-radius: 6px; font-size: 8.5pt; line-height: 1.5; color: #1e293b;"><c:out value="${savedAiSummary}"/></div>
            </div>

            <!-- 今回新しく抽出されたタスクカード -->
            <div id="newTasksContainer" style="background-color: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px; padding: 12px; margin-bottom: 12px; display: none;">
              <label style="font-size: 8.5pt; font-weight: bold; color: #15803d; display: block; margin-bottom: 4px;">【🆕 今回新しく検出されたタスク】</label>
              <div id="previewTasks" style="background: #ffffff; border: 1px solid #dcfce7; padding: 10px; border-radius: 6px; font-size: 8.5pt; color: #1e293b;"></div>
            </div>

            <!-- DB保存フォーム -->
            <form action="${pageContext.request.contextPath}/meetings/save-summary" method="POST">
              <input type="hidden" name="meetingId" id="saveMeetingId" value="<c:out value='${selectedMeetingId}'/>">
              <input type="hidden" name="aiSummary" id="saveAiSummary" value="<c:out value='${savedAiSummary}'/>">
              <input type="hidden" name="taskTitle" id="saveTaskTitle" value="">
              <input type="hidden" name="taskAssignee" id="saveTaskAssignee" value="">
              <input type="hidden" name="taskDueDate" id="saveTaskDueDate" value="">
              
              <button type="submit" id="saveBtn" class="btn-primary" style="width: 100%; background-color: #16a34a; border: none; padding: 10px; font-size: 9pt; display: none;">
                💾 この要約と新タスクをDBに保存する
              </button>
            </form>
          </div>
        </div>

        <!-- ② 下部：この会議の登録済みタスク一覧エリア (比率 1 / 動的ループ表示) -->
        <div style="flex: 1; min-height: 0; background: #fafafa; border: 1px solid #e2e8f0; border-radius: 8px; padding: 14px; display: flex; flex-direction: column; box-sizing: border-box;">
          <div style="font-size: 8.5pt; font-weight: bold; color: #475569; margin-bottom: 10px; display: flex; justify-content: space-between; align-items: center;">
            <span>📌 この会議の登録済みタスク</span>
            <span style="font-size: 7.5pt; background: #e2e8f0; color: #334155; padding: 1px 6px; border-radius: 10px;">
              全 ${empty existingTasks ? 0 : existingTasks.size()} 件
            </span>
          </div>
          
          <!-- タスク表示エリア -->
          <div style="display: flex; flex-direction: column; gap: 8px; overflow-y: auto; padding-right: 2px; flex: 1; min-height: 0;">
            <c:choose>
              <c:when test="${not empty existingTasks}">
                <c:forEach var="task" items="${existingTasks}">
                  <!-- クリックで SCR-04（タスク詳細画面）へ移動 ＆ ホバー演出 -->
                  <div onclick="location.href='${pageContext.request.contextPath}/tasks/detail?id=${task.taskId}'"
                       style="background: #ffffff; border: 1px solid #cbd5e1; padding: 10px 12px; border-radius: 6px; font-size: 8.5pt; display: flex; justify-content: space-between; align-items: center; cursor: pointer; transition: all 0.2s ease;"
                       onmouseover="this.style.backgroundColor='#f8fafc'; this.style.borderColor='#0284c7'; this.style.transform='translateY(-1px)';"
                       onmouseout="this.style.backgroundColor='#ffffff'; this.style.borderColor='#cbd5e1'; this.style.transform='none';">
                    <div>
                      <!-- Task.java の taskContent フィールドを参照 -->
                      <span style="font-weight: bold; color: #1e293b;">・<c:out value="${task.taskContent}"/></span>
                      <span style="font-size: 7.5pt; color: #64748b; margin-left: 6px;">
                        <!-- ★ assigneeName（ユーザー名）を優先表示するよう修正 -->
                        (担当: <c:out value="${empty task.assigneeName ? (empty task.assigneeEmail ? '未割当' : task.assigneeEmail) : task.assigneeName}"/> / 締切: <c:out value="${empty task.dueDate ? '期限なし' : task.dueDate}"/>)
                      </span>
                    </div>
                    <span style="background: ${task.status == 'COMPLETED' ? '#dcfce7' : (task.status == 'IN_PROGRESS' ? '#fef3c7' : '#f1f5f9')}; 
                                 color: ${task.status == 'COMPLETED' ? '#15803d' : (task.status == 'IN_PROGRESS' ? '#d97706' : '#64748b')}; 
                                 font-size: 7pt; font-weight: bold; padding: 2px 8px; border-radius: 4px;">
                      <c:out value="${empty task.status ? 'TODO' : task.status}"/>
                    </span>
                  </div>
                </c:forEach>
              </c:when>
              <c:otherwise>
                <div style="color: #94a3b8; font-size: 8.5pt; text-align: center; margin-top: 20px;">
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
  function handleAiAnalyze(event) {
    event.preventDefault();
    
    const meetingId = document.getElementById('meetingSelect').value;
    const persona = document.getElementById('personaSelect').value;
    const btn = document.getElementById('aiBtn');
    
    if (!meetingId) {
      alert("対象の会議を選択してください。");
      return false;
    }

    btn.innerText = '⏳ Gemini AIで解析中...';
    btn.disabled = true;

    setTimeout(() => {
      let mockSummary = "";
      if (persona === 'tsundere') {
        mockSummary = "べ、別にあなたのためにまとめたわけじゃないんだからね！Day 3のDB設計が終わったからって調子に乗らないでよ？次回までにFastAPIの基盤作成を終わらせなさいよね！";
      } else if (persona === 'hotblooded') {
        mockSummary = "素晴らしい進捗だ！Day 3のDB設計完了おめでとう！この熱量のまま次のFastAPI基盤作成も限界突破で突き進もうぜ！！";
      } else if (persona === 'nerv') {
        mockSummary = "状況報告。DB設計フェーズ完了。ただちにFastAPIの基盤作成フェーズへと移行せよ。";
      } else {
        mockSummary = "会議にてDay 3のDB設計完了が確認されました。次回までにFastAPIの基盤作成を実施予定です。";
      }

      const mockTask = {
        title: "FastAPIの基盤作成",
        assignee: "sato@company.com",
        dueDate: "2026-08-20"
      };

      const mockTaskHtml = `
        <div style="display: flex; justify-content: space-between; align-items: center; padding: 6px 0;">
          <div><b>・\${mockTask.title}</b> <span style="color: #64748b;">(AI自動抽出)</span></div>
          <span style="background-color: #dcfce7; color: #15803d; padding: 2px 8px; border-radius: 4px; font-size: 7.5pt; font-weight: bold;">
            担当: \${mockTask.assignee} / 期限: \${mockTask.dueDate}
          </span>
        </div>
      `;

      // プレビュー表示制御の切替
      document.getElementById('emptyPreview').style.display = 'none';
      document.getElementById('resultPreviewArea').style.display = 'block';
      
      // 新規抽出タスクエリアと保存ボタンを表示
      document.getElementById('newTasksContainer').style.display = 'block';
      document.getElementById('saveBtn').style.display = 'block';

      // プレビュー表示内容の更新
      document.getElementById('summaryCardLabel').innerText = '【✨ 生成されたAI要約】';
      document.getElementById('previewSummary').innerText = mockSummary;
      document.getElementById('previewTasks').innerHTML = mockTaskHtml;

      // DB保存フォーム用 hidden フィールドに値をセット
      document.getElementById('saveMeetingId').value = meetingId;
      document.getElementById('saveAiSummary').value = mockSummary;
      document.getElementById('saveTaskTitle').value = mockTask.title;
      document.getElementById('saveTaskAssignee').value = mockTask.assignee;
      document.getElementById('saveTaskDueDate').value = mockTask.dueDate;

      btn.innerText = '✨ Gemini APIで要約・タスクを抽出する';
      btn.disabled = false;
    }, 1000);

    return false;
  }
</script>

</body>
</html>