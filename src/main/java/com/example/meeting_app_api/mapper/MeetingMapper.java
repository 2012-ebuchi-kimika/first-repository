package com.example.meeting_app_api.mapper;

import com.example.meeting_app_api.entity.Meeting;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface MeetingMapper {

    // 会議一覧の取得
    List<Meeting> findAll(@Param("keyword") String keyword, @Param("showAll") boolean showAll);

    // IDによる会議1件の取得（編集・削除時の参照用）
    Meeting findById(@Param("meetingId") Integer meetingId);

    // 新規登録
    void insert(Meeting meeting);

    // 会議情報の更新（編集用）
    void update(Meeting meeting);

    // 会議の削除
    void deleteById(@Param("meetingId") Integer meetingId);

    // 対象の会議IDのAI要約文（ai_summary）を更新
    @Update("UPDATE meetings SET ai_summary = #{aiSummary} WHERE meeting_id = #{meetingId}")
    void updateAiSummary(@Param("meetingId") Long meetingId, @Param("aiSummary") String aiSummary);
}