package com.adobe.protocols.dict
{
   public class MatchStrategy
   {
      
      private var _name:String;
      
      private var _description:String;
      
      public function MatchStrategy(param1:String, param2:String)
      {
         super();
         this._name = param1;
         this._description = param2;
      }
      
      public function set name(param1:String) : void
      {
         this._name = param1;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function set description(param1:String) : void
      {
         this._description = param1;
      }
      
      public function get description() : String
      {
         return this._description;
      }
   }
}

