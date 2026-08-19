package com.example.meeting_app_api;

import org.apache.commons.io.FileUtils;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.io.File;
import java.io.FileInputStream;
import java.nio.file.Files;
import java.nio.file.attribute.BasicFileAttributeView;
import java.nio.file.attribute.FileTime;
import java.text.SimpleDateFormat;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class MeetingAutoTest {

    private static WebDriver driver;

    @BeforeAll
    public static void setUpAll() {
        ChromeOptions options = new ChromeOptions();

        // 表示倍率を 80%に設定
        options.addArguments("--force-device-scale-factor=0.8");

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
            Sheet mainSheet = workbook.getSheetAt(0);
            List<String> targetTestIds = new ArrayList<>();

            for (int i = 1; i <= mainSheet.getLastRowNum(); i++) {
                Row row = mainSheet.getRow(i);
                if (row == null)
                    continue;

                String runFlag = formatter.formatCellValue(row.getCell(1)).trim(); // B列: 実行フラグ
                String testId = formatter.formatCellValue(row.getCell(2)).trim(); // C列: テストID

                if ("Y".equalsIgnoreCase(runFlag) && !testId.isEmpty()) {
                    targetTestIds.add(testId);
                }
            }

            if (targetTestIds.isEmpty()) {
                System.out.println("⚠️ 実行対象（実行フラグ=Y）のシナリオが1つもありません。");
                return;
            }

            // 2. アプリへ移動
            System.out.println("🌐 Webアプリを開きます: http://localhost:8080/dashboard");
            driver.get("http://localhost:8080/dashboard");

            // 3. 対象のテストID（シート）を順に実行
            for (String testId : targetTestIds) {
                System.out.println("\n==========================================");
                System.out.println("▶▶ [START] テストケース実行: " + testId);
                System.out.println("==========================================");

                Sheet detailSheet = workbook.getSheet(testId);
                if (detailSheet == null) {
                    System.out.println("⚠️ シートが見つかりません: " + testId);
                    continue;
                }

                try {
                    // Excelの行を1行ずつループ実行する処理
                    executeSheetSteps(testId, detailSheet, formatter);

                    // ★ APIログファイルのコピー保存
                    copyApiLog(testId, "app-api.log");

                    System.out.println("✅ [SUCCESS] " + testId + " のシナリオ実行が完了しました。");

                } catch (Exception e) {
                    System.err.println("❌ [FAILURE] " + testId + " 実行中にエラーが発生しました: " + e.getMessage());
                    takeScreenshot(testId, "ERROR"); // エラー時スクショ
                    copyApiLog(testId, "ERROR_app-api.log"); // エラー時ログ
                }

                Thread.sleep(1000);
            }
        }
    }

    /**
     * Excelシート上の操作手順（A列:操作, B列:要素ID/XPath/CSS, C列:入力値, D列:スクショY/N）を上から順に実行
     */
    private void executeSheetSteps(String testId, Sheet sheet, DataFormatter formatter) throws Exception {
        int stepNo = 1;
        for (int i = 1; i <= sheet.getLastRowNum(); i++) {
            Row row = sheet.getRow(i);
            if (row == null)
                continue;

            String actionType = formatter.formatCellValue(row.getCell(0)).trim(); // A列: 操作種別
            String target = formatter.formatCellValue(row.getCell(1)).trim(); // B列: ID/XPath/CSS
            String inputValue = formatter.formatCellValue(row.getCell(2)).trim(); // C列: 入力値
            String shotFlag = formatter.formatCellValue(row.getCell(3)).trim(); // D列: スクショ撮影

            if (actionType.isEmpty())
                continue;

            System.out.println(
                    " 🔹 [Step " + stepNo + "] 操作: " + actionType + " | 対象: " + target + " | 値: " + inputValue);

            switch (actionType.toUpperCase()) {
                case "CLICK":
                    WebElement clickElem = findElementByTarget(target);
                    clickElem.click();
                    break;

                case "CLEAR": // テキストボックスの値を全消去する
                    WebElement clearElem = findElementByTarget(target);
                    clearElem.clear();
                    // JSでも値を空にしてinput/changeイベントを発火
                    JavascriptExecutor jsClear = (JavascriptExecutor) driver;
                    jsClear.executeScript("arguments[0].value = '';", clearElem);
                    jsClear.executeScript("arguments[0].dispatchEvent(new Event('input', { bubbles: true }));",
                            clearElem);
                    jsClear.executeScript("arguments[0].dispatchEvent(new Event('change', { bubbles: true }));",
                            clearElem);
                    break;

                case "INPUT":
                    WebElement inputElem = findElementByTarget(target);

                    // type="datetime-local" や ID/セレクター に "time"/"date" が含まれる場合は JS で直接セット（400エラー防止）
                    String inputType = inputElem.getAttribute("type");
                    boolean isDateTime = "datetime-local".equalsIgnoreCase(inputType)
                            || target.toLowerCase().contains("time")
                            || target.toLowerCase().contains("date");

                    if (isDateTime) {
                        JavascriptExecutor js = (JavascriptExecutor) driver;
                        js.executeScript("arguments[0].value = arguments[1];", inputElem, inputValue);
                        js.executeScript("arguments[0].dispatchEvent(new Event('input', { bubbles: true }));",
                                inputElem);
                        js.executeScript("arguments[0].dispatchEvent(new Event('change', { bubbles: true }));",
                                inputElem);
                    } else {
                        inputElem.clear();
                        inputElem.sendKeys(inputValue);
                    }
                    break;

                case "WAIT":
                    long waitMs = inputValue.isEmpty() ? 1000 : Long.parseLong(inputValue);
                    Thread.sleep(waitMs);
                    break;

                case "ACCEPT_ALERT": // 削除確認ダイアログの「OK」をクリック
                    try {
                        WebDriverWait alertWait = new WebDriverWait(driver, Duration.ofSeconds(5));
                        org.openqa.selenium.Alert alert = alertWait.until(ExpectedConditions.alertIsPresent());
                        alert.accept();
                        System.out.println(" 🔹 確認ダイアログ（Alert）の「OK」をクリックしました。");
                    } catch (Exception e) {
                        System.out.println(" ⚠️ 確認ダイアログが表示されなかったためスキップしました: " + e.getMessage());
                    }
                    break;

                case "SELECT": // プルダウン（<select>）の値または表示テキストを選択する
                    WebElement selectElem = findElementByTarget(target);
                    org.openqa.selenium.support.ui.Select select = new org.openqa.selenium.support.ui.Select(
                            selectElem);
                    try {
                        // まず表示テキスト（例: "営業推進班" など）で選択を試みる
                        select.selectByVisibleText(inputValue);
                    } catch (Exception e) {
                        // 見つからなければ value 属性（IDなど）で選択を試みる
                        select.selectByValue(inputValue);
                    }
                    // changeイベントを発火させてJavaScript側の自動入力スクリプトを起動
                    JavascriptExecutor jsSelect = (JavascriptExecutor) driver;
                    jsSelect.executeScript("arguments[0].dispatchEvent(new Event('change', { bubbles: true }));",
                            selectElem);
                    break;

                case "TAKE_ELEMENT_SHOT": // 指定した要素（エリア）のみを切り抜いてスクショ撮影
                    WebElement shotTargetElem = findElementByTarget(target);
                    File elemSrcFile = shotTargetElem.getScreenshotAs(OutputType.FILE);

                    File elemTargetDir = new File("build/screenshots/" + testId);
                    if (!elemTargetDir.exists()) {
                        elemTargetDir.mkdirs();
                    }

                    String elemTimestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
                    File elemDestFile = new File(elemTargetDir,
                            testId + "_step" + stepNo + "_" + elemTimestamp + ".png");

                    FileUtils.copyFile(elemSrcFile, elemDestFile);
                    System.out.println(" 📸 【ピンポイント撮影】 エリア要素のスクショを保存しました: " + elemDestFile.getAbsolutePath());
                    break;

                default:
                    System.out.println(" ⚠️ 未知の操作種別です: " + actionType);
                    break;
            }

            // D列が "Y" の場合、そのステップの直後にスクショ撮影
            if ("Y".equalsIgnoreCase(shotFlag)) {
                takeScreenshot(testId, "step" + stepNo);
            }

            stepNo++;
        }
    }

    /**
     * ID, XPath, または CSSセレクター（.クラス名など）で画面要素を特定し、クリック可能になるまで待機する
     */
    private WebElement findElementByTarget(String target) {
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));
        By locator;

        if (target.startsWith("//") || target.startsWith("(")) {
            locator = By.xpath(target);
        } else if (target.startsWith(".") || target.startsWith("#") || target.contains("[")) {
            locator = By.cssSelector(target);
        } else {
            locator = By.id(target);
        }

        return wait.until(ExpectedConditions.elementToBeClickable(locator));
    }

    // ★ スクリーンショット撮影メソッド
    private void takeScreenshot(String testId, String stepName) {
        try {
            TakesScreenshot ts = (TakesScreenshot) driver;
            File srcFile = ts.getScreenshotAs(OutputType.FILE);

            File targetDir = new File("build/screenshots/" + testId);
            if (!targetDir.exists()) {
                targetDir.mkdirs();
            }

            String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            File destFile = new File(targetDir, testId + "_" + stepName + "_" + timestamp + ".png");

            FileUtils.copyFile(srcFile, destFile);
            System.out.println(" 📸 スクリーンショット保存完了: " + destFile.getAbsolutePath());

        } catch (Exception e) {
            System.err.println(" ⚠️ スクリーンショット撮影失敗: " + e.getMessage());
        }
    }

    // ★ APIログコピー保存メソッド（全タイムスタンプを現在時刻に強制上書き版）
    private void copyApiLog(String testId, String targetFileName) {
        try {
            File srcLogFile = null;

            File defaultLog = new File("logs/app-api.log");
            if (defaultLog.exists() && defaultLog.isFile()) {
                srcLogFile = defaultLog;
            } else {
                File logsDir = new File("logs");
                if (logsDir.exists() && logsDir.isDirectory()) {
                    File[] logFiles = logsDir.listFiles((dir, name) -> name.endsWith(".log") && !name.endsWith(".gz"));
                    if (logFiles != null && logFiles.length > 0) {
                        srcLogFile = logFiles[0];
                        for (File f : logFiles) {
                            if (f.lastModified() > srcLogFile.lastModified()) {
                                srcLogFile = f;
                            }
                        }
                    }
                }
            }

            if (srcLogFile == null) {
                File rootLog = new File("app-api.log");
                if (rootLog.exists() && rootLog.isFile()) {
                    srcLogFile = rootLog;
                }
            }

            if (srcLogFile == null) {
                System.out.println(" ⚠️ logs フォルダ内に適切なログファイルが見つかりません。");
                return;
            }

            File targetDir = new File("build/screenshots/" + testId);
            if (!targetDir.exists()) {
                targetDir.mkdirs();
            }

            String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            File destFile = new File(targetDir, testId + "_" + timestamp + "_" + targetFileName);

            FileUtils.copyFile(srcLogFile, destFile);

            // 全タイムスタンプ（作成・更新・アクセス）を現在時刻に上書き
            FileTime now = FileTime.fromMillis(System.currentTimeMillis());
            BasicFileAttributeView attributes = Files.getFileAttributeView(destFile.toPath(),
                    BasicFileAttributeView.class);
            if (attributes != null) {
                attributes.setTimes(now, now, now);
            }

            System.out.println(" 📄 APIログ保存完了: " + destFile.getAbsolutePath());

        } catch (Exception e) {
            System.err.println(" ⚠️ ログファイル保存失敗: " + e.getMessage());
        }
    }

    @AfterAll
    public static void tearDownAll() {
        if (driver != null) {
            driver.quit();
        }
    }
}