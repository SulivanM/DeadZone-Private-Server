package mx.messaging
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import mx.logging.Log;
   import mx.messaging.channels.PollingChannel;
   import mx.messaging.events.ChannelEvent;
   import mx.messaging.events.ChannelFaultEvent;
   import mx.messaging.events.MessageEvent;
   import mx.messaging.events.MessageFaultEvent;
   import mx.messaging.messages.AcknowledgeMessage;
   import mx.messaging.messages.CommandMessage;
   import mx.messaging.messages.ErrorMessage;
   import mx.messaging.messages.IMessage;
   import mx.resources.IResourceManager;
   import mx.resources.ResourceManager;
   
   use namespace mx_internal;
   
   public class AbstractConsumer extends MessageAgent
   {
      
      private var _currentAttempt:int;
      
      private var _resubscribeTimer:Timer;
      
      protected var _shouldBeSubscribed:Boolean;
      
      private var _subscribeMsg:CommandMessage;
      
      private var resourceManager:IResourceManager = ResourceManager.getInstance();
      
      private var _maxFrequency:uint = 0;
      
      private var _resubscribeAttempts:int = 5;
      
      private var _resubscribeInterval:int = 5000;
      
      private var _subscribed:Boolean;
      
      private var _timestamp:Number = -1;
      
      public function AbstractConsumer()
      {
         super();
         _log = Log.getLogger("mx.messaging.Consumer");
         _agentType = "consumer";
      }
      
      override mx_internal function setClientId(param1:String) : void
      {
         var _loc2_:Boolean = false;
         if(super.clientId != param1)
         {
            _loc2_ = false;
            if(this.subscribed)
            {
               this.unsubscribe();
               _loc2_ = true;
            }
            super.mx_internal::setClientId(param1);
            if(_loc2_)
            {
               this.subscribe(param1);
            }
         }
      }
      
      override public function set destination(param1:String) : void
      {
         var _loc2_:Boolean = false;
         if(destination != param1)
         {
            _loc2_ = false;
            if(this.subscribed)
            {
               this.unsubscribe();
               _loc2_ = true;
            }
            super.destination = param1;
            if(_loc2_)
            {
               this.subscribe();
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get maxFrequency() : uint
      {
         return this._maxFrequency;
      }
      
      public function set maxFrequency(param1:uint) : void
      {
         var _loc2_:PropertyChangeEvent = PropertyChangeEvent.createUpdateEvent(this,"maxFrequency",this._maxFrequency,param1);
         this._maxFrequency = param1;
         dispatchEvent(_loc2_);
      }
      
      [Bindable(event="propertyChange")]
      public function get resubscribeAttempts() : int
      {
         return this._resubscribeAttempts;
      }
      
      public function set resubscribeAttempts(param1:int) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         if(this._resubscribeAttempts != param1)
         {
            if(param1 == 0)
            {
               this.stopResubscribeTimer();
            }
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"resubscribeAttempts",this._resubscribeAttempts,param1);
            this._resubscribeAttempts = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get resubscribeInterval() : int
      {
         return this._resubscribeInterval;
      }
      
      public function set resubscribeInterval(param1:int) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         var _loc3_:String = null;
         if(this._resubscribeInterval != param1)
         {
            if(param1 < 0)
            {
               _loc3_ = this.resourceManager.getString("messaging","resubscribeIntervalNegative");
               throw new ArgumentError(_loc3_);
            }
            if(param1 == 0)
            {
               this.stopResubscribeTimer();
            }
            else if(this._resubscribeTimer != null)
            {
               this._resubscribeTimer.delay = param1;
            }
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"resubscribeInterval",this._resubscribeInterval,param1);
            this._resubscribeInterval = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get subscribed() : Boolean
      {
         return this._subscribed;
      }
      
      protected function setSubscribed(param1:Boolean) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         if(this._subscribed != param1)
         {
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"subscribed",this._subscribed,param1);
            this._subscribed = param1;
            if(this._subscribed)
            {
               ConsumerMessageDispatcher.getInstance().registerSubscription(this);
               if(channelSet != null && channelSet.currentChannel != null && channelSet.currentChannel is PollingChannel)
               {
                  PollingChannel(channelSet.currentChannel).enablePolling();
               }
            }
            else
            {
               ConsumerMessageDispatcher.getInstance().unregisterSubscription(this);
               if(channelSet != null && channelSet.currentChannel != null && channelSet.currentChannel is PollingChannel)
               {
                  PollingChannel(channelSet.currentChannel).disablePolling();
               }
            }
            dispatchEvent(_loc2_);
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get timestamp() : Number
      {
         return this._timestamp;
      }
      
      public function set timestamp(param1:Number) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         if(this._timestamp != param1)
         {
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"timestamp",this._timestamp,param1);
            this._timestamp = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      override public function acknowledge(param1:AcknowledgeMessage, param2:IMessage) : void
      {
         var _loc3_:CommandMessage = null;
         var _loc4_:int = 0;
         var _loc5_:Array = null;
         var _loc6_:IMessage = null;
         if(_disconnectBarrier)
         {
            return;
         }
         if(!param1.headers[AcknowledgeMessage.ERROR_HINT_HEADER] && param2 is CommandMessage)
         {
            _loc3_ = param2 as CommandMessage;
            _loc4_ = int(_loc3_.operation);
            if(_loc4_ == CommandMessage.MULTI_SUBSCRIBE_OPERATION)
            {
               if(param2.headers.DSlastUnsub != null)
               {
                  _loc4_ = int(CommandMessage.UNSUBSCRIBE_OPERATION);
               }
               else
               {
                  _loc4_ = int(CommandMessage.SUBSCRIBE_OPERATION);
               }
            }
            switch(_loc4_)
            {
               case CommandMessage.UNSUBSCRIBE_OPERATION:
                  if(Log.isInfo())
                  {
                     _log.info("\'{0}\' {1} acknowledge for unsubscribe.",id,_agentType);
                  }
                  super.mx_internal::setClientId(null);
                  this.setSubscribed(false);
                  param1.clientId = null;
                  super.acknowledge(param1,param2);
                  break;
               case CommandMessage.SUBSCRIBE_OPERATION:
                  this.stopResubscribeTimer();
                  if(param1.timestamp > this._timestamp)
                  {
                     this._timestamp = param1.timestamp - 1;
                  }
                  if(Log.isInfo())
                  {
                     _log.info("\'{0}\' {1} acknowledge for subscribe. Client id \'{2}\' new timestamp {3}",id,_agentType,param1.clientId,this._timestamp);
                  }
                  super.mx_internal::setClientId(param1.clientId);
                  this.setSubscribed(true);
                  super.acknowledge(param1,param2);
                  break;
               case CommandMessage.POLL_OPERATION:
                  if(param1.body != null && param1.body is Array)
                  {
                     _loc5_ = param1.body as Array;
                     for each(_loc6_ in _loc5_)
                     {
                        this.mx_internal::messageHandler(MessageEvent.createEvent(MessageEvent.MESSAGE,_loc6_));
                     }
                  }
                  super.acknowledge(param1,param2);
            }
         }
         else
         {
            super.acknowledge(param1,param2);
         }
      }
      
      override public function disconnect() : void
      {
         this._shouldBeSubscribed = false;
         this.stopResubscribeTimer();
         this.setSubscribed(false);
         super.disconnect();
      }
      
      override public function fault(param1:ErrorMessage, param2:IMessage) : void
      {
         if(_disconnectBarrier)
         {
            return;
         }
         if(param1.headers[ErrorMessage.RETRYABLE_HINT_HEADER])
         {
            if(this._resubscribeTimer == null)
            {
               if(this._subscribeMsg != null && param1.correlationId == this._subscribeMsg.messageId)
               {
                  this._shouldBeSubscribed = false;
               }
               super.fault(param1,param2);
            }
         }
         else
         {
            super.fault(param1,param2);
         }
      }
      
      override public function channelConnectHandler(param1:ChannelEvent) : void
      {
         super.channelConnectHandler(param1);
         if(connected && channelSet != null && channelSet.currentChannel != null && !channelSet.currentChannel.mx_internal::realtime && Log.isWarn())
         {
            _log.warn("\'{0}\' {1} connected over a non-realtime channel \'{2}\'" + " which means channel is not automatically receiving updates via polling or server push.",id,_agentType,channelSet.currentChannel.id);
         }
      }
      
      override public function channelDisconnectHandler(param1:ChannelEvent) : void
      {
         this.setSubscribed(false);
         super.channelDisconnectHandler(param1);
         if(this._shouldBeSubscribed && !param1.rejected)
         {
            this.startResubscribeTimer();
         }
      }
      
      override public function channelFaultHandler(param1:ChannelFaultEvent) : void
      {
         if(!param1.channel.connected)
         {
            this.setSubscribed(false);
         }
         super.channelFaultHandler(param1);
         if(this._shouldBeSubscribed && !param1.rejected && !param1.channel.connected)
         {
            this.startResubscribeTimer();
         }
      }
      
      public function receive(param1:Number = 0) : void
      {
         var _loc2_:CommandMessage = null;
         if(clientId != null)
         {
            _loc2_ = new CommandMessage();
            _loc2_.operation = CommandMessage.POLL_OPERATION;
            _loc2_.destination = destination;
            internalSend(_loc2_);
         }
      }
      
      public function subscribe(param1:String = null) : void
      {
         var _loc2_:Boolean = param1 != null && super.clientId != param1 ? true : false;
         if(this.subscribed && _loc2_)
         {
            this.unsubscribe();
         }
         this.stopResubscribeTimer();
         this._shouldBeSubscribed = true;
         if(_loc2_)
         {
            super.mx_internal::setClientId(param1);
         }
         if(Log.isInfo())
         {
            _log.info("\'{0}\' {1} subscribe.",id,_agentType);
         }
         this._subscribeMsg = this.buildSubscribeMessage();
         internalSend(this._subscribeMsg);
      }
      
      public function unsubscribe(param1:Boolean = false) : void
      {
         this._shouldBeSubscribed = false;
         if(this.subscribed)
         {
            if(channelSet != null)
            {
               channelSet.removeEventListener(destination,this.mx_internal::messageHandler);
            }
            if(Log.isInfo())
            {
               _log.info("\'{0}\' {1} unsubscribe.",id,_agentType);
            }
            internalSend(this.buildUnsubscribeMessage(param1));
         }
         else
         {
            this.stopResubscribeTimer();
         }
      }
      
      mx_internal function messageHandler(param1:MessageEvent) : void
      {
         var _loc3_:CommandMessage = null;
         var _loc2_:IMessage = param1.message;
         if(_loc2_ is CommandMessage)
         {
            _loc3_ = _loc2_ as CommandMessage;
            switch(_loc3_.operation)
            {
               case CommandMessage.SUBSCRIPTION_INVALIDATE_OPERATION:
                  this.setSubscribed(false);
                  break;
               default:
                  if(Log.isWarn())
                  {
                     _log.warn("\'{0}\' received a CommandMessage \'{1}\' that could not be handled.",id,CommandMessage.getOperationAsString(_loc3_.operation));
                  }
            }
            return;
         }
         if(_loc2_.timestamp > this._timestamp)
         {
            this._timestamp = _loc2_.timestamp;
         }
         if(_loc2_ is ErrorMessage)
         {
            dispatchEvent(MessageFaultEvent.createEvent(ErrorMessage(_loc2_)));
         }
         else
         {
            dispatchEvent(MessageEvent.createEvent(MessageEvent.MESSAGE,_loc2_));
         }
      }
      
      protected function buildSubscribeMessage() : CommandMessage
      {
         var _loc1_:CommandMessage = new CommandMessage();
         _loc1_.operation = CommandMessage.SUBSCRIBE_OPERATION;
         _loc1_.clientId = clientId;
         _loc1_.destination = destination;
         if(this.maxFrequency > 0)
         {
            _loc1_.headers[CommandMessage.MAX_FREQUENCY_HEADER] = this.maxFrequency;
         }
         return _loc1_;
      }
      
      protected function buildUnsubscribeMessage(param1:Boolean) : CommandMessage
      {
         var _loc2_:CommandMessage = new CommandMessage();
         _loc2_.operation = CommandMessage.UNSUBSCRIBE_OPERATION;
         _loc2_.clientId = clientId;
         _loc2_.destination = destination;
         if(param1)
         {
            _loc2_.headers[CommandMessage.PRESERVE_DURABLE_HEADER] = param1;
         }
         return _loc2_;
      }
      
      protected function resubscribe(param1:TimerEvent) : void
      {
         var _loc2_:ErrorMessage = null;
         if(this._resubscribeAttempts != -1 && this._currentAttempt >= this._resubscribeAttempts)
         {
            this.stopResubscribeTimer();
            this._shouldBeSubscribed = false;
            _loc2_ = new ErrorMessage();
            _loc2_.faultCode = "Client.Error.Subscribe";
            _loc2_.faultString = this.resourceManager.getString("messaging","consumerSubscribeError");
            _loc2_.faultDetail = this.resourceManager.getString("messaging","failedToSubscribe");
            _loc2_.correlationId = this._subscribeMsg.messageId;
            this.fault(_loc2_,this._subscribeMsg);
            return;
         }
         if(Log.isDebug())
         {
            _log.debug("\'{0}\' {1} trying to resubscribe.",id,_agentType);
         }
         this._resubscribeTimer.delay = this._resubscribeInterval;
         ++this._currentAttempt;
         internalSend(this._subscribeMsg,false);
      }
      
      protected function startResubscribeTimer() : void
      {
         if(this._shouldBeSubscribed && this._resubscribeTimer == null)
         {
            if(this._resubscribeAttempts != 0 && this._resubscribeInterval > 0)
            {
               if(Log.isDebug())
               {
                  _log.debug("\'{0}\' {1} starting resubscribe timer.",id,_agentType);
               }
               this._resubscribeTimer = new Timer(1);
               this._resubscribeTimer.addEventListener(TimerEvent.TIMER,this.resubscribe);
               this._resubscribeTimer.start();
               this._currentAttempt = 0;
            }
         }
      }
      
      protected function stopResubscribeTimer() : void
      {
         if(this._resubscribeTimer != null)
         {
            if(Log.isDebug())
            {
               _log.debug("\'{0}\' {1} stopping resubscribe timer.",id,_agentType);
            }
            this._resubscribeTimer.removeEventListener(TimerEvent.TIMER,this.resubscribe);
            this._resubscribeTimer.reset();
            this._resubscribeTimer = null;
         }
      }
   }
}

