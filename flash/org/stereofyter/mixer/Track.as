package org.stereofyter.mixer {

	//import flash.display.Graphics;
	import com.chrislovejoy.utils.Debug;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	public class Track extends Sprite {

		public static const
			MUTE = "track_mute",
			UNMUTE = "track_unmute",
			NONE = "NONE",
			SOLO = "SOLO",
			OTHER_SOLO = "OTHER_SOLO";

		public var
			index:int;

		private var
			volume:Number = 1,
			Mute:Boolean = false,
			Solo:String = "",
			regions:Array = [],
			Beats:Array = [],
			BeatWidth:Number,
			Width:Number,
			Height:Number,
			Tempo:Number,
			MaxBeats:int;

		public function Track(beatWidth:Number, tempo:Number, maxBeats:int):void {
			/*
			 * Track contains a graphic representation of a track, and can have Regions
			 * added to it.
			 */
			Tempo = tempo;
			BeatWidth = beatWidth;
			// width: max + room to display the last cell
			Width = beatWidth * (maxBeats+1);
			MaxBeats = maxBeats;
			attachBehaviors();
		}

		public function addRegion(region:Region, beatIndex:int = -1):void {
			if (beatIndex == -1) {
				beatIndex = getRegionBeat(region);
			}
			if (Beats[beatIndex] && Beats[beatIndex] !== region) throw new Error("Cannot add region: position is occupied");
			region.trackIndex = this.index;
			addChild(region);
			region.x = BeatWidth * beatIndex;
			region.y = 0;
			Beats[beatIndex] = region;
			regions.push(region);
			updateRegionIndices();
		}

		public function removeRegion(region:Region):void {
			try { removeChild(region); } catch(error:Error) {}
			var regionRemoved:Boolean = false;
			for (var i:int = regions.length -1; i >= 0; i--) {
				if (regions[i] === region) {
					regions.splice(i, 1);
					regionRemoved = true;
				}
			}
			if (!regionRemoved) return;
			Beats[getRegionBeat(region)] = undefined;
			updateRegionIndices();
		}

		public function getRegionAtBeat(index:int):Region {
			return Beats[index];
		}

		public function getRegionAtIndex(index:int):Region {
			for (var i:int = 0; i < regions.length; i++) {
				if (regions[i].regionIndex == index) return regions[i];
			}
			return null;
		}

		public function getRegionBeat(region:Region):int {
			for (var i:int = 0; i < Beats.length; i++) {
				if (Beats[i] === region) {
					return i;
				}
			}
			return getRegionPositionBeat(region);
		}

		public function getRegionPositionBeat(region:Region):int {
			var regionPosition:Point = new Point(region.x, region.y);
			if (region.parent && region.parent !== this) {
				regionPosition = globalToLocal(region.parent.localToGlobal(regionPosition));
			}
			return Math.round(regionPosition.x / BeatWidth);
		}

		public function get maxBeats():int {
			return MaxBeats;
		}
		
		public function get numRegions():int {
			return regions.length;
		}

		public function get solo():String {
			return Solo;
		}

		public function set solo(solo:String):void {
			Solo = solo;
			if (solo == Track.OTHER_SOLO) {
				alpha = 0.5;
			} else {
				alpha = 1;
			}
		}

		public function get mute():Boolean {
			return mute;
		}

		public function set mute(mute:Boolean):void {
			Mute = mute;
			alpha = mute? 0.5: 1;
		}
		
		public function get beats():Array {
			return Beats;
		}
		
		public function getDuration():Number {
			var lastBeatIndex:int = -1;
			for (var i:int = 0; i < Beats.length; i++) {
				if (Beats[i]) {
					lastBeatIndex = i;
				}
			}
			if (lastBeatIndex === -1) return 0;
			return Number(lastBeatIndex) * 60000 / Tempo + Beats[lastBeatIndex].duration;
		}

		override public function get width():Number {
			return Width;
		}

		override public function set width(newWidth:Number):void {
			Width = newWidth;
		}

		override public function get height():Number {
			return Height;
		}

		override public function set height(newHeight:Number):void {
			Height = newHeight;
			for each (var region:Region in regions) {
				region.height = newHeight;
			}
		}

		private function attachBehaviors():void {
			addEventListener(Region.SOLO, function() {
				dispatchEvent(new Event(Track.SOLO, true));
			});
		}

		private function updateRegionIndices():void {
			var index:int = -1;
			for (var i:uint = 0; i < Beats.length; i++) {
				if (Beats[i]) {
					index++;
					Beats[i].regionIndex = index;
				}
			}
		}

	}

}
