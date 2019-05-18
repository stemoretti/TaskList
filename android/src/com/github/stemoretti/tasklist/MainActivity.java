package com.github.stemoretti.tasklist;

import org.qtproject.qt5.android.bindings.QtActivity;

import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.speech.RecognizerIntent;
import android.widget.Toast;
import android.app.PendingIntent;
import android.content.Context;

import java.util.ArrayList;
import java.util.Locale;

public class MainActivity extends QtActivity {
    private Intent speechIntent;
    private Alarm alarm = new Alarm();

    public static native void sendResult(String text);

    public void setAlarm(int id, long time, String task) {
        alarm.setAlarm(this, id, time, task);
    }

    public void cancelAlarm(int id) {
        alarm.cancelAlarm(this, id);
    }

    public void getSpeechInput() {
        if (speechIntent == null) {
            speechIntent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
            speechIntent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
            speechIntent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault());
        }

        try {
            startActivityForResult(speechIntent, 10);
        } catch (ActivityNotFoundException a) {
            Toast.makeText(this, "Speech recognition not supported", Toast.LENGTH_SHORT).show();
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
