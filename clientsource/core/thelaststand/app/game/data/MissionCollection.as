package thelaststand.app.game.data
{
   import flash.utils.Dictionary;
   
   public class MissionCollection
   {
      
      private var _missions:Vector.<MissionData>;
      
      private var _missionsById:Dictionary;
      
      public function MissionCollection()
      {
         super();
         this._missions = new Vector.<MissionData>();
         this._missionsById = new Dictionary(true);
      }
      
      public function addMission(param1:MissionData) : MissionData
      {
         if(this._missions.indexOf(param1) > -1)
         {
            return null;
         }
         this._missions.push(param1);
         this._missionsById[param1.id.toUpperCase()] = param1;
         return param1;
      }
      
      public function containsMission(param1:MissionData) : Boolean
      {
         return this._missions.indexOf(param1) > -1;
      }
      
      public function containsMissionId(param1:String) : Boolean
      {
         return this._missions[param1.toUpperCase()] != null;
      }
      
      public function dispose() : void
      {
         this._missions = null;
         this._missionsById = null;
      }
      
      public function getMission(param1:uint) : MissionData
      {
         if(param1 >= this._missions.length)
         {
            return null;
         }
         return this._missions[param1];
      }
      
      public function getMissionById(param1:String) : MissionData
      {
         return this._missionsById[param1.toUpperCase()];
      }
      
      public function getPvPMissionsByPlayerId(param1:String) : Vector.<MissionData>
      {
         var _loc3_:MissionData = null;
         var _loc2_:Vector.<MissionData> = new Vector.<MissionData>();
         for each(_loc3_ in this._missions)
         {
            if(_loc3_.opponent.isPlayer && _loc3_.opponent.id.toLowerCase() == param1.toLowerCase())
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function hasUncompletedPvPMissionAgainstPlayer(param1:String) : Boolean
      {
         var _loc2_:MissionData = null;
         for each(_loc2_ in this.getPvPMissionsByPlayerId(param1))
         {
            if(_loc2_.lockTimer != null && !_loc2_.lockTimer.hasEnded())
            {
               return true;
            }
         }
         return false;
      }
      
      public function getLatestLockedMissionByAreaId(param1:String) : MissionData
      {
         var _loc2_:MissionData = null;
         var _loc4_:MissionData = null;
         var _loc5_:Number = NaN;
         var _loc3_:Number = int.MIN_VALUE;
         for each(_loc4_ in this._missions)
         {
            if(_loc4_.areaId == param1)
            {
               if(_loc4_.lockTimer != null)
               {
                  _loc5_ = _loc4_.lockTimer.timeEnd.time;
                  if(_loc5_ >= _loc3_)
                  {
                     _loc3_ = _loc5_;
                     _loc2_ = _loc4_;
                  }
               }
            }
         }
         return _loc2_;
      }
      
      public function getMissionByAreaId(param1:String) : MissionData
      {
         var _loc2_:MissionData = null;
         for each(_loc2_ in this._missions)
         {
            if(_loc2_.areaId == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getMissionsByAreaType(param1:String) : Vector.<MissionData>
      {
         var _loc3_:MissionData = null;
         var _loc2_:Vector.<MissionData> = new Vector.<MissionData>();
         for each(_loc3_ in this._missions)
         {
            if(_loc3_.type == param1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         return param1 || [];
      }
      
      public function readObject(param1:Object) : void
      {
         var _loc4_:MissionData = null;
         this._missions = new Vector.<MissionData>();
         if(!(param1 is Array))
         {
            return;
         }
         var _loc2_:int = 0;
         var _loc3_:int = int(param1.length);
         while(_loc2_ < _loc3_)
         {
            if(param1[_loc2_] != null)
            {
               _loc4_ = new MissionData();
               _loc4_.readObject(param1[_loc2_]);
               this._missions.push(_loc4_);
            }
            _loc2_++;
         }
         this.buildIdLookup();
      }
      
      public function removeMission(param1:MissionData) : MissionData
      {
         var _loc2_:int = int(this._missions.indexOf(param1));
         if(_loc2_ == -1)
         {
            return null;
         }
         if(this._missionsById[param1.id.toUpperCase()] == null)
         {
            return null;
         }
         this._missions.splice(_loc2_,1);
         this._missionsById[param1.id.toUpperCase()] = null;
         delete this._missionsById[param1.id.toUpperCase()];
         return param1;
      }
      
      public function removeMissionById(param1:String) : MissionData
      {
         var _loc2_:MissionData = this._missionsById[param1.toUpperCase()];
         return this.removeMission(_loc2_);
      }
      
      private function buildIdLookup() : void
      {
         var _loc1_:MissionData = null;
         this._missionsById = new Dictionary(true);
         for each(_loc1_ in this._missions)
         {
            this._missionsById[_loc1_.id.toUpperCase()] = _loc1_;
         }
      }
      
      public function get length() : int
      {
         return this._missions.length;
      }
   }
}

