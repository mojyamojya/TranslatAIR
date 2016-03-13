package jp.flashcast.translator.air.models
{
	public class HistoryModel
	{
		private var _history:Array;
		private var _lmodel:LanguageModel;
		
		public function HistoryModel()
		{
			_history = new Array();
		}
		
		public function set History(history:Array):void {
			_history = history;
		}
		
		public function get History():Array {
			return _history;
		}
		
		public function push(item:Object):void {
			_history.push(item);
			_history.sortOn("datetime", Array.DESCENDING);
		}

	}
}