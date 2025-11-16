package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class AuthenticateStartDialog extends Message
   {
      
      public var name:String;
      
      public var arguments:Array = [];
      
      public var argumentsDummy:KeyValuePair = null;
      
      public function AuthenticateStartDialog()
      {
         super();
         registerField("name","",9,1,1);
         registerField("arguments","playerio.generated.messages.KeyValuePair",11,3,2);
      }
   }
}

