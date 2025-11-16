package thelaststand.app.game.data
{
   import thelaststand.app.data.IOpponent;
   import thelaststand.common.lang.Language;
   
   public class UnknownOpponentData implements IOpponent
   {
      
      private var _id:String = "cpuOpponent";
      
      private var _level:int = 0;
      
      private var _nickname:String;
      
      private var _imageURI:String;
      
      public function UnknownOpponentData(param1:int)
      {
         super();
         this._level = param1;
         this._nickname = Language.getInstance().getString("enemies.unknown");
         this._imageURI = "images/ui/unknown-enemy.png";
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get level() : int
      {
         return this._level;
      }
      
      public function set level(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._level = param1;
      }
      
      public function get nickname() : String
      {
         return this._nickname;
      }
      
      public function get isPlayer() : Boolean
      {
         return false;
      }
      
      public function get imageURI() : String
      {
         return this._imageURI;
      }
   }
}

