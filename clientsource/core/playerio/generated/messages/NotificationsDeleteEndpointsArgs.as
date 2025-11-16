package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class NotificationsDeleteEndpointsArgs extends Message
   {
      
      public var lastVersion:String;
      
      public var endpoints:Array = [];
      
      public var endpointsDummy:NotificationsEndpointId = null;
      
      public function NotificationsDeleteEndpointsArgs(param1:String, param2:Array)
      {
         super();
         registerField("lastVersion","",9,1,1);
         registerField("endpoints","playerio.generated.messages.NotificationsEndpointId",11,3,2);
         this.lastVersion = param1;
         this.endpoints = param2;
      }
   }
}

