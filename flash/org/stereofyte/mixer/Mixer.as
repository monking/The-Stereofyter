package org.stereofyte.mixer {

  import flash.display.DisplayObject;
  import flash.display.Graphics;
  import flash.display.MovieClip;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.ui.Keyboard;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.geom.Point;
  import flash.geom.Rectangle;
  import com.chrislovejoy.gui.DragAndDrop;

  public class Mixer extends Sprite {
    
    public static const
      BEAT_WIDTH:Number = 11,
      REGION_ADDED:String = "mixer_region_added",
      REGION_MOVED:String = "mixer_region_moved",
      REGION_REMOVED:String = "mixer_region_removed",
      SEEK_START:String = "mixer_seek_start",
      SEEK:String = "mixer_seek",
      SEEK_FINISH:String = "mixer_seek_finish",
      PLAY:String = "mixer_play",
      STOP:String = "mixer_stop",
      MAX_BEATS:int = 240;

    private static const
      TRACKFIELD_X:Number = 9,
      TRACKFIELD_Y:Number = 10;

    private var
      seekbarBounds:Rectangle,
      tracks:Array,
      Regions:Array,
      bins:Array,
      snapGrid:Point,
      trackField:Sprite,
      trackFieldMask:Sprite,
      playhead:MovieClip,
      PlaybackPosition:Number = 0,
      playing:Boolean,
      Width:Number,
      Height:Number,
      trackWidth:Number,
      trackHeight:Number,
      ui:MixerUI,
      bottom:SFMixerBottom,
      tooltip:MixerTooltip,
      LiftedRegionData:Object,
      RemovedRegionData:Object,
      tempo:Number = 90,
      beatsPerRegion:int = 8,
      trackFieldPushed:Boolean = false;

    public function Mixer(width:Number = 500, height:Number = 240, trackCount:Number = 8):void {
      tracks = [];
      Regions = [];
      bins = [];
      Width = width;
      Height = height;
      // width: max + room to display the last cell
      trackWidth = BEAT_WIDTH * (MAX_BEATS+1);
      trackHeight = Height / trackCount;
      snapGrid = new Point(BEAT_WIDTH * beatsPerRegion, trackHeight);
      ui = new MixerUI();
      ui.scaleX = 1.15;
      ui.scaleY = 1.15;
      bottom = new SFMixerBottom();
      tooltip = new MixerTooltip();
      addChild(ui);
      addChild(bottom);
      addChild(tooltip);
      seekbarBounds = new Rectangle(TRACKFIELD_X - ui.seekbar.x, 7, width, 0);
      drawTrackField();
      drawPlayhead();
      attachBehaviors();
      for (var i:Number = 0; i < trackCount; i++) {
        addTrack(new Track(BEAT_WIDTH, trackHeight, MAX_BEATS));
      }
      addEventListener(Event.ADDED_TO_STAGE, function(event) {
        root.addEventListener(Event.RESIZE, resize);
        resize();
      });
      demo();
      updatePlayhead();
    }

    public function addRegion(sample:Sample):Region {
      var region = new Region(
        sample,
        BEAT_WIDTH * beatsPerRegion,
        trackHeight - 1,
        {
          grid:            snapGrid,
          forceSnapOnStop: true,
          coordinateSpace: trackField,
          ghostColor:      0xff0000,
          grabAnywhere:    false
        }
      );
      region.addEventListener(DragAndDrop.DRAG_START, onLiftRegion);
      region.addEventListener(DragAndDrop.DRAG_STOP, onPlaceRegion);
      region.addEventListener(Region.DUPLICATE, onDuplicateRegion);
      region.addEventListener(Region.DELETE, onDeleteRegion);
      region.hideButtons(null, true);
      addChild(region);
      Regions.push(region);
      return region;
    }

    public function resetLiftedRegion(region:Region):void {
      if (LiftedRegionData) {
        tracks[LiftedRegionData.trackIndex].addRegion(region, LiftedRegionData.cellIndex);
        LiftedRegionData = null;
      } else {
        removeRegion(region);
      }
    }

    public function removeRegion(region:Region):void {
      tooltip.visible = false;
      LiftedRegionData = null;
      region.removeEventListener(DragAndDrop.DRAG_START, onLiftRegion);
      region.removeEventListener(DragAndDrop.DRAG_STOP, onPlaceRegion);
      region.removeEventListener(Region.DUPLICATE, onDuplicateRegion);
      region.removeEventListener(Region.DELETE, onDeleteRegion);
      if (region.solo == Region.SOLO_THIS) region.dispatchEvent(new Event(Region.SOLO, true));
      var trackIndex = -1;
      if (region.parent is Track) {
        var track:Track = region.parent as Track;
        trackIndex = track.index;
        track.removeRegion(region);
      }
      for (var i:Number = Regions.length - 1; i >=0; i--) {
        if (region === Regions[i]) {
          Regions.splice(i, 1);
        }
      }
      RemovedRegionData = {regionId:region.id, trackIndex:trackIndex};
      dispatchEvent(new Event(Mixer.REGION_REMOVED, true));
      RemovedRegionData = null;
      region.clear();
    }

    public function getRegionPosition(region:Region):Number {
      if (region && region && region.parent is Track) {
        var track:Track = region.parent as Track;
        return track.getRegionIndex(region);
      } else {
        return playbackPosition;
      }
    }

    public function get regions():Array {
      return Regions;
    }

    public function addSample(sample:Sample) {
      for (var i:int = 0; i < bins.length; i++) {
        if (bins[i].addSample(sample)) break;
      }
    }

    override public function get width():Number {
      return Width;
    }
    
    override public function set width(newWidth:Number):void {
      Width = newWidth;
      resizeTrackField(Width, Height);
    }
    
    override public function get height():Number {
      return Height;
    }
    
    override public function set height(newHeight:Number):void {
      Height = newHeight
      resizeTrackField(Width, Height);
    }

    private function onLiftRegion(event:Event) {
      liftRegion(event.target as Region);
    }

    private function onPlaceRegion(event:Event) {
      placeRegion(event.target as Region);
    }

    private function onDuplicateRegion(event:Event) {
      duplicateRegion(event.target as Region);
    }

    private function onDeleteRegion(event:Event) {
      removeRegion(event.target as Region);
    }

    private function liftRegion(region:Region) {
      LiftedRegionData = null;
      if (this !== region.parent) {
        var regionPosition = globalToLocal(region.localToGlobal(new Point()));
        if (region.parent is Track) {
          var track:Track = region.parent as Track;
          LiftedRegionData = {trackIndex:track.index, cellIndex:track.getRegionIndex(region)}
          track.removeRegion(region);
        }
        addChild(region);
        region.x = regionPosition.x;
        region.y = regionPosition.y;
      }
      region.removeEventListener(Event.ENTER_FRAME, updateRegionstatus);
      region.addEventListener(Event.ENTER_FRAME, updateRegionstatus);
    }

    private function placeRegion(region:Region, useNextOpenSpace:Boolean = false) {
      region.removeEventListener(Event.ENTER_FRAME, updateRegionstatus);
      var targetTrackIndex:Number = getObjectTargetTrackIndex(region);
      var debug = "placeRegion: ";
      if (isNaN(targetTrackIndex)) {
        debug += "not on a valid track: remove";
        removeRegion(region);
      } else {
        var track:Track = tracks[targetTrackIndex] as Track;
        var targetBeatIndex:int = track.getRegionIndex(region);
        var collision:Boolean = false;
        if (track.getRegionAtIndex(targetBeatIndex)) {
          collision = true;
          if (useNextOpenSpace) {
            for (var i:int = targetBeatIndex; i < MAX_BEATS; i+=beatsPerRegion) {
              if (!track.getRegionAtIndex(i)) {
                targetBeatIndex = i;
                collision = false;
                break;
              }
            }
          }
        }
        if (collision) {
          debug += "existing region at this position: reset";
          resetLiftedRegion(region);
        } else if (targetBeatIndex < 0 || targetBeatIndex > MAX_BEATS) {
          debug += "beyond the range of the mix: reset";
          resetLiftedRegion(region);
        } else {
          track.addRegion(region, targetBeatIndex);
          if (Region.STATUS_NULL == region.status) {
            debug += "new region: ADDED";
            region.status = Region.STATUS_LIVE;
            region.dispatchEvent(new Event(Mixer.REGION_ADDED, true));
          } else {
            debug += "existing region: MOVED";
            region.dispatchEvent(new Event(Mixer.REGION_MOVED, true));
          }
        }
      }
      if (trackFieldPushed) {
        dispatchEvent(new Event(Mixer.SEEK_FINISH));
        trackFieldPushed = false;
      }
      LiftedRegionData = null;
      trace(debug);
    }

    private function duplicateRegion(region:Region) {
      var newRegion:Region = addRegion(region.sample);
      var newPosition = globalToLocal(region.parent.localToGlobal(new Point(region.x + region.width, region.y)));
      newRegion.x = newPosition.x;
      newRegion.y = newPosition.y;
      placeRegion(newRegion, true);
      newRegion.setVolume(region.volume);
    }

    private function getObjectTargetTrackIndex(object:DisplayObject):Number {
      /* find track the object is hovering over */
      var targetTrackIndex:Number = NaN;
      var targetCoord:Point = trackField.globalToLocal(object.localToGlobal(new Point()));
      targetTrackIndex = Math.floor((targetCoord.y + trackHeight / 2) / trackHeight);
      if (targetTrackIndex < 0 || targetTrackIndex > tracks.length)
        targetTrackIndex = NaN;
      return targetTrackIndex;
    }

    private function updateRegionstatus(event:Event):void {
      var region:Region = event.currentTarget as Region;

      /*
       * check for dragging out of bounds... and scroll
       */
      var regionTopLeft = region.parent.localToGlobal(new Point(region.x, region.y));
      var regionBottomRight = regionTopLeft.add(new Point(region.width, region.height));
      var bounds = trackField.mask.getRect(stage);
      var scrollModifier = 0.2;
      if (regionBottomRight.y < bounds.y + bounds.height + trackHeight) {
        if (regionTopLeft.x < bounds.x) {
          // scroll left
          pushTrackField(new Point((regionTopLeft.x - bounds.x) * scrollModifier, 0));
        } else if (regionTopLeft.y < bounds.y) {
          // scroll up
          //pushTrackField(new Point(0, (regionTopLeft.y - bounds.y) * scrollModifier));
        } else if (regionBottomRight.x > bounds.x + bounds.width) {
          // scroll right
          pushTrackField(new Point((regionBottomRight.x - (bounds.x + bounds.width)) * scrollModifier, 0));
        } else if (regionBottomRight.y > bounds.y + bounds.height) {
          // scroll down
          //pushTrackField(new Point(0, (regionBottomRight.y - (bounds.y + bounds.height)) * scrollModifier));
        }
      }

      var targetTrackIndex:Number = getObjectTargetTrackIndex(region.snapGhost);
      // check for snapping out of bounds
      if (isNaN(targetTrackIndex)) {
        region.showDeleteMode();
      } else {
        region.showNormalMode();
      }

    }

    private function drawTrackField():void {
      trackField = new Sprite();
      trackField.x = TRACKFIELD_X;
      trackField.y = TRACKFIELD_Y;
      trackFieldMask = new Sprite();
      trackField.mask = trackFieldMask;
      resizeTrackField(width, height);
      ui.addChild(trackField);
      trackField.addChild(trackFieldMask);
      trackField.addEventListener(MouseEvent.MOUSE_WHEEL, function(event) {
        pushTrackField(new Point(event.delta * 20, 0));
      } );
      addEventListener(Event.ADDED_TO_STAGE, function(event) {
        stage.addEventListener(KeyboardEvent.KEY_UP, function(event) {
          switch (event.keyCode) {
            case Keyboard.ENTER:
              PlaybackPosition = 0;
              dispatchEvent(new Event(Mixer.SEEK_FINISH));
              break;
            case Keyboard.SPACE:
              ui.buttonPlay.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
              break;
            case Keyboard.RIGHT:
              PlaybackPosition = Math.min(PlaybackPosition + beatsPerRegion, MAX_BEATS);
              PlaybackPosition -= PlaybackPosition % beatsPerRegion;
              dispatchEvent(new Event(Mixer.SEEK_FINISH));
              break;
            case Keyboard.LEFT:
              PlaybackPosition = Math.max(PlaybackPosition - beatsPerRegion / 2, 0);
              PlaybackPosition -= PlaybackPosition % beatsPerRegion;
              dispatchEvent(new Event(Mixer.SEEK_FINISH));
              break;
            case Keyboard.UP:
              //pushTrackField(new Point(0, -trackHeight));
              break;
            case Keyboard.DOWN:
              //pushTrackField(new Point(0, trackHeight));
              break;
          }
        } );
      } );
    }

    public function scrollTrackField(position:Point):void {
      position = new Point(Math.round(position.x), Math.round(position.y));
      if (position.x < 0) {
        position.x = 0;
      } else if (position.y < 0) {
        position.y = 0;
      } else if (position.x + trackField.mask.width > trackWidth) {
        position.x = trackWidth - trackField.mask.width;
      } else if (position.y + trackField.mask.height > trackHeight * tracks.length) {
        position.x = trackHeight * tracks.length - trackField.mask.height;
      }
      /* for now, no vertical scrolling */ position.y = 0;
      trackField.x = TRACKFIELD_X - position.x;
      trackField.y = TRACKFIELD_Y - position.y;
      trackField.mask.x = position.x;
      trackField.mask.y = position.y;
    }

    public function pushTrackField(delta:Point):void {
      //ignoring y coordinate
      playbackPosition = (trackField.mask.x + delta.x) * MAX_BEATS / (BEAT_WIDTH * MAX_BEATS - Width);
      trackFieldPushed = true;
    }

    public function zoomTrackField(factor:Number):void {
      trackField.scaleX = factor;
      //snapGrid = new Point(BEAT_WIDTH * factor, trackHeight * factor);
    }

    private function resizeTrackField(width:Number, height:Number):void {
      trackFieldMask.graphics.clear();
      trackFieldMask.graphics.beginFill(0x000000, 1);
      trackFieldMask.graphics.drawRect(0, 0, width, height);
      trackFieldMask.graphics.endFill();
    }
    
    private function addTrack(track:Track):void {
      tracks.push(track);
      trackField.addChildAt(track, 0);
      var trackIndex = tracks.length - 1;
      track.index = trackIndex;
      track.y = trackHeight * trackIndex;
      if (tracks.length > 1) {
        var gridLine = new MixerGridLine();
        gridLine.x = TRACKFIELD_X;
        gridLine.y = track.y + TRACKFIELD_Y - 1;
        ui.addChild(gridLine);
      }
    }

    public function getTrack(index:int):Track {
      return tracks[index] as Track;
    }
    
    private function drawPlayhead():void {
      playhead = ui.playhead;
      playhead.mouseEnabled = false;
      playhead.mouseChildren = false;
      /*
      playhead = new Sprite();
      playhead.graphics.lineStyle(0, 0xFF0000, 1);
      playhead.graphics.lineTo(0, trackField.mask.height);
      */
      ui.addChild(playhead);
      ui.addChild(ui.seekbar);
    }

    public function updatePlayhead():void {
      ui.seekbar.handle.x = PlaybackPosition / MAX_BEATS * seekbarBounds.width + seekbarBounds.x;
      ui.seekbar.fill.width = Math.max(0, ui.seekbar.handle.x - ui.seekbar.fill.x);
      playhead.x = ui.seekbar.x + ui.seekbar.handle.x;
      playhead.y = 5;
      scrollTrackField(new Point(PlaybackPosition * BEAT_WIDTH - Width * PlaybackPosition / MAX_BEATS));
    }
    
    private function addBin(bin:Bin):void {
      bins.push(bin);
      bin.addEventListener(Bin.PULL, grabBin);
      addChild(bin);
      bin.y = 200;
      if (bins.length > 2) {
        removeBin(bins[0]);
      }
    }

    public function removeBin(bin:Bin):void {
      for (var i:Number = bins.length - 1; i >= 0; i--) {
        if (bins[i] === bin) {
          bins.splice(i, 1);
          break;
        }
      }
      removeChild(bin);
      bin.removeEventListener(Bin.PULL, grabBin);
    }

    public function setPreviewPlaying(playing:Boolean, url:String):void {
      for (var i:int = 0; i < bins.length; i++) {
        bins[i].setPreviewPlaying(playing, url);
      }
    }

    public function setPlaying(newPlaying:Boolean):void {
      trace("setPlaying: "+newPlaying);
      playing = newPlaying;
    }

    public function get isPlaying():Boolean {
      return playing;
    }

    public function get playbackPosition():Number {
      return PlaybackPosition;
    }

    public function get liftedRegionData():Object {
      return LiftedRegionData;
    }

    public function get removedRegionData():Object {
      return RemovedRegionData;
    }

    public function set playbackPosition(beat:Number):void {
      if (beat < 0) beat = 0;
      if (beat > MAX_BEATS) beat = MAX_BEATS;
      PlaybackPosition = beat;
      updatePlayhead();
    }

    private function grabBin(event:Event) {
      var region = addRegion(event.target.selectedSample);
      region.grab();
    }

    private function attachBehaviors():void {
      /*
       * Playback
       */
      ui.buttonPlay.addEventListener(MouseEvent.CLICK, function(event:MouseEvent) {
        trace(isPlaying);
        isPlaying?
        dispatchEvent(new Event(Mixer.STOP)):
        dispatchEvent(new Event(Mixer.PLAY));
      });
      ui.buttonStop.addEventListener(MouseEvent.CLICK, function(event:MouseEvent) {
        dispatchEvent(new Event(Mixer.STOP));
      });
      ui.seekbar.addEventListener(MouseEvent.MOUSE_DOWN, onStartSeekbarSlide);
      updatePlayhead();
      /*
       * Solo
       */
      addEventListener(Region.SOLO, function(event:Event) {
        var region = event.target as Region;
        region.toggleSolo();
        for (var i:int = 0; i < Regions.length; i++) {
          if (Regions[i] !== region) {
            Regions[i].setSolo(region.solo == Region.SOLO_THIS? Region.SOLO_OTHER: Region.SOLO_NONE);
          }
        }
      });
      addEventListener(Region.BUTTON_OVER, showRegionTooltip);
      addEventListener(Region.BUTTON_OUT, hideTooltip);
    }

    public function showTooltip(message:String) {
      tooltip.visible = true;
      tooltip.label.text = message;
      tooltip.background.width = tooltip.label.textWidth + 12;
      stage.addEventListener(MouseEvent.MOUSE_MOVE, placeTooltip);
      placeTooltip();
    }

    public function hideTooltip(event:Event = null) {
      tooltip.visible = false;
      stage.removeEventListener(MouseEvent.MOUSE_MOVE, placeTooltip);
    }

    private function placeTooltip(event:Event = null) {
      tooltip.x = mouseX - 4;
      tooltip.y = mouseY;
    }

    public function addTooltip(object:DisplayObject, message:String):void {
      object.addEventListener(MouseEvent.MOUSE_OVER, function() { showTooltip(message); });
      object.addEventListener(MouseEvent.MOUSE_OUT, hideTooltip);
    }

    private function showRegionTooltip(event:Event):void {
      var region:Region = event.target as Region;
      showTooltip(region.tooltipMessage);
    }

    private function onStartSeekbarSlide(event:MouseEvent):void {
      stage.addEventListener(MouseEvent.MOUSE_MOVE, onSeekbarSlide);
      stage.addEventListener(MouseEvent.MOUSE_UP, onStopSeekbarSlide);
      ui.seekbar.handle.startDrag(true, seekbarBounds);
      ui.seekbar.handle.x = Math.min(seekbarBounds.x+seekbarBounds.width, Math.max(ui.seekbar.mouseX, seekbarBounds.x));
      dispatchEvent(new Event(Mixer.SEEK_START));
      onSeekbarSlide(event);
    }

    private function onSeekbarSlide(event:MouseEvent):void {
      playbackPosition = (ui.seekbar.handle.x - seekbarBounds.x) / seekbarBounds.width * MAX_BEATS;
      dispatchEvent(new Event(Mixer.SEEK));
    }

    private function onStopSeekbarSlide(event:MouseEvent):void {
      ui.seekbar.handle.stopDrag();
      stage.removeEventListener(MouseEvent.MOUSE_MOVE, onSeekbarSlide);
      stage.removeEventListener(MouseEvent.MOUSE_UP, onStopSeekbarSlide);
      dispatchEvent(new Event(Mixer.SEEK_FINISH));
    }

    private function resize(event:Event = null):void {
      ui.x = Math.floor(stage.stageWidth / 2 - ui.width / 2);
      ui.y = 30;
      bottom.y = stage.stageHeight - 229;
      bottom.x = Math.floor(stage.stageWidth / 2);
      bottom.socialLinks.x = -bottom.x + 10;
      bottom.socialLinks.visible = false;
      bins[0].x = Math.floor(stage.stageWidth / 2 - 200 - bins[0].width);
      bins[0].y = bottom.y + 10;
      bins[1].x = Math.floor(stage.stageWidth / 2 + 200);
      bins[1].y = bins[0].y;
    }

    private function demo():void {
      addBin(new Bin());
      addBin(new Bin());
    }

  }

}
