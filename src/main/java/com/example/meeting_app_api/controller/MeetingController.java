package com.example.meeting_app_api.controller;

import com.example.meeting_app_api.entity.Meeting;
import com.example.meeting_app_api.mapper.MeetingMapper;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

@Controller
public class MeetingController {

    private final MeetingMapper meetingMapper;

    // 推奨されるコンストラクタ注入
    public MeetingController(MeetingMapper meetingMapper) {
        this.meetingMapper = meetingMapper;
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

        // 1. DBに会議を新規登録（MeetingMapperを使用）
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