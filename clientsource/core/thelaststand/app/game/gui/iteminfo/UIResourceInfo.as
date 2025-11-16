package thelaststand.app.game.gui.iteminfo
{
   import com.deadreckoned.threshold.display.Color;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.network.Network;
   
   public class UIResourceInfo extends UIGenericItemInfo
   {
      
      private var txt_amount:BodyTextField;
      
      public function UIResourceInfo()
      {
         super();
         this.txt_amount = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "multiline":true,
            "size":14
         });
         this.txt_amount.x = int(mc_image.x + mc_image.width + 10);
         this.txt_amount.y = int(mc_image.y - 2);
         this.txt_amount.width = int(_width - this.txt_amount.x);
         addChild(this.txt_amount);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.txt_amount.dispose();
      }
      
      override public function setItem(param1:Item, param2:SurvivorLoadout = null, param3:Object = null) : void
      {
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         super.setItem(param1,param2);
         if(param3 == null)
         {
            param3 = {};
         }
         if(!param3.hasOwnProperty("showResourceLimited"))
         {
            param3.showResourceLimited = true;
         }
         this.txt_amount.htmlText = "";
         for each(_loc4_ in _item.xml.res.res)
         {
            _loc5_ = _loc4_.@id.toString();
            _loc6_ = _item.quantity * int(_loc4_.toString());
            _loc7_ = Network.getInstance().playerData.compound.resources.getAvailableStorageCapacity(_loc5_);
            if(_loc5_ != GameResources.CASH && _loc7_ <= 0 && param3.showResourceLimited == true)
            {
               this.txt_amount.htmlText += "<font color=\'" + Color.colorToHex(Effects.COLOR_WARNING) + "\'>" + _lang.getString("items." + _loc4_.@id.toString()) + " (" + _lang.getString("msg_storage_full") + ")</font><br/>";
            }
            else
            {
               _loc8_ = _loc6_;
               this.txt_amount.htmlText += "<font color=\'" + Color.colorToHex(Effects.COLOR_GOOD) + "\'>+" + _loc8_ + " " + _lang.getString("items." + _loc4_.@id.toString()) + "</font><br/>";
            }
         }
         this.txt_amount.y = int(txt_desc.y + txt_desc.height + 10);
         _height = Math.max(_height,int(this.txt_amount.y + this.txt_amount.height));
      }
   }
}

