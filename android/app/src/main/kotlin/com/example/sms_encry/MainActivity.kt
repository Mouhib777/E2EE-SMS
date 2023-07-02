package com.example.sms_encry

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import android.provider.Telephony
import android.widget.Toast
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.example.sms_encry"
    private val SMS_RECEIVED_ACTION = "android.provider.Telephony.SMS_RECEIVED"

    private val smsReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == SMS_RECEIVED_ACTION) {
                val bundle = intent.extras
                if (bundle != null) {
                    val pdus = bundle.get("pdus") as Array<Any>?
                    if (pdus != null) {
                        for (pdu in pdus) {
                            val smsMessage = Telephony.Sms.Intents.getMessagesFromIntent(intent)[0]
                            val messageBody = smsMessage.messageBody
                            val sender = smsMessage.displayOriginatingAddress
                            // Process the received SMS message here
                            // Extract the SMS data from the intent and handle it as needed
                            // You can use Toast to display a quick message for testing purposes
                            Toast.makeText(context, "Received SMS: $messageBody from $sender", Toast.LENGTH_SHORT).show()
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
        registerReceiver(smsReceiver, intentFilter)
    }

    override fun onDestroy() {
        super.onDestroy()

        // Unregister the SMS receiver
        unregisterReceiver(smsReceiver)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setDefaultSms") {
                try {
                    val intent = Intent(Telephony.Sms.Intents.ACTION_CHANGE_DEFAULT)
                    intent.putExtra(Telephony.Sms.Intents.EXTRA_PACKAGE_NAME, packageName)
                    startActivity(intent)
                    result.success("Success t7atet app as default SMS app")
                } catch (ex: Exception) {
                    result.error("UNAVAILABLE", "Setting default sms.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
