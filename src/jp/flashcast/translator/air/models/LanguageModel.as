package jp.flashcast.translator.air.models
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	public class LanguageModel
	{
		private var _languages:XML;
		
		public function LanguageModel()
		{
		}
		
		public function initLanguageModel(config:String):void {
			try {
				var file:File = File.applicationDirectory.resolvePath(config);
				var stream:FileStream = new FileStream();

				stream.open(file, FileMode.READ);
				
				_languages = new XML(stream.readUTFBytes(stream.bytesAvailable));
				stream.close();
			}
			catch(error:Error) {
				throw error;
			}
		}
		
		public function get Languages():XML {
			return _languages;
		}
		
		public function getLanguageLabel(data:String):String {
			var label:String = "";
			
			if (_languages != null) {
				for each (var item:Object in _languages.item) {
					if (item.data == data) {
						label = item.label;
						break;
					}
				}
			}
			
			return label;
		}
		
		public function getLanguageData(label:String):String {
			var data:String = "";
			
			if (_languages != null) {
				for each (var item:Object in _languages.item) {
					if (item.label == label) {
						data = item.data;
						break;
					}
				}
			}
			
			return data;
		}

	}
}