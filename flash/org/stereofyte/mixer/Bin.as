package org.stereofyte.mixer {

  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.display.Graphics;
  import flash.display.Sprite;
  import org.stereofyte.mixblendr.*;

  public class Bin extends Sprite {
    
    public static const
      PULL:String = "pull";

    protected var
      focusedItem:Number = NaN,
      items:Array = [];

    public function Bin():void {
      /*
       * Bin contains symbols of records
       * mousing over flips through the records
       * dragging from a record produces a new instance
       * of org.stereofyte.mixer.Cell
       */
      addEventListener(MouseEvent.MOUSE_DOWN, focusItem);
      addEventListener(MouseEvent.MOUSE_MOVE, pull);
      demo();
    }

    public function get pulledItem():Object {
      return items[focusedItem].data;
    }

    private function scroll(event:MouseEvent) {
    }

    private function addItem(itemData:Object):void {
    }

    private function focusItem(event:MouseEvent):void {
      var item = event.target;
      dispatchEvent(new Event(Bin.PULL));
    }

    private function pull(event:MouseEvent):void {
      if (isNaN(focusedItem)) return;
      dispatchEvent(new Event(Bin.PULL));
    }

    private function demo():void {
      graphics.beginFill(0x333333, 1);
      graphics.drawRect(0, 0, 100, 200);
      graphics.endFill();
    }

  }

}
