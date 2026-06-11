package com.example.signal_atlas;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.os.PowerManager;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "com.example.signal_atlas";

    public static MethodChannel sharedChannel;
    public static FlutterEngine sharedEngine;
    private boolean returnedFromBatterySettings = false;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);


        sharedEngine = flutterEngine;

        sharedChannel = new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                CHANNEL
        );

        sharedChannel.setMethodCallHandler((call, result) -> {

            if (call.method.equals("requestBatteryOptimization")) {
                requestBatteryOptimizationDisable();
                result.success(null);

            } else if (call.method.equals("startService")) {

                Intent intent = new Intent(this, SignalService.class);

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    startForegroundService(intent);
                } else {
                    startService(intent);
                }

                result.success(null);
            } else if (call.method.equals("stopService")) {

                Intent intent = new Intent(this, SignalService.class);
                stopService(intent);

                result.success(null);
            }
        });
    }

    private void requestBatteryOptimizationDisable() {
        try {
            String packageName = getPackageName();
            PowerManager pm = (PowerManager) getSystemService(POWER_SERVICE);

            Intent intent;
            if (pm != null && !pm.isIgnoringBatteryOptimizations(packageName)) {
                // Direct prompt — requires REQUEST_IGNORE_BATTERY_OPTIMIZATIONS in manifest
                intent = new Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS);
                intent.setData(android.net.Uri.parse("package:" + packageName));
            } else {
                // Already whitelisted, skip to callback immediately
                if (sharedChannel != null) {
                    sharedChannel.invokeMethod("batterySettingsClosed", null);
                }
                return;
            }

            startActivity(intent);
            returnedFromBatterySettings = true;
        } catch (Exception e) {
            // Fallback: just proceed without it
            if (sharedChannel != null) {
                sharedChannel.invokeMethod("batterySettingsClosed", null);
            }
        }
    }

    @Override
    protected void onResume() {
        super.onResume();

        if (returnedFromBatterySettings) {
            returnedFromBatterySettings = false;

            // NOW safe to continue Flutter flow
            if (sharedChannel != null) {
                sharedChannel.invokeMethod("batterySettingsClosed", null);
            }
        }
    }
    @Override
    protected void onDestroy() {

        sharedEngine = null;
        sharedChannel = null;

        super.onDestroy();
    }
}