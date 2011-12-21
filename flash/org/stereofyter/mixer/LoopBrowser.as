package org.stereofyter.mixer
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
	import flash.utils.Timer;
	
	public class LoopBrowser extends MovieClip
	{
		public function LoopBrowser():void
		{
		}
		public function show():void
		{
			gotoAndPlay('show');
		}
		public function hide():void
		{
			gotoAndPlay('hide');
		}
	}
}
