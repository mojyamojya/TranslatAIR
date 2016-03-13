package jp.flashcast.translator.air.views
{
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import jp.flashcast.translator.air.events.TransWindowEvent;
	import jp.flashcast.translator.air.models.ConfigModel;
	import jp.flashcast.translator.air.models.HistoryModel;
	import jp.flashcast.translator.air.models.LanguageModel;
	import jp.flashcast.translator.air.models.TranslateModel;
	
	import mx.controls.DataGrid;
	import mx.core.Window;

	public class HistoryWindowBase extends Window
	{
		public var dgHistory:DataGrid;
		private var _hmodel:HistoryModel;
		private var _lmodel:LanguageModel;
		private var _gmodel:TranslateModel;
		private var _fmodel:ConfigModel;
		
		public function HistoryWindowBase()
		{
			super();
		}
		
		public function initHistoryWindow(hmodel:HistoryModel, lmodel:LanguageModel, gmodel:TranslateModel, fmodel:ConfigModel):void {
			this.systemChrome = NativeWindowSystemChrome.NONE;
			this.type = NativeWindowType.UTILITY;
			this.transparent = true;
			this.alpha = 0.8;
			this.maximizable = false;
			this.minimizable = false;
			this.resizable = false;
			this.showStatusBar = false;
			this._hmodel = hmodel;
			this._lmodel = lmodel;
			this._gmodel = gmodel;
			this._fmodel = fmodel;
			this.addEventListener(Event.CLOSING, onClosingHandler);
			this.addEventListener(Event.CLOSE, onCloseHandler);
		}
		
		private function onCloseHandler(event:Event):void {
			this.removeEventListener(event.type, arguments.callee);
			this.removeEventListener(Event.CLOSING, onClosingHandler);
			dispatchEvent(new TransWindowEvent(TransWindowEvent.HIS_WINDOW_CLOSE));
		}
		
		public function onCreationCompleteHandler(event:Event):void {
			dgHistory.dataProvider = _hmodel.History.map(toLanguageLabel);
			this.nativeWindow.x = _fmodel.Hx;
			this.nativeWindow.y = _fmodel.Hy;
		}
		
		private function toLanguageLabel(element:Object, index:int, arr:Array):Object {
			return {
				id:element.id,
				original:element.original,
				translated:element.translated,
				languagefrom:_lmodel.getLanguageLabel(element.languagefrom),
				languageto:_lmodel.getLanguageLabel(element.languageto),
				datetime:element.datetime};
		}
		
		public function onDgHistoryDoubleClickHandler(event:MouseEvent):void {
			var dg:DataGrid = event.currentTarget as DataGrid;
			var index:int = dg.selectedIndex;
			
			if (index >= 0) {
				_gmodel.Original = dg.dataProvider[index].original;
				_gmodel.Translated = dg.dataProvider[index].translated;
				_gmodel.LanguageFrom = "";
				_gmodel.LanguageFrom = _lmodel.getLanguageData(dg.dataProvider[index].languagefrom);
				_gmodel.LanguageTo = "";
				_gmodel.LanguageTo = _lmodel.getLanguageData(dg.dataProvider[index].languageto);
				_gmodel.DateTime = dg.dataProvider[index].datetime;
				
				dispatchEvent(new TransWindowEvent(TransWindowEvent.HIS_WINDOW_GRID_DOUBLE_CLICK));
			}
		}
		
		private function onClosingHandler(event:Event):void {
			_fmodel.Hx = this.nativeWindow.x;
			_fmodel.Hy = this.nativeWindow.y;
		}
	}
}