package com.chrislovejoy.audio
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.media.ID3Info;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	
	public class MP3Stream
	{
		protected var
			sound:Sound,
			channel:SoundChannel,
			context:SoundLoaderContext,
			bufferTime:Number = 1000,
			IsPlaying:Boolean = false;
		
		public function MP3Stream(url:String = "", bufferTime:Number = NaN):void
		{
			sound = new Sound();
			if (url) load(url, bufferTime);
		}
		
		public function load(url:String, bufferTime:Number = NaN):void {
			stop();
			if (!isNaN(bufferTime)) this.bufferTime = bufferTime;
			context = new SoundLoaderContext(this.bufferTime);
			sound = new Sound();
			sound.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			sound.load(new URLRequest(url), context);
		}
		
		public function play(startTime:Number = NaN):void {
			if (isNaN(startTime)) startTime = position;
			if (channel) channel.stop();
			channel = sound.play(startTime);
			channel.addEventListener(Event.SOUND_COMPLETE, playbackComplete);
			IsPlaying = true;
		}
		
		public function pause():void {
			if (!channel) return;
			position; // seems that just requesting channel.position makes it persist...?
			channel.stop();
			IsPlaying = false;
		}
		
		public function stop():void {
			pause();
			channel = null;
		}
		
		public function get bytesLoaded():uint {
			return sound.bytesLoaded;
		}
		
		public function get bytesTotal():int {
			return sound.bytesTotal;
		}
		
		public function get id3():ID3Info {
			return sound.id3;
		}
		
		public function get isBuffering():Boolean{
			return sound.isBuffering;
		}
		
		public function get length():Number {
			return sound.length;
		}
		
		public function get url():String {
			return sound.url;
		}
		
		public function get position():Number{
			if (!channel) return 0;
			return channel.position;
		}
		
		public function get isPlaying():Boolean {
			return IsPlaying;
		}
		
		protected function playbackComplete(event:Event):void {
			IsPlaying = false;
			channel = null;
		}
		
		protected function onLoadProgress(event:ProgressEvent):void {
			
		}
	}
}