package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class NotificationsToggleEndpointsOutput extends Message
   {
      
      public var version:String;
      
      public var endpoints:Array = [];
      
      public var endpointsDummy:NotificationsEndpoint = null;
      
      public function NotificationsToggleEndpointsOutput()
      {
         super();
         registerField("version","",9,1,1);
         registerField("endpoints","playerio.generated.messages.NotificationsEndpoint",11,3,2);
      }
   }
}

