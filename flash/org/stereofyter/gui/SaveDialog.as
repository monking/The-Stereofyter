package org.stereofyter.gui
{
	import com.adobe.serialization.json.JSON;
	import com.chrislovejoy.utils.Debug;
	import com.chrislovejoy.utils.StringUtils;
	
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
			SUBMIT_SAVE_MIX:String = 'submit save mix';
		protected var
			saveURL:String,
			mixData:Object,
			_error:String;
		public function SaveDialog(saveURL:String, mixListURL:String):void
		{
			this.saveURL = saveURL;
			form.saveNew.addEventListener(Event.CHANGE, onSaveNewChange);
			form.submit.addEventListener(MouseEvent.CLICK, onMixSaveSubmit);
			form.closeButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent){hide();});
			form.addEventListener(KeyboardEvent.KEY_UP, trapKeyboardEvent);
		}
		public function show(mixData:Object = null):void
		{
			gotoAndPlay('show');
			this.mixData = mixData;
			if (mixData && mixData.id) {
				form.title.text = mixData.title;
				form.published.selected = mixData.published == "1";
				form.message.htmlText = mixData.message || "";
			}
			form.saveNew.enabled = mixData && !isNaN(mixData.id);
			form.saveNew.selected = !form.saveNew.enabled;
			form.saveNew.dispatchEvent(new Event(Event.CHANGE));
		}
		public function hide():void
		{
			gotoAndPlay('hide');
		}
		public function get mixId():Number{
			return !form.saveNew.selected && mixData ? mixData.id : NaN;
		}
		public function get mixTitle():String {
			return form.title.text;
		}
		public function get mixPublished():Boolean {
			return form.published.selected;
		}
		public function get mixMessage():String {
			return form.message.text;
		}
		protected function onMixSaveSubmit(event:Event):void
		{
			dispatchEvent(new Event(SUBMIT_SAVE_MIX, true));
		}
		protected function onSaveNewChange(event:Event):void
		{
			if (event.target.selected) {// new mix
				form.submit.label = 'Save New Mix';
				form.published.selected = false;
				form.published.selected = false;
			} else {// overwriting mix
				var shortTitle = mixData.title.substr(0,20);
				if (shortTitle.length < mixData.title.length)
					shortTitle += "...";
				form.submit.label = 'Overwrite "'+shortTitle+'"';
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