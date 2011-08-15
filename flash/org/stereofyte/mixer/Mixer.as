package org.stereofyte.mixer {

  import flash.display.DisplayObject;
  import flash.display.Graphics;
  import flash.display.MovieClip;
  import flash.display.Sprite;
  import flash.events.Event;
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
      MAX_BEATS:int = 160;

    private static const
      SEEKBAR_BOUNDS:Rectangle = new Rectangle(4, 7, 515, 0),
      TRACKFIELD_X:Number = 9,
      TRACKFIELD_Y:Number = 10;

    private var
      tracks:Array,
      regions:Array,
      bins:Array,
      snapGrid:Point,
      trackField:Sprite,
      trackFieldMask:Sprite,
      playhead:MovieClip,
      PlaybackPosition:Number = 0,
      Width:Number,
      Height:Number,
      trackWidth:Number,
      trackHeight:Number,
      ui:MixerUI,
      liftedRegionData:Object,
      tempo:Number = 90,
      beatsPerRegion:int = 8;

    public function Mixer(width:Number = 500, height:Number = 240, trackCount:Number = 5):void {
      tracks = [];
      regions = [];
      bins = [];
      Width = width;
      Height = height;
      trackWidth = BEAT_WIDTH * MAX_BEATS;
      trackHeight = Height / trackCount;
      snapGrid = new Point(BEAT_WIDTH * beatsPerRegion, trackHeight);
      ui = new MixerUI();
      addChild(ui);
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
    }

    public function addRegion(sample:Sample):Region {
      var region = new Region(
        sample,
        BEAT_WIDTH * beatsPerRegion,
        trackHeight,
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
      regions.push(region);
      return region;
    }

    public function resetLiftedRegion(region:Region):void {
      if (liftedRegionData) {
        tracks[liftedRegionData.trackIndex].addRegion(region, liftedRegionData.cellIndex);
        liftedRegionData = null;
      } else {
        removeRegion(region);
      }
    }

    public function removeRegion(region:Region):void {
      liftedRegionData = null;
      region.removeEventListener(DragAndDrop.DRAG_START, onLiftRegion);
      region.removeEventListener(DragAndDrop.DRAG_STOP, onPlaceRegion);
      region.removeEventListener(Region.DUPLICATE, onDuplicateRegion);
      region.removeEventListener(Region.DELETE, onDeleteRegion);
      if (region.parent is Track) {
        var track:Track = region.parent as Track;
        track.removeRegion(region);
      }
      for (var i:Number = regions.length - 1; i >=0; i--) {
        if (region === regions[i]) {
          regions.splice(i, 1);
        }
      }
      region.dispatchEvent(new Event(Mixer.REGION_REMOVED, true));
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

    public function addSample(sample:Sample) {
      bins[0].addSample(sample);
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
      liftedRegionData = null;
      if (this !== region.parent) {
        var regionPosition = globalToLocal(region.localToGlobal(new Point()));
        if (region.parent is Track) {
          var track:Track = region.parent as Track;
          liftedRegionData = {trackIndex:track.index, cellIndex:track.getRegionIndex(region)}
          track.removeRegion(region);
        }
        addChild(region);
        region.x = regionPosition.x;
        region.y = regionPosition.y;
      }
      region.removeEventListener(Event.ENTER_FRAME, updateRegionStatus);
      region.addEventListener(Event.ENTER_FRAME, updateRegionStatus);
    }

    private function placeRegion(region:Region, useNextOpenSpace:Boolean = false) {
      region.removeEventListener(Event.ENTER_FRAME, updateRegionStatus);
      var targetTrackIndex:Number = getObjectTargetTrackIndex(region);
      var debug = "placeRegion: ";
      if (isNaN(targetTrackIndex)) {
        debug += "not on a valid track: remove";
        removeRegion(region);
      } else {
        var track:Track = tracks[targetTrackIndex] as Track;
        var targetCellIndex:int = track.getRegionIndex(region);
        if (track.getRegionAtIndex(targetCellIndex)) {
          var collision:Boolean = true;
          if (useNextOpenSpace) {
            for (var i:int = targetCellIndex; i < MAX_BEATS; i+=beatsPerRegion) {
              trace("trying to place at "+i);
              if (!track.getRegionAtIndex(i)) {
                track.addRegion(region, i);
                collision = false;
                break;
              }
            }
          }
          if (collision) {
            debug += "existing region at this position: reset";
            resetLiftedRegion(region);
          }
        } else {
          track.addRegion(region);
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
      liftedRegionData = null;
      trace(debug);
    }

    private function duplicateRegion(region:Region) {
      var newRegion:Region = addRegion(region.sample);
      var newPosition = globalToLocal(region.parent.localToGlobal(new Point(region.x + region.width, region.y)));
      newRegion.x = newPosition.x;
      newRegion.y = newPosition.y;
      placeRegion(newRegion, true);
    }

    private function getObjectTargetTrackIndex(object:DisplayObject):Number {
      /* find track the object is hovering over */
      var targetTrackIndex:Number = NaN;
      var targetCoord:Point = trackField.globalToLocal(object.localToGlobal(new Point()));
      if (
        targetCoord.x >= 0
        && targetCoord.x < trackWidth
        && targetCoord.y >= 0
        && targetCoord.y < tracks.length * trackHeight
        ) {
        return Math.floor(targetCoord.y / trackHeight);
      }
      return targetTrackIndex;
    }

    private function updateRegionStatus(event:Event):void {
      var region:Region = event.currentTarget as Region;

      /*
       * check for dragging out of bounds... and scroll
       *
      var regionTopLeft = region.parent.localToGlobal(new Point(region.x, region.y));
      var regionBottomRight = regionTopLeft.add(new Point(region.width, region.height));
      var bounds = trackField.mask.getRect(stage);
      var scrollModifier = 0.2;
      if (regionTopLeft.x < bounds.x) {
        // scroll left
        pushTrackField(new Point((regionTopLeft.x - bounds.x) * scrollModifier, 0));
      } else if (regionTopLeft.y < bounds.y) {
        // scroll up
        pushTrackField(new Point(0, (regionTopLeft.y - bounds.y) * scrollModifier));
      } else if (regionBottomRight.x > bounds.x + bounds.width) {
        // scroll right
        pushTrackField(new Point((regionBottomRight.x - (bounds.x + bounds.width)) * scrollModifier, 0));
      } else if (regionBottomRight.y > bounds.y + bounds.height) {
        // scroll down
        pushTrackField(new Point(0, (regionBottomRight.y - (bounds.y + bounds.height)) * scrollModifier));
      }
       */

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
        stage.addEventListener(KeyboardEvent.KEY_DOWN, function(event) {
          switch (event.keyCode) {
            case 39/*<RIGHT>*/:
              pushTrackField(new Point(BEAT_WIDTH * beatsPerRegion, 0));
              break;
            case 37/*<LEFT>*/:
              pushTrackField(new Point(-BEAT_WIDTH * beatsPerRegion, 0));
              break;
            case 38/*<UP>*/:
              pushTrackField(new Point(0, -trackHeight));
              break;
            case 40/*<DOWN>*/:
              pushTrackField(new Point(0, trackHeight));
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
      trackField.x = TRACKFIELD_X - position.x;
      trackField.y = TRACKFIELD_Y - position.y;
      trackField.mask.x = position.x;
      trackField.mask.y = position.y;
    }

    public function pushTrackField(delta:Point):void {
      scrollTrackField(new Point(trackField.mask.x + delta.x, trackField.mask.x + delta.x));
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
      trackField.addChild(playhead);
      updatePlayhead();
    }

    public function updatePlayhead():void {
      playhead.x = PlaybackPosition * BEAT_WIDTH;
      playhead.y = 0;
      scrollTrackField(new Point(playhead.x - trackField.mask.width / 2, 0));
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

    private function grabBin(event:Event) {
      var region = addRegion(event.target.pulledSample);
      region.grab();
    }

    private function attachBehaviors():void {
      /*
       * Playback
       */
      ui.buttonPlay.addEventListener(MouseEvent.CLICK, function(event:MouseEvent) {
        dispatchEvent(new Event(Mixer.PLAY));
      });
      ui.buttonStop.addEventListener(MouseEvent.CLICK, function(event:MouseEvent) {
        dispatchEvent(new Event(Mixer.STOP));
      });
      ui.seekbar.addEventListener(MouseEvent.MOUSE_DOWN, onStartSeekbarSlide);
      updateSeekbar();
    }

    public function get playbackPosition():Number {
      return PlaybackPosition;
    }

    public function set playbackPosition(beat:Number):void {
      PlaybackPosition = beat;
      updatePlayhead();
      updateSeekbar();
    }

    private function onStartSeekbarSlide(event:MouseEvent):void {
      stage.addEventListener(MouseEvent.MOUSE_MOVE, onSeekbarSlide);
      stage.addEventListener(MouseEvent.MOUSE_UP, onStopSeekbarSlide);
      ui.seekbar.handle.startDrag(true, SEEKBAR_BOUNDS);
      ui.seekbar.handle.x = ui.seekbar.mouseX;
      dispatchEvent(new Event(Mixer.SEEK_START));
      onSeekbarSlide(event);
    }

    private function onSeekbarSlide(event:MouseEvent):void {
      playbackPosition = (ui.seekbar.handle.x - SEEKBAR_BOUNDS.x) / SEEKBAR_BOUNDS.width * MAX_BEATS;
      dispatchEvent(new Event(Mixer.SEEK));
    }

    private function onStopSeekbarSlide(event:MouseEvent):void {
      ui.seekbar.handle.stopDrag();
      stage.removeEventListener(MouseEvent.MOUSE_MOVE, onSeekbarSlide);
      stage.removeEventListener(MouseEvent.MOUSE_UP, onStopSeekbarSlide);
      dispatchEvent(new Event(Mixer.SEEK_FINISH));
    }

    private function updateSeekbar():void {
      trace("PlaybackPosition: "+PlaybackPosition);
      ui.seekbar.handle.x = PlaybackPosition / MAX_BEATS * SEEKBAR_BOUNDS.width + SEEKBAR_BOUNDS.x;
      ui.seekbar.fill.width = ui.seekbar.handle.x - ui.seekbar.fill.x;
    }

    private function resize(event:Event = null):void {
      trace("resize");
      ui.x = Math.floor(stage.stageWidth / 2 - ui.width / 2);
      ui.y = 60;
      bins[0].x = Math.floor(stage.stageWidth / 2 - 300 - bins[0].width);
      bins[0].y = stage.stageHeight - bins[0].height - 10;
      bins[1].x = Math.floor(stage.stageWidth / 2 + 300);
      bins[1].y = stage.stageHeight - bins[1].height - 10;
    }

    private function demo():void {
      addBin(new Bin());
      addBin(new Bin());
    }

  }

}
