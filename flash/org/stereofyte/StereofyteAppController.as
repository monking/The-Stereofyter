package org.stereofyte {
  
  import flash.display.DisplayObject;
  import flash.display.Sprite;
  import flash.display.Graphics;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.*;
  import com.chrislovejoy.WebAppController;
  import org.stereofyte.mixblendr.*;
  import org.stereofyte.mixer.*;
  
  public class StereofyteAppController extends WebAppController {
    
    public static const WEBROOT:String = '.';

    public var mbinterface;
    
    public function StereofyteAppController(root:DisplayObject):void {
      super(root)
      _root.stage.frameRate = 60
      _root.stage.align = StageAlign.TOP_LEFT
      _root.stage.scaleMode = StageScaleMode.NO_SCALE
      mbinterface = new MixBlendrInterface("mbinterface");
      demo();
    }

    private function demo():void {
      drawBackground();
      var cell = new Cell();
      _root.stage.addChild(cell);
    }

    private function drawBackground():void {
      var controller = this;
      var debug = new Sprite();
      debug.graphics.beginFill(0x999999, 1);
      debug.graphics.drawRect(0, 0, 200, 200);
      debug.graphics.endFill();
      _root.stage.addChild(debug);

      debug.addEventListener(
        MouseEvent.CLICK,
        function(event:MouseEvent) {
          //controller.mbinterface.call("seek", event.localX);
        }
      );
    }
    
  }
  
}
