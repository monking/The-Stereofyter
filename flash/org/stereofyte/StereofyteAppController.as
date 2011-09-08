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
      mixer = new Mixer(523, 225, 8);
      _root.stage.addChild(mixer);
      mixer.addEventListener(Mixer.REGION_ADDED, function(event:Event) {
        var region:Region = event.target as Region;
        var track:Track = region.parent as Track;
        var sample:Sample = region.sample;
        trace("adding at beat "+mixer.getRegionPosition(region));
        region.id = engine.call("addRegion", track.index, sample.src, mixer.getRegionPosition(region));
      });
      mixer.addEventListener(Mixer.REGION_MOVED, function(event:Event) {
        var region:Region = event.target as Region;
        var track:Track = region.parent as Track;
        region.id = engine.call("moveRegion", region.id, mixer.liftedRegionData.trackIndex, track.index, mixer.getRegionPosition(region));
      });
      mixer.addEventListener(Mixer.REGION_REMOVED, function(event:Event) {
        engine.call("removeRegion", mixer.removedRegionData.regionId, mixer.removedRegionData.trackIndex);
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
        trace("SEEK_FINISH");
        engine.call("setPlaybackPosition", mixer.playbackPosition);
        if (mixer.isPlaying) {
          feedbackDelay.addEventListener(TimerEvent.TIMER, delayStartUpdatePlayhead);
          feedbackDelay.start();
        }
      });
      mixer.addEventListener(Region.VOLUME_CHANGE, function(event:Event) {
        var region:Region = event.target as Region;
        engine.call("setRegionVolume", region.id, (region.parent as Track).index, region.volume);
      });
      mixer.addEventListener(Region.MUTE, function(event:Event) {
        var region:Region = event.target as Region;
        engine.call("setRegionMuted", region.id, (region.parent as Track).index, region.isMuted);
      });
      mixer.addEventListener(Region.SOLO, function(event:Event) {
        var region:Region = event.target as Region;
        for (var i:int = 0; i < mixer.regions.length; i++) {
          var otherRegion:Region = mixer.regions[i];
          engine.call("setRegionMuted", otherRegion.id, (otherRegion.parent as Track).index, otherRegion.isMuted || otherRegion.solo == Region.SOLO_OTHER);
        }
      });
      mixer.addEventListener(Bin.PREVIEW_TOGGLE, function(event:Event) {
        engine.call("previewToggle", event.target.selectedSample.src);
      });
      engine.addEventListener("playbackStart", function(event:Event) {
        trace("playbackStart");
        mixer.setPlaying(true);
        updatePlayhead(event);
      });
      engine.addEventListener("playbackStop", function(event:Event) {
        trace("playbackStop");
        mixer.setPlaying(false);
        updatePlayhead(event);
        stopUpdatePlayhead(event);
      });
      engine.addEventListener("playbackPositionChanged", function(event:Event) {
        trace("playbackPositionChanged");
        updatePlayhead(event);
      });
      engine.addEventListener("previewStart", function(event:Event) {
        trace("previewStart");
        mixer.setPreviewPlaying(true, engine.data.url);
      });
      engine.addEventListener("previewStop", function(event:Event) {
        trace("previewStop");
        mixer.setPreviewPlaying(false, engine.data.url);
      });
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
        name:"African Mist Voice 2",
        family:Sample.FAMILY_VOCAL
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Backroads_Banjo.ogg",
        name:"Backroads Banjo",
        family:Sample.FAMILY_GUITAR
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Cuban_Percussion.ogg",
        name:"Cuban Percussion",
        family:Sample.FAMILY_DRUM
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Djembe.ogg",
        name:"Djembe",
        family:Sample.FAMILY_DRUM
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Electro_Transistor_Beat.ogg",
        name:"Electro Transistor Beat",
        family:Sample.FAMILY_DRUM
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Hip_Hop_Wakka_Guitar.ogg",
        name:"Hip Hop Wakka Guitar",
        family:Sample.FAMILY_GUITAR
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"House_Lazy_Beat.ogg",
        name:"House Lazy Beat",
        family:Sample.FAMILY_DRUM
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Jazz_Piano.ogg",
        name:"Jazz Piano",
        family:Sample.FAMILY_STRINGS
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Cuban_Voice.ogg",
        name:"Cuban Voice",
        family:Sample.FAMILY_VOCAL
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Eastern_Gold_Voice.ogg",
        name:"Eastern Gold Voice",
        family:Sample.FAMILY_VOCAL
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Koto.ogg",
        name:"Koto",
        family:Sample.FAMILY_GUITAR
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Sine_Bass.ogg",
        name:"Sine Bass",
        family:Sample.FAMILY_GUITAR
      }));
      mixer.addSample(new Sample({
        src:SAMPLE_PATH+"Tremolo_Organ.ogg",
        name:"Tremolo Organ",
        family:Sample.FAMILY_STRINGS
      }));
    }
    
  }
  
}
