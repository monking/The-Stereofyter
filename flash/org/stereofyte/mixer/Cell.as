package org.stereofyte.mixer {

  import flash.display.Sprite;
  import com.chrislovejoy.gui.DragAndDrop;
  import org.stereofyte.gui.*;
  import flash.display.Graphics;
  import flash.geom.Point;

  public class Cell extends DragAndDrop {
    
    public static const
      family:Object = {
        VOCAL:"vocal",
        BRASS:"brass",
        DRUM:"drum",
        GUITAR:"guitar",
        BASS:"bass",
        SYNTH:"synth"
      };

    protected var
      samplePath:String,
      instrumentFamily:String,
      icon:InstrumentIcon;

    public function Cell(cellData:Object):void {
      super(20, new Point(120, 40), null, null, true);
      this.samplePath = cellData.samplePath;
      this.instrumentFamily = cellData.instrumentFamily;
      /*
       * Cell is a drag-and-drop element that snaps to the mixer track grid.
       * contains
       *  volume slider
       *  "solo" button
       *  mute buton
       *  "x" delete button
       *  symbol for sample instrument
       */
      drawBackground();
      drawIcon();
    }

    private function drawIcon():void {
      icon = new InstrumentIcon();
      icon.gotoAndStop(instrumentFamily);
      addChild(icon);
      icon.y = height / 2 - icon.height / 2;
      icon.x = icon.y;
    }

    private function drawBackground():void {
      graphics.beginFill(0x666666, 1);
      graphics.drawRect(0, 0, 120, 40);
      graphics.endFill();
    }

  }

}
