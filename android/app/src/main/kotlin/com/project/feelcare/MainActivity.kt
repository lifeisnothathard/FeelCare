package com.project.feelcare

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.NotificationChannelCompat


class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val channel = NotificationChannelCompat.Builder(
            "high_importance_channel",
            NotificationManagerCompat.IMPORTANCE_HIGH
        )
            .setName("High Importance Notifications")
            .setDescription("Notifications for important messages")
            .build()

        NotificationManagerCompat.from(this)
            .createNotificationChannel(channel)
    }
}
