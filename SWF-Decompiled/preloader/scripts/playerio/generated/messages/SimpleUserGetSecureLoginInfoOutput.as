package playerio.generated.messages
{
   import com.protobuf.Message;
   import flash.utils.ByteArray;
   
   public final class SimpleUserGetSecureLoginInfoOutput extends Message
   {
      public var publicKey:ByteArray;
      
      public var nonce:String;
      
      public function SimpleUserGetSecureLoginInfoOutput()
      {
         super();
         registerField("publicKey","",12,1,1);
         registerField("nonce","",9,1,2);
      }
   }
}

