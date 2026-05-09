package com.example.signal_atlas;

import android.util.Log;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;
import java.util.Timer;
import java.util.TimerTask;

public class ReadingBatcher {
    private static final String TAG = "ReadingBatcher";
    private static final int BATCH_SIZE = 20;
    private static final long FLUSH_INTERVAL_MS = 30_000;
    private static final int MAX_RETRIES = 5;

    private final List<JSONObject> buffer = new ArrayList<>();
    private final String baseUrl;
    private final String apiKey;
    private final BatchCallback callback;
    private final SimpleDateFormat isoFormat;
    private Timer timer;
    private int totalSent = 0;

    public interface BatchCallback {
        void onBatchSent(int totalSent);
    }

    public ReadingBatcher(String baseUrl, String apiKey, BatchCallback callback) {
        this.baseUrl = baseUrl;
        this.apiKey = apiKey;
        this.callback = callback;
        this.isoFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US);
        this.isoFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
    }

    public synchronized void addReading(Map<String, Object> raw) {
        buffer.add(toPayload(raw));
        if (buffer.size() >= BATCH_SIZE) {
            flush();
        }
    }

    public synchronized int getTotalSent() {
        return totalSent;
    }

    public synchronized int getPendingCount() {
        return buffer.size();
    }

    public synchronized void start() {
        if (timer != null) return;
        timer = new Timer();
        timer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                synchronized (ReadingBatcher.this) {
                    if (!buffer.isEmpty()) {
                        flush();
                    }
                }
            }
        }, FLUSH_INTERVAL_MS, FLUSH_INTERVAL_MS);
    }

    public synchronized void flushAll() {
        while (!buffer.isEmpty()) {
            doFlush();
        }
    }

    public void stop() {
        if (timer != null) {
            timer.cancel();
            timer = null;
        }
    }

    private synchronized void doFlush() {
        if (buffer.isEmpty()) return;

        final List<JSONObject> batch = new ArrayList<>();
        int count = Math.min(BATCH_SIZE, buffer.size());
        for (int i = 0; i < count; i++) {
            batch.add(buffer.get(i));
        }

        sendBatchWithRetry(batch);
    }

    private synchronized void flush() {
        doFlush();
    }

    private void sendBatchWithRetry(final List<JSONObject> batch) {
        int attempts = 0;
        while (attempts < MAX_RETRIES) {
            try {
                sendHttpBatch(batch);

                for (int i = 0; i < batch.size(); i++) {
                    if (!buffer.isEmpty()) {
                        buffer.remove(0);
                    }
                }
                totalSent += batch.size();

                final int currentTotal = totalSent;
                if (callback != null) {
                    callback.onBatchSent(currentTotal);
                }
                return;

            } catch (Exception e) {
                attempts++;
                Log.e(TAG, "Batch failed (attempt " + attempts + "/" + MAX_RETRIES + "): " + e.getMessage());
                if (attempts >= MAX_RETRIES) {
                    Log.e(TAG, "Dropping batch after " + MAX_RETRIES + " failed attempts");
                    for (int i = 0; i < batch.size(); i++) {
                        if (!buffer.isEmpty()) {
                            buffer.remove(0);
                        }
                    }
                    return;
                }
                try {
                    Thread.sleep((long) Math.pow(2, attempts) * 1000);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    return;
                }
            }
        }
    }

    private void sendHttpBatch(List<JSONObject> batch) throws Exception {
        JSONArray jsonReadings = new JSONArray();
        for (JSONObject reading : batch) {
            jsonReadings.put(reading);
        }
        JSONObject payload = new JSONObject();
        payload.put("readings", jsonReadings);

        URL url = new URL(baseUrl + "/api/network-data/batch");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setRequestProperty("X-API-Key", apiKey);
        conn.setDoOutput(true);
        conn.setConnectTimeout(15000);
        conn.setReadTimeout(15000);

        try (OutputStream os = conn.getOutputStream()) {
            byte[] body = payload.toString().getBytes("UTF-8");
            os.write(body);
        }

        int responseCode = conn.getResponseCode();
        conn.disconnect();

        if (responseCode != 200 && responseCode != 201) {
            throw new Exception("Server returned " + responseCode);
        }
    }

    private JSONObject toPayload(Map<String, Object> raw) {
        JSONObject obj = new JSONObject();
        try {
            obj.put("source", valueOr(raw.get("ID"), "unknown"));
            obj.put("timestamp", isoFormat.format(new Date(toLong(raw.get("Timestamp"), System.currentTimeMillis()))));
            obj.put("latitude", toDouble(raw.get("Latitude"), 0.0));
            obj.put("longitude", toDouble(raw.get("Longitude"), 0.0));
            obj.put("altitude", toDouble(raw.get("Altitude"), 0.0));
            obj.put("level", toInt(raw.get("Level"), 0));
            obj.put("asu", toInt(raw.get("ASU Level"), 0));
            obj.put("rsrp", toInt(raw.get("RSRP"), 0));
            obj.put("rssi", toInt(raw.get("RSSI"), 0));
            obj.put("rsrq", toInt(raw.get("RSRQ"), 0));
            obj.put("networkType", valueOr(raw.get("NetworkType"), "-"));
            obj.put("operator", valueOr(raw.get("Operator"), "-"));
            obj.put("cellId", String.valueOf(toInt(raw.get("Cell ID"), 0)));
            obj.put("physicalCellId", toInt(raw.get("PCI"), 0));
            obj.put("trackingAreaCode", toInt(raw.get("TAC"), 0));

            Object accuracy = raw.get("Accuracy");
            if (accuracy instanceof Number) {
                obj.put("gpsAccuracy", ((Number) accuracy).floatValue());
            }

            Object indoorOutdoor = raw.get("IndoorOutdoor");
            if (indoorOutdoor != null) {
                obj.put("indoorOutdoor", indoorOutdoor.toString());
            }
        } catch (Exception e) {
            Log.e(TAG, "Error building payload: " + e.getMessage());
        }
        return obj;
    }

    private static String valueOr(Object value, String fallback) {
        return value != null ? value.toString() : fallback;
    }

    private static int toInt(Object value, int fallback) {
        if (value instanceof Number) return ((Number) value).intValue();
        return fallback;
    }

    private static double toDouble(Object value, double fallback) {
        if (value instanceof Number) return ((Number) value).doubleValue();
        return fallback;
    }

    private static long toLong(Object value, long fallback) {
        if (value instanceof Number) return ((Number) value).longValue();
        return fallback;
    }
}
