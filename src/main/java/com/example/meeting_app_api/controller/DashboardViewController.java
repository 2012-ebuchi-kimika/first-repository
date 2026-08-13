package com.example.meeting_app_api.controller;

import com.example.meeting_app_api.entity.Group;
import com.example.meeting_app_api.entity.Meeting;
import com.example.meeting_app_api.entity.Task;
import com.example.meeting_app_api.entity.User;
import com.example.meeting_app_api.service.DashboardService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
public class DashboardViewController {

    private final DashboardService dashboardService;

    public DashboardViewController(DashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    @GetMapping("/dashboard")
    public String showDashboard(
            @RequestParam(name = "keyword", required = false) String keyword,
            @RequestParam(name = "showAll", required = false, defaultValue = "false") boolean showAll,
            Model model) {

        // 1. 会議一覧
        List<Meeting> meetings = dashboardService.getDashboardMeetings(keyword, showAll);
        model.addAttribute("meetings", meetings);

        // 2. ユーザー一覧
        List<User> users = dashboardService.getAllUsers();
        model.addAttribute("users", users);

        // 3. タスク一覧（氏名変換・緊急度計算はService内で自動実行）
        List<Task> tasks = dashboardService.getDashboardTasks(users);
        model.addAttribute("tasks", tasks);

        // 4. 検索条件の保持
        model.addAttribute("keyword", keyword);
        model.addAttribute("showAll", showAll);

        // 5. 招待グループ一覧
        List<Group> groups = dashboardService.getDashboardGroups();
        model.addAttribute("groups", groups);

        return "dashboard";
    }
}