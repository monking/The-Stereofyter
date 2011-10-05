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