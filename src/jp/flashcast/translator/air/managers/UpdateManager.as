package jp.flashcast.translator.air.managers
{
	import air.update.ApplicationUpdater;
	import air.update.events.UpdateEvent;
	
	import flash.events.ErrorEvent;
	import flash.filesystem.File;

	public class UpdateManager extends ApplicationUpdater
	{
		public function UpdateManager()
		{
			super();
			
			this.configurationFile = File.applicationDirectory.resolvePath("update-config.xml");
			this.addEventListener(ErrorEvent.ERROR, trace);
		}
		
		public function initUpdateManager():void {
			this.addEventListener(UpdateEvent.INITIALIZED, updateInitializeHandler);
			this.initialize();
		}
		
		private function updateInitializeHandler(event:UpdateEvent):void {
			this.removeEventListener(event.type, arguments.callee);
			this.checkNow();
		}
		
	}
}