package com.github.stemoretti.tasklist;

import org.qtproject.qt5.android.bindings.QtActivity;

import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.speech.RecognizerIntent;
import android.widget.Toast;
import android.net.Uri;
import android.media.RingtoneManager;
import android.app.PendingIntent;
import android.app.Notification;
import android.app.NotificationManager;
import android.content.Context;

import java.util.ArrayList;
import java.util.Locale;

public class MainActivity extends QtActivity {
    private NotificationManager m_notificationManager;
    private Notification.Builder m_builder;
    private Intent m_intent;
    private Alarm m_alarm = new Alarm();

    public static native void sendResult(String text);

    public void setAlarm() {
        m_alarm.setAlarm(this);
    }

    public void cancelAlarm() {
        m_alarm.cancelAlarm(this);
    }

    public void notify(String s) {
        Uri soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        if (m_notificationManager == null) {
            m_notificationManager = (NotificationManager)getSystemService(Context.NOTIFICATION_SERVICE);
            PendingIntent notifyPIntent =
                PendingIntent.getActivity(getApplicationContext(), 0, new Intent(), 0);
            m_builder = new Notification.Builder(this)
                .setSmallIcon(R.drawable.icon)
                .setContentTitle("TaskList")
//                .setContentTitle(R.string.app_name)
                .setSound(soundUri)
                .setContentIntent(notifyPIntent)
                .setAutoCancel(true);
        }

        m_builder.setContentText(s);
        m_notificationManager.notify(1, m_builder.build());
    }

    public void getSpeechInput() {
        if (m_intent == null) {
            m_intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
            m_intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
            m_intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault());
        }

        try {
            startActivityForResult(m_intent, 10);
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
