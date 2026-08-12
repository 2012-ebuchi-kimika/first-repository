package com.example.meeting_app_api.controller;

import com.example.meeting_app_api.entity.Task;
import com.example.meeting_app_api.entity.User;
import com.example.meeting_app_api.mapper.TaskMapper;
import com.example.meeting_app_api.mapper.UserMapper;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

@Controller
public class TaskController {

    private final TaskMapper taskMapper;
    private final UserMapper userMapper;

    public TaskController(TaskMapper taskMapper, UserMapper userMapper) {
        this.taskMapper = taskMapper;
        this.userMapper = userMapper;
    }

    /**
     * 【SCR-02】ダッシュボード画面用 API
     * タスク一覧をJSON形式で取得
     */
    @GetMapping("/api/tasks")
    @ResponseBody
    public List<Task> getTasks() {
        return taskMapper.findAll();
    }

    /**
     * 【SCR-04】タスク詳細・ステータス編集画面を表示するハンドラメソッド
     * 選択されたタスクの情報および各ユーザーの未完了タスク数を計算して画面（task-detail.jsp）に引き渡す
     *
     * @param taskId 編集対象のタスクID
     * @param model  画面引き渡し用モデル
     * @return タスク詳細画面 (task-detail.jsp)
     */
    @GetMapping("/tasks/detail")
    public String showTaskDetail(@RequestParam("id") Long taskId, Model model) {
        Task task = taskMapper.findById(taskId);
        model.addAttribute("task", task);

        // 全タスクと全ユーザーを取得
        List<Task> allTasks = taskMapper.findAll();
        List<User> users = userMapper.findAll();

        // 各ユーザーの未完了タスク件数をカウントして User にセット
        for (User u : users) {
            long pendingCount = allTasks.stream()
                    .filter(t -> t.getAssigneeEmail() != null && t.getAssigneeEmail().toLowerCase().contains(u.getEmail().toLowerCase()))
                    .filter(t -> !"COMPLETED".equalsIgnoreCase(t.getStatus()))
                    .count();
            u.setPendingTaskCount((int) pendingCount);
        }

        model.addAttribute("users", users);

        return "task-detail";
    }

    /**
     * 【SCR-04】タスク詳細・ステータス編集画面の変更保存処理
     * フォームから受け取った内容（ステータス・期限・担当・タスク内容）をDBに反映
     *
     * @param taskId        タスクID
     * @param taskContent   タスク内容
     * @param assigneeEmail 担当者メールアドレス
     * @param dueDate       履行期限
     * @param status        ステータス
     * @return ダッシュボード画面へのリダイレクト
     */
    @PostMapping("/tasks/update")
    public String updateTask(
            @RequestParam("taskId") Long taskId,
            @RequestParam("taskContent") String taskContent,
            @RequestParam(name = "assigneeEmail", required = false) String assigneeEmail,
            @RequestParam(name = "dueDate", required = false) String dueDate,
            @RequestParam("status") String status) {

        // 締切の日付が空文字の場合は null に変換（DBで NULL として保持）
        if (dueDate != null && dueDate.trim().isEmpty()) {
            dueDate = null;
        }

        taskMapper.updateTask(taskId, taskContent, assigneeEmail, dueDate, status);

        // 更新後は【SCR-02】ダッシュボード画面へ遷移
        return "redirect:/dashboard";
    }
}