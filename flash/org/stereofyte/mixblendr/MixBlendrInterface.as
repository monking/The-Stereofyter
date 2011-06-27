package org.stereofyte.mixblendr {
  
  import flash.events.*;
  import flash.external.ExternalInterface;
  
  public class MixblendrInterface extends EventDispatcher {
    
    public var data;

    private var jsBridgeName;

    public function MixblendrInterface():void {
      ExternalInterface.addCallback("dispatchMBEvent", dispatchMBEvent);
      addEventListener("ready", onready);
    }

    public function call(method, ... arguments):* {
      trace("calling " + method);
      switch (arguments.length) {
        case 0:
          ExternalInterface.call(jsBridgeName+'.'+method);
          break;
        case 1:
          ExternalInterface.call(jsBridgeName+'.'+method, arguments[0]);
          break;
        case 2:
          ExternalInterface.call(jsBridgeName+'.'+method, arguments[0], arguments[1]);
          break;
        case 3:
          ExternalInterface.call(jsBridgeName+'.'+method, arguments[0], arguments[1], arguments[2]);
          break;
        case 4:
          ExternalInterface.call(jsBridgeName+'.'+method, arguments[0], arguments[1], arguments[2], arguments[3]);
          break;
        case 5:
          ExternalInterface.call(jsBridgeName+'.'+method, arguments[0], arguments[1], arguments[2], arguments[3], arguments[4]);
          break;
        default:
          trace("method '"+method+"' could not be called because it had more than the supported 5 arguments");
          break;
      }
      return ExternalInterface.call(jsBridgeName+'.'+method, arguments);
    }

    protected function dispatchMBEvent(type, data):void {
      this.data = data;
      dispatchEvent(new Event(type));
    }

    protected function onready(event:Event):void {
      jsBridgeName = event.target.data.appletVarName;
    }
    
  }
  
}
