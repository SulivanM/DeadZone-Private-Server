package thelaststand.app.data
{
   import com.dynamicflash.util.Base64;
   import flash.external.ExternalInterface;
   import flash.system.Capabilities;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import playerio.Message;
   import playerio.PlayerIOError;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.SharedResources;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.game.data.BatchRecycleJobCollection;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.ClothingAccessory;
   import thelaststand.app.game.data.CompoundData;
   import thelaststand.app.game.data.CooldownCollection;
   import thelaststand.app.game.data.CrateItem;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.Gender;
   import thelaststand.app.game.data.IRecyclable;
   import thelaststand.app.game.data.Inventory;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemBindState;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.MissionCollection;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Schematic;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.SurvivorLoadoutManager;
   import thelaststand.app.game.data.Task;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.data.assignment.AssignmentCollection;
   import thelaststand.app.game.data.bounty.InfectedBounty;
   import thelaststand.app.game.data.bounty.InfectedBountyTask;
   import thelaststand.app.game.data.bounty.InfectedBountyTaskCondition;
   import thelaststand.app.game.data.effects.Effect;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.data.quests.DynamicQuest;
   import thelaststand.app.game.data.quests.GlobalQuestData;
   import thelaststand.app.game.data.research.ResearchState;
   import thelaststand.app.game.data.skills.SkillCollection;
   import thelaststand.app.game.entities.actors.HumanActor;
   import thelaststand.app.game.gui.dialogues.RecycleResultDialogue;
   import thelaststand.app.game.logic.DialogueController;
   import thelaststand.app.game.logic.TradeSystem;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.NetworkMessage;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.PlayerIOConnector;
   import thelaststand.app.network.RemotePlayerManager;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.app.utils.BinaryUtils;
   import thelaststand.common.io.ISerializable;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class PlayerData implements ISerializable
   {
      
      private var _id:String;
      
      private var _user:Object;
      
      private var _compound:CompoundData;
      
      private var _missions:MissionCollection;
      
      private var _batchRecycleJobs:BatchRecycleJobCollection;
      
      private var _network:Network;
      
      private var _nickname:String;
      
      private var _levelPoints:uint;
      
      private var _inventory:Inventory;
      
      private var _survivorId:String;
      
      private var _restedXP:int = 0;
      
      private var _playerSurvivor:Survivor;
      
      private var _dailyQuest:DynamicQuest;
      
      private var _questsCompletedStatus:Vector.<Boolean>;
      
      private var _questsCollectedStatus:Vector.<Boolean>;
      
      private var _questsTracked:Vector.<int>;
      
      private var _achievementsStatus:Vector.<Boolean>;
      
      private var _deathMobileUpgrade:Boolean;
      
      private var _inventoryUpgrade:Boolean;
      
      private var _loadoutManager:SurvivorLoadoutManager;
      
      private var _globalQuests:GlobalQuestData;
      
      private var _cooldowns:CooldownCollection;
      
      private var _oneTimePurchases:Array;
      
      private var _isAdmin:Boolean;
      
      private var _flags:FlagSet;
      
      private var _upgrades:FlagSet;
      
      private var _allianceId:String;
      
      private var _allianceTag:String;
      
      private var _uncollectedWinnings:Boolean;
      
      private var _lastLogout:Date;
      
      private var _recentPVPs:Object = new Object();
      
      private var _infectedBounty:InfectedBounty;
      
      private var _nextDZBountyIssue:Date;
      
      private var _assignments:AssignmentCollection;
      
      private var _inventoryBaseMaxSize:int;
      
      private var _linkedAlliances:Array = new Array();
      
      private var _researchState:ResearchState;
      
      private var _skills:SkillCollection;
      
      public var uncollectedWinningsChanged:Signal = new Signal();
      
      public var bountyCap:int;
      
      public var bountyCapTimestamp:Number;
      
      public var crateUnlocked:Signal;
      
      public var stateUpdated:Signal;
      
      public var restedXPChanged:Signal;
      
      public var levelUpPointsChanged:Signal;
      
      public var infectedBountyReceived:Signal;
      
      public var missionStarted:Signal;
      
      public var missionEnded:Signal;
      
      public var inventorySizeChanged:Signal;
      
      public var highActivityZones:Array = new Array();
      
      public function PlayerData()
      {
         super();
         this._flags = new FlagSet(PlayerFlags);
         this._upgrades = new FlagSet(PlayerUpgrades);
         this._upgrades.changed.add(this.onUpgradeFlagChanged);
         this._compound = new CompoundData(this);
         this._batchRecycleJobs = new BatchRecycleJobCollection();
         this._questsTracked = new Vector.<int>();
         this._loadoutManager = new SurvivorLoadoutManager();
         this._cooldowns = new CooldownCollection();
         this.stateUpdated = new Signal();
         this.crateUnlocked = new Signal(CrateItem);
         this.restedXPChanged = new Signal();
         this.levelUpPointsChanged = new Signal();
         this.infectedBountyReceived = new Signal(InfectedBounty);
         this.inventorySizeChanged = new Signal();
         this.missionStarted = new Signal(MissionData);
         this.missionEnded = new Signal(MissionData);
         this.uncollectedWinningsChanged = new Signal();
         this._recentPVPs = new Object();
         this._lastLogout = new Date();
         this._lastLogout.minutes += this._lastLogout.timezoneOffset;
      }
      
      public function log(msg:String) : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("console.log",msg);
         }
      }
      
      public function dispose() : void
      {
         this.removeNetworkListeners();
         this._network = null;
         this._compound.dispose();
         this._compound = null;
         this._missions.dispose();
         this._missions = null;
         this._batchRecycleJobs.dispose();
         this._batchRecycleJobs = null;
         this.stateUpdated.removeAll();
         this.crateUnlocked.removeAll();
      }
      
      public function addNetworkListeners() : void
      {
         this._network = Network.getInstance();
         this._network.connection.addMessageHandler(NetworkMessage.SERVER_UPDATE,this.onNetworkMessage);
         this._network.connection.addMessageHandler(NetworkMessage.RESOURCE_UPDATE,this.onNetworkMessage);
         this._network.connection.addMessageHandler(NetworkMessage.FUEL_UPDATE,this.onNetworkMessage);
         this._network.connection.addMessageHandler(NetworkMessage.TASK_COMPLETE,this.onNetworkMessage);
         this._network.connection.addMessageHandler(NetworkMessage.FLAG_CHANGED,this.onNetworkMessage);
         this._network.connection.addMessageHandler(NetworkMessage.UPGRADE_FLAG_CHANGED,this.onNetworkMessage);
         this._network.connection.addMessageHandler(NetworkMessage.PVP_LIST_UPDATE,this.onNetworkMessage);
         this._network.connection.addMessageHandler(NetworkMessage.TRADE_DISABLED,this.onNetworkMessage);
         this._network.connection.addMessageHandler(NetworkMessage.LINKED_ALLIANCES,this.onNetworkMessage);
         this._network.connection.addMessageHandler(NetworkMessage.BOUNTY_COMPLETE,this.onNetworkMessage);
         this._network.connection.addMessageHandler(NetworkMessage.BOUNTY_TASK_COMPLETE,this.onNetworkMessage);
         this._network.connection.addMessageHandler(NetworkMessage.BOUNTY_TASK_CONDITION_COMPLETE,this.onNetworkMessage);
         this._network.connection.addMessageHandler(NetworkMessage.BOUNTY_UPDATE,this.onNetworkMessage);
      }
      
      public function removeNetworkListeners() : void
      {
         if(this._network.connection == null)
         {
            return;
         }
         this._network.connection.removeMessageHandler(NetworkMessage.SERVER_UPDATE,this.onNetworkMessage);
         this._network.connection.removeMessageHandler(NetworkMessage.RESOURCE_UPDATE,this.onNetworkMessage);
         this._network.connection.removeMessageHandler(NetworkMessage.FUEL_UPDATE,this.onNetworkMessage);
         this._network.connection.removeMessageHandler(NetworkMessage.TASK_COMPLETE,this.onNetworkMessage);
         this._network.connection.removeMessageHandler(NetworkMessage.FLAG_CHANGED,this.onNetworkMessage);
         this._network.connection.removeMessageHandler(NetworkMessage.UPGRADE_FLAG_CHANGED,this.onNetworkMessage);
         this._network.connection.removeMessageHandler(NetworkMessage.PVP_LIST_UPDATE,this.onNetworkMessage);
         this._network.connection.removeMessageHandler(NetworkMessage.TRADE_DISABLED,this.onNetworkMessage);
         this._network.connection.removeMessageHandler(NetworkMessage.LINKED_ALLIANCES,this.onNetworkMessage);
         this._network.connection.removeMessageHandler(NetworkMessage.BOUNTY_COMPLETE,this.onNetworkMessage);
         this._network.connection.removeMessageHandler(NetworkMessage.BOUNTY_TASK_COMPLETE,this.onNetworkMessage);
         this._network.connection.removeMessageHandler(NetworkMessage.BOUNTY_TASK_CONDITION_COMPLETE,this.onNetworkMessage);
         this._network.connection.removeMessageHandler(NetworkMessage.BOUNTY_UPDATE,this.onNetworkMessage);
      }
      
      public function getPlayerSurvivor() : Survivor
      {
         return this._playerSurvivor;
      }
      
      public function canUpgradeItem(param1:Item) : Boolean
      {
         var _loc2_:Building = this._compound.buildings.getHighestLevelBuilding(param1 is Weapon ? "bench-weapon" : "bench-gear");
         var _loc3_:int = _loc2_ != null ? int(_loc2_.getLevelXML().max_upgrade_level) : -1;
         if(param1.level > _loc3_ - 1)
         {
            return false;
         }
         return param1.isUpgradable;
      }
      
      public function canBuildBuilding(param1:String, param2:int, param3:Boolean = false) : Boolean
      {
         var lvlDef:XML;
         var xml:XML = null;
         var num:int = 0;
         var cost:int = 0;
         var costResources:Dictionary = null;
         var buildingType:String = param1;
         var level:int = param2;
         var buy:Boolean = param3;
         xml = Building.getBuildingXML(buildingType);
         if(!xml)
         {
            return false;
         }
         lvlDef = xml.lvl.(@n == level)[0];
         if(!lvlDef)
         {
            return false;
         }
         if(level <= 0)
         {
            num = this._compound.buildings.getNumBuildingsOfType(buildingType);
            if(num >= Building.getMaxNumOfBuilding(buildingType))
            {
               return false;
            }
         }
         if(buy)
         {
            cost = Building.getBuildingUpgradeFuelCost(buildingType,level);
            if(cost > this._compound.resources.getAmount(GameResources.CASH))
            {
               return false;
            }
         }
         else
         {
            costResources = new Dictionary(true);
            Building.getBuildingUpgradeResourceItemCost(buildingType,level,costResources);
            if(!this._compound.resources.hasResources(costResources))
            {
               return false;
            }
            if(!this.meetsRequirements(lvlDef.req.children()))
            {
               return false;
            }
         }
         return true;
      }
      
      public function canRepairBuilding(param1:String, param2:int, param3:Boolean = false) : Boolean
      {
         var xml:XML = null;
         var lvlDef:XML = null;
         var cost:int = 0;
         var costResources:Dictionary = null;
         var costItems:Dictionary = null;
         var buildingType:String = param1;
         var level:int = param2;
         var buy:Boolean = param3;
         xml = ResourceManager.getInstance().getResource("xml/buildings.xml").content.item.(@id == buildingType)[0];
         if(!xml)
         {
            return false;
         }
         lvlDef = xml.lvl.(@n == level)[0];
         if(!lvlDef)
         {
            return false;
         }
         if(buy)
         {
            cost = int(Building.getBuildingRepairFuelCost(buildingType,level));
            if(cost > this._compound.resources.getAmount(GameResources.CASH))
            {
               return false;
            }
         }
         else
         {
            costResources = new Dictionary(true);
            costItems = new Dictionary(true);
            Building.getBuildingRepairResourceItemCost(buildingType,level,costResources,costItems);
            if(!this._compound.resources.hasResources(costResources))
            {
               return false;
            }
            if(!this._inventory.containsQuantitiesOfTypes(costItems))
            {
               return false;
            }
         }
         return true;
      }
      
      public function getNextSurvivorProgress() : Number
      {
         var _loc1_:int = this._compound.survivors.length;
         var _loc2_:XML = ResourceManager.getInstance().getResource("xml/survivor.xml").content.survivor[_loc1_ - 1];
         if(_loc2_ == null)
         {
            return 1;
         }
         var _loc3_:int = 24 * 60 * 60;
         var _loc4_:int = int(Config.constant.SURVIVOR_ADULT_FOOD_CONSUMPTION);
         var _loc5_:int = int(Config.constant.SURVIVOR_ADULT_WATER_CONSUMPTION);
         var _loc6_:int = int(Config.constant.MAX_SURVIVORS);
         var _loc7_:Number = Number(_loc2_.food);
         var _loc8_:Number = this._compound.resources.getResourceDaysRemaining(GameResources.FOOD);
         var _loc9_:Number = _loc7_ != 0 ? _loc8_ / _loc7_ : 1;
         if(_loc8_ == Number.POSITIVE_INFINITY || _loc9_ < 0)
         {
            _loc9_ = 0;
         }
         else if(_loc9_ > 1)
         {
            _loc9_ = 1;
         }
         var _loc10_:Number = Number(_loc2_.water);
         var _loc11_:Number = this._compound.resources.getResourceDaysRemaining(GameResources.WATER);
         var _loc12_:Number = _loc10_ != 0 ? _loc11_ / _loc10_ : 1;
         if(_loc11_ == Number.POSITIVE_INFINITY || _loc12_ < 0)
         {
            _loc12_ = 0;
         }
         else if(_loc12_ > 1)
         {
            _loc12_ = 1;
         }
         var _loc13_:int = this._compound.getComfortRating();
         var _loc14_:int = int(_loc2_.comfort);
         var _loc15_:Number = _loc14_ != 0 ? _loc13_ / _loc14_ : 1;
         if(_loc15_ < 0)
         {
            _loc15_ = 0;
         }
         else if(_loc15_ > 1)
         {
            _loc15_ = 1;
         }
         var _loc16_:int = this._compound.getSecurityRating();
         var _loc17_:int = int(_loc2_.security);
         var _loc18_:Number = _loc17_ != 0 ? _loc16_ / _loc17_ : 1;
         if(_loc18_ < 0)
         {
            _loc18_ = 0;
         }
         else if(_loc18_ > 1)
         {
            _loc18_ = 1;
         }
         var _loc19_:int = this._compound.morale.getRoundedTotal();
         var _loc20_:int = Math.round(_loc2_.morale);
         var _loc21_:Number = 0;
         if(_loc20_ == 0 || _loc19_ >= _loc20_)
         {
            _loc21_ = 1;
         }
         else if(_loc20_ < 0)
         {
            _loc21_ = 1 + (_loc19_ - _loc20_) / -_loc20_;
         }
         if(_loc21_ < 0)
         {
            _loc21_ = 0;
         }
         else if(_loc21_ > 1)
         {
            _loc21_ = 1;
         }
         return (_loc9_ + _loc12_ + _loc15_ + _loc18_ + _loc21_) / 5;
      }
      
      public function giveItem(param1:Item, param2:Boolean = true) : void
      {
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:Number = Number(NaN);
         if(param1 == null)
         {
            return;
         }
         if(param1.category == "resource")
         {
            for each(_loc3_ in param1.xml.res.res)
            {
               _loc4_ = _loc3_.@id.toString();
               _loc5_ = Math.floor(Number(_loc3_.toString()) * param1.quantity);
               this._compound.resources.addAmount(_loc4_,_loc5_);
            }
         }
         else
         {
            if(param2)
            {
               param1.isNew = true;
            }
            this._inventory.addItem(param1);
         }
      }
      
      public function giveItemOfType(param1:String, param2:int = 1, param3:int = 0) : Item
      {
         var _loc4_:Item = ItemFactory.createItemFromTypeId(param1);
         if(_loc4_ == null)
         {
            return null;
         }
         _loc4_.quantity = param2;
         _loc4_.baseLevel = param3;
         this.giveItem(_loc4_);
         return _loc4_;
      }
      
      public function giveItemOfTypes(param1:Object) : void
      {
         var _loc2_:String = null;
         for(_loc2_ in param1)
         {
            this.giveItemOfType(_loc2_,int(param1[_loc2_]));
         }
      }
      
      public function meetsRequirements(param1:XMLList, param2:uint = 16777215) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:XML = null;
         var _loc6_:int = 0;
         var _loc7_:Survivor = null;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:String = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:String = null;
         var _loc15_:int = 0;
         var _loc16_:String = null;
         var _loc17_:int = 0;
         var _loc18_:String = null;
         var _loc19_:int = 0;
         if(param1 == null || param1.length() == 0)
         {
            return true;
         }
         for each(_loc5_ in param1)
         {
            switch(_loc5_.localName())
            {
               case "lvl":
                  if((param2 & RequirementTypes.PlayerLevel) != 0)
                  {
                     _loc6_ = int(_loc5_.toString());
                     _loc7_ = this.getPlayerSurvivor();
                     if(_loc7_ == null || _loc7_.level < _loc6_)
                     {
                        return false;
                     }
                  }
                  break;
               case "bld":
                  if((param2 & RequirementTypes.Buildings) != 0)
                  {
                     _loc8_ = _loc5_.@id.toString();
                     _loc9_ = int(_loc5_.@lvl.toString());
                     _loc10_ = Math.max(1,int(_loc5_.toString()));
                     if(!this._compound.buildings.hasBuilding(_loc8_,_loc9_,_loc10_))
                     {
                        return false;
                     }
                  }
                  break;
               case "srv":
                  if((param2 & RequirementTypes.Survivors) != 0)
                  {
                     _loc11_ = _loc5_.@id.toString();
                     _loc12_ = int(_loc5_.@lvl.toString());
                     _loc13_ = Math.max(1,int(_loc5_.toString()));
                     if(!this._compound.survivors.hasSurvivor(_loc11_,_loc12_,_loc13_))
                     {
                        return false;
                     }
                  }
                  break;
               case "itm":
                  if((param2 & RequirementTypes.Items) != 0)
                  {
                     _loc14_ = _loc5_.@id.toString();
                     _loc15_ = Math.max(int(_loc5_.toString()),1);
                     if(!this._inventory.containsTypeQuantity(_loc14_,_loc15_))
                     {
                        return false;
                     }
                  }
                  break;
               case "res":
                  if((param2 & RequirementTypes.Resources) != 0)
                  {
                     _loc16_ = _loc5_.@id.toString();
                     _loc17_ = int(_loc5_.toString());
                     if(this._compound.resources.getAmount(_loc16_) < _loc17_)
                     {
                        return false;
                     }
                  }
                  break;
               case "skill":
                  if((param2 & RequirementTypes.Skills) != 0)
                  {
                     _loc18_ = _loc5_.@id.toString();
                     _loc19_ = int(_loc5_.@lvl.toString());
                     if(this._skills.getSkill(_loc18_).level < _loc19_)
                     {
                        return false;
                     }
                  }
            }
         }
         return true;
      }
      
      public function appyRestedXPBonus(param1:int) : int
      {
         if(this._restedXP <= 0)
         {
            return param1;
         }
         var _loc2_:Number = Config.constant.REST_XP_BONUS - 1;
         var _loc3_:int = int(Math.ceil(param1 * _loc2_));
         if(param1 + _loc3_ > this._restedXP)
         {
            _loc3_ = this._restedXP;
         }
         var _loc4_:int = param1 + _loc3_;
         var _loc5_:int = Math.max(this._restedXP - _loc4_,0);
         if(_loc5_ != this._restedXP)
         {
            this._restedXP = _loc5_;
            this.restedXPChanged.dispatch();
         }
         return _loc4_;
      }
      
      public function resetLeaderAttributes(param1:Function) : void
      {
         var msgBusy:BusyDialogue = null;
         var onComplete:Function = param1;
         if(this.getPlayerSurvivor().level < Config.constant.LEADER_RESET_MIN_LEVEL)
         {
            onComplete(false);
            return;
         }
         msgBusy = new BusyDialogue(Language.getInstance().getString("retrain_leader_busy"));
         msgBusy.open();
         this._network.save(null,SaveDataMethod.RESET_LEADER,function(param1:Object):void
         {
            var _loc3_:String = null;
            msgBusy.close();
            if(param1 == null)
            {
               onComplete(false);
               return;
            }
            var _loc4_:*;
            switch(_loc4_)
            {
               case param1.success:
                  var _loc2_:Survivor = getPlayerSurvivor();
                  if(param1.hasOwnProperty("attributes"))
                  {
                     for(_loc3_ in param1.attributes)
                     {
                        if(_loc3_ in _loc2_.attributes)
                        {
                           _loc2_.attributes[_loc3_] = param1.attributes[_loc3_];
                        }
                     }
                  }
                  if(param1.hasOwnProperty("levelPts"))
                  {
                     levelPoints = int(param1.levelPts);
                  }
                  if(param1.cooldown != null)
                  {
                     Network.getInstance().playerData.cooldowns.parse(Base64.decodeToByteArray(param1.cooldown));
                  }
                  ++Network.getInstance().loginFlags.leaderResets;
                  onComplete(true);
                  return;
               case _loc4_ = param1.error,PlayerIOError.NotEnoughCoins.errorID:
                  §§push(0);
                  break;
               default:
                  §§push(1);
            }
            switch(§§pop())
            {
               case 0:
                  PaymentSystem.getInstance().openBuyCoinsScreen();
                  break;
               case 1:
                  DialogueController.getInstance().showGenericRequestError();
            }
            onComplete(false);
         });
      }
      
      public function saveCustomization(param1:Object = null, param2:Object = null, param3:Function = null) : void
      {
         var state:Object;
         var msgBusy:BusyDialogue = null;
         var survivorData:Object = param1;
         var attributes:Object = param2;
         var onComplete:Function = param3;
         var lang:Language = Language.getInstance();
         msgBusy = new BusyDialogue(lang.getString("server_saving"),"saving");
         msgBusy.open();
         state = survivorData || {};
         if(attributes != null)
         {
            state.att = attributes;
         }
         if(Boolean(state.hasOwnProperty("name")) && (state.name == null || state.name == "undefined" || state.name == "null"))
         {
            state.name = "";
         }
         this._network.save(state,SaveDataMethod.PLAYER_CUSTOM,function(param1:*):void
         {
            var _loc3_:String = null;
            msgBusy.close();
            if(param1 == null)
            {
               DialogueController.getInstance().showGenericRequestError();
               if(onComplete != null)
               {
                  onComplete(false);
               }
               return;
            }
            if(param1.error != null)
            {
               onComplete(false,param1.error);
               return;
            }
            var _loc2_:Survivor = getPlayerSurvivor();
            if(param1.hasOwnProperty("attributes"))
            {
               for(_loc3_ in param1.attributes)
               {
                  _loc2_.attributes[_loc3_] = param1.attributes[_loc3_];
               }
            }
            if(param1.hasOwnProperty("levelPts"))
            {
               levelPoints = int(param1.levelPts);
            }
            if(param1.hasOwnProperty("nickname"))
            {
               _loc2_.setName(param1.nickname);
            }
            if(onComplete != null)
            {
               onComplete(true);
            }
         });
      }
      
      public function updateState(param1:Object) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Object = null;
         var _loc4_:Survivor = null;
         var _loc5_:String = null;
         var _loc6_:Task = null;
         var _loc7_:String = null;
         var _loc8_:MissionData = null;
         if(param1 == null)
         {
            return;
         }
         if(param1.resources != null)
         {
            this._compound.resources.readObject(param1.resources);
         }
         if(param1.survivors != null)
         {
            for each(_loc3_ in param1.survivors)
            {
               if(_loc3_ != null)
               {
                  _loc4_ = this._compound.survivors.getSurvivorById(String(_loc3_.id));
                  if(_loc4_ != null)
                  {
                     if(_loc3_.morale != null)
                     {
                        _loc4_.morale.readObject(_loc3_.morale);
                     }
                  }
               }
            }
            this._compound.applyMoraleEffects();
         }
         if(param1.tasks != null)
         {
            for(_loc5_ in param1.tasks)
            {
               _loc6_ = this._compound.tasks.getTaskById(_loc5_);
               if(_loc6_ != null)
               {
                  _loc2_ = param1.tasks[_loc5_].split("|");
                  _loc6_.length = int(_loc2_[1]);
                  _loc6_.time = int(_loc2_[0]);
               }
            }
         }
         if(param1.missions != null)
         {
            for(_loc7_ in param1.missions)
            {
               _loc8_ = this._missions.getMissionById(_loc7_);
               if(!(_loc8_ == null || _loc8_.returnTimer == null))
               {
                  _loc2_ = param1.missions[_loc7_].split("|");
                  _loc8_.returnTimer.setTimer(new Date(Number(_loc2_[0])),int(_loc2_[1]));
               }
            }
         }
         if(param1.bountyCap != null)
         {
            this.bountyCap = param1.bountyCap;
         }
         if(param1.bountyCapTimestamp != null)
         {
            this.bountyCapTimestamp = param1.bountyCapTimestamp;
         }
         if(param1.research)
         {
            this._researchState.parseEffects(param1.research);
         }
         this.stateUpdated.dispatch();
      }
      
      public function hasOneTimePurchase(param1:String) : Boolean
      {
         return this._oneTimePurchases.indexOf(param1) > -1;
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         return param1;
      }
      
      public function readObject(param1:Object) : void
      {
         log("ENTERING readObject of PlayerData with obj: " + JSON.stringify(param1));
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc6_:Survivor = null;
         var _loc7_:Building = null;
         var _loc8_:Array = null;
         log("readObject: param1.key = " + param1.key);
         this._id = param1.key;
         log("readObject: param1.user = " + param1.user);
         this._user = param1.user || {};
         log("readObject: param1.admin = " + param1.admin);
         this._isAdmin = param1.admin === true;
         log("readObject: param1.allianceId = " + param1.allianceId);
         this._allianceId = param1.allianceId;
         log("readObject: param1.allianceTag = " + param1.allianceTag);
         this._allianceTag = param1.allianceTag;
         this._flags.deserialize(param1.flags);
         log("readObject: flags deserialized");
         this._upgrades.deserialize(param1.upgrades);
         log("readObject: upgrades deserialized");
         this._nickname = param1.nickname != null && param1.nickname.length == 0 ? null : param1.nickname;
         log("readObject: nickname = " + this._nickname);
         this._survivorId = param1.playerSurvivor;
         log("readObject: playerSurvivor = " + this._survivorId);
         this._levelPoints = param1.hasOwnProperty("levelPts") ? uint(int(param1.levelPts)) : 0;
         log("readObject: levelPts = " + this._levelPoints);
         this._restedXP = param1.hasOwnProperty("restXP") ? int(param1.restXP) : 0;
         log("readObject: restedXP = " + this._restedXP);
         this._oneTimePurchases = "oneTimePurchases" in param1 ? (param1.oneTimePurchases as Array).concat() : [];
         log("readObject: oneTimePurchases = " + this._oneTimePurchases);
         var _loc4_:RemotePlayerManager = RemotePlayerManager.getInstance();
         if(param1.neighbors != null)
         {
            _loc4_.addNeighbors(param1.neighbors);
            log("readObject: neighbors added");
         }
         if(param1.friends != null)
         {
            _loc4_.addFriends(param1.friends);
            log("readObject: friends added");
         }
         if(param1.neighborHistory != null)
         {
            _loc4_.updateHistory(param1.neighborHistory);
            log("readObject: neighborHistory updated");
         }
         this._researchState = new ResearchState();
         if(param1.research != null)
         {
            this._researchState.parse(param1.research);
            log("readObject: research parsed");
         }
         this._skills = new SkillCollection();
         if(param1.skills != null)
         {
            this._skills.read(param1.skills);
            log("readObject: skills read");
         }
         this._compound.resources.readObject(param1.resources);
         log("readObject: resources loaded");
         this._compound.survivors.readObject(param1.survivors);
         log("readObject: survivors loaded");
         _loc2_ = 0;
         _loc3_ = this._compound.survivors.length;
         while(_loc2_ < _loc3_)
         {
            _loc6_ = this._compound.survivors.getSurvivor(_loc2_);
            _loc6_.isPlayerOwned = true;
            this._loadoutManager.addSurvivor(_loc6_);
            log("readObject: added survivor #" + _loc2_);
            _loc2_++;
         }
         this._playerSurvivor = this._compound.survivors.getSurvivorById(this._survivorId);
         log("readObject: _playerSurvivor = " + this._playerSurvivor);
         this._playerSurvivor.attributes.readObject(param1.playerAttributes);
         log("readObject: player attributes loaded");
         this._playerSurvivor.levelIncreased.add(this.onLevelUp);
         this._compound.buildings.readObject(param1.buildings);
         log("readObject: buildings loaded");
         this._compound.buildings.buildingAdded.add(this.onBuildingAdded);
         this._compound.buildings.buildingRemoved.add(this.onBuildRemoved);
         this._compound.setRallyAssignments(param1.rally);
         log("readObject: rally assignments set");
         _loc2_ = 0;
         _loc3_ = this._compound.buildings.numBuildings;
         while(_loc2_ < _loc3_)
         {
            _loc7_ = this._compound.buildings.getBuilding(_loc2_);
            if(_loc7_ != null)
            {
               _loc7_.upgradeStarted.add(this.onBuildingUpgradeStarted);
               if(_loc7_.upgradeTimer != null && !_loc7_.upgradeTimer.hasEnded())
               {
                  _loc7_.upgradeTimer.completed.addOnce(this.onBuildingUpgradeComplete);
               }
               log("readObject: building #" + _loc2_ + " initialized");
            }
            _loc2_++;
         }
         this._compound.tasks.readObject(param1.tasks);
         log("readObject: tasks loaded");
         this._missions = new MissionCollection();
         if(param1.missions != null)
         {
            this._missions.readObject(param1.missions);
            log("readObject: missions read");
         }
         this._assignments = new AssignmentCollection();
         if(param1.assignments != null)
         {
            this._assignments.parse(param1.assignments);
            log("readObject: assignments parsed");
         }
         _loc2_ = 0;
         _loc3_ = this._compound.survivors.length;
         while(_loc2_ < _loc3_)
         {
            _loc6_ = this._compound.survivors.getSurvivor(_loc2_);
            if(_loc6_.assignmentId != null && this._assignments.getById(_loc6_.assignmentId) == null)
            {
               _loc6_.assignmentId = null;
               log("readObject: cleared invalid assignment for survivor #" + _loc2_);
            }
            _loc2_++;
         }
         this._inventory = new Inventory();
         if(param1.inventory != null)
         {
            this._inventory.deserialize(param1.inventory);
            log("readObject: inventory deserialized");
         }
         this._inventory.itemRemoved.add(this.onInventoryItemRemoved);
         if(param1.effects != null)
         {
            this._compound.effects.readObject(param1.effects);
            log("readObject: effects loaded");
         }
         this._compound.effects.effectChanged.add(this.onEffectChanged);
         this._compound.effects.effectExpired.add(this.onEffectExpired);
         this._compound.globalEffects.effectChanged.add(this.onEffectChanged);
         this._compound.globalEffects.effectExpired.add(this.onEffectExpired);
         if(param1.globalEffects != null)
         {
            this._compound.globalEffects.readObject(param1.globalEffects);
            log("readObject: globalEffects loaded");
         }
         if(param1.cooldowns != null)
         {
            this._cooldowns.readObject(param1.cooldowns);
            log("readObject: cooldowns loaded");
         }
         this._batchRecycleJobs.clear();
         if(param1.batchRecycles != null)
         {
            this._batchRecycleJobs.readObject(param1.batchRecycles);
            log("readObject: batchRecycles loaded");
         }
         if(param1.offenceLoadout != null)
         {
            this._loadoutManager.parseLoadout(SurvivorLoadout.TYPE_OFFENCE,param1.offenceLoadout,this._inventory);
            log("readObject: offence loadout parsed");
         }
         if(param1.defenceLoadout != null)
         {
            this._loadoutManager.parseLoadout(SurvivorLoadout.TYPE_DEFENCE,param1.defenceLoadout,this._inventory);
            log("readObject: defence loadout parsed");
         }
         if(param1.survivors != null)
         {
            this._loadoutManager.parseClothingAccessories(param1.survivors,this._inventory);
            log("readObject: clothing/accessories parsed");
         }
         if(param1.quests != null)
         {
            this._questsCompletedStatus = BinaryUtils.booleanArrayFromByteArray(param1.quests);
            log("readObject: quests loaded");
         }
         if(param1.questsCollected != null)
         {
            this._questsCollectedStatus = BinaryUtils.booleanArrayFromByteArray(param1.questsCollected);
            log("readObject: questsCollected loaded");
         }
         if(param1.achievements != null)
         {
            this._achievementsStatus = BinaryUtils.booleanArrayFromByteArray(param1.achievements);
            log("readObject: achievements loaded");
         }
         if(param1.dailyQuest != null)
         {
            this._dailyQuest = new DynamicQuest(param1.dailyQuest);
            log("readObject: dailyQuest loaded");
         }
         this._questsTracked.length = 0;
         if(param1.questsTracked != null)
         {
            _loc8_ = String(param1.questsTracked).split("|");
            _loc2_ = 0;
            _loc3_ = int(_loc8_.length);
            while(_loc2_ < _loc3_)
            {
               if(_loc8_[_loc2_].length != 0)
               {
                  this._questsTracked[_loc2_] = int(_loc8_[_loc2_]);
               }
               _loc2_++;
            }
            log("readObject: questsTracked loaded");
         }
         this._globalQuests = new GlobalQuestData();
         if(param1.gQuestsV2)
         {
            this._globalQuests.readObject(param1.gQuestsV2);
            log("readObject: globalQuestsV2 loaded");
         }
         this.bountyCap = param1.bountyCap;
         log("readObject: bountyCap = " + this.bountyCap);
         if(param1.lastLogout)
         {
            this._lastLogout = param1.lastLogout;
            this._lastLogout.minutes += this._lastLogout.timezoneOffset;
            log("readObject: lastLogout set");
         }
         var _loc5_:Object = param1["dzbounty"];
         if(_loc5_ != null)
         {
            this._infectedBounty = new InfectedBounty(_loc5_);
            log("readObject: dzbounty loaded");
         }
         this._nextDZBountyIssue = param1["nextDZBountyIssue"];
         log("readObject: nextDZBountyIssue = " + this._nextDZBountyIssue);
         if(param1.highActivity != null && param1.highActivity.buildings != null)
         {
            this.highActivityZones = param1.highActivity.buildings;
            log("readObject: highActivity buildings set");
         }
         this._inventoryBaseMaxSize = int(param1["invsize"]);
         log("readObject: invsize = " + this._inventoryBaseMaxSize);
         this.updateInventoryCap();
         log("readObject: inventory cap updated");
         this.checkAndUpdateLoadouts();
         log("readObject: loadouts updated");
         this._compound.init();
         log("readObject: compound initialized");
      }
      
      public function recycleObject(param1:IRecyclable, param2:Function = null) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Item = null;
         var _loc6_:Building = null;
         if(param1 is Item)
         {
            _loc5_ = Item(param1);
            this.recycleItem(_loc5_,param2);
         }
         else if(param1 is Building)
         {
            _loc6_ = Building(param1);
            this.recycleBuilding(_loc6_,param2);
         }
      }
      
      public function recycleBuilding(param1:Building, param2:Function = null) : void
      {
         var msgBusy:BusyDialogue = null;
         var building:Building = param1;
         var onComplete:Function = param2;
         if(building.type == "rally" && this._compound.buildings.getNumBuildingsOfType("rally") <= 1)
         {
            if(onComplete != null)
            {
               onComplete(false);
            }
            return;
         }
         msgBusy = new BusyDialogue(Language.getInstance().getString("recycle_recycling"));
         msgBusy.open();
         this._network.save({"id":building.id},SaveDataMethod.BUILDING_RECYCLE,function(param1:Object):void
         {
            var _loc2_:Object = null;
            var _loc3_:Item = null;
            msgBusy.close();
            if(param1 == null || param1.success !== true)
            {
               if(onComplete != null)
               {
                  onComplete(false);
               }
               return;
            }
            if(param1.items != null)
            {
               for each(_loc2_ in param1.items)
               {
                  _loc3_ = ItemFactory.createItemFromObject(_loc2_);
                  if(_loc3_ != null)
                  {
                     giveItem(_loc3_);
                  }
               }
            }
            _compound.buildings.removeBuilding(building);
            building.recycled.dispatch(building);
            building.dispose();
            if(onComplete != null)
            {
               onComplete(true);
            }
         });
      }
      
      public function recycleItem(param1:Item, param2:Function = null) : void
      {
         var msgBusy:BusyDialogue = null;
         var item:Item = param1;
         var onComplete:Function = param2;
         if(item == null)
         {
            if(onComplete != null)
            {
               onComplete(false);
            }
            return;
         }
         msgBusy = new BusyDialogue(Language.getInstance().getString("recycle_recycling"));
         msgBusy.open();
         this._network.save({"id":item.id},SaveDataMethod.ITEM_RECYCLE,function(param1:Object):void
         {
            var _loc3_:Vector.<Item> = null;
            var _loc4_:Object = null;
            var _loc5_:Item = null;
            var _loc6_:RecycleResultDialogue = null;
            msgBusy.close();
            if(param1 == null || param1.success !== true)
            {
               if(onComplete != null)
               {
                  onComplete(false);
               }
               return;
            }
            var _loc2_:int = int(param1.qty);
            if(_loc2_ <= 0)
            {
               _inventory.removeItem(item);
            }
            else
            {
               item.quantity = _loc2_;
            }
            if(param1.items != null)
            {
               _loc3_ = null;
               for each(_loc4_ in param1.items)
               {
                  _loc5_ = ItemFactory.createItemFromObject(_loc4_);
                  if(_loc5_ != null)
                  {
                     giveItem(_loc5_);
                     if(_loc4_.randgrp === true)
                     {
                        _loc3_ ||= new Vector.<Item>();
                        _loc3_.push(_loc5_);
                     }
                  }
               }
               if(_loc3_ != null)
               {
                  _loc6_ = new RecycleResultDialogue(_loc3_);
                  _loc6_.open();
               }
            }
            if(onComplete != null)
            {
               onComplete(true);
            }
         });
      }
      
      public function disposeItem(param1:Item, param2:Function = null) : void
      {
         var msgBusy:BusyDialogue = null;
         var item:Item = param1;
         var onComplete:Function = param2;
         if(item == null)
         {
            if(onComplete != null)
            {
               onComplete(false);
            }
            return;
         }
         msgBusy = new BusyDialogue(Language.getInstance().getString("disposing"));
         msgBusy.open();
         this._network.save({"id":item.id},SaveDataMethod.ITEM_DISPOSE,function(param1:Object):void
         {
            msgBusy.close();
            if(param1 == null || param1.success !== true)
            {
               if(onComplete != null)
               {
                  onComplete(false);
               }
               return;
            }
            var _loc2_:int = int(param1.qty);
            if(_loc2_ <= 0)
            {
               _inventory.removeItem(item);
            }
            else
            {
               item.quantity = _loc2_;
            }
            if(onComplete != null)
            {
               onComplete(true);
            }
         });
      }
      
      public function getHighActivityAreaLevel() : int
      {
         var _loc1_:int = int(Network.getInstance().playerData.getPlayerSurvivor().level);
         return _loc1_ + int(Config.constant.HAZ_MISSION_LEVEL_INCREASE);
      }
      
      public function saveSurvivorOffensiveLoadout() : void
      {
         var srv:Survivor = null;
         var loadoutData:Array = [];
         var i:int = 0;
         var len:int = this.compound.survivors.length;
         while(i < len)
         {
            srv = this.compound.survivors.getSurvivor(i);
            if(!(srv == null || srv.id == null))
            {
               loadoutData.push(srv.loadoutOffence.toHashtable());
            }
            i++;
         }
         this._network.save(loadoutData,SaveDataMethod.SURVIVOR_OFFENCE_LOADOUT,function(param1:Object):void
         {
            var _loc3_:int = 0;
            var _loc4_:String = null;
            var _loc5_:Item = null;
            if(param1 == null)
            {
               return;
            }
            var _loc2_:Array = param1.bind as Array;
            if(_loc2_ != null)
            {
               _loc3_ = 0;
               while(_loc3_ < _loc2_.length)
               {
                  _loc4_ = _loc2_[_loc3_];
                  _loc5_ = inventory.getItemById(_loc4_);
                  if(_loc5_ != null)
                  {
                     _loc5_.bindState = ItemBindState.Bound;
                  }
                  _loc3_++;
               }
            }
         });
      }
      
      public function saveSurvivorDefensiveLoadout() : void
      {
         var srv:Survivor = null;
         var loadoutData:Array = [];
         var i:int = 0;
         var len:int = this.compound.survivors.length;
         while(i < len)
         {
            srv = this.compound.survivors.getSurvivor(i);
            if(!(srv == null || srv.id == null))
            {
               loadoutData.push(srv.loadoutDefence.toHashtable());
            }
            i++;
         }
         this._network.save(loadoutData,SaveDataMethod.SURVIVOR_DEFENCE_LOADOUT,function(param1:Object):void
         {
            var _loc3_:int = 0;
            var _loc4_:String = null;
            var _loc5_:Item = null;
            if(param1 == null)
            {
               return;
            }
            var _loc2_:Array = param1.bind as Array;
            if(_loc2_ != null)
            {
               _loc3_ = 0;
               while(_loc3_ < _loc2_.length)
               {
                  _loc4_ = _loc2_[_loc3_];
                  _loc5_ = inventory.getItemById(_loc4_);
                  if(_loc5_ != null)
                  {
                     _loc5_.bindState = ItemBindState.Bound;
                  }
                  _loc3_++;
               }
            }
         });
      }
      
      public function saveSurvivorClothingLoadout() : void
      {
         var srv:Survivor = null;
         var slotData:Object = null;
         var j:int = 0;
         var item:ClothingAccessory = null;
         var loadoutData:Object = {};
         var i:int = 0;
         var len:int = this.compound.survivors.length;
         while(i < len)
         {
            srv = this.compound.survivors.getSurvivor(i);
            if(!(srv == null || srv.id == null))
            {
               slotData = {};
               j = 0;
               while(j < srv.maxClothingAccessories)
               {
                  item = srv.getAccessory(j);
                  if(item != null)
                  {
                     slotData[j.toString()] = item.id;
                  }
                  j++;
               }
               loadoutData[srv.id] = slotData;
            }
            i++;
         }
         this._network.save(loadoutData,SaveDataMethod.SURVIVOR_CLOTHING_LOADOUT,function(param1:Object):void
         {
            var _loc3_:int = 0;
            var _loc4_:String = null;
            var _loc5_:Item = null;
            if(param1 == null)
            {
               return;
            }
            var _loc2_:Array = param1.bind as Array;
            if(_loc2_ != null)
            {
               _loc3_ = 0;
               while(_loc3_ < _loc2_.length)
               {
                  _loc4_ = _loc2_[_loc3_];
                  _loc5_ = inventory.getItemById(_loc4_);
                  if(_loc5_ != null)
                  {
                     _loc5_.bindState = ItemBindState.Bound;
                  }
                  _loc3_++;
               }
            }
         });
      }
      
      public function trackLevelUp() : void
      {
         try
         {
            Tracking.setCustomVarsForPlayer(this);
            Tracking.trackEvent("Player","LevelUp",String(this._playerSurvivor.level),this._playerSurvivor.level);
            Tracking.trackEvent("Player","Comfort",null,this._compound.getComfortRating());
            Tracking.trackEvent("Player","Security",null,this._compound.getSecurityRating());
            Tracking.trackEvent("Player","Morale",null,this._compound.morale.getRoundedTotal());
            Tracking.trackEvent("Player","Survivors",null,this._compound.survivors.length);
            Tracking.trackEvent("Player","InventorySize",null,this._inventory.numItems);
            Tracking.trackEvent("Player","Weapons",null,this._inventory.getItemsOfCategory("weapon").length);
            Tracking.trackEvent("Player","Gear",null,this._inventory.getItemsOfCategory("gear").length);
            if(Network.getInstance().service == PlayerIOConnector.SERVICE_KONGREGATE && this._playerSurvivor.level <= this._playerSurvivor.levelMax)
            {
               SharedResources.kongregateAPI.stats.submit("Level",this._playerSurvivor.level + 1);
            }
         }
         catch(e:Error)
         {
         }
      }
      
      public function isInventoryUpgraded() : Boolean
      {
         return this._inventoryBaseMaxSize > Config.constant.INVENTORY_SIZE_DEFAULT;
      }
      
      public function canUpgradeInventory() : Boolean
      {
         return this._inventoryBaseMaxSize < Config.constant.INVENTORY_MAX;
      }
      
      public function canBuyInventoryUpgrade(param1:String) : Boolean
      {
         var _loc2_:Object = Network.getInstance().data.costTable.getItemByKey(param1);
         if(_loc2_ == null || _loc2_.type != "inventory")
         {
            return false;
         }
         var _loc3_:int = this._inventoryBaseMaxSize;
         _loc3_ += int(_loc2_.amount);
         return _loc3_ <= Config.constant.INVENTORY_MAX;
      }
      
      public function setInventoryBaseSize(param1:int) : void
      {
         if(param1 == this._inventoryBaseMaxSize)
         {
            return;
         }
         this._inventoryBaseMaxSize = param1;
         this.updateInventoryCap();
         this.inventorySizeChanged.dispatch();
      }
      
      public function refreshInventorySize(param1:Function) : void
      {
         var completeCallback:Function = param1;
         this._network.save(null,SaveDataMethod.GET_INVENTORY_SIZE,function(param1:Object):void
         {
            if(param1 == null || param1.success !== true)
            {
               if(completeCallback != null)
               {
                  completeCallback(false);
               }
               return;
            }
            var _loc2_:int = int(param1["size"]);
            setInventoryBaseSize(_loc2_);
            if(completeCallback != null)
            {
               completeCallback(true);
            }
         });
      }
      
      private function updateInventoryCap() : void
      {
         var _loc1_:int = this._inventoryBaseMaxSize;
         var _loc2_:Number = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("InventoryCap"));
         _loc1_ += int(Math.floor(_loc1_ * (_loc2_ / 100)));
         this._inventory.maxItems = _loc1_;
      }
      
      public function checkAndUpdateLoadouts() : void
      {
         var itemLevelLimit:int = 0;
         try
         {
            itemLevelLimit = this._compound.getEffectValue(EffectType.getTypeValue("WeaponGearLevelLimit"));
            if(this._loadoutManager.checkAllUsability(SurvivorLoadout.TYPE_OFFENCE,itemLevelLimit))
            {
               this.saveSurvivorOffensiveLoadout();
            }
            if(this._loadoutManager.checkAllUsability(SurvivorLoadout.TYPE_DEFENCE,itemLevelLimit))
            {
               this.saveSurvivorDefensiveLoadout();
            }
         }
         catch(e:Error)
         {
         }
      }
      
      private function onBuildingAdded(param1:Building) : void
      {
         param1.upgradeStarted.add(this.onBuildingUpgradeStarted);
         if(param1.upgradeTimer != null)
         {
            this.onBuildingUpgradeStarted(param1);
         }
      }
      
      private function onBuildRemoved(param1:Building) : void
      {
         param1.upgradeStarted.remove(this.onBuildingUpgradeStarted);
         if(param1.upgradeTimer != null)
         {
            param1.upgradeTimer.completed.remove(this.onBuildingUpgradeComplete);
         }
      }
      
      private function onBuildingUpgradeStarted(param1:Building, param2:Boolean = false) : void
      {
         var _loc3_:String = null;
         var _loc4_:Vector.<String> = null;
         var _loc5_:String = null;
         var _loc6_:Schematic = null;
         if(param1.upgradeTimer != null)
         {
            param1.upgradeTimer.completed.addOnce(this.onBuildingUpgradeComplete);
         }
         if(param2 && param1.craftingCategories.length > 0)
         {
            for each(_loc3_ in param1.craftingCategories)
            {
               _loc4_ = Schematic.getBaseSchematics(_loc3_,param1.level);
               for each(_loc5_ in _loc4_)
               {
                  _loc6_ = new Schematic(_loc5_);
                  this._inventory.addSchematic(_loc6_);
               }
            }
         }
      }
      
      private function onBuildingUpgradeComplete(param1:TimerData) : void
      {
         var _loc3_:String = null;
         var _loc4_:Vector.<String> = null;
         var _loc5_:String = null;
         var _loc6_:Schematic = null;
         if(param1 == null || this._compound == null)
         {
            return;
         }
         var _loc2_:Building = param1.target as Building;
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.craftingCategories.length > 0)
         {
            for each(_loc3_ in _loc2_.craftingCategories)
            {
               _loc4_ = Schematic.getBaseSchematics(_loc3_,_loc2_.level);
               for each(_loc5_ in _loc4_)
               {
                  _loc6_ = new Schematic(_loc5_);
                  this._inventory.addSchematic(_loc6_);
               }
            }
         }
      }
      
      private function onLevelUp(param1:Survivor, param2:int) : void
      {
         if(param1 != this._playerSurvivor)
         {
            return;
         }
         this.levelPoints += param2 - this._playerSurvivor.level;
         this.trackLevelUp();
         this._inventory.updateLimitedSchematics();
      }
      
      private function onNetworkMessage(param1:Message) : void
      {
         var data:String = null;
         var n:int = 0;
         var id:String = null;
         var task:Task = null;
         var rewardItem:Item = null;
         var bTask:InfectedBountyTask = null;
         var bCond:InfectedBountyTaskCondition = null;
         var i:int = 0;
         var msg:Message = param1;
         try
         {
            n = 0;
            switch(msg.type)
            {
               case NetworkMessage.SERVER_UPDATE:
                  if(msg.length <= 0)
                  {
                     return;
                  }
                  data = msg.getString(n++);
                  if(data != null)
                  {
                     this.updateState(JSON.parse(data));
                  }
                  break;
               case NetworkMessage.RESOURCE_UPDATE:
                  if(msg.length <= 0)
                  {
                     return;
                  }
                  this._compound.updateProductionResources(JSON.parse(msg.getString(n++)));
                  break;
               case NetworkMessage.FUEL_UPDATE:
                  if(msg.length <= 0)
                  {
                     return;
                  }
                  this._compound.resources.setAmount(GameResources.CASH,msg.getInt(0));
                  break;
               case NetworkMessage.TASK_COMPLETE:
                  id = msg.getString(n++);
                  task = this._compound.tasks.getTaskById(id);
                  if(task != null)
                  {
                     task.completeTask();
                  }
                  break;
               case NetworkMessage.FLAG_CHANGED:
                  if(msg.length < 2)
                  {
                     return;
                  }
                  this._flags.set(msg.getInt(n++),msg.getBoolean(n++));
                  break;
               case NetworkMessage.UPGRADE_FLAG_CHANGED:
                  if(msg.length < 2)
                  {
                     return;
                  }
                  this._upgrades.set(msg.getInt(n++),msg.getBoolean(n++));
                  break;
               case NetworkMessage.PVP_LIST_UPDATE:
                  if(msg.length < 2)
                  {
                     return;
                  }
                  this.updateRecentPVPList(msg.getString(n++),msg.getNumber(n++));
                  break;
               case NetworkMessage.TRADE_DISABLED:
                  TradeSystem.getInstance().isTradeSystemEnabled = false;
                  break;
               case NetworkMessage.BOUNTY_COMPLETE:
                  if(msg.length < 2 || this._infectedBounty == null)
                  {
                     return;
                  }
                  if(this._infectedBounty.id == msg.getString(n++))
                  {
                     rewardItem = ItemFactory.createItemFromObject(JSON.parse(msg.getString(n++)));
                     if(rewardItem != null)
                     {
                        this._inventory.addItem(rewardItem);
                        this._infectedBounty.complete(rewardItem);
                     }
                  }
                  break;
               case NetworkMessage.BOUNTY_TASK_COMPLETE:
                  if(msg.length < 2 || this._infectedBounty == null)
                  {
                     return;
                  }
                  if(this._infectedBounty.id == msg.getString(n++))
                  {
                     bTask = this._infectedBounty.getTask(msg.getInt(n++));
                     if(bTask != null)
                     {
                        bTask.complete();
                     }
                  }
                  break;
               case NetworkMessage.BOUNTY_TASK_CONDITION_COMPLETE:
                  if(msg.length < 3 || this._infectedBounty == null)
                  {
                     return;
                  }
                  if(this._infectedBounty.id == msg.getString(n++))
                  {
                     bTask = this._infectedBounty.getTask(msg.getInt(n++));
                     if(bTask != null)
                     {
                        bCond = bTask.getCondition(msg.getInt(n++));
                        if(bCond != null)
                        {
                           bCond.complete();
                        }
                     }
                  }
                  break;
               case NetworkMessage.BOUNTY_UPDATE:
                  if(this._infectedBounty != null)
                  {
                     this._infectedBounty.parseUpdateMessage(msg);
                  }
                  break;
               case NetworkMessage.LINKED_ALLIANCES:
                  this._linkedAlliances = new Array();
                  i = 0;
                  while(true)
                  {
                     if(true)
                     {
                        if(true)
                        {
                           if(i < msg.length)
                           {
                              this._linkedAlliances.push(msg.getString(i));
                              i++;
                           }
                        }
                        continue;
                     }
                  }
            }
         }
         catch(error:Error)
         {
            if(Capabilities.isDebugger)
            {
               _network.client.errorLog.writeError("Error: " + error.name,error.message,error.getStackTrace(),{"player":_network.playerData.id});
               throw error;
            }
         }
      }
      
      private function onInventoryItemRemoved(param1:Item) : void
      {
         this._loadoutManager.removeItem(param1);
      }
      
      private function onEffectChanged(param1:Effect, param2:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Survivor = null;
         if(param1 != null)
         {
            if(param1.getValue(EffectType.getTypeValue("HalloweenTrickTinyZombie")) != 0)
            {
               _loc3_ = 0;
               while(_loc3_ < this._compound.survivors.length)
               {
                  _loc4_ = this._compound.survivors.getSurvivor(_loc3_);
                  if(_loc4_ != null)
                  {
                     _loc4_.actor.defaultScale = (_loc4_.gender == Gender.FEMALE ? 1.22 : 1.25) * 1.15;
                     HumanActor(_loc4_.actor).setAppearance(_loc4_.appearance);
                     HumanActor(_loc4_.actor).applyAppearance();
                  }
                  _loc3_++;
               }
            }
            if(param1.getValue(EffectType.getTypeValue("HalloweenTrickGreenSkin")) != 0)
            {
               _loc3_ = 0;
               while(_loc3_ < this._compound.survivors.length)
               {
                  _loc4_ = this._compound.survivors.getSurvivor(_loc3_);
                  if(_loc4_ != null)
                  {
                     _loc4_.appearance.skin.tint = 7320386;
                     HumanActor(_loc4_.actor).setAppearance(_loc4_.appearance);
                     HumanActor(_loc4_.actor).applyAppearance();
                     _loc4_.updatePortrait();
                  }
                  _loc3_++;
               }
            }
            if(param1.timer != null && param1.item != null)
            {
               this._inventory.removeItem(param1.item);
            }
         }
         this.updateInventoryCap();
         var _loc5_:int = this._compound.getEffectValue(EffectType.getTypeValue("WeaponGearLevelLimit"));
         this.checkAndUpdateLoadouts();
      }
      
      private function onEffectExpired(param1:Effect) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Survivor = null;
         if(param1.getValue(EffectType.getTypeValue("WeaponGearLevelLimit")) != 0)
         {
            this.checkAndUpdateLoadouts();
         }
         if(this._compound.getEffectValue(EffectType.getTypeValue("HalloweenTrickTinyZombie")) == 0)
         {
            _loc2_ = 0;
            while(_loc2_ < this._compound.survivors.length)
            {
               _loc3_ = this._compound.survivors.getSurvivor(_loc2_);
               _loc3_.actor.defaultScale = _loc3_.gender == Gender.FEMALE ? 1.22 : 1.25;
               HumanActor(_loc3_.actor).setAppearance(_loc3_.appearance);
               HumanActor(_loc3_.actor).applyAppearance();
               _loc2_++;
            }
         }
         if(this._compound.getEffectValue(EffectType.getTypeValue("HalloweenTrickGreenSkin")) == 0)
         {
            _loc2_ = 0;
            while(_loc2_ < this._compound.survivors.length)
            {
               _loc3_ = this._compound.survivors.getSurvivor(_loc2_);
               _loc3_.appearance.skin.tint = NaN;
               HumanActor(_loc3_.actor).setAppearance(_loc3_.appearance);
               HumanActor(_loc3_.actor).applyAppearance();
               _loc3_.updatePortrait();
               _loc2_++;
            }
         }
      }
      
      private function onUpgradeFlagChanged(param1:uint, param2:Boolean) : void
      {
         var _loc3_:Building = null;
         switch(param1)
         {
            case PlayerUpgrades.DeathMobileUpgrade:
               _loc3_ = this._compound.buildings.getFirstBuildingOfType("car");
               if(_loc3_ == null)
               {
                  return;
               }
               _loc3_.setLevel(param2 ? 1 : 0);
         }
      }
      
      public function setupRecentPVPList(param1:Object) : void
      {
         this._recentPVPs = param1;
      }
      
      private function updateRecentPVPList(param1:String, param2:Number) : void
      {
         var _loc6_:String = null;
         this._recentPVPs[param1] = param2;
         var _loc3_:String = "";
         var _loc4_:Number = Number.MAX_VALUE;
         var _loc5_:int = 0;
         for(_loc6_ in this._recentPVPs)
         {
            if(this._recentPVPs[_loc6_] < _loc4_)
            {
               _loc3_ = _loc6_;
               _loc4_ = Number(this._recentPVPs[_loc6_]);
            }
            _loc5_++;
         }
         if(_loc5_ > 10)
         {
            delete this._recentPVPs[_loc3_];
         }
      }
      
      public function get batchRecycleJobs() : BatchRecycleJobCollection
      {
         return this._batchRecycleJobs;
      }
      
      public function get compound() : CompoundData
      {
         return this._compound;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get nickname() : String
      {
         return this._nickname;
      }
      
      public function get levelPoints() : uint
      {
         return this._levelPoints;
      }
      
      public function set levelPoints(param1:uint) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         if(param1 == this._levelPoints)
         {
            return;
         }
         this._levelPoints = param1;
         this.levelUpPointsChanged.dispatch();
      }
      
      public function get inventory() : Inventory
      {
         return this._inventory;
      }
      
      public function get missionList() : MissionCollection
      {
         return this._missions;
      }
      
      public function get survivorId() : String
      {
         return this._survivorId;
      }
      
      public function get user() : Object
      {
         return this._user;
      }
      
      public function get questsCompletedStatus() : Vector.<Boolean>
      {
         return this._questsCompletedStatus;
      }
      
      public function get questsCollectedStatus() : Vector.<Boolean>
      {
         return this._questsCollectedStatus;
      }
      
      public function get achievementsStatus() : Vector.<Boolean>
      {
         return this._achievementsStatus;
      }
      
      public function get questsTracked() : Vector.<int>
      {
         return this._questsTracked;
      }
      
      public function get restedXP() : int
      {
         return this._restedXP;
      }
      
      public function get loadoutManager() : SurvivorLoadoutManager
      {
         return this._loadoutManager;
      }
      
      public function get globalQuests() : GlobalQuestData
      {
         return this._globalQuests;
      }
      
      public function get dailyQuest() : DynamicQuest
      {
         return this._dailyQuest;
      }
      
      public function set dailyQuest(param1:DynamicQuest) : void
      {
         this._dailyQuest = param1;
      }
      
      public function get cooldowns() : CooldownCollection
      {
         return this._cooldowns;
      }
      
      public function get oneTimePurchases() : Array
      {
         return this._oneTimePurchases;
      }
      
      public function set oneTimePurchases(param1:Array) : void
      {
         this._oneTimePurchases = param1;
      }
      
      public function get isAdmin() : Boolean
      {
         return this._isAdmin;
      }
      
      public function get flags() : FlagSet
      {
         return this._flags;
      }
      
      public function get upgrades() : FlagSet
      {
         return this._upgrades;
      }
      
      public function get allianceId() : String
      {
         return this._allianceId;
      }
      
      public function set allianceId(param1:String) : void
      {
         if(param1 == this._allianceId)
         {
            return;
         }
         this._allianceId = param1;
      }
      
      public function get allianceTag() : String
      {
         return this._allianceTag;
      }
      
      public function set allianceTag(param1:String) : void
      {
         if(param1 == this._allianceTag)
         {
            return;
         }
         this._allianceTag = param1;
      }
      
      public function get uncollectedWinnings() : Boolean
      {
         return this._uncollectedWinnings;
      }
      
      public function set uncollectedWinnings(param1:Boolean) : void
      {
         var _loc2_:* = this._uncollectedWinnings != param1;
         this._uncollectedWinnings = param1;
         if(_loc2_)
         {
            this.uncollectedWinningsChanged.dispatch();
         }
      }
      
      public function get lastLogout() : Date
      {
         return this._lastLogout;
      }
      
      public function get recentPVPs() : Object
      {
         return this._recentPVPs;
      }
      
      public function get infectedBounty() : InfectedBounty
      {
         return this._infectedBounty;
      }
      
      public function set infectedBounty(param1:InfectedBounty) : void
      {
         if(param1 == this._infectedBounty)
         {
            return;
         }
         this._infectedBounty = param1;
         this.infectedBountyReceived.dispatch(this._infectedBounty);
      }
      
      public function get assignments() : AssignmentCollection
      {
         return this._assignments;
      }
      
      public function get inventoryBaseSize() : int
      {
         return this._inventoryBaseMaxSize;
      }
      
      public function get linkedAlliances() : Array
      {
         return this._linkedAlliances;
      }
      
      public function get researchState() : ResearchState
      {
         return this._researchState;
      }
      
      public function get nextInfectedBountyIssueTime() : Date
      {
         return this._nextDZBountyIssue;
      }
      
      public function set nextInfectedBountyIssueTime(param1:Date) : void
      {
         this._nextDZBountyIssue = param1;
      }
      
      public function get timeUntilNextInfectedBounty() : Number
      {
         var _loc1_:Date = new Date();
         var _loc2_:Number = this._nextDZBountyIssue.time - _loc1_.time;
         return Math.max(_loc2_ / 1000,0);
      }
      
      public function get skills() : SkillCollection
      {
         return this._skills;
      }
   }
}

