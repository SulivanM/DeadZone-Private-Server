package mx.rpc
{
   import flash.events.EventDispatcher;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import mx.messaging.messages.IMessage;
   import mx.rpc.events.FaultEvent;
   import mx.rpc.events.ResultEvent;
   
   use namespace mx_internal;
   
   public dynamic class AsyncToken extends EventDispatcher
   {
      
      private var _message:IMessage;
      
      private var _responders:Array;
      
      private var _result:Object;
      
      public function AsyncToken(param1:IMessage = null)
      {
         super();
         this._message = param1;
      }
      
      public function get message() : IMessage
      {
         return this._message;
      }
      
      mx_internal function setMessage(param1:IMessage) : void
      {
         this._message = param1;
      }
      
      public function get responders() : Array
      {
         return this._responders;
      }
      
      [Bindable(event="propertyChange")]
      public function get result() : Object
      {
         return this._result;
      }
      
      public function addResponder(param1:IResponder) : void
      {
         if(this._responders == null)
         {
            this._responders = [];
         }
         this._responders.push(param1);
      }
      
      public function hasResponder() : Boolean
      {
         return this._responders != null && this._responders.length > 0;
      }
      
      mx_internal function applyFault(param1:FaultEvent) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:IResponder = null;
         if(this._responders != null)
         {
            _loc2_ = 0;
            while(_loc2_ < this._responders.length)
            {
               _loc3_ = this._responders[_loc2_];
               if(_loc3_ != null)
               {
                  _loc3_.fault(param1);
               }
               _loc2_++;
            }
         }
      }
      
      mx_internal function applyResult(param1:ResultEvent) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:IResponder = null;
         this.mx_internal::setResult(param1.result);
         if(this._responders != null)
         {
            _loc2_ = 0;
            while(_loc2_ < this._responders.length)
            {
               _loc3_ = this._responders[_loc2_];
               if(_loc3_ != null)
               {
                  _loc3_.result(param1);
               }
               _loc2_++;
            }
         }
      }
      
      mx_internal function setResult(param1:Object) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         if(this._result !== param1)
         {
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"result",this._result,param1);
            this._result = param1;
            dispatchEvent(_loc2_);
         }
      }
   }
}

