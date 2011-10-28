package org.stereofyter {

	import com.chrislovejoy.WebAppController;
	import com.chrislovejoy.utils.ContextMenuUtil;
	import com.chrislovejoy.utils.Debug;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	
	import org.stereofyter.gui.*;
	import org.stereofyter.mixblendr.*;
	import org.stereofyter.mixer.*;

	public class StereofyterAppController extends WebAppController {
		public static var
			WEBROOT:String = '.';

		private var
			mixer:Mixer,
			engine:MixblendrInterface,
			site:StereofyterSite,
			feedbackDelay:Timer,
			userData:Object = null,
			saveLoader:URLLoader,
			loadLoader:URLLoader;

		public function StereofyterAppController(root:DisplayObject, debug:Boolean = false):void {
			super(root, debug);
			_root.stage.frameRate = 60;
			_root.stage.align = StageAlign.TOP_LEFT;
			_root.stage.quality = StageQuality.HIGH;
			_root.stage.scaleMode = StageScaleMode.NO_SCALE;
			engine = new MixblendrInterface();
			site = new StereofyterSite();
			_root.stage.addChild(site);
			feedbackDelay = new Timer(34, 1);
			addMixer();
			ContextMenuUtil.setContextMenu(site, [
				{
					caption:"©2011 On The Map Records",
					action:null
				},
				{
					caption:"Notify me with updates",
					action:function(){
						site.dispatchEvent(new Event(StereofyterSite.SHOW_NEWSLETTER));
					}
				},
				{
					caption:"About StereoFyter",
					action:function(){
						site.dispatchEvent(new Event(StereofyterSite.SHOW_ABOUT));
					}
				}
			]);
			site.hover("loading mixer engine", {progress: true});
			prepareSaveLoad();
			attachSiteListeners();
			registerExternalMethods();
			engine.check(); //if Java loaded first, this was already called when creating engine. Find a way to do this without redundancy
		}
		
		public function setUserSessionData(data:Object):void {
			userData = data;
		}
		
		private function prepareSaveLoad():void {
			saveLoader = new URLLoader();
			loadLoader = new URLLoader();
			saveLoader.addEventListener(Event.COMPLETE, saveCompleteListener);
			loadLoader.addEventListener(Event.COMPLETE, loadCompleteListener);
		}
		
		private function attachSiteListeners():void {
			site.addEventListener(StereofyterSite.SHOW_ABOUT, function() {
				site.toggleSiteInfoPane();
				site.hideNewsletterSignup();
			});
			site.addEventListener(StereofyterSite.SHOW_NEWSLETTER, function() {
				site.toggleNewsletterSignup();
				site.hideSiteInfoPane();
			});
			site.addEventListener(Mixer.REQUEST_SAVE_MIX, function(event:Event) {
				if (userData)
					site.showSaveDialog();
				else
					ExternalInterface.call('login');
			});
			site.addEventListener(SaveDialog.SUBMIT_SAVE_MIX, function(event:Event) {
				var dialog:SaveDialog = event.target as SaveDialog;
				mixer.updateMixData({
					id:dialog.mixId,
					title:dialog.mixTitle
				});
				saveMix();
			});
		}
		
		
		private function registerExternalMethods():void {
			ExternalInterface.addCallback("setUserSessionData", setUserSessionData);
		}

		private function addMixer():void {
			mixer = new Mixer(523, 220, 8);
			site.midground.addChildAt(mixer, 0);
			mixer.addEventListener(Mixer.REGION_ADDED, function(event:Event) {
				var region:Region = event.target as Region;
				var track:Track = region.parent as Track;
				var sample:Sample = region.sample;
				engine.call("addRegion", track.index, mixer.sampleRoot+sample.src, mixer.getRegionPosition(region));
			});
			mixer.addEventListener(Mixer.REGION_MOVED, function(event:Event) {
				var region:Region = event.target as Region;
				var track:Track = region.parent as Track;
				engine.call("moveRegion", mixer.liftedRegionData.regionIndex, mixer.liftedRegionData.trackIndex, track.index, mixer.getRegionPosition(region));
			});
			mixer.addEventListener(Mixer.REGION_REMOVED, function(event:Event) {
				engine.call("removeRegion", mixer.removedRegionData.regionIndex, mixer.removedRegionData.trackIndex);
			});
			mixer.addEventListener(Mixer.PLAY, function(event:Event) {
				engine.call("startPlayback");
				startUpdatePlayhead(event);
				mixer.setPlaying(true);
			});
			mixer.addEventListener(Mixer.STOP, function(event:Event) {
				engine.call("stopPlayback");
				stopUpdatePlayhead(event);
				mixer.setPlaying(false);
			});
			mixer.addEventListener(Mixer.REWIND, function(event:Event) {
				mixer.playbackPosition = 0;
				mixer.dispatchEvent(new Event(Mixer.SEEK_FINISH));
			});
			mixer.addEventListener(Mixer.SEEK_START, stopUpdatePlayhead);
			mixer.addEventListener(Mixer.SEEK_FINISH, function(event:Event) {
				trace("SEEK_FINISH");
				engine.call("setPlaybackPosition", mixer.playbackPosition);
				if (mixer.isPlaying) {
					feedbackDelay.addEventListener(TimerEvent.TIMER, delayStartUpdatePlayhead);
					feedbackDelay.start();
				}
			});
			mixer.addEventListener(Region.VOLUME_CHANGE, function(event:Event) {
				var region:Region = event.target as Region;
				engine.call("setRegionVolume", region.regionIndex, region.trackIndex, region.volume);
			});
			mixer.addEventListener(Region.MUTE, function(event:Event) {
				var region:Region = event.target as Region;
				engine.call("setRegionMuted", region.regionIndex, region.trackIndex, region.isMuted);
			});
			mixer.addEventListener(Region.SOLO, function(event:Event) {
				var region:Region = event.target as Region;
				for (var i:int = 0; i < mixer.regions.length; i++) {
					var otherRegion:Region = mixer.regions[i];
					engine.call("setRegionMuted", otherRegion.regionIndex, otherRegion.trackIndex, otherRegion.isMuted || otherRegion.solo == Region.SOLO_OTHER);
				}
			});
			mixer.addEventListener(Bin.PREVIEW_TOGGLE, function(event:Event) {
				engine.call("previewToggle", mixer.sampleRoot+event.target.selectedSample.src);
			});
			mixer.addEventListener(SAVE_BEGIN, function(event:Event) {
				site.hover("saving", {progress: true, timeout: 0, close: "none"});
			});
			mixer.addEventListener(SAVE_COMPLETE, function(event:Event) {
				site.hover("save complete", {timeout: 1000, close: "none"});
			});
			mixer.addEventListener(SAVE_ERROR, function(event:Event) {
				Debug.log("save error, about to reference mixer.error");
				site.hover("save error: "+mixer.error, {timeout: 0, close: "top right"});
			});
			mixer.addEventListener(LOAD_BEGIN, function(event:Event) {
				site.hover("loading", {progress: true, timeout: 0, close: "none"});
			});
			mixer.addEventListener(Mixer.PARSE_COMPLETE, function(event:Event) {
				site.hover("load complete", {timeout: 1000, close: "none"});
			});
			mixer.addEventListener(Mixer.PARSE_ERROR, function(event:Event) {
				site.hover("load error: "+mixer.error, {timeout: 0, close: "top right"});
			});
			mixer.addEventListener(LOAD_ERROR, function(event:Event) {
				site.hover("load error: "+mixer.error, {timeout: 0, close: "top right"});
			});
			mixer.addEventListener(Mixer.REQUEST_LOAD_MIX, function(event:Event) {
				if (userData)
					loadMix();
				else
					ExternalInterface.call('login');
			});
			engine.addEventListener("playbackStart", function(event:Event) {
				trace("playbackStart");
				mixer.setPlaying(true);
				updatePlayhead(event);
			});
			engine.addEventListener("ready", function(event:Event) {
				site.hideHover();
				mixer.introDJ();
				FlashVars.loadMix && loadMix(FlashVars.loadMix);
			});
			engine.addEventListener("playbackStop", function(event:Event) {
				trace("playbackStop");
				mixer.setPlaying(false);
				updatePlayhead(event);
				stopUpdatePlayhead(event);
			});
			engine.addEventListener("playbackPositionChanged", function(event:Event) {
				trace("playbackPositionChanged");
				updatePlayhead(event);
			});
			engine.addEventListener("previewStart", function(event:Event) {
				trace("previewStart");
				mixer.setPreviewPlaying(true, engine.data.url);
			});
			engine.addEventListener("previewStop", function(event:Event) {
				trace("previewStop");
				mixer.setPreviewPlaying(false, engine.data.url);
			});
			
			FlashVars.sampleListUrl && mixer.loadSampleList(FlashVars.sampleListUrl);
		}
		
		private function delayStartUpdatePlayhead(event:Event):void {
			feedbackDelay.removeEventListener(TimerEvent.TIMER, delayStartUpdatePlayhead);
			startUpdatePlayhead(event);
		}
		
		private function startUpdatePlayhead(event:Event):void {
			mixer.addEventListener(Event.ENTER_FRAME, updatePlayhead);
		}
		
		private function stopUpdatePlayhead(event:Event):void {
			mixer.removeEventListener(Event.ENTER_FRAME, updatePlayhead);
		}
		
		private function updatePlayhead(event:Event):void {
			mixer.playbackPosition = engine.call("getPlaybackPosition");
		}

		private function loadMix(id:int = -1):void {
			dispatchEvent(new Event(LOAD_BEGIN, true));
			var loadReq:URLRequest = new URLRequest(WebAppController.flashVars.loadUrl);
			if (id != -1)
				loadReq.data = "id="+id;
			loadLoader.load(loadReq);
		}

		private function saveMix():void {
			dispatchEvent(new Event(SAVE_BEGIN, true));
			
			mixer.encodeMix();
			
			var saveReq:URLRequest = new URLRequest(WebAppController.flashVars.saveUrl);
			saveReq.data = "mix="+encodeURIComponent(JSON.encode(encodedMix));
			if (mixer.mixData.hasOwnProperty("id"))
				saveReq.data += "&id="+mixer.mixData.id;
			if (mixer.mixData.hasOwnProperty("title"))
				saveReq.data += "&title="+mixer.mixData.title;
			if (mixer.mixData.hasOwnProperty("tempo"))
				saveReq.data += "&tempo="+mixer.mixData.tempo;
			if (mixer.mixData.hasOwnProperty("key"))
				saveReq.data += "&key="+mixer.mixData.key;
			saveReq.method = URLRequestMethod.POST;
			saveLoader.load(saveReq);
		}
		
		private function saveCompleteListener(event:Event):void {
			var data:Object = JSON.decode(saveLoader.data);
			if (data) {
				if (data.hasOwnProperty("error")) {
					_error = data.error;
					dispatchEvent(new Event(SAVE_ERROR, true));
					return;
				}
				mixer.updateMixData(data);
			}
			dispatchEvent(new Event(SAVE_COMPLETE, true));
		}
		
		private function loadCompleteListener(event:Event):void {
			dispatchEvent(new Event(LOAD_COMPLETE, true));
			var data:Object = JSON.decode(loadLoader.data);
			if (data) {
				if (data.hasOwnProperty("error")) {
					_error = data.error;
					dispatchEvent(new Event(LOAD_ERROR, true));
					return;
				}
				mixer.setMixData(data);
			}
		}

	}

}
