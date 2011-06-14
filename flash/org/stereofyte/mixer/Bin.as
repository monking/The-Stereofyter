package org.stereofyte.mixer {

  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.display.Graphics;
  import flash.display.Sprite;
  import org.stereofyte.mixblendr.*;

  public class Bin extends Sprite {
    
    public static const
      PULL:String = "pull";

    private var
      focusedIndex:Number = NaN,
      items:Array = [];

    public function Bin():void {
      /*
       * Bin contains symbols of records
       * mousing over flips through the records
       * dragging from a record produces a new instance
       * of org.stereofyte.mixer.Cell
       */
      drawBin();
    }

    public function addItem(itemData:Object):void {
      var element = new Sprite();
      var icon = new InstrumentIcon();
      icon.gotoAndStop(itemData.family);
      element.addChild(icon);
      addChild(element);
      element.addEventListener(MouseEvent.MOUSE_DOWN, focusItem);
      /* position element relative to total number of items */
      element.y = 30 * items.length;
      items.push({element:element, data:itemData});
    }

    public function get pulledItemData():Object {
      if (isNaN(focusedIndex)) return null;
      return items[focusedIndex].data;
    }

    private function scroll(event:MouseEvent) {
    }

    private function focusItem(event:MouseEvent):void {
      /* find the index of the item being clicked */
      for (var i:Number = 0; i < items.length; i++) {
        if (items[i].element === event.currentTarget as Sprite) {
          focusedIndex = i;
          root.stage.addEventListener(MouseEvent.MOUSE_MOVE, pull);
          root.stage.addEventListener(MouseEvent.MOUSE_UP, drop);
          break;
        }
      }
    }

    private function pull(event:MouseEvent):void {
      if (isNaN(focusedIndex)) return;
      dispatchEvent(new Event(Bin.PULL));
      drop(event);
    }

    private function drop(event:MouseEvent):void {
      root.stage.removeEventListener(MouseEvent.MOUSE_MOVE, pull);
      root.stage.removeEventListener(MouseEvent.MOUSE_UP, drop);
      focusedIndex = NaN;
    }

    private function drawBin():void {
      graphics.beginFill(0x333333, 1);
      graphics.drawRect(0, 0, 100, 200);
      graphics.endFill();
    }

  }

}
