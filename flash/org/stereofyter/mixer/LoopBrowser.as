package org.stereofyter.mixer
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.utils.ArrayUtil;
	
	import com.chrislovejoy.utils.Debug;
	import org.stereofyter.StereofyterAppController;
	import org.stereofyter.mixer.Sample;
	
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
		public static const
			SAMPLE_LIST_LOADED:String = "loopbrowser_sample_list_loaded",
		private var
			sampleData:Array = [],
			SampleRoot:String,
			loopListLoader:URLLoader;
			loopListLoader.addEventListener(Event.COMPLETE, loadCompleteListener);
		public var
			samples:Array = [];
		
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
		public function loadSampleList(url:String):void {
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, function(event:Event) {
				try {
					var json:Object = JSON.decode(loader.data);
					SampleRoot = json.sampleRoot;
					sampleData = ArrayUtil.createUniqueCopy(sampleData.concat(json.samples));
					dispatchEvent(new Event(SAMPLE_LIST_LOADED, true));
				} catch (error:Error) {
					Debug.log(error, "loading sample list failed ('"+url+"')");
				}
			});
			loader.load(new URLRequest(url));
		}
		private function onSampleListLoad(event:Event):void {
			/*for preview, just put all samples in the bin*/
			bins[0].clearSamples();
			bins[1].clearSamples();
			for (var i:int = 0; i < sampleData.length; i++) {
				addSample(new Sample({
					src:sampleData[i].src,
					name:sampleData[i].name,
					family:sampleData[i].family,
					country:sampleData[i].country,
					tempo:sampleData[i].tempo,
					key:sampleData[i].key
				}));
			}
		}
		private function addSample(sample:Sample):void {
			samples.push(sample);
			//draw sample in scrolling list
		}
	}
}
