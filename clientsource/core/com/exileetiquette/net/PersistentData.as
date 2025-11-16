package com.exileetiquette.net
{
   import flash.events.NetStatusEvent;
   import flash.net.SharedObject;
   
   public class PersistentData
   {
      
      private var _data:Object;
      
      private var _saveToDisk:Boolean = true;
      
      private var _sharedObject:SharedObject;
      
      private var _sharedObjectName:String;
      
      public var minDiskSpace:int = 10240;
      
      public function PersistentData()
      {
         super();
         this._data = {};
      }
      
      public function clearData() : void
      {
         if(this._sharedObject)
         {
            this._sharedObject.clear();
         }
         this._data = {};
      }
      
      public function isSet(param1:String) : Boolean
      {
         return param1 in this._data;
      }
      
      public function getData(param1:String, param2:* = null) : *
      {
         if(!this._sharedObjectName)
         {
            throw new Error("No SharedObject name supplied.");
         }
         if(this._data[param1])
         {
            return this._data[param1];
         }
         if(Boolean(this._sharedObject) && this._sharedObject.data[param1] != null)
         {
            return this._sharedObject.data[param1];
         }
         return param2;
      }
      
      public function setData(param1:String, param2:*, param3:Boolean = true) : void
      {
         if(!this._sharedObjectName)
         {
            throw new Error("No SharedObject name supplied.");
         }
         this._data[param1] = param2;
         if(this._saveToDisk && Boolean(this._sharedObject))
         {
            this._sharedObject.data[param1] = param2;
            if(param3)
            {
               this.flush();
            }
         }
      }
      
      public function flush() : void
      {
         if(!this._saveToDisk || !this._sharedObject)
         {
            return;
         }
         this._sharedObject.flush(this.minDiskSpace);
      }
      
      public function traceData() : void
      {
         var _loc2_:String = null;
         var _loc1_:* = "-- PersistenData::traceData --\r";
         if(this._sharedObject)
         {
            for(_loc2_ in this._sharedObject.data)
            {
               _loc1_ += "  " + _loc2_ + " = " + this._data[_loc2_] + "\r";
            }
         }
         else
         {
            _loc1_ += "[!] No SharedObject name has been set\r";
         }
         _loc1_ += "----------------------------------";
      }
      
      private function onFlushStatus(param1:NetStatusEvent) : void
      {
         switch(param1.info.code)
         {
            case "SharedObject.Flush.Success":
               this._saveToDisk = true;
               break;
            case "SharedObject.Flush.Failed":
               this._saveToDisk = false;
         }
      }
      
      public function get sharedObjectName() : String
      {
         return this._sharedObjectName;
      }
      
      public function set sharedObjectName(param1:String) : void
      {
         var _loc2_:String = null;
         this._sharedObjectName = param1;
         this._sharedObject = SharedObject.getLocal(this._sharedObjectName,"/");
         this._sharedObject.addEventListener(NetStatusEvent.NET_STATUS,this.onFlushStatus,false,0,true);
         if(this._sharedObject)
         {
            for(_loc2_ in this._sharedObject.data)
            {
               this._data[_loc2_] = this._sharedObject.data[_loc2_];
            }
         }
      }
   }
}

