package thelaststand.app.game.gui.store
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.common.lang.Language;
   
   public class UIFuelCounter extends Sprite
   {
      
      private var _network:Network;
      
      private var bmp_fuelIcon:Bitmap;
      
      private var bmp_addButton:Bitmap;
      
      private var bmp_add:Bitmap;
      
      private var mc_background:Sprite;
      
      private var txt_amount:BodyTextField;
      
      public function UIFuelCounter()
      {
         super();
         this._network = Network.getInstance();
         this._network.playerData.compound.resources.resourceChanged.add(this.onResourceChanged);
         this.mc_background = new Sprite();
         this.mc_background.graphics.beginFill(2499618);
         this.mc_background.graphics.drawRect(0,0,80,23);
         this.mc_background.graphics.endFill();
         this.mc_background.filters = [new GlowFilter(7039851,0.75,3,3,3,2)];
         addChild(this.mc_background);
         this.bmp_addButton = new Bitmap(new BmpResourceAddButton());
         this.bmp_addButton.x = int(this.mc_background.x + this.mc_background.width);
         this.bmp_addButton.y = int(this.mc_background.y + (this.mc_background.height - this.bmp_addButton.height) * 0.5);
         addChildAt(this.bmp_addButton,0);
         this.bmp_add = new Bitmap(new BmpIconAddResource());
         this.bmp_add.x = int(this.bmp_addButton.x + this.bmp_addButton.width - this.bmp_add.width - 4);
         this.bmp_add.y = int(this.bmp_addButton.y + (this.bmp_addButton.height - this.bmp_add.height) * 0.5);
         addChild(this.bmp_add);
         this.bmp_fuelIcon = new Bitmap(new BmpIconFuel());
         this.bmp_fuelIcon.x = -int(this.bmp_fuelIcon.width * 0.5);
         this.bmp_fuelIcon.y = int(this.mc_background.y + (this.mc_background.height - this.bmp_fuelIcon.height) * 0.5);
         this.bmp_fuelIcon.filters = [Effects.ICON_SHADOW];
         addChild(this.bmp_fuelIcon);
         this.txt_amount = new BodyTextField({
            "color":16777215,
            "size":16,
            "bold":true,
            "filters":[Effects.STROKE]
         });
         this.txt_amount.text = NumberFormatter.format(this._network.playerData.compound.resources.getAmount(GameResources.CASH),0);
         this.txt_amount.x = int(this.mc_background.x + (this.mc_background.width - this.txt_amount.width) * 0.5 + this.bmp_fuelIcon.width * 0.25);
         this.txt_amount.y = int(this.mc_background.y + (this.mc_background.height - this.txt_amount.height) * 0.5 - 1);
         addChild(this.txt_amount);
         mouseChildren = false;
         buttonMode = true;
         TooltipManager.getInstance().add(this,Language.getInstance().getString("tooltip.res_fuel"),new Point(width,NaN),TooltipDirection.DIRECTION_LEFT);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
      }
      
      public function dispose() : void
      {
         this.bmp_fuelIcon.bitmapData.dispose();
         this.bmp_fuelIcon.bitmapData = null;
         this.bmp_addButton.bitmapData.dispose();
         this.bmp_addButton.bitmapData = null;
         this.bmp_add.bitmapData.dispose();
         this.bmp_add.bitmapData = null;
         this._network.playerData.compound.resources.resourceChanged.remove(this.onResourceChanged);
         this._network = null;
         TooltipManager.getInstance().removeAllFromParent(this,true);
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
      
      private function onResourceChanged(param1:String, param2:int) : void
      {
         if(param1 == GameResources.CASH)
         {
            this.txt_amount.text = NumberFormatter.format(param2,0);
            this.txt_amount.x = int(this.mc_background.x + (this.mc_background.width - this.txt_amount.width) * 0.5 + this.bmp_fuelIcon.width * 0.25);
         }
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         PaymentSystem.getInstance().openBuyCoinsScreen(false);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(param1.buttonDown)
         {
            return;
         }
         TweenMax.to(this.bmp_add,0,{
            "colorTransform":{"exposure":1.1},
            "glowFilter":{
               "color":7065090,
               "alpha":1,
               "blurX":8,
               "blurY":8,
               "strength":2,
               "quality":1
            },
            "overwrite":true
         });
         TweenMax.to(this.mc_background,0,{
            "colorTransform":{"exposure":1.08},
            "overwrite":true
         });
         TweenMax.to(this.bmp_addButton,0,{
            "colorTransform":{"exposure":1.08},
            "overwrite":true
         });
         Audio.sound.play("sound/interface/int-over.mp3");
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         TweenMax.to(this.bmp_add,0.25,{
            "colorTransform":{"exposure":1},
            "glowFilter":{
               "alpha":0,
               "remove":true
            }
         });
         TweenMax.to(this.mc_background,0.25,{"colorTransform":{"exposure":1}});
         TweenMax.to(this.bmp_addButton,0.25,{"colorTransform":{"exposure":1}});
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         TweenMax.to(this.bmp_addButton,0,{
            "colorTransform":{"exposure":1.25},
            "overwrite":true
         });
         TweenMax.to(this.bmp_addButton,0.5,{
            "delay":0.05,
            "colorTransform":{"exposure":1}
         });
         Audio.sound.play("sound/interface/int-click.mp3");
      }
   }
}

