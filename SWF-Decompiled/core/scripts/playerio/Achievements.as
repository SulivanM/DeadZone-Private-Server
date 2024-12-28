package playerio
{
   import flash.utils.Dictionary;
   import playerio.generated.Achievements;
   import playerio.generated.PlayerIOError;
   import playerio.generated.messages.Achievement;
   import playerio.utils.HTTPChannel;
   
   public class Achievements extends playerio.generated.Achievements
   {
      private var _version:String = null;
      
      private var _myAchievements:Array = null;
      
      private var _onCompletedHandler:Function = null;
      
      public function Achievements(param1:HTTPChannel, param2:Client)
      {
         super(param1,param2);
      }
      
      public function set onCompletedHandler(param1:Function) : void
      {
         _onCompletedHandler = param1;
      }
      
      public function get myAchievements() : Array
      {
         if(_myAchievements != null)
         {
            return _myAchievements;
         }
         throw new playerio.generated.PlayerIOError("Cannot access myAchievements before \'achievements\' has been loaded. Please refresh the achievements first",playerio.PlayerIOError.AchievementsNotLoaded.errorID);
      }
      
      public function get(param1:String) : playerio.Achievement
      {
         for each(var _loc2_ in _myAchievements)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function refresh(param1:Function = null, param2:Function = null) : void
      {
         var callback:Function = param1;
         var errorHandler:Function = param2;
         _achievementsRefresh(_version,function(param1:String, param2:Array):void
         {
            refreshAchiemeventsHelper(param1,param2);
            if(callback != null)
            {
               callback();
            }
         },errorHandler);
      }
      
      public function load(param1:Array, param2:Function = null, param3:Function = null) : void
      {
         var userIds:Array = param1;
         var callback:Function = param2;
         var errorHandler:Function = param3;
         _achievementsLoad(userIds,function(param1:Array):void
         {
            var _loc2_:Dictionary = null;
            if(callback != null)
            {
               _loc2_ = parseUserAchievements(param1);
               callback(_loc2_);
            }
         },errorHandler);
      }
      
      public function progressSet(param1:String, param2:int, param3:Function, param4:Function) : void
      {
         var achievementId:String = param1;
         var progress:int = param2;
         var callback:Function = param3;
         var errorHandler:Function = param4;
         _achievementsProgressSet(achievementId,progress,function(param1:playerio.generated.messages.Achievement, param2:Boolean):void
         {
            processResults(param1,param2,callback);
         },errorHandler);
      }
      
      public function progressAdd(param1:String, param2:int, param3:Function, param4:Function) : void
      {
         var achievementId:String = param1;
         var progressDelta:int = param2;
         var callback:Function = param3;
         var errorHandler:Function = param4;
         _achievementsProgressAdd(achievementId,progressDelta,function(param1:playerio.generated.messages.Achievement, param2:Boolean):void
         {
            processResults(param1,param2,callback);
         },errorHandler);
      }
      
      public function progressMax(param1:String, param2:int, param3:Function, param4:Function) : void
      {
         var achievementId:String = param1;
         var progress:int = param2;
         var callback:Function = param3;
         var errorHandler:Function = param4;
         _achievementsProgressMax(achievementId,progress,function(param1:playerio.generated.messages.Achievement, param2:Boolean):void
         {
            processResults(param1,param2,callback);
         },errorHandler);
      }
      
      public function progressComplete(param1:String, param2:Function, param3:Function) : void
      {
         var achievementId:String = param1;
         var callback:Function = param2;
         var errorHandler:Function = param3;
         _achievementsProgressComplete(achievementId,function(param1:playerio.generated.messages.Achievement, param2:Boolean):void
         {
            processResults(param1,param2,callback);
         },errorHandler);
      }
      
      private function refreshAchiemeventsHelper(param1:String, param2:Array) : void
      {
         _version = param1;
         _myAchievements = parseAchievements(param2);
      }
      
      private function parseUserAchievements(param1:Array) : Dictionary
      {
         var _loc3_:int = 0;
         var _loc2_:Dictionary = new Dictionary();
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_[param1[_loc3_].userId] = new UserAchievement(param1[_loc3_].userId,parseAchievements(param1[_loc3_].achievements)).achievements;
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function parseAchievements(param1:Array) : Array
      {
         var _loc4_:int = 0;
         var _loc2_:playerio.Achievement = null;
         var _loc3_:Array = [];
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc2_ = new playerio.Achievement();
            _loc2_._internal_initialize(param1[_loc4_] as playerio.generated.messages.Achievement);
            _loc3_.push(_loc2_);
            _loc4_++;
         }
         return _loc3_;
      }
      
      private function processResults(param1:playerio.generated.messages.Achievement, param2:Boolean, param3:Function) : void
      {
         var _loc5_:int = 0;
         var _loc4_:playerio.Achievement = null;
         if(_myAchievements != null)
         {
            _loc5_ = 0;
            while(_loc5_ < _myAchievements.length)
            {
               if(_myAchievements[_loc5_].id == param1.identifier)
               {
                  _loc4_ = _myAchievements[_loc5_];
                  _loc4_._internal_initialize(param1);
                  break;
               }
               _loc5_++;
            }
            if(_loc4_ == null)
            {
               _loc4_ = new playerio.Achievement();
               _loc4_._internal_initialize(param1);
               _myAchievements.push(_loc4_);
            }
         }
         else
         {
            _loc4_ = new playerio.Achievement();
            _loc4_._internal_initialize(param1);
         }
         if(param2 && _onCompletedHandler != null)
         {
            _onCompletedHandler(_loc4_);
         }
         if(param3 != null)
         {
            param3(_loc4_);
         }
      }
   }
}

