package thelaststand.app.game.gui.dialogues
{
   import com.deadreckoned.threshold.display.Color;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Settings;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.Schematic;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.crafting.UIRecipeInterface;
   import thelaststand.app.game.gui.crafting.UISchematicListInterface;
   import thelaststand.app.game.gui.crafting.UIUpgradeListInterface;
   import thelaststand.app.game.gui.notification.UINotificationCount;
   import thelaststand.app.game.gui.skills.UISkillXpBar;
   import thelaststand.app.game.logic.DialogueController;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class CraftingDialogue extends BaseDialogue
   {
      
      private static var _lastSelectedCategory:String = "weapon";
      
      private var _categoryButtons:Vector.<PushButton>;
      
      private var _selectedCategoryButton:PushButton;
      
      private var _selectedCategory:String;
      
      private var _upgradeFilterButtons:Vector.<PushButton>;
      
      private var _upgradeSortButtons:Vector.<PushButton>;
      
      private var _schematicList:Vector.<Schematic>;
      
      private var _selectedSchematic:Schematic;
      
      private var _selectedItem:Item;
      
      private var _lang:Language;
      
      private var _xml:XML;
      
      private var _tooltip:TooltipManager;
      
      private var _limtedNotifications:Vector.<UINotificationCount>;
      
      private var bmp_inventory:Bitmap;
      
      private var btn_craft:PurchasePushButton;
      
      private var btn_inventory:PushButton;
      
      private var mc_container:Sprite;
      
      private var ui_recipe:UIRecipeInterface;
      
      private var ui_schematicList:UISchematicListInterface;
      
      private var ui_upgradeList:UIUpgradeListInterface;
      
      private var ui_skillTacticsBar:UISkillXpBar;
      
      private const _categories:Array;
      
      public function CraftingDialogue(param1:String = null, param2:String = null)
      {
         var _loc10_:String = null;
         var _loc11_:int = 0;
         var _loc12_:PushButton = null;
         var _loc13_:String = null;
         this._limtedNotifications = new Vector.<UINotificationCount>();
         this._categories = [{
            "id":"weapon",
            "size":0.145,
            "icon":BmpCraftIconWeapons
         },{
            "id":"gear",
            "size":0.145,
            "icon":BmpCraftIconGear
         },{
            "id":"medical",
            "size":0.145,
            "icon":BmpCraftIconMedical
         },{
            "id":"crafting",
            "size":0.145,
            "icon":BmpCraftIconComponents
         },{
            "id":"ammo",
            "size":0.145,
            "icon":BmpCraftIconAmmo
         },{
            "id":"tactics",
            "size":0.145,
            "icon":BmpCraftIconTactics
         },{
            "id":"upgrade",
            "size":0.145,
            "icon":BmpCraftIconUpgrades
         }];
         this.mc_container = new Sprite();
         super("crafting-dialogue",this.mc_container,true);
         if(param1 != null)
         {
            _lastSelectedCategory = param1;
         }
         _autoSize = false;
         _width = 708;
         _height = 466;
         this._lang = Language.getInstance();
         this._xml = ResourceManager.getInstance().getResource("xml/crafting.xml").content;
         this._tooltip = TooltipManager.getInstance();
         addTitle(this._lang.getString("crafting_title"),5864895);
         this.ui_recipe = new UIRecipeInterface();
         this.ui_recipe.y = 0;
         this.ui_recipe.x = int(_width - this.ui_recipe.width - _padding * 2);
         this.mc_container.addChild(this.ui_recipe);
         this.btn_inventory = new PushButton(this._lang.getString("crafting_open_inventory"));
         this.btn_inventory.clicked.add(this.onClickInventory);
         this.btn_inventory.labelOffset = -20;
         this.btn_inventory.width = 106;
         this.btn_inventory.x = int(this.ui_recipe.x + 2);
         this.btn_inventory.y = int(this.ui_recipe.y + this.ui_recipe.height + 14);
         this.mc_container.addChild(this.btn_inventory);
         var _loc3_:Boolean = Network.getInstance().playerData.isInventoryUpgraded();
         this.bmp_inventory = new Bitmap(_loc3_ ? new BmpIconHUDInventoryUpgrade1() : new BmpIconHUDInventory(),"auto",true);
         this.bmp_inventory.filters = [Effects.ICON_SHADOW];
         this.bmp_inventory.width = 40;
         this.bmp_inventory.scaleY = this.bmp_inventory.scaleX;
         this.bmp_inventory.x = this.btn_inventory.x + this.btn_inventory.width - 50;
         this.bmp_inventory.y = int(this.btn_inventory.y + (this.btn_inventory.height - this.bmp_inventory.height) * 0.5);
         this.mc_container.addChild(this.bmp_inventory);
         this.btn_craft = new PurchasePushButton(this._lang.getString("crafting_craft"),0,true);
         this.btn_craft.iconAlign = PurchasePushButton.ICON_ALIGN_LABEL_RIGHT;
         this.btn_craft.clicked.add(this.onCraftClicked);
         this.btn_craft.enabled = false;
         this.btn_craft.width = int(this.ui_recipe.width - this.btn_inventory.width - 22);
         this.btn_craft.x = int(this.btn_inventory.x + this.btn_inventory.width + 18);
         this.btn_craft.y = int(this.btn_inventory.y);
         this.mc_container.addChild(this.btn_craft);
         this.ui_schematicList = new UISchematicListInterface();
         this.ui_schematicList.y = int(this.ui_recipe.y + this.ui_recipe.height - this.ui_schematicList.height + 46);
         this.ui_schematicList.schematicSelected.add(this.onSchematicSelected);
         this.ui_upgradeList = new UIUpgradeListInterface();
         this.ui_upgradeList.y = int(this.ui_schematicList.y);
         this.ui_upgradeList.itemSelected.add(this.onUpgradeItemSelected);
         this.ui_skillTacticsBar = new UISkillXpBar();
         this.ui_skillTacticsBar.skillState = Network.getInstance().playerData.skills.getSkill("tactics");
         this.ui_skillTacticsBar.width = 234;
         this.ui_skillTacticsBar.height = 25;
         this.ui_skillTacticsBar.x = int(_width - this.ui_skillTacticsBar.width - 54);
         this.ui_skillTacticsBar.y = 12;
         this._categoryButtons = new Vector.<PushButton>();
         var _loc4_:int = int(this._categories.length);
         var _loc5_:int = 12;
         var _loc6_:int = int(this.ui_schematicList.width - 2 - _loc5_ * _loc4_ + _loc5_);
         var _loc7_:int = 2;
         var _loc8_:int = 6;
         var _loc9_:int = 0;
         while(_loc9_ < _loc4_)
         {
            _loc10_ = this._categories[_loc9_].id as String;
            _loc11_ = int(_loc6_ * this._categories[_loc9_].size);
            _loc12_ = new PushButton(null,new this._categories[_loc9_].icon());
            _loc12_.clicked.add(this.onClickCategory);
            _loc12_.autoSize = false;
            _loc12_.data = _loc10_;
            _loc12_.x = _loc7_;
            _loc12_.y = _loc8_;
            _loc12_.width = _loc11_;
            _loc13_ = this._lang.getString("craft_cat." + _loc10_);
            this._tooltip.add(_loc12_,_loc13_,new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
            if(_loc10_ != "upgrade" && _loc10_ != "tactics")
            {
               _loc12_.enabled = Network.getInstance().playerData.compound.buildings.getNumCraftingBuildings(_loc10_) > 0;
               if(!_loc12_.enabled)
               {
                  this._tooltip.remove(_loc12_);
                  this._tooltip.add(_loc12_,this._lang.getString("tooltip.craft_build_" + _loc10_),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
                  if(_lastSelectedCategory == _loc10_)
                  {
                     _lastSelectedCategory = "tactics";
                  }
               }
            }
            _loc7_ += int(_loc11_ + _loc5_);
            this.mc_container.addChild(_loc12_);
            this._categoryButtons.push(_loc12_);
            _loc9_++;
         }
         this.gotoCategory(_lastSelectedCategory);
         if(param2 != null && this._selectedCategory != "upgrade")
         {
            this.selectBestSchematicOfItemType(param2);
         }
         this.updateLimitedSchematicsNotifcations();
         this.mc_container.addEventListener("UpgradeKitChanged",this.onUpgradeKitChanged,false,0,true);
      }
      
      private function updateLimitedSchematicsNotifcations() : void
      {
         var _loc1_:UINotificationCount = null;
         var _loc2_:Dictionary = null;
         var _loc3_:int = 0;
         var _loc4_:PushButton = null;
         var _loc5_:int = 0;
         for each(_loc1_ in this._limtedNotifications)
         {
            _loc1_.dispose();
         }
         this._limtedNotifications.length = 0;
         _loc2_ = Schematic.getLimitedCountByType();
         _loc3_ = 0;
         while(_loc3_ < this._categoryButtons.length)
         {
            _loc4_ = this._categoryButtons[_loc3_];
            _loc5_ = int(_loc2_[_loc4_.data]);
            if(_loc5_ > 0)
            {
               _loc1_ = new UINotificationCount(13475084);
               _loc1_.mouseEnabled = _loc1_.mouseChildren = false;
               _loc1_.label = _loc5_.toString();
               _loc1_.x = int(_loc4_.x);
               _loc1_.y = int(_loc4_.y);
               this.mc_container.addChild(_loc1_);
               this._limtedNotifications.push(_loc1_);
            }
            _loc3_++;
         }
      }
      
      override public function dispose() : void
      {
         var _loc1_:PushButton = null;
         var _loc2_:UINotificationCount = null;
         super.dispose();
         this._tooltip.removeAllFromParent(this.mc_container);
         this._tooltip = null;
         this._lang = null;
         this._xml = null;
         this._selectedItem = null;
         this._selectedSchematic = null;
         this.bmp_inventory.bitmapData.dispose();
         this.bmp_inventory.bitmapData = null;
         this.bmp_inventory.filters = [];
         this.btn_inventory.dispose();
         this.btn_inventory = null;
         this.btn_craft.dispose();
         this.btn_craft = null;
         this.ui_recipe.dispose();
         this.ui_schematicList.dispose();
         this.ui_skillTacticsBar.dispose();
         for each(_loc1_ in this._categoryButtons)
         {
            _loc1_.dispose();
         }
         this._categoryButtons = null;
         for each(_loc2_ in this._limtedNotifications)
         {
            _loc2_.dispose();
         }
         this._limtedNotifications = null;
      }
      
      override public function close() : void
      {
         super.close();
         Network.getInstance().playerData.inventory.clearSchematicNewFlags();
      }
      
      public function selectSchematic(param1:Schematic) : void
      {
         if(param1 == null)
         {
            return;
         }
         this.gotoCategory(param1.xml.@type.toString());
         this.ui_schematicList.selectSchematic(param1);
         this.onSchematicSelected(param1);
      }
      
      public function setCategoryAndSelectSchematicByType(param1:String, param2:String) : void
      {
         this.gotoCategory(param1);
         this.selectBestSchematicOfItemType(param2);
      }
      
      private function gotoCategory(param1:String) : void
      {
         var _loc2_:PushButton = null;
         var _loc4_:PushButton = null;
         switch(param1)
         {
            case "craftkit":
               param1 = "crafting";
         }
         var _loc3_:int = 0;
         while(_loc3_ < this._categoryButtons.length)
         {
            _loc4_ = this._categoryButtons[_loc3_];
            if(_loc4_.data == param1)
            {
               _loc2_ = _loc4_;
               break;
            }
            _loc3_++;
         }
         if(_loc2_ == null)
         {
            return;
         }
         if(this._selectedCategoryButton == _loc2_)
         {
            return;
         }
         if(this._selectedCategoryButton != null)
         {
            this._selectedCategoryButton.selected = false;
            this._selectedCategory = null;
         }
         this._selectedCategory = _loc2_.data;
         this._selectedCategoryButton = _loc2_;
         this._selectedCategoryButton.selected = true;
         _lastSelectedCategory = this._selectedCategory;
         switch(this._selectedCategory)
         {
            case "upgrade":
               this.mc_container.addChild(this.ui_upgradeList);
               if(this.ui_schematicList.parent != null)
               {
                  this.ui_schematicList.parent.removeChild(this.ui_schematicList);
               }
               this._selectedSchematic = null;
               this.onUpgradeItemSelected(this.ui_upgradeList.selectedItem);
               break;
            default:
               this.ui_schematicList.setCategory(this._selectedCategory);
               this.mc_container.addChild(this.ui_schematicList);
               if(this.ui_upgradeList.parent != null)
               {
                  this.ui_upgradeList.parent.removeChild(this.ui_upgradeList);
               }
               this._selectedItem = null;
               this.onSchematicSelected(this.ui_schematicList.selectedSchematic);
         }
         if(this._selectedCategory == "tactics")
         {
            sprite.addChild(this.ui_skillTacticsBar);
         }
         else if(this.ui_skillTacticsBar.parent != null)
         {
            this.ui_skillTacticsBar.parent.removeChild(this.ui_skillTacticsBar);
         }
      }
      
      private function selectBestSchematicOfItemType(param1:String) : void
      {
         var _loc5_:Schematic = null;
         var _loc2_:Schematic = null;
         var _loc3_:int = int.MIN_VALUE;
         var _loc4_:int = int.MIN_VALUE;
         for each(_loc5_ in this.ui_schematicList.schematicList)
         {
            if(_loc5_ != this._selectedSchematic)
            {
               if(_loc5_ != null && _loc5_.outputItem.type == param1)
               {
                  if(_loc5_.outputItem.level >= _loc3_)
                  {
                     _loc2_ = _loc5_;
                     _loc3_ = _loc5_.outputItem.level;
                  }
                  else if(_loc5_.outputItem.quantity > _loc4_)
                  {
                     _loc2_ = _loc5_;
                     _loc4_ = int(_loc5_.outputItem.quantity);
                  }
               }
            }
         }
         if(_loc2_ == null)
         {
            return;
         }
         this.ui_schematicList.selectSchematic(_loc2_);
         this.onSchematicSelected(this.ui_schematicList.selectedSchematic);
      }
      
      private function onUpgradeKitChanged(param1:Event) : void
      {
         this.onUpgradeItemSelected(this._selectedItem);
      }
      
      private function onCraftClicked(param1:MouseEvent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         if(Network.getInstance().isBusy)
         {
            return;
         }
         if(this._selectedCategory == "upgrade")
         {
            if(this._selectedItem == null)
            {
               return;
            }
            if(!Network.getInstance().playerData.isAdmin && !Settings.getInstance().itemUpgradingEnabled)
            {
               DialogueController.getInstance().showDisabledFeatureError();
               return;
            }
            if(!this._selectedItem.isUpgradable)
            {
               this._tooltip.add(this.btn_craft,this._lang.getString("upgradeable"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
               this._tooltip.show(this.btn_craft);
               Audio.sound.play("sound/interface/int-error.mp3");
            }
            this.btn_craft.updateTooltip();
            if(!this._selectedItem.isUpgradable)
            {
               return;
            }
            this._selectedItem.upgrade(this.ui_recipe.getUpgradeKitItem(),this.onUpgradeComplete);
         }
         else
         {
            if(this._selectedSchematic == null)
            {
               return;
            }
            if(!Network.getInstance().playerData.isAdmin && !Settings.getInstance().craftingEnabled)
            {
               DialogueController.getInstance().showDisabledFeatureError();
               return;
            }
            _loc2_ = this.ui_recipe.getSchematicInputItemIds();
            _loc3_ = this.canCraft(this._selectedSchematic,_loc2_);
            switch(_loc3_)
            {
               case 1:
                  this._tooltip.add(this.btn_craft,this._lang.getString("crafting_schem_unavailble"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
                  this._tooltip.show(this.btn_craft);
                  Audio.sound.play("sound/interface/int-error.mp3");
                  break;
               case 2:
                  this._tooltip.add(this.btn_craft,this._lang.getString("crafting_req_not_met"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
                  this._tooltip.show(this.btn_craft);
                  Audio.sound.play("sound/interface/int-error.mp3");
                  break;
               case 0:
            }
            if(this.btn_craft.cost > 0)
            {
               this.btn_craft.updateTooltip();
            }
            if(_loc3_ > 0)
            {
               return;
            }
            this._selectedSchematic.craft(_loc2_,this.onCraftingComplete);
         }
      }
      
      private function canCraft(param1:Schematic, param2:Array) : int
      {
         if(param1 == null)
         {
            return 1;
         }
         if(!Schematic.meetsLimitConstraints(param1.id))
         {
            return 1;
         }
         if(param2.length < param1.inputItemTypes.length || !Network.getInstance().playerData.meetsRequirements(param1.xml.recipe.children()))
         {
            return 2;
         }
         return 0;
      }
      
      private function onCraftingComplete(param1:Item) : void
      {
         if(param1 == null)
         {
            return;
         }
         this.onSchematicSelected(this._selectedSchematic);
         var _loc2_:CraftingCompleteDialogue = new CraftingCompleteDialogue(param1);
         _loc2_.open();
      }
      
      private function onUpgradeComplete(param1:Item) : void
      {
         if(param1 == null)
         {
            return;
         }
         this.ui_recipe.clearUpgradeKitItem();
         this.onUpgradeItemSelected(this._selectedItem);
         this.ui_upgradeList.update();
         var _loc2_:CraftingCompleteDialogue = new CraftingCompleteDialogue(param1,true);
         _loc2_.open();
      }
      
      private function onClickCategory(param1:MouseEvent) : void
      {
         var _loc2_:PushButton = PushButton(param1.currentTarget);
         this.gotoCategory(_loc2_.data);
      }
      
      private function onSchematicSelected(param1:Schematic) : void
      {
         var _loc6_:XML = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         if(param1 == null)
         {
            this.ui_recipe.clear();
            this.btn_craft.label = this._lang.getString("crafting_craft");
            this.btn_craft.enabled = false;
            return;
         }
         var _loc2_:PlayerData = Network.getInstance().playerData;
         this._selectedSchematic = param1;
         this.ui_recipe.showSchematic(this._selectedSchematic);
         var _loc3_:int = param1.getCraftingCost();
         if(!Network.getInstance().playerData.isAdmin && !Settings.getInstance().craftingEnabled)
         {
            this.btn_craft.label = this._lang.getString("disabled");
            this.btn_craft.enabled = false;
         }
         else if(_loc3_ <= 0)
         {
            this.btn_craft.label = this._lang.getString("crafting_craft") + " - " + this._lang.getString("free");
            this.btn_craft.showIcon = false;
            this.btn_craft.cost = 0;
         }
         else
         {
            this.btn_craft.label = this._lang.getString("crafting_craft");
            this.btn_craft.showIcon = true;
            this.btn_craft.cost = _loc3_;
         }
         var _loc4_:Boolean = Schematic.meetsLimitConstraints(param1.id);
         this.btn_craft.enabled = _loc4_;
         if(_loc4_)
         {
            this.btn_craft.updateTooltip();
            var _loc5_:XMLList = this._selectedSchematic.outputItem.xml.res.res;
            if(_loc5_.length() > 0)
            {
               for each(_loc6_ in _loc5_)
               {
                  _loc7_ = _loc6_.@id.toString();
                  _loc8_ = int(_loc6_.@q);
                  _loc9_ = this._selectedSchematic.outputItem.quantity * _loc8_;
                  if(_loc9_ >= _loc2_.compound.resources.getAvailableStorageCapacity(_loc7_))
                  {
                     this.btn_craft.enabled = false;
                     this.btn_craft.cost = 0;
                     TooltipManager.getInstance().add(this.btn_craft,"<b><font color=\'" + Color.colorToHex(Effects.COLOR_WARNING) + "\'>" + Language.getInstance().getString("msg_storage_full") + "</font></b>",new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
                     break;
                  }
               }
            }
            return;
         }
         TooltipManager.getInstance().add(this.btn_craft,Language.getInstance().getString("crafting_schem_unavailble"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
      }
      
      private function onUpgradeItemSelected(param1:Item) : void
      {
         var _loc2_:int = param1 != null ? param1.getUpgradeCost() : -1;
         if(this.ui_recipe.getUpgradeKitItem() != null)
         {
            _loc2_ = 0;
         }
         this._selectedItem = param1;
         this.ui_recipe.showUpgrade(this._selectedItem);
         if(!Network.getInstance().playerData.isAdmin && !Settings.getInstance().itemUpgradingEnabled)
         {
            this.btn_craft.label = this._lang.getString("disabled");
            this.btn_craft.enabled = false;
         }
         else if(_loc2_ < 0 || !Network.getInstance().playerData.canUpgradeItem(param1))
         {
            this.btn_craft.label = this._lang.getString("crafting_craft");
            this.btn_craft.enabled = false;
         }
         else if(_loc2_ == 0)
         {
            this._tooltip.remove(this.btn_craft);
            this.btn_craft.label = this._lang.getString("crafting_craft") + " - " + this._lang.getString("free");
            this.btn_craft.cost = 0;
            this.btn_craft.showIcon = false;
            this.btn_craft.enabled = true;
         }
         else
         {
            this.btn_craft.label = this._lang.getString("crafting_craft");
            this.btn_craft.cost = _loc2_;
            this.btn_craft.enabled = true;
            this.btn_craft.showIcon = true;
            this.btn_craft.updateTooltip();
         }
      }
      
      private function onClickInventory(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         var dlg:InventoryDialogue = new InventoryDialogue(this._selectedCategory);
         dlg.closed.addOnce(function(param1:Dialogue):void
         {
            if(_selectedSchematic != null)
            {
               onSchematicSelected(_selectedSchematic);
            }
            else if(_selectedItem != null)
            {
               onUpgradeItemSelected(_selectedItem);
            }
         });
         dlg.open();
      }
   }
}

