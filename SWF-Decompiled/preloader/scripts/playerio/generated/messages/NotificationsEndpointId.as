package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class NotificationsEndpointId extends Message
   {
      public var type:String;
      
      public var identifier:String;
      
      public function NotificationsEndpointId()
      {
         super();
         registerField("type","",9,1,1);
         registerField("identifier","",9,1,2);
      }
   }
}

