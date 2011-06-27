package org.stereofyte.mixer {

  import flash.display.Sprite;
  import com.chrislovejoy.gui.DragAndDrop;
  import org.stereofyte.gui.*;
  import flash.display.Graphics;
  import flash.events.MouseEvent;
  import flash.geom.Point;

  public class Region extends DragAndDrop {

    public static const
      STATUS_NULL = "null",
      STATUS_LIVE = "live";

    public var
      status:String;

    private var
      sample:Sample,
      Width:Number,
      Height:Number,
      icon:InstrumentIcon,
      background:Sprite,
      deleteSymbol:RegionDeleteSymbol,
      state:String,
      regionData:Object;

    public function Region(sample:Sample, width:Number, height:Number, options:Object):void {
      super(options);
      this.status = Region.STATUS_NULL;
      this.sample = sample;
      this.Width = width;
      this.Height = height;
      this.state = "normal",
      /*
       * Region is a drag-and-drop element that snaps to the mixer track grid.
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

    public function getSample():Sample {
      return sample;
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
      icon.gotoAndStop(sample.family);
      addChild(icon);
      icon.y = height / 2 - icon.height / 2;
      icon.x = icon.y;
      deleteSymbol = new RegionDeleteSymbol();
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
