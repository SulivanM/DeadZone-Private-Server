package thelaststand.app.game.gui.crafting
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.EffectItem;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.Schematic;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.data.WeaponData;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.iteminfo.UIItemTitle;
   import thelaststand.app.game.gui.lists.UIInventoryListItem;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class UIRecipeInterface extends Sprite
   {
      
      private var _width:int = 274;
      
      private var _height:int = 394;
      
      private var _padding:int = 8;
      
      private var _lang:Language;
      
      private var _outputItem:Item;
      
      private var mc_divider:Sprite;
      
      private var mc_image:UIInventoryListItem;
      
      private var txt_none:BodyTextField;
      
      private var txt_dpsValue:BodyTextField;
      
      private var txt_dpsTitle:BodyTextField;
      
      private var txt_damage:BodyTextField;
      
      private var txt_desc:BodyTextField;
      
      private var ui_itemInfo:UIItemInfo;
      
      private var mc_outputInfoHitArea:Sprite;
      
      private var ui_title:UIItemTitle;
      
      private var ui_schematic:UIRecipeSchematic;
      
      private var ui_upgrade:UIRecipeUpgrade;
      
      public function UIRecipeInterface()
      {
         super();
         this._lang = Language.getInstance();
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         this.ui_title = new UIItemTitle();
         this.ui_title.width = int(this._width - this._padding * 2 + 8);
         this.ui_title.x = int((this._width - this.ui_title.width) * 0.5);
         this.ui_title.y = this.ui_title.x;
         this.txt_none = new BodyTextField({
            "htmlText":this._lang.getString("crafting_none"),
            "color":16777215,
            "multiline":true,
            "size":14
         });
         this.txt_none.x = this.txt_none.y = this._padding;
         this.txt_none.width = int(this._width - this.txt_none.x * 2);
         this.mc_image = new UIInventoryListItem(52);
         this.mc_image.showEquippedIcon = false;
         this.mc_image.showNewIcon = false;
         this.mc_image.mouseEnabled = this.mc_image.mouseChildren = false;
         this.mc_image.x = this._padding;
         this.mc_image.y = int(this.ui_title.y + this.ui_title.height + 4);
         this.mc_outputInfoHitArea = new Sprite();
         this.mc_outputInfoHitArea.graphics.beginFill(16711680,0);
         this.mc_outputInfoHitArea.graphics.drawRect(0,0,this._width,this.mc_image.height + 10);
         this.mc_outputInfoHitArea.graphics.endFill();
         this.mc_outputInfoHitArea.y = int(this.mc_image.y - 5);
         this.mc_divider = new BlueprintDivider();
         this.mc_divider.width = int(this._width - this._padding * 2);
         this.txt_dpsValue = new BodyTextField({
            "text":"0",
            "color":16777215,
            "size":30,
            "bold":true
         });
         this.txt_dpsValue.x = this.mc_image.x + this.mc_image.width + 6;
         this.txt_dpsValue.y = this.mc_image.y;
         this.txt_dpsValue.filters = [new GlowFilter(16777215,1,20,20,1,2)];
         this.txt_dpsTitle = new BodyTextField({
            "color":11908533,
            "size":12,
            "bold":true
         });
         this.txt_dpsTitle.text = this._lang.getString("itm_details.dps").toUpperCase();
         this.txt_dpsTitle.x = this.txt_dpsValue.x;
         this.txt_dpsTitle.y = Math.round(this.txt_dpsValue.y + (this.txt_dpsValue.height - this.txt_dpsTitle.height) * 0.5);
         this.txt_damage = new BodyTextField({
            "color":11908533,
            "size":14,
            "bold":true
         });
         this.txt_damage.x = this.txt_dpsValue.x;
         this.txt_damage.y = int(this.txt_dpsValue.y + this.txt_dpsValue.height - 5);
         this.txt_desc = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "multiline":true,
            "size":13
         });
         this.txt_desc.x = int(this.mc_image.x + this.mc_image.width + 10);
         this.txt_desc.y = int(this.mc_image.y - 2);
         this.txt_desc.width = int(this._width - this.txt_desc.x - this._padding);
         this.ui_schematic = new UIRecipeSchematic();
         this.ui_schematic.addEventListener("itemChanged",this.onSchematicItemChanged,false,0,true);
         this.ui_schematic.x = this._padding;
         this.ui_upgrade = new UIRecipeUpgrade();
         this.ui_upgrade.x = int(this.ui_schematic.x);
         this.ui_itemInfo = new UIItemInfo();
      }
      
      private function onSchematicItemChanged(param1:Event) : void
      {
         var _loc2_:Schematic = this.ui_schematic.schematic;
         if(_loc2_ == null)
         {
            return;
         }
         this._outputItem = this.ui_schematic.getOutputItem();
         this.ui_itemInfo.extraInfo = _loc2_.getCraftInfo();
         this.ui_itemInfo.setItem(this._outputItem,null,{
            "expiry":_loc2_.getExpiryDate(),
            "lvl_max":_loc2_.getMaxLevel()
         });
         this.updateDisplay(_loc2_.getName());
         addChild(this.ui_schematic);
         if(this.ui_upgrade.parent != null)
         {
            this.ui_upgrade.parent.removeChild(this.ui_upgrade);
         }
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this._lang = null;
         this.mc_image.dispose();
         this.ui_schematic.dispose();
         this.ui_upgrade.dispose();
         this.ui_itemInfo.dispose();
         this.txt_none.dispose();
         this.txt_damage.dispose();
         this.txt_desc.dispose();
         this.txt_dpsTitle.dispose();
         this.txt_dpsValue.dispose();
         this.ui_title.dispose();
      }
      
      public function clear() : void
      {
         var _loc1_:int = numChildren - 1;
         while(_loc1_ >= 0)
         {
            removeChildAt(_loc1_);
            _loc1_--;
         }
         addChild(this.txt_none);
      }
      
      public function showSchematic(param1:Schematic) : void
      {
         this.ui_schematic.schematic = param1;
         this._outputItem = this.ui_schematic.getOutputItem();
         this.ui_itemInfo.extraInfo = param1.getCraftInfo();
         this.ui_itemInfo.setItem(this._outputItem,null,{
            "expiry":param1.getExpiryDate(),
            "lvl_max":param1.getMaxLevel()
         });
         this.updateDisplay(param1.getName());
         addChild(this.ui_schematic);
         if(this.ui_upgrade.parent != null)
         {
            this.ui_upgrade.parent.removeChild(this.ui_upgrade);
         }
      }
      
      public function showUpgrade(param1:Item) : void
      {
         this._outputItem = param1.clone();
         if(!this._outputItem.isAtMaxLevel())
         {
            ++this._outputItem.baseLevel;
         }
         this.ui_upgrade.setItem(param1,this._outputItem);
         this.ui_itemInfo.extraInfo = null;
         this.ui_itemInfo.setItem(this._outputItem);
         this.updateDisplay(param1.getName());
         addChild(this.ui_upgrade);
         if(this.ui_schematic.parent != null)
         {
            this.ui_schematic.parent.removeChild(this.ui_schematic);
         }
      }
      
      public function getSchematicInputItemIds() : Array
      {
         return this.ui_schematic.inputItemIds;
      }
      
      public function getUpgradeKitItem() : Item
      {
         return this.ui_upgrade.upgradeKitItem;
      }
      
      public function clearUpgradeKitItem() : void
      {
         this.ui_upgrade.upgradeKitPanel.clear();
      }
      
      private function updateDisplay(param1:String) : void
      {
         var _loc2_:int = numChildren - 1;
         while(_loc2_ >= 0)
         {
            removeChildAt(_loc2_);
            _loc2_--;
         }
         this.ui_title.setItem(this._outputItem);
         this.mc_image.itemData = this._outputItem;
         this.mc_divider.y = int(this.mc_image.y + this.mc_image.height + this._padding + 2);
         this.mc_divider.x = int((this._width - this.mc_divider.width) * 0.5);
         if(this._outputItem is Weapon)
         {
            this.updateWeaponDisplay();
         }
         else
         {
            this.updateItemDisplay();
         }
         var _loc3_:int = int(this.mc_divider.y + 6);
         this.ui_schematic.y = _loc3_;
         this.ui_upgrade.y = _loc3_;
         addChild(this.ui_title);
         addChild(this.mc_image);
         addChild(this.mc_divider);
         addChild(this.mc_outputInfoHitArea);
         this.ui_itemInfo.addRolloverTarget(this.mc_outputInfoHitArea);
      }
      
      private function updateWeaponDisplay() : void
      {
         var _loc1_:Weapon = Weapon(this._outputItem);
         var _loc2_:WeaponData = new WeaponData();
         _loc2_.populate(null,_loc1_);
         var _loc3_:int = _loc1_.getMinLevel();
         this.txt_dpsValue.text = Number(_loc2_.getDPS().toFixed(1)).toString();
         this.txt_damage.text = int(_loc2_.damageMin * 100) + " - " + int(_loc2_.damageMax * 100) + " " + this._lang.getString("itm_details.dmg");
         this.txt_dpsTitle.x = int(this.txt_dpsValue.x + this.txt_dpsValue.width + 2);
         addChild(this.txt_dpsValue);
         addChild(this.txt_dpsTitle);
         addChild(this.txt_damage);
      }
      
      private function updateItemDisplay() : void
      {
         if(this._outputItem is EffectItem)
         {
            this.txt_desc.htmlText = this._lang.getString("effect_desc." + EffectItem(this._outputItem).effect.type);
         }
         else
         {
            this.txt_desc.htmlText = this._lang.getString("itm_desc." + this._outputItem.type);
         }
         addChild(this.txt_desc);
      }
   }
}

