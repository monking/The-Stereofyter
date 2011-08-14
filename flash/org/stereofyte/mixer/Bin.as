package org.stereofyte.mixer {

  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.display.Graphics;
  import flash.display.Sprite;
  import org.stereofyte.mixblendr.*;

  public class Bin extends Sprite {
    
    public static const
      PULL:String = "pull";

    private static const
      WIDTH:Number      = 118,
      HEIGHT:Number     = 186,
      SAMPLE_UP_FRAME:Number   = 1,
      SAMPLE_DOWN_FRAME:Number = 8;

    private var
      focusedIndex:Number = NaN,
      samples:Array = [],
      ui:BinUI;

    public function Bin():void {
      /*
       * Bin contains symbols of records
       * mousing over flips through the records
       * dragging from a record produces a new instance
       * of org.stereofyte.mixer.Cell
       */
      drawBin();
      attachBehaviors();
    }

    public function addSample(sample:Sample):void {
      var element = new BinSampleUI();
      element.front.gotoAndStop(sample.family);
      element.front.sleeve.gotoAndStop(sample.family);
      element.front.discInside.gotoAndStop(sample.family + "_insleeve");
      element.front.discOutside.gotoAndStop(sample.family);
      addChild(element);
      element.addEventListener(MouseEvent.CLICK, pull);
      /* position element relative to total number of samples */
      element.x = 11;
      element.y = 15 * samples.length;
      element.scaleY = 0.7;
      samples.push({element:element, sample:sample});
    }

    public function get pulledSample():Sample {
      if (isNaN(focusedIndex)) return null;
      return samples[focusedIndex].sample;
    }

    override public function get width():Number {
      return WIDTH;
    }

    override public function set width(newWidth:Number):void {}

    override public function get height():Number {
      return HEIGHT;
    }

    override public function set height(newHeight:Number):void {}

    private function getSampleIndex(element:BinSampleUI):int {
      /* find the index of the element being clicked */
      for (var i:Number = 0; i < samples.length; i++) {
        if (samples[i].element === element) {
          return i;
        }
      }
      return -1;
    }

    private function pull(event:MouseEvent):void {
      var element = event.currentTarget as BinSampleUI;
      focusedIndex = getSampleIndex(element);
      element.front.gotoAndPlay(1);
      dispatchEvent(new Event(Bin.PULL));
      focusedIndex = NaN;
    }

    private function drawBin():void {
      ui = new BinUI();
      addChild(ui);
      /*
      graphics.beginFill(0x333333, 1);
      graphics.drawRect(0, 0, WIDTH, HEIGHT);
      graphics.endFill();
      */
    }

    private function scroll(event:MouseEvent):void {
      for (var i:Number = 0; i < samples.length; i++) {
        var element = samples[i].element;
        if (mouseY < element.y) {
          if (i > 0 && element.currentFrame <= SAMPLE_UP_FRAME || element.currentFrame > SAMPLE_DOWN_FRAME) {
            element.gotoAndPlay(SAMPLE_UP_FRAME);
          }
        } else {
          if (element.currentFrame > SAMPLE_UP_FRAME && element.currentFrame <= SAMPLE_DOWN_FRAME) {
            element.gotoAndPlay(SAMPLE_DOWN_FRAME);
          }
        }
      }
    }

    private function attachBehaviors():void {
      addEventListener(MouseEvent.MOUSE_MOVE, scroll);
    }

  }

}
