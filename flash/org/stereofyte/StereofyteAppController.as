package org.stereofyte {
  
  import flash.display.DisplayObject;
  import flash.display.Sprite;
  import flash.display.Graphics;
  import flash.display.LoaderInfo;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.*;
  import flash.external.ExternalInterface;
  import com.chrislovejoy.WebAppController;
  import org.stereofyte.gui.*;
  import org.stereofyte.mixblendr.*;
  import org.stereofyte.mixer.*;
  
  public class StereofyteAppController extends WebAppController {
    
    public static const
      WEBROOT:String = '.';

    private var
      mixer:Mixer,
      engine:MixblendrInterface,
      site:StereofyteSite;
    
    public function StereofyteAppController(root:DisplayObject):void {
      super(root);
      _root.stage.frameRate = 60;
      _root.stage.align = StageAlign.TOP_LEFT;
      _root.stage.scaleMode = StageScaleMode.NO_SCALE;
      engine = new MixblendrInterface();
      site = new StereofyteSite(_root.stage);
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
      logObject(flashVars);
      var SAMPLE_PATH:String = flashVars.samplepath;

      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"African_Mist_Voice_1.ogg",
        name:"African Mist Voice 1",
        family:Sample.FAMILY_VOCAL
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"African_Mist_Voice_2.ogg",
        name:"African_Mist_Voice_2.ogg",
        family:Sample.FAMILY_VOCAL
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Backroads_Banjo.ogg",
        name:"Backroads_Banjo.ogg",
        family:Sample.FAMILY_GUITAR
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Cuban_Percussion.ogg",
        name:"Cuban_Percussion.ogg",
        family:Sample.FAMILY_DRUM
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Djembe.ogg",
        name:"Djembe.ogg",
        family:Sample.FAMILY_DRUM
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Electro_Transistor_Beat.ogg",
        name:"Electro_Transistor_Beat.ogg",
        family:Sample.FAMILY_DRUM
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Hip_Hop_Wakka_Guitar.ogg",
        name:"Hip_Hop_Wakka_Guitar.ogg",
        family:Sample.FAMILY_GUITAR
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"House_Lazy_Beat.ogg",
        name:"House_Lazy_Beat.ogg",
        family:Sample.FAMILY_DRUM
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Jazz_Piano.ogg",
        name:"Jazz_Piano.ogg",
        family:Sample.FAMILY_STRINGS
      }));
    }
    
  }
  
}
