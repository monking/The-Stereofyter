package org.stereofyte.mixer {

  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.events.TimerEvent;
  import flash.display.Graphics;
  import flash.display.Sprite;
  import flash.utils.Timer;
  import org.stereofyte.mixblendr.*;

  public class Bin extends Sprite {
    
    public static const
      PULL:String = "pull",
      PREVIEW_TOGGLE:String = "preview_toggle";

    private static const
      WIDTH:Number      = 118,
      HEIGHT:Number     = 186,
      SAMPLE_UP_FRAME:Number   = 1,
      SAMPLE_DOWN_FRAME:Number = 8;

    private var
      selectedIndex:Number = NaN,
      samples:Array = [],
      sampleHolder:Sprite,
      ui:BinUI,
      tooltipFadeTimer:Timer;

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
      sampleHolder.addChild(element);
      element.addEventListener(MouseEvent.CLICK, pull);
      /* position element relative to total number of samples */
      element.x = 11;
      element.y = 15 * samples.length;
      element.scaleY = 0.7;
      samples.push({element:element, sample:sample});
    }

    public function get selectedSample():Sample {
      if (isNaN(selectedIndex)) return null;
      return samples[selectedIndex].sample;
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
      selectedIndex = getSampleIndex(element);
      element.front.gotoAndPlay(1);
      dispatchEvent(new Event(Bin.PULL, true));
      selectedIndex = NaN;
    }

    private function drawBin():void {
      ui = new BinUI();
      ui.tooltip.visible = false;
      ui.tooltip.mouseChildren = false;
      sampleHolder = new Sprite();
      addChild(ui);
      addChild(sampleHolder);
      addChild(ui.tooltip);
      /*
      graphics.beginFill(0x333333, 1);
      graphics.drawRect(0, 0, WIDTH, HEIGHT);
      graphics.endFill();
      */
    }

    private function scroll(event:MouseEvent):void {
      if (event.target == ui.tooltip) return;
      var firstIndexBelow:int = -1;
      for (var i:Number = 0; i < samples.length; i++) {
        var element = samples[i].element;
        if (element.y <= mouseY) {
          sampleHolder.setChildIndex(element, i);
          if (element.currentFrame > SAMPLE_UP_FRAME && element.currentFrame <= SAMPLE_DOWN_FRAME) {
            element.gotoAndPlay(SAMPLE_DOWN_FRAME);
          }
          selectedIndex = i;
        } else {
          if (firstIndexBelow == -1) firstIndexBelow = i;
          if (i > 0 && element.currentFrame <= SAMPLE_UP_FRAME || element.currentFrame > SAMPLE_DOWN_FRAME) {
            element.gotoAndPlay(SAMPLE_UP_FRAME);
          }
          sampleHolder.setChildIndex(element, samples.length - 1 - i + firstIndexBelow);
        }
      }
      ui.tooltip.visible = true;
      ui.tooltip.y = samples[selectedIndex].element.y + 25;
      ui.tooltip.gotoAndStop(samples[selectedIndex].sample.family);
      ui.tooltip.label.text = samples[selectedIndex].sample.name;
      tooltipFadeTimer.stop();
    }

    private function attachBehaviors():void {
      tooltipFadeTimer = new Timer(1500, 1);
      tooltipFadeTimer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent) {
        ui.tooltip.visible = false;
      });
      ui.tooltip.addEventListener(MouseEvent.CLICK, function(event:MouseEvent) {
        dispatchEvent(new Event(Bin.PREVIEW_TOGGLE, true));
      });
      addEventListener(MouseEvent.MOUSE_MOVE, scroll);
      addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent) {
        tooltipFadeTimer.stop();
        tooltipFadeTimer.start();
      });
    }

  }

}
