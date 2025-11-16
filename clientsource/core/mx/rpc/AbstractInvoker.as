package mx.rpc
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.getQualifiedClassName;
   import mx.core.mx_internal;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.messaging.errors.MessagingError;
   import mx.messaging.events.MessageEvent;
   import mx.messaging.events.MessageFaultEvent;
   import mx.messaging.messages.AsyncMessage;
   import mx.messaging.messages.IMessage;
   import mx.netmon.NetworkMonitor;
   import mx.resources.IResourceManager;
   import mx.resources.ResourceManager;
   import mx.rpc.events.AbstractEvent;
   import mx.rpc.events.FaultEvent;
   import mx.rpc.events.InvokeEvent;
   import mx.rpc.events.ResultEvent;
   import mx.utils.ObjectProxy;
   
   use namespace mx_internal;
   
   public class AbstractInvoker extends EventDispatcher
   {
      
      mx_internal static const BINDING_RESULT:String = "resultForBinding";
      
      private var resourceManager:IResourceManager = ResourceManager.getInstance();
      
      public var operationManager:Function;
      
      public var resultType:Class;
      
      public var resultElementType:Class;
      
      mx_internal var activeCalls:ActiveCalls;
      
      mx_internal var _responseHeaders:Array;
      
      mx_internal var _result:Object;
      
      mx_internal var _makeObjectsBindable:Boolean;
      
      private var _asyncRequest:AsyncRequest;
      
      private var _log:ILogger;
      
      public function AbstractInvoker()
      {
         super();
         this._log = Log.getLogger("mx.rpc.AbstractInvoker");
         this.mx_internal::activeCalls = new ActiveCalls();
      }
      
      [Bindable("resultForBinding")]
      public function get lastResult() : Object
      {
         return this.mx_internal::_result;
      }
      
      public function get makeObjectsBindable() : Boolean
      {
         return this.mx_internal::_makeObjectsBindable;
      }
      
      public function set makeObjectsBindable(param1:Boolean) : void
      {
         this.mx_internal::_makeObjectsBindable = param1;
      }
      
      public function cancel(param1:String = null) : AsyncToken
      {
         if(param1 != null)
         {
            return this.mx_internal::activeCalls.removeCall(param1);
         }
         return this.mx_internal::activeCalls.cancelLast();
      }
      
      public function clearResult(param1:Boolean = true) : void
      {
         if(param1)
         {
            this.setResult(null);
         }
         else
         {
            this.mx_internal::_result = null;
         }
      }
      
      public function setResult(param1:Object) : void
      {
         this.mx_internal::_result = param1;
         dispatchEvent(new Event(mx_internal::BINDING_RESULT));
      }
      
      mx_internal function dispatchRpcEvent(param1:AbstractEvent) : void
      {
         param1.mx_internal::callTokenResponders();
         if(!param1.isDefaultPrevented())
         {
            dispatchEvent(param1);
         }
      }
      
      mx_internal function monitorRpcEvent(param1:AbstractEvent) : void
      {
         if(NetworkMonitor.isMonitoring())
         {
            if(param1 is ResultEvent)
            {
               NetworkMonitor.monitorResult(param1.message,ResultEvent(param1).result);
            }
            else if(param1 is FaultEvent)
            {
               NetworkMonitor.monitorFault(param1.message,FaultEvent(param1).fault);
            }
         }
      }
      
      mx_internal function resultHandler(param1:MessageEvent) : void
      {
         var _loc3_:ResultEvent = null;
         var _loc2_:AsyncToken = this.mx_internal::preHandle(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(this.mx_internal::processResult(param1.message,_loc2_))
         {
            dispatchEvent(new Event(mx_internal::BINDING_RESULT));
            _loc3_ = ResultEvent.createEvent(this.mx_internal::_result,_loc2_,param1.message);
            _loc3_.headers = this.mx_internal::_responseHeaders;
            this.mx_internal::dispatchRpcEvent(_loc3_);
         }
      }
      
      mx_internal function faultHandler(param1:MessageFaultEvent) : void
      {
         var _loc4_:Fault = null;
         var _loc5_:FaultEvent = null;
         var _loc2_:MessageEvent = MessageEvent.createEvent(MessageEvent.MESSAGE,param1.message);
         var _loc3_:AsyncToken = this.mx_internal::preHandle(_loc2_);
         if(_loc3_ == null && AsyncMessage(param1.message).correlationId != null && AsyncMessage(param1.message).correlationId != "" && param1.faultCode != "Client.Authentication")
         {
            return;
         }
         if(this.mx_internal::processFault(param1.message,_loc3_))
         {
            _loc4_ = new Fault(param1.faultCode,param1.faultString,param1.faultDetail);
            _loc4_.content = param1.message.body;
            _loc4_.rootCause = param1.rootCause;
            _loc5_ = FaultEvent.createEvent(_loc4_,_loc3_,param1.message);
            _loc5_.headers = this.mx_internal::_responseHeaders;
            this.mx_internal::dispatchRpcEvent(_loc5_);
         }
      }
      
      mx_internal function getNetmonId() : String
      {
         return null;
      }
      
      mx_internal function invoke(param1:IMessage, param2:AsyncToken = null) : AsyncToken
      {
         var fault:Fault = null;
         var errorText:String = null;
         var message:IMessage = param1;
         var token:AsyncToken = param2;
         if(token == null)
         {
            token = new AsyncToken(message);
         }
         else
         {
            token.mx_internal::setMessage(message);
         }
         this.mx_internal::activeCalls.addCall(message.messageId,token);
         try
         {
            this.mx_internal::asyncRequest.invoke(message,new Responder(this.mx_internal::resultHandler,this.mx_internal::faultHandler));
            this.mx_internal::dispatchRpcEvent(InvokeEvent.createEvent(token,message));
         }
         catch(e:MessagingError)
         {
            _log.warn(e.toString());
            errorText = resourceManager.getString("rpc","cannotConnectToDestination",[mx_internal::asyncRequest.destination]);
            fault = new Fault("InvokeFailed",e.toString(),errorText);
            new AsyncDispatcher(mx_internal::dispatchRpcEvent,[FaultEvent.createEvent(fault,token,message)],10);
         }
         catch(e2:Error)
         {
            _log.warn(e2.toString());
            fault = new Fault("InvokeFailed",e2.message);
            new AsyncDispatcher(mx_internal::dispatchRpcEvent,[FaultEvent.createEvent(fault,token,message)],10);
         }
         return token;
      }
      
      mx_internal function preHandle(param1:MessageEvent) : AsyncToken
      {
         return this.mx_internal::activeCalls.removeCall(AsyncMessage(param1.message).correlationId);
      }
      
      mx_internal function processFault(param1:IMessage, param2:AsyncToken) : Boolean
      {
         return true;
      }
      
      mx_internal function processResult(param1:IMessage, param2:AsyncToken) : Boolean
      {
         var _loc3_:Object = param1.body;
         if(this.makeObjectsBindable && _loc3_ != null && getQualifiedClassName(_loc3_) == "Object")
         {
            this.mx_internal::_result = new ObjectProxy(_loc3_);
         }
         else
         {
            this.mx_internal::_result = _loc3_;
         }
         return true;
      }
      
      mx_internal function get asyncRequest() : AsyncRequest
      {
         if(this._asyncRequest == null)
         {
            this._asyncRequest = new AsyncRequest();
         }
         return this._asyncRequest;
      }
      
      mx_internal function set asyncRequest(param1:AsyncRequest) : void
      {
         this._asyncRequest = param1;
      }
   }
}

