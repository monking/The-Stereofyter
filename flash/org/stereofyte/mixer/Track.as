package org.stereofyte.mixer {

  //import flash.display.Graphics;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.geom.Point;

  public class Track extends Sprite {
    
		public static const
			MUTE = "mute",
			UNMUTE = "unmute",
			SOLO = "solo";

		protected var
			volume:Number,
			muted:Boolean,
			cells:Array = [];

    public function Track(width:Number, height:Number):void {
      /*
			 * Track contains a graphic representation of a track, and can have Cells
			 * added to it.
       */
			 drawHead();
			 drawBackground(width, height);
    }

		public function addCell(cell:Cell):void {
			cells.push(cell);
			var cellPosition:Point = globalToLocal(cell.localToGlobal(new Point()));
			addChild(cell);
			cell.x = cellPosition.x;
			cell.y = cellPosition.y;
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

		protected function drawBackground(width:Number, height:Number):void {
			graphics.beginFill(0xEEEEEE, 1);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
			graphics.lineStyle(0, 0x000000);
			graphics.moveTo(0, height-1);
			graphics.lineTo(1000, height-1);
		}

  }

}
