package org.stereofyte.mixer {

  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.display.Graphics;
  import flash.display.Sprite;
  import flash.text.TextField;
  import org.stereofyte.mixblendr.*;

  public class Bin extends Sprite {
    
    public static const
      PULL:String = "pull";

    private var
      focusedIndex:Number = NaN,
      samples:Array = [];

    public function Bin():void {
      /*
       * Bin contains symbols of records
       * mousing over flips through the records
       * dragging from a record produces a new instance
       * of org.stereofyte.mixer.Cell
       */
      drawBin();
    }

    public function addSample(sample:Sample):void {
      var element = new Sprite();
      var icon = new InstrumentIcon();
      icon.gotoAndStop(sample.family);
      var label = new TextField();
      label.text = sample.src;
      label.x = 50;
      element.addChild(icon);
      element.addChild(label);
      addChild(element);
      element.addEventListener(MouseEvent.MOUSE_DOWN, focusSample);
      /* position element relative to total number of samples */
      element.y = 30 * samples.length;
      samples.push({element:element, sample:sample});
    }

    public function get pulledSample():Sample {
      if (isNaN(focusedIndex)) return null;
      return samples[focusedIndex].sample;
    }

    private function scroll(event:MouseEvent) {
    }

    private function focusSample(event:MouseEvent):void {
      /* find the index of the sample being clicked */
      for (var i:Number = 0; i < samples.length; i++) {
        if (samples[i].element === event.currentTarget as Sprite) {
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
