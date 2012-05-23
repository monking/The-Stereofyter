package org.stereofyter.mixblendr {
	
	import com.chrislovejoy.utils.Debug;
	
	import flash.events.*;
	import flash.external.ExternalInterface;
	
	public class MixblendrInterface extends EventDispatcher {
		
		public var data;

		private var jsBridgeName;

		public function MixblendrInterface():void {
			ExternalInterface.addCallback("dispatchMBEvent", dispatchMBEvent);
			addEventListener("ready", onready);
		//check();
		}

		public function call(method, ... arguments):* {
			//trace("calling on MixBlendr: " + method);
			switch (arguments.length) {
				case 0:
					return ExternalInterface.call(jsBridgeName+'.'+method);
					break;
				case 1:
					return ExternalInterface.call(jsBridgeName+'.'+method, arguments[0]);
					break;
				case 2:
					return ExternalInterface.call(jsBridgeName+'.'+method, arguments[0], arguments[1]);
					break;
				case 3:
					return ExternalInterface.call(jsBridgeName+'.'+method, arguments[0], arguments[1], arguments[2]);
					break;
				case 4:
					return ExternalInterface.call(jsBridgeName+'.'+method, arguments[0], arguments[1], arguments[2], arguments[3]);
					break;
				case 5:
					return ExternalInterface.call(jsBridgeName+'.'+method, arguments[0], arguments[1], arguments[2], arguments[3], arguments[4]);
					break;
				default:
					//trace("method '"+method+"' could not be called because it had more than the supported 5 arguments");
					return undefined;
			}
		}
	
		public function check():void {
			!ready && ExternalInterface.call("checkMixblendr");
		}
		
		public function get ready():Boolean {
			return !!jsBridgeName;
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
