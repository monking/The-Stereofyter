package com.chrislovejoy.util {
  
  public function hasOwnProperties(object:Object, ...properties):Boolean {
    for each(var property:String in properties) if(!object.hasOwnProperty(property)) return false
    return true
  }
  
}