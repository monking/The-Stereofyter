/*
 * © Copyright 2011 Stereofyte.org
 * written by Christopher Lovejoy lovejoy.chris@gmail.com
 * -----------
 * implements javaobject.js
 */
var MixBlendrInterface = function(options) {
  this.applet = JavaEmbed(options);
  this.init();
};

MixBlendrInterface.prototype = {
  init:function() {
    //this.mixblendr = this.applet.MixBlendr;
  },
  test:function(msg) {
    alert(this.applet.testConn(msg));
  },
  play:function() {
    alert("mb_play");
  },
  seek:function(time) {
    alert("mb_seek to " + time);
  },
  pause:function() {
    alert("mb_pause");
  },
  stop:function() {
    alert("mb_stop");
  },
  moveSample:function(id, place) {
    alert("mb_move");
  },
  loadDefaultSong:function() {
    this.applet.loadDefaultSong();
  }
};
