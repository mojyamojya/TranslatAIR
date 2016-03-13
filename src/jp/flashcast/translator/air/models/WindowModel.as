package jp.flashcast.translator.air.models
{
	[Bindable]
	public class WindowModel
	{
		private var _isTransWinOpened:Boolean;
		private var _isHisWinOpened:Boolean;
		private var _isConfigWinOpened:Boolean;
		public var _alpha:Number;
		
		public function WindowModel()
		{
			_isTransWinOpened = false;
			_isHisWinOpened = false;
			_isConfigWinOpened = false;
			_alpha = 0;
		}
		
		public function set isTransWinOpened(isTransWinOpened:Boolean):void {
			_isTransWinOpened = isTransWinOpened;
		}
		
		public function get isTransWinOpened():Boolean {
			return _isTransWinOpened;
		}
		
		public function set isHisWinOpened(isHisWinOpened:Boolean):void {
			_isHisWinOpened = isHisWinOpened;
		
		}
		public function get isHisWinOpened():Boolean {
			return _isHisWinOpened;
		}
		
		public function set isConfigWinOpened(isConfigWinOpened:Boolean):void {
			_isConfigWinOpened = isConfigWinOpened;
		}
		
		public function get isConfigWinOpened():Boolean {
			return _isConfigWinOpened;
		}
		
		public function set Alpha(alpha:Number):void {
			_alpha = alpha;
		}
		
		public function get Alpha():Number {
			return _alpha;
		}

	}
}