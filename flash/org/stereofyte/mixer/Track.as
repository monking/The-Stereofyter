package org.stereofyte.mixer {

  //import flash.display.Graphics;
  import flash.display.Sprite;
  import flash.events.Event;

  public class Track extends Sprite {
    
		public static const
			MUTE = "mute",
			UNMUTE = "unmute",
			SOLO = "solo";

		protected var
			volume:Number,
			muted:Boolean,
			cells:Array = [];

    public function Track():void {
      /*
			 * Track contains a graphic representation of a track, and can have Cells
			 * added to it.
       */
			 drawHead();
			 drawBackground();
    }

		public function addCell(cell:Cell):void {
			cells.push(cell);
			addChild(cell);
			cell.y = 0;
			/* set cell x and y to match prior global position */
		}

		public function removeCell(cell:Cell):void {
			try { removeChild(cell); } catch(error:Error) {}
			for (var i:Number = cells.length - 1; i >= 0; i--) {
				if (cells[i] === cell) {
					cells.splice(i, 1);
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

		public function solo():void {
			/* Perhaps solo() should not set the muted property of other tracks, but
			 * mute them modally, so that removing the solo reverts them to their
			 * muted value before the solo */
			unmute();
			dispatchEvent(new Event(Track.SOLO));
		}

		public function get isMute():Boolean {
			return muted;
		}

		protected function drawHead():void {
		}

		protected function drawBackground():void {
			graphics.beginFill(0xEEEEEE, 1);
			graphics.drawRect(0, 0, 1000, 40);
			graphics.endFill();
			graphics.lineStyle(0, 0x000000);
			graphics.moveTo(0, 39);
			graphics.lineTo(1000, 39);
		}

  }

}
