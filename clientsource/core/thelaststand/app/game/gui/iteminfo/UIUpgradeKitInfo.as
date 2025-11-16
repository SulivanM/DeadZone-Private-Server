package thelaststand.app.game.gui.iteminfo
{
   import com.deadreckoned.threshold.display.Color;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.utils.StringUtils;
   import thelaststand.common.lang.Language;
   
   public class UIUpgradeKitInfo extends UIGenericItemInfo
   {
      
      private var txt_info:BodyTextField;
      
      public function UIUpgradeKitInfo()
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
         var _loc4_:int = int(param1.xml.kit.itm_lvl_min) + 1;
         var _loc5_:int = int(param1.xml.kit.itm_lvl_max) + 1;
         var _loc6_:Number = Math.ceil(Number(param1.xml.kit.max_upgrade_chance) * 100);
         var _loc7_:Vector.<String> = new Vector.<String>();
         _loc7_.push(this.goodStatString(Language.getInstance().getString("itm_desc.upgradekit_point1")));
         _loc7_.push(this.goodStatString(Language.getInstance().getString("itm_desc.upgradekit_point2",_loc4_,_loc5_)));
         _loc7_.push(this.goodStatString(Language.getInstance().getString("itm_desc.upgradekit_point3",_loc6_)));
         this.txt_info.y = int(_height + 10);
         this.txt_info.width = _width;
         this.txt_info.htmlText = StringUtils.htmlSetDoubleBreakLeading(_loc7_.join("<br/><br/>"));
         _height = int(this.txt_info.y + this.txt_info.height);
      }
      
      private function goodStatString(param1:String) : String
      {
         return "<font color=\'" + Color.colorToHex(Effects.COLOR_GOOD) + "\'>" + param1 + "</font>";
      }
   }
}

