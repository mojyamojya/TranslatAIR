package jp.flashcast.translator.air.models
{
	import flash.net.SharedObject;
	
	public class XAuthModel
	{
		private static var access_token_url:String = "https://api.twitter.com/oauth/access_token"
		private static var consumer_key:String = "Your own consumer key.";
		private static var consumer_secret:String = "Your own consumer secret key.";
		private var oauth_token:String;
		private var oauth_token_secret:String;
		private var oauth_signature:String;
		private var _save:Boolean;
		
		public function XAuthModel()
		{
			oauth_token = "";
			oauth_token_secret = "";
			oauth_signature = "";
			_save = false;
		}
		
		public function initXAuthModel():void {
			var so:SharedObject = SharedObject.getLocal("jp.flashcast.translator.air.twitter");
			var oauth_token:Object = so.data["oauth_token"];
			var oauth_token_secret:Object = so.data["oauth_token_secret"];
			
			if (so.data["oauth_token"] != null) {
				if (so.data["oauth_token"].toString().length) {
					OAuthToken = so.data["oauth_token"].toString();
				}
			}
			if (so.data["oauth_token_secret"] != null) {
				if (so.data["oauth_token_secret"].toString().length) {
					OAuthTokenSecret = so.data["oauth_token_secret"];
				}
			}
		}
		
		public function get AccessTokenUrl():String {
			return access_token_url;
		}
		
		public function set OAuthSignature(signature:String):void {
			oauth_signature = signature;
		}
		
		public function get OAuthSignature():String {
			return oauth_signature;
		}
		
		public function set OAuthToken(token:String):void {
			oauth_token = token;
		}
		
		public function get OAuthToken():String {
			return oauth_token;
		}
		
		public function set OAuthTokenSecret(secret:String):void {
			oauth_token_secret = secret;
		}
		
		public function get OAuthTokenSecret():String {
			return oauth_token_secret;
		}
		
		public function get ConsumerKey():String {
			return consumer_key;
		}
		
		public function get ConsumerSecret():String {
			return consumer_secret;
		}
		
		public function set isSave(save:Boolean):void {
			_save = save;
		}
		
		public function get isSave():Boolean {
			return _save;
		}

	}
}