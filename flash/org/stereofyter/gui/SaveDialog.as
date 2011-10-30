package org.stereofyter.gui
{
	import com.adobe.serialization.json.JSON;
	
	import fl.controls.Button;
	import fl.controls.SelectableList;
	import fl.controls.TextInput;
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.ui.Keyboard;

	public class SaveDialog extends MovieClip
	{
		public static const
			SUBMIT_SAVE_MIX:String = 'submit save mix',
			LOAD_ERROR:String = 'save_form_load_error';
		protected var
			saveURL:String,
			mixListURL:String,
			mixListData:Object,
			mixListLoader:URLLoader,
			_error:String;
		public function SaveDialog(saveURL:String, mixListURL:String):void
		{
			this.saveURL = saveURL;
			this.mixListURL = mixListURL;
			mixListLoader = new URLLoader();
			mixListLoader.addEventListener(Event.COMPLETE, onMixListLoadComplete);
			form.mixList.addEventListener(Event.CHANGE, onMixSelect);
			form.submit.addEventListener(MouseEvent.CLICK, onMixSaveSubmit);
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
					dispatchEvent(new Event(SaveDialog.LOAD_ERROR, true));
					return;
				}
				mixListData = data;
				form.mixList.removeAll();
				for (var id:String in data) {
					form.mixList.addItem({
						label:data[id].title,
						data:id
					});
				}
				form.mixList.addItem({
					label:'(Save a New Mix)',
					data:'new'
				});
			}
		}
		protected function onMixSaveSubmit(event:Event):void
		{
			dispatchEvent(new Event(SUBMIT_SAVE_MIX, true));
		}
		protected function onMixSelect(event:Event):void
		{
			if (isNaN(mixId))// new mix
				form.title.text = 'Title';
			else// renaming mix
				form.title.text = 'Title (Rename)';
		}
		
		protected function trapKeyboardEvent(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case Keyboard.ESCAPE: hide(); break;
			}
			event.stopPropagation();
		}
	}
}