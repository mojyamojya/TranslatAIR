package jp.flashcast.translator.air.managers
{
	import flash.desktop.DockIcon;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemTrayIcon;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import jp.flashcast.translator.air.events.TransMenuEvent;
	import jp.flashcast.translator.air.models.ConfigModel;
	import jp.flashcast.translator.air.models.WindowModel;
	import jp.flashcast.translator.air.util.Locale;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.events.PropertyChangeEvent;

	public class MenuManager extends EventDispatcher
	{
		private var _fmodel:ConfigModel;
		private var _wmodel:WindowModel;

		public function MenuManager()
		{
		}

		public function initMenuManager(fmodel:ConfigModel, wmodel:WindowModel):void {
			_fmodel = fmodel;
			_wmodel = wmodel;

			ChangeWatcher.watch(_fmodel, '_translate', onTransConfigChangedHandler);
			ChangeWatcher.watch(_fmodel, '_clipmode', onClipmodeConfigChangeHandler);

			initMenuItem();
		}

		public function initMenuItem():void {
			var transMenuItem:NativeMenuItem = new NativeMenuItem(Locale.localize("翻訳"));
			var historyMenuItem:NativeMenuItem = new NativeMenuItem(Locale.localize("翻訳履歴"));
			var configMenuItem:NativeMenuItem = new NativeMenuItem(Locale.localize("設定"));
			var clipmodeMenuItem:NativeMenuItem = new NativeMenuItem(Locale.localize("クリップボードを置き換える"));

			transMenuItem.addEventListener(Event.SELECT, onTranslateMenuSelectHandler);
			historyMenuItem.addEventListener(Event.SELECT, onHistoryMenuSelectHandler);
			configMenuItem.addEventListener(Event.SELECT, onConfigMenuSelectHandler);
			clipmodeMenuItem.addEventListener(Event.SELECT, onClipmodeMenuSelectHandler);

			clipmodeMenuItem.name = "clipmode";
			clipmodeMenuItem.enabled = _fmodel.Translate;
			clipmodeMenuItem.checked = _fmodel.Clipmode;

			var menu:NativeMenu = new NativeMenu();
			menu.addItem(transMenuItem);
			menu.addItem(new NativeMenuItem("", true));
			menu.addItem(historyMenuItem);
			menu.addItem(configMenuItem);
			menu.addItem(new NativeMenuItem("", true));
			menu.addItem(clipmodeMenuItem);

			if (NativeApplication.supportsSystemTrayIcon) {
				// Windows対応
				// Macの場合はDockアイコンに終了メニューが自動的に入るためセットしない。
				var exitMenuItem:NativeMenuItem = new NativeMenuItem(Locale.localize("終了"));
				exitMenuItem.addEventListener(Event.SELECT, onExitMenuSelectHandler);
				menu.addItem(new NativeMenuItem("", true));
				menu.addItem(exitMenuItem);
			}

			setSystemMenu(menu);
		}

		private function onClipmodeConfigChangeHandler(event:PropertyChangeEvent):void {
			var menuItem:NativeMenuItem = getClipmodeMenuItem();
			menuItem.checked = event.newValue as Boolean;
		}

		private function onTransConfigChangedHandler(event:PropertyChangeEvent):void {
			var menuItem:NativeMenuItem = getClipmodeMenuItem();
			menuItem.enabled = event.newValue as Boolean;
		}

		private function onTranslateMenuSelectHandler(event:Event):void {
			dispatchEvent(new TransMenuEvent(TransMenuEvent.TRANSLATE_SELECT));
		}

		private function onHistoryMenuSelectHandler(event:Event):void {
			dispatchEvent(new TransMenuEvent(TransMenuEvent.HISTORY_SELECT));
		}

		private function onConfigMenuSelectHandler(event:Event):void {
			dispatchEvent(new TransMenuEvent(TransMenuEvent.CONFIG_SELECT));
		}

		private function onExitMenuSelectHandler(event:Event):void {
			NativeApplication.nativeApplication.exit();
		}

		private function onClipmodeMenuSelectHandler(event:Event):void {
			_fmodel.Clipmode = !_fmodel.Clipmode;

			var menuItem:NativeMenuItem = event.target as NativeMenuItem;
			menuItem.checked = _fmodel.Clipmode;

			dispatchEvent(new TransMenuEvent(TransMenuEvent.CLIPMODE_SELECT));
		}

		private function getSystemMenu():NativeMenu {
			var menu:NativeMenu;
			
			if (NativeApplication.supportsSystemTrayIcon) {
				menu = getSystemTrayIcon().menu;
			}
			else if (NativeApplication.supportsDockIcon) {
				menu = getDockIcon().menu;
			}
			
			return menu;
		}

		private function setSystemMenu(menu:NativeMenu):void {
			if (NativeApplication.supportsSystemTrayIcon) {
				getSystemTrayIcon().menu = menu;
			}
			else if (NativeApplication.supportsDockIcon) {
				getDockIcon().menu = menu;
			}
		}

		private function getClipmodeMenuItem():NativeMenuItem {
			return getSystemMenu().getItemByName("clipmode");
		}

		private function getSystemTrayIcon():SystemTrayIcon {
			return NativeApplication.nativeApplication.icon as SystemTrayIcon;
		}

		private function getDockIcon():DockIcon {
			return NativeApplication.nativeApplication.icon as DockIcon;
		}
	}
}
