package playerio
{
   import playerio.generated.OneScore;
   import playerio.generated.messages.OneScoreValue;
   import playerio.utils.HTTPChannel;
   
   public class OneScore extends playerio.generated.OneScore
   {
      private var _value:playerio.OneScoreValue;
      
      public function OneScore(param1:HTTPChannel, param2:Client)
      {
         super(param1,param2);
      }
      
      public function get score() : int
      {
         if(_value == null)
         {
            throw new PlayerIOError("Cannot access Score before Refresh() has been called.",PlayerIOError.OneScoreNotLoaded.errorID);
         }
         return _value.score;
      }
      
      public function get percentile() : Number
      {
         if(_value == null)
         {
            throw new PlayerIOError("Cannot access Percentile before Refresh() has been called.",PlayerIOError.OneScoreNotLoaded.errorID);
         }
         return _value.percentile;
      }
      
      public function get topRank() : int
      {
         if(_value == null)
         {
            throw new PlayerIOError("Cannot access TopRank before Refresh() has been called.",PlayerIOError.OneScoreNotLoaded.errorID);
         }
         return _value.topRank;
      }
      
      private function processOneScoreValue(param1:playerio.generated.messages.OneScoreValue, param2:Function = null) : void
      {
         var _loc3_:playerio.OneScoreValue = convertOneScoreValue2ClientOneScoreValue(param1);
         this._value = _loc3_;
         if(param2 != null)
         {
            param2();
         }
      }
      
      private function convertOneScoreValue2ClientOneScoreValue(param1:playerio.generated.messages.OneScoreValue) : playerio.OneScoreValue
      {
         var _loc2_:playerio.OneScoreValue = new playerio.OneScoreValue();
         _loc2_._internal_initialize(param1);
         return _loc2_;
      }
      
      public function refresh(param1:Function = null, param2:Function = null) : void
      {
         var callback:Function = param1;
         var errorHandler:Function = param2;
         _oneScoreRefresh(function(param1:playerio.generated.messages.OneScoreValue):void
         {
            processOneScoreValue(param1,callback);
         },errorHandler);
      }
      
      public function set(param1:int, param2:Function = null, param3:Function = null) : void
      {
         var score:int = param1;
         var callback:Function = param2;
         var errorHandler:Function = param3;
         _oneScoreSet(score,function(param1:playerio.generated.messages.OneScoreValue):void
         {
            processOneScoreValue(param1,callback);
         },errorHandler);
      }
      
      public function add(param1:int, param2:Function = null, param3:Function = null) : void
      {
         var score:int = param1;
         var callback:Function = param2;
         var errorHandler:Function = param3;
         _oneScoreAdd(score,function(param1:playerio.generated.messages.OneScoreValue):void
         {
            processOneScoreValue(param1,callback);
         },errorHandler);
      }
      
      public function load(param1:Array, param2:Function = null, param3:Function = null) : void
      {
         var userIds:Array = param1;
         var callback:Function = param2;
         var errorHandler:Function = param3;
         _oneScoreLoad(userIds,function(param1:Array):void
         {
            var _loc4_:int = 0;
            var _loc2_:int = 0;
            var _loc3_:Array = [];
            _loc4_ = 0;
            while(_loc4_ < userIds.length)
            {
               if(_loc2_ < param1.length && userIds[_loc4_] == playerio.generated.messages.OneScoreValue(param1[_loc2_]).userId)
               {
                  _loc3_.push(convertOneScoreValue2ClientOneScoreValue(param1[_loc2_]));
                  _loc2_++;
               }
               else
               {
                  _loc3_.push(null);
               }
               _loc4_++;
            }
            if(callback != null)
            {
               callback(_loc3_);
            }
         },errorHandler);
      }
   }
}

