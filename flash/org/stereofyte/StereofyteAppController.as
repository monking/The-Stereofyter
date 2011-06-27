package org.stereofyte {
  
  import flash.display.DisplayObject;
  import flash.display.Sprite;
  import flash.display.Graphics;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.*;
  import flash.external.ExternalInterface;
  import com.chrislovejoy.WebAppController;
  import org.stereofyte.mixblendr.*;
  import org.stereofyte.mixer.*;
  
  public class StereofyteAppController extends WebAppController {
    
    public static const
      WEBROOT:String = '.';

    private var
      mixer:Mixer,
      engine:MixblendrInterface;
    
    public function StereofyteAppController(root:DisplayObject):void {
      super(root);
      _root.stage.frameRate = 60;
      _root.stage.align = StageAlign.TOP_LEFT;
      _root.stage.scaleMode = StageScaleMode.SHOW_ALL;
      engine = new MixblendrInterface();
      addMixer();
      demo();
    }

    private function addMixer():void {
      mixer = new Mixer();
      _root.stage.addChild(mixer);
      mixer.addEventListener(Mixer.REGION_ADDED, function(event:Event) {
        var region:Region = event.target as Region;
        var track:Track = region.parent as Track;
        var sample:Sample = region.getSample();
        engine.call("addRegion", track.index, sample.src, mixer.getBeat(region));
      });
    }

    private function demo():void {
      /*
       * load an XML or JSON file containing the sample data, to be built by PHP querying a database.
       */
      var SAMPLE_PATH:String = "http://local.stereofyte.org/audio/samples/";
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"African Mist Voice 1.mp3",
        family:Sample.FAMILY_VOCAL
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"African Mist Voice 2.mp3",
        family:Sample.FAMILY_VOCAL
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Backroads Banjo.mp3",
        family:Sample.FAMILY_GUITAR
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Cuban Percussion.mp3",
        family:Sample.FAMILY_DRUM
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Djembe.mp3",
        family:Sample.FAMILY_DRUM
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Electro Transistor Beat.mp3",
        family:Sample.FAMILY_DRUM
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Hip Hop Wakka Guitar.mp3",
        family:Sample.FAMILY_GUITAR
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"House Lazy Beat.mp3",
        family:Sample.FAMILY_DRUM
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Jazz Piano.mp3",
        family:Sample.FAMILY_STRINGS
      }));
    }
    
  }
  
}
