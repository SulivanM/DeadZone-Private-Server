package thelaststand.app.game.gui.map
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.osflash.signals.natives.NativeSignal;
   import thelaststand.app.core.Config;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   
   public class UIMapAssignmentPin extends Sprite
   {
      
      protected var _id:String;
      
      protected var _xml:XML;
      
      private var mc_hitArea:Sprite;
      
      private var mc_icon:Sprite;
      
      private var txt_name:BodyTextField;
      
      private var txt_level:BodyTextField;
      
      private var bmp_icon:Bitmap;
      
      public var clicked:NativeSignal;
      
      public function UIMapAssignmentPin(param1:String)
      {
         super();
         this._id = param1;
         this._xml = this.getXML();
         this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
         this.mc_hitArea = new Sprite();
         this.mc_hitArea.graphics.beginFill(0,0);
         this.mc_hitArea.graphics.drawCircle(0,0,60);
         this.mc_hitArea.graphics.endFill();
         addChild(this.mc_hitArea);
         this.bmp_icon = new Bitmap(this.getIcon(),"auto",true);
         this.bmp_icon.x = -int(this.bmp_icon.width / 2);
         this.bmp_icon.y = -int(this.bmp_icon.height / 2);
         this.mc_icon = new Sprite();
         this.mc_icon.addChild(this.bmp_icon);
         addChild(this.mc_icon);
         this.txt_name = new BodyTextField({
            "color":16777215,
            "size":16,
            "bold":true,
            "filters":[Effects.STROKE]
         });
         this.txt_name.text = this.getName().toUpperCase();
         this.txt_name.x = -int(this.txt_name.width / 2);
         this.txt_name.y = int(this.mc_icon.height / 2) - 6;
         addChild(this.txt_name);
         var _loc2_:int = int(this._xml.level_min);
         var _loc3_:int = int(int(this._xml.level_max) || int(Config.constant.MAX_SURVIVOR_LEVEL));
         this.txt_level = new BodyTextField({
            "color":16763904,
            "size":13,
            "bold":true,
            "filters":[Effects.STROKE]
         });
         this.txt_level.text = "LVL " + (_loc2_ + 1) + "-" + (_loc3_ + 1);
         this.txt_level.x = -int(this.txt_level.width / 2);
         this.txt_level.y = int(this.txt_name.y + this.txt_name.height - 2);
         addChild(this.txt_level);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         TweenMax.killChildTweensOf(this);
         this.bmp_icon.bitmapData.dispose();
         this.txt_name.dispose();
         this.txt_level.dispose();
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         TweenMax.to(this.mc_icon,0.1,{
            "scaleX":1.05,
            "scaleY":1.05
         });
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         TweenMax.to(this.mc_icon,0.25,{
            "scaleX":1,
            "scaleY":1
         });
      }
      
      protected function getXML() : XML
      {
         throw new Error("This function must be overridden by subclasses.");
      }
      
      protected function getIcon() : BitmapData
      {
         throw new Error("This function must be overridden by subclasses.");
      }
      
      protected function getName() : String
      {
         throw new Error("This function must be overridden by subclasses.");
      }
   }
}

