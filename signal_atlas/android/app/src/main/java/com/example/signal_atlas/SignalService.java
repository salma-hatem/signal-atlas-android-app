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

import androidx.core.app.ActivityCompat;
import androidx.core.app.NotificationCompat;
import com.google.android.gms.location.*;
import io.flutter.plugin.common.MethodChannel;

import java.util.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class SignalService extends Service {

    private Timer timer;
    private boolean isRunning = false;

    private TelephonyManager telephonyManager;
    private FusedLocationProviderClient fusedLocationClient;

    private final ExecutorService executor = Executors.newSingleThreadExecutor();

    private Double lastLat = null, lastLng = null, lastAlt = null;
    private volatile float latestAccuracy = -1;
    private volatile String latestIndoorOutdoor = "Unknown";

    // SPEED STATE
    private Location lastLocation = null;
    private long lastTime = 0;
    private volatile double latestSpeedMps = 0;

    private LocationCallback locationCallback;

    @Override
    public void onCreate() {
        super.onCreate();

        telephonyManager = (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this);

        startLocationTracking();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {

        createNotificationChannel();
        startForeground(1, createNotification());

        startLocationTracking();
        startCollecting();

        return START_NOT_STICKY;
    }

    // Data is sent periodically using a Timer
    private void startCollecting() {
        if (timer != null) {
            timer.cancel();
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

        // Permissions
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE)
                != PackageManager.PERMISSION_GRANTED ||
                ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
                        != PackageManager.PERMISSION_GRANTED) {

            data.put("error", "Permissions not granted");
            sendToFlutter(data);
            isRunning = false;
            return;
        }

        // Device info
        data.put("ID", Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID));
        data.put("Date", new Date().toString());
        data.put("Timestamp", System.currentTimeMillis());


        // Operator info
        try {
            data.put("Operator", telephonyManager.getNetworkOperatorName());
        } catch (Exception e) {
            data.put("Operator", "unknown");
        }

        // Network type
        try {
            int networkType = (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R)
                    ? telephonyManager.getDataNetworkType()
                    : telephonyManager.getNetworkType();

            data.put("NetworkType", getNetworkTypeName(networkType));
        } catch (Exception e) {
            data.put("NetworkType", "unknown");
        }

        // Cell Info
        try {
            List<CellInfo> cellInfos = telephonyManager.getAllCellInfo();

            if (cellInfos != null && !cellInfos.isEmpty()) {
                for (CellInfo cellInfo : cellInfos) {

                    CellSignalStrength strength = null;
                    CellIdentity identity = null;

                    if (cellInfo instanceof CellInfoLte) {
                        CellInfoLte lte = (CellInfoLte) cellInfo;
                        strength = lte.getCellSignalStrength();
                        identity = lte.getCellIdentity();
                        data.put("Type", "LTE");

                    } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && cellInfo instanceof CellInfoNr) {
                        CellInfoNr nr = (CellInfoNr) cellInfo;
                        strength = nr.getCellSignalStrength();
                        identity = nr.getCellIdentity();
                        data.put("Type", "5G");

                    } else if (cellInfo instanceof CellInfoGsm) {
                        CellInfoGsm gsm = (CellInfoGsm) cellInfo;
                        strength = gsm.getCellSignalStrength();
                        identity = gsm.getCellIdentity();
                        data.put("Type", "GSM");
                    }

                    if (strength != null && identity != null) {
                        data.put("Level", strength.getLevel());
                        data.put("ASU Level", strength.getAsuLevel());

                        if (strength instanceof CellSignalStrengthLte && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            CellSignalStrengthLte lteSignal = (CellSignalStrengthLte) strength;
                            data.put("RSRP", lteSignal.getRsrp());
                            data.put("RSRQ", lteSignal.getRsrq());
                            data.put("RSSI", lteSignal.getRssi());
                        }

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && strength instanceof CellSignalStrengthNr) {
                            CellSignalStrengthNr nrSignal = (CellSignalStrengthNr) strength;
                            data.put("RSRP", nrSignal.getCsiRsrp());
                            data.put("RSRQ", nrSignal.getCsiRsrq());
                        }

                        if (cellInfo instanceof CellInfoLte && cellInfo.isRegistered()) {
                            CellInfoLte lte = (CellInfoLte) cellInfo;
                            CellIdentityLte lteId = lte.getCellIdentity();

                            int ci = lteId.getCi();

                            if (ci == CellInfo.UNAVAILABLE) {
                                data.put("Cell ID", null);
                            } else {
                                data.put("Cell ID", ci);
                            }
                            data.put("MCC", lteId.getMccString());
                            data.put("MNC", lteId.getMncString());
                        }

                        if (identity instanceof CellIdentityLte) {
                            CellIdentityLte lteId = (CellIdentityLte) identity;

                            data.put("TAC", lteId.getTac());
                            data.put("PCI", lteId.getPci());

                        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && identity instanceof CellIdentityNr) {
                            CellIdentityNr nrId = (CellIdentityNr) identity;
                            data.put("Cell ID", nrId.getNci());
                            data.put("TAC", nrId.getTac());
                            data.put("PCI", nrId.getPci());
                        }
                    }
                }
            }

        } catch (Exception e) {
            data.put("cellInfoError", e.toString());
        }

        // Final speed
        data.put("Speed_mps", latestSpeedMps);

        // Location
        data.put("Latitude", lastLat);
        data.put("Longitude", lastLng);
        data.put("Altitude", lastAlt);

        // GPS accuracy
        data.put("Accuracy", latestAccuracy);
        data.put("IndoorOutdoor", latestIndoorOutdoor);

        sendToFlutter(data);
        isRunning = false;
    }

    // Get device current location (lon, lat, alt)
    private void startLocationTracking() {

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
                != PackageManager.PERMISSION_GRANTED) {
            return;
        }

        LocationRequest request =
                LocationRequest.create()
                        .setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY)
                        .setInterval(1000)
                        .setFastestInterval(500);

        locationCallback = new LocationCallback() {
            @Override
            public void onLocationResult(LocationResult result) {

                Location location = result.getLastLocation();
                if (location == null) return;

                if (location.getAccuracy() > 100) {
                    return; // ignore bad GPS fix
                }

                // Save coordinates
                lastLat = location.getLatitude();
                lastLng = location.getLongitude();
                lastAlt = location.hasAltitude() ? location.getAltitude() : null;

                // Accuracy classification
                latestAccuracy = location.getAccuracy();
                latestIndoorOutdoor = estimateIndoorOutdoor(location);

                long now = System.currentTimeMillis();

                double speed = 0;

                if (lastLocation != null) {
                    double distance = lastLocation.distanceTo(location);
                    double timeSec = (now - lastTime) / 1000.0;

                    if (timeSec > 0) {
                        speed = distance / timeSec;
                    }
                }

                latestSpeedMps = (latestSpeedMps == 0)
                        ? speed
                        : (latestSpeedMps * 0.8) + (speed * 0.2);

                lastLocation = location;
                lastTime = now;
            }
        };

        fusedLocationClient.requestLocationUpdates(
                request,
                locationCallback,
                getMainLooper()
        );
    }

    // Estimate Indoors/Outdoors
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

    // Helper functions
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

    private void sendToFlutter(Map<String, Object> data) {
        if (MainActivity.sharedEngine == null) return;

        new android.os.Handler(getMainLooper()).post(() -> {
            try {
                new MethodChannel(
                        MainActivity.sharedEngine.getDartExecutor().getBinaryMessenger(),
                        "com.example.signal_atlas"
                ).invokeMethod("newNetworkReading", data);
            } catch (Exception ignored) {}
        });
    }

    // Notifications
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

    // Clean up
    @Override
    public void onDestroy() {

        if (timer != null) timer.cancel();

        if (fusedLocationClient != null && locationCallback != null) {
            fusedLocationClient.removeLocationUpdates(locationCallback);
        }

        executor.shutdownNow();

        stopForeground(true);

        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onTaskRemoved(Intent rootIntent) {
        stopSelf();
        super.onTaskRemoved(rootIntent);
    }
}