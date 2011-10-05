package com.chrislovejoy {
	
	import com.chrislovejoy.utils.Debug;
	
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.external.ExternalInterface;
	
	public class WebAppController {
		
		protected static var
			FlashVars:Object = {};

		protected var
			_root:DisplayObject;

		public function WebAppController(root:DisplayObject, debug:Boolean = false) {
			_root = root;
			Debug.on = debug;
			if(_root.stage.hasOwnProperty('loaderInfo')) {
				FlashVars = LoaderInfo(_root.stage.loaderInfo).parameters; 
			}
		}
		
		public static function get flashVars():Object {
			return FlashVars;
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
		
	}
	
}
