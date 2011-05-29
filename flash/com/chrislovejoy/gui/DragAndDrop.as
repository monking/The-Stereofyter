package com.chrislovejoy.gui {

  import flash.display.Graphics;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.geom.Rectangle;
  import flash.geom.Point;

  public class DragAndDrop extends Sprite {
    
    /*
     * Currently only snaps by origin
     * also only snaps to regular grid, not objects or edges
     */

    public static const
      DRAG_START = "drag_start",
      DRAG_STOP = "drag_stop";

    public var snapRadius:Number,
               snapOnMouseUp:Boolean,
               snapToIntersectionsOnly:Boolean,
               grid:Point,
               gridOrigin:Point,
               bounds:Rectangle;

    protected var dragging:Boolean,
                  grabOrigin:Point;
    
    public function DragAndDrop(snapRadius:Number = 0, grid:Point = null, gridOrigin:Point = null, bounds:Rectangle = null, snapOnMouseUp:Boolean = false, snapToIntersectionsOnly:Boolean = false):void {
      this.snapRadius = snapRadius;
      this.grid = grid;
      this.gridOrigin = gridOrigin || new Point(0, 0);
      this.bounds = bounds;
      this.snapOnMouseUp = snapOnMouseUp;
      this.snapToIntersectionsOnly = snapToIntersectionsOnly;
      addEventListener( MouseEvent.MOUSE_DOWN, startMyDrag );
    }

    public function get isDragging():Boolean {
      return dragging;
    }

    protected function drag(event:MouseEvent):void {
      x = parent.mouseX - grabOrigin.x;
      y = parent.mouseY - grabOrigin.y;
      snapRadius && grid && snap();
    }

    protected function startMyDrag(event:MouseEvent = null):void {
      if (dragging) return;
      dragging = true;
      grabOrigin = new Point(mouseX, mouseY);
      dispatchEvent(new Event(DragAndDrop.DRAG_START));
      root.stage.addEventListener( MouseEvent.MOUSE_MOVE, drag );

      addEventListener( MouseEvent.MOUSE_UP, stopMyDrag );
      root.stage.addEventListener( Event.MOUSE_LEAVE, stopMyDrag );
      root.stage.addEventListener( MouseEvent.MOUSE_UP, stopMyDrag );
    }

    protected function stopMyDrag(event:MouseEvent = null):void {
      if (!dragging) return;
      snapOnMouseUp && snap(true);
      dispatchEvent(new Event(DragAndDrop.DRAG_STOP));

      root.stage.removeEventListener( MouseEvent.MOUSE_MOVE, drag );

      removeEventListener( MouseEvent.MOUSE_UP, stopMyDrag );
      root.stage.removeEventListener( MouseEvent.MOUSE_UP, stopMyDrag );
      root.stage.removeEventListener( Event.MOUSE_LEAVE, stopMyDrag );
      dragging = false;
      stopDrag();
    }

    protected function snap(force:Boolean = false):void {
      var positionOnGrid:Point = new Point(x, y);
      positionOnGrid.subtract(gridOrigin);
      var distanceFromGridLine:Point = new Point(positionOnGrid.x % grid.x, positionOnGrid.y % grid.y);

      if (force) {
        if (distanceFromGridLine.x < grid.x / 2) {
          x -= distanceFromGridLine.x;
        } else {
          x += grid.x - distanceFromGridLine.x;
        }
        if (distanceFromGridLine.y < grid.y / 2) {
          y -= distanceFromGridLine.y;
        } else {
          y += grid.y - distanceFromGridLine.y;
        }
      } else if (snapToIntersectionsOnly) {
        if (distanceFromGridLine.length < snapRadius) {
          x -= distanceFromGridLine.x;
          y -= distanceFromGridLine.y;
        }
      } else {
        if (distanceFromGridLine.x < snapRadius) {
          x -= distanceFromGridLine.x;
        } else if (grid.x - distanceFromGridLine.x < snapRadius) {
          x += grid.x - distanceFromGridLine.x;
        }
        if (distanceFromGridLine.y < snapRadius) {
          y -= distanceFromGridLine.y;
        } else if (grid.y - distanceFromGridLine.y < snapRadius) {
          y += grid.y - distanceFromGridLine.y;
        }
      }
    }

  }

}
