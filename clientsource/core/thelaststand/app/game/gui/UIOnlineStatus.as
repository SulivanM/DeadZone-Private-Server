package thelaststand.app.game.gui
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   
   public class UIOnlineStatus extends Sprite
   {
      
      public static const STATUS_ONLINE:String = "online";
      
      public static const STATUS_OFFLINE:String = "offline";
      
      private var _status:String = "offline";
      
      private var bmp_icon:Bitmap;
      
      public function UIOnlineStatus(param1:Number = 8)
      {
         super();
         graphics.lineStyle(1,4868682);
         graphics.beginFill(2434341);
         graphics.drawCircle(param1,param1,param1);
         graphics.endFill();
         this.bmp_icon = new Bitmap(new BmpIconOnline(),"auto",true);
         this.bmp_icon.x = Math.round(param1 - this.bmp_icon.width * 0.5);
         this.bmp_icon.y = Math.round(param1 - this.bmp_icon.height * 0.5);
         addChild(this.bmp_icon);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this.bmp_icon.bitmapData.dispose();
         this.bmp_icon.bitmapData = null;
         this.bmp_icon = null;
      }
      
      public function get status() : String
      {
         return this._status;
      }
      
      public function set status(param1:String) : void
      {
         this._status = param1;
         this.bmp_icon.visible = this._status == STATUS_ONLINE;
      }
   }
}

