package playerio
{
   import playerio.generated.PlayerIOError;
   import playerio.generated.PlayerInsight;
   import playerio.generated.messages.KeyValuePair;
   import playerio.generated.messages.PlayerInsightEvent;
   import playerio.generated.messages.PlayerInsightState;
   import playerio.utils.HTTPChannel;
   
   public class PlayerInsight extends playerio.generated.PlayerInsight
   {
      private var _state:PlayerInsightState = null;
      
      public function PlayerInsight(param1:HTTPChannel, param2:Client, param3:PlayerInsightState)
      {
         this._state = param3;
         super(param1,param2);
      }
      
      public function get playersOnline() : int
      {
         if(_state.playersOnline == -1)
         {
            throw new playerio.generated.PlayerIOError("The current connection does not have the rights required to read the playersonline variable.",3);
         }
         return _state.playersOnline;
      }
      
      public function getSegment(param1:String) : String
      {
         var _loc2_:int = 0;
         var _loc3_:KeyValuePair = null;
         _loc2_ = 0;
         while(_loc2_ < _state.segments.length)
         {
            _loc3_ = _state.segments[_loc2_];
            if(_loc3_.key == param1)
            {
               return _loc3_.value;
            }
            _loc2_++;
         }
         return null;
      }
      
      public function refresh(param1:Function = null, param2:Function = null) : void
      {
         var callback:Function = param1;
         var errorHandler:Function = param2;
         _playerInsightRefresh(function(param1:PlayerInsightState):void
         {
            _state = param1;
            if(callback != null)
            {
               callback();
            }
         },errorHandler);
      }
      
      public function setSegments(param1:Array, param2:Function = null, param3:Function = null) : void
      {
         var segments:Array = param1;
         var callback:Function = param2;
         var errorHandler:Function = param3;
         _playerInsightSetSegments(segments,function(param1:PlayerInsightState):void
         {
            _state = param1;
            if(callback != null)
            {
               callback();
            }
         },errorHandler);
      }
      
      public function trackInvitedBy(param1:String, param2:String, param3:Function = null, param4:Function = null) : void
      {
         _playerInsightTrackInvitedBy(param1,param2,param3,param4);
      }
      
      public function trackEvents(param1:Array, param2:Function = null, param3:Function = null) : void
      {
         var _loc5_:int = 0;
         var _loc6_:PlayerInsightEvent = null;
         var _loc4_:Array = [];
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            _loc6_ = new PlayerInsightEvent();
            _loc6_.eventType = param1[_loc5_];
            _loc6_.value = param1[_loc5_ + 1];
            _loc4_.push(_loc6_);
            _loc5_ += 2;
         }
         _playerInsightTrackEvents(_loc4_,param2,param3);
      }
      
      public function trackExternalPayment(param1:String, param2:int, param3:Function = null, param4:Function = null) : void
      {
         _playerInsightTrackExternalPayment(param1,param2,param3,param4);
      }
   }
}

