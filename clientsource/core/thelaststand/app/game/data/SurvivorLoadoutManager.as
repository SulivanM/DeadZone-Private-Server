package thelaststand.app.game.data
{
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Settings;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.data.itemfilters.GearFilter;
   import thelaststand.app.game.data.itemfilters.ItemFilter;
   import thelaststand.app.game.data.itemfilters.WeaponsFilter;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.dialogues.ClothingPreviewDisplayOptions;
   import thelaststand.app.game.gui.dialogues.HowManyDialogue;
   import thelaststand.app.game.gui.dialogues.ItemListDialogue;
   import thelaststand.app.game.gui.dialogues.ItemListOptions;
   import thelaststand.app.game.gui.dialogues.SpeedUpDialogue;
   import thelaststand.app.game.gui.inventory.UIInventoryFilter;
   import thelaststand.app.game.gui.inventory.UIInventoryGearFilter;
   import thelaststand.app.game.gui.inventory.UIInventoryWeaponFilter;
   import thelaststand.app.game.gui.survivor.UISurvivorItemListHeader;
   import thelaststand.app.gui.CheckBox;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DictionaryUtils;
   import thelaststand.common.lang.Language;
   
   public class SurvivorLoadoutManager
   {
      
      private var _survivors:Vector.<Survivor>;
      
      private var _defensiveLoadouts:Dictionary;
      
      private var _offensiveLoadouts:Dictionary;
      
      private var _offensiveItems:Dictionary;
      
      private var _defensiveItems:Dictionary;
      
      private var _clothingItems:Dictionary;
      
      public function SurvivorLoadoutManager()
      {
         super();
         this._survivors = new Vector.<Survivor>();
         this._defensiveLoadouts = new Dictionary(true);
         this._offensiveLoadouts = new Dictionary(true);
         this._offensiveItems = new Dictionary(true);
         this._defensiveItems = new Dictionary(true);
         this._clothingItems = new Dictionary(true);
      }
      
      public function addSurvivor(param1:Survivor) : void
      {
         var _loc3_:SurvivorLoadout = null;
         var _loc4_:SurvivorLoadout = null;
         this._survivors.push(param1);
         param1.accessoriesChanged.add(this.onClothingChanged);
         var _loc2_:String = param1.id.toUpperCase();
         if(this._offensiveLoadouts[_loc2_] == null)
         {
            _loc3_ = this._offensiveLoadouts[_loc2_] = param1.loadoutOffence;
            _loc3_.itemAdded.add(this.onItemAdded);
            _loc3_.itemRemoved.add(this.onItemRemoved);
         }
         if(this._defensiveLoadouts[_loc2_] == null)
         {
            _loc4_ = this._defensiveLoadouts[_loc2_] = param1.loadoutDefence;
            _loc4_.itemAdded.add(this.onItemAdded);
            _loc4_.itemRemoved.add(this.onItemRemoved);
         }
      }
      
      public function isEquippedToOffence(param1:Item) : Boolean
      {
         return this._offensiveItems[param1] != null;
      }
      
      public function isEquippedToDefence(param1:Item) : Boolean
      {
         return this._defensiveItems[param1] != null;
      }
      
      public function isEquippedClothing(param1:ClothingAccessory) : Boolean
      {
         return this._clothingItems[param1] != null;
      }
      
      public function getItemOffensiveLoadout(param1:Item) : SurvivorLoadout
      {
         return this._offensiveItems[param1] as SurvivorLoadout;
      }
      
      public function getItemDefensiveLoadout(param1:Item) : SurvivorLoadout
      {
         return this._defensiveItems[param1] as SurvivorLoadout;
      }
      
      public function getItemClothingSurvivor(param1:ClothingAccessory) : Survivor
      {
         return this._clothingItems[param1] as Survivor;
      }
      
      public function getAvailableQuantity(param1:Item, param2:Survivor = null, param3:String = null) : int
      {
         var _loc6_:SurvivorLoadout = null;
         var _loc4_:int = int(param1.quantity);
         var _loc5_:int = 0;
         for each(_loc6_ in this._offensiveLoadouts)
         {
            if(!(param3 == _loc6_.type && param2 == _loc6_.survivor))
            {
               _loc5_ += _loc6_.getQuantityEquipped(param1);
            }
         }
         for each(_loc6_ in this._defensiveLoadouts)
         {
            if(!(param3 == _loc6_.type && param2 == _loc6_.survivor))
            {
               _loc5_ += _loc6_.getQuantityEquipped(param1);
            }
         }
         return int(_loc4_ - _loc5_);
      }
      
      public function getCompoundAvailableQuantity(param1:Item) : int
      {
         var _loc4_:SurvivorLoadout = null;
         var _loc2_:int = int(param1.quantity);
         var _loc3_:int = 0;
         if(_loc2_ > 30)
         {
         }
         for each(_loc4_ in this._offensiveLoadouts)
         {
            if(_loc4_.survivor.state & SurvivorState.ON_MISSION || _loc4_.survivor.state & SurvivorState.ON_ASSIGNMENT)
            {
               _loc3_ += _loc4_.getQuantityEquipped(param1);
            }
         }
         return int(_loc2_ - _loc3_);
      }
      
      public function getQuantityEquipped(param1:Item, param2:String = null) : int
      {
         var _loc4_:SurvivorLoadout = null;
         var _loc3_:int = 0;
         if(param2 == null || param2 == SurvivorLoadout.TYPE_OFFENCE)
         {
            for each(_loc4_ in this._offensiveLoadouts)
            {
               _loc3_ += _loc4_.getQuantityEquipped(param1);
            }
         }
         if(param2 == null || param2 == SurvivorLoadout.TYPE_DEFENCE)
         {
            for each(_loc4_ in this._defensiveLoadouts)
            {
               _loc3_ += _loc4_.getQuantityEquipped(param1);
            }
         }
         return _loc3_;
      }
      
      public function openAccessoryEquipDialog(param1:Survivor, param2:int) : void
      {
         var lang:Language;
         var equippedItem:Item;
         var itemList:Vector.<Item>;
         var options:ItemListOptions;
         var strTitle:String;
         var clothingFlags:uint;
         var i:int = 0;
         var clothing:ClothingAccessory = null;
         var attireFlags:uint = 0;
         var dlgEquip:ItemListDialogue = null;
         var item:Item = null;
         var invClothing:ClothingAccessory = null;
         var flags:uint = 0;
         var equippable:Boolean = false;
         var survivor:Survivor = param1;
         var slot:int = param2;
         if(survivor == null || slot < 0 || slot >= survivor.accessories.length)
         {
            return;
         }
         lang = Language.getInstance();
         if(Boolean(survivor.state & SurvivorState.ON_MISSION) || Boolean(survivor.state & SurvivorState.REASSIGNING) || Boolean(survivor.state & SurvivorState.ON_ASSIGNMENT))
         {
            this.handleEquipSurvivorBusy(survivor);
            return;
         }
         if(slot == 2)
         {
            attireFlags = AttireFlags.UPPER_BODY;
         }
         else if(slot == 3)
         {
            attireFlags = AttireFlags.LOWER_BODY;
         }
         else
         {
            attireFlags = AttireFlags.ACCESSORIES;
         }
         equippedItem = survivor.accessories[slot];
         itemList = Network.getInstance().playerData.inventory.getItemsOfCategoryWhere("clothing",function(param1:Item):Boolean
         {
            var _loc2_:* = param1 as ClothingAccessory;
            if(_loc2_ == null)
            {
               return false;
            }
            return (_loc2_.getAttireFlags(survivor.gender) & attireFlags) != 0;
         });
         options = new ItemListOptions();
         options.clothingPreviews = ClothingPreviewDisplayOptions.DISABLED;
         options.showNoneItem = true;
         options.loadout = survivor.loadoutOffence;
         options.header = new UISurvivorItemListHeader(survivor);
         strTitle = lang.getString("select_clothing");
         dlgEquip = new ItemListDialogue(strTitle,itemList,options);
         dlgEquip.selectItem(survivor.accessories[slot]);
         dlgEquip.selected.add(function(param1:ClothingAccessory):void
         {
            Network.getInstance().playerData.loadoutManager.equipClothingAccessory(survivor,slot,param1,dlgEquip.close);
            dlgEquip.selectItem(survivor.accessories[slot],false);
            Audio.sound.play("sound/interface/int-click-weapon.mp3");
         });
         dlgEquip.open();
         clothingFlags = 0;
         i = 0;
         while(i < survivor.maxClothingAccessories)
         {
            if(i != slot)
            {
               clothing = survivor.accessories[i];
               if(clothing != null)
               {
                  clothingFlags |= clothing.getAttireFlags(survivor.gender);
               }
            }
            i++;
         }
         clothingFlags &= ~AttireFlags.NO_HAIR;
         clothingFlags &= ~AttireFlags.NO_FACIAL_HAIR;
         for each(item in itemList)
         {
            if(!dlgEquip.list.getItemById(item.id).unequippable)
            {
               invClothing = ClothingAccessory(item);
               if(invClothing != null)
               {
                  flags = invClothing.getAttireFlags(survivor.gender);
                  flags &= ~AttireFlags.NO_HAIR;
                  flags &= ~AttireFlags.NO_FACIAL_HAIR;
                  equippable = invClothing != equippedItem && (clothingFlags & flags) == 0;
                  if(equippable)
                  {
                  }
                  if(!equippable)
                  {
                     dlgEquip.list.setEnabledStateByItemId(invClothing.id,false);
                     dlgEquip.list.setItemTint(invClothing.id,4276545);
                  }
               }
            }
         }
         Audio.sound.play("sound/interface/int-click-weapon-slot.mp3");
      }
      
      public function openEquipDialogue(param1:SurvivorLoadoutData) : void
      {
         var lang:Language;
         var survivor:Survivor;
         var i:int;
         var loadout:SurvivorLoadout = null;
         var strTitle:String = null;
         var itemList:Vector.<Item> = null;
         var options:ItemListOptions = null;
         var dlgEquip:ItemListDialogue = null;
         var item:Item = null;
         var loadoutData:SurvivorLoadoutData = param1;
         if(loadoutData == null || loadoutData.loadout == null)
         {
            return;
         }
         lang = Language.getInstance();
         loadout = loadoutData.loadout;
         survivor = loadout.survivor;
         if(Boolean(survivor.state & SurvivorState.ON_MISSION) || Boolean(survivor.state & SurvivorState.REASSIGNING) || Boolean(survivor.state & SurvivorState.ON_ASSIGNMENT))
         {
            this.handleEquipSurvivorBusy(survivor);
            return;
         }
         switch(loadoutData.type)
         {
            case SurvivorLoadout.SLOT_WEAPON:
               strTitle = lang.getString("select_weapon_title_" + loadout.type);
               itemList = Network.getInstance().playerData.inventory.getItemsOfCategory("weapon");
               break;
            case SurvivorLoadout.SLOT_GEAR_PASSIVE:
               strTitle = lang.getString("select_gear_passive_title_" + loadout.type);
               itemList = Network.getInstance().playerData.inventory.getGear(GearType.PASSIVE);
               break;
            case SurvivorLoadout.SLOT_GEAR_ACTIVE:
               strTitle = lang.getString("select_gear_active_title_" + loadout.type);
               itemList = Network.getInstance().playerData.inventory.getGear(GearType.ACTIVE);
         }
         i = int(itemList.length - 1);
         while(i >= 0)
         {
            item = itemList[i];
            if(item.quantifiable)
            {
               if(Network.getInstance().playerData.loadoutManager.getAvailableQuantity(item,survivor,loadout.type) <= 0)
               {
                  itemList.splice(i,1);
               }
            }
            i--;
         }
         options = new ItemListOptions();
         options.clothingPreviews = ClothingPreviewDisplayOptions.DISABLED;
         options.showNoneItem = true;
         options.loadout = loadout;
         options.levelAdjustment = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("WeaponGearLevelLimit"));
         options.showActiveGearQuantities = true;
         options.header = new UISurvivorItemListHeader(survivor);
         options.columns = 7;
         options.rows = 4;
         options.itemSpacing = 12;
         options.filter = loadoutData.type == SurvivorLoadout.SLOT_WEAPON ? new WeaponsFilter() : new GearFilter();
         options.ui_filter = loadoutData.type == SurvivorLoadout.SLOT_WEAPON ? new UIInventoryWeaponFilter() : new UIInventoryGearFilter();
         if("loadout" in options.filter.data)
         {
            options.filter.data["loadout"] = loadout;
         }
         dlgEquip = new ItemListDialogue(strTitle,itemList,options);
         dlgEquip.selectItem(loadoutData.item);
         dlgEquip.selected.add(function(param1:Item):void
         {
            Network.getInstance().playerData.loadoutManager.equipItem(loadout,loadoutData.type,param1,options.levelAdjustment,dlgEquip.close);
            dlgEquip.selectItem(loadoutData.item,false);
            Audio.sound.play("sound/interface/int-click-weapon.mp3");
         });
         dlgEquip.open();
         Audio.sound.play("sound/interface/int-click-weapon-slot.mp3");
      }
      
      public function equipClothingAccessory(param1:Survivor, param2:int, param3:ClothingAccessory, param4:Function = null) : void
      {
         var equip:Function;
         var equipper:Survivor = null;
         var dlgConfirm:MessageBox = null;
         var survivor:Survivor = param1;
         var slot:int = param2;
         var item:ClothingAccessory = param3;
         var onEquipped:Function = param4;
         var lang:Language = Language.getInstance();
         if(item == null)
         {
            survivor.setAccessory(slot,null);
            onEquipped();
            return;
         }
         if(!item.supportsSurvivorClass(survivor.classId))
         {
            return;
         }
         equip = function():void
         {
            survivor.setAccessory(slot,item);
            if(onEquipped != null)
            {
               onEquipped.apply();
            }
         };
         equipper = this._clothingItems[item] as Survivor;
         if(equipper != null)
         {
            if(Boolean(equipper.state & SurvivorState.ON_MISSION) || Boolean(equipper.state & SurvivorState.ON_ASSIGNMENT))
            {
               this.handleEquipSurvivorBusy(equipper);
               return;
            }
            dlgConfirm = new MessageBox(lang.getString("already_equipped_message",equipper.fullName));
            dlgConfirm.addTitle(lang.getString("already_equipped_title",item.getName()));
            dlgConfirm.addButton(lang.getString("already_equipped_ok")).clicked.addOnce(function(param1:MouseEvent):void
            {
               equipper.removeAccessory(item);
               equipper.updatePortrait();
               equip();
            });
            dlgConfirm.addButton(lang.getString("already_equipped_cancel"));
            dlgConfirm.open();
         }
         else
         {
            equip();
         }
      }
      
      public function equipItem(param1:SurvivorLoadout, param2:String, param3:Item, param4:int = 0, param5:Function = null) : void
      {
         var msg:MessageBox = null;
         var loadout:SurvivorLoadout = param1;
         var slot:String = param2;
         var item:Item = param3;
         var levelLimitMod:int = param4;
         var onEquipped:Function = param5;
         if(item != null && item.isBindOnEquip)
         {
            msg = new MessageBox(Language.getInstance().getString("bindonequip_msg"),null,true);
            msg.addTitle(Language.getInstance().getString("bindonequip_title",BaseDialogue.TITLE_COLOR_RUST));
            msg.addButton(Language.getInstance().getString("bindonequip_ok")).clicked.addOnce(function(param1:MouseEvent):void
            {
               doEquip(loadout,slot,item,levelLimitMod,onEquipped);
            });
            msg.addButton(Language.getInstance().getString("bindonequip_cancel"));
            msg.open();
         }
         else
         {
            this.doEquip(loadout,slot,item,levelLimitMod,onEquipped);
         }
      }
      
      private function doEquip(param1:SurvivorLoadout, param2:String, param3:Item, param4:int = 0, param5:Function = null) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(param1.type == SurvivorLoadout.TYPE_DEFENCE)
         {
            this.equipDefensiveItem(param1.survivor,param2,param3,param4,param5);
         }
         else
         {
            this.equipOffensiveItem(param1.survivor,param2,param3,param4,param5);
         }
      }
      
      private function equipDefensiveItem(param1:Survivor, param2:String, param3:Item, param4:int = 0, param5:Function = null) : void
      {
         var gear:Gear;
         var weapon:Weapon;
         var equip:Function;
         var currentOffenceLoadout:SurvivorLoadout;
         var currentDefenceLoadout:SurvivorLoadout;
         var equipper:Survivor = null;
         var max:int = 0;
         var dlgQuantity:HowManyDialogue = null;
         var dlgAway:MessageBox = null;
         var dlgConfirm:MessageBox = null;
         var survivor:Survivor = param1;
         var slot:String = param2;
         var item:Item = param3;
         var levelLimitMod:int = param4;
         var onEquipped:Function = param5;
         var lang:Language = Language.getInstance();
         if(item == null)
         {
            survivor.loadoutDefence[slot].item = null;
            onEquipped();
            return;
         }
         if(item.level > survivor.level - levelLimitMod)
         {
            return;
         }
         gear = item as Gear;
         if(gear != null && !gear.supportsSurvivorClass(survivor.classId))
         {
            return;
         }
         weapon = item as Weapon;
         if(weapon != null && !weapon.supportsSurvivorClass(survivor.classId))
         {
            return;
         }
         equip = function(param1:SurvivorLoadout, param2:int = 1):void
         {
            if(param2 == 0)
            {
               return;
            }
            param1[slot].item = item;
            param1[slot].quantity = param2;
            if(onEquipped != null)
            {
               onEquipped.apply();
            }
         };
         if(item.quantifiable)
         {
            max = Math.min(this.getAvailableQuantity(item,survivor,SurvivorLoadout.TYPE_DEFENCE),survivor.loadoutDefence.getCarryLimit(item));
            if(max > 1)
            {
               dlgQuantity = new HowManyDialogue(lang.getString("srv_equip_quantity_title",item.getName()),lang.getString("srv_equip_quantity_msg"),max);
               dlgQuantity.amountSelected.addOnce(function(param1:int):void
               {
                  if(param1 == 0 || param1 > max)
                  {
                     return;
                  }
                  equip(survivor.loadoutDefence,param1);
               });
               dlgQuantity.open();
            }
            else
            {
               equip(survivor.loadoutDefence,max);
            }
            return;
         }
         currentOffenceLoadout = this.getItemOffensiveLoadout(item);
         currentDefenceLoadout = this.getItemDefensiveLoadout(item);
         if(currentOffenceLoadout != null && currentOffenceLoadout.survivor != survivor)
         {
            equipper = currentOffenceLoadout.survivor;
            if(Boolean(equipper.state & SurvivorState.ON_MISSION) || Boolean(equipper.state & SurvivorState.ON_ASSIGNMENT))
            {
               dlgAway = new MessageBox(lang.getString("defence_equipped_away_msg",equipper.firstName));
               dlgAway.addTitle(lang.getString("defence_equipped_away_title",equipper.firstName));
               dlgAway.addButton(lang.getString("defence_equipped_away_ok"),true,{"width":80});
               if(!(equipper.state & SurvivorState.ON_ASSIGNMENT))
               {
                  dlgAway.addButton(lang.getString("defence_equipped_away_speedup"),true,{
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
         }
         if(currentDefenceLoadout != null && currentDefenceLoadout.survivor != survivor)
         {
            equipper = currentDefenceLoadout.survivor;
            dlgConfirm = new MessageBox(lang.getString("already_equipped_message",equipper.fullName));
            dlgConfirm.addTitle(lang.getString("already_equipped_title",item.getName()));
            dlgConfirm.addButton(lang.getString("already_equipped_ok")).clicked.addOnce(function(param1:MouseEvent):void
            {
               equip(survivor.loadoutDefence);
            });
            dlgConfirm.addButton(lang.getString("already_equipped_cancel"));
            dlgConfirm.open();
         }
         else
         {
            equip(survivor.loadoutDefence);
         }
      }
      
      private function equipOffensiveItem(param1:Survivor, param2:String, param3:Item, param4:int = 0, param5:Function = null) : void
      {
         var gear:Gear;
         var equip:Function;
         var currentOffenceLoadout:SurvivorLoadout;
         var currentDefenceLoadout:SurvivorLoadout;
         var equipper:Survivor = null;
         var dlgConfirm:MessageBox = null;
         var max:int = 0;
         var dlgQuantity:HowManyDialogue = null;
         var dlgAway:MessageBox = null;
         var survivor:Survivor = param1;
         var slot:String = param2;
         var item:Item = param3;
         var levelLimitMod:int = param4;
         var onEquipped:Function = param5;
         var lang:Language = Language.getInstance();
         if(item == null)
         {
            survivor.loadoutOffence[slot].item = null;
            onEquipped();
            return;
         }
         if(item.level > survivor.level - levelLimitMod)
         {
            return;
         }
         gear = item as Gear;
         if(gear != null && !gear.supportsSurvivorClass(survivor.classId))
         {
            return;
         }
         equip = function(param1:SurvivorLoadout, param2:int = 1):void
         {
            if(param2 == 0)
            {
               return;
            }
            param1[slot].item = item;
            param1[slot].quantity = param2;
            if(onEquipped != null)
            {
               onEquipped();
            }
         };
         if(item.quantifiable)
         {
            max = Math.min(this.getAvailableQuantity(item,survivor,SurvivorLoadout.TYPE_OFFENCE),survivor.loadoutOffence.getCarryLimit(item));
            if(max > 1)
            {
               dlgQuantity = new HowManyDialogue(lang.getString("srv_equip_quantity_title",item.getName()),lang.getString("srv_equip_quantity_msg"),max);
               dlgQuantity.amountSelected.addOnce(function(param1:int):void
               {
                  if(param1 == 0 || param1 > max)
                  {
                     return;
                  }
                  equip(survivor.loadoutOffence,param1);
               });
               dlgQuantity.open();
            }
            else
            {
               equip(survivor.loadoutOffence,max);
            }
            return;
         }
         currentOffenceLoadout = this.getItemOffensiveLoadout(item);
         currentDefenceLoadout = this.getItemDefensiveLoadout(item);
         if(currentOffenceLoadout != null && currentOffenceLoadout.survivor != survivor)
         {
            equipper = currentOffenceLoadout.survivor;
            if(Boolean(equipper.state & SurvivorState.ON_MISSION) || Boolean(equipper.state & SurvivorState.ON_ASSIGNMENT))
            {
               dlgAway = new MessageBox(lang.getString("srv_mission_cantequip_away_msg",equipper.firstName));
               dlgAway.addTitle(lang.getString("srv_mission_cantequip_away_title",equipper.firstName));
               dlgAway.addButton(lang.getString("srv_mission_cantequip_away_ok"));
               if(!(equipper.state & SurvivorState.ON_ASSIGNMENT))
               {
                  dlgAway.addButton(lang.getString("srv_mission_cantequip_away_speedup"),true,{
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
            dlgConfirm = new MessageBox(lang.getString("already_equipped_message",equipper.fullName));
            dlgConfirm.addTitle(lang.getString("already_equipped_title",item.getName()));
            dlgConfirm.addButton(lang.getString("already_equipped_ok")).clicked.addOnce(function(param1:MouseEvent):void
            {
               equip(survivor.loadoutOffence);
            });
            dlgConfirm.addButton(lang.getString("already_equipped_cancel"));
            dlgConfirm.open();
         }
         else if(currentDefenceLoadout != null && currentDefenceLoadout.survivor != survivor)
         {
            if(Settings.getInstance().session_dontAskDefenceEquipped)
            {
               equip(survivor.loadoutOffence);
            }
            else
            {
               equipper = currentDefenceLoadout.survivor;
               dlgConfirm = new MessageBox(lang.getString("defence_equipped_message",equipper.fullName));
               dlgConfirm.addTitle(lang.getString("defence_equipped_title",item.getName()));
               dlgConfirm.addButton(lang.getString("defence_equipped_ok")).clicked.addOnce(function(param1:MouseEvent):void
               {
                  equip(survivor.loadoutOffence);
               });
               dlgConfirm.addButton(lang.getString("defence_equipped_cancel"));
               dlgConfirm.addCheckbox(lang.getString("defence_equipped_dontask")).changed.add(function(param1:CheckBox):void
               {
                  Settings.getInstance().session_dontAskDefenceEquipped = param1.selected;
               });
               dlgConfirm.open();
            }
         }
         else
         {
            equip(survivor.loadoutOffence);
         }
      }
      
      public function getOffensiveLoadout(param1:Survivor) : SurvivorLoadout
      {
         return this._offensiveLoadouts[param1.id];
      }
      
      public function getDefensiveLoadout(param1:Survivor) : SurvivorLoadout
      {
         return this._defensiveLoadouts[param1.id];
      }
      
      public function checkItemUsability(param1:Item) : void
      {
         var _loc2_:SurvivorLoadout = this._offensiveItems[param1];
         if(_loc2_ != null)
         {
            if(param1.level > _loc2_.survivor.level)
            {
               _loc2_.removeItem(param1);
            }
         }
         var _loc3_:SurvivorLoadout = this._defensiveItems[param1];
         if(_loc3_ != null)
         {
            if(param1.level > _loc3_.survivor.level)
            {
               _loc3_.removeItem(param1);
            }
         }
      }
      
      public function getOrderedLoadout(param1:String, param2:Function) : Vector.<SurvivorLoadout>
      {
         var _loc3_:Dictionary = null;
         var _loc5_:SurvivorLoadout = null;
         if(param1 == SurvivorLoadout.TYPE_OFFENCE)
         {
            _loc3_ = this._offensiveLoadouts;
         }
         else if(param1 == SurvivorLoadout.TYPE_DEFENCE)
         {
            _loc3_ = this._defensiveLoadouts;
         }
         var _loc4_:Vector.<SurvivorLoadout> = new Vector.<SurvivorLoadout>();
         for each(_loc5_ in _loc3_)
         {
            _loc4_.push(_loc5_);
         }
         if(param2 != null)
         {
            _loc4_.sort(param2);
         }
         return _loc4_;
      }
      
      public function checkAllUsability(param1:String, param2:int = 0) : Boolean
      {
         var changed:Boolean;
         var activeGearLookupDict:Dictionary;
         var i:int;
         var a:SurvivorLoadout = null;
         var b:SurvivorLoadout = null;
         var loadout:SurvivorLoadout = null;
         var loadoutType:String = param1;
         var levelLimitMod:int = param2;
         var list:Vector.<SurvivorLoadout> = this.getOrderedLoadout(loadoutType,function(param1:SurvivorLoadout, param2:SurvivorLoadout):int
         {
            var _loc3_:* = param1.survivor.state & SurvivorState.ON_MISSION != 0 || param1.survivor.state & SurvivorState.ON_ASSIGNMENT != 0;
            var _loc4_:* = param2.survivor.state & SurvivorState.ON_MISSION != 0 || param2.survivor.state & SurvivorState.ON_ASSIGNMENT != 0;
            if(_loc3_ && !_loc4_)
            {
               return -1;
            }
            if(!_loc3_ && _loc4_)
            {
               return 1;
            }
            return 0;
         });
         if(list == null || list.length == 0)
         {
            return false;
         }
         changed = false;
         activeGearLookupDict = new Dictionary();
         i = 0;
         while(i < list.length)
         {
            loadout = list[i];
            if((loadout.survivor.state & SurvivorState.ON_ASSIGNMENT) == 0)
            {
               if(loadout.removeUnusableItems(activeGearLookupDict,levelLimitMod))
               {
                  changed = true;
               }
            }
            i++;
         }
         return changed;
      }
      
      public function removeItem(param1:Item) : void
      {
         var _loc2_:SurvivorLoadout = null;
         var _loc3_:Survivor = null;
         for each(_loc2_ in this._offensiveLoadouts)
         {
            _loc2_.removeItem(param1);
         }
         for each(_loc2_ in this._defensiveLoadouts)
         {
            _loc2_.removeItem(param1);
         }
         delete this._offensiveItems[param1];
         delete this._defensiveItems[param1];
         if(param1 is ClothingAccessory)
         {
            _loc3_ = this._clothingItems[param1] as Survivor;
            if(_loc3_ != null)
            {
               _loc3_.removeAccessory(ClothingAccessory(param1));
            }
         }
      }
      
      public function parseLoadout(param1:String, param2:Object, param3:Inventory) : void
      {
         var _loc4_:Dictionary = null;
         var _loc5_:Dictionary = null;
         var _loc6_:String = null;
         var _loc7_:Object = null;
         var _loc8_:SurvivorLoadout = null;
         if(param1 == SurvivorLoadout.TYPE_OFFENCE)
         {
            _loc5_ = this._offensiveLoadouts;
            _loc4_ = this._offensiveItems;
         }
         else if(param1 == SurvivorLoadout.TYPE_DEFENCE)
         {
            _loc5_ = this._defensiveLoadouts;
            _loc4_ = this._defensiveItems;
         }
         for(_loc6_ in param2)
         {
            _loc7_ = param2[_loc6_];
            if(_loc7_ != null)
            {
               _loc6_ = _loc6_.toUpperCase();
               _loc8_ = _loc5_[_loc6_];
               if(_loc8_ != null)
               {
                  if(_loc7_.weapon != null)
                  {
                     _loc8_.weapon.item = param3.getItemById(_loc7_.weapon) as Weapon;
                  }
                  if(_loc7_.gear1 != null)
                  {
                     _loc8_.gearPassive.item = param3.getItemById(_loc7_.gear1) as Gear;
                  }
                  if(_loc7_.gear2 != null)
                  {
                     _loc8_.gearActive.item = param3.getItemById(_loc7_.gear2) as Gear;
                     _loc8_.gearActive.quantity = "gear2_qty" in _loc7_ ? int(_loc7_.gear2_qty) : 0;
                  }
               }
            }
         }
      }
      
      private function getSurvivorById(param1:String) : Survivor
      {
         var _loc2_:Survivor = null;
         param1 = param1.toUpperCase();
         for each(_loc2_ in this._survivors)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function parseClothingAccessories(param1:Array, param2:Inventory) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Survivor = null;
         var _loc6_:* = undefined;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc9_:ClothingAccessory = null;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = param1[_loc3_];
            if(_loc4_ != null)
            {
               _loc5_ = this.getSurvivorById(_loc4_.id);
               if(!(_loc5_ == null || !_loc4_.accessories))
               {
                  for(_loc6_ in _loc4_.accessories)
                  {
                     _loc7_ = int(_loc6_);
                     if(!(_loc7_ < 0 || _loc7_ >= _loc5_.maxClothingAccessories))
                     {
                        _loc8_ = _loc4_.accessories[_loc6_];
                        _loc9_ = param2.getItemById(_loc8_) as ClothingAccessory;
                        if(_loc9_ != null)
                        {
                           _loc5_.accessories[_loc7_] = _loc9_;
                           _loc5_.appearance.invalidate();
                           this._clothingItems[_loc9_] = _loc5_;
                        }
                     }
                  }
               }
            }
            _loc3_++;
         }
      }
      
      private function handleEquipSurvivorBusy(param1:Survivor) : void
      {
         var survivor:Survivor = param1;
         var lang:Language = Language.getInstance();
         var langId:String = Boolean(survivor.state & SurvivorState.ON_MISSION) || Boolean(survivor.state & SurvivorState.ON_ASSIGNMENT) ? "srv_mission_" : "srv_reassign_";
         var dlgAway:MessageBox = new MessageBox(lang.getString(langId + "cantequip_away_msg",survivor.firstName));
         dlgAway.addTitle(lang.getString(langId + "cantequip_away_title",survivor.firstName));
         dlgAway.addButton(lang.getString(langId + "cantequip_away_ok"));
         if(!(survivor.state & SurvivorState.ON_ASSIGNMENT))
         {
            dlgAway.addButton(lang.getString(langId + "cantequip_away_speedup"),true,{"backgroundColor":4226049}).clicked.add(function(param1:MouseEvent):void
            {
               var _loc2_:* = undefined;
               var _loc3_:SpeedUpDialogue = null;
               if(survivor.state & SurvivorState.ON_MISSION)
               {
                  _loc2_ = Network.getInstance().playerData.missionList.getMissionById(survivor.missionId);
               }
               else if(survivor.state & SurvivorState.REASSIGNING)
               {
                  _loc2_ = survivor;
               }
               if(_loc2_ != null)
               {
                  _loc3_ = new SpeedUpDialogue(_loc2_);
                  _loc3_.open();
               }
            });
         }
         dlgAway.open();
      }
      
      private function onItemAdded(param1:SurvivorLoadout, param2:SurvivorLoadoutData, param3:Item) : void
      {
         var _loc4_:Dictionary = null;
         var _loc5_:Dictionary = null;
         var _loc6_:SurvivorLoadout = null;
         if(param1.type == SurvivorLoadout.TYPE_OFFENCE)
         {
            _loc5_ = this._offensiveLoadouts;
            _loc4_ = this._offensiveItems;
         }
         else if(param1.type == SurvivorLoadout.TYPE_DEFENCE)
         {
            _loc5_ = this._defensiveLoadouts;
            _loc4_ = this._defensiveItems;
         }
         if(param3 != null)
         {
            if(!param3.quantifiable || this.getQuantityEquipped(param3,param1.type) == 0)
            {
               delete _loc4_[param3];
            }
         }
         if(param2.item != null && !param2.item.quantifiable && _loc5_ != null)
         {
            for each(_loc6_ in _loc5_)
            {
               if(_loc6_ != param1)
               {
                  _loc6_.removeItem(param2.item);
               }
            }
         }
         _loc4_[param2.item] = param1;
      }
      
      private function onItemRemoved(param1:SurvivorLoadout, param2:SurvivorLoadoutData, param3:Item) : void
      {
         var _loc4_:Dictionary = null;
         if(param1.type == SurvivorLoadout.TYPE_OFFENCE)
         {
            _loc4_ = this._offensiveItems;
         }
         else if(param1.type == SurvivorLoadout.TYPE_DEFENCE)
         {
            _loc4_ = this._defensiveItems;
         }
         delete _loc4_[param3];
      }
      
      private function onClothingChanged(param1:Survivor) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:ClothingAccessory = null;
         DictionaryUtils.clear(this._clothingItems);
         for each(param1 in this._survivors)
         {
            _loc2_ = 0;
            _loc3_ = param1.maxClothingAccessories;
            while(_loc2_ < _loc3_)
            {
               _loc4_ = param1.getAccessory(_loc2_);
               if(_loc4_ != null)
               {
                  this._clothingItems[_loc4_] = param1;
               }
               _loc2_++;
            }
         }
      }
   }
}

