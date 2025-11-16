package thelaststand.app.display
{
   import thelaststand.common.lang.Language;
   
   public class BodyTextField extends BasicTextField
   {
      
      public function BodyTextField(param1:Object = null)
      {
         if(param1 == null)
         {
            param1 = {};
         }
         if(!param1.hasOwnProperty("font"))
         {
            param1.font = Language.getInstance().getFontName("body");
         }
         super(param1);
      }
   }
}

