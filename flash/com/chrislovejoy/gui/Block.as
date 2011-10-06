package com.chrislovejoy.gui {
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import com.chrislovejoy.utils.Debug;

	public class Block extends Sprite {
		
		public static const
			CLOSE:String = "shadowblock_close";
		
		private var
			options:Object,
			label:TextField,
			format:TextFormat,
			holder:Sprite,
			close:CornerCloseButton,
			timeoutTimer:Timer;
		
		public function Block(newOptions:Object, content:* = null):void {
			options = {
				padding: 15,
				borderRadius: 7,
				width: "auto",
				fontSize: 14,
				fontFamily: "_sans",
				color: 0x000000,
				backgroundColor: 0xFFFFFF,
				textAlign: TextFormatAlign.LEFT,
				url: null,
				fontWeight: "normal",
				fontStyle: "none",
				textDecoration: "none",
				multiline: true,
				shadow: true,
				timeout: 0,
				close: "top right"
			};
			holder = new Sprite();
			addChild(holder);
			newOptions&& setOptions(newOptions, false);
			content !== null && setContent(content);
		}
		
		public function setOptions(newOptions:Object, redraw:Boolean = true):void {
			for (var key:String in newOptions) {
				options[key] = newOptions[key];
			}
			if (!format) format = new TextFormat();
			format.font = options.fontFamily;
			format.size = options.fontSize;
			format.color = options.color;
			format.bold = (options.fontWeight == 'bold');
			format.italic = (options.fontStyle == "italic");
			format.underline = (options.textDecoration == "underline")
			format.align = options.textAlign;
			if (options.url) format.url = options.url;
			if (options.target) format.target = options.target;
			redraw && draw();
		}
		
		public function setContent(content:*, append:Boolean = false):void {
			if (!append) clearHolder();
			if (content is DisplayObject) {
				holder.addChild(content);
			} else {
				if (!label) {
					label = new TextField();
					label.defaultTextFormat = format;
				}
				if (!holder.contains(label)) {
					holder.addChild(label);
				}
				append? label.appendText(content): (label.text = content);
			}
			draw();
		}
		
		public function addContent(content:*):void {
			setContent(content, true);
		}
		
		public function get content():DisplayObject{
			return (!label || !holder.contains(label)) && holder.numChildren?
				holder.getChildAt(0):
				null;
		}
		
		public function get text():String {
			return label && holder.contains(label)? label.text: "";
		}
		
		public function get innerWidth():Number {
			return holder.width;
		}
		
		public function get innerHeight():Number {
			return holder.height;
		}
		
		private function draw():void {
			if (label && holder.contains(label)) {
				label.multiline = options.multiline;
				label.setTextFormat(format);
				label.embedFonts = format.font && !/_sans|_serif/.test(format.font);
				if (isNaN(options.width)) {
					label.autoSize = TextFieldAutoSize.LEFT;
				} else {
					label.width = options.width;
				}
			}
			holder.x = options.padding;
			holder.y = options.padding;
			var totalWidth:Number = holder.width + options.padding * 2;
			var totalHeight:Number = holder.height+ options.padding * 2;
			if (options.close != "none") {
				if (!close) {
					close = new CornerCloseButton();
					close.buttonMode = true;
					close.addEventListener(MouseEvent.CLICK, function(event:MouseEvent) {
						dispatchEvent(new Event(Block.CLOSE, true));
					});
				}
				addChild(close);
				close.x = /right/.test(options.close)? totalWidth: 0;
				close.y = /bottom/.test(options.close)? totalHeight: 0;
			} else if (close && contains(close)) removeChild(close);
			graphics.clear();
			graphics.beginFill(options.backgroundColor);
			graphics.drawRoundRect(0, 0, totalWidth, totalHeight, options.borderRadius * 2, options.borderRadius * 2);
			graphics.endFill();
			if (options.shadow) {
				this.filters = [new DropShadowFilter(4, 90, 0, 0.5, 20, 20)];
			}
			if (options.timeout > 0) {
				if (timeoutTimer) timeoutTimer.stop(); 
				timeoutTimer = new Timer(options.timeout, 1);
				timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent) {
					dispatchEvent(new Event(Block.CLOSE, true));
				});
				timeoutTimer.start();
			} else if (timeoutTimer) timeoutTimer.stop(); 
		}
		
		private function clearHolder():void {
			while (holder.numChildren) holder.removeChildAt(0);
		}

	}

}
