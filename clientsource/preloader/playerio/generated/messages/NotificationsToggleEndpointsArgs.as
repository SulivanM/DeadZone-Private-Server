package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class NotificationsToggleEndpointsArgs extends Message
   {
      
      public var lastVersion:String;
      
      public var endpoints:Array = [];
      
      public var endpointsDummy:NotificationsEndpointId = null;
      
      public var enabled:Boolean;
      
      public function NotificationsToggleEndpointsArgs(param1:String, param2:Array, param3:Boolean)
      {
         super();
         registerField("lastVersion","",9,1,1);
         registerField("endpoints","playerio.generated.messages.NotificationsEndpointId",11,3,2);
         registerField("enabled","",8,1,3);
         this.lastVersion = param1;
         this.endpoints = param2;
         this.enabled = param3;
      }
   }
}

