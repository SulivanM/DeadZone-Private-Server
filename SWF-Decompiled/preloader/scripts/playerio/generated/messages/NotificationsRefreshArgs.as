package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class NotificationsRefreshArgs extends Message
   {
      public var lastVersion:String;
      
      public function NotificationsRefreshArgs(param1:String)
      {
         super();
         registerField("lastVersion","",9,1,1);
         this.lastVersion = param1;
      }
   }
}

