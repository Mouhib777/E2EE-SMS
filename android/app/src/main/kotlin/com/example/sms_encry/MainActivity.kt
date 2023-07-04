package com.example.sms_encry

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import android.provider.Telephony
import android.widget.Toast
import android.telephony.SmsMessage
import androidx.annotation.NonNull
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    public val CHANNEL = "com.example.sms_encry"
    public val SMS_RECEIVED_ACTION = "android.provider.Telephony.SMS_RECEIVED"

    public val SmsReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == SMS_RECEIVED_ACTION) {
                val bundle = intent.extras
                if (bundle != null) {
                    val pdus = bundle?.get("pdus") as? Array<SmsMessage>
                    if (pdus != null) {
                        for (pdu in pdus) {
                            val smsMessage = Telephony.Sms.Intents.getMessagesFromIntent(intent)[0]
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
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Check if the app is already set as the default SMS app
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            if (Telephony.Sms.getDefaultSmsPackage(this) != packageName) {
                // Prompt the user to make this app the default SMS app
                val intent = Intent(Telephony.Sms.Intents.ACTION_CHANGE_DEFAULT)
                intent.putExtra(Telephony.Sms.Intents.EXTRA_PACKAGE_NAME, packageName)
                startActivity(intent)
            }
        }

        // Register the SMS receiver
        val intentFilter = IntentFilter(SMS_RECEIVED_ACTION)
        registerReceiver(SmsReceiver, intentFilter)
    }

    override fun onDestroy() {
        super.onDestroy()

        // Unregister the SMS receiver
        unregisterReceiver(SmsReceiver)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setDefaultSms") {
                try {
                    val intent = Intent(Telephony.Sms.Intents.ACTION_CHANGE_DEFAULT)
                    intent.putExtra(Telephony.Sms.Intents.EXTRA_PACKAGE_NAME, packageName)
                    startActivity(intent)
                    result.success("Successfully set the app as the default SMS app.")
                } catch (ex: Exception) {
                    result.error("UNAVAILABLE", "Failed to set the default SMS app.", null)
                }
            } else {
                result.notImplemented()
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
