package com.chrislovejoy.util {
  
  import flash.geom.Point;

  public function placeAt(coords:Point, elements:Array, axis:String = '', padding:Number = 8, groupPos:String = 'center'):void {
    var totalWidth:Number = 0,
        totalHeight:Number = 0,
        left:Number,
        top:Number;
      
    for each(var element:* in elements) {
      measure:{
        if(axis == '') {
          element.x = coords.x - element.width / 2;
          element.y = coords.y - element.height / 2;
          break measure;
        }

        if(axis == 'x' ) totalWidth += element.width;
        else totalWidth = Math.max(totalWidth, element.width);
        if(axis == 'y') totalHeight += element.height;
        else totalHeight = Math.max(totalHeight, element.height);
      }
    }
    if(axis == '') return;
    
    axis == 'x' && (totalWidth += padding * (elements.length - 1));
    axis == 'y' && (totalHeight += padding * (elements.length - 1));
    
    var leftOffset = -totalWidth / 2;
    if(groupPos.indexOf('left') != -1)
      leftOffset = 0;
    else if(groupPos.indexOf('right') != -1)
      leftOffset = totalWidth / 2;
      
    left = coords.x + leftOffset;
    
    var topOffset = -totalHeight / 2;
    if(groupPos.indexOf('top') != -1)
      topOffset = 0;
    else if(groupPos.indexOf('bottom') != -1)
      topOffset = totalHeight / 2;
      
    top = coords.y + topOffset;
  
    for(var i:* in elements) {
      element = elements[i];
      if(axis == 'x') elements[i].x = (i ? elements[i-1].x + elements[i-1].width + padding : left);
      else elements[i].x = left + (totalWidth - elements[i].width) / 2;
      
      if(axis == 'y') elements[i].y = (i ? elements[i-1].y + elements[i-1].height + padding : top);
      else elements[i].y = top + (totalHeight - elements[i].height) / 2;
    }
  }
  
}
