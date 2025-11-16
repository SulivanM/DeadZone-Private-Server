package mx.messaging
{
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import mx.messaging.messages.AsyncMessage;
   import mx.messaging.messages.CommandMessage;
   import mx.messaging.messages.IMessage;
   
   use namespace mx_internal;
   
   public class Consumer extends AbstractConsumer
   {
      
      private var _selector:String = "";
      
      private var _subtopic:String = "";
      
      public function Consumer(param1:String = "flex.messaging.messages.AsyncMessage")
      {
         super();
      }
      
      [Bindable(event="propertyChange")]
      public function get selector() : String
      {
         return this._selector;
      }
      
      public function set selector(param1:String) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         var _loc3_:Boolean = false;
         if(this._selector !== param1)
         {
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"selector",this._selector,param1);
            _loc3_ = false;
            if(subscribed)
            {
               unsubscribe();
               _loc3_ = true;
            }
            this._selector = param1;
            if(_loc3_)
            {
               subscribe(clientId);
            }
            dispatchEvent(_loc2_);
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get subtopic() : String
      {
         return this._subtopic;
      }
      
      public function set subtopic(param1:String) : void
      {
         var _loc2_:Boolean = false;
         if(this.subtopic != param1)
         {
            _loc2_ = false;
            if(subscribed)
            {
               unsubscribe();
               _loc2_ = true;
            }
            this._subtopic = param1;
            if(_loc2_)
            {
               subscribe();
            }
         }
      }
      
      override protected function internalSend(param1:IMessage, param2:Boolean = true) : void
      {
         if(this.subtopic.length > 0)
         {
            param1.headers[AsyncMessage.SUBTOPIC_HEADER] = this.subtopic;
         }
         if(this._selector.length > 0)
         {
            param1.headers[CommandMessage.SELECTOR_HEADER] = this._selector;
         }
         super.internalSend(param1,param2);
      }
   }
}

