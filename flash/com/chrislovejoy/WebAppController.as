package com.chrislovejoy {
  
  import flash.display.DisplayObject
  import flash.display.LoaderInfo;
  import flash.external.ExternalInterface;
  
  public class WebAppController {
    
    protected var
      _root:DisplayObject;

    public function WebAppController(root:DisplayObject) {
      _root = root;
    }
    
    public function get url():String {
      if(!_root.hasOwnProperty('loaderInfo')) return ''
      return _root.loaderInfo.url
    }
    
    public function get dir():String {
      return url.match(/.*(?=\/)/)[0]
    }
    
    public function get domain():String {
      var left:Number = 0,
          right:Number = 1
          
      if(url.indexOf('http://') == 0) left = 7
      else if(url.indexOf('https://') == 0) left = 7
      else return ''
      
      right = url.indexOf('/', left)
      if(right > 0) return url.substring(left, right)
      else return ''
    }

    public function get flashVars():Object {
      if(!_root.stage.hasOwnProperty('loaderInfo')) return {};
      return LoaderInfo(_root.stage.loaderInfo).parameters;
    }

    public function log(msg:Object):void {
      trace(msg.toString());
      ExternalInterface.call("window.conole.log", msg.toString());
    }

    public function logObject(object:Object):void {
      var msg = object.toString();
      for (var key in object) {
        msg += "\n  " + key + ": " + object[key];
      }
      if (!msg) msg = "[empty Object]";
      log(msg);
    }
    
  }
  
}
