package org.stereofyter.mixer {

  public class Sample extends Object {
    
    public static const
      FAMILY_BRASS = "brass",
      FAMILY_DRUM = "drum",
      FAMILY_VOCAL = "vocal",
      FAMILY_STRINGS = "strings",
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
		artist:"Unknown",
		country:"",
        key:"C",
        tempo:120,
        duration:4000
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
     * get tempo
     */
    public function get tempo():Number {
      return data.tempo;
    }
	
	/**
	 * get name
	 */
	public function get name():String {
		return data.name;
	}
	
	/**
	 * get name
	 */
	public function get artist():String {
		return data.artist;
	}
	
	/**
	 * get name
	 */
	public function get country():String {
		return data.country;
	}
	
	/**
	 * get duration in milliseconds
	 */
	public function get duration():Number {
		return data.duration;
	}
	
	/**
	 * get beats per loop
	 */
	public function get beats():Number {
		return data.duration*data.tempo/60000;
	}

  }

}
