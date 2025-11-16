package thelaststand.app.utils
{
   public class StringUtils
   {
      
      public function StringUtils()
      {
         super();
         throw new Error("StringUtils cannot be directly instantiated.");
      }
      
      public static function htmlSetDoubleBreakLeading(param1:String, param2:int = -8) : String
      {
         return param1.replace(/\<br\/?\>\<br\/?\>/ig,"<textformat leading=\'" + param2 + "\'><br/><br/></textformat>");
      }
      
      public static function htmlRemoveTrailingBreaks(param1:String) : String
      {
         return param1.replace(/(\<br\/?\>\s*)*$/ig,"");
      }
      
      public static function removeTrailingBreaks(param1:String) : String
      {
         return param1.replace(/(\\r\s*)*$/ig,"");
      }
   }
}

