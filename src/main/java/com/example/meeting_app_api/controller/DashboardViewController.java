package com.example.meeting_app_api.controller;

import com.example.meeting_app_api.entity.Group;
import com.example.meeting_app_api.entity.GroupMember;
import com.example.meeting_app_api.entity.Meeting;
import com.example.meeting_app_api.entity.Task;
import com.example.meeting_app_api.entity.User;
import com.example.meeting_app_api.mapper.GroupMapper;
import com.example.meeting_app_api.mapper.MeetingMapper;
import com.example.meeting_app_api.mapper.TaskMapper;
import com.example.meeting_app_api.mapper.UserMapper;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

@Controller
public class DashboardViewController {

    private final MeetingMapper meetingMapper;
    private final TaskMapper taskMapper;
    private final UserMapper userMapper;
    private final GroupMapper groupMapper;

    public DashboardViewController(
            MeetingMapper meetingMapper, 
            TaskMapper taskMapper, 
            UserMapper userMapper, 
            GroupMapper groupMapper) {
        this.meetingMapper = meetingMapper;
        this.taskMapper = taskMapper;
        this.userMapper = userMapper;
        this.groupMapper = groupMapper;
    }

    @GetMapping("/dashboard")
    public String showDashboard(
            @RequestParam(name = "keyword", required = false) String keyword,
            @RequestParam(name = "showAll", required = false, defaultValue = "false") boolean showAll,
            Model model) {

        // 1. 会議一覧を取得
        List<Meeting> meetings = meetingMapper.findAll(keyword, showAll);
        model.addAttribute("meetings", meetings);

        // 2. ユーザー一覧を取得
        List<User> users = userMapper.findAll();
        model.addAttribute("users", users);

        // 3. タスク一覧を取得し、氏名変換 ＆ 締切緊急度の判定をセット
        List<Task> tasks = taskMapper.findAll();
        LocalDate today = LocalDate.now();

        for (Task task : tasks) {
            // --- A. 担当者メールアドレスから氏名への変換 ---
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
                task.setAssigneeName("未設定");
            }

            // --- B. 締切緊急度（dueUrgency）の判定処理 ---
            if (task.getDueDate() != null) {
                // 現在日付から締切日までの残り日数を計算
                long daysLeft = ChronoUnit.DAYS.between(today, task.getDueDate());
                
                if (daysLeft <= 10) {
                    task.setDueUrgency("DANGER");  // 10日以内（赤色）
                } else if (daysLeft <= 30) {
                    task.setDueUrgency("WARNING"); // 11〜30日以内（黄色）
                } else {
                    task.setDueUrgency("SAFE");    // 31日以上先（緑色）
                }
            } else {
                task.setDueUrgency("NONE"); // 期限なし（グレー）
            }
        }
        model.addAttribute("tasks", tasks);

        // 4. 検索条件の保持
        model.addAttribute("keyword", keyword);
        model.addAttribute("showAll", showAll);

        // 5. 招待グループ管理モーダル用
        List<Group> groups = groupMapper.findAllGroups();
        List<GroupMember> groupMembers = groupMapper.findAllGroupMembers();

        for (Group group : groups) {
            StringBuilder membersSb = new StringBuilder();
            for (GroupMember gm : groupMembers) {
                if (group.getGroupId() != null && group.getGroupId().equals(gm.getGroupId())) {
                    if (membersSb.length() > 0) {
                        membersSb.append(", ");
                    }
                    membersSb.append(gm.getUserEmail());
                }
            }
            group.setMembers(membersSb.toString());
        }
        
        model.addAttribute("groups", groups);

        return "dashboard";
    }
}