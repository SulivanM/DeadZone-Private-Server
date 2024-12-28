package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class SimpleGetCaptchaOutput extends Message
   {
      public var captchaKey:String;
      
      public var captchaImageUrl:String;
      
      public function SimpleGetCaptchaOutput()
      {
         super();
         registerField("captchaKey","",9,1,1);
         registerField("captchaImageUrl","",9,1,2);
      }
   }
}

