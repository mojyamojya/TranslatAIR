package jp.flashcast.translator.air.views
{
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import jp.flashcast.translator.air.components.ComboBoxEx;
	import jp.flashcast.translator.air.events.TransWindowEvent;
	import jp.flashcast.translator.air.models.ConfigModel;
	import jp.flashcast.translator.air.models.LanguageModel;
	import jp.flashcast.translator.air.models.MessageModel;
	import jp.flashcast.translator.air.models.TwitterModel;
	import jp.flashcast.translator.air.util.Locale;
	
	import mx.controls.CheckBox;
	import mx.controls.HSlider;
	import mx.controls.RadioButtonGroup;
	import mx.controls.TextInput;
	import mx.core.IDataRenderer;
	import mx.core.IFlexDisplayObject;
	import mx.core.Window;
	import mx.managers.PopUpManager;

	public class ConfigWindowBase extends Window
	{
		public var cmbFrom:ComboBoxEx;
		public var cmbTo:ComboBoxEx;
		public var radioGroupTranslate:RadioButtonGroup;
		public var chkClipmode:CheckBox;
		public var chkTweet:CheckBox;
		public var txtAccount:TextInput;
		public var txtPassword:TextInput;
		public var txtConfirm:TextInput;
		public var sliderAnimate:HSlider;
		
		private var _fmodel:ConfigModel;
		private var _lmodel:LanguageModel;
		private var _tmodel:TwitterModel;
		
		public function ConfigWindowBase()
		{
			super();
		}
		
		public function initConfigWindow(fmodel:ConfigModel, lmodel:LanguageModel, tmodel:TwitterModel):void {
			this.systemChrome = NativeWindowSystemChrome.NONE;
			this.type = NativeWindowType.UTILITY;
			this.transparent = true;
			this.alpha = 0.8;
			this.maximizable = false;
			this.minimizable = false;
			this.resizable = false;
			this.showStatusBar = false;
			
			_fmodel = fmodel;
			_lmodel = lmodel
			_tmodel = tmodel;
			
			this.addEventListener(Event.CLOSING, onClosingHandler);
			this.addEventListener(Event.CLOSE, onCloseHandler);
		}
		
		public function onCreationCompleteHandler(event:Event):void {
			cmbFrom.initItems(_lmodel);
			cmbTo.initItems(_lmodel);
			cmbFrom.selectItem(_fmodel.LanguageFrom);
			cmbTo.selectItem(_fmodel.LanguageTo);
			radioGroupTranslate.selectedValue = _fmodel.Translate;
			chkClipmode.enabled = _fmodel.Translate
			chkClipmode.selected = _fmodel.Clipmode;
			chkTweet.enabled = _fmodel.Translate
			chkTweet.selected = _fmodel.Tweet;
			
			if (!_fmodel.Tweet) {
				txtAccount.enabled = false;
				txtPassword.enabled = false;
				txtConfirm.enabled = false;
				sliderAnimate.enabled = false;
			}
			
			txtAccount.text = _fmodel.Account;
			txtPassword.text = _fmodel.Password;
			txtConfirm.text = _fmodel.Password;
			sliderAnimate.value = _fmodel.DelayIcon / 1000;
			
			this.nativeWindow.x = _fmodel.Cx;
			this.nativeWindow.y = _fmodel.Cy;
		}
		
		private function onCloseHandler(event:Event):void {
			this.removeEventListener(event.type, arguments.callee);
			this.removeEventListener(Event.CLOSING, onClosingHandler);
			dispatchEvent(new TransWindowEvent(TransWindowEvent.CONFIG_WINDOW_CLOSE));
		}
		
		public function btnOKClickHandler(event:MouseEvent):void {
			if (chkTweet.selected) {
				if (txtPassword.text == "" || txtConfirm.text == "") {
					showMessageWindow(Locale.localize("twitterの設定"), Locale.localize("ユーザIDかメールアドレス、パスワードを入力してください。"));
					return;
				}
				else {
					if (txtPassword.text != txtConfirm.text) {
						showMessageWindow(Locale.localize("twitterの設定"), Locale.localize("パスワードが一致していません"));
						return;
					}
					else {
						_tmodel.Account = txtAccount.text;
						_tmodel.Password = txtPassword.text;
					}
				}
			}
			
			_fmodel.LanguageFrom = cmbFrom.selectedItem.data;
			_fmodel.LanguageTo = cmbTo.selectedItem.data;
			_fmodel.Translate = radioGroupTranslate.selectedValue;
			_fmodel.Clipmode = chkClipmode.selected;
			_fmodel.Tweet = chkTweet.selected;
			if (_fmodel.Tweet) {
				_fmodel.Account = txtAccount.text;
				_fmodel.Password = txtPassword.text;
			}
			else {
				_fmodel.Account = "";
				_fmodel.Password = "";
			}
			_fmodel.DelayIcon = sliderAnimate.value * 1000;
			
			dispatchEvent(new TransWindowEvent(TransWindowEvent.CONFIG_SAVE));
			
			close();
		}
		
		public function chkTweetSelectChangeHandler(event:Event):void {
			txtAccount.enabled = (event.target as CheckBox).selected;
			txtPassword.enabled = (event.target as CheckBox).selected;
			txtConfirm.enabled = (event.target as CheckBox).selected;
			sliderAnimate.enabled = (event.target as CheckBox).selected;
		}
		
		private function showMessageWindow(title:String, message:String):void {
			var win:IFlexDisplayObject = PopUpManager.createPopUp(this, MessageWindow, true);
			var args:MessageModel = new MessageModel();
			args.title = title;
			args.message = message;
			
			IDataRenderer(win).data = args;
			PopUpManager.centerPopUp(win);
		}
		
		private function onClosingHandler(event:Event):void {
			_fmodel.Cx = this.nativeWindow.x;
			_fmodel.Cy = this.nativeWindow.y;
		}
		
		public function onRadioTranslateChangeHandler(event:Event):void {
			var radio:RadioButtonGroup = event.currentTarget as RadioButtonGroup;
			
			chkClipmode.enabled = radio.selectedValue;
			chkTweet.enabled = radio.selectedValue;
			
			if (chkClipmode.selected && !radio.selectedValue) {
				chkClipmode.selected = false;
			}
			if (chkTweet.selected && !radio.selectedValue) {
				chkTweet.selected = false;
			}
			
			txtAccount.enabled = radio.selectedValue && chkTweet.selected;
			txtPassword.enabled = radio.selectedValue && chkTweet.selected;
			txtConfirm.enabled = radio.selectedValue && chkTweet.selected;
			sliderAnimate.enabled = radio.selectedValue && chkTweet.selected;
		}
		
	}
}