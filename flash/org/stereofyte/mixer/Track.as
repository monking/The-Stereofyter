package org.stereofyte.mixer {

	//import flash.display.Graphics;
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
			BeatWidth:Number,
			Width:Number,
			Height:Number,
			MaxBeats:int;

		public function Track(beatWidth:Number, maxBeats:int):void {
			/*
			 * Track contains a graphic representation of a track, and can have Regions
			 * added to it.
			 */
			BeatWidth = beatWidth;
			// width: max + room to display the last cell
			Width = beatWidth * (maxBeats+1);
			MaxBeats = maxBeats;
			attachBehaviors();
		}

		public function addRegion(region:Region, beatIndex:int = -1):void {
			if (beatIndex == -1) {
				beatIndex = getRegionIndex(region);
			}
			if (regions[beatIndex]) throw new Error("Cannot add region: position is occupied");
			addChild(region);
			region.x = BeatWidth * beatIndex;
			region.y = 0;
			regions[beatIndex] = region;
		}

		public function removeRegion(region:Region):void {
			try { removeChild(region); } catch(error:Error) {}
			regions[getRegionIndex(region)] = undefined;
		}

		public function getRegionAtIndex(index:int):Region {
			return regions[index];
		}

		public function getRegionIndex(region:Region):int {
			for (var i:int = 0; i < regions.length; i++) {
				if (regions[i] === region) {
					return i;
				}
			}
			var regionPosition:Point = new Point(region.x, region.y);
			if (region.parent && region.parent !== this) {
				regionPosition = globalToLocal(region.parent.localToGlobal(regionPosition));
			}
			return Math.round(regionPosition.x / BeatWidth);
		}

		public function get maxBeats():int {
			return MaxBeats;
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

	}

}
