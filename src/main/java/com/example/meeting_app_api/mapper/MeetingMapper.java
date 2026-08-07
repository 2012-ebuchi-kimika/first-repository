package com.example.meeting_app_api.mapper;

import com.example.meeting_app_api.entity.Meeting;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface MeetingMapper {

    List<Meeting> findAll(@Param("keyword") String keyword, @Param("showAll") boolean showAll);

    void insert(Meeting meeting);

    // 対象の会議IDのAI要約文（ai_summary）を更新
    @Update("UPDATE meetings SET ai_summary = #{aiSummary} WHERE meeting_id = #{meetingId}")
    void updateAiSummary(@Param("meetingId") Long meetingId, @Param("aiSummary") String aiSummary);
}