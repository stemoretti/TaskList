package com.github.stemoretti.tasklist;

import org.qtproject.qt.android.bindings.QtActivity;

import android.Manifest;
import android.app.PendingIntent;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.speech.RecognizerIntent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager.LayoutParams;
import android.widget.Toast;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.Locale;

public class MainActivity extends QtActivity {
    private Intent speechIntent;
    private Alarm alarm = new Alarm();

    public static native void sendResult(String text);

    public void setStatusBarColor(final int color, final int navbg, final boolean tbp, final boolean dark) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Window window = getWindow();
                window.addFlags(LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
                window.clearFlags(LayoutParams.FLAG_TRANSLUCENT_STATUS);
                window.setStatusBarColor(color);
                window.setNavigationBarColor(navbg);
                if (dark) {
                    int flags = ~View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR & ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
                    View decorView = window.getDecorView();
                    decorView.setSystemUiVisibility(decorView.getSystemUiVisibility() & flags);
                } else if (tbp) {
                    View decorView = window.getDecorView();
                    decorView.setSystemUiVisibility(decorView.getSystemUiVisibility() & ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
                    window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR);
                } else {
                    int flags = View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR | View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
                    window.getDecorView().setSystemUiVisibility(flags);
                }
            }
        });
    }

    public void setAlarm(int id, long time, String task) {
        alarm.setAlarm(this, id, time, task);
    }

    public void cancelAlarm(int id) {
        alarm.cancelAlarm(this, id);
    }

    public void getSpeechInput(String lang) {
        if (speechIntent == null) {
            speechIntent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
            speechIntent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                                  RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
        }

        speechIntent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, lang.replace("_", "-"));

        try {
            startActivityForResult(speechIntent, 10);
        } catch (ActivityNotFoundException a) {
            Toast.makeText(this, "Speech recognition not supported", Toast.LENGTH_SHORT).show();
        }
    }

    public void checkPermissions() {
        ArrayList<String> permissionsList = new ArrayList<String>();

        permissionsList.add(Manifest.permission.WAKE_LOCK);
        permissionsList.add(Manifest.permission.SET_ALARM);

        Iterator it = permissionsList.iterator();
        while (it.hasNext()) {
            int s = ContextCompat.checkSelfPermission(this, (String)it.next());
            if (s == PackageManager.PERMISSION_GRANTED)
                it.remove();
        }

        if (permissionsList.size() > 0) {
            String[] permissions = new String[permissionsList.size()];
            permissionsList.toArray(permissions);
            ActivityCompat.requestPermissions(this, permissions, 101);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
        case 10:
            if (resultCode == RESULT_OK && data != null) {
                ArrayList<String> result = data.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS);
                sendResult(result.get(0));
            }
            break;
        }
        super.onActivityResult(requestCode, resultCode, data);
    }
}
