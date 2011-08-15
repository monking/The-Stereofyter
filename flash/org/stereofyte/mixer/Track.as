package org.stereofyte.mixer {

  //import flash.display.Graphics;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.geom.Point;

  public class Track extends Sprite {
    
		public static const
			MUTE = "mute",
			UNMUTE = "unmute",
			SOLO = "solo",
			UNSOLO = "solo";

    public var
      index:int;

		protected var
			volume:Number = 1,
			muted:Boolean = false,
			solo:Boolean = false,
			regions:Array = [],
      BeatWidth:Number,
      Width:Number,
      Height:Number,
      MaxBeats:int;

    public function Track(beatWidth:Number, height:Number, maxBeats:int):void {
      /*
			 * Track contains a graphic representation of a track, and can have Regions
			 * added to it.
       */
       BeatWidth = beatWidth;
       Width = beatWidth * maxBeats;
       Height = height;
       MaxBeats = maxBeats;
			 drawControls();
			 //drawBackground();
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

		public function mute():void {
			if (muted) return;
			muted = true;
			dispatchEvent(new Event(Track.MUTE));
		}

		public function unmute():void {
			if (!muted) return;
			muted = false;
			dispatchEvent(new Event(Track.UNMUTE));
		}

		public function goSolo():void {
      solo = true;
			dispatchEvent(new Event(Track.SOLO));
		}

		public function unSolo():void {
      solo = false;
			dispatchEvent(new Event(Track.UNSOLO));
		}

    public function excludeFromSolo():void {
      alpha = 0.7;
    }

    public function unexcludeFromSolo():void {
      alpha = 1;
    }

		public function get isMute():Boolean {
			return muted;
		}

    public function get maxBeats():int {
      return MaxBeats;
    }

		override public function get width():Number {
			return Width;
		}

		protected function drawControls():void {
		}

		protected function drawBackground():void {
			graphics.beginFill(0xEEEEEE, 1);
			graphics.drawRect(0, 0, Width, Height);
			graphics.endFill();
			graphics.lineStyle(0, 0x000000);
			graphics.moveTo(0, Height-1);
			graphics.lineTo(1000, Height-1);
		}

  }

}
