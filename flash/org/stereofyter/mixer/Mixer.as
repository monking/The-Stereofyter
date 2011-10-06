package org.stereofyter.mixer {
	
	import com.adobe.serialization.json.JSON;
	import com.adobe.utils.ArrayUtil;
	import com.chrislovejoy.WebAppController;
	import com.chrislovejoy.display.FrameSkipper;
	import com.chrislovejoy.gui.DragAndDrop;
	import com.chrislovejoy.motion.Move;
	import com.chrislovejoy.utils.Debug;
	
	import fl.transitions.TweenEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.sampler.Sample;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	public class Mixer extends Sprite {
		public static const
			BEAT_WIDTH:Number = 11,
			REGION_ADDED:String = "mixer_region_added",
			REGION_MOVED:String = "mixer_region_moved",
			REGION_REMOVED:String = "mixer_region_removed",
			SEEK_START:String = "mixer_seek_start",
			SEEK:String = "mixer_seek",
			SEEK_FINISH:String = "mixer_seek_finish",
			PLAY:String = "mixer_play",
			STOP:String = "mixer_stop",
			REWIND:String = "mixer_rewind",
			SAMPLE_LIST_LOADED:String = "mixer_sample_list_loaded",
			SAVE_BEGIN:String = "mixer_save_begin",
			SAVE_COMPLETE:String = "mixer_save_complete",
			SAVE_ERROR:String = "mixer_save_error",
			LOAD_BEGIN:String = "mixer_load_begin",
			LOAD_COMPLETE:String = "mixer_load_complete",
			LOAD_ERROR:String = "mixer_load_error",
			PARSE_BEGIN:String = "mixer_parse_begin",
			PARSE_COMPLETE:String = "mixer_parse_complete",
			PARSE_ERROR:String = "mixer_parse_error",
			CLEAR_BEGIN:String = "mixer_clear_begin",
			CLEAR_COMPLETE:String = "mixer_clear_complete",
			MAX_BEATS:int = 240,
			MAX_TRACKS:int = 8;
		
		private static const
			TRACKFIELD_X:Number = 9,
			TRACKFIELD_Y:Number = 10,
			ENCODED_KEY_SAMPLE:String = "S",
			ENCODED_KEY_BEAT:String = "b",
			ENCODED_KEY_VOLUME:String = "v",
			ENCODED_KEY_MUTE:String = "m",
			ENCODED_KEY_SOLO:String = "s",
			PARSE_REGION_INTERVAL:int = 0;
		
		private var
			mixData:Object = {},
			PlaybackPosition:Number = 0,
			tracks:Array = [],
			Regions:Array = [],
			bins:Array = [],
			samples:Array = [],
			sampleData:Array = [],
			SampleRoot:String,
			trackWidth:Number,
			trackHeight:Number,
			playhead:MovieClip,
			playing:Boolean = false,
			LiftedRegionData:Object,
			PlacedRegionData:Object,
			RemovedRegionData:Object,
			Tempo:Number = 120,
			beatsPerRegion:int = 8,
			trackFieldPushed:Boolean = false,
			recordThrowMove:Move,
			newTrackDelay:Timer,
			saveLoader:URLLoader,
			loadLoader:URLLoader,
			Volume:Number = 1,
			_error:String = "",
			Width:Number,
			Height:Number,
			gridlines:Array = [],
			seekbarBounds:Rectangle,
			snapGrid:Point,
			trackField:Sprite,
			trackFieldMask:Sprite,
			ui:MixerUI,
			tooltip:MixerTooltip,
			bottom:MixerBottom,
			dj:MovieClip,
			djSide:String,
			saving:Boolean = false,
			loading:Boolean = false,
			parsing:Boolean = false;
		
		public function Mixer(width:Number = 500, height:Number = 240, trackCount:Number = 8):void {
			saveLoader = new URLLoader();
			loadLoader = new URLLoader();
			
			Width = width;
			Height = height;
			ui = new MixerUI();
			ui.scaleX = 1.15;
			ui.scaleY = 1.15;
			bottom = new MixerBottom();
			dj = bottom.dj;
			tooltip = new MixerTooltip();
			addChild(ui);
			addChild(bottom);
			addChild(tooltip);
			addBin(new Bin());
			addBin(new Bin());
			seekbarBounds = new Rectangle(TRACKFIELD_X - ui.seekbar.x, 7, width, 0);
			newTrackDelay = new Timer(1000, 1);
			drawTrackField();
			drawPlayhead();
			
			attachBehaviors();
			
			for (var i:Number = 0; i < trackCount; i++) {
				addTrack();
			}
		}
		
		public function addRegion(sample:Sample):Region {
			var region = new Region(
				sample,
				BEAT_WIDTH * beatsPerRegion,
				trackHeight - 1,
				{
					grid:            snapGrid,
					forceSnapOnStop: true,
					coordinateSpace: trackField,
					ghostColor:	     0xff0000,
					grabAnywhere:    false
				}
			);
			region.addEventListener(DragAndDrop.DRAG_START, onLiftRegion);
			region.addEventListener(DragAndDrop.DRAG_STOP, onPlaceRegion);
			region.addEventListener(Region.DUPLICATE, onDuplicateRegion);
			region.addEventListener(Region.DELETE, onDeleteRegion);
			region.hideButtons(null, true);
			addChild(region);
			addChild(tooltip); //keep tooltip on top
			Regions.push(region);
			return region;
		}
		
		public function resetLiftedRegion(region:Region):void {
			if (LiftedRegionData && LiftedRegionData.hasOwnProperty("trackIndex")) {
				tracks[LiftedRegionData.trackIndex].addRegion(region, LiftedRegionData.beatIndex);
				LiftedRegionData = null;
			} else {
				removeRegion(region);
			}
		}
		
		public function removeRegion(region:Region):void {
			tooltip.visible = false;
			LiftedRegionData = null;
			region.removeEventListener(DragAndDrop.DRAG_START, onLiftRegion);
			region.removeEventListener(DragAndDrop.DRAG_STOP, onPlaceRegion);
			region.removeEventListener(Region.DUPLICATE, onDuplicateRegion);
			region.removeEventListener(Region.DELETE, onDeleteRegion);
			if (region.solo == Region.SOLO_THIS) region.dispatchEvent(new Event(Region.SOLO, true));
			if (tracks[region.trackIndex]) {
				tracks[region.trackIndex].removeRegion(region);
			} else if (region.parent) {
				region.parent.removeChild(region);
			}
			for (var i:Number = Regions.length - 1; i >=0; i--) {
				if (region === Regions[i]) {
					Regions.splice(i, 1);
				}
			}
			RemovedRegionData = {regionIndex:region.regionIndex, trackIndex:region.trackIndex};
			dispatchEvent(new Event(Mixer.REGION_REMOVED, true));
			RemovedRegionData = null;
			region.clear();
		}
		
		public function getRegionPosition(region:Region):Number {
			if (region && region && region.parent is Track) {
				var track:Track = region.parent as Track;
				return track.getRegionBeat(region);
			} else {
				return playbackPosition;
			}
		}
		
		public function addSample(sample:Sample) {
			samples.push(sample);
			for (var i:int = 0; i < bins.length; i++) {
				if (bins[i].addSample(sample)) break;
			}
		}
		
		public function clearMix():void {
			dispatchEvent(new Event(Mixer.CLEAR_BEGIN, true));
			var clearTimer:Timer = new Timer(PARSE_REGION_INTERVAL, 1);
			clearTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent) {
				if (!regions.length) {
					dispatchEvent(new Event(Mixer.CLEAR_COMPLETE, true));
					return;
				}
				regions[0].dispatchEvent(new Event(Region.DELETE, true));
				clearTimer.start();
			});
			clearTimer.start();
		}

		public function saveMix():void {
			saving = true;
			dispatchEvent(new Event(Mixer.SAVE_BEGIN, true));
			//volume range is converted from 0-1 to 0-100
			var encodedMix:Object = {
				properties:{
					name:mixData.name,
					tempo:Tempo,
					key:mixData.key,
					volume:Math.round(Volume * 100)
				},
				samples:[],
				tracks:[]
			};
			for (var trackIndex:int = 0; trackIndex < tracks.length; trackIndex++) {
				var track:Track = tracks[trackIndex];
				if (!track.numRegions) continue;
				var encodedTrack:Array = [];
				for (var beat:String in track.beats) {
					var region:Region = track.beats[beat];
					if (!region) continue;
					var encodedSampleIndex:int = -1;
					for (var i:int = 0; i < encodedMix.samples.length; i++) {
						//get index if sample is already recorded
						if (encodedMix.samples[i] == region.sample.src) encodedSampleIndex = i;
					}
					if (encodedSampleIndex == -1) {
						//record sample
						encodedMix.samples.push(region.sample.src);
						encodedSampleIndex = encodedMix.samples.length - 1;
					}
					var encodedRegion:Object = {};
					encodedRegion[ENCODED_KEY_SAMPLE] = encodedSampleIndex;
					encodedRegion[ENCODED_KEY_BEAT] = new int(beat);
					encodedRegion[ENCODED_KEY_VOLUME] = new int(region.volume * 100);
					encodedRegion[ENCODED_KEY_MUTE] = region.isMuted? 1: 0;
					encodedRegion[ENCODED_KEY_SOLO] = region.solo == Region.SOLO_THIS? 1: 0;
					encodedTrack.push(encodedRegion);
				}
				encodedMix.tracks[trackIndex] = encodedTrack;
			}
			
			var saveReq:URLRequest = new URLRequest(WebAppController.flashVars.saveUrl);
			saveReq.data = "data="+encodeURIComponent(JSON.encode(encodedMix));
			if (mixData.hasOwnProperty("id"))
				saveReq.data += "&id="+mixData.id;
			saveReq.method = URLRequestMethod.POST;
			saveLoader.load(saveReq);
		}
		
		public function loadMix(id:int):void {
			loading = false;
			dispatchEvent(new Event(Mixer.LOAD_BEGIN, true));
			var loadReq:URLRequest = new URLRequest(WebAppController.flashVars.loadUrl);
			loadReq.data = "id="+id;
			loadLoader.load(loadReq);
		}
		
		public function togglePause():Boolean {
			isPlaying?
				dispatchEvent(new Event(Mixer.STOP)):
				dispatchEvent(new Event(Mixer.PLAY));
			return isPlaying;
		}
		
		public function scrollTrackField(position:Point):void {
			position = new Point(Math.round(position.x), Math.round(position.y));
			if (position.x < 0) {
				position.x = 0;
			} else if (position.y < 0) {
				position.y = 0;
			} else if (position.x + trackField.mask.width > trackWidth) {
				position.x = trackWidth - trackField.mask.width;
			} else if (position.y + trackField.mask.height > trackHeight * tracks.length) {
				position.x = trackHeight * tracks.length - trackField.mask.height;
			}
			/* for now, no vertical scrolling */ position.y = 0;
			trackField.x = TRACKFIELD_X - position.x;
			trackField.y = TRACKFIELD_Y - position.y;
			trackField.mask.x = position.x;
			trackField.mask.y = position.y;
		}
		
		public function pushTrackField(delta:Point):void {
			//ignoring y coordinate
			playbackPosition = (trackField.mask.x + delta.x) * MAX_BEATS / (BEAT_WIDTH * MAX_BEATS - Width);
			trackFieldPushed = true;
		}
		
		public function zoomTrackField(factor:Number):void {
			trackField.scaleX = factor;
			//snapGrid = new Point(BEAT_WIDTH * factor, trackHeight * factor);
		}
		
		public function getTrack(index:int):Track {
			return tracks[index] as Track;
		}
		
		public function updatePlayhead():void {
			ui.seekbar.handle.x = PlaybackPosition / MAX_BEATS * seekbarBounds.width + seekbarBounds.x;
			ui.seekbar.fill.width = Math.max(0, ui.seekbar.handle.x - ui.seekbar.fill.x);
			playhead.x = ui.seekbar.x + ui.seekbar.handle.x;
			playhead.y = 5;
			scrollTrackField(new Point(PlaybackPosition * BEAT_WIDTH - Width * PlaybackPosition / MAX_BEATS));
		}
		
		public function removeBin(bin:Bin):void {
			for (var i:Number = bins.length - 1; i >= 0; i--) {
				if (bins[i] === bin) {
					bins.splice(i, 1);
					break;
				}
			}
			removeChild(bin);
			bin.removeEventListener(Bin.PULL, grabBin);
		}
		
		public function setPreviewPlaying(playing:Boolean, url:String):void {
			for (var i:int = 0; i < bins.length; i++) {
				bins[i].setPreviewPlaying(playing, url);
			}
		}
		
		public function setPlaying(newPlaying:Boolean):void {
			if (newPlaying == playing) return;
			playing = newPlaying;
			if (playing) {
				ui.buttonPlay.gotoAndStop("playing");
				dj.gotoAndPlay("playing");
			} else {
				ui.buttonPlay.gotoAndStop("paused");
				dj.gotoAndStop("paused");
			}
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
		
		public function showTooltip(message:String) {
			tooltip.visible = true;
			tooltip.label.text = message;
			tooltip.background.width = tooltip.label.textWidth + 12;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, placeTooltip);
			placeTooltip();
		}
		
		public function addTooltip(object:DisplayObject, message:String):void {
			object.addEventListener(MouseEvent.MOUSE_OVER, function() { showTooltip(message); });
			object.addEventListener(MouseEvent.MOUSE_OUT, hideTooltip);
		}
		
		public function hideTooltip(event:Event = null) {
			tooltip.visible = false;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, placeTooltip);
		}
		
		public function introDJ():void {
			bottom.gotoAndPlay("introDJ");
		}
		
		public function get mixId():String {
			if (mixData && mixData.hasOwnProperty("id"))
				return mixData.id
			else
				return "";
		}
		
		public function get error():String {
			return _error;
		}
		
		public function get sampleRoot():String {
			return SampleRoot;
		}
		
		public function get regions():Array {
			return Regions;
		}
		
		public function get isPlaying():Boolean {
			return playing;
		}
		
		public function get playbackPosition():Number {
			return PlaybackPosition;
		}
		
		public function get liftedRegionData():Object {
			return LiftedRegionData;
		}
		
		public function get removedRegionData():Object {
			return RemovedRegionData;
		}
		
		public function set playbackPosition(beat:Number):void {
			if (beat < 0) beat = 0;
			if (beat > MAX_BEATS) beat = MAX_BEATS;
			PlaybackPosition = beat;
			updatePlayhead();
		}
		
		override public function get width():Number {
			return Width;
		}
		
		override public function set width(newWidth:Number):void {}
		
		override public function get height():Number {
			return Height;
		}
		
		override public function set height(newHeight:Number):void {}
		
		private function parseMix():void {
			parsing = true;
			dispatchEvent(new Event(Mixer.PARSE_BEGIN, true));
			if (!mixData.data || !mixData.data.tracks || !mixData.data.samples) {
				_error = "the loaded mix is incompatible";
				dispatchEvent(new Event(Mixer.PARSE_ERROR, true));
				return;
			}
			//make successive actions asynchonous, to avoid unresponsiveness
			var parseTrackPointer:int = 0;
			var parseRegionPointer:int = 0;
			var indexedSamples:Array = [];
			for (var i:int = 0; i < mixData.data.samples.length; i++) {
				var sampleFound:Boolean = false;
				for each (var sample:Sample in samples) {
					if (sample.src == mixData.data.samples[i]) {
						indexedSamples[i] = sample;
						sampleFound = true;
					}
				}
				if (!sampleFound) {
					//not found, try for partial matches
					for each (var sample:Sample in samples) {
						if (mixData.data.samples[i].indexOf(sample.src) > -1) {
							indexedSamples[i] = sample;
							sampleFound = true;
						}
					}
					if (!sampleFound) {
						_error = "loop '"+mixData.data.samples[i]+"' not found";
						dispatchEvent(new Event(Mixer.PARSE_ERROR, true));
						return;
					}
				}
			}
			var soloRegion:Region = null;
			var parseTimer:Timer = new Timer(PARSE_REGION_INTERVAL, 1);
			parseTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent) {
				if (parseTrackPointer < mixData.data.tracks.length && (!mixData.data.tracks[parseTrackPointer] || !mixData.data.tracks[parseTrackPointer][parseRegionPointer])) {
					parseRegionPointer = 0;
					parseTrackPointer++;
					parseTimer.start();
					return;
				}
				if (parseTrackPointer >= mixData.data.tracks.length) {
					parseTrackPointer--;
					//TODO: set the defined soloRegion to solo
					//if (soloRegion) soloRegion.setSolo(Region.SOLO_THIS);
					parsing = false;
					dispatchEvent(new Event(Mixer.PARSE_COMPLETE, true));
					return;
				}
				var regionData = mixData.data.tracks[parseTrackPointer][parseRegionPointer];
				dispatchEvent(new Event(Mixer.PARSE_BEGIN, true));
				if (typeof regionData[ENCODED_KEY_SAMPLE] == undefined || typeof regionData[ENCODED_KEY_BEAT] == undefined) {
					_error = "the loaded mix is incompatible";
					dispatchEvent(new Event(Mixer.PARSE_ERROR, true));
					return;
				}
				var region = addRegion(indexedSamples[regionData[ENCODED_KEY_SAMPLE]]);
				tracks[parseTrackPointer].addRegion(region, regionData[ENCODED_KEY_BEAT]);
				region.status = Region.STATUS_LIVE;
				region.dispatchEvent(new Event(Mixer.REGION_ADDED, true));
				region.setVolume(regionData[ENCODED_KEY_VOLUME] / 100);
				region.setMuted(!!regionData[ENCODED_KEY_MUTE]);
				if (regionData[ENCODED_KEY_SOLO]) soloRegion = region;
				parseRegionPointer++
				parseTimer.start();
			});
			parseTimer.start();
		}
		
		private function onLiftRegion(event:Event):void {
			var region:Region = event.target as Region;
			if (Region.STATUS_NULL == region.status) {
				if (dj.mouseX < 0) {
					djSide = "Left";
				} else {
					djSide = "Right";
				}
				dj.gotoAndPlay("grab" + djSide);
			}
			liftRegion(region);
		}
		
		private function onPlaceRegion(event:Event):void {
			var region:Region = event.target as Region;
			var throwing:Boolean = Region.STATUS_NULL == region.status;
			placeRegion(region);
			if (throwing) {
				dj.gotoAndPlay((region.parent? "throw": "drop") + djSide);
				region.visible = false; //prep for appearance animation
			}
		}
		
		private function onDuplicateRegion(event:Event):void {
			duplicateRegion(event.target as Region);
		}
		
		private function onDeleteRegion(event:Event):void {
			stage.focus = stage; // don't trap the focus in the removed object
			removeRegion(event.target as Region);
		}
		
		private function liftRegion(region:Region):void {
			LiftedRegionData = {region:region};
			if (this !== region.parent) {
				var regionPosition = globalToLocal(region.localToGlobal(new Point()));
				if (region.parent is Track) {
					var track:Track = region.parent as Track;
					LiftedRegionData.trackIndex = track.index;
					LiftedRegionData.regionIndex = region.regionIndex;
					LiftedRegionData.beatIndex = track.getRegionBeat(region);
					track.removeRegion(region);
				}
				addChild(region);
				region.x = regionPosition.x;
				region.y = regionPosition.y;
			}
			region.removeEventListener(Event.ENTER_FRAME, updateRegionStatus);
			region.addEventListener(Event.ENTER_FRAME, updateRegionStatus);
		}
		
		private function placeRegion(region:Region, useNextOpenSpace:Boolean = false):void {
			region.removeEventListener(Event.ENTER_FRAME, updateRegionStatus);
			var targetTrackIndex:Number = getObjectTargetTrackIndex(region);
			var debug = "placeRegion: ";
			if (isNaN(targetTrackIndex)) {
				debug += "not on a valid track: remove";
				removeRegion(region);
			} else {
				var track:Track = tracks[targetTrackIndex] as Track;
				var targetBeatIndex:int = track.getRegionPositionBeat(region);
				var collision:Boolean = false;
				if (!!track.getRegionAtBeat(targetBeatIndex)) {
					collision = true;
					if (useNextOpenSpace) {
						for (var i:int = targetBeatIndex; i < MAX_BEATS; i+=beatsPerRegion) {
							if (!track.getRegionAtBeat(i)) {
								targetBeatIndex = i;
								collision = false;
								break;
							}
						}
					}
				}
				if (collision) {
					debug += "existing region at this position: reset";
					resetLiftedRegion(region);
				} else if (targetBeatIndex < 0 || targetBeatIndex > MAX_BEATS) {
					debug += "beyond the range of the mix: reset";
					resetLiftedRegion(region);
				} else {
					PlacedRegionData = {region:region};
					tracks[region.trackIndex] && tracks[region.trackIndex].removeRegion(region);
					var debugOldRegionIndex:int = region.regionIndex;
					track.addRegion(region, targetBeatIndex);
					if (Region.STATUS_NULL == region.status) {
						debug += "new region: ADDED";
						region.status = Region.STATUS_LIVE;
						region.dispatchEvent(new Event(Mixer.REGION_ADDED, true));
					} else {
						debug += "existing region: MOVED";
						region.dispatchEvent(new Event(Mixer.REGION_MOVED, true));
					}
					debug += " (from index " + debugOldRegionIndex + " to " + region.regionIndex + ")";
				}
			}
import flash.events.Event;
			
			if (trackFieldPushed) {
				dispatchEvent(new Event(Mixer.SEEK_FINISH));
				trackFieldPushed = false;
			}
			LiftedRegionData = null;
			//Debug.log(debug);
		}
		
		private function duplicateRegion(region:Region):void {
			var newRegion:Region = addRegion(region.sample);
			var newPosition = globalToLocal(region.parent.localToGlobal(new Point(region.x + region.width, region.y)));
			newRegion.x = newPosition.x;
			newRegion.y = newPosition.y;
			placeRegion(newRegion, true);
			newRegion.setVolume(region.volume);
			startRegionAppear();
		}
		
		private function getObjectTargetTrackIndex(object:DisplayObject):Number {
			/* find track the object is hovering over */
			var targetTrackIndex:Number = NaN;
			var targetCoord:Point = trackField.globalToLocal(object.localToGlobal(new Point()));
			targetTrackIndex = Math.floor((targetCoord.y + trackHeight / 2) / trackHeight);
			if (targetTrackIndex < 0 || targetTrackIndex > tracks.length)
				targetTrackIndex = NaN;
			return targetTrackIndex;
		}
		
		private function updateRegionStatus(event:Event):void {
			var region:Region = event.currentTarget as Region;
			
			/*
			* check for dragging out of bounds... and scroll
			*/
			var regionTopLeft = region.parent.localToGlobal(new Point(region.x, region.y));
			var regionBottomRight = regionTopLeft.add(new Point(region.width, region.height));
			var bounds = trackField.mask.getRect(stage);
			var scrollModifier = 0.2;
			if (regionBottomRight.y < bounds.y + bounds.height + trackHeight) {
				if (regionTopLeft.x < bounds.x) {
					// scroll left
					pushTrackField(new Point((regionTopLeft.x - bounds.x) * scrollModifier, 0));
				} else if (regionBottomRight.x > bounds.x + bounds.width) {
					// scroll right
					pushTrackField(new Point((regionBottomRight.x - (bounds.x + bounds.width)) * scrollModifier, 0));
				}
				if (regionTopLeft.y < bounds.y && regionBottomRight.y >= bounds.y) {
					// show the top "add Track" shape
					//pushTrackField(new Point(0, (regionTopLeft.y - bounds.y) * scrollModifier));
				} else if (regionBottomRight.y > bounds.y + bounds.height && regionTopLeft.y > bounds.y + bounds.height) {
					// show the bottom "add Track" shape
					//startAddTrackDelay();
				} else {
					//stopAddTrackDelay();
				}
			}
			
			var targetTrackIndex:Number = getObjectTargetTrackIndex(region.snapGhost);
			// check for snapping out of bounds
			if (isNaN(targetTrackIndex)) {
				region.showDeleteMode();
			} else {
				region.showNormalMode();
			}
			
		}
		
		private function startAddTrackDelay():void {
			var track:Track = addTrack();
			if (!track) return;
			newTrackDelay.start();
			track.graphics.beginFill(0xff0000);
			track.graphics.drawRect(0, 0, track.width, track.height);
			track.graphics.endFill();
		}
		
		private function finishAddTrackDelay(event:TimerEvent):void {
			tracks[tracks.length - 1].graphics.clear();
		}
		
		private function stopAddTrackDelay():void {
			newTrackDelay.stop();
			removeTrack();
		}
		
		private function drawTrackField():void {
			trackField = new Sprite();
			trackField.x = TRACKFIELD_X;
			trackField.y = TRACKFIELD_Y;
			trackFieldMask = new Sprite();
			trackField.mask = trackFieldMask;
			resizeTrackField(Width, Height);
			ui.addChild(trackField);
			trackField.addChild(trackFieldMask);
			trackField.addEventListener(MouseEvent.MOUSE_WHEEL, function(event) {
				pushTrackField(new Point(event.delta * 20, 0));
			} );
			addEventListener(Event.ADDED_TO_STAGE, function(event) {
				stage.addEventListener(KeyboardEvent.KEY_UP, function(event) {
					switch (event.keyCode) {
						case Keyboard.HOME:
						case Keyboard.ENTER:
							dispatchEvent(new Event(Mixer.REWIND));
							break;
						case Keyboard.ESCAPE:
							dispatchEvent(new Event(Mixer.STOP));
							dispatchEvent(new Event(Mixer.REWIND));
							break;
						case Keyboard.SPACE:
							togglePause();
							break;
						case Keyboard.RIGHT:
							PlaybackPosition = Math.min(PlaybackPosition + beatsPerRegion, MAX_BEATS);
							PlaybackPosition -= PlaybackPosition % beatsPerRegion;
							dispatchEvent(new Event(Mixer.SEEK_FINISH));
							break;
						case Keyboard.LEFT:
							PlaybackPosition = Math.max(PlaybackPosition - beatsPerRegion / 2, 0);
							PlaybackPosition -= PlaybackPosition % beatsPerRegion;
							dispatchEvent(new Event(Mixer.SEEK_FINISH));
							break;
						case Keyboard.UP:
							//pushTrackField(new Point(0, -trackHeight));
							break;
						case Keyboard.DOWN:
							//pushTrackField(new Point(0, trackHeight));
							break;
					}
				} );
			} );
		}
		
		private function resizeTrackField(width:Number, height:Number):void {
			trackFieldMask.graphics.clear();
			trackFieldMask.graphics.beginFill(0x000000, 1);
			trackFieldMask.graphics.drawRect(0, 0, width, height);
			trackFieldMask.graphics.endFill();
		}
		
		private function addTrack():Track {
			if (tracks.length >= MAX_TRACKS) return null;
			
			var track:Track = new Track(BEAT_WIDTH, MAX_BEATS);
			track.index = tracks.length;
			tracks.push(track);
			trackField.addChildAt(track, 0);
			track.y = trackHeight * track.index;
			var gridline = new MixerGridLine();
			gridlines.push(gridline);
			gridline.x = TRACKFIELD_X;
			gridline.y = TRACKFIELD_Y + track.y;
			ui.addChild(gridline);
			if (tracks.length == 1) gridline.visible = false;
			resize();
			return track;
		}
		
		private function removeTrack(index:int = -1):void {
			if (index == -1) index = tracks.length - 1;
			trackField.removeChild(tracks[index]);
			tracks.splice(index, 1);
		}
		
		private function drawPlayhead():void {
			playhead = ui.playhead;
			playhead.mouseEnabled = false;
			playhead.mouseChildren = false;
			/*
			playhead = new Sprite();
			playhead.graphics.lineStyle(0, 0xFF0000, 1);
			playhead.graphics.lineTo(0, trackField.mask.height);
			*/
			ui.addChild(playhead);
			ui.addChild(ui.seekbar);
		}
		
		private function addBin(bin:Bin):void {
			bins.push(bin);
			bin.addEventListener(Bin.PULL, grabBin);
			bottom.binHolder.addChild(bin);
			bin.y = 20;
			if (bins.length > 2) {
				removeBin(bins[0]);
			}
		}
		
		private function onGrabFromBin(event:Event):void {
			var hand:MovieClip = event.target as MovieClip;
			var record:BinSampleDisc = new BinSampleDisc();
			record.gotoAndStop(LiftedRegionData.region.sample.family);
			hand.holder.numChildren && hand.holder.removeChildAt(0);
			hand.holder.addChild(record);
		}
		
		private function startRegionAppear():void {
			var region:Region = PlacedRegionData.region;
			region.visible = true;
			var regionAnimation:RegionAppearAnimation = new RegionAppearAnimation();
			region.parent.addChild(regionAnimation);
			regionAnimation.x = region.x;
			regionAnimation.y = region.y;
			regionAnimation.holder.addChild(region);
			region.x = 0;
			region.y = 0;
			regionAnimation.addEventListener("REGION_ADDED_ANIM_FINISHED", stopRegionAppear);
		}
		
		private function stopRegionAppear(event:Event):void {
			var region:Region = PlacedRegionData.region;
			var regionAnimation:RegionAppearAnimation = event.target as RegionAppearAnimation;
			regionAnimation.removeEventListener("REGION_ADDED_ANIM_FINISHED", stopRegionAppear);
			region.x = regionAnimation.x;
			region.y = regionAnimation.y;
			regionAnimation.parent.addChild(region);
			regionAnimation.parent.removeChild(regionAnimation);
		}
		
		private function onSampleThrow(event:Event):void {
			var hand:MovieClip = event.target as MovieClip;
			var record:BinSampleDisc = hand.holder.getChildAt(0);
			var recordPos:Point = globalToLocal(hand.localToGlobal(new Point()));
			var region:Region = PlacedRegionData.region;
			/*
			addChild(record);
			record.x = recordPos.x;
			record.y = recordPos.y;
			recordThrowMove = new Move(
			record,
			{
			x:50,
			y:100,
			rotation:720
			//x:region.x + region.width / 2,
			//y:region.y + region.height / 2,
			//yScale:0.1
			},
			0.1,
			"easeOut");
			recordThrowMove.addEventListener(TweenEvent.MOTION_FINISH, function(event:TweenEvent) {
			startRegionAppear();
			removeChild(record);
			});
			recordThrowMove.start();
			*/
			hand.holder.removeChild(record);
			startRegionAppear();
		}
		
		private function onSampleDrop(event:Event):void {
			var hand:MovieClip = event.target as MovieClip;
			hand.holder.numChildren && hand.holder.removeChildAt(0); //remove record
		}
		
		private function grabBin(event:Event):void {
			var region = addRegion(event.target.selectedSample);
			region.grab();
			/* enable click-move-click as well as drag-drop */
			addEventListener(MouseEvent.MOUSE_MOVE, dragFromBin);
			region.mouseUpBuffer = 1;
		}
		
		private function dragFromBin(event:MouseEvent):void {
			removeEventListener(MouseEvent.MOUSE_MOVE, dragFromBin);
			if (LiftedRegionData.region) LiftedRegionData.region.mouseUpBuffer = 0;
		}
		
		private function attachBehaviors():void {
			/* Resize */
			addEventListener(Event.ADDED_TO_STAGE, function(event) {
				root.addEventListener(Event.RESIZE, function(event:Event) {
					resize();
				});
				resize();
			});
			/* Data Events */
			addEventListener(SAMPLE_LIST_LOADED, onSampleListLoad);
			saveLoader.addEventListener(Event.COMPLETE, saveCompleteListener);
			loadLoader.addEventListener(Event.COMPLETE, loadCompleteListener);
			ui.buttonLoadMix.addEventListener(MouseEvent.CLICK, function(event:MouseEvent) {
				var id = ExternalInterface.call('prompt', 'Enter the ID of a mix to load', mixData.hasOwnProperty('id')? mixData.id: '');
				loadMix(id);
			});
			ui.buttonLoadMix.buttonMode = true;
			
			/* Playback */
			ui.buttonPlay.addEventListener(MouseEvent.CLICK, function(event:MouseEvent) {
				togglePause();
			});
			ui.buttonStop.addEventListener(MouseEvent.CLICK, function(event:MouseEvent) {
				dispatchEvent(new Event(Mixer.STOP));
				dispatchEvent(new Event(Mixer.REWIND));
			});
			ui.seekbar.addEventListener(MouseEvent.MOUSE_DOWN, onStartSeekbarSlide);
			updatePlayhead();
			
			/* Solo */
			addEventListener(Region.SOLO, function(event:Event) {
				var region = event.target as Region;
				region.toggleSolo();
				for (var i:int = 0; i < Regions.length; i++) {
					if (Regions[i] !== region) {
						Regions[i].setSolo(region.solo == Region.SOLO_THIS? Region.SOLO_OTHER: Region.SOLO_NONE);
					}
				}
			});
			addEventListener(Region.BUTTON_OVER, showRegionTooltip);
			addEventListener(Region.BUTTON_OUT, hideTooltip);
			
			/*Animation events*/
			addEventListener("DJ_ANIM_GRAB", onGrabFromBin);
			addEventListener("DJ_ANIM_THROW", onSampleThrow);
			addEventListener("DJ_ANIM_DROP", onSampleDrop);
			
			/* Interface events */
			newTrackDelay.addEventListener(TimerEvent.TIMER, finishAddTrackDelay);
		}
		
		private function placeTooltip(event:Event = null) {
			tooltip.x = mouseX - 4;
			tooltip.y = mouseY;
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
		
		private function showRegionTooltip(event:Event):void {
			var region:Region = event.target as Region;
			showTooltip(region.tooltipMessage);
		}
		
		private function onStartSeekbarSlide(event:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onSeekbarSlide);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStopSeekbarSlide);
			ui.seekbar.handle.startDrag(true, seekbarBounds);
			ui.seekbar.handle.x = Math.min(seekbarBounds.x+seekbarBounds.width, Math.max(ui.seekbar.mouseX, seekbarBounds.x));
			dispatchEvent(new Event(Mixer.SEEK_START));
			onSeekbarSlide(event);
		}
		
		private function onSeekbarSlide(event:MouseEvent):void {
			playbackPosition = (ui.seekbar.handle.x - seekbarBounds.x) / seekbarBounds.width * MAX_BEATS;
			dispatchEvent(new Event(Mixer.SEEK));
		}
		
		private function onStopSeekbarSlide(event:MouseEvent):void {
			ui.seekbar.handle.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onSeekbarSlide);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStopSeekbarSlide);
			dispatchEvent(new Event(Mixer.SEEK_FINISH));
		}
		
		private function resize(width:Number = NaN, height:Number = NaN):void {
			if (!isNaN(width)) Width = width;
			if (!isNaN(width)) Height = height;
			if (!stage) return;
			
			resizeTrackField(Width, Height);
			// width: max + room to display the last cell
			trackWidth = BEAT_WIDTH * (MAX_BEATS+1);
			trackHeight = Height / tracks.length;
			snapGrid = new Point(BEAT_WIDTH * beatsPerRegion, trackHeight);
			for (var i in tracks) {
				tracks[i].y = i * trackHeight;
				tracks[i].height = trackHeight;
				gridlines[i].y = TRACKFIELD_Y + tracks[i].y;
			}
			
			ui.x = Math.floor(stage.stageWidth / 2 - ui.width / 2);
			ui.y = 50;
			
			bottom.y = stage.stageHeight - 229;
			bottom.x = Math.floor(stage.stageWidth / 2);
			bottom.socialLinks.x = -bottom.x + 10;
			bottom.socialLinks.visible = false;
			bins[0].x = -160 - bins[0].width;
			bins[0].y = 20;
			bins[1].x = 160;
			bins[1].y = bins[0].y;
		}
		
		private function saveCompleteListener(event:Event):void {
			saving = false;
			var data:Object = JSON.decode(saveLoader.data);
			if (data) {
				if (data.hasOwnProperty("error")) {
					_error = data.error;
					dispatchEvent(new Event(Mixer.SAVE_ERROR, true));
					return;
				}
				if (!mixData) {
					mixData = data;
				} else {
					for (var key:String in data) {
						mixData[key] = data[key];
					}
				}
			}
			dispatchEvent(new Event(Mixer.SAVE_COMPLETE, true));
		}
		
		private function loadCompleteListener(event:Event):void {
			loading = false;
			dispatchEvent(new Event(Mixer.LOAD_COMPLETE, true));
			var data:Object = JSON.decode(loadLoader.data);
			if (data) {
				if (data.hasOwnProperty("error")) {
					_error = data.error;
					dispatchEvent(new Event(Mixer.LOAD_ERROR, true));
					return;
				}
				mixData = data;
				addEventListener(Mixer.CLEAR_COMPLETE, parseOnClear);
				clearMix();
			}
		}
		
		private function parseOnClear(event:Event):void {
			removeEventListener(Mixer.CLEAR_COMPLETE, parseOnClear);
			parseMix();
		}
		
	}
	
}
