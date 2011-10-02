/*
 * © Copyright 2011 Stereofyte.org
 * written by Christopher Lovejoy lovejoy.chris@gmail.com
 * -----------
 * implements javaobject.js
 */
window.oldAlert = window.alert;
window.alert = function(msg) {
	window.oldAlert(msg);
}
var mbinterface = {
	applet:null,
	containerId:"mbapp",
	listeners:[],
	addEventListenerObject:function(listenerObject) {
		this.listeners.push(listenerObject);
	}
};

function dispatchMBEvent(type, data) {
	if ("ready" == type) {
		if (!data) data = {};
		data.appletVarName = "mbinterface.applet";
		setMBApplet();
	}
	for (var i = 0; i < mbinterface.listeners.length; i++) {
		var listener = mbinterface.listeners[i];
		if (!listener.dispatchMBEvent) continue;
		listener.dispatchMBEvent(type, data);
	}
}

function setMBApplet() {
	var container = document.getElementById(mbinterface.containerId);
	if (!container) return;
	mbinterface.applet = container.getElementsByTagName("applet")[0]; 
}

function checkMixblendr() {
	setMBApplet();
	if (mbinterface.applet) dispatchMBEvent("ready");
}

/*
function embedMixblendr(options) {
	mbinterface.applet = JavaEmbed(options);
}
*/

function log(data) {
	if (console && console.log) console.log(data);
}
