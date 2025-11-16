package com.gskinner.utils
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.net.LocalConnection;
   
   public class SWFBridgeAS3 extends EventDispatcher
   {
      
      private var baseID:String;
      
      private var myID:String;
      
      private var extID:String;
      
      private var lc:LocalConnection;
      
      private var _connected:Boolean = false;
      
      private var host:Boolean = true;
      
      private var clientObj:Object;
      
      public function SWFBridgeAS3(param1:String, param2:Object)
      {
         var p_id:String = param1;
         var p_clientObj:Object = param2;
         super();
         this.baseID = p_id.split(":").join("");
         this.lc = new LocalConnection();
         this.lc.client = this;
         this.clientObj = p_clientObj;
         try
         {
            this.lc.connect(this.baseID + "_host");
         }
         catch(e:ArgumentError)
         {
            host = false;
         }
         this.myID = this.baseID + (this.host ? "_host" : "_guest");
         this.extID = this.baseID + (this.host ? "_guest" : "_host");
         if(!this.host)
         {
            this.lc.connect(this.myID);
            this.lc.send(this.extID,"com_gskinner_utils_SWFBridge_init");
         }
      }
      
      public function send(param1:String, ... rest) : void
      {
         if(!this._connected)
         {
            throw new ArgumentError("Send failed because the object is not connected.");
         }
         rest.unshift(param1);
         rest.unshift("com_gskinner_utils_SWFBridge_receive");
         rest.unshift(this.extID);
         this.lc.send.apply(this.lc,rest);
      }
      
      public function close() : void
      {
         try
         {
            this.lc.close();
         }
         catch(e:*)
         {
         }
         this.lc = null;
         this.clientObj = null;
         if(!this._connected)
         {
            throw new ArgumentError("Close failed because the object is not connected.");
         }
         this._connected = false;
      }
      
      public function get id() : String
      {
         return this.baseID;
      }
      
      public function get connected() : Boolean
      {
         return this._connected;
      }
      
      public function com_gskinner_utils_SWFBridge_receive(param1:String, ... rest) : void
      {
         var p_method:String = param1;
         var p_args:Array = rest;
         try
         {
            this.clientObj[p_method].apply(this.clientObj,p_args);
         }
         catch(e:*)
         {
         }
      }
      
      public function com_gskinner_utils_SWFBridge_init() : void
      {
         if(this.host)
         {
            this.lc.send(this.extID,"com_gskinner_utils_SWFBridge_init");
         }
         this._connected = true;
         dispatchEvent(new Event(Event.CONNECT));
      }
   }
}

