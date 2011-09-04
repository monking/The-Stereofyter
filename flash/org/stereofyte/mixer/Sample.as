package org.stereofyte.mixer {

  public class Sample extends Object {
    
    public static const
      FAMILY_BRASS = "brass",
      FAMILY_DRUM = "drum",
      FAMILY_VOCAL = "vocal",
      FAMILY_STRINGS = "vocal",
      FAMILY_GUITAR = "guitar";
    
    private var
      data:Object;

    /**
     * Sample contains references to a sound file, and properties such as
     * duration, key and tempo
     * @data data to override defaults
     */
    public function Sample(data:Object):void {
      this.data = {
        src:"",
        family:Sample.FAMILY_VOCAL,
        name:"<no name>",
        key:"C+",
        bpm:90,
        duration:6000
      };
      for (var param in this.data) {
        if (data.hasOwnProperty(param))
          this.data[param] = data[param];
      }
    }

    /**
     * play sample preview
     */
    public function play():void {
      /* play audio from file */
    }

    /**
     * get audio file source path
     */
    public function get src():String {
      return data.src;
    }

    /**
     * get name of the family of this sample
     */
    public function get family():String {
      return data.family;
    }

    /**
     * get the chromatic key of this sample
     */
    public function get key():String {
      return data.key;
    }

    /**
     * get beats per minute
     */
    public function get bpm():Number {
      return data.bpm;
    }

    /**
     * get name
     */
    public function get name():String {
      return data.name;
    }

    /**
     * get duration in seconds
     */
    public function get duration():Number {
      return data.duration;
    }

  }

}
