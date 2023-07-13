package com.example.sms_encry

import android.content.BroadcastReceiver
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.provider.Telephony
import android.telephony.SmsMessage
import android.widget.Toast
import android.os.Build
import android.app.NotificationManager
import android.app.NotificationChannel
import androidx.core.app.NotificationCompat
import DatabaseHelper

class SmsReceiver : BroadcastReceiver() {
    private lateinit var databaseHelper: DatabaseHelper
    public val CHANNEL = "com.example.sms_encry.database"


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
                        Toast.makeText(context, "Received SMS from $sender", Toast.LENGTH_SHORT).show()

                        // Save the SMS message to the database
                        saveSmsToDatabase(context, sender, messageBody)

                        // Create and display a notification
                        createNotification(context!!, sender)
                    }
                }
            }
        }
    }

    private fun saveSmsToDatabase(context: Context?, sender: String, messageBody: String): Boolean {
        if (context == null) return false

        if (!::databaseHelper.isInitialized) {
            databaseHelper = DatabaseHelper(context)
        }
        val db = databaseHelper.writableDatabase
        val contentValues = ContentValues().apply {
            put("sender", sender)
            put("message_body", messageBody)
            
        }
        val result = db.insert("sms_table", null, contentValues) != -1L
        db.close()

        return result
    }

    private fun createNotification(context: Context, sender: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "sms_notification_channel",
                "SMS Notifications",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val notificationManager = context.getSystemService(NotificationManager::class.java)
            notificationManager?.createNotificationChannel(channel)
        }

        val notificationBuilder = NotificationCompat.Builder(context, "sms_notification_channel")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("New SMS")
            .setContentText("Received SMS from $sender")
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)

        val notificationManager = context.getSystemService(NotificationManager::class.java)
        notificationManager?.notify(123, notificationBuilder.build())
    }

    companion object {
        fun register(context: Context) {
            val filter = IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION)
            val receiver = SmsReceiver()
            context.registerReceiver(receiver, filter)
        }

        fun unregister(context: Context) {
            val receiver = SmsReceiver()
            context.unregisterReceiver(receiver)
        }
    }
}