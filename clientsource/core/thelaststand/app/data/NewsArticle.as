package thelaststand.app.data
{
   public class NewsArticle
   {
      
      public var date:Date;
      
      public var body:String;
      
      public function NewsArticle(param1:String, param2:String)
      {
         super();
         var _loc3_:Array = param1.split("-");
         this.date = new Date(int(_loc3_[0]),int(_loc3_[1]) - 1,int(_loc3_[2]));
         this.body = unescape(param2);
      }
   }
}

