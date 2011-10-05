package org.stereofyter.gui {

	import com.chrislovejoy.WebAppController;
	import com.chrislovejoy.audio.MP3Stream;
	import com.chrislovejoy.util.Debug;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class StereofyterSite extends Sprite {
		
		public static const
			SHOW_NEWSLETTER:String = "show_newsletter",
			SHOW_ABOUT:String = "show_about",
			SAVE_MIX:String = "save_mix";

		public var
			foreground:Sprite,
			midground:Sprite,
			background:Sprite,
			backdrop:SFBackground,
			nav:SFNavBar,
			info:SiteInfoPane,
			newsletterSignup:NewsletterSignup,
			logo:StereofyterLogo,
			navWidth:Number = 1000,
			demoMix:MP3Stream;
		
		private var
			previewButtons:SiteButtons,
			alertBubble:TextBubble;
		
		public function StereofyterSite():void {
			background = new Sprite();
			midground = new Sprite();
			foreground = new Sprite();
			addChild(background);
			addChild(midground);
			addChild(foreground);
			backdrop = new SFBackground();
			background.addChild(backdrop);
			newsletterSignup = new NewsletterSignup();
			foreground.addChild(newsletterSignup);
			addSiteInfoPane();
			nav = new SFNavBar();
			foreground.addChild(nav);
			demoMix = new MP3Stream();
			addPreviewButtons();
			logo = new StereofyterLogo();
			background.addChild(logo);
			alertBubble = new TextBubble({
				textAlign: "center",
				fontSize: 16,
				fontFamily: "Helvetica_Medium",
				padding: 20,
				borderRadius: 10
			});
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
			logo.x = 50;
			logo.y = 20;
			previewButtons.x = stage.stageWidth / 2 + 350;
			previewButtons.y = 40;
			info.x = stage.stageWidth / 2 - info.width / 2;
			newsletterSignup.x = stage.stageWidth / 2 - newsletterSignup.width / 2;
			alertBubble.x = stage.stageWidth / 2 - alertBubble.width / 2;
			alertBubble.y = stage.stageHeight/ 2 - alertBubble.height / 2;
		}
		
		public function showSiteInfoPane():void {
			info.visible = true;
			info.gotoAndPlay("show");
		}
		
		public function hideSiteInfoPane():void {
			if (!info.visible) return;
			info.gotoAndPlay("hide");
			stage.focus = stage;
		}
		
		public function toggleSiteInfoPane():void {
			info.visible? hideSiteInfoPane(): showSiteInfoPane();
		}
		
		public function showNewsletterSignup():void {
			newsletterSignup.show();
		}
		
		public function hideNewsletterSignup():void {
			newsletterSignup.hide();
			stage.focus = stage;
		}
		
		public function toggleNewsletterSignup():void {
			newsletterSignup.toggle();
		}
		
		public function alert(message:String):void {
			alertBubble.text = message;
			addChild(alertBubble);
			if (stage) {
				alertBubble.x = stage.stageWidth / 2 - alertBubble.width / 2;
				alertBubble.y = stage.stageHeight/ 2 - alertBubble.height / 2;
			}
		}
		
		public function hideAlert():void {
			if (contains(alertBubble)) removeChild(alertBubble);
		}
		
		private function addPreviewButtons():void {
			previewButtons = new SiteButtons();
			midground.addChild(previewButtons);
			var buttonData:Object = {
				"About":{
					"label":"ABOUT",
					"action":function(event:MouseEvent) {
						dispatchEvent(new Event(StereofyterSite.SHOW_ABOUT, true));
					}
				},
				"Connect":{
					"label":"NEWSLETTER",
					"action":function(event:MouseEvent) {
						dispatchEvent(new Event(StereofyterSite.SHOW_NEWSLETTER, true));
					}
				},
				"Save":{
					"label":"SAVE",
					"action":function(event:MouseEvent) {
						dispatchEvent(new Event(StereofyterSite.SAVE_MIX, true));
					}
				},
				"Login":null,
				"Demo":{
					"label":"DEMO",
					"action":function(event:MouseEvent) {
						if (!demoMix.bytesTotal)
							demoMix.load(WebAppController.flashVars.demoMixUrl);
						if (demoMix.isPlaying) {
							demoMix.pause();
							previewButtons.buttonDemo.button.gotoAndStop("paused");
						} else {
							demoMix.play();
							previewButtons.buttonDemo.button.gotoAndStop("playing");
						}
					}
				}
			};
			for (var name:String in buttonData) {
				var button:MovieClip = previewButtons["button"+name];
				if (!buttonData[name]) {
					previewButtons.removeChild(button);
					continue;
				}
				button.tooltip.label.text = buttonData[name].label;
				button.tooltip.mouseEnabled = false;
				button.tooltip.mouseChildren = false;
				if (button.symbol) {
					button.symbol.gotoAndStop(name);
					button.symbol.mouseEnabled = false;
				} else {
					button.button.buttonMode = true;
				}
				button.tooltip.mouseChildren = false;
				button.tooltip.visible = false;
				button.button.addEventListener(MouseEvent.CLICK, buttonData[name].action);
				button.button.addEventListener(MouseEvent.MOUSE_OVER, function(event:MouseEvent) {
					event.currentTarget.parent.tooltip.visible = true;
				});
				button.button.addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent) {
					event.currentTarget.parent.tooltip.visible = false;
				});
			}
			// move buttonDemo to bottom
			var demo = previewButtons.buttonDemo;
			previewButtons.removeChild(demo);
			demo.y = previewButtons.height + 20;
			previewButtons.addChild(demo);
			
			demoMix.addEventListener(Event.SOUND_COMPLETE, function(event:Event) {
				previewButtons.buttonDemo.button.gotoAndStop("paused");
			});
		}
		
		private function addSiteInfoPane():void {
			info = new SiteInfoPane();
			info.visible = false;
			foreground.addChild(info);
			info.newsletterButton.addEventListener(MouseEvent.CLICK, function() {
				dispatchEvent(new Event(StereofyterSite.SHOW_NEWSLETTER, true));
			});
			info.closeButton.addEventListener(MouseEvent.CLICK, function() {
				hideSiteInfoPane();
			});
		}
		
	}
	
}
