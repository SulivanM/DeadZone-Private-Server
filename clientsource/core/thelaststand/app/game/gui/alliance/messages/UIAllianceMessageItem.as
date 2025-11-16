package thelaststand.app.game.gui.alliance.messages
{
   import flash.display.BitmapData;
   import thelaststand.app.game.data.alliance.AllianceMessage;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.common.lang.Language;
   
   public class UIAllianceMessageItem extends UIComponent
   {
      
      protected static var tape_bd:BitmapData = new BmpAllianceMessageTape();
      
      private var _message:AllianceMessage;
      
      protected var _width:int;
      
      protected var _height:int;
      
      public function UIAllianceMessageItem(param1:AllianceMessage, param2:int)
      {
         super();
         this._message = param1;
         this._width = param2;
      }
      
      public static function create(param1:AllianceMessage, param2:int) : UIAllianceMessageItem
      {
         switch(param1.playerId)
         {
            case "admin":
               return new UIAllianceAdminMessageItem(param1,param2);
            default:
               return new UIAllianceMemberMessageItem(param1,param2);
         }
      }
      
      public function get message() : AllianceMessage
      {
         return this._message;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._message = null;
      }
      
      protected function getPostDate() : String
      {
         var _loc1_:Array = Language.getInstance().getString("months").split(",");
         return _loc1_[this._message.date.month] + " " + this._message.date.date;
      }
   }
}

