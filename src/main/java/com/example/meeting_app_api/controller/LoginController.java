package com.example.meeting_app_api.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class LoginController {

    /**
     * ログイン画面の表示
     */
    @GetMapping("/login")
    public String showLoginPage(HttpSession session) {
        // すでにログイン済みの場合はダッシュボードへリダイレクト
        if (session.getAttribute("loginEmail") != null) {
            return "redirect:/dashboard";
        }
        return "login"; // login.jsp を表示
    }

    /**
     * ログイン処理（セッションにメールアドレスを保存）
     */
    @PostMapping("/login")
    public String login(
            @RequestParam(name = "email", required = false) String email,
            HttpSession session,
            Model model) {

        if (email == null || email.trim().isEmpty()) {
            model.addAttribute("errorMessage", "メールアドレスを入力してください。");
            return "login";
        }

        // セッションにログイン情報（メールアドレス）を保持
        session.setAttribute("loginEmail", email.trim());

        // ダッシュボード画面へリダイレクト
        return "redirect:/dashboard";
    }

    /**
     * ログアウト処理
     */
    @GetMapping("/logout")
    public String logout(HttpSession session) {
        // セッションを破棄
        session.invalidate();
        return "redirect:/login";
    }
}