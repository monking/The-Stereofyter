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
    
    public static const
      WEBROOT:String = '.';

    public var
      mixer:Mixer,
      engine:MixblendrInterface;
    
    public function StereofyteAppController(root:DisplayObject):void {
      super(root);
      _root.stage.frameRate = 60;
      _root.stage.align = StageAlign.TOP_LEFT;
      _root.stage.scaleMode = StageScaleMode.SHOW_ALL;
      demo();
    }

    public function startJavaLink(targetName:String) {
      engine = new MixblendrInterface();
    }

    private function demo():void {
      mixer = new Mixer();
      _root.stage.addChild(mixer);
      startJavaLink("mbinterface");
      engine.call("test");
    }
    
  }
  
}
