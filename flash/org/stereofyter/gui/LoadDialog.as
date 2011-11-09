package org.stereofyter.gui
{
	import com.adobe.serialization.json.JSON;
	import com.chrislovejoy.utils.Debug;
	
	import fl.controls.Button;
	import fl.controls.SelectableList;
	import fl.controls.TextInput;
	import fl.data.DataProvider;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	public class LoadDialog extends MovieClip
	{
		public static const
			SUBMIT_LOAD_MIX:String = 'submit load mix',
			LOAD_ERROR:String = 'load_formElement_load_error';
		protected var
			loadURL:String,
			mixListURL:String,
			mixListData:Object,
			mixListXData:Object,
			formElement:MovieClip,
			mixListLoader:URLLoader,
			_error:String;
		public function LoadDialog(loadURL:String, mixListURL:String):void
		{
			this.loadURL = loadURL;
			this.mixListURL = mixListURL;
			mixListLoader = new URLLoader();
			mixListLoader.addEventListener(Event.COMPLETE, onMixListLoadComplete);
			form.submit.addEventListener(MouseEvent.CLICK, onMixLoadSubmit);
			form.closeButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent){hide();});
			form.addEventListener(KeyboardEvent.KEY_UP, trapKeyboardEvent);
		}
		public function show():void
		{
			gotoAndPlay('show');
			mixListLoader.load(new URLRequest(mixListURL));
		}
		public function hide():void
		{
			gotoAndPlay('hide');
		}
		public function get mixId():Number {
			return Number(form.mixList.selectedItem.data);
		}
		public function get mixTitle():String {
			return form.title.text;
		}
		protected function onMixListLoadComplete(event:Event) {
			try {
				var data:Object = JSON.decode(mixListLoader.data);
			} catch (e:Error) {
				Debug.deepLog(e);
			}
			if (data) {
				if (data.hasOwnProperty("error")) {
					_error = data.error;
					dispatchEvent(new Event(LoadDialog.LOAD_ERROR, true));
					return;
				}
				mixListData = data;
				form.mixList.removeAll();
				mixListXData = {};
				for (var i:int = 0; i < data.length; i++) {
					mixListXData[data[i].id] = data[i];
					var seconds:String = String(Math.round(data[i].duration / 1000 % 60));
					if (seconds.length == 1) seconds = "0"+seconds;
					var minutes:String = String(Math.floor(data[i].duration / 60000));
					form.mixList.addItem({
						label: data[i].title + ' ('+minutes+':'+seconds+')',
						data:data[i].id
					});
				}
			}
		}
		protected function onMixLoadSubmit(event:Event):void
		{
			dispatchEvent(new Event(SUBMIT_LOAD_MIX, true));
		}
		
		protected function trapKeyboardEvent(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case Keyboard.ESCAPE: hide(); break;
			}
			event.stopPropagation();
		}
	}
}