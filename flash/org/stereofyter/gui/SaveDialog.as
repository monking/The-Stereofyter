package org.stereofyter.gui
{
	import com.adobe.serialization.json.JSON;
	
	import fl.controls.Button;
	import fl.controls.SelectableList;
	import fl.controls.TextInput;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.text.TextField;
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
			_error:String,
			SelectedMixID:Number;
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
		public function selectMixId(id:Number):void {
			SelectedMixID = id;
			if (isNaN(SelectedMixID))
				form.mixList.selectedIndex = 0;
			for (var i:int = 0; i < form.mixList.length; i++) {
				var item = form.mixList.dataProvider.getItemAt(i);
				if (item.data == id) {
					form.mixList.selectedIndex = i;
					form.mixList.scrollToIndex(form.mixList.selectedIndex);
					form.title.text = mixListData[id].title;
					return;
				}
			}
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
				form.mixList.addItem({
					label:'(Save a New Mix)',
					data:'new'
				});
				form.mixList.selectedIndex = 0;
				for (var id:String in data) {
					form.mixList.addItem({
						label:data[id].title,
						data:id
					});
				}
				selectMixId(SelectedMixID);
			}
		}
		protected function onMixSaveSubmit(event:Event):void
		{
			dispatchEvent(new Event(SUBMIT_SAVE_MIX, true));
		}
		protected function onMixSelect(event:Event):void
		{
			if (isNaN(mixId)) {// new mix
				form.titleLabel.text = 'Title';
				form.title.text = 'Untitled';
			} else {// renaming mix
				form.titleLabel.text = 'Title (Rename)';
				form.title.text = form.mixList.selectedItem.label;
			}
		}
		
		protected function trapKeyboardEvent(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case Keyboard.ESCAPE: hide(); break;
			}
			event.stopPropagation();
		}
	}
}