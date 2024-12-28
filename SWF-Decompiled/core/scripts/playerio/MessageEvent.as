package playerio
{
   import flash.events.Event;
   
   public class MessageEvent extends Event
   {
      public static const ON_MESSAGE:String = "onMessage";
      
      public var message:Message;
      
      public function MessageEvent(param1:String, param2:Message)
      {
         this.message = param2;
         super(param1);
      }
      
      override public function clone() : Event
      {
         return new MessageEvent(type,message);
      }
   }
}

