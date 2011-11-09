package org.stereofyter {

	import com.adobe.serialization.json.JSON;
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
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
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
			engineDelay:Timer,
			feedbackDelay:Timer,
			session:Object = {},
			saveLoader:URLLoader,
			loadLoader:URLLoader;

		public function StereofyterAppController(root:DisplayObject, debug:Boolean = false):void {
			super(root, debug);
			_root.stage.frameRate = 60;
			_root.stage.align = StageAlign.TOP_LEFT;
			_root.stage.quality = StageQuality.HIGH;
			_root.stage.scaleMode = StageScaleMode.NO_SCALE;
			if (flashVars.session)
				session = JSON.decode(flashVars.session);
			engine = new MixblendrInterface();
			site = new StereofyterSite();
			_root.stage.addChild(site);
			feedbackDelay = new Timer(34, 1);
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
			registerExternalMethods();
			addMixer();
			attachSiteListeners();
		}
		
		public function setUserSessionData(data:Object):void {
			session = data;
		}
		
		private function onMixblendrReady(event:Event):void {
			if (engineDelay.running) {
				engineDelay.stop();
			}
			site.hideHover();
			mixer.introDJ();
			FlashVars.loadMix && loadMix(FlashVars.loadMix);
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
				if (session.hasOwnProperty('user')) {
					var mixData = mixer.getMixData();
					site.showSaveDialog(mixData.hasOwnProperty('id')? mixData.id: NaN);
				} else {
					ExternalInterface.call('login');
				}
			});
			site.addEventListener(SaveDialog.SUBMIT_SAVE_MIX, function(event:Event) {
				var dialog:SaveDialog = event.target as SaveDialog;
				dialog.hide();
				var dialogMixData = { title:dialog.mixTitle };
				dialogMixData.id = dialog.mixId;
				mixer.updateMixData(dialogMixData);
				saveMix();
			});
			site.addEventListener(LoadDialog.SUBMIT_LOAD_MIX, function(event:Event) {
				var dialog:LoadDialog = event.target as LoadDialog;
				dialog.hide();
				loadMix(dialog.mixId);
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
			mixer.addEventListener(Mixer.PARSE_ERROR, function(event:Event) {
				site.hover("load error: "+mixer.error, {timeout: 0, close: "top right"});
			});
			mixer.addEventListener(Mixer.REQUEST_LOAD_MIX, function(event:Event) {
				if (session.hasOwnProperty('user'))
					site.showLoadDialog();
				else
					ExternalInterface.call('login');
			});
			engine.addEventListener("playbackStart", function(event:Event) {
				trace("playbackStart");
				mixer.setPlaying(true);
				updatePlayhead(event);
			});
			engine.ready? onMixblendrReady: engine.addEventListener("ready", onMixblendrReady);
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
			engineDelay = new Timer(500);
			engineDelay.addEventListener(TimerEvent.TIMER, function(event:TimerEvent) {
				engine.check();
			});
			engineDelay.start();
			
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
			site.hover("loading", {progress: true, timeout: 0, close: "none"});
			var loadReq:URLRequest = new URLRequest(WebAppController.flashVars.loadUrl);
			if (id != -1)
				loadReq.data = "id="+id;
			loadLoader.load(loadReq);
		}

		private function saveMix():void {
			site.hover("saving", {progress: true, timeout: 0, close: "none"});
			
			mixer.encodeMix();
			var mixData = mixer.getMixData();
			Debug.deepLog(mixData, "mixData before save");
			
			var saveReq:URLRequest = new URLRequest(WebAppController.flashVars.saveUrl);
			saveReq.data = "mix="+encodeURIComponent(JSON.encode(mixData.mix));
			if (mixData.hasOwnProperty("id") && !isNaN(mixData.id))
				saveReq.data += "&id="+mixData.id;
			if (mixData.hasOwnProperty("title"))
				saveReq.data += "&title="+mixData.title;
			if (mixData.hasOwnProperty("key"))
				saveReq.data += "&key="+mixData.key;
			saveReq.data += "&tempo="+mixData.tempo;
			saveReq.data += "&duration="+mixer.getDuration();
			Debug.log(saveReq.data, "saveReq.data");
			saveReq.method = URLRequestMethod.POST;
			saveLoader.load(saveReq);
		}
		
		private function saveCompleteListener(event:Event):void {
			try {
				var data:Object = JSON.decode(saveLoader.data);
			} catch (e:Error) {
				Debug.log(e);
				var msg = "Sorry, your mix could not be saved.\nIf the problem is persistent, please contact support.";
				site.hover(msg, {timeout: 1000, close: "none"});
				return;
			}
			Debug.deepLog(data, "save complete");
			if (data) {
				if (data.hasOwnProperty("error")) {
					site.hover("save error: "+data.error, {timeout: 0, close: "top right"});
					return;
				}
				mixer.updateMixData(data);
			}
			site.hover("save complete", {timeout: 1000, close: "none"});
		}
		
		private function loadCompleteListener(event:Event):void {
			try {
				var data:Object = JSON.decode(loadLoader.data);
			} catch (e:Error) {
				Debug.log(e);
				var msg = "Sorry, the loaded mix data is corrupted.\nPlease try again later.";
				site.hover(msg, {timeout: 1000, close: "none"});
				return;
			}
			if (data) {
				if (data.hasOwnProperty("error")) {
					site.hover("load error: "+data.error, {timeout: 0, close: "top right"});
					return;
				}
				mixer.setMixData(data);
			}
			site.hover("load complete", {timeout: 1000, close: "none"});
		}

	}

}
