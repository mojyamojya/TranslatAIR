package jp.flashcast.translator.air.views
{
	import flash.events.MouseEvent;
	
	import jp.flashcast.translator.air.events.TransWindowEvent;
	
	import mx.containers.TitleWindow;
	import mx.controls.CheckBox;
	import mx.controls.TextInput;
	import mx.events.CloseEvent;

	public class AccountWindowBase extends TitleWindow
	{
		public var txtAccount:TextInput;
		public var txtPassword:TextInput;
		public var chkSave:CheckBox;
		
		public function AccountWindowBase()
		{
			super();
		}
		
		public function btnOKClickHandler(event:MouseEvent):void {
			if (txtAccount.text != "" && txtPassword.text != "") {
				this.data[0].Account = txtAccount.text;
				this.data[0].Password = txtPassword.text;
				this.data[0].Tweeted = false;
				this.data[0].Tweet = true;
				
				if (chkSave.selected) {
					this.data[1].Account = txtAccount.text;
					this.data[1].Password = txtPassword.text;
					this.data[2].isSave = true;
					dispatchEvent(new TransWindowEvent(TransWindowEvent.ACCOUNT_WINDOW_SAVE));
				}
				
				dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
			}
		}
		
	}
}