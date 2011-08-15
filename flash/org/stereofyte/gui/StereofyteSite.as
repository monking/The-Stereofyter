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
      logo:StereofyterLogo,
      navWidth:Number = 1000;
    
    public function StereofyteSite():void {
      background = new SFBackground();
      this.addChild(background);
      nav = new SFNavBar();
      addChild(nav);
      logo = new StereofyterLogo();
      addChild(logo);
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
      logo.x = 20;
      logo.y = 20;
    }
    
  }
  
}
