package org.stereofyter.mixer
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.utils.ArrayUtil;
	import com.chrislovejoy.utils.Debug;
	
	import fl.controls.Button;
	import fl.controls.SelectableList;
	import fl.controls.TextInput;
	import fl.data.DataProvider;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import org.stereofyter.StereofyterAppController;
	import org.stereofyter.mixer.Sample;
	
	public class LoopBrowser extends MovieClip
	{
		public static const
			SAMPLE_LIST_LOADED:String = "loopbrowser_sample_list_loaded",
			SCROLL_BOUNDS:Rectangle = new Rectangle(292, -215.95, 0, 143.45);
		private var
			loader:URLLoader,
			sampleData:Array = [],
			selectedIndex:int = -1,
			listHolder:Sprite,
			listMask:Sprite,
			_active:Boolean = false;
		public var
			sampleRoot:String,
			samples:Array = [],
			sortOn:String = 'family,title',
			order:String = 'asc';
		
		public function LoopBrowser():void
		{
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onSampleListLoad);
			draw();
			enableScrollbar();
		}
		public function show():void
		{
			_active = true;
			gotoAndPlay('show');
		}
		public function hide():void
		{
			_active = false;
			gotoAndPlay('hide');
		}
		public function toggle():void
		{
			_active ? hide() : show();
		}
		public function loadSampleList(url:String):void {
			loader.load(new URLRequest(url));
		}
		public function sort(sortOn:String, order:String = 'asc'):Array {
			var sortOnSeries = sortOn.split(',');
			if (samples.length) {
				samples.sort(function(a:Object, b:Object):Number {
					var mod:int = order == 'asc' ? 1 : -1;
					for (var i:int = 0; i < sortOnSeries.length; i++) {
						if (!a.hasOwnProperty(sortOnSeries[i])) continue;
						if (a[sortOnSeries[i]] > b[sortOnSeries[i]]) return 1 * mod;
						if (a[sortOnSeries[i]] < b[sortOnSeries[i]]) return -1 * mod;
					}
					return 0;
				});
			}
			for (var i:int = 0; i < samples.length; i++) {
				getSampleRegion(samples[i]).y = i * 60;
			}
			return samples;
		}
		public function setSampleUsed(sample:Sample, used:Boolean = true):void {
			var region:LoopBrowserRegion = getSampleRegion(sample);
			if (!region) return;
			region.setUsed(used);
		}
		public function get selectedSample():Sample {
			if (selectedIndex == -1) return null;
			return samples[selectedIndex];
		}
		public function get active():Boolean {
			return _active;
		}
		private function getSampleRegion(sample:Sample):LoopBrowserRegion {
			return listHolder.getChildByName(sample.src) as LoopBrowserRegion;
		}
		private function draw():void {
			listHolder = new Sprite();
			addChild(listHolder);
			listHolder.x = -310;
			listHolder.y = -250;
			listMask = new Sprite();
			addChild(listMask);
			listHolder.mask = listMask;
			listMask.graphics.beginFill(0x000000);
			listMask.graphics.drawRect(0, 0, 600, 240);
			listMask.graphics.endFill();
			listMask.x = listHolder.x;
			listMask.y = listHolder.y;
		}
		private function enableScrollbar():void {
			scrollHandle.addEventListener(MouseEvent.MOUSE_DOWN, onStartScrollSlide);
			scrollHandle.buttonMode = true;
			scrollUpButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent) {
				scrollStep(-1);
			});
			scrollDownButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent) {
				scrollStep(1);
			});
			scrollTrack.addEventListener(MouseEvent.CLICK, function(event:MouseEvent) {
				scrollStep(scrollHandle.mouseY > 0 ? 4 : -4);
			});
		}
		private function scrollStep(count:int):void {
			scrollHandle.y += count * 60 / (listHolder.height - listMask.height) * SCROLL_BOUNDS.height;
			if (scrollHandle.y < SCROLL_BOUNDS.y) scrollHandle.y = SCROLL_BOUNDS.y;
			if (scrollHandle.y > SCROLL_BOUNDS.y + SCROLL_BOUNDS.height) scrollHandle.y = SCROLL_BOUNDS.y + SCROLL_BOUNDS.height;
			onScrollSlide();
			onStopScrollSlide();
		}
		private function onScrollSlide(event:MouseEvent = null):void {
			var ratio = (scrollHandle.y - SCROLL_BOUNDS.y) / SCROLL_BOUNDS.height;
			listHolder.y = listMask.y - ratio * (listHolder.height - listMask.height); 
		}
		private function onStartScrollSlide(event:MouseEvent = null):void {
			scrollHandle.startDrag(false, SCROLL_BOUNDS);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onScrollSlide);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStopScrollSlide);
			stage.addEventListener(Event.MOUSE_LEAVE, onStopScrollSlide);
		}
		private function onStopScrollSlide(event:MouseEvent = null):void {
			scrollHandle.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onScrollSlide);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStopScrollSlide);
			stage.removeEventListener(Event.MOUSE_LEAVE, onStopScrollSlide);
			listHolder.y = Math.round((listHolder.y - listMask.y) / 60) * 60 + listMask.y; 
		}
		private function onSampleListLoad(event:Event):void {
			try {
				var json:Object = JSON.decode(loader.data);
				sampleRoot = json.sampleRoot;
				sampleData = ArrayUtil.createUniqueCopy(sampleData.concat(json.samples));
				for (var i:int = 0; i < sampleData.length; i++) {
					var options = {
						src:sampleData[i].src,
						title:sampleData[i].title,
						family:sampleData[i].family,
						country:sampleData[i].country,
						tempo:sampleData[i].tempo,
						key:sampleData[i].key,
						artist:sampleData[i].artist,
						artistId:sampleData[i].artistId,
						duration:sampleData[i].duration,
						selected:sampleData[i].selected
					};
					var sample = new Sample(options);
					addSample(sample);
				}
				sort(sortOn, order);
				dispatchEvent(new Event(SAMPLE_LIST_LOADED));
			} catch (error:Error) {
				Debug.log(error, "loading sample list failed");
			}
		}
		private function addSample(sample:Sample):void {
			addChild(sample);
			samples.push(sample);
			var region = new LoopBrowserRegion(sample);
			listHolder.addChild(region);
			region.x = 10;
			region.y = (samples.length - 1) * 60;
		}
		private function scrollSamples(position:Number):void {
			
		}
	}
}
