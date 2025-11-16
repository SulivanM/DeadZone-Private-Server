package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class NotificationsSendArgs extends Message
   {
      
      public var notifications:Array = [];
      
      public var notificationsDummy:Notification = null;
      
      public function NotificationsSendArgs(param1:Array)
      {
         super();
         registerField("notifications","playerio.generated.messages.Notification",11,3,1);
         this.notifications = param1;
      }
   }
}

