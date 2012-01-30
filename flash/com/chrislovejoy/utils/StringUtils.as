package com.chrislovejoy.utils {
	
	public class StringUtils {
		
		public static function formatMilliseconds(ms:int, format:String):String {
			var seconds:String = String(Math.round(ms / 1000) % 60);
			var minutes:String = String(Math.floor(ms / 60000) % 60);
			var hours:String = String(Math.floor(ms / 3600000) % 24);
			var days:String = String(Math.floor(ms / 86400000));
			var secondsPad = seconds.length == 1 ? "0"+seconds : seconds;
			var minutesPad = minutes.length == 1 ? "0"+minutes : minutes;
			var hoursPad = hours.length == 1 ? "0"+hours : hours;
			var daysPad = days.length == 1 ? "0"+days : days;
			format = format
				.replace(/%s/g, seconds)
				.replace(/%m/g, minutes)
				.replace(/%h/g, hours)
				.replace(/%d/g, days)
				.replace(/%S/g, secondsPad)
				.replace(/%M/g, minutesPad)
				.replace(/%H/g, hoursPad)
				.replace(/%D/g, daysPad);
			return format
		}
		
	}
	
}
