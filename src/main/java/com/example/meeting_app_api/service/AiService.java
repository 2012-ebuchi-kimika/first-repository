package com.example.meeting_app_api.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class AiService {

    @Value("${gemini.api.key}")
    private String apiKey;

    @Value("${gemini.api.url}")
    private String apiUrl;

    /**
     * Gemini APIを呼び出して文字起こしテキストから要約とタスクを抽出する
     */
    public Map<String, Object> analyzeTranscript(String transcript, String personaType) {
        Map<String, Object> result = new HashMap<>();

        try {
            // ペルソナに応じたトーン指定
            String tonePrompt;
            if ("tsundere".equals(personaType)) {
                tonePrompt = "ツンデレ秘書風の口調（ツンツンしながらも仕事は完璧に要約）で出力してください。";
            } else if ("hotblooded".equals(personaType)) {
                tonePrompt = "熱血アニキ風の口調（情熱的で成果を激しく鼓舞するスタイル）で出力してください。";
            } else if ("nerv".equals(personaType)) {
                tonePrompt = "NERV司令官風の口調（冷徹・簡潔・報告書スタイル）で出力してください。";
            } else {
                tonePrompt = "標準的なビジネススタイルの丁寧かつ簡潔な口調で出力してください。";
            }

            // Geminiへのプロンプト設定
            String promptText = "以下の「会議の文字起こしテキスト」を分析し、指定されたトーンで要約を作成し、テキスト内に記載されている決定事項やタスク（アクションアイテム）を抽出してください。\\n\\n"
                    + "【要約のトーン】\\n" + tonePrompt + "\\n\\n"
                    + "【会議の文字起こしテキスト】\\n" + escapeJson(transcript) + "\\n\\n"
                    + "【出力フォーマット】\\n"
                    + "以下の形式に従ったJSON文字列のみを出力してください（```json 等のMarkdown文言は一切含めないでください）。\\n"
                    + "{\\n"
                    + "  \\\"summary\\\": \\\"要約内容\\\",\\n"
                    + "  \\\"taskTitle\\\": \\\"タスク内容\\\",\\n"
                    + "  \\\"taskAssignee\\\": \\\"担当者\\\",\\n"
                    + "  \\\"taskDueDate\\\": \\\"期限YYYY-MM-DD\\\"\\n"
                    + "}";

            // JSONリクエストボディ構築
            String jsonInputString = "{\"contents\": [{\"parts\": [{\"text\": \"" + promptText + "\"}]}]}";

            // HTTP接続設定
            URL url = new URL(apiUrl + "?key=" + apiKey);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; utf-8");
            conn.setDoOutput(true);

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonInputString.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }

            int responseCode = conn.getResponseCode();
            InputStream stream = (responseCode >= 200 && responseCode < 300) 
                    ? conn.getInputStream() 
                    : conn.getErrorStream();

            StringBuilder response = new StringBuilder();
            if (stream != null) {
                try (BufferedReader br = new BufferedReader(new InputStreamReader(stream, StandardCharsets.UTF_8))) {
                    String responseLine;
                    while ((responseLine = br.readLine()) != null) {
                        response.append(responseLine.trim());
                    }
                }
            }

            String responseText = response.toString();

            if (responseCode >= 200 && responseCode < 300) {
                // Java標準の正規表現でJSONレスポンスから各キーの値を抽出
                result.put("summary", getValueByKey(responseText, "summary"));
                result.put("taskTitle", getValueByKey(responseText, "taskTitle"));
                result.put("taskAssignee", getValueByKey(responseText, "taskAssignee"));
                result.put("taskDueDate", getValueByKey(responseText, "taskDueDate"));
            } else {
                result.put("summary", "⚠️ Gemini APIエラー (HTTP " + responseCode + ")");
                result.put("taskTitle", "");
                result.put("taskAssignee", "");
                result.put("taskDueDate", "");
            }

        } catch (Exception e) {
            e.printStackTrace();
            result.put("summary", "⚠️ AI解析処理でエラーが発生しました: " + e.getMessage());
            result.put("taskTitle", "");
            result.put("taskAssignee", "");
            result.put("taskDueDate", "");
        }

        return result;
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\r", "")
                    .replace("\n", "\\n");
    }

    // レスポンス文字列から指定されたキーの値を取り出す汎用メソッド
    private String getValueByKey(String jsonResponse, String key) {
        // キーのパターンを検索（エスケープされた引用符等にも対応）
        Pattern pattern = Pattern.compile("\\\\?\"" + key + "\\\\?\"\\s*:\\s*\\\\?\"(.*?)\\\\?\"", Pattern.DOTALL);
        Matcher matcher = pattern.matcher(jsonResponse);
        if (matcher.find()) {
            String val = matcher.group(1);
            // 改行コードやエスケープの復元
            return val.replace("\\n", "\n")
                      .replace("\\r", "")
                      .replace("\\\"", "\"")
                      .replace("\\\\", "\\");
        }
        return "";
    }
}