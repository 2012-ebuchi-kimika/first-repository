package com.example.meeting_app_api.service.common;

import com.example.meeting_app_api.entity.Task;
import com.example.meeting_app_api.entity.User;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

public class TaskUtils {

    /**
     * 担当者メールアドレスを名前（カンマ区切り）に変換して Task にセットする
     */
    public static void populateAssigneeNames(List<Task> tasks, List<User> users) {
        if (tasks == null || users == null) return;

        for (Task task : tasks) {
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
        }
    }

    /**
     * 締切日（dueDate）から緊急度（dueUrgency）を計算して Task にセットする
     */
    public static void calculateDueUrgency(List<Task> tasks) {
        if (tasks == null) return;

        LocalDate today = LocalDate.now();

        for (Task task : tasks) {
            if (task.getDueDate() != null) {
                long daysLeft = ChronoUnit.DAYS.between(today, task.getDueDate());
                if (daysLeft <= 10) {
                    task.setDueUrgency("DANGER");  // 10日以内
                } else if (daysLeft <= 30) {
                    task.setDueUrgency("WARNING"); // 11〜30日以内
                } else {
                    task.setDueUrgency("SAFE");    // 31日以上先
                }
            } else {
                task.setDueUrgency("NONE");
            }
        }
    }

    /**
     * 各ユーザーの未完了タスク数をカウントして User にセットする
     */
    public static void calculatePendingTasksForUsers(List<User> users, List<Task> allTasks) {
        if (users == null || allTasks == null) return;

        for (User u : users) {
            long pendingCount = allTasks.stream()
                    .filter(t -> t.getAssigneeEmail() != null && t.getAssigneeEmail().toLowerCase().contains(u.getEmail().toLowerCase()))
                    .filter(t -> !"COMPLETED".equalsIgnoreCase(t.getStatus()))
                    .count();
            u.setPendingTaskCount((int) pendingCount);
        }
    }
}