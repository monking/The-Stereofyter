package com.chrislovejoy.helpers {
  
  public class ArrayMath {

    public static function sum(array:Array):Number {
      var sum:Number = 0;
      for each(var value:* in array) sum += value;
      return sum;
    }

    public static function min(array:Array):Number {
      var min:Number = array[0];
      for each(var value:* in array) min = Math.min(min, value);
      return min;
    }

    public static function max(array:Array):Number {
      var max:Number = 0;
      for each(var value:* in array) max = Math.max(max, value);
      return max;
    }

  }

}
