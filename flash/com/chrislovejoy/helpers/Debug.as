package com.chrislovejoy.helpers {
  
  import flash.display.DisplayObject
  import flash.external.ExternalInterface;
  import flash.utils.getQualifiedClassName;
  
  public class Debug {

    public static var
      on:Boolean = false;

    public static function log(object:Object, objectName:String = "", showAlways:Boolean = false):void {
      if (!on && !showAlways) return
      if (!objectName) objectName = getQualifiedClassName(object);
      var msg = objectName + ": " + object.toString(); 
      trace(msg);
      ExternalInterface.call("console.log", msg);
    }

    public static function deepLog(object:Object, objectName:String = "", showAlways:Boolean = false):void {
      if (!on && !showAlways) return
      if (!objectName) objectName = "deepLog";

      function descend(object:Object, indent:String = ""):String {
        var msg:String = getQualifiedClassName(object) + " {";
        for (var key in object) {
          msg += "\n  " + indent + key + ": ";
          if (typeof object[key] == "object")
            msg += descend(object[key], indent + "  ");
          else
            msg += object[key].toString();
        }
        msg += "\n" + indent + "}";
        return msg;
      }

      log(descend(object), objectName);
    }

  }

}
