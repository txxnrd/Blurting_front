
class ServerEndpoints {
  static const String serverEndpoint = "http://54.180.85.164:3080";
}

class API {
  static const String sendphone = "${ServerEndpoints.serverEndpoint}/auth/signup/phonenumber";
  static const String checkphone = "${ServerEndpoints.serverEndpoint}/auth/check/phone";
  static const String checkemail = "${ServerEndpoints.serverEndpoint}/auth/check/email";
  static const String signup = "${ServerEndpoints.serverEndpoint}/auth/signup";
  static const String refresh = "${ServerEndpoints.serverEndpoint}/auth/refresh";
  static const String signupimage = "${ServerEndpoints.serverEndpoint}/auth/signup/images";

}