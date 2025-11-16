package mx.messaging
{
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import mx.logging.Log;
   import mx.messaging.messages.AbstractMessage;
   import mx.messaging.messages.AsyncMessage;
   import mx.messaging.messages.IMessage;
   
   use namespace mx_internal;
   
   public class Producer extends AbstractProducer
   {
      
      public static const DEFAULT_PRIORITY:int = 4;
      
      private var _subtopic:String = "";
      
      public function Producer()
      {
         super();
         _log = Log.getLogger("mx.messaging.Producer");
         _agentType = "producer";
      }
      
      [Bindable(event="propertyChange")]
      public function get subtopic() : String
      {
         return this._subtopic;
      }
      
      public function set subtopic(param1:String) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         if(this._subtopic != param1)
         {
            if(param1 == null)
            {
               param1 = "";
            }
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"subtopic",this._subtopic,param1);
            this._subtopic = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      override protected function internalSend(param1:IMessage, param2:Boolean = true) : void
      {
         if(this.subtopic.length > 0)
         {
            param1.headers[AsyncMessage.SUBTOPIC_HEADER] = this.subtopic;
         }
         this.handlePriority(param1);
         super.internalSend(param1,param2);
      }
      
      private function handlePriority(param1:IMessage) : void
      {
         var _loc2_:int = 0;
         if(param1.headers[AbstractMessage.PRIORITY_HEADER] != null)
         {
            _loc2_ = int(param1.headers[AbstractMessage.PRIORITY_HEADER]);
            if(_loc2_ < 0)
            {
               param1.headers[AbstractMessage.PRIORITY_HEADER] = 0;
            }
            else if(_loc2_ > 9)
            {
               param1.headers[AbstractMessage.PRIORITY_HEADER] = 9;
            }
         }
         else if(priority > -1)
         {
            param1.headers[AbstractMessage.PRIORITY_HEADER] = priority;
         }
      }
   }
}

