package mx.messaging.events
{
   import flash.events.Event;
   import mx.messaging.messages.AcknowledgeMessage;
   import mx.messaging.messages.IMessage;
   
   public class MessageAckEvent extends MessageEvent
   {
      
      public static const ACKNOWLEDGE:String = "acknowledge";
      
      public var correlation:IMessage;
      
      public function MessageAckEvent(param1:String, param2:Boolean = false, param3:Boolean = false, param4:AcknowledgeMessage = null, param5:IMessage = null)
      {
         super(param1,param2,param3,param4);
         this.correlation = param5;
      }
      
      public static function createEvent(param1:AcknowledgeMessage = null, param2:IMessage = null) : MessageAckEvent
      {
         return new MessageAckEvent(MessageAckEvent.ACKNOWLEDGE,false,false,param1,param2);
      }
      
      public function get acknowledgeMessage() : AcknowledgeMessage
      {
         return message as AcknowledgeMessage;
      }
      
      public function get correlationId() : String
      {
         if(this.correlation != null)
         {
            return this.correlation.messageId;
         }
         return null;
      }
      
      override public function clone() : Event
      {
         return new MessageAckEvent(type,bubbles,cancelable,message as AcknowledgeMessage,this.correlation);
      }
      
      override public function toString() : String
      {
         return formatToString("MessageAckEvent","messageId","correlationId","type","bubbles","cancelable","eventPhase");
      }
   }
}

