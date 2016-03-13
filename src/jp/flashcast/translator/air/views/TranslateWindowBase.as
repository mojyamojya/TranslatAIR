package jp.flashcast.translator.air.views
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import flash.utils.IDataInput;
	
	import jp.flashcast.translator.air.components.ComboBoxEx;
	import jp.flashcast.translator.air.events.TransWindowEvent;
	import jp.flashcast.translator.air.models.ConfigModel;
	import jp.flashcast.translator.air.models.LanguageModel;
	import jp.flashcast.translator.air.models.MessageModel;
	import jp.flashcast.translator.air.models.TranslateModel;
	import jp.flashcast.translator.air.models.TwitterModel;
	import jp.flashcast.translator.air.models.XAuthModel;
	import jp.flashcast.translator.air.util.Locale;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.controls.Button;
	import mx.controls.TextArea;
	import mx.core.IDataRenderer;
	import mx.core.IFlexDisplayObject;
	import mx.core.Window;
	import mx.events.PropertyChangeEvent;
	import mx.managers.PopUpManager;

	public class TranslateWindowBase extends Window
	{
		public var txtOriginal:TextArea;
		public var txtTranslated:TextArea;
		public var cmbFrom:ComboBoxEx;
		public var cmbTo:ComboBoxEx;
		public var btnVector:Button;
		public var btnRecog:Button;
		public var btnTTS:Button;
		private var vector:Boolean;
		private var _lmodel:LanguageModel;
		private var _fmodel:ConfigModel;
		private var _gmodel:TranslateModel;
		private var _tmodel:TwitterModel;
		private var _xmodel:XAuthModel;
		private var _isHistory:Boolean;
		private var recogProc:NativeProcess;
		private var ttsProc:NativeProcess;
		private var wsf:File;
		private var recogjs:File;
		private var ttsjs:File;
		private var _recognition:String;
		
		private static const WSH_CSCRIPT_PATH:String = "C:\\Windows\\System32\\cscript.exe";
		private static const WSH_RECOG_FILENAME:String = "recog.js"; 
		private static const WSH_TTS_FILENAME:String = "tts.js"; 
		
		public function TranslateWindowBase()
		{
			super();
		}
		
		public function initTranslateWindow(
			lmodel:LanguageModel,
			fmodel:ConfigModel,
			gmodel:TranslateModel,
			tmodel:TwitterModel,
			xmodel:XAuthModel,
			isHistory:Boolean):void {

			_lmodel = lmodel;
			_fmodel = fmodel;
			_gmodel = gmodel;
			_tmodel = tmodel;
			_xmodel = xmodel;
			_isHistory = isHistory;

			this.systemChrome = NativeWindowSystemChrome.NONE;
			this.type = NativeWindowType.UTILITY;
			this.transparent = true;
			this.alpha = 0.8;
			this.maximizable = false;
			this.minimizable = false;
			this.resizable = false;
			this.showStatusBar = false;
			this.vector = false;
			
			ChangeWatcher.watch(_gmodel, '_original', onOriginalChangeHandler);
			ChangeWatcher.watch(_gmodel, '_translated', onTranslatedChangeHandler);
			ChangeWatcher.watch(_gmodel, '_languageFrom', onLanguageFromChangeHandler);
			ChangeWatcher.watch(_gmodel, '_languageTo', onLanguageToChangeHandler);
			ChangeWatcher.watch(_tmodel, '_tweeted', onTweetedChangeHandler);
			
			this.addEventListener(Event.CLOSING, onClosingHandler);
			this.addEventListener(Event.CLOSE, onCloseHandler);
		}
		
		public function onCreationCompleteHandler(event:Event):void {
			cmbFrom.initItems(_lmodel);
			cmbTo.initItems(_lmodel);
			cmbFrom.selectItem(_isHistory ? _gmodel.LanguageFrom :_fmodel.LanguageFrom);
			cmbTo.selectItem(_isHistory ? _gmodel.LanguageTo : _fmodel.LanguageTo);
			
			txtOriginal.text = _gmodel.Original;
			txtTranslated.text = _gmodel.Translated;
			
			this.nativeWindow.x = _fmodel.Tx;
			this.nativeWindow.y = _fmodel.Ty;
			
			if (recogjs == null) {
				recogjs = new File(File.applicationDirectory.nativePath + File.separator + WSH_TTS_FILENAME);
			}
			if (ttsjs == null) {
				ttsjs = new File(File.applicationDirectory.nativePath + File.separator + WSH_RECOG_FILENAME);
			}
			if (NativeProcess.isSupported) {
				if (Capabilities.os.substring(0, 3).toLowerCase() == "win") {
					if (recogjs.exists && ttsjs.exists) {
						btnRecog.visible = true;
						btnTTS.visible = true;
					}
				}
			}
		}
		
		public function btnTranslateClickHandler(event:MouseEvent):void {
			if ((vector ? txtTranslated.text : txtOriginal.text) != "") {
				_gmodel.Original = vector ? txtTranslated.text : txtOriginal.text;
				_gmodel.LanguageFrom = vector ? cmbTo.selectedItem.data : cmbFrom.selectedItem.data;
				_gmodel.LanguageTo = vector ? cmbFrom.selectedItem.data : cmbTo.selectedItem.data;
				_gmodel.Translate = true;
				_gmodel.Translated = Locale.localize("翻訳中です...");
				dispatchEvent(new TransWindowEvent(TransWindowEvent.TRANSLATE));
			}
		}
		
		private function onTranslatedChangeHandler(event:PropertyChangeEvent):void {
			var translated:String = event.newValue as String;
			
			if (vector) {
				txtOriginal.text = translated;
			}
			else {
				txtTranslated.text = translated;
			}
		}
		
		private function onOriginalChangeHandler(event:PropertyChangeEvent):void {
			var original:String = event.newValue as String;
			
			if (vector) {
				txtTranslated.text = original;
			}
			else {
				txtOriginal.text = original;
			}
		}
		
		private function onLanguageFromChangeHandler(event:PropertyChangeEvent):void {
			var language:String = event.newValue as String;
			
			if (language != "") {
				if (vector) {
					cmbTo.selectItem(language);
				}
				else {
					cmbFrom.selectItem(language);
				}
			}
		}
		
		private function onLanguageToChangeHandler(event:PropertyChangeEvent):void {
			var language:String = event.newValue as String;
			
			if (language != "") {
				if (vector) {
					cmbFrom.selectItem(language);
				}
				else {
					cmbTo.selectItem(language);
				}
			}
		}
		
		private function onCloseHandler(event:Event):void {
			this.removeEventListener(event.type, arguments.callee);
			this.removeEventListener(Event.CLOSING, onClosingHandler);
			dispatchEvent(new TransWindowEvent(TransWindowEvent.TRANS_WINDOW_CLOSE));
		}
		
		public function btnVectorClickHandler(event:MouseEvent):void {
			vector = !vector;
			btnVector.label = vector ? "<<" : ">>";
		}
		
		public function btnTweetClickHandler(event:MouseEvent):void {
			if (_gmodel.Translated != "") {
				if (!_xmodel.OAuthToken.toString().length ||
					!_xmodel.OAuthTokenSecret.toString().length) {
					if (_tmodel.Account == "" || _tmodel.Password == "") {
						var win:IFlexDisplayObject = PopUpManager.createPopUp(this, AccountWindow, true);
						win.addEventListener(TransWindowEvent.ACCOUNT_WINDOW_SAVE, onAccountSaveHandler);
						
						IDataRenderer(win).data = [_tmodel, _fmodel, _xmodel];
						PopUpManager.centerPopUp(win);
					}
					else {
						_tmodel.Tweeted = false;
						_tmodel.Tweet = true;
					}
				}
				else {
					_tmodel.Tweeted = false;
					_tmodel.Tweet = true;
				}
			}
			else {
				showMessageWindow(Locale.localize("入力エラー"), Locale.localize("twitterに投稿する翻訳結果がありません。"));
			}
		}
		
		private function onTweetedChangeHandler(event:PropertyChangeEvent):void {
			if (event.newValue as Boolean) {
				showMessageWindow(Locale.localize("twitterへの投稿"), _tmodel.Message);
			}
		}
		
		private function showMessageWindow(title:String, message:String):void {
			var win:IFlexDisplayObject = PopUpManager.createPopUp(this, MessageWindow, true);
			var args:MessageModel = new MessageModel();
			args.title = title
			args.message = message;
			
			IDataRenderer(win).data = args;
			PopUpManager.centerPopUp(win);
		}
		
		private function onClosingHandler(event:Event):void {
			_fmodel.Tx = this.nativeWindow.x;
			_fmodel.Ty = this.nativeWindow.y;
		}
		
		private function onAccountSaveHandler(event:TransWindowEvent):void {
			this.removeEventListener(event.type, arguments.callee);
			dispatchEvent(new TransWindowEvent(TransWindowEvent.ACCOUNT_WINDOW_SAVE));
		}
		
		public function btnRecogClickHandler(event:MouseEvent):void {
			if (recogProc == null) {
				recogProc = new NativeProcess();
			}
			
			if (wsf == null) {
				wsf = new File(WSH_CSCRIPT_PATH); 
			}
			
			var args:Vector.<String> = new Vector.<String>;
			args.push(recogjs.nativePath);

			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.executable = wsf;
			info.arguments = args;
			
			recogProc.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onRecogStandardOutputData);
			recogProc.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onRecogStandardErrorData);
			recogProc.addEventListener(NativeProcessExitEvent.EXIT, onRecogExit);
			
			var success:Boolean = false;
			
			try {
				recogProc.start(info);
				success = true;
			}
			catch (error:IllegalOperationError) {
				trace(error.getStackTrace());
			}
			catch (error:ArgumentError) {
				trace(error.getStackTrace());
			}
			catch (error:Error) {
				trace(error.getStackTrace());
			}
			
			if (!success) {
//				Alert.show("");
			}
		}
		
		private function onRecogStandardOutputData(event:ProgressEvent):void {
			var data:IDataInput = recogProc.standardOutput;
			_recognition = data.readMultiByte(data.bytesAvailable, "shift-jis");
		}
		
		private function onRecogStandardErrorData(event:ProgressEvent):void {
			
		}
		
		private function onRecogExit(event:NativeProcessExitEvent):void {
			recogProc.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onRecogStandardOutputData);
			recogProc.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, onRecogStandardErrorData);
			recogProc.removeEventListener(NativeProcessExitEvent.EXIT, onRecogExit);
			
			var txtSrc:TextArea = (vector ? txtTranslated : txtOriginal);
			txtSrc.text= _recognition;
		}
		
		public function btnTTSClickHandler(event:MouseEvent):void {
			btnTTS.enabled = false;
			
			Speech(_recognition);
		}
		
		private function Speech(recognition:String):void {
			if (ttsProc == null) {
				ttsProc = new NativeProcess();
			}
			
			if (wsf == null) {
				wsf = new File(WSH_CSCRIPT_PATH); 
			}
			
			var args:Vector.<String> = new Vector.<String>;
			args.push(ttsjs.nativePath);
			args.push(recognition);

			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.executable = wsf;
			info.arguments = args;
			
			ttsProc.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onRecogStandardOutputData);
			ttsProc.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onRecogStandardErrorData);
			ttsProc.addEventListener(NativeProcessExitEvent.EXIT, onRecogExit);
			
			var success:Boolean = false;
			
			try {
				ttsProc.start(info);
				success = true;
			}
			catch (error:IllegalOperationError) {
				trace(error.getStackTrace());
			}
			catch (error:ArgumentError) {
				trace(error.getStackTrace());
			}
			catch (error:Error) {
				trace(error.getStackTrace());
			}
			
			if (!success) {
//				Alert.show("");
			}
		}
		
		private function onTTSStandardOutputData(event:ProgressEvent):void {
			
		}
		
		private function onTTSStandardErrorData(event:ProgressEvent):void {
			
		}
		
		private function onTTSExit(event:NativeProcessExitEvent):void {
			ttsProc.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onTTSStandardOutputData);
			ttsProc.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, onTTSStandardErrorData);
			ttsProc.removeEventListener(NativeProcessExitEvent.EXIT, onTTSExit);
			
			btnTTS.enabled = true;
		}
	}
}
