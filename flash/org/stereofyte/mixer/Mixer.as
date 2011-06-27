package org.stereofyte.mixer {

  import flash.display.DisplayObject;
  import flash.display.Graphics;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.geom.Point;
  import com.chrislovejoy.gui.DragAndDrop;

  public class Mixer extends Sprite {
    
    public static const
      TRACK_HEIGHT:Number = 40,
      BEAT_WIDTH:Number = 120,
      REGION_ADDED:String = "regionAdded",
      REGION_MOVED:String = "regionMoved";

    private var
      tracks:Array,
      regions:Array,
      bins:Array,
      snapGrid:Point,
      trackField:Sprite,
      trackFieldMask:Sprite,
      playhead:Sprite,
      Width:Number,
      Height:Number,
      trackWidth:Number = 1000

    public function Mixer(width:Number = 500, height:Number = 240, trackCount:Number = 8):void {
      tracks = [];
      regions = [];
      bins = [];
      Width = width;
      Height = height;
      drawBackground();
      drawTrackField();
      drawPlayhead();
      for (var i:Number = 0; i < trackCount; i++) {
        addTrack(new Track(trackWidth, TRACK_HEIGHT));
      }
      snapGrid = new Point(BEAT_WIDTH, TRACK_HEIGHT);
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
          coordinateSpace: trackField
        }
      );
      region.addEventListener(DragAndDrop.DRAG_START, liftRegion);
      region.addEventListener(DragAndDrop.DRAG_STOP, placeRegion);
      addChild(region);
      regions.push(region);
      return region;
    }

    public function removeRegion(region:Region):void {
      region.removeEventListener(DragAndDrop.DRAG_START, liftRegion);
      region.removeEventListener(DragAndDrop.DRAG_STOP, placeRegion);
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

    private function liftRegion(event:Event) {
      var region:Region = event.target as Region;
      if (this !== region.parent) {
        var regionPosition = globalToLocal(region.localToGlobal(new Point()));
        addChild(region);
        region.x = regionPosition.x;
        region.y = regionPosition.y;
      }
      region.removeEventListener(Event.ENTER_FRAME, updateRegionStatus);
      region.addEventListener(Event.ENTER_FRAME, updateRegionStatus);
    }

    private function placeRegion(event:Event) {
      var region:Region = event.target as Region;
      region.removeEventListener(Event.ENTER_FRAME, updateRegionStatus);
      var targetTrackIndex:Number = getObjectTargetTrackIndex(region);
      if (isNaN(targetTrackIndex)) {
        removeRegion(region);
      } else {
        tracks[targetTrackIndex].addRegion(region);
        if (Region.STATUS_NULL == region.status) {
          region.status = Region.STATUS_LIVE;
          region.dispatchEvent(new Event(Mixer.REGION_ADDED, true));
        } else {
          region.dispatchEvent(new Event(Mixer.REGION_MOVED, true));
        }
      }
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

    private function drawBackground():void {
      graphics.beginFill(0x999999, 1);
      graphics.drawRect(0, 0, Width, Height);
      graphics.endFill();
    }

    private function drawTrackField():void {
      trackField = new Sprite();
      trackFieldMask = new Sprite();
      trackField.mask = trackFieldMask;
      resizeTrackField(width, height);
      addChild(trackField);
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
      trackField.addChild(track);
      var trackIndex = tracks.length - 1;
      track.index = trackIndex;
      track.y = TRACK_HEIGHT * trackIndex;
    }
    
    private function drawPlayhead():void {
      playhead = new Sprite();
      playhead.graphics.lineStyle(0, 0xFF0000, 0.5);
      playhead.graphics.lineTo(0, trackField.mask.height);
      playhead.x = trackField.x;
      playhead.y = trackField.y;
      addChild(playhead);
    }
    
    private function addBin(bin:Bin):void {
      bins.push(bin);
      bin.addEventListener(Bin.PULL, function(event:Event) {
        var region = addRegion(bin.pulledSample);
        region.grab();
      });
      addChild(bin);
      bin.y = 200;
    }

    private function demo():void {
      trackField.x = 100;
      trackField.y = 100;
      addBin(new Bin());
    }

  }

}
