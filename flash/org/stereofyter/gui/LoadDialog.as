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
			var data:Object = JSON.decode(mixListLoader.data);
			if (data) {
				if (data.hasOwnProperty("error")) {
					_error = data.error;
					dispatchEvent(new Event(LoadDialog.LOAD_ERROR, true));
					return;
				}
				mixListData = data;
				form.mixList.removeAll();
				var dp:DataProvider = new DataProvider();
				for (var id:String in data) {
					dp.addItem({
						label: data[id].title + ' ('+data[id].duration+'s)',
						data:id
					});
				}
				form.mixList.dataProvider = dp;
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