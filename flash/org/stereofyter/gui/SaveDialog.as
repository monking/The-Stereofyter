package org.stereofyter.gui
{
	import com.adobe.serialization.json.JSON;
	
	import fl.controls.Button;
	import fl.controls.SelectableList;
	import fl.controls.TextInput;
	
	import flash.display.MovieClip;
	import flash.display.TextField;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

	public class SaveDialog extends MovieClip
	{
		public static const
			SUBMIT_SAVE_MIX:String = 'submit save mix',
			LOAD_ERROR:String = 'save_form_load_error';
		protected var
			saveUrl:String,
			mixListURL:String,
			mixListData:Object,
			mixListLoader:URLLoader,
			_error:String;
		public function SaveDialog(saveUrl:String, mixListUrl:String):void
		{
			this.saveUrl = saveUrl;
			this.mixListUrl = mixListUrl;
			mixListLoader = new URLLoader();
			mixListLoader.addEventListener(Event.COMPLETE, onMixListLoadComplete);
			mixList.addEventListener(Event.CHANGE, onMixSelected);
			submit.addEventListener(MouseEvent.CLICK, onMixSaveSubmit);
		}
		public function show():void
		{
			gotoAndPlay('show');
			mixListLoader.load(new URLRequest(mixListUrl));
		}
		public function hide():void
		{
			gotoAndPlay('hide');
		}
		public function get mixId():Number {
			return Number(mixList.selectedItem.data);
		}
		public function get mixTitle():String {
			return title.text;
		}
		protected function onMixListLoadComplete(event:Event) {
			var data:Object = JSON.decode(mixListLoader.data);
			if (data) {
				if (data.hasOwnProperty("error")) {
					_error = data.error;
					dispatchEvent(new Event(SaveDialog.LOAD_ERROR, true));
					return;
				}
				mixListData = data;
				mixSelectableList.removeAll();
				for (var id:String in data) {
					mixSelectableList.addItem({
						label:data[id].title
						data:id,
					});
				}
				mixSelectableList.addItem({
					label:'(Save a New Mix)'
					data:'new',
				});
			}
		}
		protected function onMixSaveSubmit(event:Event):void
		{
			dispatchEvent(new Event(SUBMIT_SAVE_MIX));
		}
	}
}