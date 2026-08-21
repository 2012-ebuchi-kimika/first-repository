package com.example.meeting_app_api.mapper;

import com.example.meeting_app_api.entity.UserPermission;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface UserPermissionMapper {

    /**
     * Viewから指定アドレスの権限情報を取得
     */
    List<UserPermission> findPermissionsByEmail(String email);
}