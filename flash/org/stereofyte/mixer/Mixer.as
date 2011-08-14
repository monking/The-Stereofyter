package org.stereofyte.mixer {

  import flash.display.DisplayObject;
  import flash.display.Graphics;
  import flash.display.MovieClip;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.geom.Point;
  import com.chrislovejoy.gui.DragAndDrop;

  public class Mixer extends Sprite {
    
    public static const
      TRACK_HEIGHT:Number = 46,
      BEAT_WIDTH:Number = 87,
      REGION_ADDED:String = "regionAdded",
      REGION_MOVED:String = "regionMoved";

    private var
      tracks:Array,
      regions:Array,
      bins:Array,
      snapGrid:Point,
      trackField:Sprite,
      trackFieldMask:Sprite,
      playhead:MovieClip,
      Width:Number,
      Height:Number,
      trackWidth:Number = 1000,
      ui:MixerUI;

    public function Mixer(width:Number = 500, height:Number = 240, trackCount:Number = 8):void {
      tracks = [];
      regions = [];
      bins = [];
      Width = width;
      Height = height;
      snapGrid = new Point(BEAT_WIDTH, TRACK_HEIGHT);
      ui = new MixerUI();
      addChild(ui);
      drawTrackField();
      drawPlayhead();
      for (var i:Number = 0; i < trackCount; i++) {
        addTrack(new Track(trackWidth, TRACK_HEIGHT));
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
        BEAT_WIDTH,
        TRACK_HEIGHT,
        {
          grid:            snapGrid,
          forceSnapOnStop: true,
          coordinateSpace: trackField,
          grabAnywhere:    false
        }
      );
      region.addEventListener(DragAndDrop.DRAG_START, onLiftRegion);
      region.addEventListener(DragAndDrop.DRAG_STOP, onPlaceRegion);
      region.addEventListener(Region.DUPLICATE, onDuplicateRegion);
      addChild(region);
      regions.push(region);
      return region;
    }

    public function removeRegion(region:Region):void {
      region.removeEventListener(DragAndDrop.DRAG_START, onLiftRegion);
      region.removeEventListener(DragAndDrop.DRAG_STOP, onPlaceRegion);
      region.removeEventListener(Region.DUPLICATE, onDuplicateRegion);
      for (var i:Number = regions.length - 1; i >=0; i--) {
        if (region === regions[i]) {
          regions.splice(i, 1);
        }
      }
      region.clear();
    }

    /**
     * Get the playback position of the mixer, or the position of a region, in terms of beats
     * @region OPTIONAL The region of which to get the position. Returns the playhead position if omitted.
     */
    public function getBeat(region:Region = null):Number {
      if (region) {
        return region.x / BEAT_WIDTH;
      } else {
        /* return the playhead position */
        return 0;
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

    private function liftRegion(region:Region) {
      if (this !== region.parent) {
        var regionPosition = globalToLocal(region.localToGlobal(new Point()));
        addChild(region);
        region.x = regionPosition.x;
        region.y = regionPosition.y;
      }
      region.removeEventListener(Event.ENTER_FRAME, updateRegionStatus);
      region.addEventListener(Event.ENTER_FRAME, updateRegionStatus);
    }

    private function placeRegion(region:Region) {
      region.removeEventListener(Event.ENTER_FRAME, updateRegionStatus);
      var targetTrackIndex:Number = getObjectTargetTrackIndex(region);
      var debug = "placeRegion: ";
      if (isNaN(targetTrackIndex)) {
        debug += "not on a valid track: remove Region";
        removeRegion(region);
      } else {
        tracks[targetTrackIndex].addRegion(region);
        if (Region.STATUS_NULL == region.status) {
          debug += "new region: ADDED";
          region.status = Region.STATUS_LIVE;
          region.dispatchEvent(new Event(Mixer.REGION_ADDED, true));
        } else {
          debug += "existing region: MOVED";
          region.dispatchEvent(new Event(Mixer.REGION_MOVED, true));
        }
      }
      trace(debug);
    }

    private function duplicateRegion(region:Region) {
      var newRegion:Region = addRegion(region.sample);
      var newPosition = globalToLocal(region.parent.localToGlobal(new Point(region.x + region.width, region.y)));
      newRegion.x = newPosition.x;
      newRegion.y = newPosition.y;
      placeRegion(newRegion);
    }

    private function getObjectTargetTrackIndex(object:DisplayObject):Number {
      /* find track the object is hovering over */
      var targetTrackIndex:Number = NaN;
      var targetCoord:Point = trackField.globalToLocal(object.localToGlobal(new Point()));
      if (
        targetCoord.x >= 0
        && targetCoord.x < trackWidth
        && targetCoord.y >= 0
        && targetCoord.y < tracks.length * TRACK_HEIGHT
        ) {
        return Math.floor(targetCoord.y / TRACK_HEIGHT);
      }
      return targetTrackIndex;
    }

    private function updateRegionStatus(event:Event):void {
      var region:Region = event.currentTarget as Region;

      /* check for dragging out of bounds... and scroll */
      var regionTopLeft = region.parent.localToGlobal(new Point(region.x, region.y));
      var regionBottomRight = regionTopLeft.add(new Point(region.width, region.height));
      var bounds = trackField.mask.getRect(stage);
      var scrollModifier = 0.2;
      if (regionTopLeft.x < bounds.x) {
        /* scroll left */
        scrollTrackField(new Point((regionTopLeft.x - bounds.x) * scrollModifier, 0));
      } else if (regionTopLeft.y < bounds.y) {
        /* scroll up */
        scrollTrackField(new Point(0, (regionTopLeft.y - bounds.y) * scrollModifier));
      } else if (regionBottomRight.x > bounds.x + bounds.width) {
        /* scroll right */
        scrollTrackField(new Point((regionBottomRight.x - (bounds.x + bounds.width)) * scrollModifier, 0));
      } else if (regionBottomRight.y > bounds.y + bounds.height) {
        /* scroll down */
        scrollTrackField(new Point(0, (regionBottomRight.y - (bounds.y + bounds.height)) * scrollModifier));
      }

      var targetTrackIndex:Number = getObjectTargetTrackIndex(region.snapGhost);
      /* check for snapping out of bounds */
      if (isNaN(targetTrackIndex)) {
        region.showDeleteMode();
      } else {
        region.showNormalMode();
      }

    }

    private function drawTrackField():void {
      trackField = new Sprite();
      trackField.x = 10;
      trackField.y = 11;
      trackFieldMask = new Sprite();
      trackField.mask = trackFieldMask;
      resizeTrackField(width, height);
      ui.addChild(trackField);
      trackField.addChild(trackFieldMask);
      trackField.addEventListener(MouseEvent.MOUSE_WHEEL, function(event) {
        scrollTrackField(new Point(event.delta * 20, 0));
      } );
      addEventListener(Event.ADDED_TO_STAGE, function(event) {
        stage.addEventListener(KeyboardEvent.KEY_DOWN, function(event) {
          switch (event.keyCode) {
            case 39/*<RIGHT>*/:
              scrollTrackField(new Point(BEAT_WIDTH, 0));
              break;
            case 37/*<LEFT>*/:
              scrollTrackField(new Point(-BEAT_WIDTH, 0));
              break;
            case 38/*<UP>*/:
              scrollTrackField(new Point(0, -TRACK_HEIGHT));
              break;
            case 40/*<DOWN>*/:
              scrollTrackField(new Point(0, TRACK_HEIGHT));
              break;
          }
        } );
      } );
    }

    public function scrollTrackField(delta:Point):void {
      /* positive coords scroll down/right, moving trackField up/left */
      delta = new Point(Math.round(delta.x), Math.round(delta.y));
      var maskX:Number = trackField.mask.x + delta.x;
      var maskY:Number = trackField.mask.y + delta.y;
      if (maskX < 0) {
        delta.offset(-maskX, 0);
      } else if (maskY < 0) {
        delta.offset(0, -maskY);
      } else if (maskX + trackField.mask.width > trackWidth) {
        delta.offset(trackWidth - (maskX + trackField.mask.width), 0);
      } else if (maskY + trackField.mask.height > TRACK_HEIGHT * tracks.length) {
        delta.offset(0, TRACK_HEIGHT * tracks.length - (maskY + trackField.mask.height));
      }
      trackField.x -= delta.x;
      trackField.y -= delta.y;
      trackField.mask.x += delta.x;
      trackField.mask.y += delta.y;
    }

    public function zoomTrackField(factor:Number):void {
      trackField.scaleX = factor;
      //snapGrid = new Point(BEAT_WIDTH * factor, TRACK_HEIGHT * factor);
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
      track.y = TRACK_HEIGHT * trackIndex;
    }
    
    private function drawPlayhead():void {
      playhead = ui.playhead;
      /*
      playhead = new Sprite();
      playhead.graphics.lineStyle(0, 0xFF0000, 1);
      playhead.graphics.lineTo(0, trackField.mask.height);
      */
      trackField.addChild(playhead);
      updatePlayhead(1);
    }

    public function updatePlayhead(beat:Number):void {
      playhead.x = beat * snapGrid.x;
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

    private function resize(event:Event = null):void {
      trace("resize");
      ui.x = Math.floor(stage.stageWidth / 2 - ui.width / 2);
      ui.y = 100;
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
