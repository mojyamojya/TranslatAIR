package jp.flashcast.translator.air.components
{
	import jp.flashcast.translator.air.models.LanguageModel;
	
	import mx.collections.XMLListCollection;
	import mx.controls.ComboBox;

	public class ComboBoxExBase extends ComboBox
	{
		public function ComboBoxExBase()
		{
			super();
		}
		
		public function initItems(model:LanguageModel):void {
			this.dataProvider = model.Languages.item;
		}
		
		public function selectItem(data:String):void {
			var arr:XMLListCollection = this.dataProvider as XMLListCollection;
			if (arr != null) {
				for (var i:int = 0; i < arr.length; i++) {
					if (arr[i].data == data) {
						this.selectedIndex = i;
						break;
					}
				}
			}
		}
		
	}
}