package thelaststand.app.game.gui.iteminfo
{
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.SurvivorLoadout;
   
   public class UIGenericItemInfo extends UIItemInfoDisplay
   {
      
      protected var txt_desc:BodyTextField;
      
      public function UIGenericItemInfo()
      {
         super();
         this.txt_desc = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "multiline":true,
            "size":14
         });
         this.txt_desc.x = int(mc_image.x + mc_image.width + 10);
         this.txt_desc.y = int(mc_image.y - 2);
         this.txt_desc.width = int(_width - this.txt_desc.x - 6);
         addChild(this.txt_desc);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.txt_desc.dispose();
      }
      
      override public function setItem(param1:Item, param2:SurvivorLoadout = null, param3:Object = null) : void
      {
         param3 ||= {};
         super.setItem(param1,param2,param3);
         this.txt_desc.htmlText = _lang.getString("itm_desc." + _item.type);
         _height = Math.max(_height,int(this.txt_desc.y + this.txt_desc.height));
      }
   }
}

