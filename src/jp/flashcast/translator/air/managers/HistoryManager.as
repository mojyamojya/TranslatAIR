package jp.flashcast.translator.air.managers
{
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLEvent;
	
	import jp.flashcast.translator.air.models.HistoryModel;
	import jp.flashcast.translator.air.models.TranslateModel;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.events.PropertyChangeEvent;
	
	public class HistoryManager
	{
		private var _hmodel:HistoryModel;
		private var _gmodel:TranslateModel;
		
		public function HistoryManager()
		{
		}
		
		public function initHistoryManager(hmodel:HistoryModel, gmodel:TranslateModel):void {
			_hmodel = hmodel;
			_gmodel = gmodel;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.text = "CREATE TABLE IF NOT EXISTS history (" +
				"id INTEGER PRIMARY KEY, " +
				"original TEXT, " +
				"translated TEXT, " +
				"languagefrom TEXT, " +
				"languageto TEXT, " +
				"datetime TEXT);";

			ConnectionManager.initConnectionManager();
			ConnectionManager.execute(stmt, initHistoryHandler)
			
			ChangeWatcher.watch(_gmodel, '_callback', onTranslateCallbackHandler);
		}

		private function initHistoryHandler(event:SQLEvent):void {
			getHistory();
		}
		
		private function onTranslateCallbackHandler(event:PropertyChangeEvent):void {
			if (event.newValue as Boolean) {
				setHistory();
			}
		}
		
		private function getHistory():void {
			var stmt:SQLStatement = new SQLStatement();
			stmt.text = "SELECT original, translated, languagefrom, languageto, datetime " +
				"FROM history ORDER BY id desc;" 

			ConnectionManager.execute(stmt, selectHandler);
		}
		
		private function setHistory():void {
			var stmt:SQLStatement = new SQLStatement();

			stmt.text = "INSERT INTO history " +
				"(original, translated, languagefrom, languageto, datetime) " +
				"VALUES " +
				"(:original, :translated, :languagefrom, :languageto, :datetime);";
			stmt.parameters[":original"] = _gmodel.Original;
			stmt.parameters[":translated"] = _gmodel.Translated; 
			stmt.parameters[":languagefrom"] = _gmodel.LanguageFrom;
			stmt.parameters[":languageto"] = _gmodel.LanguageTo;
			stmt.parameters[":datetime"] = _gmodel.DateTime;
			ConnectionManager.execute(stmt);
			
			_hmodel.push({
				original:_gmodel.Original,
				translated:_gmodel.Translated,
				languagefrom:_gmodel.LanguageFrom,
				languageto:_gmodel.LanguageTo,
				datetime:_gmodel.DateTime});
		}
		
		private function selectHandler(event:SQLEvent):void {
			var stmt:SQLStatement = event.currentTarget as SQLStatement;
			stmt.removeEventListener(SQLEvent.RESULT, arguments.callee);
			
			var result:SQLResult = stmt.getResult();
			
			if (result.data != null) {
				_hmodel.History = result.data;
			}
		}
		
		public function close():void {
			ConnectionManager.close();
		}

	}
}