package com.example.meeting_app_api;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.Arrays;

@Aspect
@Component
public class ApiLoggingFilter {

    private static final Logger log = LoggerFactory.getLogger(ApiLoggingFilter.class);

    // Controllerパッケージ配下のすべてのpublicメソッドの実行前後をインターセプト
    @Around("execution(public * com.example.meeting_app_api.controller..*.*(..))")
    public Object logControllerAccess(ProceedingJoinPoint joinPoint) throws Throwable {

        // 1. クラス名#メソッド名 の取得
        String className = joinPoint.getTarget().getClass().getSimpleName();
        String methodName = joinPoint.getSignature().getName();
        String targetMethod = className + "#" + methodName;

        // 2. 引数（パラメータ）の取得
        Object[] args = joinPoint.getArgs();
        String params = (args != null && args.length > 0) ? Arrays.toString(args) : "[なし]";

        // ★ リクエストログ出力（ご指定フォーマット）
        log.info("[API Request]  {} : {}", targetMethod, params);

        long startTime = System.currentTimeMillis();
        Object result;

        try {
            // 実際の Controller 処理を実行
            result = joinPoint.proceed();
        } catch (Throwable t) {
            log.error("[API Exception] {} : Status=ERROR ({}) | Cause={}", 
                      targetMethod, t.getClass().getSimpleName(), t.getMessage());
            throw t;
        }

        long duration = System.currentTimeMillis() - startTime;
        String responseStr = (result != null) ? result.toString() : "[void/null]";

        // ★ レスポンスログ出力（ご指定フォーマット）
        log.info("[API Response] {} : Status=200 ({}ms) | Response={}", 
                 targetMethod, duration, responseStr);

        return result;
    }
}