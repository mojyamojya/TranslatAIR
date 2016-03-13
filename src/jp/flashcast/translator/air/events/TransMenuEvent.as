package jp.flashcast.translator.air.events
{
	import flash.events.Event;

	public class TransMenuEvent extends Event
	{
		public static const TRANSLATE_SELECT:String = "translate";
		public static const HISTORY_SELECT:String = "history";
		public static const CONFIG_SELECT:String = "config";
		public static const CLIPMODE_SELECT:String = "clipmode";
		
		public function TransMenuEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}