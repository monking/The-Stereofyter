package com.chrislovejoy.display {

  import flash.display.DisplayObject;
  import flash.display.Sprite;
  import flash.display.MovieClip;
  import flash.display.Stage;
  import flash.events.Event;
  import flash.utils.getTimer;

  public class FrameSkipper extends Sprite {

    public static const
      RESOLUTION:uint = 10,
      MAX_STEP:uint = 6,
      NAME:String = "frameSkipper";

    public var
      clips:Object;

    private var
      intervals:Array,
      currentStep:uint;

    public static function getFS(mc:MovieClip):FrameSkipper {
      if (!mc.stage) return null;
      if (!mc.stage.hasOwnProperty(NAME)) return new FrameSkipper(mc.stage);
      return mc.stage[NAME] as FrameSkipper;
    }

    public static function play(mc:MovieClip):void {
      var fs:FrameSkipper = getFS(mc);
      if (!fs) {
        mc.play();
        return;
      }
      mc.stop();
      if (!fs.clips.hasOwnProperty(mc.name)) {
        fs.clips[mc.name] = mc;
      }
    }

    public static function gotoAndPlay(mc:MovieClip, frame:*):void {
      mc.gotoAndStop(frame);
      play(mc);
    }

    public static function stop(mc:MovieClip):void {
      var fs:FrameSkipper = getFS(mc);
      mc.stop();
      if (!fs) {
        return;
      }
      if (fs.clips.hasOwnProperty(mc.name)) {
        delete fs.clips[mc.name];
      }
    }

    public static function gotoAndStop(mc:MovieClip, frame:*):void {
      mc.gotoAndStop(frame);
      stop(mc);
    }

    public function FrameSkipper(stage:Stage):void {
      this.name = NAME;
      stage.addChild(this);
      clips = {};
      addEventListener(Event.ENTER_FRAME, step);
    }

    private function step(event:Event) {
      intervals.push(getTimer());
      if (intervals.length > RESOLUTION) {
        intervals.shift();
      }
      var intervalsSum:Number = 0;
      for each (var interval:Number in intervals) {
        intervalsSum += interval;
      }
      currentStep = Math.round((intervalsSum / intervals.length) / (1000 / stage.frameRate));
      currentStep = Math.max(1, Math.min(MAX_STEP, currentStep));
      for each (var mc:MovieClip in clips) {
        mc.gotoAndStop(mc.currentFrame + currentStep);
      }
    }
    
  }

}
