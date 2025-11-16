package thelaststand.app.network
{
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import playerio.DatabaseObject;
   import thelaststand.app.core.Config;
   
   public class RemotePlayerManager
   {
      
      private static var _instance:RemotePlayerManager;
      
      public static const SUMMARY:uint = 1;
      
      public static const STATE:uint = 2;
      
      public static const FORCE_LOAD:uint = 4;
      
      private static const DATA_REFRESH_TIME:Number = 5 * 60 * 1000;
      
      private static const CLEANUP_KEEP_TIME:Number = 2 * 60 * 1000;
      
      private static const CLEANUP_CAP:Number = 100;
      
      private var _playersById:Dictionary = new Dictionary();
      
      private var _players:Vector.<RemotePlayerData> = new Vector.<RemotePlayerData>();
      
      private var _neighbors:Vector.<RemotePlayerData> = new Vector.<RemotePlayerData>();
      
      private var _requests:Vector.<RemotePlayerLoadRequest> = new Vector.<RemotePlayerLoadRequest>();
      
      public function RemotePlayerManager(param1:RemotePlayerManagerSingletonEnforcer)
      {
         super();
         if(!param1)
         {
            throw new Error("RemotePlayerManager is a Singleton and cannot be directly instantiated. Use RemotePlayerManager.getInstance().");
         }
      }
      
      public static function getInstance() : RemotePlayerManager
      {
         if(!_instance)
         {
            _instance = new RemotePlayerManager(new RemotePlayerManagerSingletonEnforcer());
         }
         return _instance;
      }
      
      public function updatePlayer(param1:String, param2:Object) : RemotePlayerData
      {
         var _loc3_:RemotePlayerData = this._playersById[param1];
         if(_loc3_ == null)
         {
            _loc3_ = new RemotePlayerData(param1,param2);
            this._playersById[param1] = _loc3_;
            this._players.push(_loc3_);
            this.cleanupNonEssential();
         }
         else
         {
            _loc3_.readObject(param2);
         }
         _loc3_._manualTimestamp = getTimer();
         return _loc3_;
      }
      
      public function getPlayer(param1:String) : RemotePlayerData
      {
         return this._playersById[param1];
      }
      
      public function getPlayers(param1:Array, param2:Boolean = false) : Vector.<RemotePlayerData>
      {
         var _loc4_:String = null;
         var _loc3_:Vector.<RemotePlayerData> = new Vector.<RemotePlayerData>();
         for each(_loc4_ in param1)
         {
            if(!(this._playersById[_loc4_] == null && param2 == false))
            {
               _loc3_.push(this._playersById[_loc4_]);
            }
         }
         return _loc3_;
      }
      
      public function getLoadPlayer(param1:String, param2:Function, param3:int = 1) : void
      {
         this.getLoadPlayers([param1],param2,param3);
      }
      
      public function getLoadPlayers(param1:Array, param2:Function, param3:int = 1) : void
      {
         var _loc7_:String = null;
         var _loc8_:RemotePlayerData = null;
         var _loc4_:* = (param3 & FORCE_LOAD) != 0;
         if((param3 & STATE) == 0)
         {
            param3 |= SUMMARY;
         }
         var _loc5_:int = getTimer() - DATA_REFRESH_TIME;
         var _loc6_:RemotePlayerLoadRequest = new RemotePlayerLoadRequest(param1,param2);
         for each(_loc7_ in param1)
         {
            _loc8_ = this._playersById[_loc7_];
            if((param3 & SUMMARY) != 0 && (!_loc8_ || _loc8_._summaryTimestamp <= 0 || _loc8_._summaryTimestamp < _loc5_ || _loc4_))
            {
               _loc6_.summaryList.push(_loc7_);
            }
            if((param3 & STATE) != 0 && (!_loc8_ || _loc8_._stateTimestamp <= 0 || _loc8_._stateTimestamp < _loc5_ || _loc4_))
            {
               _loc6_.stateList.push(_loc7_);
            }
         }
         this._requests.push(_loc6_);
         _loc6_.onComplete.add(this.parseLoadedData);
         _loc6_.load();
      }
      
      public function updateNeighborStates() : void
      {
         var _loc2_:RemotePlayerData = null;
         var _loc1_:Array = [];
         for each(_loc2_ in this._neighbors)
         {
            _loc1_.push(_loc2_.id);
         }
         if(_loc1_.length == 0)
         {
            return;
         }
         this.getLoadPlayers(_loc1_,null,RemotePlayerManager.STATE | RemotePlayerManager.SUMMARY);
      }
      
      public function addFriends(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:RemotePlayerData = null;
         for(_loc2_ in param1)
         {
            if(!(param1[_loc2_] == null || _loc2_ == Network.getInstance().playerData.id))
            {
               _loc3_ = this._playersById[_loc2_];
               if(_loc3_ == null)
               {
                  _loc3_ = new RemotePlayerData(_loc2_,param1[_loc2_]);
                  _loc3_._friend = true;
                  this._neighbors.push(_loc3_);
                  this._playersById[_loc2_] = _loc3_;
                  this._players.push(_loc3_);
               }
               else
               {
                  _loc3_._friend = true;
                  _loc3_.readObject(param1[_loc2_]);
               }
            }
         }
         this.sortNeighbors();
      }
      
      public function addNeighbor(param1:RemotePlayerData) : void
      {
         if(this._neighbors.indexOf(param1) > -1)
         {
            return;
         }
         this._neighbors.push(param1);
         param1._neighbor = true;
         if(this._playersById[param1.id] == null)
         {
            this._playersById[param1.id] = param1;
            this._players.push(param1);
         }
      }
      
      public function addNeighbors(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc3_:RemotePlayerData = null;
         var _loc4_:String = null;
         var _loc5_:Object = null;
         for(_loc4_ in param1)
         {
            if(_loc4_ != Network.getInstance().playerData.id)
            {
               _loc5_ = param1[_loc4_];
               if(_loc5_ != null)
               {
                  _loc3_ = this.updatePlayer(_loc4_,_loc5_);
                  _loc3_._neighbor = true;
                  if(this._neighbors.indexOf(_loc3_) == -1)
                  {
                     this._neighbors.push(_loc3_);
                  }
               }
            }
         }
         this.sortNeighbors();
      }
      
      public function updateHistory(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:RemotePlayerData = null;
         var _loc4_:Date = null;
         var _loc5_:Number = NaN;
         var _loc6_:Vector.<RemotePlayerData> = null;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc9_:RemotePlayerData = null;
         for(_loc2_ in param1)
         {
            _loc3_ = this._playersById[_loc2_];
            if(!(_loc3_ == null || param1[_loc2_] == null))
            {
               _loc3_.updateHistory(param1[_loc2_]);
            }
         }
         if(this.neighbors.length >= Config.constant.MAX_NEIGHBORHOOD_CULL_TRIGGER)
         {
            _loc4_ = new Date();
            _loc4_.date -= Config.constant.NEIGHBOR_EXPIRE_DAYS;
            _loc5_ = _loc4_.time;
            _loc6_ = this.neighbors.sort(this.playerHistorySort);
            _loc7_ = [];
            _loc8_ = int(_loc6_.length - 1);
            while(_loc8_ >= 0)
            {
               _loc9_ = _loc6_[_loc8_];
               if(!(_loc9_.isFriend || _loc9_.lastInteractionTime >= _loc5_))
               {
                  _loc7_.push(_loc9_.id);
                  if(_loc6_.length - _loc7_.length <= Config.constant.MAX_NEIGHBORHOOD_SIZE)
                  {
                     break;
                  }
               }
               _loc8_--;
            }
            if(_loc7_.length > 0)
            {
               Network.getInstance().save(_loc7_,SaveDataMethod.CULL_NEIGHBORS);
            }
         }
      }
      
      private function playerHistorySort(param1:RemotePlayerData, param2:RemotePlayerData) : Number
      {
         if(param1.lastInteractionTime > param2.lastInteractionTime)
         {
            return -1;
         }
         if(param1.lastInteractionTime < param2.lastInteractionTime)
         {
            return 1;
         }
         return 0;
      }
      
      public function cleanupNonEssential() : void
      {
         var _loc4_:RemotePlayerData = null;
         var _loc5_:Boolean = false;
         var _loc6_:RemotePlayerLoadRequest = null;
         var _loc7_:int = 0;
         var _loc1_:Number = this._players.length - this._neighbors.length;
         if(_loc1_ < CLEANUP_CAP)
         {
            return;
         }
         var _loc2_:Array = [];
         var _loc3_:int = getTimer() - CLEANUP_KEEP_TIME;
         for each(_loc4_ in this._players)
         {
            if(!(_loc4_._neighbor || _loc4_._stateTimestamp > _loc3_ || _loc4_._summaryTimestamp > _loc3_ || _loc4_._manualTimestamp > _loc3_))
            {
               _loc5_ = true;
               for each(_loc6_ in this._requests)
               {
                  if(_loc6_.idList.indexOf(_loc4_.id))
                  {
                     _loc5_ = false;
                     break;
                  }
               }
               if(_loc5_)
               {
                  _loc2_.push(_loc4_);
                  _loc1_--;
                  if(_loc1_ <= CLEANUP_CAP - 10)
                  {
                     break;
                  }
               }
            }
         }
         for each(_loc4_ in _loc2_)
         {
            _loc7_ = int(this._players.indexOf(_loc4_));
            if(_loc7_ > -1)
            {
               this._players.splice(_loc7_,1);
            }
            delete this._playersById[_loc4_.id];
         }
      }
      
      private function parseLoadedData(param1:RemotePlayerLoadRequest) : void
      {
         var _loc2_:RemotePlayerData = null;
         var _loc4_:DatabaseObject = null;
         var _loc6_:Vector.<RemotePlayerData> = null;
         var _loc7_:String = null;
         var _loc3_:int = getTimer();
         for each(_loc4_ in param1.results)
         {
            if(_loc4_ != null && _loc4_.key.indexOf("armorDeathbringerXX") > -1)
            {
            }
            if(this._playersById[_loc4_.key])
            {
               _loc2_ = this._playersById[_loc4_.key];
               _loc2_.readObject(_loc4_);
            }
            else
            {
               _loc2_ = new RemotePlayerData(_loc4_.key,_loc4_);
               this._playersById[_loc4_.key] = _loc2_;
               this._players.push(_loc2_);
            }
            if(param1.summaryList.indexOf(_loc2_.id) > -1)
            {
               _loc2_._summaryTimestamp = _loc3_;
            }
            if(param1.stateList.indexOf(_loc2_.id) > -1)
            {
               _loc2_._stateTimestamp = _loc3_;
            }
         }
         if(param1.callback != null)
         {
            _loc6_ = new Vector.<RemotePlayerData>();
            for each(_loc7_ in param1.idList)
            {
               _loc2_ = this._playersById[_loc7_];
               _loc6_.push(_loc2_);
            }
            param1.callback(_loc6_);
         }
         var _loc5_:int = int(this._requests.indexOf(param1));
         if(_loc5_ > -1)
         {
            this._requests.splice(_loc5_,1);
         }
         param1.dispose();
         this.cleanupNonEssential();
      }
      
      private function sortNeighbors() : void
      {
         this._neighbors.sort(function(param1:RemotePlayerData, param2:RemotePlayerData):int
         {
            if(param1.isFriend && !param2.isFriend)
            {
               return -1;
            }
            if(param2.isFriend && !param1.isFriend)
            {
               return 1;
            }
            return param1.id.localeCompare(param2.id);
         });
      }
      
      public function get neighbors() : Vector.<RemotePlayerData>
      {
         return this._neighbors;
      }
   }
}

import org.osflash.signals.Signal;
import playerio.DatabaseObject;

class RemotePlayerManagerSingletonEnforcer
{
   
   public function RemotePlayerManagerSingletonEnforcer()
   {
      super();
   }
}

class RemotePlayerLoadRequest
{
   
   public var onComplete:Signal;
   
   public var idList:Array = [];
   
   public var callback:Function;
   
   public var summaryList:Array = [];
   
   public var stateList:Array = [];
   
   private var _loadsRemaining:int = 0;
   
   public var results:Vector.<DatabaseObject> = new Vector.<DatabaseObject>();
   
   public function RemotePlayerLoadRequest(param1:Array, param2:Function)
   {
      super();
      this.onComplete = new Signal(RemotePlayerLoadRequest);
      this.idList = param1;
      this.callback = param2;
   }
   
   public function dispose() : void
   {
      this.onComplete.removeAll();
      this.idList = null;
      this.summaryList = null;
      this.stateList = null;
      this.callback = null;
      this.results = null;
   }
   
   public function load() : void
   {
      if(this.summaryList.length > 0)
      {
         ++this._loadsRemaining;
         Network.getInstance().client.bigDB.loadKeys("PlayerSummary",this.summaryList,this.onLoadComplete,this.onLoadError);
      }
      if(this.stateList.length > 0)
      {
         ++this._loadsRemaining;
         Network.getInstance().client.bigDB.loadKeys("PlayerStates",this.stateList,this.onLoadComplete,this.onLoadError);
      }
      if(this._loadsRemaining == 0)
      {
         this.onComplete.dispatch(this);
      }
   }
   
   private function onLoadComplete(param1:Array) : void
   {
      if(param1 == null)
      {
         this.onLoadError();
         return;
      }
      this.results = this.results.concat(Vector.<DatabaseObject>(param1));
      if(--this._loadsRemaining <= 0)
      {
         this.onComplete.dispatch(this);
      }
   }
   
   private function onLoadError() : void
   {
      if(--this._loadsRemaining <= 0)
      {
         this.onComplete.dispatch(this);
      }
   }
}
