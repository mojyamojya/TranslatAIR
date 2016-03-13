package jp.flashcast.translator.air.managers
{
	import flash.events.EventDispatcher;
	
	import jp.flashcast.translator.air.controllers.ClipboardController;
	import jp.flashcast.translator.air.events.TransWindowEvent;
	import jp.flashcast.translator.air.models.ConfigModel;
	import jp.flashcast.translator.air.models.LanguageModel;
	import jp.flashcast.translator.air.models.TranslateModel;
	import jp.flashcast.translator.air.views.TranslateWindow;
	
	import mx.controls.Alert;
	
	public class WindowManager extends EventDispatcher
	{
		private var _fmodel:ConfigModel;
		private var _lmodel:LanguageModel;
		private var _gmodel:TranslateModel;
		private var _controller:ClipboardController;
		private var translateWindow:TranslateWindow;
		
		public function WindowManager()
		{
		}
		
		public function initWindowManager(lmodel:LanguageModel, fmodel:ConfigModel, gmodel:TranslateModel,
			controller:ClipboardController):void {
			_lmodel = lmodel;
			_fmodel = fmodel;
			_gmodel = gmodel;
			_controller = controller;
		}
		
		private function initTranslateWindow():void {
			translateWindow = new TranslateWindow();
			translateWindow.initTranslateWindow(_lmodel, _fmodel, _gmodel, _controller);
			translateWindow.addEventListener(TransWindowEvent.TRANSLATE, onTranslate);
		}
		
		public function openTranslateWindow():void {
			initTranslateWindow();
			translateWindow.open(true);
		}
		
		private function onTranslate(event:TransWindowEvent):void {
			dispatchEvent(new TransWindowEvent(TransWindowEvent.TRANSLATE));
		}

	}
}