package org.stereofyter.gui {
	
	import com.adobe.serialization.json.JSON;
	import com.chrislovejoy.WebAppController;
	import com.chrislovejoy.utils.Debug;
	
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.ui.Keyboard;
	
	public class NewsletterSignup extends Sprite {
		
		private const
			WIDTH:Number = 200,
			HEIGHT:Number = 300;

		private var
			countryLoader:URLLoader,
			countries:Object,
			pane:NewsletterSignupPane,
			signupLoader:URLLoader;
		
		public function NewsletterSignup():void {
			pane = new NewsletterSignupPane();
			pane.visible = false;
			addChild(pane);
			countryLoader = new URLLoader();
			countryLoader.addEventListener(Event.COMPLETE, populateCountries);
			if (WebAppController.flashVars.countryListUrl)
				countryLoader.load(new URLRequest(WebAppController.flashVars.countryListUrl));
			signupLoader = new URLLoader();
			signupLoader.addEventListener(Event.COMPLETE, onSignupResult);
			pane.graphic.submit.addEventListener(MouseEvent.CLICK, submitForm);
			pane.graphic.closeButton.addEventListener(MouseEvent.CLICK, function() {
				hide();
			});
			pane.addEventListener(KeyboardEvent.KEY_UP, trapKeyboardEvent);
		}
		
		public function show():void {
			pane.visible = true;
			pane.gotoAndPlay("show");
			stage.focus = pane.graphic.email;
		}
		
		public function hide():void {
			if (!pane.visible) return;
			pane.gotoAndPlay("hide");
			stage.focus = stage;
		}
		
		public function toggle():void {
			pane.visible? hide(): show();
		}

		private function populateCountries(event:Event):void {
			countries = JSON.decode(countryLoader.data);
			var comboData:DataProvider = new DataProvider();
			for each(var country:Object in countries) {
				comboData.addItem({label:country.name, data:country.code});
			}
			pane.graphic.country.dataProvider = comboData;
			pane.graphic.country.selectedItem = "US";
		}
		
		private function submitForm(event:Event = null):void {
			var request:URLRequest = new URLRequest(WebAppController.flashVars.registerUrl);
			request.data = "email=" + pane.graphic.email.text
				+ "&country=" + pane.graphic.country.selectedItem.data;
			request.method = URLRequestMethod.POST;
			signupLoader.load(request);
		}
		
		private function onSignupResult(event:Event):void {
			var response:Object
			try { response = JSON.decode(signupLoader.data); } catch(e) {}
			var message:String;
			if (!response) {
				message = "There was a problem processing your request. Please try again in a moment."
			} else if (response.hasOwnProperty("error")) {
				switch (response.error) {
					case "no email": message = "Please enter your email address"; break;
					case "email exists": message = "This email address has already been registered."; break;
					case "invalid email": message = "Please check that your email address is entered correctly."; break;
					case "retry": message = "There was a problem processing your request. Please try again in a moment."; Debug.log(response.note); break;
					default: message = response.error; break;
				}
			} else if (response.status && response.status == "ok") {
				message = "Thank you for subscribing!";
				hide();
			}
			if (message) {
				ExternalInterface.call("alertAsync", message);
			}
		}
		
		private function trapKeyboardEvent(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case Keyboard.ESCAPE: hide(); break;
			}
			event.stopPropagation();
		}
		
	}
	
}
