package jp.flashcast.translator.air.managers
{
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLEvent;
	
	import jp.flashcast.translator.air.models.ConfigModel;
	import jp.flashcast.translator.air.models.TwitterModel;
	
	import mx.formatters.DateFormatter;
	
	public class ConfigManager
	{
		private var _fmodel:ConfigModel;
		private var _tmodel:TwitterModel;
		
		public function ConfigManager()
		{
		}
		
		public function initConfigManager(fmodel:ConfigModel, tmodel:TwitterModel):void {
			_fmodel = fmodel;
			_tmodel = tmodel;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.text = "CREATE TABLE IF NOT EXISTS config (" +
				"id INTEGER PRIMARY KEY, " +
				"languagefrom TEXT, " +
				"languageto TEXT, " +
				"translate TEXT, " +
				"clipmode TEXT, " +
				"tweet TEXT, " +
				"account TEXT, " +
				"password TEXT, " +
				"delayicon INTEGER, " +
				"delayalpha INTEGER, " +
				"alpha REAL, " +
				"tx INTEGER, " +
				"ty INTEGER, " +
				"hx INTEGER, " +
				"hy INTEGER, " +
				"cx INTEGER, " +
				"cy INTEGER, " +
				"ax INTEGER, " +
				"ay INTEGER, " +
				"datetime TEXT);";

			ConnectionManager.initConnectionManager();
			ConnectionManager.execute(stmt, initConfigHandler);
		}
		
		private function initConfigHandler(event:SQLEvent):void {
			getConfig();
		}
		
		private function getConfig():void {
			var stmt:SQLStatement = new SQLStatement();

			stmt.text = "SELECT languagefrom, languageto, translate, clipmode, " +
				"tweet, account, password, delayicon, delayalpha, alpha, " +
				"tx, ty, hx, hy, cx, cy, ax, ay FROM config;" 

			ConnectionManager.execute(stmt, selectHandler);
		}
		
		private function selectHandler(event:SQLEvent):void {
			var stmt:SQLStatement = event.currentTarget as SQLStatement;
			stmt.removeEventListener(SQLEvent.RESULT, arguments.callee);
			
			var result:SQLResult = stmt.getResult();
			
			if (result.data != null) {
				_fmodel.LanguageFrom = result.data[0].languagefrom;
				_fmodel.LanguageTo = result.data[0].languageto;
				_fmodel.Translate = (result.data[0].translate == "1");
				_fmodel.Clipmode = (result.data[0].clipmode == "1");
				_fmodel.Tweet = (result.data[0].tweet == "1");
				_fmodel.Account = result.data[0].account;
				_tmodel.Account = result.data[0].account;
				_fmodel.Password = result.data[0].password;
				_tmodel.Password = result.data[0].password;
				_fmodel.DelayIcon = result.data[0].delayicon;
				_fmodel.DelayAlpha = result.data[0].delayalpha;
				_fmodel.Alpha = result.data[0].alpha;
				_fmodel.Tx = result.data[0].tx;
				_fmodel.Ty = result.data[0].ty;
				_fmodel.Hx = result.data[0].hx;
				_fmodel.Hy = result.data[0].hy;
				_fmodel.Cx = result.data[0].cx;
				_fmodel.Cy = result.data[0].cy;
				_fmodel.Ax = result.data[0].ax;
				_fmodel.Ay = result.data[0].ay;
			}
			else {
				insertConfig();
			}
		}
		
		public function updateConfig():void {
			var stmt:SQLStatement = new SQLStatement();

			stmt.text = "UPDATE config set languagefrom = :languagefrom, languageto = :languageto, " +
				"translate = :translate, clipmode = :clipmode, tweet = :tweet, account = :account, " +
				"password = :password, delayicon = :delayicon, delayalpha = :delayalpha, " +
				"alpha = :alpha, datetime = :datetime;"
			stmt.parameters[":languagefrom"] = _fmodel.LanguageFrom;
			stmt.parameters[":languageto"] = _fmodel.LanguageTo; 
			stmt.parameters[":translate"] = _fmodel.Translate;
			stmt.parameters[":clipmode"] = _fmodel.Clipmode;
			stmt.parameters[":tweet"] = _fmodel.Tweet;
			stmt.parameters[":account"] = _fmodel.Account;
			stmt.parameters[":password"] = _fmodel.Password;
			stmt.parameters[":delayicon"] = _fmodel.DelayIcon;
			stmt.parameters[":delayalpha"] = _fmodel.DelayAlpha;
			stmt.parameters[":alpha"] = _fmodel.Alpha;
			stmt.parameters[":datetime"] = getUpdatetime();
			
			ConnectionManager.execute(stmt);
		}
		
		private function insertConfig():void {
			var stmt:SQLStatement = new SQLStatement();
			
			stmt.text = "INSERT INTO config (languagefrom, languageto, translate, clipmode, tweet, " +
				"account, password, delayicon, delayalpha, alpha, " + 
				"tx, ty, hx, hy, cx, cy, ax, ay, datetime) " +
				"VALUES (:languagefrom, :languageto, :translate, :clipmode, :tweet, " +
				":account, :password, :delayicon, :delayalpha, :alpha, " +
				":tx, :ty, :hx, :hy, :cx, :cy, :ax, :ay, :datetime) ";
			stmt.parameters[":languagefrom"] = _fmodel.LanguageFrom;
			stmt.parameters[":languageto"] = _fmodel.LanguageTo; 
			stmt.parameters[":translate"] = _fmodel.Translate;
			stmt.parameters[":clipmode"] = _fmodel.Clipmode;
			stmt.parameters[":tweet"] = _fmodel.Tweet;
			stmt.parameters[":account"] = _fmodel.Account;
			stmt.parameters[":password"] = _fmodel.Password;
			stmt.parameters[":delayicon"] = _fmodel.DelayIcon;
			stmt.parameters[":delayalpha"] = _fmodel.DelayAlpha;
			stmt.parameters[":alpha"] = _fmodel.Alpha;
			stmt.parameters[":tx"] = _fmodel.Tx;
			stmt.parameters[":ty"] = _fmodel.Ty;
			stmt.parameters[":hx"] = _fmodel.Hx;
			stmt.parameters[":hy"] = _fmodel.Hy;
			stmt.parameters[":cx"] = _fmodel.Cx;
			stmt.parameters[":cy"] = _fmodel.Cy;
			stmt.parameters[":ax"] = _fmodel.Ax;
			stmt.parameters[":ay"] = _fmodel.Ay;
			stmt.parameters[":datetime"] = getUpdatetime();
			
			ConnectionManager.execute(stmt);
		}
		
		private function getUpdatetime():String {
			var formatter:DateFormatter = new DateFormatter();
			formatter.formatString = "YYYY/MM/DD JJ:NN:SS";
			return formatter.format(new Date());
		}
		
		public function updateOriginConfig(label:String, data:int):void {
			var stmt:SQLStatement = new SQLStatement();
			
			stmt.text = "UPDATE config set " + label + " = :" + label + ", datetime = :datetime;"
			stmt.parameters[":" + label] = data;
			stmt.parameters[":datetime"] = getUpdatetime();
			
			ConnectionManager.execute(stmt);
		}
		
		public function updateAccountConfig(account:String, password:String):void {
			var stmt:SQLStatement = new SQLStatement();
			
			stmt.text = "UPDATE config set account = :account, password = :password, datetime = :datetime;"
			stmt.parameters[":account"] = account;
			stmt.parameters[":password"] = password;
			stmt.parameters[":datetime"] = getUpdatetime();
			
			ConnectionManager.execute(stmt);
		}

	}
}