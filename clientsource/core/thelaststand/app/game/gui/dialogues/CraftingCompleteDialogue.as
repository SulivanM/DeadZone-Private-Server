package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.EffectItem;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.data.WeaponData;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.iteminfo.UIEffectItemInfo;
   import thelaststand.app.game.gui.iteminfo.UIItemTitle;
   import thelaststand.app.game.gui.lists.UIInventoryListItem;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class CraftingCompleteDialogue extends BaseDialogue
   {
      
      private var _craftedItem:Item;
      
      private var _lang:Language;
      
      private var mc_container:Sprite;
      
      private var mc_image:UIInventoryListItem;
      
      private var txt_dpsValue:BodyTextField;
      
      private var txt_dpsTitle:BodyTextField;
      
      private var txt_damage:BodyTextField;
      
      private var txt_desc:BodyTextField;
      
      private var txt_modInfo:BodyTextField;
      
      private var ui_itemInfo:UIItemInfo;
      
      private var mc_outputInfoHitArea:Sprite;
      
      private var ui_title:UIItemTitle;
      
      private var ui_effectInfo:UIEffectItemInfo;
      
      public function CraftingCompleteDialogue(param1:Item, param2:Boolean = false)
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc6_:String = null;
         var _loc7_:Weapon = null;
         var _loc8_:WeaponData = null;
         this.mc_container = new Sprite();
         super("crafted-item-dialogue",this.mc_container,false);
         this._lang = Language.getInstance();
         this._craftedItem = param1;
         _autoSize = false;
         _width = 308;
         _padding = 16;
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         addTitle(Language.getInstance().getString(param2 ? "crafted_upgraded_title" : "crafted_title"),5864895);
         _loc3_ = _width - _padding * 2;
         _loc4_ = 8;
         var _loc5_:String = this._craftedItem.getName();
         if(this._craftedItem.quantifiable && this._craftedItem.quantity > 1)
         {
            _loc5_ += " x " + this._craftedItem.quantity;
         }
         this.ui_title = new UIItemTitle();
         this.ui_title.width = int(_loc3_ - 16);
         this.ui_title.x = int((_loc3_ - this.ui_title.width) * 0.5);
         this.ui_title.y = this.ui_title.x;
         this.ui_title.setItem(this._craftedItem);
         this.mc_container.addChild(this.ui_title);
         if(this._craftedItem is EffectItem)
         {
            this.ui_effectInfo = new UIEffectItemInfo();
            this.ui_effectInfo.setItem(this._craftedItem);
            this.ui_effectInfo.x = _loc4_;
            this.ui_effectInfo.y = int(this.ui_title.y + this.ui_title.height + 8);
            this.mc_container.addChild(this.ui_effectInfo);
            _height = int(this.ui_effectInfo.y + this.ui_effectInfo.height + 8);
         }
         else
         {
            this.mc_image = new UIInventoryListItem();
            this.mc_image.showEquippedIcon = false;
            this.mc_image.showNewIcon = false;
            this.mc_image.mouseEnabled = this.mc_image.mouseChildren = false;
            this.mc_image.x = _loc4_;
            this.mc_image.y = int(this.ui_title.y + this.ui_title.height + 8);
            this.mc_image.itemData = this._craftedItem;
            this.mc_container.addChild(this.mc_image);
            this.mc_outputInfoHitArea = new Sprite();
            this.mc_outputInfoHitArea.graphics.beginFill(16711680,0);
            this.mc_outputInfoHitArea.graphics.drawRect(0,0,_loc3_,this.mc_image.height + 10);
            this.mc_outputInfoHitArea.graphics.endFill();
            this.mc_outputInfoHitArea.y = int(this.mc_image.y - 5);
            this.mc_container.addChild(this.mc_outputInfoHitArea);
            _height = int(this.mc_image.y + this.mc_image.height + 8);
            _loc6_ = "";
            if(this._craftedItem is Weapon)
            {
               _loc7_ = Weapon(this._craftedItem);
               _loc8_ = new WeaponData();
               _loc8_.populate(null,_loc7_);
               this.txt_dpsValue = new BodyTextField({
                  "text":"0",
                  "color":16777215,
                  "size":30,
                  "bold":true
               });
               this.txt_dpsValue.x = this.mc_image.x + this.mc_image.width + 6;
               this.txt_dpsValue.y = this.mc_image.y;
               this.txt_dpsValue.text = Number(_loc8_.getDPS().toFixed(1)).toString();
               this.txt_dpsValue.filters = [new GlowFilter(16777215,1,20,20,1,2)];
               this.mc_container.addChild(this.txt_dpsValue);
               this.txt_dpsTitle = new BodyTextField({
                  "color":11908533,
                  "size":12,
                  "bold":true
               });
               this.txt_dpsTitle.text = this._lang.getString("itm_details.dps").toUpperCase();
               this.txt_dpsTitle.x = int(this.txt_dpsValue.x + this.txt_dpsValue.width + 2);
               this.txt_dpsTitle.y = Math.round(this.txt_dpsValue.y + (this.txt_dpsValue.height - this.txt_dpsTitle.height) * 0.5);
               this.mc_container.addChild(this.txt_dpsTitle);
               this.txt_damage = new BodyTextField({
                  "color":11908533,
                  "size":14,
                  "bold":true
               });
               this.txt_damage.x = this.txt_dpsValue.x;
               this.txt_damage.y = int(this.txt_dpsValue.y + this.txt_dpsValue.height - 5);
               this.txt_damage.text = int(_loc8_.damageMin * 100) + " - " + int(_loc8_.damageMax * 100) + " " + this._lang.getString("itm_details.dmg");
               this.mc_container.addChild(this.txt_damage);
               if(_loc7_.numMods > 0)
               {
                  _loc6_ = _loc7_.getAllModDescriptions(true);
               }
            }
            else
            {
               this.txt_desc = new BodyTextField({
                  "htmlText":this._lang.getString("itm_desc." + this._craftedItem.type),
                  "color":Effects.COLOR_NEUTRAL,
                  "multiline":true,
                  "size":14
               });
               this.txt_desc.x = int(this.mc_image.x + this.mc_image.width + 10);
               this.txt_desc.y = int(this.mc_image.y - 2);
               this.txt_desc.width = int(_loc3_ - this.txt_desc.x - _loc4_);
               this.mc_container.addChild(this.txt_desc);
               _height = int(Math.max(_height,this.txt_desc.y + this.txt_desc.height + 8));
            }
            if(this._craftedItem.numMods > 0)
            {
               _loc6_ = this._craftedItem.getAllModDescriptions(true);
            }
            if(_loc6_.length > 0)
            {
               this.txt_modInfo = new BodyTextField({
                  "color":Effects.COLOR_NEUTRAL,
                  "multiline":true,
                  "size":14,
                  "leading":1
               });
               this.txt_modInfo.htmlText = _loc6_;
               this.txt_modInfo.x = int(this.mc_image.x - 2);
               this.txt_modInfo.y = _height;
               this.txt_modInfo.width = int(_loc3_ - this.txt_modInfo.x * 2);
               this.mc_container.addChild(this.txt_modInfo);
               _height = int(this.txt_modInfo.y + this.txt_modInfo.height + 8);
            }
            this.ui_itemInfo = new UIItemInfo();
            this.ui_itemInfo.setItem(this._craftedItem);
            this.ui_itemInfo.addRolloverTarget(this.mc_outputInfoHitArea);
         }
         GraphicUtils.drawUIBlock(this.mc_container.graphics,_loc3_,_height);
         _height += 76;
         addButton(Language.getInstance().getString("crafted_ok"),true,{"width":114});
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._craftedItem = null;
         this.ui_title.dispose();
         if(this.txt_dpsTitle != null)
         {
            this.txt_dpsTitle.dispose();
         }
         if(this.txt_dpsValue != null)
         {
            this.txt_dpsValue.dispose();
         }
         if(this.txt_damage != null)
         {
            this.txt_damage.dispose();
         }
         if(this.txt_desc != null)
         {
            this.txt_desc.dispose();
         }
         if(this.txt_modInfo != null)
         {
            this.txt_modInfo.dispose();
         }
         if(this.ui_effectInfo != null)
         {
            this.ui_effectInfo.dispose();
         }
         if(this.ui_itemInfo != null)
         {
            this.ui_itemInfo.dispose();
         }
         if(this.mc_image != null)
         {
            this.mc_image.dispose();
         }
      }
      
      override public function open() : void
      {
         super.open();
         Audio.sound.play("crafting-complete");
      }
   }
}

