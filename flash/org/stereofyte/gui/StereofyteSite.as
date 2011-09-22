package org.stereofyte.gui {
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class StereofyteSite extends Sprite {

		public var
			foreground:Sprite,
			midground:Sprite,
			background:Sprite,
			backdrop:SFBackground,
			nav:SFNavBar,
			info:SiteInfoPane,
			logo:StereofyterLogo,
			navWidth:Number = 1000;
		
		private var
			previewButtons:SiteButtons;
		
		public function StereofyteSite():void {
			background = new Sprite();
			midground = new Sprite();
			foreground = new Sprite();
			addChild(background);
			addChild(midground);
			addChild(foreground);
			backdrop = new SFBackground();
			background.addChild(backdrop);
			addSiteInfoPane();
			nav = new SFNavBar();
			foreground.addChild(nav);
			addPreviewButtons();
			logo = new StereofyterLogo();
			foreground.addChild(logo);
			addEventListener(Event.ADDED_TO_STAGE, function(event) {
				stage.addEventListener(Event.RESIZE, resize);
				resize();
			});
		}

		public function resize(event:Event = null):void {
			backdrop.width = stage.stageWidth;
			backdrop.height = stage.stageHeight;
			nav.x = stage.stageWidth / 2 - navWidth / 2;
			nav.y = -32;
			logo.x = 20;
			logo.y = 20;
			previewButtons.x = stage.stageWidth / 2 + 350;
			previewButtons.y = 90;
			info.x = stage.stageWidth / 2 - info.width / 2;
		}
		
		public function showSiteInfoPane():void {
			info.visible = true;
			info.gotoAndPlay("show");
		}
		
		public function hideSiteInfoPane():void {
			if (!info.visible) return;
			info.gotoAndPlay("hide");
		}
		
		private function addPreviewButtons():void {
			previewButtons = new SiteButtons();
			midground.addChild(previewButtons);
			var buttonData:Object = {
				"About":{
					"label":"ABOUT",
					"action":function(event:MouseEvent) {
						dispatchEvent(new Event("SHOW_ABOUT", true));
					}
				},
				"Connect":{
					"label":"NEWSLETTER",
					"action":function(event:MouseEvent) {
						dispatchEvent(new Event("SHOW_NEWSLETTER_SIGNUP", true));
					}
				},
				"Save":null,
				"Login":null
			};
			for (var name:String in buttonData) {
				var button:MovieClip = previewButtons["button"+name];
				if (!buttonData[name]) {
					button.visible = false;
					continue;
				}
				button.tooltip.label.text = buttonData[name].label;
				button.tooltip.mouseEnabled = false;
				button.tooltip.mouseChildren = false;
				button.symbol.gotoAndStop(name);
				button.symbol.mouseEnabled = false;
				button.tooltip.mouseChildren = false;
				button.tooltip.visible = false;
				button.button.addEventListener(MouseEvent.CLICK, buttonData[name].action);
				button.button.addEventListener(MouseEvent.MOUSE_OVER, function(event:MouseEvent) {
					event.target.parent.tooltip.visible = true;
				});
				button.button.addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent) {
					event.target.parent.tooltip.visible = false;
				});
			}
		}
		
		private function addSiteInfoPane():void {
			info = new SiteInfoPane();
			info.visible = false;
			foreground.addChild(info);
			info.newsletterButton.addEventListener(MouseEvent.CLICK, function() {
				hideSiteInfoPane();
				dispatchEvent(new Event("SHOW_NEWSLETTER_SIGNUP", true));
			});
			info.closeButton.addEventListener(MouseEvent.CLICK, function() {
				hideSiteInfoPane();
			});
		}
		
	}
	
}
