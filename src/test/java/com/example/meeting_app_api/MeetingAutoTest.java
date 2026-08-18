package com.example.meeting_app_api;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;

import java.io.File;
import java.io.FileInputStream;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

public class MeetingAutoTest {

    private static WebDriver driver;

    // テスト全体の開始時に1回だけブラウザを起動
    @BeforeAll
    public static void setUpAll() {
        ChromeOptions options = new ChromeOptions();
        driver = new ChromeDriver(options);
        driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(10));
        driver.manage().window().maximize();
    }

    @Test
    public void runSelectedScenarios() throws Exception {
        File excelFile = new File("src/test/resources/testdata/meeting_testdata.xlsx");

        if (!excelFile.exists()) {
            throw new RuntimeException("Excelファイルが見つかりません: " + excelFile.getAbsolutePath());
        }

        try (FileInputStream fis = new FileInputStream(excelFile);
             Workbook workbook = new XSSFWorkbook(fis)) {

            DataFormatter formatter = new DataFormatter();

            // 1. 1シート目（TestScenarios）から「実行フラグ = Y」のテストIDを取得
            Sheet mainSheet = workbook.getSheetAt(0); // 1枚目の管理シート
            List<String> targetTestIds = new ArrayList<>();

            for (int i = 1; i <= mainSheet.getLastRowNum(); i++) {
                Row row = mainSheet.getRow(i);
                if (row == null) continue;

                // B列(index 1) = 実行フラグ(Y/N), C列(index 2) = テストID(TC-001等)
                String runFlag = formatter.formatCellValue(row.getCell(1)).trim(); 
                String testId  = formatter.formatCellValue(row.getCell(2)).trim(); 

                if ("Y".equalsIgnoreCase(runFlag) && !testId.isEmpty()) {
                    targetTestIds.add(testId);
                }
            }

            if (targetTestIds.isEmpty()) {
                System.out.println("⚠️ 実行対象（実行フラグ=Y）のシナリオが1つもありません。");
                return;
            }

            // 2. Webアプリをブラウザで開く
            driver.get("http://localhost:8080/dashboard");

            // 3. 対象のテストID（同名シート）を順に実行
            for (String testId : targetTestIds) {
                System.out.println("==========================================");
                System.out.println("▶▶ 実行中シナリオ: " + testId);
                System.out.println("==========================================");

                // テストIDと同名の個別シートを取得
                Sheet detailSheet = workbook.getSheet(testId);
                if (detailSheet == null) {
                    System.out.println("⚠️ 個別シートが見つかりません: " + testId);
                    continue;
                }

                // データ行（2行目 / index 1）を取得
                Row dataRow = detailSheet.getRow(1);
                if (dataRow == null) {
                    System.out.println("⚠️ " + testId + " シートの2行目にデータが存在しません。");
                    continue;
                }

                // 各シナリオの画面操作を実行
                executeScenario(testId, dataRow, formatter);

                // 画面入力結果を目視確認するための2秒待機
                Thread.sleep(2000);
            }
        }
    }

    // テストケースごとの自動操作ロジック
    private void executeScenario(String testId, Row dataRow, DataFormatter formatter) throws Exception {
        switch (testId) {
            case "TC-001":
                // 1. 個別シート（TC-001）からデータ入力値を取得
                String title     = formatter.formatCellValue(dataRow.getCell(0)); // A列: 会議タイトル
                String startTime = formatter.formatCellValue(dataRow.getCell(1)); // B列: 開始日時
                String emails    = formatter.formatCellValue(dataRow.getCell(2)); // C列: 招待メール

                // 2. モーダルを開いて自動入力
                WebElement openModalBtn = driver.findElement(By.xpath("//button[contains(text(), '新規会議を作成')]"));
                openModalBtn.click();

                WebElement titleInput = driver.findElement(By.id("meetingTitleInput"));
                titleInput.clear();
                titleInput.sendKeys(title);

                WebElement startTimeInput = driver.findElement(By.id("meetingStartTimeInput"));
                startTimeInput.clear();
                startTimeInput.sendKeys(startTime);

                WebElement textarea = driver.findElement(By.id("invitedMembersTextarea"));
                textarea.clear();
                textarea.sendKeys(emails);
                break;

            default:
                System.out.println("⚠️ 操作ロジック未定義のテストIDです: " + testId);
                break;
        }
    }

    // 全シナリオの実行完了後にブラウザを終了
    @AfterAll
    public static void tearDownAll() {
        if (driver != null) {
            driver.quit();
        }
    }
}