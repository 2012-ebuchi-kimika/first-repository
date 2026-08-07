package com.example.meeting_app_api.mapper;

import com.example.meeting_app_api.entity.Meeting;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface MeetingMapper {

    // 会議一覧の取得
    List<Meeting> findAll(@Param("keyword") String keyword, @Param("showAll") boolean showAll);

    // 新規会議の登録（発番された ID を Meeting オブジェクトに保持する）
    void insert(Meeting meeting);
}