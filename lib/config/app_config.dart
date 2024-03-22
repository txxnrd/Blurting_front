import 'package:flutter_dotenv/flutter_dotenv.dart';

class ServerEndpoints {
  static final String? serverEndpoint = dotenv.env['API_ADDRESS'];
  static const String socketServerEndpoint = "ws://13.124.149.234:3080";
}

class API {
  /*signup 과정에서 필요한 api */
  static final String sendphone =
      "${ServerEndpoints.serverEndpoint}/auth/signup/phonenumber";
  static final String version =
      "${ServerEndpoints.serverEndpoint}/home/version";
  static final String alreadyuser =
      "${ServerEndpoints.serverEndpoint}/auth/already/signed";
  static final String alreadyusercheck =
      "${ServerEndpoints.serverEndpoint}/auth/alreay/signed/check";
  static final String checkphone =
      "${ServerEndpoints.serverEndpoint}/auth/check/phone";
  static final String checkemail =
      "${ServerEndpoints.serverEndpoint}/auth/check/email";
  static final String signup = "${ServerEndpoints.serverEndpoint}/auth/signup";
  static final String signupemail =
      "${ServerEndpoints.serverEndpoint}/auth/signup/email";
  static final String signupback =
      "${ServerEndpoints.serverEndpoint}/auth/signup/back";
  static final String refresh =
      "${ServerEndpoints.serverEndpoint}/auth/refresh";
  static final String signupimage =
      "${ServerEndpoints.serverEndpoint}/auth/signup/images";
  static final String uploadimage = "${ServerEndpoints.serverEndpoint}/s3";
  static final String startsignup =
      "${ServerEndpoints.serverEndpoint}/auth/signup/start";
  static final String user = "${ServerEndpoints.serverEndpoint}/user";
  static final String userupdate =
      "${ServerEndpoints.serverEndpoint}/user/update";
  static final String userprofile =
      "${ServerEndpoints.serverEndpoint}/user/profile";
  static final String notification =
      "${ServerEndpoints.serverEndpoint}/user/notification";
  static final String testfcm =
      "${ServerEndpoints.serverEndpoint}/user/testfcm";

  /*현재 위치 불러오기*/
  static final String geobyname =
      "${ServerEndpoints.serverEndpoint}/geocoding/search/district/by-name";
  static final String geobygeo =
      "${ServerEndpoints.serverEndpoint}/geocoding/search/district/by-geo";
  /*HOME */
  static final String homeLike = "${ServerEndpoints.serverEndpoint}/home/like";
  static final String home = "${ServerEndpoints.serverEndpoint}/home";

  static final String alarm = "${ServerEndpoints.serverEndpoint}/fcm";
  /*BLURTING */
  static final String matching = "${ServerEndpoints.serverEndpoint}/blurting";
  static final String latest =
      "${ServerEndpoints.serverEndpoint}/blurting/latest";
  static final String answerNo = "${ServerEndpoints.serverEndpoint}/blurting/";
  static final String answer =
      "${ServerEndpoints.serverEndpoint}/blurting/answer";
  static final String reply =
      "${ServerEndpoints.serverEndpoint}/blurting/reply";
  static final String register =
      "${ServerEndpoints.serverEndpoint}/blurting/register";
  static final String like = "${ServerEndpoints.serverEndpoint}/blurting/like/";
  static final String blurtingInfo =
      "${ServerEndpoints.serverEndpoint}/blurting/group-info";
  static final String result =
      "${ServerEndpoints.serverEndpoint}/blurting/result";
  /*ARROW */
  static final String sendArrow =
      "${ServerEndpoints.serverEndpoint}/blurting/arrow/";
  static final String myArrow =
      "${ServerEndpoints.serverEndpoint}/blurting/arrow";
  /*WHISPER */
  static final String roomList = "${ServerEndpoints.serverEndpoint}/chat/rooms";
  static final String chatList = "${ServerEndpoints.serverEndpoint}/chat/";
  static final String chatProfile =
      "${ServerEndpoints.serverEndpoint}/chat/profile/";
  /*POINT */
  static final String pointchat =
      "${ServerEndpoints.serverEndpoint}/point/chat";
  static final String pointcheck =
      "${ServerEndpoints.serverEndpoint}/point/check";
  static final String getpoint = "${ServerEndpoints.serverEndpoint}/point/ad";
  /*ETC*/
  static final String userpoint = "${ServerEndpoints.serverEndpoint}/user";
  static final String pointAd = "${ServerEndpoints.serverEndpoint}/point/ad";
  static final String pointAdd = "${ServerEndpoints.serverEndpoint}/point/add";

  static final String pointSub = "${ServerEndpoints.serverEndpoint}/point/sub";
  static final String disable = "${ServerEndpoints.serverEndpoint}/fcm/disable";
  static final String fcmcheck = "${ServerEndpoints.serverEndpoint}/fcm/check";
  static final String userinfo =
      "${ServerEndpoints.serverEndpoint}/user/account";
  static final String nickname =
      "${ServerEndpoints.serverEndpoint}/point/nickname";
  /*EVENT */
  static final event = "${ServerEndpoints.serverEndpoint}/event";
  static final eventLatest = "${ServerEndpoints.serverEndpoint}/event/latest";
  static final eventRegister = "${ServerEndpoints.serverEndpoint}/event/register";
  static final eventNo = "${ServerEndpoints.serverEndpoint}/event/";
  static final eventAnwer = "${ServerEndpoints.serverEndpoint}/event/answer";
  static final eventResult = "${ServerEndpoints.serverEndpoint}/event/result";
  static final eventOff = "${ServerEndpoints.serverEndpoint}/event/meeting/";
  static final eventInfo = "${ServerEndpoints.serverEndpoint}/event/group-info";
  static final eventSendArrow = "${ServerEndpoints.serverEndpoint}/event/arrow/";
  static final eventArrow = "${ServerEndpoints.serverEndpoint}/event/arrow";
  static final eventEnd = "${ServerEndpoints.serverEndpoint}/event/end";
  static final eventOffCheck = "${ServerEndpoints.serverEndpoint}/event/meeting/check";
}
