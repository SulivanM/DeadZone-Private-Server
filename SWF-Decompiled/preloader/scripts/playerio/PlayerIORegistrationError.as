package playerio
{
   public class PlayerIORegistrationError extends PlayerIOError
   {
      public var usernameError:String;
      
      public var passwordError:String;
      
      public var emailError:String;
      
      public var captchaError:String;
      
      public function PlayerIORegistrationError(param1:String, param2:int, param3:String, param4:String, param5:String, param6:String)
      {
         super(param1,param2);
         this.usernameError = param3;
         this.passwordError = param4;
         this.emailError = param5;
         this.captchaError = param6;
      }
   }
}

