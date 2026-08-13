package com.example.meeting_app_api.controller;

import com.example.meeting_app_api.entity.Meeting;
import com.example.meeting_app_api.entity.Task;
import com.example.meeting_app_api.entity.User;
import com.example.meeting_app_api.mapper.MeetingMapper;
import com.example.meeting_app_api.mapper.TaskMapper;
import com.example.meeting_app_api.mapper.UserMapper;
import com.example.meeting_app_api.service.AiService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Controller
public class MeetingController {

    private final MeetingMapper meetingMapper;
    private final TaskMapper taskMapper;
    private final UserMapper userMapper;
    private final AiService aiService;

    // AiService をコンストラクタ注入
    public MeetingController(MeetingMapper meetingMapper, TaskMapper taskMapper, UserMapper userMapper, AiService aiService) {
        this.meetingMapper = meetingMapper;
        this.taskMapper = taskMapper;
        this.userMapper = userMapper;
        this.aiService = aiService;
    }

    // 【SCR-03】議事録AI生成画面を表示するハンドラメソッド
    @GetMapping("/meetings/detail")
    public String showMeetingDetail(
            @RequestParam(name = "id", required = false) Long id, 
            Model model) {
        
        // 1. 画面の会議ドロップダウン選択肢用として会議一覧を取得
        List<Meeting> meetings = meetingMapper.findAll(null, true);
        model.addAttribute("meetings", meetings);
        
        // 2. URLパラメータで渡された対象の会議IDを画面へセット
        model.addAttribute("selectedMeetingId", id);

        // 3. モーダル等で使用する全ユーザー情報を取得
        List<User> users = userMapper.findAll();
        model.addAttribute("users", users);

        // 4. 対象の会議IDが選択されている場合、保存済みAI要約の取得および既存タスク一覧を取得
        if (id != null) {
            meetings.stream()
                    .filter(m -> m.getMeetingId() != null && m.getMeetingId().longValue() == id)
                    .findFirst()
                    .ifPresent(m -> model.addAttribute("savedAiSummary", m.getAiSummary()));

            List<Task> existingTasks = taskMapper.findByMeetingId(id);

            for (Task task : existingTasks) {
                String assigneeEmail = task.getAssigneeEmail();
                if (assigneeEmail != null && !assigneeEmail.trim().isEmpty()) {
                    String[] emails = assigneeEmail.split(",");
                    List<String> names = new ArrayList<>();

                    for (String email : emails) {
                        String trimmedEmail = email.trim();
                        if (!trimmedEmail.isEmpty()) {
                            String name = users.stream()
                                    .filter(u -> trimmedEmail.equalsIgnoreCase(u.getEmail()))
                                    .map(User::getName)
                                    .findFirst()
                                    .orElse(trimmedEmail);
                            names.add(name);
                        }
                    }
                    task.setAssigneeName(String.join(", ", names));
                } else {
                    task.setAssigneeName("未割当");
                }
            }

            model.addAttribute("existingTasks", existingTasks);
        }

        return "meeting-detail";
    }

    // 選択された会議IDから開催日を取得してAiServiceへ渡す
    @PostMapping("/meetings/analyze")
    @ResponseBody
    public Map<String, Object> analyzeMeeting(
            @RequestParam(name = "meetingId", required = false) Long meetingId,
            @RequestParam("transcript") String transcript,
            @RequestParam(name = "personaType", defaultValue = "default") String personaType) {
        
        // 選択された会議の開催日（YYYY-MM-DD）を取得
        String meetingDate = LocalDate.now().toString(); // デフォルト（現在日付）
        if (meetingId != null) {
            List<Meeting> meetings = meetingMapper.findAll(null, true);
            Meeting meeting = meetings.stream()
                    .filter(m -> m.getMeetingId() != null && m.getMeetingId().equals(meetingId))
                    .findFirst()
                    .orElse(null);

            if (meeting != null && meeting.getStartTime() != null) {
                String rawTime = meeting.getStartTime().toString();
                meetingDate = rawTime.split("T")[0].split(" ")[0];
            }
        }
        
        // AiService（Gemini API呼び出し）を実行（第3引数に動的開催日を渡す）
        return aiService.analyzeTranscript(transcript, personaType, meetingDate);
    }

    // AI要約 ＆ 抽出タスクのDB保存処理ハンドラ
    @PostMapping("/meetings/save-summary")
    public String saveSummary(
            @RequestParam("meetingId") Long meetingId,
            @RequestParam("aiSummary") String aiSummary,
            @RequestParam(name = "taskTitle", required = false) String taskTitle,
            @RequestParam(name = "taskAssignee", required = false) String taskAssignee,
            @RequestParam(name = "taskDueDate", required = false) String taskDueDate) {

        // 1. 会議テーブル（meetings）の ai_summary を更新
        meetingMapper.updateAiSummary(meetingId, aiSummary);

        // 2. 抽出された複数タスクをスラッシュ(/)で分割し、1件ずつ分解してDB登録
        if (taskTitle != null && !taskTitle.trim().isEmpty()) {
            String[] titles = taskTitle.split("\\s*/\\s*|\\s*\\\\\\s*");
            String[] assignees = (taskAssignee != null) ? taskAssignee.split("\\s*/\\s*|\\s*\\\\\\s*") : new String[0];
            String[] dueDates = (taskDueDate != null) ? taskDueDate.split("\\s*/\\s*|\\s*\\\\\\s*") : new String[0];

            for (int i = 0; i < titles.length; i++) {
                String content = titles[i].trim();
                if (content.isEmpty()) continue;

                String assignee = (i < assignees.length) ? assignees[i].trim() : "";
                String dueDate = (i < dueDates.length) ? dueDates[i].trim() : "";

                // YYYY-MM-DD フォーマットチェック（不正な文字列の場合は空にしてMySQLエラー回避）
                if (!dueDate.matches("\\d{4}-\\d{2}-\\d{2}")) {
                    dueDate = null;
                }

                // 分割した1件ごとのタスクを insert
                taskMapper.insertTask(meetingId, content, assignee, dueDate, "TODO");
            }
        }

        // 3. 保存完了後、該当の会議詳細へリダイレクト
        return "redirect:/meetings/detail?id=" + meetingId;
    }

    // JSONで一覧取得が必要な場合用のAPIエンドポイント
    @GetMapping("/api/meetings")
    @ResponseBody
    public List<Meeting> getMeetings(
            @RequestParam(required = false) String keyword,
            @RequestParam(name = "showAll", required = false, defaultValue = "false") boolean showAll) {
        return meetingMapper.findAll(keyword, showAll);
    }

    // モーダルからの会議作成処理
    @PostMapping("/meetings/create")
    public String createMeeting(
            @ModelAttribute Meeting meeting,
            @RequestParam(name = "actionType", defaultValue = "saveOnly") String actionType) {

        // ★【修正】personaType が null または空文字の場合、初期値 "default" を自動補完する
        if (meeting.getPersonaType() == null || meeting.getPersonaType().trim().isEmpty()) {
            meeting.setPersonaType("default");
        }

        meetingMapper.insert(meeting);

        if ("goToDetail".equals(actionType)) {
            return "redirect:/meetings/detail?id=" + meeting.getMeetingId();
        } else {
            return "redirect:/dashboard";
        }
    }
}