package jp.flashcast.translator.air.managers
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeApplication;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.InvokeEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import jp.flashcast.translator.air.events.TransIconEvent;
	import jp.flashcast.translator.air.models.ConfigModel;
	import jp.flashcast.translator.air.models.IconModel;
	import jp.flashcast.translator.air.models.TranslateModel;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.core.BitmapAsset;
	import mx.events.PropertyChangeEvent;

	public class IconManager extends EventDispatcher
	{
		[Embed(source="assets/translatair_icon16.png")]
		private var icon16:Class;
		[Embed(source="assets/translatair_icon128.png")]
		private var icon128:Class;
		private var newIconBitmap:BitmapData;           // アイコンくるくる用
		
		private var degrees:int;
		private var scales:int;
		private var edge:int;
		
		private var isAnimation:Boolean = false;
		private var isDecrement:Boolean = false;
		private var isReverse:Boolean = false;
		private var isSecond:Boolean = false;
		
		private var _imodel:IconModel;
		private var _gmodel:TranslateModel;
		private var _fmodel:ConfigModel;
		private var _timer:Timer;
		
		public function IconManager()
		{
		}
		
		public function initIconManager(
			imodel:IconModel, 
			gmodel:TranslateModel, 
			fmodel:ConfigModel):void {
			_imodel = imodel;
			_gmodel = gmodel;
			_fmodel = fmodel;
			
			initIcon();
			
			_timer = new Timer(_fmodel.DelayIcon);
			_timer.addEventListener(TimerEvent.TIMER, onTimerHandler);
			
			ChangeWatcher.watch(_fmodel, '_delayIcon', onDelayIconChangeHandler); 
		}
		
		private function initIcon():void {
			if (NativeApplication.supportsSystemTrayIcon) {
				// Windows対応
				newIconBitmap = (new icon16() as BitmapAsset).bitmapData;
				NativeApplication.nativeApplication.icon.addEventListener(MouseEvent.CLICK, onIconClick);
				isSecond = true;
				edge = 16;
			}
			else if (NativeApplication.supportsDockIcon) {
				// Mac対応
				newIconBitmap = (new icon128() as BitmapAsset).bitmapData;
				NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onIconClick);
				edge = 128;
			}
			else {
				NativeApplication.nativeApplication.exit();
			}
			
			setIcon(newIconBitmap);
		}
		
		private function setIcon(bitmap:BitmapData):void {
			NativeApplication.nativeApplication.icon.bitmaps = [bitmap];
		}
		
		private function onIconClick(event:Event):void {
			if (isSecond) {
				if (_imodel.Animate) {
					_imodel.Animate = false;
					
					if (NativeApplication.supportsSystemTrayIcon) {
						setIcon(newIconBitmap);
					}
				}
				else {
					if (!Clipboard.generalClipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)) {
						return;
					}
					_gmodel.Original = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
					_gmodel.Translate = true;
				}
				
				dispatchEvent(new TransIconEvent(TransIconEvent.CLICK));
			}
			else {
				isSecond = true;
			}
		}
		
		public function iconAnimate(event:Event):void {
			var iconBitmap:BitmapData;
			var newIconBitmap:BitmapData;
			var rectangle:Rectangle;
			
			if (edge == 128) {
				degrees++;
				
				if (isDecrement) {
					scales--;
				}
				else {
					scales++;
				}
			}
			else {
				degrees += 6;
			}
			
			iconBitmap = new BitmapData(edge, edge, true, 0x00000000);
			newIconBitmap = (((edge == 128) ? new icon128() : new icon16()) as BitmapAsset).bitmapData;
			rectangle = new Rectangle(0, 0, edge, edge);
			
			setIcon((edge == 128) ?
				moveBitmap(iconBitmap, newIconBitmap, rectangle, scales, degrees, isReverse) :
				rotateBitmap(iconBitmap, newIconBitmap, iconBitmap.width/2, iconBitmap.height/2,rectangle, degrees));
			
			if (edge == 128) {
				if (scales == edge || scales == 0) {
					if (scales == edge) {
						isDecrement = true;
						isReverse = !isReverse;
					}
					else if (scales == 0) {
						isDecrement = false;
					}
				}
				
				if (degrees == 360) {
					degrees = 0;
				}
			}
			else {
				if (degrees >= 360) {
					degrees = degrees - 360
				}
			}
		}
		
		private function moveBitmap(iconBitmap:BitmapData, newIconBitmap:BitmapData, 
			rectangle:Rectangle, scales:int, degrees:int, isReverse:Boolean):BitmapData {
			var matrixRotate:Matrix;
			var matrixScaling:Matrix;
			var radian:Number = degrees/180*Math.PI;
			
			if (isReverse) {
				var tempBitmap:BitmapData = new BitmapData(edge, edge, true, 0x00000000);
				var tempMatrix:Matrix = new Matrix();
				var tempRectangle:Rectangle = new Rectangle(0, 0, edge, edge);
				tempMatrix.scale(-1, 1);
				tempMatrix.translate(edge, 0);
				tempBitmap.draw(newIconBitmap, tempMatrix, null, null, tempRectangle);
				newIconBitmap = tempBitmap.clone();
			}
			
			matrixScaling = new Matrix();
			var sx:Number;
			var sy:Number;
			var tx:Number;
			var ty:Number;
			sx = (edge-scales)/edge;
			sy = 1;
			tx = edge/2-(sx*edge/2);
			ty = 0; 
			matrixScaling.scale(sx, sy);
			matrixScaling.translate(tx, ty);
			
			matrixRotate = new Matrix();
			matrixRotate.rotate(radian);
			matrixRotate.translate(edge/2-(Math.cos(radian)*edge/2-Math.sin(radian)*edge/2),
				edge/2-(Math.sin(radian)*edge/2+Math.cos(radian)*edge/2));

			matrixScaling.concat(matrixRotate);
			iconBitmap.draw(newIconBitmap, matrixScaling, null, null, rectangle);
			
			return iconBitmap;
		}
		
		private function rotateBitmap(iconBitmap:BitmapData, newIconBitmap:BitmapData,
			originX:int, originY:int, rectangle:Rectangle, degrees:int):BitmapData {
			var radian:Number = degrees/180 * Math.PI;
			var matrix:Matrix = new Matrix();
			
			matrix.rotate(radian);
			matrix.translate(originX-Math.cos(radian)*originX+Math.sin(radian)*originY,
				originY-Math.cos(radian)*originX-Math.sin(radian)*originY);
			
			iconBitmap.draw(newIconBitmap, matrix, null, null, rectangle, true);

			return iconBitmap;
		}
		
		private function onTimerHandler(event:TimerEvent):void {
			_imodel.Animate = false;
			
			if (NativeApplication.supportsSystemTrayIcon) {
				setIcon(newIconBitmap);
			}
		}
		
		public function timerStart():void {
			_timer.start();
		}
		
		public function timerStop():void {
			_timer.stop();
		}
		
		private function onDelayIconChangeHandler(event:PropertyChangeEvent):void {
			_timer.delay = event.newValue as int;
		}
		
		private function initTrayIcon():void {
			newIconBitmap = (new icon16() as BitmapAsset).bitmapData;
			setIcon(newIconBitmap);
		}
	}
}