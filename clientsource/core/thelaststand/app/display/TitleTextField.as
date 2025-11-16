package thelaststand.app.display
{
   import thelaststand.common.lang.Language;
   
   public class TitleTextField extends BasicTextField
   {
      
      public function TitleTextField(param1:Object = null)
      {
         if(param1 == null)
         {
            param1 = {};
         }
         if(!param1.hasOwnProperty("font"))
         {
            param1.font = Language.getInstance().getFontName("title");
         }
         super(param1);
      }
   }
}

