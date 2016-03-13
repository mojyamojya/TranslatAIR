package jp.flashcast.translator.air.managers
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	
	public class ConnectionManager
	{
		private static var connection:SQLConnection;
		private var stmt:SQLStatement;
		
		public function ConnectionManager()
		{
		}
		
		public static function initConnectionManager():void {
			if (connection == null) {
				connection = new SQLConnection();
				connection.addEventListener(SQLErrorEvent.ERROR, errorHandler);
				connection.open(File.applicationStorageDirectory.resolvePath("translatair.db"));
			}
		}

		private static function errorHandler(event:SQLErrorEvent):void {
			throw new Error(event.errorID + ":" + event.eventPhase);
		}

		public static function execute(stmt:SQLStatement, callback:Function = null):void {
			if (callback != null) {
				stmt.addEventListener(SQLEvent.RESULT, callback);
			}
			
			stmt.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			stmt.sqlConnection = connection;
			stmt.execute();
		}
		
		public static function close():void {
			if (connection != null) {
				if (connection.connected) {
					connection.close();
				}
			}
		}

	}
}