package org.stereofyte.mixer {

  import flash.display.Sprite;
  import com.chrislovejoy.gui.DragAndDrop;
  import org.stereofyte.gui.*;
  import org.stereofyte.mixblendr.*;
  import flash.display.Graphics;
  import flash.geom.Point;

  public class Cell extends DragAndDrop {
    
    public function Cell():void {
      super(20, new Point(120, 40), null, null, true);
      /*
       * Cell is a drag-and-drop element that snaps to the mixer track grid.
       * contains
       *  volume slider
       *  "solo" button
       *  mute buton
       *  "x" delete button
       *  symbol for sample instrument
       */
      demo();
    }

    private function demo():void {
      graphics.beginFill(0x666666, 1);
      graphics.drawRect(0, 0, 120, 40);
      graphics.endFill();
    }

  }

}
