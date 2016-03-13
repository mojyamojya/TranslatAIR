package jp.flashcast.translator.air.models
{
	[Bindable]
	public class IconModel
	{
		public var _animate:Boolean;
		
		public function IconModel()
		{
			_animate = false;
		}
		
		public function set Animate(animate:Boolean):void {
			_animate = animate;
		}
		
		public function get Animate():Boolean {
			return _animate;
		}

	}
}