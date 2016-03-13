package jp.flashcast.translator.air.managers
{
	import com.adobe.serialization.json.JSON;
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.hash.HMAC;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;
	
	import flash.net.SharedObject;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	import jp.flashcast.translator.air.models.ConfigModel;
	import jp.flashcast.translator.air.models.TwitterModel;
	import jp.flashcast.translator.air.models.XAuthModel;
	import jp.flashcast.translator.air.util.Locale;
	import jp.flashcast.translator.air.util.URLEncoding;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.utils.UIDUtil;
	
	public class TwitterManager
	{
		private static var status_update_url:String = "http://twitter.com/statuses/update.json"
		private var requestTokenService:HTTPService;;
		private var updateService:HTTPService;
		private var _tmodel:TwitterModel;
		private var _xmodel:XAuthModel;
		private var _fmodel:ConfigModel
		
		public function TwitterManager()
		{
		}
		
		public function initTwitterManager(tmodel:TwitterModel, xmodel:XAuthModel, fmodel:ConfigModel):void {
			_tmodel = tmodel;
			_xmodel = xmodel;
			_fmodel = fmodel;
		}
		
		public function Tweet():void {
			if (!_xmodel.OAuthToken.toString().length ||
				!_xmodel.OAuthTokenSecret.toString().length) {
				getAuthToken();
			}
			else {
				setStatus();
			}
		}

		private function getAuthToken():void {
			if (requestTokenService == null) {
				requestTokenService = new HTTPService();
				requestTokenService.method = "POST";
				requestTokenService.url = _xmodel.AccessTokenUrl;
			}
			requestTokenService.addEventListener(ResultEvent.RESULT, onAuthTokenResult);
			requestTokenService.addEventListener(FaultEvent.FAULT, onAuthTokenFault);
			
			var forms:URLVariables = new URLVariables();
			forms.x_auth_mode = "client_auth";
			forms.x_auth_password = _tmodel.Password;
			forms.x_auth_username = _tmodel.Account;
			forms.oauth_signature = getSignature(requestTokenService.method, requestTokenService.url, forms);
			
 			requestTokenService.request = forms;
			requestTokenService.send();
		}
		
		private function onAuthTokenResult(event:ResultEvent):void {
			var results:Array  = event.result.toString().split("&");
			
			for each (var token:String in results) {
				if (_xmodel.OAuthToken == "" || _xmodel.OAuthTokenSecret == "") {
					var values:Array = token.split("=");
					
					if (values.length == 2) {
						if (values[0] == "oauth_token") {
							_xmodel.OAuthToken = values[1];
						}
						else if (values[0] == "oauth_token_secret") {
							_xmodel.OAuthTokenSecret = values[1];
						}
						else {
							continue;
						}
					}
				}
				else {
					break;
				}
			}
			
			if (_xmodel.isSave) {
				var so:SharedObject = SharedObject.getLocal("jp.flashcast.translator.air.twitter");
				
				if (so.data["oauth_token"] == null || so.data["oauth_token_secret"] == null) {
					so.data["oauth_token"] = _xmodel.OAuthToken;
					so.data["oauth_token_secret"] = _xmodel.OAuthTokenSecret;
				}
				else {
					if (!so.data["oauth_token"].toString().length ||
						!so.data["oauth_token_secret"].toString().length) {
						so.data["oauth_token"] = _xmodel.OAuthToken;
						so.data["oauth_token_secret"] = _xmodel.OAuthTokenSecret;
					}
				}
			}
			
			requestTokenService.removeEventListener(ResultEvent.RESULT, onAuthTokenResult);
			requestTokenService.removeEventListener(FaultEvent.FAULT, onAuthTokenFault);
			
			setStatus();
		}
		
		private function onAuthTokenFault(event:FaultEvent):void {
			_tmodel.Message = Locale.localize("投稿失敗...") + "\n" + event.fault.toString();
			_tmodel.Account = "";
			_tmodel.Password = "";
			_tmodel.Tweet = false;
			_tmodel.Tweeted = true;
			
			requestTokenService.removeEventListener(ResultEvent.RESULT, onAuthTokenResult);
			requestTokenService.removeEventListener(FaultEvent.FAULT, onAuthTokenFault);
			
			_xmodel.isSave = false;
		}
		
		private function getSignature(method:String, url:String, forms:URLVariables):String {
			var now:Date = new Date();
			
			forms.oauth_consumer_key = _xmodel.ConsumerKey;
			forms.oauth_nonce = UIDUtil.getUID(now);
			forms.oauth_signature_method = "HMAC-SHA1";
			forms.oauth_timestamp = now.time.toString().substring(0, 10);
			forms.oauth_version = "1.0";
			if (_xmodel.OAuthToken.length) {
				forms.oauth_token = _xmodel.OAuthToken; 
			}
			
			var sortArr:Array = UrlVariablesToArray(forms);
			var sigBase:String = URLEncoding.encode(method) + "&" +  URLEncoding.encode(url)  + "&" + URLEncoding.encode(sortArr.join("&"));
			var sigkeybase:String = URLEncoding.encode(_xmodel.ConsumerSecret) + "&";
			if (_xmodel.OAuthTokenSecret.length){
				sigkeybase += URLEncoding.encode(_xmodel.OAuthTokenSecret);
			}
			
			var hmac:HMAC = Crypto.getHMAC("sha1");
			var sig_key:ByteArray = Hex.toArray(Hex.fromString(sigkeybase));
			
			var data:ByteArray = Hex.toArray(Hex.fromString(sigBase));
			var signature:String = Base64.encodeByteArray(hmac.compute(sig_key, data));
				
			return signature;
		}
		
		private function UrlVariablesToArray(variables:URLVariables):Array{
			var arr:Array = new Array();
			for(var key:String in variables){
				arr.push(key + "=" + URLEncoding.encode(variables[key]));
			}
			arr.sort();
			return arr;
		}
		
		private function setStatus():void {
			if (updateService == null) {
				updateService = new HTTPService;
				updateService.method = "POST";
				updateService.url = status_update_url;
				updateService.resultFormat = "text";
			}
			updateService.addEventListener(ResultEvent.RESULT, onResult);
			updateService.addEventListener(FaultEvent.FAULT, onFault);

			var forms:URLVariables = new URLVariables();
			forms.status = _tmodel.Status;
			forms.oauth_signature = getSignature(updateService.method, updateService.url, forms);
			updateService.request = forms;
			updateService.send();
			
			_tmodel.Tweet = false;
		}
		
		private function onResult(event:ResultEvent):void {
			var json:Object = JSON.decode(event.result.toString());
			_tmodel.Message = Locale.localize("翻訳した文章をtwitterに投稿しました。");
			_tmodel.Result = true;
			_tmodel.Tweeted = true;
			
			updateService.removeEventListener(ResultEvent.RESULT, onResult);
			updateService.removeEventListener(FaultEvent.FAULT, onFault);
		}
		
		private function onFault(event:FaultEvent):void {
			_tmodel.Message = Locale.localize("投稿失敗...") + "\n" + event.fault.toString();
			_tmodel.Tweeted = true;
			
			updateService.removeEventListener(ResultEvent.RESULT, onResult);
			updateService.removeEventListener(FaultEvent.FAULT, onFault);
		}

	}
}