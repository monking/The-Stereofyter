package org.stereofyte {
  
  import flash.display.DisplayObject;
  import flash.display.Sprite;
  import flash.display.Graphics;
  import flash.display.LoaderInfo;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.*;
  import flash.external.ExternalInterface;
  import flash.utils.Timer;
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
      site:StereofyteSite,
      feedbackDelay:Timer;
    
    public function StereofyteAppController(root:DisplayObject):void {
      super(root);
      _root.stage.frameRate = 60;
      _root.stage.align = StageAlign.TOP_LEFT;
      _root.stage.scaleMode = StageScaleMode.NO_SCALE;
      engine = new MixblendrInterface();
      site = new StereofyteSite();
      _root.stage.addChild(site);
      feedbackDelay = new Timer(34, 1);
      addMixer();
      demo();
    }

    private function addMixer():void {
      mixer = new Mixer(523, 225, 5);
      _root.stage.addChild(mixer);
      mixer.addEventListener(Mixer.REGION_ADDED, function(event:Event) {
        var region:Region = event.target as Region;
        var track:Track = region.parent as Track;
        var sample:Sample = region.sample;
        region.id = engine.call("addRegion", track.index, sample.src, mixer.getRegionPosition(region));
      });
      mixer.addEventListener(Mixer.REGION_MOVED, function(event:Event) {
        var region:Region = event.target as Region;
        var track:Track = region.parent as Track;
        engine.call("moveRegion", region.id, track.index, mixer.getRegionPosition(region));
      });
      mixer.addEventListener(Track.SOLO, function(event:Event) {
        return;
        var track:Track = event.target as Track;
        var tracks:Array = engine.call("toggleSolo", track.index);
        for (var i:int = 0; i < tracks.length; i++) {
          mixer.getTrack(i).solo = tracks[i];
        }
      });
      mixer.addEventListener(Mixer.PLAY, function(event:Event) {
        engine.call("startPlayback");
        startUpdatePlayhead(event);
      });
      mixer.addEventListener(Mixer.STOP, function(event:Event) {
        engine.call("stopPlayback");
        stopUpdatePlayhead(event);
      });
      mixer.addEventListener(Mixer.SEEK_START, stopUpdatePlayhead);
      mixer.addEventListener(Mixer.SEEK_FINISH, function(event:Event) {
        engine.call("setPlaybackPosition", mixer.playbackPosition);
        feedbackDelay.addEventListener(TimerEvent.TIMER, delayStartUpdatePlayhead);
        feedbackDelay.start();
      });
      mixer.addEventListener(Region.VOLUME_CHANGE, function(event:Event) {
        var region:Region = event.target as Region;
        engine.call("setRegionVolume", region.id, region.volume);
      });
      engine.addEventListener("playbackStart", updatePlayhead);
      engine.addEventListener("playbackStop", function(event:Event) {
        updatePlayhead(event);
        stopUpdatePlayhead(event);
      });
      engine.addEventListener("playbackPositionChanged", updatePlayhead);
    }

    private function delayStartUpdatePlayhead(event:Event):void {
      feedbackDelay.removeEventListener(TimerEvent.TIMER, delayStartUpdatePlayhead);
      startUpdatePlayhead(event);
    }

    private function startUpdatePlayhead(event:Event):void {
      mixer.addEventListener(Event.ENTER_FRAME, updatePlayhead);
    }

    private function stopUpdatePlayhead(event:Event):void {
      mixer.removeEventListener(Event.ENTER_FRAME, updatePlayhead);
    }

    private function updatePlayhead(event:Event):void {
      mixer.playbackPosition = engine.call("getPlaybackPosition");
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
