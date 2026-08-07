package com.example.meeting_app_api.mapper;

import com.example.meeting_app_api.entity.User;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface UserMapper {
    List<User> findAll();
}