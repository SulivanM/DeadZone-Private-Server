package mx.messaging.channels
{
   import flash.events.AsyncErrorEvent;
   import flash.events.ErrorEvent;
   import flash.events.IOErrorEvent;
   import flash.events.NetStatusEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.NetConnection;
   import flash.net.ObjectEncoding;
   import mx.core.mx_internal;
   import mx.logging.Log;
   import mx.messaging.MessageAgent;
   import mx.messaging.MessageResponder;
   import mx.messaging.config.LoaderConfig;
   import mx.messaging.events.ChannelFaultEvent;
   import mx.messaging.events.MessageEvent;
   import mx.messaging.messages.IMessage;
   import mx.messaging.messages.ISmallMessage;
   import mx.messaging.messages.MessagePerformanceInfo;
   import mx.messaging.messages.MessagePerformanceUtils;
   import mx.netmon.NetworkMonitor;
   
   use namespace mx_internal;
   
   public class NetConnectionChannel extends PollingChannel
   {
      
      mx_internal var _appendToURL:String;
      
      protected var _nc:NetConnection;
      
      public function NetConnectionChannel(param1:String = null, param2:String = null)
      {
         super(param1,param2);
         this._nc = new NetConnection();
         this._nc.objectEncoding = ObjectEncoding.AMF3;
         this._nc.client = this;
      }
      
      public function get netConnection() : NetConnection
      {
         return this._nc;
      }
      
      override public function get useSmallMessages() : Boolean
      {
         return super.useSmallMessages && this._nc != null && this._nc.objectEncoding >= ObjectEncoding.AMF3;
      }
      
      override protected function connectTimeoutHandler(param1:TimerEvent) : void
      {
         this.shutdownNetConnection();
         super.connectTimeoutHandler(param1);
      }
      
      override protected function getDefaultMessageResponder(param1:MessageAgent, param2:IMessage) : MessageResponder
      {
         return new NetConnectionMessageResponder(param1,param2,this);
      }
      
      override protected function internalDisconnect(param1:Boolean = false) : void
      {
         super.internalDisconnect(param1);
         this.shutdownNetConnection();
         disconnectSuccess(param1);
      }
      
      override protected function internalConnect() : void
      {
         var url:String = null;
         var i:int = 0;
         var temp:String = null;
         var j:int = 0;
         var redirectedUrl:String = null;
         super.internalConnect();
         url = endpoint;
         if(this.mx_internal::_appendToURL != null)
         {
            i = int(url.indexOf("wsrp-url="));
            if(i != -1)
            {
               temp = url.substr(i + 9,url.length);
               j = int(temp.indexOf("&"));
               if(j != -1)
               {
                  temp = temp.substr(0,j);
               }
               url = url.replace(temp,temp + this.mx_internal::_appendToURL);
            }
            else
            {
               url += this.mx_internal::_appendToURL;
            }
         }
         if(this._nc.uri != null && this._nc.uri.length > 0 && this._nc.connected)
         {
            this._nc.removeEventListener(NetStatusEvent.NET_STATUS,this.statusHandler);
            this._nc.close();
         }
         if("httpIdleTimeout" in this._nc && requestTimeout > 0)
         {
            this._nc["httpIdleTimeout"] = requestTimeout * 1000;
         }
         this._nc.addEventListener(NetStatusEvent.NET_STATUS,this.statusHandler);
         this._nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.securityErrorHandler);
         this._nc.addEventListener(IOErrorEvent.IO_ERROR,this.ioErrorHandler);
         this._nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR,this.asyncErrorHandler);
         try
         {
            if(NetworkMonitor.isMonitoring())
            {
               redirectedUrl = NetworkMonitor.adjustNetConnectionURL(LoaderConfig.url,url);
               if(redirectedUrl != null)
               {
                  url = redirectedUrl;
               }
            }
            this._nc.connect(url);
         }
         catch(e:Error)
         {
            e.message += "  url: \'" + url + "\'";
            throw e;
         }
      }
      
      override protected function internalSend(param1:MessageResponder) : void
      {
         var _loc3_:MessagePerformanceInfo = null;
         var _loc4_:IMessage = null;
         setFlexClientIdOnMessage(param1.message);
         if(mpiEnabled)
         {
            _loc3_ = new MessagePerformanceInfo();
            if(recordMessageTimes)
            {
               _loc3_.sendTime = new Date().getTime();
            }
            param1.message.headers[MessagePerformanceUtils.MPI_HEADER_IN] = _loc3_;
         }
         var _loc2_:IMessage = param1.message;
         if(this.useSmallMessages && _loc2_ is ISmallMessage)
         {
            _loc4_ = ISmallMessage(_loc2_).getSmallMessage();
            if(_loc4_ != null)
            {
               _loc2_ = _loc4_;
            }
         }
         this._nc.call(null,param1,_loc2_);
      }
      
      public function AppendToGatewayUrl(param1:String) : void
      {
         if(param1 != null && param1 != "" && param1 != this.mx_internal::_appendToURL)
         {
            if(Log.isDebug())
            {
               _log.debug("\'{0}\' channel will disconnect and reconnect with with its session identifier \'{1}\' appended to its endpoint url \n",id,param1);
            }
            this.mx_internal::_appendToURL = param1;
         }
      }
      
      public function receive(param1:IMessage, ... rest) : void
      {
         var mpiutil:MessagePerformanceUtils = null;
         var msg:IMessage = param1;
         if(Log.isDebug())
         {
            _log.debug("\'{0}\' channel got message\n{1}\n",id,msg.toString());
            if(this.mpiEnabled)
            {
               try
               {
                  mpiutil = new MessagePerformanceUtils(msg);
                  _log.debug(mpiutil.prettyPrint());
               }
               catch(e:Error)
               {
                  _log.debug("Could not get message performance information for: " + msg.toString());
               }
            }
         }
         dispatchEvent(MessageEvent.createEvent(MessageEvent.MESSAGE,msg));
      }
      
      protected function shutdownNetConnection() : void
      {
         this._nc.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.securityErrorHandler);
         this._nc.removeEventListener(IOErrorEvent.IO_ERROR,this.ioErrorHandler);
         this._nc.removeEventListener(NetStatusEvent.NET_STATUS,this.statusHandler);
         this._nc.removeEventListener(AsyncErrorEvent.ASYNC_ERROR,this.asyncErrorHandler);
         this._nc.close();
      }
      
      protected function statusHandler(param1:NetStatusEvent) : void
      {
      }
      
      protected function securityErrorHandler(param1:SecurityErrorEvent) : void
      {
         this.defaultErrorHandler("Channel.Security.Error",param1);
      }
      
      protected function ioErrorHandler(param1:IOErrorEvent) : void
      {
         this.defaultErrorHandler("Channel.IO.Error",param1);
      }
      
      protected function asyncErrorHandler(param1:AsyncErrorEvent) : void
      {
         this.defaultErrorHandler("Channel.Async.Error",param1);
      }
      
      private function defaultErrorHandler(param1:String, param2:ErrorEvent) : void
      {
         var _loc3_:ChannelFaultEvent = ChannelFaultEvent.createEvent(this,false,param1,"error",param2.text + " url: \'" + endpoint + "\'");
         _loc3_.rootCause = param2;
         if(_connecting)
         {
            connectFailed(_loc3_);
         }
         else
         {
            dispatchEvent(_loc3_);
         }
      }
   }
}

import mx.core.mx_internal;
import mx.messaging.MessageAgent;
import mx.messaging.MessageResponder;
import mx.messaging.events.ChannelEvent;
import mx.messaging.events.ChannelFaultEvent;
import mx.messaging.messages.AcknowledgeMessage;
import mx.messaging.messages.AsyncMessage;
import mx.messaging.messages.ErrorMessage;
import mx.messaging.messages.IMessage;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

use namespace mx_internal;

class NetConnectionMessageResponder extends MessageResponder
{
   
   private var handled:Boolean;
   
   private var resourceManager:IResourceManager = ResourceManager.getInstance();
   
   public function NetConnectionMessageResponder(param1:MessageAgent, param2:IMessage, param3:NetConnectionChannel)
   {
      super(param1,param2,param3);
      param3.addEventListener(ChannelEvent.DISCONNECT,this.channelDisconnectHandler);
      param3.addEventListener(ChannelFaultEvent.FAULT,this.channelFaultHandler);
   }
   
   override protected function resultHandler(param1:IMessage) : void
   {
      var _loc2_:ErrorMessage = null;
      if(this.handled)
      {
         return;
      }
      this.disconnect();
      if(param1 is AsyncMessage)
      {
         if(AsyncMessage(param1).correlationId == message.messageId)
         {
            agent.acknowledge(param1 as AcknowledgeMessage,message);
         }
         else
         {
            _loc2_ = new ErrorMessage();
            _loc2_.faultCode = "Server.Acknowledge.Failed";
            _loc2_.faultString = this.resourceManager.getString("messaging","ackFailed");
            _loc2_.faultDetail = this.resourceManager.getString("messaging","ackFailed.details",[message.messageId,AsyncMessage(param1).correlationId]);
            _loc2_.correlationId = message.messageId;
            agent.fault(_loc2_,message);
         }
      }
      else
      {
         _loc2_ = new ErrorMessage();
         _loc2_.faultCode = "Server.Acknowledge.Failed";
         _loc2_.faultString = this.resourceManager.getString("messaging","noAckMessage");
         _loc2_.faultDetail = this.resourceManager.getString("messaging","noAckMessage.details",[param1 ? param1.toString() : "null"]);
         _loc2_.correlationId = message.messageId;
         agent.fault(_loc2_,message);
      }
   }
   
   override protected function statusHandler(param1:IMessage) : void
   {
      var _loc2_:AcknowledgeMessage = null;
      var _loc3_:ErrorMessage = null;
      if(this.handled)
      {
         return;
      }
      this.disconnect();
      if(param1 is AsyncMessage)
      {
         if(AsyncMessage(param1).correlationId == message.messageId)
         {
            _loc2_ = new AcknowledgeMessage();
            _loc2_.correlationId = AsyncMessage(param1).correlationId;
            _loc2_.headers[AcknowledgeMessage.ERROR_HINT_HEADER] = true;
            agent.acknowledge(_loc2_,message);
            agent.fault(param1 as ErrorMessage,message);
         }
         else if(param1 is ErrorMessage)
         {
            agent.fault(param1 as ErrorMessage,message);
         }
         else
         {
            _loc3_ = new ErrorMessage();
            _loc3_.faultCode = "Server.Acknowledge.Failed";
            _loc3_.faultString = this.resourceManager.getString("messaging","noErrorForMessage");
            _loc3_.faultDetail = this.resourceManager.getString("messaging","noErrorForMessage.details",[message.messageId,AsyncMessage(param1).correlationId]);
            _loc3_.correlationId = message.messageId;
            agent.fault(_loc3_,message);
         }
      }
      else
      {
         _loc3_ = new ErrorMessage();
         _loc3_.faultCode = "Server.Acknowledge.Failed";
         _loc3_.faultString = this.resourceManager.getString("messaging","noAckMessage");
         _loc3_.faultDetail = this.resourceManager.getString("messaging","noAckMessage.details",[param1 ? param1.toString() : "null"]);
         _loc3_.correlationId = message.messageId;
         agent.fault(_loc3_,message);
      }
   }
   
   override protected function requestTimedOut() : void
   {
      this.statusHandler(createRequestTimeoutErrorMessage());
   }
   
   protected function channelDisconnectHandler(param1:ChannelEvent) : void
   {
      if(this.handled)
      {
         return;
      }
      this.disconnect();
      var _loc2_:ErrorMessage = new ErrorMessage();
      _loc2_.correlationId = message.messageId;
      _loc2_.faultString = this.resourceManager.getString("messaging","deliveryInDoubt");
      _loc2_.faultDetail = this.resourceManager.getString("messaging","deliveryInDoubt.details");
      _loc2_.faultCode = ErrorMessage.MESSAGE_DELIVERY_IN_DOUBT;
      _loc2_.rootCause = param1;
      agent.fault(_loc2_,message);
   }
   
   protected function channelFaultHandler(param1:ChannelFaultEvent) : void
   {
      if(this.handled)
      {
         return;
      }
      this.disconnect();
      var _loc2_:ErrorMessage = param1.createErrorMessage();
      _loc2_.correlationId = message.messageId;
      if(!param1.channel.connected)
      {
         _loc2_.faultCode = ErrorMessage.MESSAGE_DELIVERY_IN_DOUBT;
      }
      _loc2_.rootCause = param1;
      agent.fault(_loc2_,message);
   }
   
   private function disconnect() : void
   {
      this.handled = true;
      channel.removeEventListener(ChannelEvent.DISCONNECT,this.channelDisconnectHandler);
      channel.removeEventListener(ChannelFaultEvent.FAULT,this.channelFaultHandler);
   }
}
