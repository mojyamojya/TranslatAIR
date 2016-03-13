package jp.flashcast.translator.air.events
{
	import flash.events.Event;

	public class TransWindowEvent extends Event
	{
		public static const TRANSLATE:String = "translate";
		public static const TRANS_WINDOW_CLOSE:String = "trans_window_close";
		public static const HIS_WINDOW_CLOSE:String = "his_window_close";
		public static const HIS_WINDOW_GRID_DOUBLE_CLICK:String = "his_window_grid_double_click";
		public static const CONFIG_WINDOW_CLOSE:String = "config_window_close";
		public static const CONFIG_SAVE:String = "config_save";
		public static const INFORMATION_WINDOW_CLICK:String = "information_window_click";
		public static const ACCOUNT_WINDOW_SAVE:String = "account_window_save";
		
		public function TransWindowEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}