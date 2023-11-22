class ServerEndpoints {
  static const String serverEndpoint = "https://api.blurting.devkor.club";
  static const String socketServerEndpoint = "ws://api.blurting.devkor.club";

}

class API {
  /*signup 과정에서 필요한 api */
  static const String sendphone = "${ServerEndpoints.serverEndpoint}/auth/signup/phonenumber";
  static const String checkphone = "${ServerEndpoints.serverEndpoint}/auth/check/phone";
  static const String checkemail = "${ServerEndpoints.serverEndpoint}/auth/check/email";
  static const String signup = "${ServerEndpoints.serverEndpoint}/auth/signup";
  static const String signupemail = "${ServerEndpoints.serverEndpoint}/auth/signup/email";
  static const String signupback = "${ServerEndpoints.serverEndpoint}/auth/signup/back";
  static const String refresh = "${ServerEndpoints.serverEndpoint}/auth/refresh";
  static const String signupimage = "${ServerEndpoints.serverEndpoint}/auth/signup/images";
  static const String uploadimage = "${ServerEndpoints.serverEndpoint}/s3";
  static const String startsignup = "${ServerEndpoints.serverEndpoint}/auth/signup/start";
  static const String user = "${ServerEndpoints.serverEndpoint}/user";
  static const String userupdate = "${ServerEndpoints.serverEndpoint}/user/update";
  static const String userprofile = "${ServerEndpoints.serverEndpoint}/user/profile";
  /*현재 위치 불러오기*/
  static const String geobyname = "${ServerEndpoints.serverEndpoint}/geocoding/search/district/by-name";
  static const String geobygeo = "${ServerEndpoints.serverEndpoint}/geocoding/search/district/by-geo";




}