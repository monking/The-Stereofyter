<?php
header('Cache-Control: no-cache, must-revalidate');
//header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
header('Content-type: application/json; charset=utf-8');

?>
{
	"sampleRoot":"http://<?=$_SERVER['SERVER_NAME']?>/audio/samples/",
	"samples":[
		{
			"src":"African_Mist_Voice_1.ogg",
			"name":"African Mist Voice 1",
			"family":"vocal",
			"country":"South Africa",
			"tempo":"120",
			"key":"*"
		},
		{
			"src":"African_Mist_Voice_2.ogg",
			"name":"African Mist Voice 2",
			"family":"vocal",
			"country":"South Africa",
			"tempo":"120",
			"key":"*"
		},
		{
			"src":"Backroads_Banjo.ogg",
			"name":"Backroads Banjo",
			"family":"guitar",
			"country":"U.S.A.",
			"tempo":"120",
			"key":"*"
		},
		{
			"src":"Cuban_Percussion.ogg",
			"name":"Cuban Percussion",
			"family":"drum",
			"country":"Cuba",
			"tempo":"120",
			"key":"*"
		},
		{
			"src":"Djembe.ogg",
			"name":"Djembe",
			"family":"drum",
			"country":"Mali",
			"tempo":"120",
			"key":"*"
		},
		{
			"src":"Electro_Transistor_Beat.ogg",
			"name":"Electro Transistor Beat",
			"family":"drum",
			"country":"U.S.A.",
			"tempo":"120",
			"key":"*"
		},
		{
			"src":"Hip_Hop_Wakka_Guitar.ogg",
			"name":"Hip Hop Wakka Guitar",
			"family":"guitar",
			"country":"U.S.A.",
			"tempo":"120",
			"key":"*"
		},
		{
			"src":"House_Lazy_Beat.ogg",
			"name":"House Lazy Beat",
			"family":"drum",
			"country":"U.S.A.",
			"tempo":"120",
			"key":"*"
		},
		{
			"src":"Jazz_Piano.ogg",
			"name":"Jazz Piano",
			"family":"strings",
			"country":"U.S.A.",
			"tempo":"120",
			"key":"*"
		},
		{
			"src":"Cuban_Voice.ogg",
			"name":"Cuban Voice",
			"family":"vocal",
			"country":"Cuba",
			"tempo":"120",
			"key":"*"
		},
		{
			"src":"Eastern_Gold_Voice.ogg",
			"name":"Eastern Gold Voice",
			"family":"vocal",
			"country":"Egypt",
			"tempo":"120",
			"key":"*"
		},
		{
			"src":"Koto.ogg",
			"name":"Koto",
			"family":"guitar",
			"country":"Japan",
			"tempo":"120",
			"key":"*"
		},
		{
			"src":"Sine_Bass.ogg",
			"name":"Sine Bass",
			"family":"guitar",
			"country":"U.S.A.",
			"tempo":"120",
			"key":"*"
		},
		{
			"src":"Tremolo_Organ.ogg",
			"name":"Tremolo Organ",
			"family":"strings",
			"country":"U.S.A.",
			"tempo":"120",
			"key":"*"
		}
	]
}
