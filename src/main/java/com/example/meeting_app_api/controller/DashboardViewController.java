package com.example.meeting_app_api.controller;

import com.example.meeting_app_api.entity.Meeting;
import com.example.meeting_app_api.mapper.MeetingMapper;
import com.example.meeting_app_api.mapper.TaskMapper;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
public class DashboardViewController {

    private final MeetingMapper meetingMapper;
    private final TaskMapper taskMapper;

    public DashboardViewController(MeetingMapper meetingMapper, TaskMapper taskMapper) {
        this.meetingMapper = meetingMapper;
        this.taskMapper = taskMapper;
    }

    @GetMapping("/dashboard")
    public String showDashboard(
            @RequestParam(name = "keyword", required = false) String keyword,
            @RequestParam(name = "showAll", required = false, defaultValue = "false") boolean showAll,
            Model model) {

        // DBから検索結果を取得（showAll フラグも渡す）
        List<Meeting> meetings = meetingMapper.findAll(keyword, showAll);
        
        // Model に渡す
        model.addAttribute("meetings", meetings);
        model.addAttribute("tasks", taskMapper.findAll());
        model.addAttribute("keyword", keyword);
        model.addAttribute("showAll", showAll);

        return "dashboard";
    }
}