package mx.messaging
{
   import flash.utils.Dictionary;
   import mx.core.mx_internal;
   import mx.logging.Log;
   import mx.messaging.events.MessageEvent;
   
   use namespace mx_internal;
   
   public class ConsumerMessageDispatcher
   {
      
      private static var _instance:ConsumerMessageDispatcher;
      
      private const _consumers:Object = {};
      
      private const _channelSetRefCounts:Dictionary = new Dictionary();
      
      private const _consumerDuplicateMessageBarrier:Object = {};
      
      public function ConsumerMessageDispatcher()
      {
         super();
      }
      
      public static function getInstance() : ConsumerMessageDispatcher
      {
         if(!_instance)
         {
            _instance = new ConsumerMessageDispatcher();
         }
         return _instance;
      }
      
      public function isChannelUsedForSubscriptions(param1:Channel) : Boolean
      {
         var _loc2_:Array = param1.channelSets;
         var _loc3_:ChannelSet = null;
         var _loc4_:int = int(_loc2_.length);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc3_ = _loc2_[_loc5_];
            if(this._channelSetRefCounts[_loc3_] != null && _loc3_.currentChannel == param1)
            {
               return true;
            }
            _loc5_++;
         }
         return false;
      }
      
      public function registerSubscription(param1:AbstractConsumer) : void
      {
         this._consumers[param1.clientId] = param1;
         if(this._channelSetRefCounts[param1.channelSet] == null)
         {
            param1.channelSet.addEventListener(MessageEvent.MESSAGE,this.messageHandler);
            this._channelSetRefCounts[param1.channelSet] = 1;
         }
         else
         {
            ++this._channelSetRefCounts[param1.channelSet];
         }
      }
      
      public function unregisterSubscription(param1:AbstractConsumer) : void
      {
         delete this._consumers[param1.clientId];
         var _loc2_:int = int(this._channelSetRefCounts[param1.channelSet]);
         if(--_loc2_ == 0)
         {
            param1.channelSet.removeEventListener(MessageEvent.MESSAGE,this.messageHandler);
            delete this._channelSetRefCounts[param1.channelSet];
            if(this._consumerDuplicateMessageBarrier[param1.id] != null)
            {
               delete this._consumerDuplicateMessageBarrier[param1.id];
            }
         }
         else
         {
            this._channelSetRefCounts[param1.channelSet] = _loc2_;
         }
      }
      
      private function messageHandler(param1:MessageEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:ChannelSet = null;
         var _loc5_:Array = null;
         var _loc2_:AbstractConsumer = this._consumers[param1.message.clientId];
         if(_loc2_ == null)
         {
            if(Log.isDebug())
            {
               Log.getLogger("mx.messaging.Consumer").debug("\'{0}\' received pushed message for consumer but no longer subscribed: {1}",param1.message.clientId,param1.message);
            }
            return;
         }
         if(param1.target.currentChannel.channelSets.length > 1)
         {
            _loc3_ = 0;
            for each(_loc4_ in param1.target.currentChannel.channelSets)
            {
               if(this._channelSetRefCounts[_loc4_] != null)
               {
                  _loc3_++;
               }
            }
            if(_loc3_ > 1)
            {
               if(this._consumerDuplicateMessageBarrier[_loc2_.id] == null)
               {
                  this._consumerDuplicateMessageBarrier[_loc2_.id] = [param1.messageId,_loc3_];
                  _loc2_.mx_internal::messageHandler(param1);
               }
               _loc5_ = this._consumerDuplicateMessageBarrier[_loc2_.id];
               if(_loc5_[0] == param1.messageId)
               {
                  if(--_loc5_[1] == 0)
                  {
                     delete this._consumerDuplicateMessageBarrier[_loc2_.id];
                  }
               }
               return;
            }
         }
         _loc2_.mx_internal::messageHandler(param1);
      }
   }
}

