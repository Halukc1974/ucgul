package com.program.ucgul1

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.program.ucgul1/notifications"
    private val notificationChannelId = "birthday_channel"
    private lateinit var notificationManager: NotificationManager

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initializeNotifications" -> {
                    createNotificationChannel()
                    result.success(true)
                }
                "showNotification" -> {
                    val title = call.argument<String>("title")
                    val body = call.argument<String>("body")
                    val id = call.argument<Int>("id") ?: 0

                    if (title != null && body != null) {
                        showNotification(id, title, body)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Title and body must not be null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Doğum Günü Bildirimleri"
            val descriptionText = "Doğum günü hatırlatmaları için bildirim kanalı"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(notificationChannelId, name, importance).apply {
                description = descriptionText
            }
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun showNotification(id: Int, title: String, body: String) {
        val builder = NotificationCompat.Builder(this, notificationChannelId)
            .setSmallIcon(com.program.ucgul1.R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)

        notificationManager.notify(id, builder.build())
    }
}
