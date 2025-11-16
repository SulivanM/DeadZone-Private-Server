package thelaststand.app.game.gui.lists
{
   import flash.display.Bitmap;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Settings;
   import thelaststand.app.game.data.ClothingAccessory;
   import thelaststand.app.game.data.CrateItem;
   import thelaststand.app.game.data.CrateMysteryItem;
   import thelaststand.app.game.data.EffectItem;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.Gear;
   import thelaststand.app.game.data.IRecyclable;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemQualityType;
   import thelaststand.app.game.data.MedicalItem;
   import thelaststand.app.game.data.SchematicItem;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.SurvivorState;
   import thelaststand.app.game.data.UnknownItem;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.gui.UIItemControl;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.dialogues.ClothingPreviewDisplayOptions;
   import thelaststand.app.game.gui.dialogues.CrateInspectionDialogue;
   import thelaststand.app.game.gui.dialogues.CrateMysteryUnlockDialogue;
   import thelaststand.app.game.gui.dialogues.ItemListOptions;
   import thelaststand.app.game.gui.dialogues.RecycleDialogue;
   import thelaststand.app.game.gui.dialogues.SpeedUpDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class UIInventoryList extends UIPagedList
   {
      
      private static var _sortTypeIndices:Dictionary;
      
      private var _allowSelection:Boolean = true;
      
      private var _allowSelectionOfUnequippable:Boolean = false;
      
      private var _controlRolloutTimer:Timer;
      
      private var _showControls:Boolean;
      
      private var _showEquippedIcons:Boolean;
      
      private var _showNewIcons:Boolean = true;
      
      private var _category:String;
      
      private var _maxLevel:int = 2147483647;
      
      private var _itemSize:int;
      
      private var _itemList:Vector.<Item>;
      
      private var _itemById:Dictionary;
      
      private var _xml:XML;
      
      private var _options:ItemListOptions;
      
      private var _itemTints:Dictionary;
      
      private var _disposed:Boolean;
      
      private var ui_itemInfo:UIItemInfo;
      
      private var ui_itemControl:UIItemControl;
      
      public function UIInventoryList(param1:int = 64, param2:int = 10, param3:ItemListOptions = null)
      {
         var _loc4_:XML = null;
         this._itemTints = new Dictionary();
         super();
         this._options = param3 || new ItemListOptions();
         this._itemSize = param1;
         _paddingX = param2;
         _paddingY = param2;
         this._xml = ResourceManager.getInstance().getResource("xml/items.xml").content;
         listItemClass = UIInventoryListItem;
         _itemWidth = this._itemSize + 4;
         _itemHeight = this._itemSize + 4;
         this._controlRolloutTimer = new Timer(500,1);
         this._controlRolloutTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onControlRolloutTimerExpired,false,0,true);
         if(_sortTypeIndices == null)
         {
            _sortTypeIndices = new Dictionary();
            for each(_loc4_ in this._xml.sortorder.cat)
            {
               _sortTypeIndices[_loc4_.toString()] = _loc4_.childIndex();
            }
         }
         this.ui_itemInfo = new UIItemInfo();
         switch(param3.clothingPreviews)
         {
            case ClothingPreviewDisplayOptions.DEFAULT:
               this.ui_itemInfo.displayClothingPreview = Settings.getInstance().clothingPreview;
               break;
            case ClothingPreviewDisplayOptions.ENABLED:
               this.ui_itemInfo.displayClothingPreview = true;
               break;
            case ClothingPreviewDisplayOptions.DISABLED:
               this.ui_itemInfo.displayClothingPreview = false;
         }
         this.ui_itemControl = new UIItemControl();
         this.ui_itemControl.recycleClicked.add(this.onItemRecycleClicked);
         this.ui_itemControl.disposeClicked.add(this.onItemDisposeClicked);
         this.ui_itemControl.inspectClicked.add(this.onItemInspectClicked);
         this.ui_itemControl.unlockClicked.add(this.onItemUnlockClicked);
         this.ui_itemControl.addEventListener(MouseEvent.MOUSE_OVER,this.onItemControlMouseOver,false,0,true);
         this.ui_itemControl.addEventListener(MouseEvent.MOUSE_OUT,this.onItemMouseOut,false,0,true);
      }
      
      override public function dispose() : void
      {
         if(this._disposed)
         {
            return;
         }
         this._disposed = true;
         super.dispose();
         this.ui_itemInfo.dispose();
         this.ui_itemControl.recycleClicked.remove(this.onItemRecycleClicked);
         this.ui_itemControl.disposeClicked.remove(this.onItemDisposeClicked);
         this.ui_itemControl.inspectClicked.remove(this.onItemInspectClicked);
         this.ui_itemControl.unlockClicked.remove(this.onItemUnlockClicked);
         this.ui_itemControl.removeEventListener(MouseEvent.MOUSE_OUT,this.onItemMouseOut);
         this.ui_itemControl.dispose();
         this._xml = null;
         this._itemList = null;
         this._itemById = null;
         this._itemTints = null;
         this._options.loadout = null;
         this._options = null;
         this._controlRolloutTimer.stop();
         this._controlRolloutTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onControlRolloutTimerExpired);
      }
      
      public function getItemById(param1:String) : UIInventoryListItem
      {
         return this._itemById[param1];
      }
      
      public function setEnabledStateByItemId(param1:String, param2:Boolean) : void
      {
         var _loc3_:UIInventoryListItem = this._itemById[param1];
         if(_loc3_ != null)
         {
            _loc3_.unequippable = !param2;
         }
      }
      
      public function setItemTint(param1:String, param2:int) : void
      {
         if(param2 < 0 || param2 > 16777215)
         {
            delete this._itemTints[param1];
         }
         else
         {
            this._itemTints[param1] = param2;
         }
         if(!this._itemById[param1])
         {
            return;
         }
         UIInventoryListItem(this._itemById[param1]).tint = param2;
      }
      
      override protected function createItems() : void
      {
         var _loc4_:int = 0;
         var _loc5_:UIInventoryListItem = null;
         var _loc6_:XML = null;
         var _loc7_:String = null;
         var _loc8_:* = false;
         var _loc9_:Gear = null;
         var _loc10_:Weapon = null;
         var _loc11_:ClothingAccessory = null;
         _selectedItem = null;
         this._itemById = new Dictionary(true);
         this._controlRolloutTimer.stop();
         if(this.ui_itemControl != null)
         {
            this.ui_itemControl.visible = false;
         }
         if(this._options.sortItems)
         {
            this._itemList.sort(this.inventoryCompare);
         }
         var _loc1_:int = getColsPerPage();
         var _loc2_:int = getRowsPerPage();
         var _loc3_:int = _loc1_ * _loc2_ * Math.ceil(Math.max(this.itemList.length,1) / (_loc1_ * _loc2_));
         if(_loc3_ < _items.length)
         {
            _loc4_ = _loc3_;
            while(_loc4_ < _items.length)
            {
               this.ui_itemInfo.removeRolloverTarget(_items[_loc4_]);
               _items[_loc4_].dispose();
               _loc4_++;
            }
         }
         _items.length = _loc3_;
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = _items[_loc4_] as UIInventoryListItem;
            if(_loc5_ == null)
            {
               _loc5_ = new UIInventoryListItem(this._itemSize);
            }
            if(_loc4_ < this.itemList.length)
            {
               if(this.itemList[_loc4_] == null)
               {
                  _loc5_.dispose();
                  _loc5_ = new UIInventoryListItem(this._itemSize,true);
               }
               if(this.itemList[_loc4_] != null)
               {
                  _loc5_.itemData = this.itemList[_loc4_];
                  _loc5_.showEquippedIcon = this._options.showEquippedIcons;
                  _loc5_.showNewIcon = this._options.showNewIcons;
                  if(this.itemList[_loc4_].category == "resource")
                  {
                     _loc6_ = this.itemList[_loc4_].xml.res.res[0];
                     _loc7_ = _loc6_.@id.toString();
                     if(this._options.showResourceLimited)
                     {
                        _loc5_.unequippable = _loc7_ != GameResources.CASH && Network.getInstance().playerData.compound.resources.getAvailableStorageCapacity(_loc7_) <= 0;
                     }
                  }
                  else if(_loc5_.itemData.category == "weapon" || _loc5_.itemData.category == "gear")
                  {
                     _loc8_ = _loc5_.itemData.level <= this._options.maxLevel;
                     if(this._options.loadout != null)
                     {
                        _loc9_ = _loc5_.itemData as Gear;
                        if(_loc9_ != null && !_loc9_.supportsSurvivorClass(this._options.loadout.survivor.classId))
                        {
                           _loc8_ = false;
                        }
                        _loc10_ = _loc5_.itemData as Weapon;
                        if(_loc10_ != null && !_loc10_.supportsSurvivorClass(this._options.loadout.survivor.classId))
                        {
                           _loc8_ = false;
                        }
                        if(this._options.showActiveGearQuantities && _loc5_.itemData.quantifiable)
                        {
                           _loc5_.image.quantity = Network.getInstance().playerData.loadoutManager.getAvailableQuantity(_loc5_.itemData,this._options.loadout.survivor,this._options.loadout.type);
                        }
                     }
                     else if(this._options.showActiveGearQuantities && _loc5_.itemData.quantifiable)
                     {
                        _loc5_.image.quantityFieldSize = 14;
                        _loc5_.image.quantityAvailable = Network.getInstance().playerData.loadoutManager.getAvailableQuantity(_loc5_.itemData);
                     }
                     _loc5_.unequippable = !_loc8_;
                  }
                  else if(_loc5_.itemData.category == "clothing")
                  {
                     _loc11_ = _loc5_.itemData as ClothingAccessory;
                     if(_loc11_ != null)
                     {
                        if(this._options.loadout != null && !_loc11_.supportsSurvivorClass(this._options.loadout.survivor.classId))
                        {
                           _loc5_.unequippable = true;
                        }
                     }
                  }
                  else
                  {
                     _loc5_.unequippable = false;
                  }
                  this.ui_itemInfo.addRolloverTarget(_loc5_);
               }
               _loc5_.clicked.add(this.onItemClicked);
               _loc5_.mouseOver.add(this.onItemMouseOver);
               _loc5_.mouseOut.add(this.onItemMouseOut);
               _loc5_.enabled = true;
               _loc5_.tint = this._itemTints[_loc5_.id] != undefined ? int(this._itemTints[_loc5_.id]) : -1;
            }
            else
            {
               _loc5_.itemData = null;
               _loc5_.enabled = false;
               _loc5_.unequippable = false;
               _loc5_.tint = -1;
            }
            mc_pageContainer.addChild(_loc5_);
            _items[_loc4_] = _loc5_;
            if(_loc5_ != null && _loc5_.itemData != null)
            {
               this._itemById[_loc5_.itemData.id] = _loc5_;
            }
            _loc4_++;
         }
         super.createItems();
      }
      
      override protected function positionItems() : void
      {
         var _loc1_:UIInventoryListItem = null;
         for each(_loc1_ in _items)
         {
            _loc1_.updateNewFlag();
         }
         super.positionItems();
      }
      
      private function inventoryCompare(param1:Item, param2:Item) : int
      {
         var _loc3_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:EffectItem = null;
         var _loc9_:EffectItem = null;
         var _loc10_:int = 0;
         var _loc11_:MedicalItem = null;
         var _loc12_:MedicalItem = null;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         if(param1 == null)
         {
            return -1;
         }
         if(param2 == null)
         {
            return 1;
         }
         var _loc4_:int = int(_sortTypeIndices[param1.category]);
         var _loc5_:int = int(_sortTypeIndices[param2.category]);
         var _loc6_:int = _loc4_ - _loc5_;
         if(_loc6_ == 0)
         {
            if(param1.category == "weapon" && param2.category == "weapon" || param1.category == "gear" && param2.category == "gear" || param1.category == "schematic" && param2.category == "schematic")
            {
               if(param1.level != param2.level)
               {
                  return param2.level - param1.level;
               }
            }
            if(param1.category == "effect" && param2.category == "effect")
            {
               _loc8_ = EffectItem(param1);
               _loc9_ = EffectItem(param2);
               _loc10_ = int(_loc8_.effect.group.localeCompare(_loc9_.effect.group));
               if(_loc10_ != 0)
               {
                  return _loc10_;
               }
            }
            if(param1.category == "medical" && param2.category == "medical")
            {
               _loc11_ = MedicalItem(param1);
               _loc12_ = MedicalItem(param2);
               _loc13_ = int(_loc11_.medicalClass.localeCompare(_loc12_.medicalClass));
               if(_loc13_ != 0)
               {
                  return _loc13_;
               }
               _loc14_ = _loc11_.medicalGrade - _loc12_.medicalGrade;
               if(_loc14_ != 0)
               {
                  return _loc14_;
               }
            }
            _loc7_ = int(param1.getBaseName().toLowerCase().localeCompare(param2.getBaseName().toLowerCase()));
            if(_loc7_ != 0)
            {
               return _loc7_;
            }
            return param1.id.localeCompare(param2.id);
         }
         return _loc6_;
      }
      
      private function onItemMouseOver(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         if(stage == null)
         {
            return;
         }
         var _loc2_:UIInventoryListItem = UIInventoryListItem(param1.currentTarget);
         if(_loc2_.itemData == null || _loc2_.itemData is UnknownItem)
         {
            return;
         }
         var _loc3_:Array = [];
         if(this.options.showMaxUpgradeLevel)
         {
            _loc4_ = _loc2_.itemData.getMaxLevel();
            if(_loc2_.itemData.isUpgradable && _loc2_.itemData.level < _loc4_)
            {
               _loc3_.push(Language.getInstance().getString("crafting_info_maxlevel",_loc4_ + 1));
            }
         }
         if(!_loc2_.itemData.isTradable)
         {
            _loc3_.push(Language.getInstance().getString("itm_details.notrade"));
         }
         this.ui_itemInfo.extraInfo = _loc3_.length > 0 ? _loc3_.join("<br/>") : null;
         this.ui_itemInfo.setItem(_loc2_.itemData,this._options.loadout,this._options.itemInfoParams);
         if(_loc2_ == _selectedItem)
         {
            this._controlRolloutTimer.stop();
            if(this.ui_itemControl != null)
            {
               this.ui_itemControl.item = _loc2_.itemData;
               this.ui_itemControl.visible = true;
            }
         }
      }
      
      private function onItemMouseOut(param1:MouseEvent) : void
      {
         if(param1.relatedObject == null || param1.relatedObject != this.ui_itemControl && !this.ui_itemControl.contains(param1.relatedObject))
         {
            this._controlRolloutTimer.reset();
            this._controlRolloutTimer.start();
         }
      }
      
      private function onItemControlMouseOver(param1:MouseEvent) : void
      {
         this._controlRolloutTimer.stop();
      }
      
      private function onControlRolloutTimerExpired(param1:TimerEvent) : void
      {
         if(this.ui_itemControl != null)
         {
            this.ui_itemControl.visible = false;
         }
      }
      
      override protected function onItemClicked(param1:MouseEvent) : void
      {
         var _loc2_:UIInventoryListItem = null;
         if(param1.shiftKey)
         {
            return;
         }
         _loc2_ = param1.currentTarget as UIInventoryListItem;
         if(_loc2_.selectable == false)
         {
            return;
         }
         if(_loc2_.unequippable && !this._options.allowSelectionOfUnequippable)
         {
            Audio.sound.play("sound/interface/int-error.mp3");
            return;
         }
         if(_selectedItem != null && _selectedItem != _loc2_)
         {
            _selectedItem.selected = false;
            _selectedItem = null;
         }
         _selectedItem = _loc2_;
         _selectedItem.selected = this._options.allowSelection;
         if(this._options.showControls)
         {
            this.ui_itemControl.align = this.ui_itemInfo.displaySide == "right" ? UIItemControl.ALIGN_LEFT : UIItemControl.ALIGN_RIGHT;
            this.ui_itemControl.x = mc_pageContainer.x + (this.ui_itemInfo.displaySide == "right" ? int(_selectedItem.x - this.ui_itemControl.width - 2) : int(_selectedItem.x + _selectedItem.width + 2));
            this.ui_itemControl.y = int(_selectedItem.y + (_selectedItem.height - this.ui_itemControl.height) * 0.5);
            this.ui_itemControl.item = _loc2_.itemData;
            this.ui_itemControl.visible = true;
            addChild(this.ui_itemControl);
            this._controlRolloutTimer.stop();
         }
         changed.dispatch();
      }
      
      private function onItemRecycleClicked() : void
      {
         var lang:Language;
         var showRecycleDialogue:Function;
         var offLoadout:SurvivorLoadout;
         var listItem:UIInventoryListItem = null;
         var item:Item = null;
         var currPage:int = 0;
         var equipper:Survivor = null;
         var dlgAway:MessageBox = null;
         var boughtMsg:MessageBox = null;
         var uniqueMsg:MessageBox = null;
         var effectMsg:MessageBox = null;
         if(_selectedItem == null)
         {
            return;
         }
         listItem = UIInventoryListItem(_selectedItem);
         item = listItem.itemData;
         if(item == null)
         {
            return;
         }
         this.ui_itemControl.visible = false;
         currPage = _currentPage;
         lang = Language.getInstance();
         showRecycleDialogue = function():void
         {
            var dlgRecycle:RecycleDialogue = new RecycleDialogue(item);
            dlgRecycle.recycled.addOnce(function(param1:IRecyclable):void
            {
               var _loc3_:int = 0;
               if(_disposed)
               {
                  return;
               }
               var _loc2_:Item = Item(param1);
               if(_loc2_ == null)
               {
                  return;
               }
               if(_loc2_.quantity <= 0)
               {
                  _loc3_ = int(_itemList.indexOf(_loc2_));
                  if(_loc3_ > -1)
                  {
                     _itemList.splice(_loc3_,1);
                  }
                  listItem.itemData = null;
                  createItems();
               }
               else
               {
                  listItem.itemData = _loc2_;
                  positionItems();
               }
               gotoPage(currPage,false);
            });
            dlgRecycle.open();
         };
         offLoadout = Network.getInstance().playerData.loadoutManager.getItemOffensiveLoadout(item);
         if(offLoadout != null && offLoadout.survivor != null && (Boolean(offLoadout.survivor.state & SurvivorState.ON_MISSION) || Boolean(offLoadout.survivor.state & SurvivorState.ON_ASSIGNMENT)))
         {
            equipper = offLoadout.survivor;
            dlgAway = new MessageBox(lang.getString("srv_mission_cantrecycle_away_msg",equipper.firstName));
            dlgAway.addTitle(lang.getString("srv_mission_cantrecycle_away_title",equipper.firstName));
            dlgAway.addButton(lang.getString("srv_mission_cantrecycle_away_ok"));
            if(!(offLoadout.survivor.state & SurvivorState.ON_ASSIGNMENT))
            {
               dlgAway.addButton(lang.getString("srv_mission_cantrecycle_away_speedup"),true,{
                  "buttonClass":PurchasePushButton,
                  "width":100
               }).clicked.add(function(param1:MouseEvent):void
               {
                  var _loc2_:SpeedUpDialogue = new SpeedUpDialogue(Network.getInstance().playerData.missionList.getMissionById(equipper.missionId));
                  _loc2_.open();
               });
            }
            dlgAway.open();
         }
         else if(item.bought)
         {
            boughtMsg = new MessageBox(lang.getString("recycle_bought_msg",item.getName()),null,true);
            boughtMsg.addImage(item.getImageURI());
            boughtMsg.addTitle(lang.getString("recycle_bought_title"));
            boughtMsg.addButton(lang.getString("recycle_bought_ok")).clicked.addOnce(function(param1:MouseEvent):void
            {
               showRecycleDialogue();
            });
            boughtMsg.addButton(lang.getString("recycle_bought_cancel"));
            boughtMsg.open();
         }
         else if(item.qualityType == ItemQualityType.PREMIUM || ItemQualityType.isSpecial(item.qualityType))
         {
            uniqueMsg = new MessageBox(lang.getString("recycle_unique_msg",item.getName()),null,true);
            uniqueMsg.addImage(item.getImageURI());
            uniqueMsg.addTitle(lang.getString("recycle_unique_title"));
            uniqueMsg.addButton(lang.getString("recycle_unique_ok")).clicked.addOnce(function(param1:MouseEvent):void
            {
               showRecycleDialogue();
            });
            uniqueMsg.addButton(lang.getString("recycle_unique_cancel"));
            uniqueMsg.open();
         }
         else if(item is EffectItem && Network.getInstance().playerData.compound.effects.containsEffect(EffectItem(item).effect))
         {
            effectMsg = new MessageBox(lang.getString("effect_equipped_msg"),null,true);
            effectMsg.addImage(item.getImageURI());
            effectMsg.addTitle(lang.getString("effect_equipped_title"));
            effectMsg.addButton(lang.getString("effect_equipped_ok"));
            effectMsg.open();
         }
         else
         {
            showRecycleDialogue();
         }
      }
      
      private function onItemDisposeClicked() : void
      {
         var showDisposeDialogue:Function;
         var offLoadout:SurvivorLoadout;
         var listItem:UIInventoryListItem = null;
         var item:Item = null;
         var itemName:String = null;
         var currPage:int = 0;
         var lang:Language = null;
         var equipper:Survivor = null;
         var dlgAway:MessageBox = null;
         var boughtMsg:MessageBox = null;
         var uniqueMsg:MessageBox = null;
         var effectMsg:MessageBox = null;
         if(_selectedItem == null)
         {
            return;
         }
         listItem = UIInventoryListItem(_selectedItem);
         item = listItem.itemData;
         if(item == null)
         {
            return;
         }
         this.ui_itemControl.visible = false;
         itemName = item.getName();
         currPage = _currentPage;
         lang = Language.getInstance();
         showDisposeDialogue = function():void
         {
            var dlgDispose:MessageBox = new MessageBox(lang.getString("dispose_msg",itemName),"dispose-item");
            dlgDispose.addTitle(lang.getString("dispose_title",(item.quantity > 1 ? "1 x " : "") + itemName));
            dlgDispose.addImage(item.getImageURI());
            dlgDispose.addButton(lang.getString("dispose_cancel"));
            dlgDispose.addButton(lang.getString("dispose_ok"),true,{
               "icon":new Bitmap(new BmpIconButtonClose()),
               "iconBackgroundColor":7545099
            }).clicked.addOnce(function(param1:MouseEvent):void
            {
               var e:MouseEvent = param1;
               Network.getInstance().playerData.disposeItem(item,function(param1:Boolean):void
               {
                  var _loc2_:int = 0;
                  if(_disposed || !param1)
                  {
                     return;
                  }
                  if(item.quantity <= 0)
                  {
                     _loc2_ = int(_itemList.indexOf(item));
                     if(_loc2_ > -1)
                     {
                        _itemList.splice(_loc2_,1);
                     }
                     listItem.itemData = null;
                     createItems();
                  }
                  else
                  {
                     listItem.itemData = item;
                     positionItems();
                  }
                  gotoPage(currPage,false);
               });
            });
            dlgDispose.open();
         };
         offLoadout = Network.getInstance().playerData.loadoutManager.getItemOffensiveLoadout(item);
         if(offLoadout != null && offLoadout.survivor != null && (Boolean(offLoadout.survivor.state & SurvivorState.ON_MISSION) || Boolean(offLoadout.survivor.state & SurvivorState.ON_ASSIGNMENT)))
         {
            equipper = offLoadout.survivor;
            dlgAway = new MessageBox(lang.getString("srv_mission_cantdispose_away_msg",equipper.firstName));
            dlgAway.addTitle(lang.getString("srv_mission_cantdispose_away_title",equipper.firstName));
            dlgAway.addButton(lang.getString("srv_mission_cantdispose_away_ok"));
            if(!(offLoadout.survivor.state & SurvivorState.ON_ASSIGNMENT))
            {
               dlgAway.addButton(lang.getString("srv_mission_cantdispose_away_speedup"),true,{
                  "buttonClass":PurchasePushButton,
                  "width":100
               }).clicked.add(function(param1:MouseEvent):void
               {
                  var _loc2_:SpeedUpDialogue = new SpeedUpDialogue(Network.getInstance().playerData.missionList.getMissionById(equipper.missionId));
                  _loc2_.open();
               });
            }
            dlgAway.open();
         }
         else if(item.bought)
         {
            boughtMsg = new MessageBox(lang.getString("dispose_bought_msg",item.getName()),null,true);
            boughtMsg.addImage(item.getImageURI());
            boughtMsg.addTitle(lang.getString("dispose_bought_title"));
            boughtMsg.addButton(lang.getString("dispose_bought_ok")).clicked.addOnce(function(param1:MouseEvent):void
            {
               showDisposeDialogue();
            });
            boughtMsg.addButton(lang.getString("dispose_bought_cancel"));
            boughtMsg.open();
         }
         else if(item.category == "clothing" || item.qualityType == ItemQualityType.PREMIUM || ItemQualityType.isSpecial(item.qualityType))
         {
            uniqueMsg = new MessageBox(lang.getString("dispose_unique_msg",item.getName()),null,true);
            uniqueMsg.addImage(item.getImageURI());
            uniqueMsg.addTitle(lang.getString("dispose_unique_title"));
            uniqueMsg.addButton(lang.getString("dispose_unique_ok")).clicked.addOnce(function(param1:MouseEvent):void
            {
               showDisposeDialogue();
            });
            uniqueMsg.addButton(lang.getString("dispose_unique_cancel"));
            uniqueMsg.open();
         }
         else if(item is EffectItem && Network.getInstance().playerData.compound.effects.containsEffect(EffectItem(item).effect))
         {
            effectMsg = new MessageBox(lang.getString("effect_equipped_msg"),null,true);
            effectMsg.addImage(item.getImageURI());
            effectMsg.addTitle(lang.getString("effect_equipped_title"));
            effectMsg.addButton(lang.getString("effect_equipped_ok"));
            effectMsg.open();
         }
         else
         {
            showDisposeDialogue();
         }
      }
      
      private function onItemInspectClicked() : void
      {
         if(_selectedItem == null)
         {
            return;
         }
         var _loc1_:UIInventoryListItem = UIInventoryListItem(_selectedItem);
         var _loc2_:CrateItem = _loc1_.itemData as CrateItem;
         if(_loc2_ == null)
         {
            return;
         }
         this.ui_itemControl.visible = false;
         var _loc3_:CrateInspectionDialogue = new CrateInspectionDialogue(_loc2_);
         _loc3_.open();
      }
      
      private function onItemUnlockClicked() : void
      {
         var listItem:UIInventoryListItem = null;
         var dlgOpen:CrateMysteryUnlockDialogue = null;
         var schematic:SchematicItem = null;
         if(_selectedItem == null)
         {
            return;
         }
         listItem = UIInventoryListItem(_selectedItem);
         if(listItem.itemData is CrateMysteryItem)
         {
            dlgOpen = new CrateMysteryUnlockDialogue(listItem.itemData as CrateMysteryItem);
            dlgOpen.open();
         }
         else if(listItem.itemData is SchematicItem)
         {
            schematic = listItem.itemData as SchematicItem;
            if(schematic == null)
            {
               return;
            }
            schematic.unlock(function(param1:Boolean):void
            {
               if(!param1)
               {
                  return;
               }
               var _loc2_:int = int(_itemList.indexOf(listItem.itemData));
               if(_loc2_ > -1)
               {
                  _itemList.splice(_loc2_,1);
               }
               createItems();
            });
         }
      }
      
      public function get itemList() : Vector.<Item>
      {
         return this._itemList;
      }
      
      public function set itemList(param1:Vector.<Item>) : void
      {
         this._itemList = param1;
         if(this._options.showNoneItem)
         {
            this._itemList = this._itemList.concat();
            this._itemList.unshift(null);
         }
         this.createItems();
      }
      
      public function get options() : ItemListOptions
      {
         return this._options;
      }
   }
}

