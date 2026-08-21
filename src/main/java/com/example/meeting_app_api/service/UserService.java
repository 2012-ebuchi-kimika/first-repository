package com.example.meeting_app_api.service;

import com.example.meeting_app_api.entity.UserPermission;
import com.example.meeting_app_api.mapper.UserPermissionMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class UserService {

    // 役職コードの定数化
    public static final String ROLE_SYSTEM_ADMIN = "R001"; // システム管理者
    public static final String ROLE_GROUP_ADMIN = "R002";  // グループ管理者

    // グループ管理機能を許可するロール一覧
    private static final Set<String> ALLOWED_GROUP_MANAGEMENT_ROLES = Set.of(
            ROLE_SYSTEM_ADMIN,
            ROLE_GROUP_ADMIN
    );

    @Autowired
    private UserPermissionMapper userPermissionMapper;

    /**
     * 指定されたメールアドレスがグループ管理権限を持っているかチェック
     * 
     * @param email ログインユーザーのメールアドレス
     * @return 権限があれば true
     */
    public boolean hasGroupManagementPermission(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }

        List<UserPermission> permissions = userPermissionMapper.findPermissionsByEmail(email.trim());

        // 定数リスト（ALLOWED_GROUP_MANAGEMENT_ROLES）に含まれるロールを持っているか判定
        return permissions.stream()
                .map(UserPermission::getRoleId)
                .anyMatch(ALLOWED_GROUP_MANAGEMENT_ROLES::contains);
    }

    /**
     * 画面のバッジ表示用：指定されたメールアドレスの役職名を取得
     * 
     * @param email ログインユーザーのメールアドレス
     * @return 役職名文字列（例: 「システム管理者, グループ管理者」）
     */
    public String getUserRoleName(String email) {
        if (email == null || email.trim().isEmpty()) {
            return "権限なし";
        }

        List<UserPermission> permissions = userPermissionMapper.findPermissionsByEmail(email.trim());

        if (permissions.isEmpty()) {
            return "一般ユーザー";
        }

        return permissions.stream()
                .map(UserPermission::getRoleName)
                .filter(roleName -> roleName != null && !roleName.isEmpty())
                .distinct()
                .collect(Collectors.joining(", "));
    }
}