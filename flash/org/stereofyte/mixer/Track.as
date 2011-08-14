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
      Width:Number,
      Height:Number;

    public function Track(width:Number, height:Number):void {
      /*
			 * Track contains a graphic representation of a track, and can have Regions
			 * added to it.
       */
       Width = width;
       Height = height;
			 drawControls();
			 //drawBackground();
    }

		public function addRegion(region:Region):void {
			regions.push(region);
			var regionPosition:Point = globalToLocal(region.localToGlobal(new Point()));
			addChild(region);
			region.x = regionPosition.x;
			region.y = regionPosition.y;
			/* set region x and y to match prior global position */
		}

		public function removeRegion(region:Region):void {
			try { removeChild(region); } catch(error:Error) {}
			for (var i:Number = regions.length - 1; i >= 0; i--) {
				if (regions[i] === region) {
					regions.splice(i, 1);
				}
			}
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
