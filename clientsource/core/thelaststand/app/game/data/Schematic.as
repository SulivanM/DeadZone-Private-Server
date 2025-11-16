package thelaststand.app.game.data
{
   import com.deadreckoned.threshold.display.Color;
   import flash.utils.Dictionary;
   import playerio.PlayerIOError;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.data.skills.SkillState;
   import thelaststand.app.game.gui.dialogues.AutoProgressBarDialogue;
   import thelaststand.app.game.gui.dialogues.InventoryFullDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class Schematic
   {
      
      private var _id:String;
      
      private var _inputItemTypes:Vector.<String>;
      
      private var _outputItem:Item;
      
      private var _new:Boolean;
      
      private var _category:String;
      
      private var _xml:XML;
      
      private var _startDate:Date;
      
      private var _expiryDate:Date;
      
      private var _minLevel:int = 0;
      
      private var _maxLevel:int = 2147483647;
      
      public function Schematic(param1:String)
      {
         var inputNode:XML = null;
         var node:XML = null;
         var id:String = param1;
         super();
         this._id = id;
         this._xml = ResourceManager.getInstance().getResource("xml/crafting.xml").content..schem.(@id == _id)[0];
         if(!this._xml)
         {
            Network.getInstance().client.errorLog.writeError("Schematic definition does not exist",this._id,null,null,null,null);
            return;
         }
         this._category = this._xml.@type.toString();
         this._inputItemTypes = new Vector.<String>();
         for each(inputNode in this._xml.input.itm)
         {
            this._inputItemTypes.push(inputNode.@id.toString());
         }
         this._outputItem = ItemFactory.createItemFromXML(this._xml.itm[0]);
         for each(node in this._xml.limit.children())
         {
            switch(node.localName())
            {
               case "start":
                  this._startDate = new Date(node.toString().replace(/-/ig,"/"));
                  this._startDate.minutes -= this._startDate.timezoneOffset;
                  break;
               case "end":
                  this._expiryDate = new Date(node.toString().replace(/-/ig,"/"));
                  this._expiryDate.minutes -= this._expiryDate.timezoneOffset;
                  break;
               case "lvl_min":
                  this._minLevel = int(node.toString());
                  break;
               case "lvl_max":
                  this._maxLevel = int(node.toString());
            }
         }
      }
      
      public static function getBaseSchematics(param1:String, param2:int) : Vector.<String>
      {
         var _loc5_:XML = null;
         var _loc6_:int = 0;
         var _loc3_:Vector.<String> = new Vector.<String>();
         var _loc4_:XMLList = ResourceManager.getInstance().getResource("xml/crafting.xml").content.schem;
         for each(_loc5_ in _loc4_)
         {
            if(!(_loc5_.@type.toString() != param1 || !_loc5_.hasOwnProperty("@base_lvl")))
            {
               _loc6_ = int(_loc5_.@base_lvl.toString());
               if(_loc6_ == param2)
               {
                  _loc3_.push(_loc5_.@id.toString());
               }
            }
         }
         return _loc3_;
      }
      
      public static function getLimitedCountByType() : Dictionary
      {
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc1_:Dictionary = new Dictionary(true);
         var _loc2_:XMLList = ResourceManager.getInstance().getResource("xml/crafting.xml").content.limited.schem;
         if(_loc2_.length() == 0)
         {
            return _loc1_;
         }
         for each(_loc3_ in _loc2_)
         {
            if(meetsLimitConstraints(_loc3_.@id.toString()))
            {
               _loc4_ = _loc3_.@type.toString();
               _loc5_ = int(_loc1_[_loc4_]);
               _loc1_[_loc4_] = _loc5_ + 1;
            }
         }
         return _loc1_;
      }
      
      public static function meetsLimitConstraints(param1:String) : Boolean
      {
         var xml:XML = null;
         var lim:XML = null;
         var start:Date = null;
         var end:Date = null;
         var lvlMin:int = 0;
         var lvlMax:int = 0;
         var schemId:String = param1;
         xml = ResourceManager.getInstance().getResource("xml/crafting.xml").content.limited.schem.(@id == schemId)[0];
         if(xml == null)
         {
            return true;
         }
         if(xml.limit == null)
         {
            return false;
         }
         for each(lim in xml.limit.children())
         {
            switch(lim.localName())
            {
               case "start":
                  start = new Date(lim.toString().replace(/-/ig,"/"));
                  if(Network.getInstance().serverTime < start.time)
                  {
                     return false;
                  }
                  break;
               case "end":
                  end = new Date(lim.toString().replace(/-/ig,"/"));
                  if(Network.getInstance().serverTime > end.time)
                  {
                     return false;
                  }
                  break;
               case "lvl_min":
                  lvlMin = int(lim.toString());
                  if(Network.getInstance().playerData.getPlayerSurvivor().level < lvlMin)
                  {
                     return false;
                  }
                  break;
               case "lvl_max":
                  lvlMax = int(lim.toString());
                  if(Network.getInstance().playerData.getPlayerSurvivor().level > lvlMax)
                  {
                     return false;
                  }
            }
         }
         return true;
      }
      
      public function dispose() : void
      {
         this._inputItemTypes = null;
         this._outputItem.dispose();
         this._outputItem = null;
         this._xml = null;
      }
      
      public function craft(param1:Array, param2:Function = null) : void
      {
         var numOpsComplete:int;
         var onCraftingComplete:Function;
         var skillNodes:XMLList;
         var time:Number;
         var cost:int = 0;
         var craftKitItem:Item = null;
         var numOpsTotal:int = 0;
         var responseData:Object = null;
         var skills:Vector.<SkillState> = null;
         var dlgBusy:AutoProgressBarDialogue = null;
         var network:Network = null;
         var dlgInvFull:InventoryFullDialogue = null;
         var i:int = 0;
         var inputItem:Item = null;
         var skillNode:XML = null;
         var skillId:String = null;
         var skillState:SkillState = null;
         var inputItemIds:Array = param1;
         var onComplete:Function = param2;
         var playerData:PlayerData = Network.getInstance().playerData;
         if(playerData.inventory.isFull)
         {
            dlgInvFull = new InventoryFullDialogue(InventoryFullDialogue.CRAFT_FULL);
            dlgInvFull.open();
            return;
         }
         cost = this.getCraftingCost();
         if(cost > playerData.compound.resources.getAmount(GameResources.CASH))
         {
            PaymentSystem.getInstance().openBuyCoinsScreen(true);
            return;
         }
         craftKitItem = null;
         if(this.allowCraftKit)
         {
            i = 0;
            while(i < inputItemIds.length)
            {
               inputItem = playerData.inventory.getItemById(inputItemIds[i]);
               if(inputItem != null && inputItem.category == "craftkit")
               {
                  craftKitItem = inputItem;
                  break;
               }
               i++;
            }
         }
         numOpsComplete = 0;
         numOpsTotal = 2;
         onCraftingComplete = function(param1:Object):void
         {
            var _loc2_:MessageBox = null;
            var _loc3_:Item = null;
            var _loc4_:Gear = null;
            if(++numOpsComplete < numOpsTotal)
            {
               return;
            }
            dlgBusy.close();
            if(param1 == null)
            {
               return;
            }
            var _loc5_:*;
            switch(_loc5_)
            {
               case param1.success:
                  if(param1.change != null)
                  {
                     network.playerData.inventory.updateQuantities(param1.change);
                  }
                  if(param1.item != null)
                  {
                     _loc3_ = ItemFactory.createItemFromObject(param1.item);
                     if(_loc3_ != null)
                     {
                        network.playerData.giveItem(_loc3_);
                     }
                  }
                  if(param1.res != null)
                  {
                     network.playerData.compound.resources.readObject(param1.res);
                  }
                  Tracking.trackEvent("Player","Crafted",_id,cost);
                  if(_loc3_ is Gear)
                  {
                     _loc4_ = Gear(_loc3_);
                     if(_loc4_.gearType & GearType.ACTIVE)
                     {
                        Tracking.trackEvent("Player","ActiveGearCrafted",_id,cost);
                     }
                  }
                  if(craftKitItem != null)
                  {
                     Tracking.trackEvent("Player","Crafted",craftKitItem.type + "_" + _id,cost);
                  }
                  if(onComplete != null)
                  {
                     onComplete(_loc3_);
                  }
                  return;
               case _loc5_ = param1.error,PlayerIOError.NotEnoughCoins.errorID:
                  §§push(0);
                  break;
               default:
                  §§push(1);
            }
            switch(§§pop())
            {
               case 0:
                  PaymentSystem.getInstance().openBuyCoinsScreen(true);
                  return;
               default:
                  _loc2_ = new MessageBox(Language.getInstance().getString("crafted_failed_msg"));
                  _loc2_.addTitle(Language.getInstance().getString("crafted_failed_title"));
                  _loc2_.addButton(Language.getInstance().getString("crafted_failed_ok"));
                  _loc2_.open();
                  return;
            }
         };
         responseData = null;
         skillNodes = this.xml.skill;
         if(skillNodes.length() > 0)
         {
            skills = new Vector.<SkillState>();
            for each(skillNode in skillNodes)
            {
               skillId = skillNode.@id.toString();
               skillState = Network.getInstance().playerData.skills.getSkill(skillId);
               skills.push(skillState);
            }
         }
         time = 3;
         dlgBusy = new AutoProgressBarDialogue(Language.getInstance().getString("crafting_crafting",this._outputItem.getName()),5140136,time,skills);
         dlgBusy.completed.addOnce(function():void
         {
            onCraftingComplete(responseData);
         });
         dlgBusy.open();
         Audio.sound.play("sound/interface/int-crafting-progress.mp3");
         network = Network.getInstance();
         network.startAsyncOp();
         network.save({
            "id":this._id,
            "inputItems":inputItemIds
         },SaveDataMethod.CRAFT_ITEM,function(param1:Object):void
         {
            network.completeAsyncOp();
            responseData = param1;
            onCraftingComplete(responseData);
         });
      }
      
      public function getName() : String
      {
         return this._outputItem.getName() + (this._outputItem.quantifiable && this._outputItem.quantity > 1 ? " x " + this._outputItem.quantity : "");
      }
      
      public function getStartDate() : Date
      {
         return this._startDate;
      }
      
      public function getExpiryDate() : Date
      {
         return this._expiryDate;
      }
      
      public function getMinLevel() : int
      {
         return this._minLevel;
      }
      
      public function getMaxLevel() : int
      {
         return this._maxLevel;
      }
      
      public function getCraftInfo() : String
      {
         var _loc1_:Array = [];
         if(this._outputItem.numMods > 0)
         {
            if(this._outputItem.category == "weapon" || this._outputItem.category == "gear" || this._outputItem.category == "clothing")
            {
               _loc1_.push("<font color=\'" + Color.colorToHex(Effects.COLOR_GOOD) + "\'>" + Language.getInstance().getString("crafting_info_property") + "</font>");
            }
         }
         var _loc2_:int = this._outputItem.getMaxLevel();
         if(this._outputItem.level < _loc2_)
         {
            _loc1_.push(Language.getInstance().getString("crafting_info_maxlevel",_loc2_ + 1));
         }
         if(!this._outputItem.isTradable)
         {
            _loc1_.push(Language.getInstance().getString("itm_details.notrade"));
         }
         return _loc1_.join("<br/>");
      }
      
      public function getCraftingCost() : int
      {
         var _loc3_:int = 0;
         var _loc4_:XML = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:SkillState = null;
         var _loc9_:Object = null;
         var _loc10_:int = 0;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc1_:Number = 1 + Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("CraftingCost")) / 100;
         var _loc2_:Number = Number(Config.constant.CRAFT_COST_MIN_EFFECT);
         if(_loc1_ < _loc2_)
         {
            _loc1_ = _loc2_;
         }
         if(this._xml.hasOwnProperty("cost"))
         {
            _loc4_ = this._xml.cost[0];
            _loc5_ = 0;
            if(_loc4_.hasOwnProperty("@skill"))
            {
               _loc6_ = _loc4_.@skill.toString();
               _loc7_ = int(_loc4_);
               _loc8_ = Network.getInstance().playerData.skills.getSkill(_loc6_);
               _loc5_ = _loc8_.getLevelValue(_loc7_,"craft_cost");
            }
            else
            {
               _loc5_ = int(_loc4_);
            }
            _loc3_ = Math.floor(_loc5_ * _loc1_);
            _loc3_ = Math.max(_loc3_,Math.min(_loc5_,1));
         }
         else
         {
            _loc9_ = Network.getInstance().data.costTable.getItemByKey("CraftItem");
            _loc10_ = int(_loc9_.minCost);
            _loc11_ = Number(_loc9_.costPerLevel);
            _loc12_ = Number(_loc9_["cost_" + ItemQualityType.getName(this._outputItem.qualityType).toLowerCase()]);
            _loc3_ = Math.floor((this._outputItem.level + 1) * _loc11_ * _loc12_ * _loc1_);
            _loc3_ = Math.max(_loc10_,_loc3_);
         }
         return _loc3_;
      }
      
      public function getItemRequirements() : Dictionary
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc1_:Dictionary = new Dictionary();
         for each(_loc2_ in this._xml.recipe.itm)
         {
            _loc3_ = _loc2_.@id.toString();
            _loc1_[_loc3_] = int(_loc2_.toString());
         }
         return _loc1_;
      }
      
      public function getResourceRequirements() : Dictionary
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc1_:Dictionary = new Dictionary();
         for each(_loc2_ in this._xml.recipe.res)
         {
            _loc3_ = _loc2_.@id.toString();
            _loc1_[_loc3_] = int(_loc2_.toString());
         }
         return _loc1_;
      }
      
      public function getNonItemRequirements() : XMLList
      {
         return this._xml.recipe.children().(localName() != "itm");
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get inputItemTypes() : Vector.<String>
      {
         return this._inputItemTypes;
      }
      
      public function get isNew() : Boolean
      {
         return this._new;
      }
      
      public function set isNew(param1:Boolean) : void
      {
         this._new = param1;
      }
      
      public function get outputItem() : Item
      {
         return this._outputItem;
      }
      
      public function get category() : String
      {
         return this._category;
      }
      
      public function get allowCraftKit() : Boolean
      {
         return (this._category == "weapon" || this._category == "gear") && (!this._xml.hasOwnProperty("@nokit") || this._xml.@nokit == "0");
      }
      
      public function get xml() : XML
      {
         return this._xml;
      }
   }
}

