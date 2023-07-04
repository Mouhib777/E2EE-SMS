package com.example.sms_encry

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.telephony.SmsMessage
import android.widget.Toast

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
        // TODO: Implement your notification creation logic here
    }
}
