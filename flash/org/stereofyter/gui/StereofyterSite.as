package org.stereofyter.gui {

	import com.chrislovejoy.WebAppController;
	import com.chrislovejoy.media.MP3Stream;
	import com.chrislovejoy.gui.Block;
	import com.chrislovejoy.utils.Debug;
	
	import org.stereofyter.mixer.Mixer;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.Font;
	
	public class StereofyterSite extends Sprite {
		
		public static const
			SHOW_NEWSLETTER:String = "show_newsletter",
			SHOW_ABOUT:String = "show_about",
			REQUEST_SAVE_MIX:String = "save_mix";

		public var
			foreground:Sprite,
			midground:Sprite,
			background:Sprite,
			backdrop:SFBackground,
			nav:SFNavBar,
			loadDialog:LoadDialog,
			saveDialog:SaveDialog,
			info:SiteInfoPane,
			newsletterSignup:NewsletterSignup,
			logo:StereofyterLogo,
			navWidth:Number = 1000,
			demoMix:MP3Stream;
		
		private var
			previewButtons:SiteButtons,
			hoverBlock:Block,
			loadingWheel:SFLoadingWheel;
		
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
			loadDialog = new LoadDialog();
			foreground.addChild(loadDialog);
			saveDialog = new SaveDialog();
			foreground.addChild(saveDialog);
			addSiteInfoPane();
			nav = new SFNavBar();
			foreground.addChild(nav);
			demoMix = new MP3Stream();
			addPreviewButtons();
			logo = new StereofyterLogo();
			background.addChild(logo);
			loadingWheel = new SFLoadingWheel();
			var lightFont:Font = new Helvetica_Light();
			hoverBlock = new Block({
				padding: 20,
				borderRadius: 10,
				textAlign: "center",
				fontSize: 14,
				fontFamily: lightFont.fontName,
				backgroundColor: 0xEEEEEE,
				close: "bottom right"
			});
			hoverBlock.addEventListener(Block.CLOSE, hideHover);
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
			hoverBlock.x = stage.stageWidth / 2 - hoverBlock.width / 2;
			hoverBlock.y = stage.stageHeight/ 2 - hoverBlock.height / 2;
		}
		
		public function showSaveDialog():void {
			saveDialog.show();
		}
		
		public function hideSaveDialog():void {
			saveDialog.hide();
			stage.focus = stage;
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
		
		public function hover(content:*, options:Object = null):void {
			hoverBlock.setOptions(options, false);
			hoverBlock.setContent(content);
			if (options && options.hasOwnProperty("progress")) {
				loadingWheel.width = 30;
				loadingWheel.height = 30;
				loadingWheel.x = hoverBlock.innerWidth  / 2;
				loadingWheel.y = hoverBlock.innerHeight + 25;
				hoverBlock.addContent(loadingWheel);
			}
			midground.addChild(hoverBlock);
			if (stage) {
				hoverBlock.x = stage.stageWidth / 2 - hoverBlock.width / 2;
				hoverBlock.y = stage.stageHeight/ 2 - hoverBlock.height / 2;
			}
		}
		
		public function hideHover(event:Event = null):void {
			if (midground.contains(hoverBlock)) midground.removeChild(hoverBlock);
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
						dispatchEvent(new Event(Mixer.REQUEST_REQUEST_SAVE_MIX, true));
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
