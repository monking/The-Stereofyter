package org.stereofyte.mixblendr {
  
  import flash.events.*;
  import flash.external.ExternalInterface;
  
  public class MixBlendrInterface extends Object {
    
    private var jsBridgeName;
    public function MixBlendrInterface(jsBridgeName) {
      this.jsBridgeName = jsBridgeName;
    }

    public function call(method, ... arguments) {
      trace("calling " + method);
      ExternalInterface.call(this.jsBridgeName+'.'+method, arguments);
    }
    
  }
  
}
