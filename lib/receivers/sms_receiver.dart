import 'package:flutter/widgets.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:telephony/telephony.dart' as telephony;

class SmsReceiver extends StatefulWidget {
  @override
  _SmsReceiverState createState() => _SmsReceiverState();
}

class _SmsReceiverState extends State<SmsReceiver> {
  final telephony.Telephony telephonyInstance = telephony.Telephony.instance;
  final FlutterSmsInbox _smsInbox = FlutterSmsInbox();
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    startListening();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }

  void startListening() {
    if (!isListening) {
      telephonyInstance.listenIncomingSms(
        onNewMessage: (telephony.SmsMessage smsMessage) {
          final String? messageBody = smsMessage.body;
          final String? sender = smsMessage.address;

          // Process the received SMS message here
          // You can use Flutter's debugPrint to print a quick message for testing purposes
          debugPrint('Received SMS: $messageBody from $sender');
        },
      );
      isListening = true;
    }
  }

  void stopListening() {
    if (isListening) {
      // Currently, there is no stopListeningIncomingSms method available
      // You can remove this method or handle the logic as per your requirement
      isListening = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // This widget doesn't need to have any UI, so we can return an empty container
    return Container();
  }
}
