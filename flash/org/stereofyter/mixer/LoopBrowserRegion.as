package org.stereofyter.mixer {
	
	import com.chrislovejoy.utils.Debug;
	import com.chrislovejoy.utils.StringUtils;
	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.None;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.stereofyter.gui.*;

	public class LoopBrowserRegion extends MovieClip {

		public static const
			ADD = "loopbrowser_region_add",
			REMOVE = "loopbrowser_region_remove",
			BUTTON_OVER = "button_over",
			BUTTON_OUT = "button_out";

		private static const
			SEEK_BOUNDS:Rectangle = new Rectangle(56, 36, 416, 0);

		public var
			regionIndex:int = -1,
			tooltipMessage:String;

		private var
			_sample:Sample,
			icon:InstrumentIcon,
			_seek:Number = 0,
			_inUse:Boolean = false;

		public function LoopBrowserRegion(sample:Sample):void {
			this._sample = sample;
			/*
			 * Region is a drag-and-drop element that snaps to the mixer track grid.
			 * contains
			 *	seek slider
			 *	"solo" button
			 *	mute buton
			 *	"x" delete button
			 *	symbol for sample instrument
			 */
			this.name = _sample.src;
			label_title.text = /*_sample.artist + " - " + */_sample.title;
			label_bpm.text = 'tempo: ' + _sample.tempo + " BPM";
			label_key.text = 'key: ' + _sample.key.replace(/^\*$/, 'any');
			label_length.text = _sample.beats + ' beats ' + StringUtils.formatMilliseconds(_sample.duration, '(%m:%S)');
			draw();
			setUsed(false);
			attachBehaviors();
		}
		
		public function setUsed(used:Boolean):void {
			label_title.text = /*_sample.artist + " - " + */_sample.title + (used ? ' (already in your bin)' : '');
			background.gotoAndStop(used ? 'gray' : _sample.family);
			buttonAdd.gotoAndStop(used ? 'minus' : 'plus');
			_inUse = used;
		}
	
		public function get beats():int {
			return _sample.beats;
		}
		
		public function get duration():Number {
			return _sample.duration;
		}

		public function get sample():Sample {
			return _sample;
		}

		private function attachBehaviors():void {
			/*
			 * Preview
			 */
			buttonPreview.gotoAndStop('play');
			addTooltip(buttonPreview, "Play");
			buttonPreview.addEventListener(MouseEvent.CLICK, function(event) {
				_sample.dispatchEvent(new Event(Sample.PREVIEW_TOGGLE, true));
			});
			/*
			 * Add
			 */
			buttonAdd.gotoAndStop('plus');
			addTooltip(buttonAdd, "Add to My Bin");
			buttonAdd.addEventListener(MouseEvent.CLICK, function(event) {
				dispatchEvent(new Event(_inUse ? REMOVE : ADD, true));
			});
		}

		public function addTooltip(object:DisplayObject, message:String):void {
			object.addEventListener(MouseEvent.MOUSE_OVER, function(event:MouseEvent) {
				tooltipMessage = message;
				dispatchEvent(new Event(BUTTON_OVER, true));
			});
			object.addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent) {
				dispatchEvent(new Event(BUTTON_OUT, true));
			});
		}

		private function draw():void {
			background.filters = [new DropShadowFilter(3, 90, 0, 0.5)];
			icon = new InstrumentIcon();
			icon.gotoAndStop(_sample.family);
			addChild(icon);
			icon.x = 4;
			icon.y = 25 - icon.height / 2;
			icon.mouseEnabled = false;
			icon.mouseChildren = false;
		}

	}

}
