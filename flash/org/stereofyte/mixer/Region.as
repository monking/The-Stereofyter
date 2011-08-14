package org.stereofyte.mixer {

  import flash.display.Sprite;
  import com.chrislovejoy.gui.DragAndDrop;
  import org.stereofyte.gui.*;
  import flash.display.Graphics;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.geom.Point;
  import flash.geom.Rectangle;

  public class Region extends DragAndDrop {

    public static const
      STATUS_NULL = "null",
      STATUS_LIVE = "live",
      VOLUME_CHANGE = "volume_change",
      DUPLICATE = "duplicate";

    private static const
      VOLUME_BOUNDS:Rectangle = new Rectangle(48, 30, 16, 0);

    public var
      status:String;

    private var
      _sample:Sample,
      Width:Number,
      Height:Number,
      icon:InstrumentIcon,
      ui:RegionUI,
      deleteSymbol:RegionDeleteSymbol,
      state:String,
      regionData:Object,
      _volume:Number = 1;

    public function Region(sample:Sample, width:Number, height:Number, options:Object):void {
      super(options);
      this.status = Region.STATUS_NULL;
      this._sample = sample;
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
      ui = new RegionUI();
      addChild(ui);
      ui.gotoAndStop(_sample.family);
      ui.buttonBody.addEventListener(MouseEvent.MOUSE_DOWN, startMyDrag);
      drawIcon();
      attachBehaviors();
    }

    public function grab():void {
      x = parent.mouseX - height / 2;
      y = parent.mouseY - height / 2;
      startMyDrag();
    }

    public function setVolume(newVolume:Number):void {
      _volume = newVolume;
      updateVolumeSlider();
    }

    public function showDeleteMode():void {
      if ("delete" == state) return;
      state = "delete";
      addChild(deleteSymbol);
      ui.visible = false;
      icon.alpha = 0.5;
      snapGhost.visible = false;
    }

    public function showNormalMode():void {
      if ("normal" == state) return;
      state = "normal";
      removeChild(deleteSymbol);
      ui.visible = true;
      icon.alpha = 1;
      snapGhost.visible = true;
    }

    public function get volume():Number {
      return _volume;
    }

    public function get sample():Sample {
      return _sample;
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

    private function attachBehaviors():void {
      /*
       * Volume
       */
      ui.volumeHandle.gotoAndStop(_sample.family);
      ui.volumeHandle.button.addEventListener(MouseEvent.MOUSE_DOWN, function(event) {
        ui.volumeHandle.startDrag(false, VOLUME_BOUNDS);
      });
      addEventListener(Event.ADDED_TO_STAGE, function(event) {
        stage.addEventListener(MouseEvent.MOUSE_UP, function(event) {
          ui.volumeHandle.stopDrag();
        });
        stage.addEventListener(Event.MOUSE_LEAVE, function(event) {
          ui.volumeHandle.stopDrag();
        });
      });
      updateVolumeSlider();
      /*
       * Duplicate
       */
      ui.buttonDupe.addEventListener(MouseEvent.CLICK, function(event) {
        dispatchEvent(new Event(DUPLICATE));
      });
      /*
       * Solo
       */
      /*
       * Mute
       */
    }

    private function onVolumeSlide(event:MouseEvent):void {
      _volume = (ui.volumeHandle.x - VOLUME_BOUNDS.x) / VOLUME_BOUNDS.width;
      dispatchEvent(new Event(VOLUME_CHANGE));
    }

    private function updateVolumeSlider():void {
      ui.volumeHandle.x = volume * VOLUME_BOUNDS.width + VOLUME_BOUNDS.x;
    }

    private function drawIcon():void {
      icon = new InstrumentIcon();
      icon.gotoAndStop(_sample.family);
      addChild(icon);
      icon.y = 7;
      icon.x = 4;
      icon.mouseEnabled = false;
      icon.mouseChildren = false;
      deleteSymbol = new RegionDeleteSymbol();
      deleteSymbol.x = icon.x;
      deleteSymbol.y = icon.y;
    }

  }

}
