package jp.flashcast.translator.air.views
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.SharedObject;
	
	import jp.flashcast.translator.air.events.TransIconEvent;
	import jp.flashcast.translator.air.events.TransMenuEvent;
	import jp.flashcast.translator.air.events.TransWindowEvent;
	import jp.flashcast.translator.air.managers.ConfigManager;
	import jp.flashcast.translator.air.managers.HistoryManager;
	import jp.flashcast.translator.air.managers.IconManager;
	import jp.flashcast.translator.air.managers.MenuManager;
	import jp.flashcast.translator.air.managers.TranslateManager;
	import jp.flashcast.translator.air.managers.TwitterManager;
	import jp.flashcast.translator.air.managers.UpdateManager;
	import jp.flashcast.translator.air.models.ConfigModel;
	import jp.flashcast.translator.air.models.HistoryModel;
	import jp.flashcast.translator.air.models.IconModel;
	import jp.flashcast.translator.air.models.LanguageModel;
	import jp.flashcast.translator.air.models.TranslateModel;
	import jp.flashcast.translator.air.models.TwitterModel;
	import jp.flashcast.translator.air.models.WindowModel;
	import jp.flashcast.translator.air.models.XAuthModel;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.core.Application;
	import mx.events.PropertyChangeEvent;

	public class TranslatAIRBase extends Application
	{
		private var _imanager:IconManager;
		private var _mmanager:MenuManager;
		private var _gmanager:TranslateManager;
		private var _tmanager:TwitterManager;
		private var _hmanager:HistoryManager;
		private var _fmanager:ConfigManager;
		private var _umanager:UpdateManager;
		private var _fmodel:ConfigModel;
		private var _imodel:IconModel;
		private var _gmodel:TranslateModel;
		private var _tmodel:TwitterModel;
		private var _lmodel:LanguageModel;
		private var _wmodel:WindowModel;
		private var _hmodel:HistoryModel;
		private var _xmodel:XAuthModel
		private var translateWindow:TranslateWindow;
		private var historyWindow:HistoryWindow;
		private var configWindow:ConfigWindow;
		private var informationWindow:InformationWindow;
		
		public function TranslatAIRBase()
		{
			super();
		}
		
		public function initApp():void {
			initModels();
			initManagers();
			initInformationWindow();
			
			ChangeWatcher.watch(_fmodel, 'tx', onWindowOriginChangeHandler);
			ChangeWatcher.watch(_fmodel, 'ty', onWindowOriginChangeHandler);
			ChangeWatcher.watch(_fmodel, 'hx', onWindowOriginChangeHandler);
			ChangeWatcher.watch(_fmodel, 'hy', onWindowOriginChangeHandler);
			ChangeWatcher.watch(_fmodel, 'cx', onWindowOriginChangeHandler);
			ChangeWatcher.watch(_fmodel, 'cy', onWindowOriginChangeHandler);
			ChangeWatcher.watch(_fmodel, 'ax', onWindowOriginChangeHandler);
			ChangeWatcher.watch(_fmodel, 'ay', onWindowOriginChangeHandler);
			ChangeWatcher.watch(_imodel, '_animate', onIconAnimateHandler);
			ChangeWatcher.watch(_gmodel, '_callback', onTranslateCallbackHandler);
			ChangeWatcher.watch(_tmodel, '_tweet', onTweetHandler);
			
			_imanager.addEventListener(TransIconEvent.CLICK, onTranslateChangeHandler);
			_mmanager.addEventListener(TransMenuEvent.TRANSLATE_SELECT, onTranslateWindowOpenHandler);
			_mmanager.addEventListener(TransMenuEvent.HISTORY_SELECT, onHistoryWindowOpenHandler);
			_mmanager.addEventListener(TransMenuEvent.CONFIG_SELECT, onConfigWindowOpenHandler);
			_mmanager.addEventListener(TransMenuEvent.CLIPMODE_SELECT, onClipmodeChangeHandler);
			
			CONFIG::release {
				setStartUpMenu();
			}
		}
		
		private function initModels():void {
			_fmodel = new ConfigModel();
			_imodel = new IconModel();
			_wmodel = new WindowModel();
			_gmodel = new TranslateModel();
			_tmodel = new TwitterModel();
			_lmodel = new LanguageModel();
			_hmodel = new HistoryModel;
			_xmodel = new XAuthModel;
			
			_lmodel.initLanguageModel("language-config.xml");
			_xmodel.initXAuthModel();
		}
		
		private function initManagers():void {
			_fmanager = new ConfigManager();
			_imanager = new IconManager();
			_mmanager = new MenuManager();
			_gmanager = new TranslateManager();
			_tmanager = new TwitterManager();
			_hmanager = new HistoryManager();
			_umanager = new UpdateManager();

			_fmanager.initConfigManager(_fmodel, _tmodel);
			_imanager.initIconManager(_imodel, _gmodel, _fmodel);
			_mmanager.initMenuManager(_fmodel, _wmodel);
			_gmanager.initTranslateManager(_gmodel);
			_tmanager.initTwitterManager(_tmodel, _xmodel, _fmodel);
			_hmanager.initHistoryManager(_hmodel, _gmodel);
			_umanager.initUpdateManager();
		}
		
		private function initInformationWindow():void {
			informationWindow = new InformationWindow();
			informationWindow.initTransparentWindow(_gmodel, _tmodel, _fmodel, _wmodel);
			informationWindow.addEventListener(TransWindowEvent.INFORMATION_WINDOW_CLICK, onInfoWindowClickHandler);
		}
		
		private function onIconAnimateHandler(event:PropertyChangeEvent):void {
			if (event.newValue as Boolean) {
				this.addEventListener(Event.ENTER_FRAME, _imanager.iconAnimate);
				_imanager.timerStart();
			}
			else {
				this.removeEventListener(Event.ENTER_FRAME, _imanager.iconAnimate);
				_imanager.timerStop();
			}
		}
		
		private function onTranslateChangeHandler(event:TransIconEvent):void {
			if (_gmodel.Translate) {
				_gmodel.Translated = "";
				
				if (_fmodel.Translate) {
					_gmodel.LanguageFrom = _fmodel.LanguageFrom;
					_gmodel.LanguageTo = _fmodel.LanguageTo;
					Translate(_gmodel.Original, _gmodel.LanguageFrom, _gmodel.LanguageTo);
				}
				else {
					if (!_wmodel.isTransWinOpened) {
						openTranslateWindow(false);
					}
				}
			}
			else {
				if (_gmodel.Result) {
					_tmodel.Account = _fmodel.Account;
					_tmodel.Password = _fmodel.Password;
					_tmodel.Tweet = true;
				}
			}
		}
		
		private function Translate(original:String, languageFrom:String, languageTo:String):void {
			_gmodel.Result = false;
			_gmodel.Translate = false;
			_gmodel.Callback = false;
			_gmanager.Translate(_fmodel.Version, original, languageFrom, languageTo);
		}
		
		private function onTranslateCallbackHandler(event:PropertyChangeEvent):void {
			if (event.newValue as Boolean) {
				if (!_wmodel.isTransWinOpened) {
					if (_fmodel.Tweet) {
						if (_gmodel.Result) {
							_imodel.Animate = true;
						}
					}
					
					if (_fmodel.Clipmode) {
						Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, _gmodel.Translated);
					}
				}
			}
		}
		
		private function onTweetHandler(event:PropertyChangeEvent):void {
			if (event.newValue as Boolean) {
				_tmodel.Message = "";
				_tmodel.Result = false;
				_tmodel.Tweeted = false;
				_tmodel.Status = _gmodel.Translated.substr(0, 140);
				_tmanager.Tweet();
			}
		}
		
		private function onTranslateWindowOpenHandler(event:TransMenuEvent):void {
			if (!_wmodel.isTransWinOpened) {
				_gmodel.Original = "";
				_gmodel.Translated = "";
				openTranslateWindow(false);
			}
			else {
				translateWindow.activate();
			}
		}
		
		private function openTranslateWindow(isHistory:Boolean):void {
			translateWindow = new TranslateWindow();
			translateWindow.initTranslateWindow(_lmodel, _fmodel, _gmodel, _tmodel, _xmodel, isHistory);
			translateWindow.addEventListener(TransWindowEvent.TRANSLATE, onTranslateHandler);
			translateWindow.addEventListener(TransWindowEvent.TRANS_WINDOW_CLOSE, onTransWindowCloseHandler);
			translateWindow.addEventListener(TransWindowEvent.ACCOUNT_WINDOW_SAVE, onAccountSaveHandler);
			translateWindow.open(true);
			
			_wmodel.isTransWinOpened = true;
		}
		
		private function onTranslateHandler(event:TransWindowEvent):void {
			if (_gmodel.Translate) {
				Translate(_gmodel.Original, _gmodel.LanguageFrom, _gmodel.LanguageTo);
			}
		}
		
		private function onTransWindowCloseHandler(event:TransWindowEvent):void {
			_wmodel.isTransWinOpened = false;
			
			translateWindow.removeEventListener(event.type, arguments.callee);
			translateWindow.removeEventListener(TransWindowEvent.TRANSLATE, onTranslateHandler);
			translateWindow.removeEventListener(TransWindowEvent.ACCOUNT_WINDOW_SAVE, onAccountSaveHandler);
		}
		
		private function onHistoryWindowOpenHandler(event:TransMenuEvent):void {
			if (_wmodel.isHisWinOpened) {
				historyWindow.activate();
			}
			else {
				openHistoryWindow();
			}
		}
		
		private function openHistoryWindow():void {
			historyWindow = new HistoryWindow();
			historyWindow.initHistoryWindow(_hmodel, _lmodel, _gmodel, _fmodel);
			historyWindow.addEventListener(TransWindowEvent.HIS_WINDOW_CLOSE, onHisWindowCloseHandler);
			historyWindow.addEventListener(TransWindowEvent.HIS_WINDOW_GRID_DOUBLE_CLICK, onHisWindowDoubleClickHandler);
			historyWindow.open(true);
			
			_wmodel.isHisWinOpened = true;
		}
		
		private function onHisWindowCloseHandler(event:TransWindowEvent):void {
			_wmodel.isHisWinOpened = false;
			historyWindow.removeEventListener(event.type, arguments.callee);
			historyWindow.removeEventListener(TransWindowEvent.HIS_WINDOW_GRID_DOUBLE_CLICK, onHisWindowDoubleClickHandler);
		}
		
		private function onHisWindowDoubleClickHandler(event:TransWindowEvent):void {
			if (!_wmodel.isTransWinOpened) {
				openTranslateWindow(true);
			}
			else {
				translateWindow.activate();
			}
		}
		
		private function onConfigWindowOpenHandler(event:TransMenuEvent):void {
			if (!_wmodel.isConfigWinOpened) {
				openConfigWindow();
			}
			else {
				configWindow.activate();
			}
		}
		
		private function openConfigWindow():void {
			configWindow = new ConfigWindow();
			configWindow.initConfigWindow(_fmodel, _lmodel, _tmodel);
			configWindow.addEventListener(TransWindowEvent.CONFIG_WINDOW_CLOSE, onConfigWindowCloseHandler);
			configWindow.addEventListener(TransWindowEvent.CONFIG_SAVE, onConfigSaveHandler);
			configWindow.open(true);
			
			_wmodel.isConfigWinOpened = true;
		}
		
		private function onConfigSaveHandler(event:TransWindowEvent):void {
			_fmanager.updateConfig();
			
			if (_xmodel.OAuthToken.toString().length) {
				_xmodel.OAuthToken = "";
			}
			if (_xmodel.OAuthTokenSecret.toString().length) {
				_xmodel.OAuthTokenSecret = "";
			}
			
			var so:SharedObject = SharedObject.getLocal("jp.flashcast.translator.air.twitter");
			so.clear();
		}
		
		private function onConfigWindowCloseHandler(event:TransWindowEvent):void {
			_wmodel.isConfigWinOpened = false;
			configWindow.removeEventListener(event.type, arguments.callee);
			configWindow.removeEventListener(TransWindowEvent.CONFIG_SAVE, onConfigSaveHandler);
		}
		
		private function onClipmodeChangeHandler(event:TransMenuEvent):void {
			_fmanager.updateConfig();
		}
		
		private function onWindowOriginChangeHandler(event:PropertyChangeEvent):void {
			_fmanager.updateOriginConfig(event.property as String, event.newValue as int);
		}
		
		private function onInfoWindowClickHandler(event:TransWindowEvent):void {
			openTranslateWindow(false);
		}
		
		private function setStartUpMenu():void {
			var name:String = "jp.flashcast.translator.air";
			var file:File = File.applicationDirectory.resolvePath("META-INF");
			
			if (file.exists) {
				name += file.creationDate.time
			}
			
			var so:SharedObject = SharedObject.getLocal(name);
			
			if (so.size == 0) {
				so.data.startAtLogin = true;
				so.flush();
				
				NativeApplication.nativeApplication.startAtLogin = true;
			}
		}
		
		private function onAccountSaveHandler(event:TransWindowEvent):void {
			_fmanager.updateAccountConfig(_fmodel.Account, _fmodel.Password);
		}
	}
}