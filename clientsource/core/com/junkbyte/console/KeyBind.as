package com.junkbyte.console
{
   public class KeyBind
   {
      
      private var _code:Boolean;
      
      private var _key:String;
      
      public function KeyBind(param1:*, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false, param5:Boolean = false)
      {
         super();
         this._key = String(param1).toUpperCase();
         if(param1 is uint)
         {
            this._code = true;
         }
         else if(!param1 || this._key.length != 1)
         {
            throw new Error("KeyBind: character (first char) must be a single character. You gave [" + param1 + "]");
         }
         if(this._code)
         {
            this._key = "keycode:" + this._key;
         }
         if(param2)
         {
            this._key += "+shift";
         }
         if(param3)
         {
            this._key += "+ctrl";
         }
         if(param4)
         {
            this._key += "+alt";
         }
         if(param5)
         {
            this._key += "+up";
         }
      }
      
      public function get useKeyCode() : Boolean
      {
         return this._code;
      }
      
      public function get key() : String
      {
         return this._key;
      }
   }
}

