package jp.flashcast.translator.air.util
{
	import mx.resources.ResourceManager;
	import mx.resources.ResourceBundle;
	
	[ResourceBundle("resource")]
	public class Locale
	{
		public function Locale()
		{
		}
		
		public static function localize(key:String):String {
			if (key == null) {
				return null;
			}
			
			var value:String = ResourceManager.getInstance().getString("resource", key);
			return (value == null) ? key : value;
		}

	}
}