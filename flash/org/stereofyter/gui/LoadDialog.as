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
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.text.TextField;
	
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
			this.loadURL = loadURL || 'http://local.stereofyter.org/scripts/load_mix.php';//DEBUG
			this.mixListURL = mixListURL || 'http://local.stereofyter.org/scripts/my_mixes.json.php';//DEBUG
			formElement = form;
			mixListLoader = new URLLoader();
			mixListLoader.addEventListener(Event.COMPLETE, onMixListLoadComplete);
			formElement.submit.addEventListener(MouseEvent.CLICK, onMixLoadSubmit);
			formElement.mixList.addEventListener(Event.CHANGE, function(event:Event){Debug.deepLog(event.target.selectedItem);});
			formElement.closeButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent){hide();});
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
			return Number(formElement.mixList.selectedItem.data);
		}
		public function get mixTitle():String {
			return formElement.title.text;
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
				formElement.mixList.removeAll();
				var dp:DataProvider = new DataProvider();
				for (var id:String in data) {
					dp.addItem({
						label: data[id].title + ' ('+data[id].duration+'s)',
						data:id
					});
				}
				dp.addItem({label:'test', data:'value'});
				formElement.mixList.dataProvider = dp;
				Debug.deepLog(formElement.mixList.dataProvider, "formElement.mixList.dataProvider");
			}
		}
		protected function onMixLoadSubmit(event:Event):void
		{
			dispatchEvent(new Event(SUBMIT_LOAD_MIX));
		}
	}
}