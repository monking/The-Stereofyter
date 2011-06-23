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
      DRAG_MOVE = "drag_move",
      DRAG_STOP = "drag_stop";

    public var options:Object;

    protected var dragging:Boolean,
                  grabOrigin:Point,
                  ghost:DragAndDrop;
    
    public function DragAndDrop(options:Object):void {
      this.options = {
        isGhost:                 false,
        snapRadius:              0,
        grid:                    new Point(10, 10),
        gridOrigin:              new Point(),
        coordinateSpace:         null,
        bounds:                  null,
        snapToGlobal:            false,
        forceSnapOnStop:         false,
        dragOn:                  Event.ENTER_FRAME,
        ghostColor:              0x000000,
        ghostAlpha:              0.2,
        snapToIntersectionsOnly: false
      };
      for (var key:String in this.options) {
        if (options.hasOwnProperty(key)) this.options[key] = options[key];
      }
      if (!options.isGhost) {
        ghost = new DragAndDrop({
          isGhost:    true,
          snapRadius: this.options.forceSnapOnStop? NaN: this.options.snapRadius,
          grid:       this.options.grid,
          gridOrigin: this.options.gridOrigin,
          dragOn:     this.options.dragOn
        });
      }
      addEventListener( MouseEvent.MOUSE_DOWN, startMyDrag );
    }

    public function clear(event:Event = null) {
      stopMyDrag();
      parent && parent.removeChild(this);
      ghost.parent && ghost.parent.removeChild(ghost);
    }

    public function update():void {
      options.snapRadius !== 0 && options.grid && snap();
    }

    override public function startDrag(lockCenter:Boolean = false, bounds:Rectangle = null):void {
      options.bounds = bounds;
      startMyDrag();
    }

    override public function stopDrag():void {
      stopMyDrag();
    }

    public function get isDragging():Boolean {
      return dragging;
    }

    public function get snapPoint():Point {
      return ghost.parent.localToGlobal(new Point(ghost.x, ghost.y));
    }

    public function get snapRect():Rectangle {
      var snapPosition:Point = snapPoint;
      return new Rectangle(snapPosition.x, snapPosition.y, width, height);
    }

    protected function drag(event:Event = null):void {
      x = parent.mouseX - grabOrigin.x;
      y = parent.mouseY - grabOrigin.y;
      update();
      dispatchEvent( new Event(DragAndDrop.DRAG_MOVE) );
    }

    protected function startMyDrag(event:Event = null):void {
      if (dragging || !stage) return;
      dragging = true;
      grabOrigin = new Point(mouseX, mouseY);

      stage.addEventListener( options.dragOn, drag );
      stage.addEventListener( Event.MOUSE_LEAVE, stopMyDrag );
      stage.addEventListener( MouseEvent.MOUSE_UP, stopMyDrag );

      dispatchEvent(new Event(DragAndDrop.DRAG_START));
      options.isGhost || startSnapGhost(); /* after dispatchEvent in case a listener adds this instance to another parent */
    }

    protected function stopMyDrag(event:Event = null):void {
      if (stage) {
        stage.removeEventListener( options.dragOn, drag );
        stage.removeEventListener( MouseEvent.MOUSE_UP, stopMyDrag );
        stage.removeEventListener( Event.MOUSE_LEAVE, stopMyDrag );
      }

      if (!dragging) return;
      dragging = false;
      options.forceSnapOnStop && snap(true);
      options.isGhost || stopSnapGhost();
      dispatchEvent(new Event(DragAndDrop.DRAG_STOP));
    }

    protected function snap(force:Boolean = false):void {
      var positionOnGrid:Point = new Point(x, y);
      if (options.snapToGlobal) {
        positionOnGrid = parent.localToGlobal(positionOnGrid);
      } else if(!options.isGhost) {
        positionOnGrid = ghost.parent.globalToLocal(parent.localToGlobal(positionOnGrid));
      }
      positionOnGrid = positionOnGrid.subtract(options.gridOrigin);
      var distanceFromGridLine:Point = new Point(positionOnGrid.x % options.grid.x, positionOnGrid.y % options.grid.y);

      if (force || isNaN(options.snapRadius)) {
        if (distanceFromGridLine.x < options.grid.x / 2) {
          x -= distanceFromGridLine.x;
        } else {
          x += options.grid.x - distanceFromGridLine.x;
        }
        if (distanceFromGridLine.y < options.grid.y / 2) {
          y -= distanceFromGridLine.y;
        } else {
          y += options.grid.y - distanceFromGridLine.y;
        }
      } else if (options.snapToIntersectionsOnly) {
        if (distanceFromGridLine.length < options.snapRadius) {
          x -= distanceFromGridLine.x;
          y -= distanceFromGridLine.y;
        }
      } else {
        if (distanceFromGridLine.x < Math.min(options.snapRadius, options.grid.x / 2)) {
          x -= distanceFromGridLine.x;
        } else if (options.grid.x - distanceFromGridLine.x < options.snapRadius) {
          x += options.grid.x - distanceFromGridLine.x;
        }
        if (distanceFromGridLine.y < Math.min(options.snapRadius, options.grid.y / 2)) {
          y -= distanceFromGridLine.y;
        } else if (options.grid.y - distanceFromGridLine.y < options.snapRadius) {
          y += options.grid.y - distanceFromGridLine.y;
        }
      }
    }

    protected function drawSnapGhost():void {
      if (options.isGhost) return;
      if (options.forceSnapOnStop) {
        ghost.graphics.beginFill(options.ghostColor, options.ghostAlpha);
        ghost.graphics.drawRect(0, 0, width, height);
        ghost.graphics.endFill();
      }
    }

    protected function startSnapGhost():void {
      if (options.isGhost) return;
      drawSnapGhost();
      if (!options.coordinateSpace || options.coordinateSpace === parent) {
        options.coordinateSpace.addChildAt(ghost, parent.getChildIndex(this));
      } else {
        options.coordinateSpace.addChild(ghost);
      }
      var ghostPosition = ghost.parent.globalToLocal(parent.localToGlobal(new Point(x, y)));
      ghost.x = ghostPosition.x;
      ghost.y = ghostPosition.y;
      ghost.startDrag();
    }

    protected function stopSnapGhost():void {
      if (options.isGhost) return;
      ghost.graphics.clear();
      ghost.stopDrag();
    }

  }

}
