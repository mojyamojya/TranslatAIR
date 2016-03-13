package jp.flashcast.translator.air.models
{
	[Bindable]
	public class TwitterModel
	{
		public var _tweet:Boolean;
		public var _tweeted:Boolean;
		private var _message:String;
		private var _account:String;
		private var _password:String;
		private var _status:String;
		private var _result:Boolean;
		
		public function TwitterModel()
		{
			_tweet = false;
			_tweeted = false;
			_result = false;
			_message = "";
			_account = "";
			_password = "";
		}
		
		public function set Tweet(tweet:Boolean):void {
			_tweet = tweet;
		}
		
		public function get Tweet():Boolean {
			return _tweet;
		}
		
		public function set Tweeted(tweeted:Boolean):void {
			_tweeted = tweeted;
		}
		
		public function get Tweeted():Boolean {
			return _tweeted;
		}
		
		public function set Message(message:String):void {
			_message = message;
		}
		
		public function get Message():String {
			return _message;
		}
		
		public function set Account(account:String):void {
			_account = account;
		}
		
		public function get Account():String {
			return _account;
		}
		
		public function set Password(password:String):void {
			_password = password;
		}
		
		public function get Password():String {
			return _password;
		}
		
		public function set Status(status:String):void {
			_status = status;
		}
		
		public function get Status():String {
			return _status;
		}
		
		public function set Result(result:Boolean):void {
			_result = result;
		}
		
		public function get Result():Boolean {
			return _result;
		}

	}
}