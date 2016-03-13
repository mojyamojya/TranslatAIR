package jp.flashcast.translator.air.models
{
	[Bindable]
	public class ConfigModel
	{
		private var _version:String;
		private var _languageFrom:String;
		private var _languageTo:String;
		public var _clipmode:Boolean;
		public var _translate:Boolean;
		public var _tweet:Boolean;
		private var _account:String;
		private var _password:String;
		public var _delayIcon:int;
		public var _delayAlpha:int;
		public var _alpha:Number;
		public var tx:int;
		public var ty:int;
		public var hx:int;
		public var hy:int;
		public var cx:int;
		public var cy:int;
		public var ax:int;
		public var ay:int;
		
		public function ConfigModel()
		{
			_version = "1.0";
			_languageFrom = "en";
			_languageTo = "ja";
			_clipmode = false;
			_translate = false;
			_tweet = false;
			_account = "";
			_password = "";
			_delayIcon = 8000;
			_delayAlpha = 50;
			_alpha = 1.1;
			tx = 100;
			ty = 100;
			hx = 100;
			hy = 100;
			cx = 100;
			cy = 100;
			ax = 100;
			ay = 100;
		}
		
		public function set Version(version:String):void {
			_version = version;
		}
		
		public function get Version():String {
			return _version;
		}
		
		public function set LanguageFrom(language:String):void {
			_languageFrom = language;
		}
		
		public function get LanguageFrom():String {
			return _languageFrom;
		}
		
		public function set LanguageTo(language:String):void {
			_languageTo = language;
		}
		
		public function get LanguageTo():String {
			return _languageTo;
		}
		
		public function set Clipmode(clipmode:Boolean):void {
			_clipmode = clipmode;
		}
		
		public function get Clipmode():Boolean {
			return _clipmode;
		}
		
		public function set Translate(translate:Boolean):void {
			_translate = translate;
		}
		
		public function get Translate():Boolean {
			return _translate;
		}
		
		public function set Tweet(tweet:Boolean):void {
			_tweet = tweet;
		}
		
		public function get Tweet():Boolean {
			return _tweet;
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
		
		public function set DelayIcon(delay:int):void {
			_delayIcon = delay;
		}
		
		public function get DelayIcon():int {
			return _delayIcon;
		}
		
		public function set DelayAlpha(delay:int):void {
			_delayAlpha = delay;
		}
		
		public function get DelayAlpha():int {
			return _delayAlpha;
		}
		
		public function set Alpha(alpha:Number):void {
			_alpha = alpha;
		}
		
		public function get Alpha():Number {
			return _alpha;
		}
		
		public function set Tx(x:int):void {
			tx = x;
		}
		
		public function get Tx():int {
			return tx;
		}
		
		public function set Ty(y:int):void {
			ty = y;
		}
		
		public function get Ty():int {
			return ty;
		}
		
		public function set Hx(x:int):void {
			hx = x;
		}
		
		public function get Hx():int {
			return hx;
		}
		
		public function set Hy(y:int):void {
			hy = y;
		}
		
		public function get Hy():int {
			return hy;
		}
		
		public function set Cx(x:int):void {
			cx = x;
		}
		
		public function get Cx():int {
			return cx;
		}
		
		public function set Cy(y:int):void {
			cy = y;
		}
		
		public function get Cy():int {
			return cy;
		}
		
		public function set Ax(x:int):void {
			ax = x;
		}
		
		public function get Ax():int {
			return ax;
		}
		
		public function set Ay(y:int):void {
			ay = y;
		}
		
		public function get Ay():int {
			return ay;
		}

	}
}