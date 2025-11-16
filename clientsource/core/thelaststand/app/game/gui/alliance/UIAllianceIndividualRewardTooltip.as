package thelaststand.app.game.gui.alliance
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import flash.text.TextFieldAutoSize;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class UIAllianceIndividualRewardTooltip extends Sprite
   {
      
      private static var ITEM_GLOW_ENABLED:GlowFilter = new GlowFilter(12358190,1,4,4,100,1);
      
      private var ui_titleBar:UITitleBar;
      
      private var txt_title:BodyTextField;
      
      private var ui_icon:UIImage;
      
      private var bmpGem:Bitmap;
      
      private var txt_rewardTitle:BodyTextField;
      
      private var txt_contains:BodyTextField;
      
      private var txt_items:BodyTextField;
      
      private var txt_disclaimer:BodyTextField;
      
      private var allianceXML:XML;
      
      private var _lang:Language = Language.getInstance();
      
      public function UIAllianceIndividualRewardTooltip()
      {
         super();
         this.allianceXML = ResourceManager.getInstance().get("xml/alliances.xml");
         this.ui_titleBar = new UITitleBar(null,12358190);
         this.ui_titleBar.width = 270;
         this.ui_titleBar.height = 26;
         addChild(this.ui_titleBar);
         this.txt_title = new BodyTextField({
            "text":" ",
            "color":15188587,
            "size":16,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_title.text = Language.getInstance().getString("alliance.indiReward_tooltip_title");
         this.txt_title.y = int(this.ui_titleBar.y + (this.ui_titleBar.height - this.txt_title.height) * 0.5);
         this.txt_title.x = int(this.ui_titleBar.x + (this.ui_titleBar.width - this.txt_title.width) * 0.5);
         addChild(this.txt_title);
         this.ui_icon = new UIImage(64,64,1184274,1,true,null);
         this.ui_icon.x = 4;
         this.ui_icon.y = int(this.ui_titleBar.y + this.ui_titleBar.height + 12);
         this.ui_icon.filters = [];
         addChild(this.ui_icon);
         this.bmpGem = new Bitmap(new BmpAllianceRewardGem());
         this.bmpGem.x = this.ui_icon.x + this.ui_icon.width + 14;
         this.bmpGem.y = this.ui_icon.y;
         addChild(this.bmpGem);
         this.txt_rewardTitle = new BodyTextField({
            "text":"title",
            "color":16777215,
            "size":14,
            "bold":false,
            "autoSize":TextFieldAutoSize.LEFT,
            "multiline":true,
            "width":165
         });
         this.txt_rewardTitle.x = this.bmpGem.x + this.bmpGem.width;
         this.txt_rewardTitle.y = this.bmpGem.y;
         addChild(this.txt_rewardTitle);
         this.txt_contains = new BodyTextField({
            "text":this._lang.getString("alliance.indiReward_tooltip_contains"),
            "color":16777215,
            "size":14,
            "bold":false,
            "autoSize":TextFieldAutoSize.LEFT,
            "multiline":true,
            "width":180
         });
         this.txt_contains.x = this.bmpGem.x;
         addChild(this.txt_contains);
         this.txt_items = new BodyTextField({
            "text":"+50 item",
            "color":8048236,
            "size":14,
            "bold":false,
            "autoSize":TextFieldAutoSize.LEFT,
            "multiline":true,
            "width":180
         });
         this.txt_items.x = this.txt_contains.x;
         addChild(this.txt_items);
         this.txt_disclaimer = new BodyTextField({
            "text":"disclaimer",
            "color":6250077,
            "size":14,
            "bold":false,
            "autoSize":TextFieldAutoSize.LEFT,
            "multiline":true,
            "width":this.ui_titleBar.width - 5
         });
         this.txt_disclaimer.x = this.ui_icon.x;
         addChild(this.txt_disclaimer);
      }
      
      public function dispose() : void
      {
         this.ui_titleBar.dispose();
         this.txt_title.dispose();
         this.ui_icon.dispose();
         this.txt_rewardTitle.dispose();
         this.txt_contains.dispose();
         this.txt_items.dispose();
         this.txt_disclaimer.dispose();
         this.bmpGem.bitmapData.dispose();
         this._lang = null;
      }
      
      public function populate(param1:UIAllianceIndividualRewardTierMarker) : void
      {
         var _loc3_:Item = null;
         var _loc2_:* = "";
         for each(_loc3_ in param1.Items)
         {
            if(_loc2_ != "")
            {
               _loc2_ += "<br/>";
            }
            _loc2_ += _loc3_.getName() + (_loc3_.quantifiable && _loc3_.quantity > 1 ? " x " + _loc3_.quantity : "");
         }
         this.txt_items.htmlText = _loc2_;
         this.ui_icon.uri = String(param1.data.@img);
         if(param1.state == UIAllianceIndividualRewardTierMarker.STATE_ACTIVE_CURRENT)
         {
            this.bmpGem.visible = true;
            this.txt_title.textColor = 15188587;
            this.ui_titleBar.color = 12358190;
            this.txt_rewardTitle.textColor = 16102685;
            this.txt_rewardTitle.x = this.bmpGem.x + this.bmpGem.width;
            this.ui_icon.filters = [ITEM_GLOW_ENABLED];
         }
         else
         {
            this.bmpGem.visible = false;
            this.txt_title.textColor = 14540253;
            this.ui_titleBar.color = 6710886;
            this.txt_rewardTitle.textColor = 13421772;
            this.txt_rewardTitle.x = this.bmpGem.x;
            this.ui_icon.filters = [ITEM_GLOW_ENABLED,Effects.GREYSCALE.filter];
         }
         switch(param1.state)
         {
            case UIAllianceIndividualRewardTierMarker.STATE_ACTIVE_PASSED:
               this.txt_rewardTitle.text = this._lang.getString("alliance.indiReward_tooltip_rewardtitle_past",param1.value.toString());
               this.txt_disclaimer.text = this._lang.getString("alliance.indiReward_tooltip_disclaimer_past",param1.value.toString());
               break;
            case UIAllianceIndividualRewardTierMarker.STATE_ACTIVE_CURRENT:
               this.txt_rewardTitle.text = this._lang.getString("alliance.indiReward_tooltip_rewardtitle_current",param1.value.toString());
               this.txt_disclaimer.text = this._lang.getString("alliance.indiReward_tooltip_disclaimer_current",param1.value.toString());
               break;
            case UIAllianceIndividualRewardTierMarker.STATE_INACTIVE:
            default:
               this.txt_rewardTitle.text = this._lang.getString("alliance.indiReward_tooltip_rewardtitle_future",param1.value.toString());
               this.txt_disclaimer.text = this._lang.getString("alliance.indiReward_tooltip_disclaimer_future",param1.value.toString());
         }
         this.txt_contains.y = this.txt_rewardTitle.y + this.txt_rewardTitle.height;
         this.txt_items.y = this.txt_contains.y + this.txt_contains.height;
         this.txt_disclaimer.y = Math.max(this.ui_icon.y + this.ui_icon.height,this.txt_items.y + this.txt_items.height) + 10;
      }
   }
}

