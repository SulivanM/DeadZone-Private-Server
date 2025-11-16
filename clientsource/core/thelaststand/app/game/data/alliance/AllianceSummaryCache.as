package thelaststand.app.game.data.alliance
{
   import flash.utils.Dictionary;
   
   public class AllianceSummaryCache
   {
      
      private static var _instance:AllianceSummaryCache;
      
      private var _internalObjects:Dictionary = new Dictionary();
      
      public function AllianceSummaryCache(param1:AllianceSummaryCacheSingletonEnforcer)
      {
         super();
         if(!param1)
         {
            throw new Error("AllianceSummaryCache is a Singleton and cannot be directly instantiated. Use AllianceSummaryCache.getInstance().");
         }
      }
      
      public static function getInstance() : AllianceSummaryCache
      {
         if(!_instance)
         {
            _instance = new AllianceSummaryCache(new AllianceSummaryCacheSingletonEnforcer());
         }
         return _instance;
      }
      
      public function getSummary(param1:String, param2:Function, param3:Boolean = false) : void
      {
         var _loc4_:AllianceCacheInternalObject = this._internalObjects[param1];
         if(_loc4_ == null)
         {
            _loc4_ = new AllianceCacheInternalObject(param1);
            this._internalObjects[param1] = _loc4_;
         }
         _loc4_.request(param2,param3);
      }
      
      public function getExistingSummary(param1:String) : AllianceDataSummary
      {
         var _loc2_:AllianceCacheInternalObject = this._internalObjects[param1];
         if(_loc2_ == null)
         {
            return null;
         }
         return _loc2_.data;
      }
      
      public function hasSummary(param1:String) : Boolean
      {
         var _loc2_:AllianceCacheInternalObject = this._internalObjects[param1];
         if(_loc2_ == null || _loc2_.data == null)
         {
            return false;
         }
         return true;
      }
   }
}

import flash.utils.getTimer;
import playerio.DatabaseObject;
import playerio.PlayerIOError;
import thelaststand.app.network.Network;

class AllianceSummaryCacheSingletonEnforcer
{
   
   public function AllianceSummaryCacheSingletonEnforcer()
   {
      super();
   }
}

class AllianceCacheInternalObject
{
   
   private static const EXPIRE_TIME:int = 10 * 60 * 1000;
   
   public var id:String;
   
   public var timestamp:int = 0;
   
   public var isloading:Boolean = false;
   
   public var requests:Array = [];
   
   public var data:AllianceDataSummary;
   
   public function AllianceCacheInternalObject(param1:String)
   {
      super();
      this.id = param1;
   }
   
   public function request(param1:Function, param2:Boolean) : void
   {
      var callback:Function = param1;
      var force:Boolean = param2;
      this.requests.push(callback);
      if(this.timestamp < getTimer() || force == true || this.data == null && this.isloading == false)
      {
         this.timestamp = getTimer();
         this.isloading = true;
         Network.getInstance().client.bigDB.load("AllianceSummary",this.id,function(param1:DatabaseObject):void
         {
            onLoadComplete(param1);
         },function(param1:PlayerIOError):void
         {
            onLoadComplete(null);
         });
      }
      else
      {
         this.processRequests();
      }
   }
   
   private function onLoadComplete(param1:DatabaseObject) : void
   {
      var loadedData:DatabaseObject = param1;
      this.isloading = false;
      this.timestamp = getTimer() + EXPIRE_TIME;
      if(loadedData != null)
      {
         if(this.data == null)
         {
            this.data = new AllianceDataSummary(this.id);
         }
         try
         {
            this.data.deserialize(loadedData);
         }
         catch(error:Error)
         {
            data = null;
         }
      }
      this.processRequests();
   }
   
   private function processRequests() : void
   {
      var _loc1_:Function = null;
      while(this.requests.length > 0)
      {
         _loc1_ = this.requests.shift();
         if(_loc1_ != null)
         {
            _loc1_(this.data);
         }
      }
   }
}
