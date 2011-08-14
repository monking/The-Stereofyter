package org.stereofyte.gui {
  
  import flash.display.DisplayObject;
  import flash.display.Graphics;
  import flash.display.LoaderInfo;
  import flash.display.Sprite;
  import flash.display.Stage;
  import flash.events.Event;
  
  public class StereofyteSite extends Sprite {

    public var
      background:SFBackground,
      nav:SFNavBar,
      navWidth:Number = 1000;
    
    public function StereofyteSite():void {
      background = new SFBackground();
      this.addChild(background);
      nav = new SFNavBar();
      this.addChild(nav);
      addEventListener(Event.ADDED_TO_STAGE, function(event) {
        stage.addEventListener(Event.RESIZE, resize);
        resize();
      });
    }

    public function resize(event:Event = null):void {
      background.width = stage.stageWidth;
      background.height = stage.stageHeight;
      nav.x = stage.stageWidth / 2 - navWidth / 2;
      nav.y = -32;
    }
    
  }
  
}
