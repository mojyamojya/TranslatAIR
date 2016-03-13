package jp.flashcast.translator.air.models
{
	[Bindable]
	public class TranslateModel
	{
		public var _original:String;
		public var _translated:String;
		public var _languageFrom:String;
		public var _languageTo:String;
		private var _datetime:String;
		private var _translate:Boolean;
		private var _result:Boolean;
		public var _callback:Boolean;
		
		public function TranslateModel()
		{
			_original = "";
			_translated = "";
			_languageFrom = "";
			_languageTo = "";
			_datetime = "";
			_translate = false;
			_result = false;
			_callback = false;
		}
		
		public function set Original(original:String):void {
			_original = original;
		}
		
		public function get Original():String {
			return _original;
		}
		
		public function set Translated(translated:String):void {
			_translated = translated;
		}
		
		public function get Translated():String {
			return _translated;
		}
		
		public function set Translate(translate:Boolean):void {
			_translate = translate;
		}
		
		public function get Translate():Boolean {
			return _translate;
		}
		
		public function set Result(result:Boolean):void {
			_result = result;
		}
		
		public function get Result():Boolean {
			return _result;
		}
		
		public function set LanguageFrom(languageFrom:String):void {
			_languageFrom = languageFrom;
		}
		
		public function get LanguageFrom():String {
			return _languageFrom;
		}
		
		public function set LanguageTo(languageTo:String):void {
			_languageTo = languageTo;
		}
		
		public function get LanguageTo():String {
			return _languageTo;
		}
		
		public function set DateTime(datetime:String):void {
			_datetime = datetime;
		}
		
		public function get DateTime():String {
			return _datetime;
		}
		
		public function set Callback(callback:Boolean):void {
			_callback = callback;
		}
		
		public function get Callback():Boolean {
			return _callback;
		}

	}
}