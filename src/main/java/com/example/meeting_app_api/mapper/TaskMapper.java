package com.example.meeting_app_api.mapper;

import com.example.meeting_app_api.entity.Task;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import java.util.List;

@Mapper
public interface TaskMapper {

    /**
     * 【SCR-02】ダッシュボード画面用
     * 全てのタスク一覧を取得
     */
    List<Task> findAll();

    /**
     * 【SCR-03】議事録投稿 ＆ AI解析画面用
     * 特定の会議IDに紐付く登録済みタスク一覧を取得
     *
     * @param meetingId 対象の会議ID
     * @return 紐付くタスクのリスト（タスクID降順）
     */
    @Select("SELECT * FROM tasks WHERE meeting_id = #{meetingId} ORDER BY task_id DESC")
    List<Task> findByMeetingId(@Param("meetingId") Long meetingId);

    /**
     * 【SCR-04】タスク詳細・ステータス編集画面用
     * 編集画面の初期表示用に、タスク情報を1件取得
     *
     * @param taskId 対象のタスクID
     * @return タスクエンティティ
     */
    @Select("SELECT * FROM tasks WHERE task_id = #{taskId}")
    Task findById(@Param("taskId") Long taskId);

    /**
     * 【SCR-03】議事録投稿 ＆ AI解析画面用
     * AI解析結果から新規抽出されたタスクをDBへ登録
     *
     * @param meetingId     紐付ける会議ID
     * @param taskContent   タスク内容
     * @param assigneeEmail 担当者メールアドレス
     * @param dueDate       履行期限
     * @param status        ステータス
     */
    @Insert("INSERT INTO tasks (meeting_id, task_content, assignee_email, due_date, status, created_at) " +
            "VALUES (#{meetingId}, #{taskContent}, #{assigneeEmail}, #{dueDate}, #{status}, NOW())")
    void insertTask(@Param("meetingId") Long meetingId,
                    @Param("taskContent") String taskContent,
                    @Param("assigneeEmail") String assigneeEmail,
                    @Param("dueDate") String dueDate,
                    @Param("status") String status);

    /**
     * 【SCR-04】タスク詳細・ステータス編集画面用
     * タスクの内容・担当者・履行期限・ステータスを変更・更新
     *
     * @param taskId        更新対象のタスクID
     * @param taskContent   タスク内容
     * @param assigneeEmail 担当者メールアドレス
     * @param dueDate       履行期限
     * @param status        ステータス
     */
    @Update("UPDATE tasks SET task_content = #{taskContent}, assignee_email = #{assigneeEmail}, " +
            "due_date = #{dueDate}, status = #{status}, updated_at = NOW() " +
            "WHERE task_id = #{taskId}")
    void updateTask(@Param("taskId") Long taskId,
                    @Param("taskContent") String taskContent,
                    @Param("assigneeEmail") String assigneeEmail,
                    @Param("dueDate") String dueDate,
                    @Param("status") String status);
}