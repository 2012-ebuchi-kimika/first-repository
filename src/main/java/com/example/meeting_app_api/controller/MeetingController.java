package com.example.meeting_app_api.controller;

import com.example.meeting_app_api.entity.Meeting;
import com.example.meeting_app_api.mapper.MeetingMapper;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

@Controller
public class MeetingController {

    private final MeetingMapper meetingMapper;

    // コンストラクタ注入
    public MeetingController(MeetingMapper meetingMapper) {
        this.meetingMapper = meetingMapper;
    }

    // 議事録AI生成画面（SCR-03）を表示するハンドラメソッド
    @GetMapping("/meetings/detail")
    public String showMeetingDetail(
            @RequestParam(name = "id", required = false) Long id, 
            Model model) {
        
        // 画面の会議ドロップダウン選択肢用として会議一覧を取得
        List<Meeting> meetings = meetingMapper.findAll(null, true);
        model.addAttribute("meetings", meetings);
        
        // URLパラメータで渡された対象の会議IDを画面へセット
        model.addAttribute("selectedMeetingId", id);

        return "meeting-detail";
    }

    // AI要約・タスクのDB保存処理ハンドラ
    @PostMapping("/meetings/save-summary")
    public String saveSummary(
            @RequestParam("meetingId") Long meetingId,
            @RequestParam("aiSummary") String aiSummary,
            @RequestParam(name = "extractedTasksJson", required = false) String extractedTasksJson) {

        // 会議テーブルの aiSummary を更新
        meetingMapper.updateAiSummary(meetingId, aiSummary);

        // 保存完了後、該当の会議詳細へリダイレクト
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

        // 1. DBに会議を新規登録
        meetingMapper.insert(meeting);

        // 2. 押されたボタンに応じて遷移先を制御
        if ("goToDetail".equals(actionType)) {
            // 「保存して要約作成へ」が押された場合
            return "redirect:/meetings/detail?id=" + meeting.getMeetingId();
        } else {
            // 「保存する」が押された場合（ダッシュボードに戻る）
            return "redirect:/dashboard";
        }
    }
}