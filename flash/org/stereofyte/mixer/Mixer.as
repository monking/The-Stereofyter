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
      var cell = new Cell(
        cellData,
        CELL_WIDTH,
        TRACK_HEIGHT,
        {
          grid:            new Point(CELL_WIDTH, TRACK_HEIGHT),
          forceSnapOnStop: true,
          coordinateSpace: trackField
        }
      );
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
      cell.removeEventListener(DragAndDrop.DRAG_MOVE, updateCellStatusOnDrag);
      cell.addEventListener(DragAndDrop.DRAG_MOVE, updateCellStatusOnDrag);
    }

    protected function placeCell(event:Event) {
      var cell:Cell = event.target as Cell;
      cell.removeEventListener(DragAndDrop.DRAG_MOVE, updateCellStatusOnDrag);
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
        if (trackField.mask.hitTestPoint(targetCoord.x+1, targetCoord.y+1)) {
          if (tracks[i].hitTestPoint(targetCoord.x+1, targetCoord.y+1)) {
            targetTrackIndex = i;
            break;
          }
        }
      }
      return targetTrackIndex;
    }

    protected function updateCellStatusOnDrag(event:Event):void {
      var cell:Cell = event.target as Cell;
      var targetTrackIndex:Number = getObjectTargetTrackIndex(cell.snapGhost);
      /* check for snapping out of bounds */
      if (isNaN(targetTrackIndex)) {
        cell.showDeleteMode();
      } else {
        cell.showNormalMode();
      }

      /* check for dragging out of bounds... and scroll */
      var cellTopLeft = cell.parent.localToGlobal(new Point(cell.x, cell.y));
      var cellBottomRight = cellTopLeft.add(new Point(cell.width, cell.height));
      var bounds = trackField.mask.getRect(stage);
      var scrollModifier = 0.25;
      if (cellTopLeft.x < bounds.x) {
        /* scroll left */
        scrollTrackField(new Point((cellTopLeft.x - bounds.x) * scrollModifier, 0));
      } else if (cellTopLeft.y < bounds.y) {
        /* scroll up */
        scrollTrackField(new Point(0, (cellTopLeft.y - bounds.y) * scrollModifier));
      } else if (cellBottomRight.x > bounds.x + bounds.width) {
        /* scroll right */
        scrollTrackField(new Point((cellBottomRight.x - (bounds.x + bounds.width)) * scrollModifier, 0));
      } else if (cellBottomRight.y > bounds.y + bounds.height) {
        /* scroll down */
        scrollTrackField(new Point(0, (cellBottomRight.y - (bounds.y + bounds.height)) * scrollModifier));
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
            case 39/*<RIGHT>*/:
              scrollTrackField(new Point(CELL_WIDTH, 0));
              break;
            case 37/*<LEFT>*/:
              scrollTrackField(new Point(-CELL_WIDTH, 0));
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
      var maskX:Number = trackField.mask.x + delta.x;
      var maskY:Number = trackField.mask.y + delta.y;
      if (maskX < 0) {
        delta.offset(-maskX, 0);
      } else if (maskY < 0) {
        delta.offset(0, -maskY);
      } else if (maskX + trackField.mask.width > trackField.width) {
        delta.offset(trackField.width - (maskX + trackField.mask.width), 0);
      } else if (maskY + trackField.mask.height > trackField.height) {
        delta.offset(0, trackField.height - (maskY + trackField.mask.height));
      }
      trackField.x -= delta.x;
      trackField.y -= delta.y;
      trackField.mask.x += delta.x;
      trackField.mask.y += delta.y;
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
