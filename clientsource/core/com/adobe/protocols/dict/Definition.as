package com.adobe.protocols.dict
{
   public class Definition
   {
      
      private var _definition:String;
      
      private var _database:String;
      
      private var _term:String;
      
      public function Definition()
      {
         super();
      }
      
      public function set definition(param1:String) : void
      {
         this._definition = param1;
      }
      
      public function get definition() : String
      {
         return this._definition;
      }
      
      public function set database(param1:String) : void
      {
         this._database = param1;
      }
      
      public function get database() : String
      {
         return this._database;
      }
      
      public function set term(param1:String) : void
      {
         this._term = param1;
      }
      
      public function get term() : String
      {
         return this._term;
      }
   }
}

