package org.stereofyte.mixer {

  import flash.display.Sprite;
  import com.chrislovejoy.gui.DragAndDrop;
  import org.stereofyte.gui.*;
  import flash.display.Graphics;
  import flash.events.MouseEvent;
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
      Width:Number,
      Height:Number,
      src:String,
      family:String,
      icon:InstrumentIcon,
      background:Sprite,
      deleteSymbol:DeleteCellSymbol,
      state:String;

    public function Cell(cellData:Object, width:Number, height:Number, grid:Point, gridOrigin:Point):void {
      super({
        grid:            grid,
        gridOrigin:      gridOrigin,
        forceSnapOnStop: true
      });
      this.src = cellData.src;
      this.family = cellData.family;
      this.Width = width;
      this.Height = height;
      this.state = "normal",
      /*
       * Cell is a drag-and-drop element that snaps to the mixer track grid.
       * contains
       *  volume slider
       *  "solo" button
       *  mute buton
       *  "x" delete button
       *  symbol for sample instrument
       */
      drawIcon();
      drawBackground();
    }

    public function grab():void {
      x = parent.mouseX - height / 2;
      y = parent.mouseY - height / 2;
      startMyDrag();
    }

    public function showDeleteMode():void {
      if ("delete" == state) return;
      state = "delete";
      addChild(deleteSymbol);
      background.visible = false;
      icon.alpha = 0.5;
      snapGhost.visible = false;
    }

    public function showNormalMode():void {
      if ("normal" == state) return;
      state = "normal";
      removeChild(deleteSymbol);
      background.visible = true;
      icon.alpha = 1;
      snapGhost.visible = true;
    }
    
    public function get snapGhost():DragAndDrop {
      return ghost;
    }
    
    override public function get width():Number {
      return Width;
    }
    
    override public function get height():Number {
      return Height;
    }

    private function drawIcon():void {
      icon = new InstrumentIcon();
      icon.gotoAndStop(family);
      addChild(icon);
      icon.y = height / 2 - icon.height / 2;
      icon.x = icon.y;
      deleteSymbol = new DeleteCellSymbol();
      deleteSymbol.x = icon.x;
      deleteSymbol.y = icon.y;
    }

    private function drawBackground():void {
      background = new Sprite();
      addChildAt(background, 0);
      var backgroundColor = icon.iconColor || Math.random() * 0xFFFFFF;
      background.graphics.beginFill(backgroundColor, 1);
      background.graphics.drawRect(0, 0, Width, Height - 1);
      background.graphics.endFill();
    }

  }

}
