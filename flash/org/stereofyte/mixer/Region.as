package org.stereofyte.mixer {

  import com.chrislovejoy.gui.DragAndDrop;
  import org.stereofyte.gui.*;
  import flash.display.Graphics;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.filters.ColorMatrixFilter;
  import flash.geom.Point;
  import flash.geom.Rectangle;
  import fl.transitions.Tween;
  import fl.transitions.TweenEvent;
  import fl.transitions.easing.None;

  public class Region extends DragAndDrop {

    public static const
      VOLUME_CHANGE = "region_volume_change",
      MUTE = "region_mute",
      SOLO = "region_solo",
      DELETE = "region_delete",
      DUPLICATE = "region_duplicate",
      SOLO_THIS = "solo",
      SOLO_OTHER = "other",
      SOLO_NONE = "none",
      STATUS_NULL = "region_null",
      STATUS_LIVE = "region_live";

    private static const
      VOLUME_BOUNDS:Rectangle = new Rectangle(48, 30, 16, 0);

    public var
      status:String,
      id:int;

    private var
      _sample:Sample,
      Width:Number,
      Height:Number,
      icon:InstrumentIcon,
      ui:RegionUI,
      deleteSymbol:RegionDeleteSymbol,
      Solo:String,
      Muted:Boolean,
      state:String,
      regionData:Object,
      _volume:Number = 1,
      buttonFade:Tween;

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
      ui.buttons.gotoAndStop(_sample.family);
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

    public function setMuted(muted:Boolean):void {
      Muted = muted;
      updateStyle();
    }

    public function toggleMuted():Boolean {
      if (Solo == SOLO_THIS) return false;
      setMuted(!Muted);
      return true;
    }

    public function setSolo(solo:String):void {
      Solo = solo;
      updateStyle();
    }

    public function toggleSolo():void {
      setSolo(Solo == SOLO_THIS? SOLO_NONE: SOLO_THIS);
    }

    public function showDeleteMode():void {
      if ("delete" == state) return;
      state = "delete";
      addChild(deleteSymbol);
      addChild(icon);
      ui.visible = false;
      //icon.alpha = 0.5;
      snapGhost.visible = false;
    }

    public function showNormalMode():void {
      if ("normal" == state) return;
      state = "normal";
      removeChild(deleteSymbol);
      ui.buttons.addChild(icon);
      ui.visible = true;
      icon.alpha = 1;
      snapGhost.visible = true;
    }

    public function showButtons(event:MouseEvent = null, suddenly:Boolean = false):void {
      if (suddenly) {
        ui.buttons.alpha = 1;
        ui.buttons.visible = true;
      } else {
        fadeButtons(1);
      }
    }

    public function hideButtons(event:MouseEvent = null, suddenly:Boolean = false):void {
      if (suddenly) {
        ui.buttons.alpha = 0;
        ui.buttons.visible = false;
      } else {
        fadeButtons(0);
      }
    }

    override public function clear(event:Event = null):void {
      removeEventListener(MouseEvent.MOUSE_OVER, showButtons);
      removeEventListener(MouseEvent.MOUSE_OUT, hideButtons);
      super.clear();
    }

    public function get volume():Number {
      return _volume;
    }

    public function get isMuted():Boolean {
      return Muted;
    }

    public function get solo():String {
      return Solo;
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
      addEventListener(MouseEvent.MOUSE_OVER, showButtons);
      addEventListener(MouseEvent.MOUSE_OUT, hideButtons);
      /*
       * Instrument Icon button
       */
      ui.buttons.buttonBody.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent) {
        if (isDragging) return;
        function click(event:MouseEvent) {
          stage.removeEventListener(MouseEvent.MOUSE_MOVE, lift);
          event.target.removeEventListener(MouseEvent.MOUSE_UP, click);
          toggleMuted();
          dispatchEvent(new Event(MUTE, true));
        }
        function lift(event:MouseEvent) {
          stage.removeEventListener(MouseEvent.MOUSE_MOVE, lift);
          event.target.removeEventListener(MouseEvent.MOUSE_UP, click);
          startMyDrag(event);
        }
        stage.addEventListener(MouseEvent.MOUSE_MOVE, lift);
        event.target.addEventListener(MouseEvent.MOUSE_UP, click);
      });
      /*
       * Volume
       */
      ui.buttons.volumeHandle.gotoAndStop(_sample.family);
      ui.buttons.volumeHandle.button.addEventListener(MouseEvent.MOUSE_DOWN, onStartVolumeSlide);
      updateVolumeSlider();
      /*
       * Delete
       */
      ui.buttons.buttonDelete.addEventListener(MouseEvent.CLICK, function(event) {
        dispatchEvent(new Event(DELETE));
      });
      /*
       * Duplicate
       */
      ui.buttons.buttonDupe.addEventListener(MouseEvent.CLICK, function(event) {
        dispatchEvent(new Event(DUPLICATE));
      });
      /*
       * Solo
       */
      ui.buttons.buttonSolo.addEventListener(MouseEvent.CLICK, function(event) {
        dispatchEvent(new Event(SOLO, true));
      });
      /*
       * Mute
       */
      ui.buttons.buttonMute.addEventListener(MouseEvent.CLICK, function(event) {
        if (!toggleMuted()) return;
        dispatchEvent(new Event(MUTE, true));
      });
    }

    private function onVolumeSlide(event:MouseEvent):void {
      _volume = (ui.buttons.volumeHandle.x - VOLUME_BOUNDS.x) / VOLUME_BOUNDS.width;
      dispatchEvent(new Event(VOLUME_CHANGE, true));
    }

    private function onStartVolumeSlide(event:MouseEvent):void {
      ui.buttons.volumeHandle.startDrag(false, VOLUME_BOUNDS);
      stage.addEventListener(MouseEvent.MOUSE_MOVE, onVolumeSlide);
      stage.addEventListener(MouseEvent.MOUSE_UP, onStopVolumeSlide);
      stage.addEventListener(Event.MOUSE_LEAVE, onStopVolumeSlide);
    }

    private function onStopVolumeSlide(event:MouseEvent):void {
      ui.buttons.volumeHandle.stopDrag();
      stage.removeEventListener(MouseEvent.MOUSE_MOVE, onVolumeSlide);
      stage.removeEventListener(MouseEvent.MOUSE_UP, onStopVolumeSlide);
      stage.removeEventListener(Event.MOUSE_LEAVE, onStopVolumeSlide);
    }

    private function updateVolumeSlider():void {
      ui.buttons.volumeHandle.x = volume * VOLUME_BOUNDS.width + VOLUME_BOUNDS.x;
    }

    private function fadeButtons(alpha:Number):void {
      if (buttonFade && buttonFade.isPlaying) {
        buttonFade.stop();
        buttonFade.removeEventListener(TweenEvent.MOTION_FINISH, onFadeButtonsFinish);
      }
      if (ui.buttons.alpha == alpha) return;
      ui.buttons.visible = true;
      buttonFade = new Tween(
        ui.buttons,
        "alpha",
        fl.transitions.easing.None.easeNone,
        ui.buttons.alpha,
        alpha,
        5
      );
      buttonFade.addEventListener(TweenEvent.MOTION_FINISH, onFadeButtonsFinish);
      buttonFade.start();
    }

    private function onFadeButtonsFinish(event:TweenEvent):void {
      buttonFade.removeEventListener(TweenEvent.MOTION_FINISH, onFadeButtonsFinish);
      if (!ui.buttons.alpha) ui.buttons.visible = false;
    }

    private function drawIcon():void {
      icon = new InstrumentIcon();
      icon.gotoAndStop(_sample.family);
      ui.buttons.addChild(icon);
      icon.y = 7;
      icon.x = 4;
      icon.mouseEnabled = false;
      icon.mouseChildren = false;
      deleteSymbol = new RegionDeleteSymbol();
      deleteSymbol.x = icon.x;
      deleteSymbol.y = icon.y;
    }

    private function updateStyle():void {
      if (Muted || Solo == SOLO_OTHER) {

        var mat:Array = [ .50,.50,.50,0,0,
                          .50,.50,.50,0,0,
                          .50,.50,.50,0,0,
                          .50,.50,.50,1,0 ];
        var colorMat:ColorMatrixFilter = new ColorMatrixFilter(mat);
        this.filters = [colorMat];
      } else {
        this.filters = [];
      }
    }

  }

}
