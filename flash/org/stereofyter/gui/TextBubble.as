package org.stereofyter.gui {
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class TextBubble extends Sprite {
		
		private var
			options:Object,
			label:TextField,
			format:TextFormat;
		
		public function TextBubble(options:Object):void {
			this.options = {
				padding: 15,
				borderRadius: 7,
				width: "auto",
				fontSize: 14,
				fontFamily: "_sans",
				color: 0x000000,
				backgroundColor: 0xEEEEEE,
				textAlign: TextFormatAlign.LEFT,
				url: null,
				fontWeight: "normal",
				fontStyle: "none",
				textDecoration: "none",
				multiline: true,
				shadow: true
			};
			for (var key:String in options) {
				this.options[key] = options[key];
			}
			label = new TextField();
			addChild(label);
			label.multiline = options.multiline;
			format = new TextFormat(options.fontFamily, options.fontSize, options.color, (options.fontWeight == 'bold'), (options.fontStyle == "italic"), (options.textDecoration == "underline"), options.url, options.target, options.textAlign);
			draw();
		}
		
		public function set text(newText:String):void {
			label.text = newText;
			draw();
		}
		
		public function get text():String {
			return label.text;
		}
		
		private function draw():void {
			label.setTextFormat(format);
			label.x = options.padding;
			label.y = options.padding;
			if (isNaN(options.width)) {
				label.autoSize = TextFieldAutoSize.LEFT;
			} else {
				label.width = options.width;
			}
			graphics.clear();
			graphics.beginFill(options.backgroundColor);
			graphics.drawRoundRect(0, 0, label.width + options.padding * 2, label.height + options.padding * 2, options.borderRadius * 2, options.borderRadius * 2);
			graphics.endFill();
			if (options.shadow) {
				this.filters = [new DropShadowFilter(4, 90, 0, 0.5, 20, 20)];
			}
		}

	}

}
