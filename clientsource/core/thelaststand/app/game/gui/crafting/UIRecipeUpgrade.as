package thelaststand.app.game.gui.crafting
{
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.text.AntiAliasType;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.lists.UIInventoryListItem;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class UIRecipeUpgrade extends Sprite
   {
      
      private const LEVEL_GLOW_A:GlowFilter = new GlowFilter(0,1,20,20,1,2);
      
      private const LEVEL_GLOW_B:GlowFilter = new GlowFilter(16777215,1,20,20,0.75,2);
      
      private var _itemInput:Item;
      
      private var _itemOutput:Item;
      
      private var _width:int = 258;
      
      private var _height:int = 265;
      
      private var _lang:Language;
      
      private var bmp_arrow:Bitmap;
      
      private var txt_upgrading:BodyTextField;
      
      private var txt_desc:BodyTextField;
      
      private var mc_bg:Shape;
      
      private var ui_itemA:UIInventoryListItem;
      
      private var ui_itemB:UIInventoryListItem;
      
      private var txt_levelA:BodyTextField;
      
      private var txt_levelB:BodyTextField;
      
      private var txt_levelMax:BodyTextField;
      
      private var ui_itemInfo:UIItemInfo;
      
      private var ui_upgradeKit:UIUpgradeKitPanel;
      
      public function UIRecipeUpgrade()
      {
         super();
         this._lang = Language.getInstance();
         this.txt_upgrading = new BodyTextField({
            "text":this._lang.getString("crafting_upgrading_title"),
            "color":12961221,
            "size":11,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_upgrading.x = -2;
         this.txt_desc = new BodyTextField({
            "htmlText":this._lang.getString("crafting_upgrade_desc2"),
            "color":12961221,
            "size":14,
            "multiline":true
         });
         this.txt_desc.x = 0;
         this.txt_desc.width = int(this._width - this.txt_desc.x * 2);
         this.mc_bg = new Shape();
         this.mc_bg.x = -8;
         GraphicUtils.drawUIBlock(this.mc_bg.graphics,this._width + 16,106,0,0,3552051);
         this.ui_upgradeKit = new UIUpgradeKitPanel();
         this.ui_upgradeKit.x = int((this._width - this.ui_upgradeKit.width) / 2);
         this.ui_upgradeKit.y = int(this._height - this.ui_upgradeKit.height) - 4;
         this.ui_itemA = new UIInventoryListItem(48);
         this.ui_itemA.showEquippedIcon = false;
         this.ui_itemA.showNewIcon = false;
         this.ui_itemA.mouseOver.add(this.onMouseOverItem);
         this.ui_itemB = new UIInventoryListItem(48);
         this.ui_itemB.showEquippedIcon = false;
         this.ui_itemB.showNewIcon = false;
         this.ui_itemB.mouseOver.add(this.onMouseOverItem);
         this.bmp_arrow = new Bitmap(new BmpBatchRecycleArrow());
         this.txt_levelA = new BodyTextField({
            "text":" ",
            "color":12829635,
            "size":30,
            "bold":true,
            "filters":[this.LEVEL_GLOW_A]
         });
         this.txt_levelB = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":30,
            "bold":true,
            "filters":[this.LEVEL_GLOW_B]
         });
         this.txt_levelMax = new BodyTextField({
            "text":"(" + this._lang.getString("max").toUpperCase() + ")",
            "color":16777215,
            "size":13,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.ui_itemInfo = new UIItemInfo();
         this.ui_itemInfo.addRolloverTarget(this.ui_itemA);
         this.ui_itemInfo.addRolloverTarget(this.ui_itemB);
      }
      
      public function get upgradeKitPanel() : UIUpgradeKitPanel
      {
         return this.ui_upgradeKit;
      }
      
      public function get upgradeKitItem() : Item
      {
         return this.ui_upgradeKit.upgradeKitItem;
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this.ui_itemA.dispose();
         this.ui_itemB.dispose();
         this.ui_itemInfo.dispose();
         this.txt_desc.dispose();
         this.txt_levelA.dispose();
         this.txt_levelB.dispose();
         this.txt_upgrading.dispose();
         this.txt_levelMax.dispose();
         this.ui_upgradeKit.dispose();
      }
      
      public function setItem(param1:Item, param2:Item) : void
      {
         this._itemInput = param1;
         this._itemOutput = param2;
         this.ui_upgradeKit.inputItem = this._itemInput;
         this.updateDisplay();
      }
      
      private function updateDisplay() : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc7_:XML = null;
         var _loc1_:int = numChildren - 1;
         while(_loc1_ >= 0)
         {
            removeChildAt(_loc1_);
            _loc1_--;
         }
         if(!this._itemInput.isUpgradable)
         {
            if(this._itemInput.isAtMaxLevel())
            {
               this.txt_desc.htmlText = this._lang.getString("crafting_upgrade_max");
               this.txt_desc.textColor = 16729856;
               this.txt_desc.y = int(this.txt_upgrading.y);
               addChild(this.txt_desc);
            }
            return;
         }
         var _loc2_:String = this._itemInput is Weapon ? "bench-weapon" : "bench-gear";
         var _loc3_:Building = Network.getInstance().playerData.compound.buildings.getHighestLevelBuilding(_loc2_);
         var _loc4_:int = _loc3_ != null ? int(_loc3_.getLevelXML().max_upgrade_level) : -1;
         if(this._itemInput.level > _loc4_ - 1)
         {
            _loc6_ = -1;
            for each(_loc7_ in Building.getBuildingXML(_loc2_).lvl)
            {
               if(int(_loc7_.max_upgrade_level) - 1 >= this._itemInput.level)
               {
                  _loc6_ = int(_loc7_.@n.toString());
                  break;
               }
            }
            if(_loc6_ < 0)
            {
               this.txt_desc.htmlText = "<b>" + this._lang.getString("crafting_cannot_upgrade") + "</b>";
            }
            else
            {
               this.txt_desc.htmlText = "<b>" + this._lang.getString("construct_requires",_loc6_ + 1,this._lang.getString("blds." + _loc2_)) + "</b>";
            }
            this.txt_desc.textColor = 16729856;
            this.txt_desc.y = int(this.txt_upgrading.y);
            addChild(this.txt_desc);
            return;
         }
         this.mc_bg.y = int(this.txt_upgrading.y + this.txt_upgrading.height + 4);
         _loc5_ = 46;
         this.ui_itemA.x = int(this.mc_bg.x + _loc5_);
         this.ui_itemB.x = int(this.mc_bg.x + (this.mc_bg.width - this.ui_itemB.width - _loc5_));
         this.ui_itemA.y = int(this.mc_bg.y + 12);
         this.ui_itemB.y = this.ui_itemA.y;
         this.ui_itemA.itemData = this._itemInput;
         this.ui_itemB.itemData = this._itemOutput;
         this.bmp_arrow.x = int(this.mc_bg.x + (this.mc_bg.width - this.bmp_arrow.width) * 0.5);
         this.bmp_arrow.y = int(this.ui_itemA.y + (this.ui_itemA.height - this.bmp_arrow.height) * 0.5);
         this.txt_levelA.text = int(this._itemInput.level + 1).toString();
         this.txt_levelA.x = int(this.ui_itemA.x + (this.ui_itemA.width - this.txt_levelA.width) * 0.5);
         this.txt_levelA.y = int(this.ui_itemA.y + this.ui_itemA.height + 0);
         this.txt_levelB.text = int(this._itemOutput.level + 1).toString();
         this.txt_levelB.x = int(this.ui_itemB.x + (this.ui_itemB.width - this.txt_levelB.width) * 0.5);
         this.txt_levelB.y = int(this.txt_levelA.y);
         this.txt_desc.htmlText = this._lang.getString("crafting_upgrade_desc2");
         this.txt_desc.textColor = 12961221;
         this.txt_desc.y = int(this.mc_bg.y + this.mc_bg.height + 6);
         addChild(this.mc_bg);
         addChild(this.txt_upgrading);
         addChild(this.txt_levelA);
         addChild(this.txt_levelB);
         addChild(this.bmp_arrow);
         addChild(this.ui_itemA);
         addChild(this.ui_itemB);
         addChild(this.txt_desc);
         addChild(this.ui_upgradeKit);
         if(this._itemInput.level >= this._itemInput.getMaxLevel() - 1)
         {
            this.txt_levelMax.x = int(this.txt_levelB.x + this.txt_levelB.width);
            this.txt_levelMax.y = int(this.txt_levelB.y + (this.txt_levelB.height - this.txt_levelMax.height) * 0.5) + 1;
            addChild(this.txt_levelMax);
         }
         else if(this.txt_levelMax.parent != null)
         {
            this.txt_levelMax.parent.removeChild(this.txt_levelMax);
         }
      }
      
      private function onMouseOverItem(param1:MouseEvent) : void
      {
         var _loc2_:UIInventoryListItem = UIInventoryListItem(param1.currentTarget);
         this.ui_itemInfo.setItem(_loc2_.itemData);
      }
   }
}

