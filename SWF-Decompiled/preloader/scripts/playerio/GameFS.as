package playerio
{
   public class GameFS
   {
      private static var maps:Object = {};
      
      private var gameId:String;
      
      public function GameFS(param1:String, param2:String)
      {
         super();
         this.gameId = param1;
         if(param2 != null)
         {
            maps[param1] = new UrlMap(param2);
         }
      }
      
      private static function getUrl(param1:String, param2:String, param3:Boolean = false) : String
      {
         var _loc4_:UrlMap = null;
         if(param2.indexOf("/") != 0)
         {
            throw new Error("GameFS paths must be absolute and start with a slash (/). IE client.gameFS.getURL(\"/folder/file.extention\")",0);
         }
         if(maps != null && maps[param1] != undefined)
         {
            _loc4_ = UrlMap(maps[param1]);
            return _loc4_.getUrl(param2,param3);
         }
         return (param3 ? "https" : "http") + "://r.playerio.com/r/" + param1 + param2;
      }
      
      public function getUrl(param1:String, param2:Boolean = false) : String
      {
         return GameFS.getUrl(gameId,param1,param2);
      }
   }
}

class UrlMap
{
   private var baseUrl:String;
   
   private var secureBaseUrl:String;
   
   private var map:Object = null;
   
   public function UrlMap(param1:String)
   {
      var _loc2_:Array = null;
      var _loc4_:int = 0;
      var _loc3_:String = null;
      super();
      if(param1 != null && param1 != "")
      {
         _loc2_ = param1.split("|");
         map = {};
         _loc4_ = 0;
         while(_loc4_ != _loc2_.length)
         {
            _loc3_ = _loc2_[_loc4_];
            if(_loc3_ == "alltoredirect" || _loc3_ == "cdnmap")
            {
               baseUrl = _loc2_[_loc4_ + 1];
            }
            else if(_loc3_ == "alltoredirectsecure" || _loc3_ == "cdnmapsecure")
            {
               secureBaseUrl = _loc2_[_loc4_ + 1];
            }
            else
            {
               map[_loc3_] = _loc2_[_loc4_ + 1];
            }
            _loc4_ += 2;
         }
      }
   }
   
   public function getUrl(param1:String, param2:Boolean) : String
   {
      if(map == null)
      {
         return (param2 ? secureBaseUrl : baseUrl) + param1;
      }
      if(map[param1] != undefined)
      {
         return (param2 ? secureBaseUrl : baseUrl) + map[param1];
      }
      return (param2 ? secureBaseUrl : baseUrl) + param1;
   }
}
