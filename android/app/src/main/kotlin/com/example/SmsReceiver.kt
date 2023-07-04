package com.example.sms_encry

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.telephony.SmsMessage
import android.widget.Toast
import android.os.Build
import android.app.NotificationManager
import android.app.NotificationChannel
import androidx.core.app.NotificationCompat

class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val bundle = intent.extras
            if (bundle != null) {
                val pdus = bundle.get("pdus") as? Array<Any>
                if (pdus != null) {
                    for (pdu in pdus) {
                        val smsMessage = SmsMessage.createFromPdu(pdu as ByteArray)
                        val messageBody = smsMessage.messageBody
                        val sender = smsMessage.displayOriginatingAddress
                        // Process the received SMS message here
                        // Extract the SMS data from the intent and handle it as needed
                        // You can use Toast to display a quick message for testing purposes
                        Toast.makeText(context, "Received SMS: $messageBody from $sender", Toast.LENGTH_SHORT).show()
                        // Create and display a notification
                        createNotification(context!!, sender, messageBody)
                    }
                }
            }
        }
    }

    private fun createNotification(context: Context, sender: String, messageBody: String) {
        // Create a notification channel for Android Oreo and above
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "sms_notification_channel",
                "SMS Notifications",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val notificationManager = context?.getSystemService(NotificationManager::class.java)
            notificationManager?.createNotificationChannel(channel)
        }

        // Create the notification
        val notificationBuilder = NotificationCompat.Builder(context, "sms_notification_channel")
            // .setSmallIcon(R.drawable.notification_icon)
            .setContentTitle("New SMS")
            .setContentText("Received SMS from $sender: $messageBody")
            // .setColor(ContextCompat.getColor(context, R.color.notification_color))
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)

        // Display the notification
        val notificationManager = context.getSystemService(NotificationManager::class.java)
        notificationManager?.notify(123, notificationBuilder.build())
    }
}
