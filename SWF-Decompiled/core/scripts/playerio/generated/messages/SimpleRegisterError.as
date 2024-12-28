package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class SimpleRegisterError extends Message
   {
      public var errorCode:int;
      
      public var message:String;
      
      public var usernameError:String;
      
      public var passwordError:String;
      
      public var emailError:String;
      
      public var captchaError:String;
      
      public function SimpleRegisterError()
      {
         super();
         registerField("errorCode","",5,1,1);
         registerField("message","",9,1,2);
         registerField("usernameError","",9,1,3);
         registerField("passwordError","",9,1,4);
         registerField("emailError","",9,1,5);
         registerField("captchaError","",9,1,6);
      }
   }
}

