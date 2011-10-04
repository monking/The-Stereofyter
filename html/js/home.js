function loadMixblendr() {
	embedMixblendr( {
		containerId: "mbapp",
		id: "mixblendr",
		code: "com/mixblendr/gui/main/Applet",
		archive: "mixblendr/mixblendr.jar?TIMESTAMP="+(new Date()).getTime(),
/*
		width: 1,
		height: 1,
*/
		width: 1,
		height: 1,
		params: {
			url: "mixblendr/competition/getfile",
			REDIRECT_URL: "mixblendr/competition/competition-entries/",
			DEFAULT_TEMPO: "120.0"
		}
	} );
};
var flashvars = {
	sampleListUrl:"scripts/samples.json.php",
	countryListUrl:"js/country_codes.json",
	saveUrl:"scripts/save_mix.php",
	loadUrl:"scripts/load_mix.php",
	registerUrl:"scripts/register.php",
	demoMixUrl:"audio/mixes/demo_mix_01.mp3"
};
var attributes = {
	menu: "false"
};
swfobject.embedSWF(
	"swf/main.swf",
	"sfapp",
	"100%",
	"100%",
	"9.0.0",
	"swf/expressInstall.swf",
	flashvars,
	null,
	attributes,
	function(e){
		e.success && mbinterface.addEventListenerObject(e.ref);
	}
);
function alertAsync(msg) {
	setTimeout(function(){
		alert(msg);
	},0);
}
