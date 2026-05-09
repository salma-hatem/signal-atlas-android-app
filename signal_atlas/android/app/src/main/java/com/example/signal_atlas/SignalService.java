package com.example.signal_atlas;

import android.Manifest;
import android.app.*;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationManager;
import android.os.Build;
import android.os.IBinder;
import android.provider.Settings;
import android.telephony.*;
import io.flutter.plugin.common.MethodChannel;

import androidx.core.app.ActivityCompat;
import androidx.core.app.NotificationCompat;

import com.google.android.gms.location.*;

import java.util.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class SignalService extends Service {

    public static SignalService instance;

    private Timer timer;
    private boolean isRunning = false;

    private TelephonyManager telephonyManager;
    private FusedLocationProviderClient fusedLocationClient;

    private final ExecutorService executor = Executors.newSingleThreadExecutor();

    private long lastLocationRequestTime = 0;

    private Double lastLat = null, lastLng = null, lastAlt = null;

    private ReadingBatcher batcher;

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;

        telephonyManager = (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {

        createNotificationChannel();
        startForeground(1, createNotification());

        startCollecting();

        return START_NOT_STICKY;
    }

    public void startBatching(String baseUrl, String apiKey) {
        if (batcher == null) {
            batcher = new ReadingBatcher(baseUrl, apiKey, this::onBatchSent);
            batcher.start();
        }
    }

    public int stopBatching() {
        int count = 0;
        if (batcher != null) {
            batcher.flushAll();
            count = batcher.getTotalSent();
            batcher.stop();
            batcher = null;
        }
        return count;
    }

    private void onBatchSent(int totalSent) {
        new android.os.Handler(getMainLooper()).post(() -> {
            try {
                if (MainActivity.sharedChannel != null) {
                    MainActivity.sharedChannel.invokeMethod("samplesCount", totalSent);
                }
            } catch (Exception ignored) {}
        });
    }

    public int flushAndGetCount() {
        if (batcher != null) {
            batcher.flushAll();
            return batcher.getTotalSent();
        }
        return 0;
    }

    private void startCollecting() {
        if (timer != null) {
            timer.cancel();
            timer = null;
        }
        timer = new Timer();
        timer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                executor.execute(() -> collectData());
            }
        }, 0, 2500);
    }

    private void collectData() {
        if (isRunning) return;
        isRunning = true;

        Map<String, Object> data = new HashMap<>();

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED ||
                ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {

            data.put("error", "Permissions not granted");
            sendToFlutter(data);
            isRunning = false;
            return;
        }

        data.put("ID", Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID));
        data.put("Date", new Date().toString());
        data.put("Timestamp", System.currentTimeMillis());

        try {
            data.put("Operator", telephonyManager.getNetworkOperatorName());
        } catch (Exception e) {
            data.put("Operator", "unknown");
        }

        try {
            int networkType = (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R)
                    ? telephonyManager.getDataNetworkType()
                    : telephonyManager.getNetworkType();

            data.put("NetworkType", getNetworkTypeName(networkType));
        } catch (Exception e) {
            data.put("NetworkType", "unknown");
        }

        try {
            List<CellInfo> cellInfos = telephonyManager.getAllCellInfo();

            if (cellInfos != null && !cellInfos.isEmpty()) {
                for (CellInfo cellInfo : cellInfos) {
                    if (!cellInfo.isRegistered()) continue;

                    if (cellInfo instanceof CellInfoLte) {
                        CellInfoLte lte = (CellInfoLte) cellInfo;
                        CellSignalStrengthLte strength = lte.getCellSignalStrength();
                        CellIdentityLte identity = lte.getCellIdentity();

                        data.put("Type", "LTE");
                        data.put("Level", strength.getLevel());
                        data.put("ASU Level", strength.getAsuLevel());

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            data.put("RSRP", strength.getRsrp());
                            data.put("RSRQ", strength.getRsrq());
                            data.put("RSSI", strength.getRssi());
                        }

                        int ci = identity.getCi();
                        data.put("Cell ID", ci == CellInfo.UNAVAILABLE ? null : ci);
                        data.put("MCC", identity.getMccString());
                        data.put("MNC", identity.getMncString());
                        data.put("TAC", identity.getTac());
                        data.put("PCI", identity.getPci());

                    } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && cellInfo instanceof CellInfoNr) {
                        CellInfoNr nr = (CellInfoNr) cellInfo;
                        CellSignalStrengthNr strength = (CellSignalStrengthNr) nr.getCellSignalStrength();
                        CellIdentityNr identity = (CellIdentityNr) nr.getCellIdentity();

                        data.put("Type", "5G");
                        data.put("Level", strength.getLevel());
                        data.put("ASU Level", strength.getAsuLevel());
                        data.put("RSRP", strength.getCsiRsrp());
                        data.put("RSRQ", strength.getCsiRsrq());

                        data.put("Cell ID", identity.getNci());
                        data.put("MCC", identity.getMccString());
                        data.put("MNC", identity.getMncString());
                        data.put("TAC", identity.getTac());
                        data.put("PCI", identity.getPci());

                    } else if (cellInfo instanceof CellInfoGsm) {
                        CellInfoGsm gsm = (CellInfoGsm) cellInfo;
                        CellSignalStrengthGsm strength = gsm.getCellSignalStrength();
                        CellIdentityGsm identity = gsm.getCellIdentity();

                        data.put("Type", "GSM");
                        data.put("Level", strength.getLevel());
                        data.put("ASU Level", strength.getAsuLevel());

                        data.put("Cell ID", identity.getCid() == CellInfo.UNAVAILABLE ? null : identity.getCid());
                        data.put("MCC", identity.getMccString());
                        data.put("MNC", identity.getMncString());
                        data.put("LAC", identity.getLac());
                    }

                    break;
                }
            }

        } catch (Exception e) {
            data.put("cellInfoError", e.toString());
        }

        getLocationAndSend(data);
    }

    private void getLocationAndSend(Map<String, Object> data) {

        if (!isLocationEnabled()) {
            data.put("Accuracy", -1);
            data.put("IndoorOutdoor", "Unknown");
            sendWithCachedLocation(data);
            return;
        }

        long now = System.currentTimeMillis();

        if (now - lastLocationRequestTime < 2500) {
            data.put("Accuracy", -1);
            data.put("IndoorOutdoor", "Cached");
            sendWithCachedLocation(data);
            return;
        }

        lastLocationRequestTime = now;

        fusedLocationClient.getCurrentLocation(
                com.google.android.gms.location.LocationRequest.PRIORITY_HIGH_ACCURACY,
                null
        ).addOnSuccessListener(location -> {

            if (location != null) {

                float acc = location.getAccuracy();
                long age = System.currentTimeMillis() - location.getTime();

                if (acc <= 70 && age < 15000) {

                    lastLat = location.getLatitude();
                    lastLng = location.getLongitude();
                    lastAlt = location.hasAltitude() ? location.getAltitude() : null;

                    data.put("Accuracy", acc);
                    data.put("IndoorOutdoor", estimateIndoorOutdoor(location));

                    sendWithCachedLocation(data);
                    return;
                }
            }

            fallbackToLastLocation(data);

        }).addOnFailureListener(e -> {
            fallbackToLastLocation(data);
        });
    }

    private void fallbackToLastLocation(Map<String, Object> data) {

        fusedLocationClient.getLastLocation()
                .addOnSuccessListener(location -> {

                    if (location != null) {

                        float acc = location.getAccuracy();

                        if (acc <= 100) {
                            lastLat = location.getLatitude();
                            lastLng = location.getLongitude();
                            lastAlt = location.hasAltitude() ? location.getAltitude() : null;

                            data.put("Accuracy", acc);
                            data.put("IndoorOutdoor", estimateIndoorOutdoor(location));

                            sendWithCachedLocation(data);
                            return;
                        }
                    }

                    data.put("Accuracy", -1);
                    data.put("IndoorOutdoor", "Unknown");

                    sendWithCachedLocation(data);

                })
                .addOnFailureListener(e -> {
                    data.put("Accuracy", -1);
                    data.put("IndoorOutdoor", "Unknown");
                    sendWithCachedLocation(data);
                });
    }

    private String estimateIndoorOutdoor(Location location) {
        if (location == null) return "Unknown";

        float accuracy = location.getAccuracy();

        if (accuracy <= 15) {
            return "Outdoor";
        } else if (accuracy <= 50) {
            return "Uncertain";
        } else {
            return "Indoor";
        }
    }

    private void sendWithCachedLocation(Map<String, Object> data) {
        data.put("Latitude", lastLat);
        data.put("Longitude", lastLng);
        data.put("Altitude", lastAlt);

        if (batcher != null) {
            batcher.addReading(data);
        }

        sendToFlutter(data);
        isRunning = false;
    }

    private String getNetworkTypeName(int type) {
        switch (type) {
            case TelephonyManager.NETWORK_TYPE_LTE: return "LTE";
            case TelephonyManager.NETWORK_TYPE_NR: return "5G";
            case TelephonyManager.NETWORK_TYPE_HSPAP: return "HSPA+";
            case TelephonyManager.NETWORK_TYPE_EDGE: return "EDGE";
            case TelephonyManager.NETWORK_TYPE_GPRS: return "GPRS";
            default: return "Unknown";
        }
    }

    private boolean isLocationEnabled() {
        LocationManager lm = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
        return lm.isProviderEnabled(LocationManager.GPS_PROVIDER) ||
                lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER);
    }

    private void sendToFlutter(Map<String, Object> data) {
        new android.os.Handler(getMainLooper()).post(() -> {
            try {
                if (MainActivity.sharedChannel != null) {
                    MainActivity.sharedChannel.invokeMethod("newNetworkReading", data);
                }
            } catch (Exception ignored) {}
        });
    }

    private Notification createNotification() {
        return new NotificationCompat.Builder(this, "signal_channel")
                .setContentTitle("Signal Atlas Running")
                .setContentText("Collecting network data...")
                .setSmallIcon(R.mipmap.ic_launcher)
                .build();
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    "signal_channel",
                    "Signal Atlas Service",
                    NotificationManager.IMPORTANCE_LOW
            );

            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(channel);
        }
    }

    @Override
    public void onDestroy() {
        if (batcher != null) {
            batcher.flushAll();
            batcher.stop();
        }
        if (timer != null) {
            timer.cancel();
            timer = null;
        }
        executor.shutdown();
        stopForeground(true);
        isRunning = false;
        instance = null;
        super.onDestroy();
    }

    @Override
    public void onTaskRemoved(Intent rootIntent) {
        if (batcher != null) {
            batcher.flushAll();
        }
        super.onTaskRemoved(rootIntent);
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
