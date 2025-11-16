package thelaststand.app.game.gui.crafting
{
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.AntiAliasType;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.data.Inventory;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.Schematic;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.SurvivorState;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.UIRequirementsChecklist;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.dialogues.ClothingPreviewDisplayOptions;
   import thelaststand.app.game.gui.dialogues.ItemListDialogue;
   import thelaststand.app.game.gui.dialogues.ItemListOptions;
   import thelaststand.app.game.gui.dialogues.SpeedUpDialogue;
   import thelaststand.app.game.gui.dialogues.StoreDialogue;
   import thelaststand.app.game.gui.dialogues.UIMaterialRequirementIcon;
   import thelaststand.app.game.gui.injury.UIInputItem;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.XMLUtils;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class UIRecipeSchematic extends UIComponent
   {
      
      private const NUM_COMPONENT_SLOTS:int = 6;
      
      private var _width:int = 258;
      
      private var _lang:Language;
      
      private var _schematic:Schematic;
      
      private var _componentList:Vector.<UIMaterialRequirementIcon>;
      
      private var txt_selectInput:BodyTextField;
      
      private var txt_compNeeded:BodyTextField;
      
      private var ui_requirements:UIRequirementsChecklist;
      
      private var ui_input1:UIInputItem;
      
      private var ui_input2:UIInputItem;
      
      private var ui_inputKit:UICraftKitInput;
      
      private var ui_itemInfo:UIItemInfo;
      
      public function UIRecipeSchematic()
      {
         var _loc2_:UIMaterialRequirementIcon = null;
         super();
         this._lang = Language.getInstance();
         this._componentList = new Vector.<UIMaterialRequirementIcon>();
         this.txt_selectInput = new BodyTextField({
            "text":this._lang.getString("crafting_select_input"),
            "color":12961221,
            "size":11,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_compNeeded = new BodyTextField({
            "text":this._lang.getString("crafting_components"),
            "color":12961221,
            "size":11,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.ui_requirements = new UIRequirementsChecklist();
         this.ui_requirements.width = this._width;
         this.ui_input1 = new UIInputItem();
         this.ui_input1.clicked.add(this.onInputItemClicked);
         this.ui_input1.mouseOver.add(this.onInfoObjectMouseOver);
         this.ui_input2 = new UIInputItem();
         this.ui_input2.clicked.add(this.onInputItemClicked);
         this.ui_input2.mouseOver.add(this.onInfoObjectMouseOver);
         this.ui_inputKit = new UICraftKitInput();
         this.ui_inputKit.clicked.add(this.onCraftKitItemClicked);
         this.ui_inputKit.mouseOver.add(this.onCraftKitMouseOver);
         this.ui_itemInfo = new UIItemInfo();
         var _loc1_:int = 0;
         while(_loc1_ < this.NUM_COMPONENT_SLOTS)
         {
            _loc2_ = new UIMaterialRequirementIcon();
            _loc2_.borderColor = 8092539;
            this._componentList.push(_loc2_);
            _loc1_++;
         }
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIMaterialRequirementIcon = null;
         super.dispose();
         this._lang = null;
         this._schematic = null;
         for each(_loc1_ in this._componentList)
         {
            _loc1_.dispose();
         }
         this._componentList = null;
         this.txt_compNeeded.dispose();
         this.txt_selectInput.dispose();
         this.ui_requirements.dispose();
         this.ui_input1.dispose();
         this.ui_input2.dispose();
         this.ui_inputKit.dispose();
         this.ui_itemInfo.dispose();
      }
      
      override protected function draw() : void
      {
         var ty:int;
         var numInputs:int;
         var tx:int;
         var col:int;
         var numCols:int;
         var itemReqList:XMLList;
         var numItemReqs:int;
         var reqList:XMLList;
         var i:int = 0;
         var itemType1:String = null;
         var itemXML1:XML = null;
         var itemName1:String = null;
         var itemType2:String = null;
         var itemXML2:XML = null;
         var itemName2:String = null;
         var itemReqNode:XML = null;
         var reqIcon:UIMaterialRequirementIcon = null;
         i = numChildren - 1;
         while(i >= 0)
         {
            removeChildAt(i);
            i--;
         }
         this.txt_selectInput.x = -2;
         this.txt_compNeeded.x = this.txt_selectInput.x;
         ty = 0;
         numInputs = int(this._schematic.inputItemTypes.length);
         if(numInputs > 0)
         {
            this.txt_selectInput.y = ty;
            this.ui_input1.y = int(this.txt_selectInput.y + this.txt_selectInput.height + 2);
            this.ui_input1.visible = this._schematic.inputItemTypes.length >= 1;
            this.ui_input1.item = null;
            if(this.ui_input1.visible)
            {
               itemType1 = this._schematic.inputItemTypes[0];
               itemXML1 = ItemFactory.getItemDefinition(itemType1);
               itemName1 = this._lang.getString("items." + itemType1);
               if(itemXML1.@vint == "1")
               {
                  itemName1 = this._lang.getString("quality_type.vintage",itemName1);
               }
               this.ui_input1.getBuyCraftOptions().setItem(itemType1);
               this.ui_input1.getBuyCraftOptions().showCraft = Network.getInstance().playerData.inventory.hasOtherSchematicForItem(itemType1,this._schematic);
               this.ui_input1.label = itemName1;
               this.ui_input1.data = {"item":itemType1};
            }
            this.ui_input2.x = 134;
            this.ui_input2.y = int(this.ui_input1.y);
            this.ui_input2.visible = this._schematic.inputItemTypes.length >= 2;
            this.ui_input2.item = null;
            if(this.ui_input2.visible)
            {
               itemType2 = this._schematic.inputItemTypes[1];
               itemXML2 = ItemFactory.getItemDefinition(itemType2);
               itemName2 = this._lang.getString("items." + itemType2);
               if(itemXML2.@vint == "1")
               {
                  itemName2 = this._lang.getString("quality_type.vintage",itemName2);
               }
               this.ui_input2.getBuyCraftOptions().setItem(itemType2);
               this.ui_input1.getBuyCraftOptions().showCraft = Network.getInstance().playerData.inventory.hasOtherSchematicForItem(itemType2,this._schematic);
               this.ui_input2.label = itemName2;
               this.ui_input2.data = {"item":itemType2};
            }
            addChild(this.txt_selectInput);
            addChild(this.ui_input1);
            addChild(this.ui_input2);
            ty = int(this.ui_input2.y + this.ui_input2.height + 5);
         }
         if(this._schematic.allowCraftKit)
         {
            this.ui_inputKit.x = numInputs >= 1 ? this._width - this.ui_inputKit.width : 0;
            this.ui_inputKit.y = numInputs == 1 ? int(this.txt_selectInput.y) : ty;
            addChild(this.ui_inputKit);
            ty = int(this.ui_inputKit.y + this.ui_inputKit.height + 2);
         }
         else if(this.ui_inputKit.parent != null)
         {
            this.ui_inputKit.parent.removeChild(this.ui_inputKit);
         }
         this.txt_compNeeded.y = ty;
         addChild(this.txt_compNeeded);
         ty = int(this.txt_compNeeded.y + this.txt_compNeeded.height + 2);
         tx = 0;
         col = 0;
         numCols = 2;
         itemReqList = this._schematic.xml.recipe.itm + this._schematic.xml.recipe.res;
         numItemReqs = int(itemReqList.length());
         i = 0;
         while(i < this.NUM_COMPONENT_SLOTS)
         {
            itemReqNode = itemReqList[i];
            reqIcon = this._componentList[i];
            reqIcon.x = tx;
            reqIcon.y = ty;
            addChild(reqIcon);
            if(i < numItemReqs)
            {
               reqIcon.visible = true;
               reqIcon.setMaterial(itemReqNode.@id.toString(),int(itemReqNode.toString()));
               if(++col >= numCols || i == numItemReqs - 1)
               {
                  tx = 0;
                  ty += int(reqIcon.height + 4);
                  col = 0;
               }
               else
               {
                  tx += 134;
               }
            }
            else
            {
               reqIcon.visible = false;
               reqIcon.setMaterial(null,0);
            }
            i++;
         }
         ty += 2;
         reqList = this._schematic.xml.recipe.children().(localName() != "itm" && localName() != "res");
         reqList = XMLUtils.sortXMLList(reqList,function(param1:XML, param2:XML):int
         {
            return int(param1.@lvl) - int(param2.@lvl);
         });
         this.ui_requirements.list = reqList;
         this.ui_requirements.y = ty;
         addChild(this.ui_requirements);
      }
      
      private function getCraftKitsFromInventory() : Vector.<Item>
      {
         var inventory:Inventory = Network.getInstance().playerData.inventory;
         return inventory.getItemsOfCategoryWhere("craftkit",function(param1:Item):Boolean
         {
            var item:Item = param1;
            return item.xml.kit.category.(toString() == _schematic.category).length() > 0;
         });
      }
      
      public function getOutputItem() : Item
      {
         if(this._schematic == null)
         {
            return null;
         }
         var _loc1_:Item = this._schematic.outputItem;
         if(this.ui_inputKit.item != null)
         {
            _loc1_ = Item.createCraftingKitVariant(_loc1_,this.ui_inputKit.item);
         }
         return _loc1_;
      }
      
      private function onCraftKitItemClicked(param1:MouseEvent) : void
      {
         var storeDlg:StoreDialogue = null;
         var e:MouseEvent = param1;
         var itemList:Vector.<Item> = this.getCraftKitsFromInventory();
         if(itemList.length == 0)
         {
            storeDlg = new StoreDialogue("craftkit");
            storeDlg.closed.addOnce(function(param1:Dialogue):void
            {
               openCraftKitInventory(getCraftKitsFromInventory());
            });
            storeDlg.open();
            return;
         }
         this.openCraftKitInventory(itemList);
      }
      
      private function openCraftKitInventory(param1:Vector.<Item>) : void
      {
         var self:UIRecipeSchematic = null;
         var itemDlg:ItemListDialogue = null;
         var itemList:Vector.<Item> = param1;
         var options:ItemListOptions = new ItemListOptions();
         options.clothingPreviews = ClothingPreviewDisplayOptions.DISABLED;
         options.showNoneItem = true;
         self = this;
         itemDlg = new ItemListDialogue(Language.getInstance().getString("crafting_craftkit_item_title"),itemList,options);
         itemDlg.selected.add(function(param1:Item):void
         {
            ui_inputKit.item = param1;
            if(param1 != null)
            {
               ui_itemInfo.addRolloverTarget(ui_inputKit);
            }
            else
            {
               ui_itemInfo.removeRolloverTarget(ui_inputKit);
            }
            self.dispatchEvent(new Event("itemChanged",true));
            itemDlg.close();
         });
         itemDlg.open();
      }
      
      private function onInputItemClicked(param1:MouseEvent) : void
      {
         var inputItem:UIInputItem = null;
         var itemDlg:ItemListDialogue = null;
         var e:MouseEvent = param1;
         inputItem = UIInputItem(e.currentTarget);
         var itemList:Vector.<Item> = Network.getInstance().playerData.inventory.getItemsOfTypeWhere(inputItem.data.item,function(param1:Item):Boolean
         {
            if(inputItem == ui_input1 && param1 == ui_input2.item)
            {
               return false;
            }
            if(inputItem == ui_input2 && param1 == ui_input1.item)
            {
               return false;
            }
            return true;
         });
         var options:ItemListOptions = new ItemListOptions();
         options.showNoneItem = true;
         itemDlg = new ItemListDialogue(this._lang.getString("crafting_select_input_title"),itemList,options);
         itemDlg.selected.add(function(param1:Item):void
         {
            var equipper:Survivor = null;
            var dlgAway:MessageBox = null;
            var selectedItem:Item = param1;
            var loadout:SurvivorLoadout = Network.getInstance().playerData.loadoutManager.getItemOffensiveLoadout(selectedItem);
            if(loadout != null && loadout.survivor != null && (Boolean(loadout.survivor.state & SurvivorState.ON_MISSION) || Boolean(loadout.survivor.state & SurvivorState.ON_ASSIGNMENT)))
            {
               equipper = loadout.survivor;
               dlgAway = new MessageBox(_lang.getString("srv_mission_cantsalvage_away_msg",equipper.firstName));
               dlgAway.addTitle(_lang.getString("srv_mission_cantsalvage_away_title",equipper.firstName));
               dlgAway.addButton(_lang.getString("srv_mission_cantsalvage_away_ok"));
               if(!(loadout.survivor.state & SurvivorState.ON_ASSIGNMENT))
               {
                  dlgAway.addButton(_lang.getString("srv_mission_cantsalvage_away_speedup"),true,{
                     "buttonClass":PurchasePushButton,
                     "width":100
                  }).clicked.add(function(param1:MouseEvent):void
                  {
                     var _loc2_:SpeedUpDialogue = new SpeedUpDialogue(Network.getInstance().playerData.missionList.getMissionById(equipper.missionId));
                     _loc2_.open();
                  });
               }
               dlgAway.open();
               return;
            }
            inputItem.item = selectedItem;
            if(selectedItem != null)
            {
               ui_itemInfo.addRolloverTarget(inputItem);
            }
            else
            {
               ui_itemInfo.removeRolloverTarget(inputItem);
            }
            itemDlg.close();
         });
         itemDlg.open();
      }
      
      private function onInfoObjectMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:UIInputItem = UIInputItem(param1.currentTarget);
         this.ui_itemInfo.setItem(_loc2_.item);
      }
      
      private function onCraftKitMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:UICraftKitInput = UICraftKitInput(param1.currentTarget);
         this.ui_itemInfo.setItem(_loc2_.item);
      }
      
      public function get schematic() : Schematic
      {
         return this._schematic;
      }
      
      public function set schematic(param1:Schematic) : void
      {
         this._schematic = param1;
         this.ui_input1.item = null;
         this.ui_input2.item = null;
         this.ui_inputKit.item = null;
         invalidate();
      }
      
      public function get inputItems() : Array
      {
         var _loc1_:Array = [];
         if(this.ui_input1.item != null)
         {
            _loc1_.push(this.ui_input1.item);
         }
         if(this.ui_input2.item != null)
         {
            _loc1_.push(this.ui_input2.item);
         }
         if(this.ui_inputKit.item != null)
         {
            _loc1_.push(this.ui_inputKit.item);
         }
         return _loc1_;
      }
      
      public function get inputItemIds() : Array
      {
         var _loc1_:Array = [];
         if(this.ui_input1.item != null)
         {
            _loc1_.push(this.ui_input1.item.id);
         }
         if(this.ui_input2.item != null)
         {
            _loc1_.push(this.ui_input2.item.id);
         }
         if(this.ui_inputKit.item != null)
         {
            _loc1_.push(this.ui_inputKit.item.id);
         }
         return _loc1_;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
   }
}

