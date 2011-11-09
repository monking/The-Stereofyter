package org.stereofyter.gui
{
	import com.adobe.serialization.json.JSON;
	import com.chrislovejoy.utils.Debug;
	
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
			try {
				var data:Object = JSON.decode(mixListLoader.data);
			} catch (e:Error) {
				Debug.deepLog(e);
			}
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
				for (var i:int = 0; i < data.length; i++) {
					var seconds:String = String(Math.round(data[i].duration / 1000 % 60));
					if (seconds.length == 1) seconds = "0"+seconds;
					var minutes:String = String(Math.floor(data[i].duration / 60000));
					form.mixList.addItem({
						label: data[i].title + ' ('+minutes+':'+seconds+')',
						data:data[i].id
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
				form.title.text = mixListData[mixId].title;
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