package com.example.meeting_app_api.mapper;

import com.example.meeting_app_api.entity.Group;
import com.example.meeting_app_api.entity.GroupMember;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface GroupMapper {
    List<Group> findAllGroups();
    List<GroupMember> findAllGroupMembers();
}