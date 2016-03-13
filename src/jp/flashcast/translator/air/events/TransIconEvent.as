package jp.flashcast.translator.air.events
{
	import flash.events.Event;

	public class TransIconEvent extends Event
	{
		public static const CLICK:String = "click";
		
		public function TransIconEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}