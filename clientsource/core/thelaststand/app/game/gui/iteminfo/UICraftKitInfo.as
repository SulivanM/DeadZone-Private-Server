package thelaststand.app.game.gui.iteminfo
{
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.utils.StringUtils;
   import thelaststand.common.lang.Language;
   
   public class UICraftKitInfo extends UIGenericItemInfo
   {
      
      private var txt_info:BodyTextField;
      
      public function UICraftKitInfo()
      {
         super();
         this.txt_info = new BodyTextField({
            "color":16777215,
            "multiline":true,
            "size":14
         });
         addChild(this.txt_info);
      }
      
      override public function setItem(param1:Item, param2:SurvivorLoadout = null, param3:Object = null) : void
      {
         super.setItem(param1,param2,param3);
         var _loc4_:String = param1.xml.kit.mod.toString();
         var _loc5_:String = param1.getAllModDescriptions();
         _loc5_ = _loc5_ + ("<br/><br/>" + Language.getInstance().getString("itm_details.craftkit_info"));
         _loc5_ = StringUtils.htmlRemoveTrailingBreaks(_loc5_);
         _loc5_ = StringUtils.htmlSetDoubleBreakLeading(_loc5_);
         this.txt_info.y = int(_height + 10);
         this.txt_info.width = _width;
         this.txt_info.htmlText = _loc5_;
         _height = int(this.txt_info.y + this.txt_info.height);
      }
   }
}

