package thelaststand.app.game.gui.bounty
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.text.AntiAliasType;
   import flash.text.TextFormatAlign;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.lang.Language;
   
   public class BountyCapDisplay extends Sprite
   {
      
      private var txt_label:BodyTextField;
      
      private var txt_value:BodyTextField;
      
      private var bmp_star:Bitmap;
      
      private var _tooltip:TooltipManager;
      
      public function BountyCapDisplay()
      {
         super();
         var _loc1_:Number = 90;
         var _loc2_:Number = 28;
         var _loc3_:Number = 15;
         this.bmp_star = new Bitmap(new BmpIconBountyHunterSilver());
         this.bmp_star.y = _loc3_ + int((_loc2_ - this.bmp_star.height) * 0.5);
         this.bmp_star.filters = [new GlowFilter(0,0.8,6,6,2)];
         addChild(this.bmp_star);
         var _loc4_:Number = int(this.bmp_star.width * 0.5);
         this.txt_label = new BodyTextField({
            "color":7763574,
            "size":11,
            "bold":true,
            "align":TextFormatAlign.CENTER,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_label.text = Language.getInstance().getString("bounty.cap_title");
         this.txt_label.x = _loc4_;
         this.txt_label.maxWidth = _loc1_;
         addChild(this.txt_label);
         var _loc5_:int = Network.getInstance().playerData.bountyCap;
         this.txt_value = new BodyTextField({
            "color":(_loc5_ == 0 ? Effects.COLOR_WARNING : 13882323),
            "size":19,
            "bold":true,
            "autoSize":"none",
            "align":TextFormatAlign.CENTER,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_value.x = this.bmp_star.width;
         this.txt_value.y = _loc3_ + int((_loc2_ - this.txt_value.height) * 0.5) - 1;
         this.txt_value.width = _loc1_ - int(this.bmp_star.width * 0.5) - 10;
         this.txt_value.text = _loc5_.toString();
         addChild(this.txt_value);
         graphics.beginFill(7763574,1);
         graphics.drawRect(_loc4_,_loc3_,_loc1_,_loc2_);
         graphics.beginFill(2434341,1);
         graphics.drawRect(_loc4_ + 1,_loc3_ + 1,_loc1_ - 2,_loc2_ - 2);
         this._tooltip = TooltipManager.getInstance();
         this._tooltip.add(this,this.calcToolTip,new Point(Number.NaN,_loc3_),TooltipDirection.DIRECTION_DOWN);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.txt_value.dispose();
         this.txt_value = null;
         this.txt_label.dispose();
         this.txt_label = null;
         this.bmp_star.bitmapData.dispose();
         this.bmp_star = null;
         this._tooltip.removeAllFromParent(this);
         this._tooltip = null;
      }
      
      private function calcToolTip() : String
      {
         var _loc5_:Number = NaN;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc1_:Date = new Date(Network.getInstance().playerData.bountyCapTimestamp);
         var _loc2_:Date = new Date();
         var _loc3_:Number = _loc2_.time - _loc1_.time;
         var _loc4_:Number = 24 * 60 * 60 * 1000;
         if(_loc3_ < _loc4_)
         {
            _loc5_ = (_loc4_ - _loc3_) / 1000;
            _loc6_ = _loc5_ <= 5 * 60 ? "&lt; 5 mins" : DateTimeUtils.secondsToString(_loc5_,false);
            return Language.getInstance().getString("bounty.cap_tip_remaining",_loc6_);
         }
         return Language.getInstance().getString("bounty.cap_tip");
      }
   }
}

