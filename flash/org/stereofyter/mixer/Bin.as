package org.stereofyter.mixer {

  import flash.display.Graphics;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.events.TimerEvent;
  import flash.utils.Timer;
  
  import org.stereofyter.mixblendr.*;

  public class Bin extends Sprite {

    public static const
      PULL:String = "pull",
      CAPACITY:int = 9;

    private static const
      WIDTH:Number      = 118,
      HEIGHT:Number     = 186,
      SAMPLE_UP_FRAME:Number   = 1,
      SAMPLE_DOWN_FRAME:Number = 8;

    private var
      selectedIndex:int = -1,
      samples:Array = [],
      sampleHolder:Sprite,
      ui:BinUI,
      tooltip:BinSampleTooltip,
      tooltipFadeTimer:Timer,
      previewPlayingIndex:int;

    public function Bin():void {
      /*
       * Bin contains symbols of records
       * mousing over flips through the records
       * dragging from a record produces a new instance
       * of org.stereofyte.mixer.Region
       */
      drawBin();
      attachBehaviors();
    }

    public function addSample(sample:Sample):Boolean {
      if (isMaxed) return false;
      var element = new BinSampleUI();
      element.front.gotoAndStop(sample.family);
      element.front.sleeve.gotoAndStop(sample.family);
      element.front.discInside.gotoAndStop(sample.family + "_insleeve");
      element.front.discOutside.gotoAndStop(sample.family);
      sampleHolder.addChild(element);
      element.addEventListener(MouseEvent.MOUSE_DOWN, pull);
      /* position element relative to total number of samples */
      element.x = 11;
      element.y = 15 * samples.length;
      element.scaleY = 0.7;
      samples.push({element:element, sample:sample});
      return true;
    }
	
	public function removeSample(sample:Sample):Boolean {
		for (var i:int = samples.length; i >=0; i--) {
			if (samples[i].sample === sample) {
				removeChild(samples[i].element);
				samples.splice(i, 1);
				return true;
			}
		}
		return false;
	}
	
	public function clearSamples():void {
		for (var i:int = 0; i < samples.length; i++) {
			sampleHolder.removeChild(samples[i].element);
		}
		samples = [];
	}

    public function get selectedSample():Sample {
      if (selectedIndex == -1) return null;
      return samples[selectedIndex].sample;
    }

    public function setPreviewPlaying(playing:Boolean, url:String):void {
      if (playing) {
        for (var i:int = 0; i < samples.length; i++) {
          if (samples[i].sample.src == url) {
            previewPlayingIndex = i;
          }
        }
      } else {
        previewPlayingIndex = -1;
      }
      updateTooltip();
    }

    public function get length():int {
      return samples.length;
    }

    public function get isMaxed():Boolean {
      if (length >= CAPACITY) return true;
      return false;
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
      for (var i:int = 0; i < samples.length; i++) {
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
      selectedIndex = -1;
    }

    private function drawBin():void {
      ui = new BinUI();
      sampleHolder = new Sprite();
      tooltip = new BinSampleTooltip();
      tooltip.mouseChildren = false;
      tooltip.buttonMode = true;
      tooltip.x = 33;
      tooltip.visible = false;
      addChild(ui);
      addChild(sampleHolder);
      sampleHolder.addChild(tooltip);
      /*
      graphics.beginFill(0x333333, 1);
      graphics.drawRect(0, 0, WIDTH, HEIGHT);
      graphics.endFill();
      */
    }

    private function scroll(event:MouseEvent):void {
      if (!samples.length || event.target.constructor == BinSampleTooltip) return;
      var firstIndexBelow:int = -1;
      for (var i:int = 0; i < samples.length; i++) {
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
      tooltip.visible = true;
      updateTooltip();
      tooltipFadeTimer.reset();
    }

    private function attachBehaviors():void {
      tooltipFadeTimer = new Timer(1500, 1);
      tooltipFadeTimer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent) {
        tooltip.visible = false;
      });
      tooltip.addEventListener(MouseEvent.CLICK, function(event:MouseEvent) {
        selectedSample.dispatchEvent(new Event(Sample.PREVIEW_TOGGLE, true));
      });
      addEventListener(MouseEvent.MOUSE_MOVE, scroll);
      addEventListener(MouseEvent.MOUSE_OVER, function(event:MouseEvent) {
        tooltipFadeTimer.reset();
      });
      addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent) {
        tooltipFadeTimer.reset();
        tooltipFadeTimer.start();
      });
    }

    private function updateTooltip():void {
      if (selectedIndex == -1) {
        return;
      }
      tooltip.y = samples[selectedIndex].element.y + 25;
      tooltip.gotoAndStop(selectedSample.family);
      tooltip.label.text = selectedSample.title;
      if (previewPlayingIndex == selectedIndex) {
        tooltip.previewButton.gotoAndStop("playing");
      } else {
        tooltip.previewButton.gotoAndStop("paused");
      }
    }

  }

}
