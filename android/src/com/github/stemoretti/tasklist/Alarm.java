package com.github.stemoretti.tasklist;

import android.app.AlarmManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.PowerManager;
import android.net.Uri;
import android.media.RingtoneManager;

import androidx.core.app.NotificationCompat;

public class Alarm extends BroadcastReceiver
{
    private NotificationManager notificationManager;
    private NotificationCompat.Builder builder;

    @Override
    public void onReceive(Context context, Intent intent)
    {
        PowerManager pm = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
        PowerManager.WakeLock wl = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "");
        wl.acquire();

        if (notificationManager == null) {
            notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            PendingIntent notifyPIntent = PendingIntent.getActivity(context, 0, new Intent(), 0);
            Uri soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);

            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                int importance = NotificationManager.IMPORTANCE_DEFAULT;
                NotificationChannel nc = new NotificationChannel("ID", "Name", importance);
                notificationManager.createNotificationChannel(nc);
                builder = new NotificationCompat.Builder(context, nc.getId());
            } else {
                builder = new NotificationCompat.Builder(context);
            }
            builder = builder
                .setSmallIcon(R.drawable.icon)
                .setContentTitle("TaskList")
                .setSound(soundUri)
                .setContentIntent(notifyPIntent)
                .setAutoCancel(true);
        }

        builder.setContentText(intent.getStringExtra("task"));
        notificationManager.notify(intent.getIntExtra("id", 1), builder.build());

        wl.release();
    }

    public void setAlarm(Context context, int id, long time, String task)
    {
        AlarmManager am = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        Intent i = new Intent(context, Alarm.class);
        i.putExtra("id", id);
        i.putExtra("task", task);
        PendingIntent pi = PendingIntent.getBroadcast(context, id, i, PendingIntent.FLAG_UPDATE_CURRENT);
        am.set(AlarmManager.RTC_WAKEUP, time, pi);
    }

    public void cancelAlarm(Context context, int id)
    {
        Intent i = new Intent(context, Alarm.class);
        PendingIntent pi = PendingIntent.getBroadcast(context, id, i, 0);
        AlarmManager am = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        am.cancel(pi);
    }
}
