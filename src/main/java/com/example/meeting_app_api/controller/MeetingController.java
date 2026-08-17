package com.example.meeting_app_api.controller;

import com.example.meeting_app_api.entity.Meeting;
import com.example.meeting_app_api.entity.Task;
import com.example.meeting_app_api.entity.User;
import com.example.meeting_app_api.service.GoogleCalendarService;
import com.example.meeting_app_api.service.MeetingService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Controller
public class MeetingController {

    private final MeetingService meetingService;
    private final GoogleCalendarService googleCalendarService;

    // コンストラクタインジェクション（推奨される書き方）
    public MeetingController(MeetingService meetingService, GoogleCalendarService googleCalendarService) {
        this.meetingService = meetingService;
        this.googleCalendarService = googleCalendarService;
    }

    // 1. 議事録投稿＆AI解析画面の表示
    @GetMapping("/meetings/detail")
    public String showMeetingDetail(
            @RequestParam(name = "id", required = false) Long meetingId,
            Model model) {

        List<Meeting> meetings = meetingService.getAllMeetings(null, true);

        // IDが指定されていない場合はリストの先頭の会議IDを初期選択
        if (meetingId == null && !meetings.isEmpty()) {
            meetingId = meetings.get(0).getMeetingId() != null 
                    ? meetings.get(0).getMeetingId().longValue() 
                    : null;
        }

        // 保存済み要約と既存タスクの取得
        String savedAiSummary = meetingService.getSavedAiSummary(meetingId, meetings);
        List<User> users = meetingService.getAllUsers();
        List<Task> existingTasks = meetingService.getExistingTasksForMeeting(meetingId, users);

        model.addAttribute("meetings", meetings);
        model.addAttribute("selectedMeetingId", meetingId);
        model.addAttribute("savedAiSummary", savedAiSummary);
        model.addAttribute("existingTasks", existingTasks);

        return "meeting-detail";
    }

    // 2. 新規会議作成
    @PostMapping("/meetings/create")
    public String createMeeting(
            @ModelAttribute Meeting meeting,
            @RequestParam(name = "attendeeEmails", required = false) String attendeeEmails,
            @RequestParam(name = "actionType", defaultValue = "saveOnly") String actionType) {

        if (attendeeEmails != null) {
            meeting.setAttendeeEmails(attendeeEmails);
        }

        // 1. Google カレンダーへ登録し eventId を取得
        String googleEventId = googleCalendarService.createGoogleEvent(meeting);
        meeting.setGoogleEventId(googleEventId);

        // 2. DBへ保存
        Integer newMeetingId = meetingService.createMeeting(meeting);

        if ("goToDetail".equals(actionType)) {
            return "redirect:/meetings/detail?id=" + newMeetingId;
        } else {
            return "redirect:/dashboard";
        }
    }

    // 3. 会議の編集・更新処理（追加）
    @PostMapping("/meetings/update")
    public String updateMeeting(
            @ModelAttribute Meeting meeting,
            @RequestParam(name = "attendeeEmails", required = false) String attendeeEmails) {

        if (attendeeEmails != null) {
            meeting.setAttendeeEmails(attendeeEmails);
        }

        // DBの更新処理
        meetingService.updateMeeting(meeting);

        return "redirect:/dashboard";
    }

    // 4. 会議の削除処理（追加）
    @PostMapping("/meetings/delete")
    public String deleteMeeting(@RequestParam("meetingId") Integer meetingId) {

        // DBからの削除処理
        meetingService.deleteMeeting(meetingId);

        return "redirect:/dashboard";
    }

    // 5. Gemini API非同期解析 (Fetch API用)
    @PostMapping("/meetings/analyze")
    @ResponseBody
    public Map<String, Object> analyzeTranscript(
            @RequestParam("meetingId") Long meetingId,
            @RequestParam("transcript") String transcript,
            @RequestParam(name = "personaType", defaultValue = "default") String personaType) {

        return meetingService.analyzeTranscript(meetingId, transcript, personaType);
    }

    // 6. 要約とタスクのDB保存
    @PostMapping("/meetings/save-summary")
    public String saveSummaryAndTasks(
            @RequestParam("meetingId") Long meetingId,
            @RequestParam("aiSummary") String aiSummary,
            @RequestParam(name = "taskTitle", required = false) String taskTitle,
            @RequestParam(name = "taskAssignee", required = false) String taskAssignee,
            @RequestParam(name = "taskDueDate", required = false) String taskDueDate) {

        meetingService.saveSummaryAndTasks(meetingId, aiSummary, taskTitle, taskAssignee, taskDueDate);

        return "redirect:/meetings/detail?id=" + meetingId;
    }
}