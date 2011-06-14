package org.stereofyte {
  
  import flash.display.DisplayObject;
  import flash.display.Sprite;
  import flash.display.Graphics;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.*;
  import com.chrislovejoy.WebAppController;
  import org.stereofyte.mixer.*;
  
  public class StereofyteAppController extends WebAppController {
    
    public static const
      WEBROOT:String = '.';

    public var
      mixer:Mixer;
    
    public function StereofyteAppController(root:DisplayObject):void {
      super(root);
      _root.stage.frameRate = 60;
      _root.stage.align = StageAlign.TOP_LEFT;
      _root.stage.scaleMode = StageScaleMode.EXACT_FIT;
      demo();
    }

    private function demo():void {
      mixer = new Mixer();
      _root.stage.addChild(mixer);
    }
    
  }
  
}
