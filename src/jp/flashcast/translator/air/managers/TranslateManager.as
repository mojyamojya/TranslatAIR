package jp.flashcast.translator.air.managers
{
	import com.adobe.serialization.json.JSON;
	
	import flash.net.URLVariables;
	
	import jp.flashcast.translator.air.models.TranslateModel;
	import jp.flashcast.translator.air.util.Locale;
	
	import mx.formatters.DateFormatter;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class TranslateManager
	{
		private var _service:HTTPService;
		private var _model:TranslateModel;
		
		public function TranslateManager()
		{
		}
		
		public function initTranslateManager(model:TranslateModel):void {
			_service = new HTTPService();
			_service.url = "http://ajax.googleapis.com/ajax/services/language/translate";
			_service.method = "post";
			_service.addEventListener(ResultEvent.RESULT, onResult);
			_service.addEventListener(FaultEvent.FAULT, onFault);
			
			_model = model;
		}
		
		public function Translate(v:String, q:String, languageFrom:String, languageTo:String):void {
			var forms:URLVariables = new URLVariables();
			
			forms.v = v;
			forms.q = q;
			forms.format = "text";
			forms.langpair = languageFrom + "|" + languageTo;
			_service.request = forms;
			_service.send();
		}
		
		private function onResult(event:ResultEvent):void {
			// 翻訳時間をセット
			setUpdatetime();

			var json:Object = JSON.decode(event.result.toString());
			
			if (json.responseStatus == 200) {
				if (json.responseData.translatedText != "") {
					_model.Translated = json.responseData.translatedText;
					_model.Result = true;
				}
				else {
					// 変換結果が空だった場合、メッセージに「翻訳失敗...」をセットする
					_model.Translated = Locale.localize("翻訳失敗...");
				}
			}
			else {
				_model.Translated = Locale.localize("翻訳失敗...");
			}
			
			_model.Callback = true;
		}
		
		private function onFault(event:FaultEvent):void {
			_model.Translated = Locale.localize("翻訳失敗...") + "\n" + event.fault.message;
			_model.Callback = true;
		}
		
		private function setUpdatetime():void {
			var formatter:DateFormatter = new DateFormatter();
			formatter.formatString = "YYYY/MM/DD JJ:NN:SS";
			_model.DateTime = formatter.format(new Date());
		}
		
	}
}