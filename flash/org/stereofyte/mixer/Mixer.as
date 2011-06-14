/*
 * ----------------------------------------------------
 * BUG: placing a cell left of 0 causes an endless loop
 * Error: Error #1502: A script has executed for longer than the default timeout period of 15 seconds.
 *   at org.stereofyte.mixer::Mixer/removeCell()
 *   at org.stereofyte.mixer::Mixer/placeCell()
 *   at flash.events::EventDispatcher/dispatchEventFunction()
 *   at flash.events::EventDispatcher/dispatchEvent()
 *   at com.chrislovejoy.gui::DragAndDrop/stopMyDrag()
 * TypeError: Error #1009: Cannot access a property or method of a null object reference.
 *   at com.chrislovejoy.gui::DragAndDrop/stopMyDrag()
 * TypeError: Error #1009: Cannot access a property or method of a null object reference.
 *   at com.chrislovejoy.gui::DragAndDrop/stopMyDrag()
 * ---------------------------------------------------
 */
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
    
    protected static const
      TRACK_HEIGHT:Number = 40,
      CELL_WIDTH:Number = 120;

    protected var
      Width:Number,
      Height:Number,
      trackField:Sprite,
      trackFieldMask:Sprite,
      tracks:Array,
      cells:Array,
      bins:Array

    public function Mixer(width:Number = 500, height:Number = 240, trackCount:Number = 8):void {
      tracks = [];
      cells = [];
      bins = [];
      this.Width = width;
      this.Height = height;
      drawBackground();
      drawTrackField();
      for (var i:Number = 0; i < trackCount; i++) {
        addTrack(new Track(1000, TRACK_HEIGHT));
      }
      demo();
    }

    public function addCell(cellData:Object):Cell {
      var cell = new Cell(cellData, CELL_WIDTH, TRACK_HEIGHT, new Point(CELL_WIDTH, TRACK_HEIGHT), trackField.localToGlobal(new Point(0, 0)));
      cell.addEventListener(DragAndDrop.DRAG_START, liftCell);
      cell.addEventListener(DragAndDrop.DRAG_STOP, placeCell);
      addChild(cell);
      cells.push(cell);
      return cell;
    }

    public function removeCell(cell:Cell):void {
      cell.removeEventListener(DragAndDrop.DRAG_START, liftCell);
      cell.removeEventListener(DragAndDrop.DRAG_STOP, placeCell);
      for (var i:Number = cells.length - 1; i >=0; i--) {
        if (cell === cells[i]) {
          cells.splice(i, 1);
        }
      }
      cell.clear();
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

    protected function liftCell(event:Event) {
      var cell:Cell = event.target as Cell;
      if (this !== cell.parent) {
        var cellPosition = globalToLocal(cell.localToGlobal(new Point()));
        addChild(cell);
        cell.x = cellPosition.x;
        cell.y = cellPosition.y;
      }
      cell.removeEventListener(DragAndDrop.DRAG_MOVE, checkForDeleteCell);
      cell.addEventListener(DragAndDrop.DRAG_MOVE, checkForDeleteCell);
    }

    protected function placeCell(event:Event) {
      var cell:Cell = event.target as Cell;
      cell.removeEventListener(DragAndDrop.DRAG_MOVE, checkForDeleteCell);
      var targetTrackIndex:Number = getObjectTargetTrackIndex(cell);
      if (isNaN(targetTrackIndex)) {
        removeCell(cell);
      } else {
        tracks[targetTrackIndex].addCell(cell);
      }
    }

    protected function getObjectTargetTrackIndex(object:DisplayObject):Number {
      /* find track the object is hovering over */
      var targetTrackIndex:Number = NaN;
      var targetCoord:Point = object.localToGlobal(new Point());
      for (var i:Number = 0; i < tracks.length; i++) {
        if (tracks[i].hitTestPoint(targetCoord.x+1, targetCoord.y+1)) {
          targetTrackIndex = i;
          break;
        }
      }
      return targetTrackIndex;
    }

    protected function checkForDeleteCell(event:Event):void {
      var cell:Cell = event.target as Cell;
      var targetTrackIndex:Number = getObjectTargetTrackIndex(cell.snapGhost);
      if (isNaN(targetTrackIndex)) {
        cell.showDeleteMode();
      } else {
        cell.showNormalMode();
      }
    }

    protected function drawBackground():void {
      graphics.beginFill(0x999999, 1);
      graphics.drawRect(0, 0, Width, Height);
      graphics.endFill();
    }

    protected function drawTrackField():void {
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
            case 39:
              scrollTrackField(new Point(-30, 0));
              break;
            case 37:
              scrollTrackField(new Point(30, 0));
              break;
          }
        } );
      } );
    }

    public function scrollTrackField(delta:Point):void {
      trackField.x += delta.x;
      trackField.y += delta.y;
      trackField.mask.x -= delta.x;
      trackField.mask.y -= delta.y;
    }

    protected function resizeTrackField(width:Number, height:Number):void {
      trackFieldMask.graphics.clear();
      trackFieldMask.graphics.beginFill(0x000000, 1);
      trackFieldMask.graphics.drawRect(0, 0, width, height);
      trackFieldMask.graphics.endFill();
    }
    
    protected function addTrack(track:Track):void {
      tracks.push(track);
      trackField.addChild(track);
      track.y = track.height * (tracks.length - 1);
    }
    
    protected function addBin(bin:Bin):void {
      bins.push(bin);
      bin.addEventListener(Bin.PULL, function(event:Event) {
        var cell = addCell(bin.pulledItemData);
        cell.grab();
      });
      addChild(bin);
      bin.y = 200;
    }

    private function demo():void {
      trackField.x = 100;
      trackField.y = 100;
      var bin = new Bin();
      addBin(bin);

      bin.addItem({
        src:"egypt/vocals.ogg",
        key:"E+",
        bpm:90,
        family:"vocals",
        duration:6000
      });
      bin.addItem({
        src:"egypt/drums.ogg",
        key:"E+",
        bpm:90,
        family:"drums",
        duration:6000
      });
      bin.addItem({
        src:"egypt/strings.ogg",
        key:"E+",
        bpm:90,
        family:"strings",
        duration:6000
      });
      bin.addItem({
        src:"egypt/guitar.ogg",
        key:"E+",
        bpm:90,
        family:"guitar",
        duration:6000
      });
      bin.addItem({
        src:"egypt/brass.ogg",
        key:"E+",
        bpm:90,
        family:"brass",
        duration:6000
      });
    }

  }

}
