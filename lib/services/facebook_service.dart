import 'package:facebook_app_events/facebook_app_events.dart';

class FacebookService
{

  static final facebookAppEvents = FacebookAppEvents();

  static Future<void> logEvent (String eventKey,Map<String,String> parameters)
  async {
    await facebookAppEvents.logEvent(name: eventKey,parameters: parameters).whenComplete(()
    {
      print('FACEBOOK_TEST: '+'Successfully Sent loginEvent');
    }).onError((error, isError)
    {
      print('FACEBOOK_TEST: '+error.toString());

    });
  }

  static Future<void> setUserData(String email, String fullName)
  async{
    await facebookAppEvents.setUserData(
      email: email,
      firstName: fullName
    );
  }


}

class FacebookEvents {

  static final String EVENT1 = "test_event_one";

}