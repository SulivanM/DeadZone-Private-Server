package mx.rpc
{
   import mx.core.mx_internal;
   import mx.messaging.Producer;
   import mx.messaging.events.MessageEvent;
   import mx.messaging.events.MessageFaultEvent;
   import mx.messaging.messages.AcknowledgeMessage;
   import mx.messaging.messages.ErrorMessage;
   import mx.messaging.messages.IMessage;
   
   use namespace mx_internal;
   
   public class AsyncRequest extends Producer
   {
      
      private var _pendingRequests:Object = {};
      
      public function AsyncRequest()
      {
         super();
      }
      
      override public function acknowledge(param1:AcknowledgeMessage, param2:IMessage) : void
      {
         var _loc4_:String = null;
         var _loc5_:IResponder = null;
         var _loc3_:Boolean = Boolean(param1.headers[AcknowledgeMessage.ERROR_HINT_HEADER]);
         super.acknowledge(param1,param2);
         if(!_loc3_)
         {
            _loc4_ = param1.correlationId;
            _loc5_ = IResponder(this._pendingRequests[_loc4_]);
            if(_loc5_)
            {
               delete this._pendingRequests[_loc4_];
               _loc5_.result(MessageEvent.createEvent(MessageEvent.RESULT,param1));
            }
         }
      }
      
      override public function fault(param1:ErrorMessage, param2:IMessage) : void
      {
         super.fault(param1,param2);
         if(_ignoreFault)
         {
            return;
         }
         var _loc3_:String = param2.messageId;
         var _loc4_:IResponder = IResponder(this._pendingRequests[_loc3_]);
         if(_loc4_)
         {
            delete this._pendingRequests[_loc3_];
            _loc4_.fault(MessageFaultEvent.createEvent(param1));
         }
      }
      
      override public function hasPendingRequestForMessage(param1:IMessage) : Boolean
      {
         var _loc2_:String = param1.messageId;
         return this._pendingRequests[_loc2_];
      }
      
      public function invoke(param1:IMessage, param2:IResponder) : void
      {
         this._pendingRequests[param1.messageId] = param2;
         send(param1);
      }
   }
}

