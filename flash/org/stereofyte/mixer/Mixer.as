package org.stereofyte.mixer {

  import flash.display.Graphics;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.geom.Point;
  import com.chrislovejoy.gui.DragAndDrop;
  import org.stereofyte.mixblendr.*;

  public class Mixer extends Sprite {
    
    protected static const
      trackHeight:Number = 40;

    protected var
      Width:Number,
      Height:Number,
      trackField:Sprite,
      trackFieldMask:Sprite,
      tracks:Array,
      cells:Array,
      bins:Array,
      mbinterface:MixBlendrInterface;

    public function Mixer(width:Number = 500, height:Number = 240, trackCount:Number = 8):void {
      tracks = [];
      cells = [];
      bins = [];
      mbinterface = new MixBlendrInterface("mbinterface");
      this.Width = width;
      this.Height = height;
      drawBackground();
      drawTrackField();
      for (var i:Number = 0; i < trackCount; i++) {
        addTrack(new Track());
      }
      demo();
    }

    public function addCell(cellData:Object):void {
      var cell = new Cell(cellData);
      cell.addEventListener(DragAndDrop.DRAG_START, function(event) {
        var cell:Cell = event.target as Cell;
        if (this === cell.parent) return;
        var cellPosition = globalToLocal(cell.localToGlobal(new Point()));
        addChild(cell);
        cell.x = cellPosition.x;
        cell.y = cellPosition.y;
      });
      cell.addEventListener(DragAndDrop.DRAG_STOP, function(event) {
        var cell:Cell = event.target as Cell;
        if (this === cell.parent) return;
        /* find track the cell is hovering over */
        var targetTrackIndex = 0;
        for (var i:Number = 0; i < tracks.length; i++) {
          if (cell.y <= tracks[i].y) {
            targetTrackIndex = i;
            break;
          }
        }
        trace(targetTrackIndex);
        tracks[targetTrackIndex].addCell(cell);
      });
      addChild(cell);
      cells.push(cell);
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
      addChild(trackFieldMask);
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
      track.y = /*track.height*/40 * (tracks.length - 1);
    }

    private function demo():void {
      x = 100;
      y = 100;
      addCell({sample:"", family:"brass"});
    }

  }

}
