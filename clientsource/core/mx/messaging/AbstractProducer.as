package mx.messaging
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import mx.logging.Log;
   import mx.messaging.events.ChannelEvent;
   import mx.messaging.events.ChannelFaultEvent;
   import mx.messaging.messages.AcknowledgeMessage;
   import mx.messaging.messages.CommandMessage;
   import mx.messaging.messages.ErrorMessage;
   import mx.messaging.messages.IMessage;
   import mx.resources.IResourceManager;
   import mx.resources.ResourceManager;
   
   use namespace mx_internal;
   
   public class AbstractProducer extends MessageAgent
   {
      
      private var _connectMsg:CommandMessage;
      
      private var _currentAttempt:int;
      
      private var _reconnectTimer:Timer;
      
      protected var _shouldBeConnected:Boolean;
      
      private var resourceManager:IResourceManager = ResourceManager.getInstance();
      
      private var _autoConnect:Boolean = true;
      
      private var _defaultHeaders:Object;
      
      private var _priority:int = -1;
      
      private var _reconnectAttempts:int;
      
      private var _reconnectInterval:int;
      
      public function AbstractProducer()
      {
         super();
      }
      
      [Bindable(event="propertyChange")]
      public function get autoConnect() : Boolean
      {
         return this._autoConnect;
      }
      
      public function set autoConnect(param1:Boolean) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         if(this._autoConnect != param1)
         {
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"autoConnect",this._autoConnect,param1);
            this._autoConnect = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get defaultHeaders() : Object
      {
         return this._defaultHeaders;
      }
      
      public function set defaultHeaders(param1:Object) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         if(this._defaultHeaders != param1)
         {
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"defaultHeaders",this._defaultHeaders,param1);
            this._defaultHeaders = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get priority() : int
      {
         return this._priority;
      }
      
      public function set priority(param1:int) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         if(this._priority != param1)
         {
            param1 = param1 < 0 ? 0 : (param1 > 9 ? 9 : param1);
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"priority",this._priority,param1);
            this._priority = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get reconnectAttempts() : int
      {
         return this._reconnectAttempts;
      }
      
      public function set reconnectAttempts(param1:int) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         if(this._reconnectAttempts != param1)
         {
            if(param1 == 0)
            {
               this.stopReconnectTimer();
            }
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"reconnectAttempts",this._reconnectAttempts,param1);
            this._reconnectAttempts = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get reconnectInterval() : int
      {
         return this._reconnectInterval;
      }
      
      public function set reconnectInterval(param1:int) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         var _loc3_:String = null;
         if(this._reconnectInterval != param1)
         {
            if(param1 < 0)
            {
               _loc3_ = this.resourceManager.getString("messaging","reconnectIntervalNegative");
               throw new ArgumentError(_loc3_);
            }
            if(param1 == 0)
            {
               this.stopReconnectTimer();
            }
            else if(this._reconnectTimer != null)
            {
               this._reconnectTimer.delay = param1;
            }
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"reconnectInterval",this._reconnectInterval,param1);
            this._reconnectInterval = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      override public function acknowledge(param1:AcknowledgeMessage, param2:IMessage) : void
      {
         if(_disconnectBarrier)
         {
            return;
         }
         super.acknowledge(param1,param2);
         if(param2 is CommandMessage && CommandMessage(param2).operation == CommandMessage.TRIGGER_CONNECT_OPERATION)
         {
            this.stopReconnectTimer();
         }
      }
      
      override public function fault(param1:ErrorMessage, param2:IMessage) : void
      {
         this.mx_internal::internalFault(param1,param2);
      }
      
      override public function channelDisconnectHandler(param1:ChannelEvent) : void
      {
         super.channelDisconnectHandler(param1);
         if(this._shouldBeConnected && !param1.rejected)
         {
            this.startReconnectTimer();
         }
      }
      
      override public function channelFaultHandler(param1:ChannelFaultEvent) : void
      {
         super.channelFaultHandler(param1);
         if(this._shouldBeConnected && !param1.rejected && !param1.channel.connected)
         {
            this.startReconnectTimer();
         }
      }
      
      override public function disconnect() : void
      {
         this._shouldBeConnected = false;
         this.stopReconnectTimer();
         super.disconnect();
      }
      
      public function connect() : void
      {
         if(!connected)
         {
            this._shouldBeConnected = true;
            if(this._connectMsg == null)
            {
               this._connectMsg = this.buildConnectMessage();
            }
            internalSend(this._connectMsg,false);
         }
      }
      
      public function send(param1:IMessage) : void
      {
         var _loc2_:String = null;
         var _loc3_:ErrorMessage = null;
         if(!connected && this.autoConnect)
         {
            this._shouldBeConnected = true;
         }
         if(this.defaultHeaders != null)
         {
            for(_loc2_ in this.defaultHeaders)
            {
               if(!param1.headers.hasOwnProperty(_loc2_))
               {
                  param1.headers[_loc2_] = this.defaultHeaders[_loc2_];
               }
            }
         }
         if(!connected && !this.autoConnect)
         {
            this._shouldBeConnected = false;
            _loc3_ = new ErrorMessage();
            _loc3_.faultCode = "Client.Error.MessageSend";
            _loc3_.faultString = this.resourceManager.getString("messaging","producerSendError");
            _loc3_.faultDetail = this.resourceManager.getString("messaging","producerSendErrorDetails");
            _loc3_.correlationId = param1.messageId;
            this.mx_internal::internalFault(_loc3_,param1,false,true);
         }
         else
         {
            if(Log.isInfo())
            {
               _log.info("\'{0}\' {1} sending message \'{2}\'",id,_agentType,param1.messageId);
            }
            internalSend(param1);
         }
      }
      
      mx_internal function internalFault(param1:ErrorMessage, param2:IMessage, param3:Boolean = true, param4:Boolean = false) : void
      {
         var _loc5_:ErrorMessage = null;
         if(_disconnectBarrier && !param4)
         {
            return;
         }
         if(param2 is CommandMessage && CommandMessage(param2).operation == CommandMessage.TRIGGER_CONNECT_OPERATION)
         {
            if(this._reconnectTimer == null)
            {
               if(this._connectMsg != null && param1.correlationId == this._connectMsg.messageId)
               {
                  this._shouldBeConnected = false;
                  _loc5_ = this.buildConnectErrorMessage();
                  _loc5_.rootCause = param1.rootCause;
                  super.fault(_loc5_,param2);
               }
               else
               {
                  super.fault(param1,param2);
               }
            }
         }
         else
         {
            super.fault(param1,param2);
         }
      }
      
      protected function reconnect(param1:TimerEvent) : void
      {
         if(this._reconnectAttempts != -1 && this._currentAttempt >= this._reconnectAttempts)
         {
            this.stopReconnectTimer();
            this._shouldBeConnected = false;
            this.fault(this.buildConnectErrorMessage(),this._connectMsg);
            return;
         }
         if(Log.isDebug())
         {
            _log.debug("\'{0}\' {1} trying to reconnect.",id,_agentType);
         }
         this._reconnectTimer.delay = this._reconnectInterval;
         ++this._currentAttempt;
         if(this._connectMsg == null)
         {
            this._connectMsg = this.buildConnectMessage();
         }
         internalSend(this._connectMsg,false);
      }
      
      protected function startReconnectTimer() : void
      {
         if(this._shouldBeConnected && this._reconnectTimer == null)
         {
            if(this._reconnectAttempts != 0 && this._reconnectInterval > 0)
            {
               if(Log.isDebug())
               {
                  _log.debug("\'{0}\' {1} starting reconnect timer.",id,_agentType);
               }
               this._reconnectTimer = new Timer(1);
               this._reconnectTimer.addEventListener(TimerEvent.TIMER,this.reconnect);
               this._reconnectTimer.start();
               this._currentAttempt = 0;
            }
         }
      }
      
      protected function stopReconnectTimer() : void
      {
         if(this._reconnectTimer != null)
         {
            if(Log.isDebug())
            {
               _log.debug("\'{0}\' {1} stopping reconnect timer.",id,_agentType);
            }
            this._reconnectTimer.removeEventListener(TimerEvent.TIMER,this.reconnect);
            this._reconnectTimer.reset();
            this._reconnectTimer = null;
         }
      }
      
      private function buildConnectErrorMessage() : ErrorMessage
      {
         var _loc1_:ErrorMessage = new ErrorMessage();
         _loc1_.faultCode = "Client.Error.Connect";
         _loc1_.faultString = this.resourceManager.getString("messaging","producerConnectError");
         _loc1_.faultDetail = this.resourceManager.getString("messaging","failedToConnect");
         _loc1_.correlationId = this._connectMsg.messageId;
         return _loc1_;
      }
      
      private function buildConnectMessage() : CommandMessage
      {
         var _loc1_:CommandMessage = new CommandMessage();
         _loc1_.operation = CommandMessage.TRIGGER_CONNECT_OPERATION;
         _loc1_.clientId = clientId;
         _loc1_.destination = destination;
         return _loc1_;
      }
   }
}

