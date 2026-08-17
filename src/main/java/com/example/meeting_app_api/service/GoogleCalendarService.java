package com.example.meeting_app_api.service;

import com.example.meeting_app_api.entity.Meeting;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.services.calendar.Calendar;
import com.google.api.services.calendar.CalendarScopes;
import com.google.api.services.calendar.model.Event;
import com.google.api.services.calendar.model.EventAttendee;
import com.google.api.services.calendar.model.EventDateTime;
import com.google.auth.http.HttpCredentialsAdapter;
import com.google.auth.oauth2.GoogleCredentials;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.io.InputStream;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class GoogleCalendarService {

    private static final String APPLICATION_NAME = "AI Smart Meeting System";

    // Google Calendar API サービスの初期化
    private Calendar getCalendarService() throws Exception {
        ClassPathResource resource = new ClassPathResource("credentials.json");
        try (InputStream in = resource.getInputStream()) {
            GoogleCredentials credentials = GoogleCredentials.fromStream(in)
                    .createScoped(Collections.singleton(CalendarScopes.CALENDAR));

            return new Calendar.Builder(
                    GoogleNetHttpTransport.newTrustedTransport(),
                    GsonFactory.getDefaultInstance(),
                    new HttpCredentialsAdapter(credentials))
                    .setApplicationName(APPLICATION_NAME)
                    .build();
        }
    }

    // ➕ 会議作成時に Google カレンダーへ登録 ＆ 招待メール自動送信
    public String createGoogleEvent(Meeting meeting) {
        try {
            Calendar service = getCalendarService();

            Event event = new Event()
                    .setSummary(meeting.getTitle())
                    .setDescription("⚡ AI Smart Meeting System より自動登録された会議です。");

            // 開始日時・終了日時（仮で1時間枠）の設定
            String startIso = meeting.getStartTime().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME) + ":00+09:00";
            String endIso = meeting.getStartTime().plusHours(1).format(DateTimeFormatter.ISO_LOCAL_DATE_TIME) + ":00+09:00";

            event.setStart(new EventDateTime().setDateTime(new com.google.api.client.util.DateTime(startIso)).setTimeZone("Asia/Tokyo"));
            event.setEnd(new EventDateTime().setDateTime(new com.google.api.client.util.DateTime(endIso)).setTimeZone("Asia/Tokyo"));

            // 👥 参加者（メールアドレス）を登録 ➔ Googleから自動で招待メールが送られます
            if (meeting.getAttendeeEmails() != null && !meeting.getAttendeeEmails().trim().isEmpty()) {
                List<EventAttendee> attendees = Arrays.stream(meeting.getAttendeeEmails().split(","))
                        .map(String::trim)
                        .filter(email -> !email.isEmpty())
                        .map(email -> new EventAttendee().setEmail(email))
                        .collect(Collectors.toList());
                event.setAttendees(attendees);
            }

            // イベントを作成して送信通知（sendUpdates = all）を有効化
            Event createdEvent = service.events().insert("primary", event)
                    .setSendUpdates("all")
                    .execute();

            return createdEvent.getId();
        } catch (Exception e) {
            System.err.println("⚠️ Google Calendar 同期エラー: " + e.getMessage());
            e.printStackTrace();
            return null; // エラー時もアプリ側の作成処理は止めない
        }
    }

    // 🔄 会議編集時に Google カレンダーの予定も更新
    public void updateGoogleEvent(Meeting meeting) {
        if (meeting.getGoogleEventId() == null || meeting.getGoogleEventId().trim().isEmpty()) {
            return; // GoogleイベントIDがない場合はスキップ
        }
        try {
            Calendar service = getCalendarService();

            // 既存のイベントを取得
            Event event = service.events().get("primary", meeting.getGoogleEventId()).execute();

            // 内容を更新
            event.setSummary(meeting.getTitle());

            String startIso = meeting.getStartTime().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME) + ":00+09:00";
            String endIso = meeting.getStartTime().plusHours(1).format(DateTimeFormatter.ISO_LOCAL_DATE_TIME) + ":00+09:00";

            event.setStart(new EventDateTime().setDateTime(new com.google.api.client.util.DateTime(startIso)).setTimeZone("Asia/Tokyo"));
            event.setEnd(new EventDateTime().setDateTime(new com.google.api.client.util.DateTime(endIso)).setTimeZone("Asia/Tokyo"));

            if (meeting.getAttendeeEmails() != null && !meeting.getAttendeeEmails().trim().isEmpty()) {
                List<EventAttendee> attendees = Arrays.stream(meeting.getAttendeeEmails().split(","))
                        .map(String::trim)
                        .filter(email -> !email.isEmpty())
                        .map(email -> new EventAttendee().setEmail(email))
                        .collect(Collectors.toList());
                event.setAttendees(attendees);
            }

            // 更新を実行（sendUpdates = all で変更通知メール送信）
            service.events().update("primary", meeting.getGoogleEventId(), event)
                    .setSendUpdates("all")
                    .execute();

        } catch (Exception e) {
            System.err.println("⚠️ Google Calendar 更新エラー: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // 🗑️ 会議削除時に Google カレンダーの予定も削除
    public void deleteGoogleEvent(String googleEventId) {
        if (googleEventId == null || googleEventId.trim().isEmpty()) {
            return;
        }
        try {
            Calendar service = getCalendarService();
            service.events().delete("primary", googleEventId)
                    .setSendUpdates("all")
                    .execute();
        } catch (Exception e) {
            System.err.println("⚠️ Google Calendar 削除エラー: " + e.getMessage());
            e.printStackTrace();
        }
    }
}