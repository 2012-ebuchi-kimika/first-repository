package com.example.meeting_app_api.mapper;

import com.example.meeting_app_api.entity.Group;
import com.example.meeting_app_api.entity.GroupMember;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface GroupMapper {

    List<Group> findAllGroups();
    List<GroupMember> findAllGroupMembers();

    // ★ 修正箇所: SQL に owner_user_id を追加
    @Insert("INSERT INTO groups (group_name, owner_user_id, created_at) VALUES (#{groupName}, #{ownerUserId}, NOW())")
    @Options(useGeneratedKeys = true, keyProperty = "groupId")
    void insertGroup(Group group);

    @Update("UPDATE groups SET group_name = #{groupName} WHERE group_id = #{groupId}")
    void updateGroup(Group group);

    @Delete("DELETE FROM groups WHERE group_id = #{groupId}")
    void deleteGroup(@Param("groupId") Integer groupId);

    @Insert("INSERT INTO group_members (group_id, user_email) VALUES (#{groupId}, #{userEmail})")
    void insertGroupMember(@Param("groupId") Integer groupId, @Param("userEmail") String userEmail);

    @Delete("DELETE FROM group_members WHERE group_id = #{groupId}")
    void deleteGroupMembersByGroupId(@Param("groupId") Integer groupId);
}