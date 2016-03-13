var text = WScript.Arguments.Unnamed;



if (text.Count > 0) {

	var tts = WScript.CreateObject('SAPI.SpVoice');

	tts.Speak(text.item(0));

}


tts = null;

WScript.Quit(0);
