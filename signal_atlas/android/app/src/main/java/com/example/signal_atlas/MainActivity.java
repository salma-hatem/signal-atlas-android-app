package com.example.signal_atlas;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationManager;
import android.os.Build;
import android.provider.Settings;
import android.telephony.*;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import com.google.android.gms.location.*;

import java.util.*;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "com.example.signal_atlas";

    private MethodChannel channel;
    private Timer timer;
    private long lastSendTime = 0;

    private TelephonyManager telephonyManager;
    private FusedLocationProviderClient fusedLocationClient;

    private boolean isRunning = false;
    private long lastLocationRequestTime = 0;

    private Double lastLat = null, lastLng = null, lastAlt = null;

    // Create connection channel with Flutter to send data
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        telephonyManager = (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this);

        startSendingUpdates();
    }

    @Override
    protected void onPause() {
        super.onPause();

        if (timer != null) {
            timer.cancel();
            timer = null;
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        new android.os.Handler().postDelayed(() -> {
            if (timer == null) {
                startSendingUpdates();
            }
        }, 500);
    }

    // Data is sent periodically using a Timer
    private void startSendingUpdates() {
        if (timer != null) {
            timer.cancel();
            timer = null;
        }
        timer = new Timer();
        timer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                runOnUiThread(() -> collectData());
            }
        }, 0, 2500);
    }

    // Get data using TelephonyManager and Location APIs
    private void collectData() {
        if (isRunning) return;
        isRunning = true;

        Map<String, Object> data = new HashMap<>();

        // Permissions
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED ||
                ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {

            data.put("error", "Permissions not granted");
            invokeChannelSafe(data);
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

        // Location
        getLocationAndSend(data);
    }

    // Get device current location (lon, lat, alt)
    private void getLocationAndSend(Map<String, Object> data) {

        if (!isLocationEnabled()) {
            data.put("Accuracy", -1);
            data.put("IndoorOutdoor", "Unknown");
            sendWithCachedLocation(data);
            return;
        }

        long now = System.currentTimeMillis();

        // throttle GPS requests
        if (now - lastLocationRequestTime < 2500) {
            data.put("Accuracy", -1);
            data.put("IndoorOutdoor", "Cached");
            sendWithCachedLocation(data);
            return;
        }

        lastLocationRequestTime = now;

        // Try to get fresh high-accuracy location first
        com.google.android.gms.location.LocationRequest request =
                com.google.android.gms.location.LocationRequest.create()
                        .setPriority(com.google.android.gms.location.LocationRequest.PRIORITY_HIGH_ACCURACY)
                        .setNumUpdates(1)
                        .setInterval(0);

        fusedLocationClient.getCurrentLocation(
                com.google.android.gms.location.LocationRequest.PRIORITY_HIGH_ACCURACY,
                null
        ).addOnSuccessListener(location -> {

            if (location != null) {

                float acc = location.getAccuracy();
                long age = System.currentTimeMillis() - location.getTime();

                // Accept only good + fresh locations
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

            // Fallback if fresh location is bad or null
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

                        // accept even if slightly worse (fallback mode)
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

                    // total failure → use cached
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

    private void sendWithCachedLocation(Map<String, Object> data) {
        data.put("Latitude", lastLat);
        data.put("Longitude", lastLng);
        data.put("Altitude", lastAlt);

        invokeChannelSafe(data);
        isRunning = false;
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

    private boolean isLocationEnabled() {
        LocationManager lm = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
        return lm.isProviderEnabled(LocationManager.GPS_PROVIDER) ||
                lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER);
    }

    private void invokeChannelSafe(Map<String, Object> data) {
        if (channel == null || getFlutterEngine() == null) return;
        long now = System.currentTimeMillis();
        if (now - lastSendTime < 300) return; // throttle Flutter flood
        lastSendTime = now;

        if (isFinishing() || isDestroyed()) return;

        runOnUiThread(() -> {
            try {
                channel.invokeMethod("newNetworkReading", data);
            } catch (Exception ignored) {}
        });
    }

    @Override
    protected void onDestroy() {
        if (timer != null) {
            timer.cancel();
            timer = null;
        }
        super.onDestroy();
    }
}