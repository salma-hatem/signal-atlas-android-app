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
import java.util.Timer;
import java.util.TimerTask;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.signal_atlas";
    private MethodChannel channel;
    private Timer timer;

    private TelephonyManager telephonyManager;
    private FusedLocationProviderClient fusedLocationClient;

    // Create connection channel with Flutter to continously send data
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        telephonyManager = (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this);

        startSendingUpdates();
    }

    // Data is sent periodically using a Timer
    private void startSendingUpdates() {
        timer = new Timer();
        timer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                runOnUiThread(() -> collectData());
            }
        }, 0, 2000);
    }

    // Get data using TelephonyManager and Location APIs
    private void collectData() {
        Map<String, Object> data = new HashMap<>();

        // Device info
        data.put("ID", Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID));
        data.put("Date", new Date().toString());
        data.put("Timestamp", System.currentTimeMillis());

        // Operator info
        data.put("Operator", telephonyManager.getNetworkOperatorName());
        int networkType = (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R)
                ? telephonyManager.getDataNetworkType()
                : telephonyManager.getNetworkType();
        data.put("NetworkType", getNetworkTypeName(networkType));

        // Permissions check
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
            data.put("error", "Phone permission not granted");
            invokeChannelSafe(data);
            return;
        }
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            data.put("error", "Location permission not granted");
            invokeChannelSafe(data);
            return;
        }

        // Cell info
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

                        // LTE RSRP / RSRQ / RSSI
                        if (strength instanceof CellSignalStrengthLte && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            CellSignalStrengthLte lteSignal = (CellSignalStrengthLte) strength;
                            data.put("RSRP", lteSignal.getRsrp());
                            data.put("RSRQ", lteSignal.getRsrq());
                            data.put("RSSI", lteSignal.getRssi());
                        }

                        // 5G NR RSRP / RSRQ
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && strength instanceof CellSignalStrengthNr) {
                            CellSignalStrengthNr nrSignal = (CellSignalStrengthNr) strength;
                            data.put("RSRP", nrSignal.getCsiRsrp());
                            data.put("RSRQ", nrSignal.getCsiRsrq());
                        }

                        // Identity info
                        if (identity instanceof CellIdentityLte) {
                            CellIdentityLte lteId = (CellIdentityLte) identity;
                            data.put("Cell ID", lteId.getCi());
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
            data.put("Latitude", null);
            data.put("Longitude", null);
            data.put("Altitude", null);
            invokeChannelSafe(data);
            return;
        }

        // Fallback: use last location but request current if null
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) { // API 31+
            fusedLocationClient.getCurrentLocation(
                    LocationRequest.PRIORITY_HIGH_ACCURACY,
                    null
            ).addOnSuccessListener(location -> {
                if (location != null) {
                    data.put("Latitude", location.getLatitude());
                    data.put("Longitude", location.getLongitude());
                    data.put("Altitude", location.hasAltitude() ? location.getAltitude() : null);
                } else {
                    data.put("Latitude", null);
                    data.put("Longitude", null);
                    data.put("Altitude", null);
                }
                invokeChannelSafe(data);
            }).addOnFailureListener(e -> {
                data.put("Latitude", null);
                data.put("Longitude", null);
                data.put("Altitude", null);
                invokeChannelSafe(data);
            });
        } else {
            // For older devices, fallback to getLastLocation() but may be null
            fusedLocationClient.getLastLocation()
                    .addOnSuccessListener(location -> {
                        if (location != null) {
                            data.put("Latitude", location.getLatitude());
                            data.put("Longitude", location.getLongitude());
                            data.put("Altitude", location.hasAltitude() ? location.getAltitude() : null);
                        } else {
                            data.put("Latitude", null);
                            data.put("Longitude", null);
                            data.put("Altitude", null);
                        }
                        invokeChannelSafe(data);
                    })
                    .addOnFailureListener(e -> {
                        data.put("Latitude", null);
                        data.put("Longitude", null);
                        data.put("Altitude", null);
                        invokeChannelSafe(data);
                    });
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

    private boolean isLocationEnabled() {
        LocationManager lm = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
        return lm.isProviderEnabled(LocationManager.GPS_PROVIDER) ||
                lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER);
    }

    private void invokeChannelSafe(Map<String, Object> data) {
        runOnUiThread(() -> channel.invokeMethod("newNetworkReading", data));
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