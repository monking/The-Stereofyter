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
			LOAD_ERROR:String = 'save_form_load_error';
		protected var
			mixList:Object,
			mixListLoader:URLLoader,
			mixSelectablelist:SelectableList,
			titleField:TextInput,
			saveButton:Button,
			_error:String;
		public function SaveDialog():void
		{
			mixListLoader = new URLLoader();
			mixListLoader.addEventListener(Event.COMPLETE, onMixListLoadComplete);
		}
		public function show():void
		{
			drawForm();
			_visible = true;
		}
		protected function drawForm():void
		{
			list = new SelectableList();
			list.width = 280;
			list.height = 200;
			addChild(list);
			list.addEventListener(Event.CHANGE, onMixSelected);
			saveButton = new Button();
		}
		protected function onMixListLoadComplete(event:Event) {
			var data:Object = JSON.decode(mixListLoader.data);
			if (data) {
				if (data.hasOwnProperty("error")) {
					_error = data.error;
					dispatchEvent(new Event(SaveDialog.LOAD_ERROR, true));
					return;
				}
				mixList = data;
				mixSelectableList.removeAll();
				for (var id:String in data) {
					mixSelectableList.addItem({
						label:data[id].title
						data:id,
					});
				}
			}
		}
		protected function onMixSelected(event:Event):void
		{
			//don't really need to do anything, do we?
		}
	}
}