import 'package:amplitude_flutter/amplitude.dart';

Future<void> amplitudeCheck(String pageInfo) async {
  final Amplitude analytics = Amplitude.getInstance(instanceName: "Blurting");
  // Log an event
  analytics.logEvent('SignUp question: $pageInfo',
      eventProperties: {'friend_num': 10, 'is_heavy_user': true});
}
