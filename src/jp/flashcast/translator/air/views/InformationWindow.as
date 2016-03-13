package jp.flashcast.translator.air.views
{
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import jp.flashcast.translator.air.events.TransWindowEvent;
	import jp.flashcast.translator.air.models.ConfigModel;
	import jp.flashcast.translator.air.models.TranslateModel;
	import jp.flashcast.translator.air.models.TwitterModel;
	import jp.flashcast.translator.air.models.WindowModel;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.core.BitmapAsset;
	import mx.events.PropertyChangeEvent;

	public class InformationWindow extends NativeWindow
	{
		[Embed(source='assets/close_up.gif')]
		private var btnImageUp:Class;
		
		[Embed(source='assets/close_over.gif')]
		private var btnImageOver:Class;
		
		[Embed(source='assets/close_down.gif')]
		private var btnImageDown:Class;
		
		[Embed(source='assets/info.gif')]
		private var imageInfo:Class;
		
		[Embed(source='assets/alert.gif')]
		private var imageAlert:Class;
		
		private var _gmodel:TranslateModel;
		private var _tmodel:TwitterModel;
		private var _wmodel:WindowModel;
		private var _fmodel:ConfigModel;
		private var isDragging:Boolean;		// ウィンドウがドラッグされたかどうか
		private var isClosing:Boolean;		// 閉じるボタンが押されたかどうか
		private var isIncrement:Boolean;
		private var _timer:Timer;
		
		public function InformationWindow()
		{
			var options:NativeWindowInitOptions = new NativeWindowInitOptions();
			
			options.systemChrome = NativeWindowSystemChrome.NONE;
			options.type = NativeWindowType.LIGHTWEIGHT;
			options.transparent = true;
			options.maximizable = true;
			
			super(options);
		}
		
		public function initTransparentWindow(
			gmodel:TranslateModel, 
			tmodel:TwitterModel, 
			fmodel:ConfigModel,
			wmodel:WindowModel):void {
			_gmodel = gmodel;
			_tmodel = tmodel;
			_fmodel = fmodel;
			_wmodel = wmodel;
			
			var background:Sprite = new Sprite();
			var graphics:Graphics = background.graphics;
			
			graphics.beginFill(0x000000);
			graphics.lineStyle(2, 0x999999);
			graphics.drawRoundRect(_fmodel.Ax, _fmodel.Ay, 350, 70, 5, 5);
			graphics.endFill();
			
			background.alpha = _wmodel.Alpha;
			background.filters = [new DropShadowFilter(5, 45, 0, .3)];
			background.buttonMode = true;
			background.useHandCursor = true;
			background.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler);
			background.addEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler);
			background.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverHandler);
			background.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutHandler);
			background.addEventListener(MouseEvent.CLICK, onClickHandler);
			
			// 閉じるボタンの生成
			var btnClose:SimpleButton = new SimpleButton(
				new btnImageUp(), 
				new btnImageOver(), 
				new btnImageDown(), 
				new btnImageUp());
			
			// 閉じるボタンの初期化
			btnClose.x = _fmodel.Ax + 330;
			btnClose.y = _fmodel.Ay + 7;
			btnClose.addEventListener(MouseEvent.CLICK, onClose);
			
			// ラベルの生成
			var lblMessage:TextField = new TextField();
			
			lblMessage.x = _fmodel.Ax + 50;
			lblMessage.y = _fmodel.Ay + 8;
			lblMessage.width = 275;
			lblMessage.height = 60;
			lblMessage.wordWrap = true;
			lblMessage.multiline = false;
			lblMessage.selectable = false;
			lblMessage.mouseEnabled = false;
			lblMessage.antiAliasType = AntiAliasType.ADVANCED;
			lblMessage.gridFitType = GridFitType.PIXEL;
			lblMessage.textColor = 0xFFFFFF;
			
			// ビットマップの初期化
			var bmpInfo:Bitmap = new Bitmap((new imageInfo() as BitmapAsset).bitmapData);
			var bmpAlert:Bitmap = new Bitmap((new imageAlert() as BitmapAsset).bitmapData);
			bmpInfo.x = _fmodel.Ax + 15;
			bmpInfo.y = _fmodel.Ay + 10
			bmpAlert.x = _fmodel.Ax + 15;
			bmpAlert.y = _fmodel.Ay + 10;
			bmpInfo.visible = true;
			bmpAlert.visible = false;
			
			background.addChildAt(bmpInfo, 0);
			background.addChildAt(bmpAlert, 1);
			background.addChildAt(btnClose, 2);
			background.addChildAt(lblMessage, 3)
			
			stage.addChild(background);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			this.maximize();
			this.visible = false;
			this.alwaysInFront = true;
			
			_timer = new Timer(_fmodel.DelayAlpha);
			_timer.addEventListener(TimerEvent.TIMER, onTimerHandler);
			
			ChangeWatcher.watch(_gmodel, '_callback', onTranslateCallbackHandler);
			ChangeWatcher.watch(_tmodel, '_tweeted', onTweetedChangeHandler);
			ChangeWatcher.watch(_wmodel, '_alpha', onAlphaChangeHandler);
		}
		
		private function onMouseDownHandler(event:MouseEvent):void {
			var background:Sprite = stage.getChildAt(0) as Sprite;
			background.startDrag();
			background.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
		}
		
		private function onMouseMoveHandler(event:MouseEvent):void {
			isDragging = true;
		}
		
		private function onMouseUpHandler(event:MouseEvent):void {
			var background:Sprite = stage.getChildAt(0) as Sprite;
			
			var x:Number = _fmodel.Ax + background.x;
			var y:Number = _fmodel.Ay + background.y;
			
			if (x >= 0 && x < this.width) {
				if (y >= 0 && y < this.height) {
					_fmodel.Ax = x;
					_fmodel.Ay = y;
				}
			}
			
			background.stopDrag();
			background.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
		} 
		
		private function onMouseOverHandler(event:MouseEvent):void {
			if (_wmodel.Alpha > 0) {
				reset(_fmodel.Alpha);
			}
		}
		
		private function onMouseOutHandler(event:MouseEvent):void {
			if (_wmodel.Alpha >= 1) {
				_timer.start();
			}
		}
		
		private function onClickHandler(event:MouseEvent):void {
			if (!isDragging) {
				// ドラッグされてなければ画面を非表示にする
				reset(0);
				
				if (!isClosing) {
					// 閉じるボタン以外をクリック
					dispatchEvent(new TransWindowEvent(TransWindowEvent.INFORMATION_WINDOW_CLICK));
				}
			}
			isDragging = false;
			isClosing = false;
		}
		
		private function onClose(event:MouseEvent):void {
			reset(0);
			isClosing = true;		// 閉じるボタンが押された
		}
		
		private function onTranslateCallbackHandler(event:PropertyChangeEvent):void {
			if (event.newValue as Boolean) {
				if (_gmodel.Translated != "") {
					if (!_wmodel.isTransWinOpened) {
						showMessage(_gmodel.Result, _gmodel.Translated);
					}
				}
			}
		}
		
		private function onTweetedChangeHandler(event:PropertyChangeEvent):void {
			if (event.newValue as Boolean) {
				if (_tmodel.Message != "") {
					if (!_wmodel.isTransWinOpened) {
						showMessage(_tmodel.Result, _tmodel.Message);
					}
				}
			}
		}
		
		private function showMessage(result:Boolean, message:String):void {
			initComponents(result, message);
			activate();
			
			if (_timer.running) {
				isIncrement = true;
			}
			else {
				_timer.start();
			}
		}
		
		private function initComponents(result:Boolean, message:String):void {
			var background:Sprite = stage.getChildAt(0) as Sprite;
			(background.getChildAt(0) as Bitmap).visible = result;
			(background.getChildAt(1) as Bitmap).visible = !result;
			(background.getChildAt(3) as TextField).text = message;
		}
		
		private function onTimerHandler(event:TimerEvent):void {
			if (_wmodel.Alpha <= 0) {
				isIncrement = true;
			}
			else if (_wmodel.Alpha >= _fmodel.Alpha) {
				isIncrement = false;
			}
			
			if (isIncrement) {
				_wmodel.Alpha = _wmodel.Alpha + 0.01;
			}
			else {
				_wmodel.Alpha = _wmodel.Alpha - 0.01;
			}

			if (_wmodel.Alpha <= 0) {
				_timer.stop();
			}
		}
		
		private function onAlphaChangeHandler(event:PropertyChangeEvent):void {
			var background:Sprite = stage.getChildAt(0) as Sprite;
			background.alpha = event.newValue as Number;
			if (background.alpha <= 0) {
				background.useHandCursor = false;
				(background.getChildAt(2) as SimpleButton).enabled = false;
				reset(0);
			}
			else {
				if (!background.useHandCursor) {
					background.useHandCursor = true;
				}
				if (!(background.getChildAt(2) as SimpleButton).enabled) {
					(background.getChildAt(2) as SimpleButton).enabled = true;
				}
			}
		}
		
		private function reset(alpha:Number):void {
			_timer.stop();
			_wmodel.Alpha = alpha;
		}
	}
}