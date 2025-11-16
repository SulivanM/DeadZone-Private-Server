package thelaststand.app.game.data
{
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import playerio.PlayerIOError;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.game.Tutorial;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.data.research.ResearchEffect;
   import thelaststand.app.game.entities.EntityFlags;
   import thelaststand.app.game.entities.actions.ResourceBuildingAction;
   import thelaststand.app.game.entities.actions.SmokeEmissionAction;
   import thelaststand.app.game.entities.actions.WindmillAction;
   import thelaststand.app.game.entities.buildings.BuildingEntity;
   import thelaststand.app.game.entities.buildings.BuildingEntityFactory;
   import thelaststand.app.game.logic.TimerManager;
   import thelaststand.app.game.logic.ai.AIAgent;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.io.ISerializable;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.map.Cell;
   import thelaststand.engine.map.CellFlag;
   import thelaststand.engine.map.NavEdge;
   import thelaststand.engine.map.NavEdgeFlag;
   import thelaststand.engine.map.TraversalArea;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   
   public class Building extends AIAgent implements IRecyclable, ISerializable
   {
      
      private var _id:String;
      
      private var _type:String;
      
      private var _assetURI:String;
      
      private var _assetDamagedURI:String;
      
      private var _comfort:int;
      
      private var _assignable:Boolean;
      
      private var _connectable:Boolean;
      
      private var _assignedSurvivors:Vector.<Survivor>;
      
      private var _assignedChanged:Boolean = false;
      
      private var _isDoor:Boolean = false;
      
      private var _isTrap:Boolean = false;
      
      private var _isDecoyTrap:Boolean = false;
      
      private var _isExplosive:Boolean = false;
      
      private var _doorwayOnly:Boolean = false;
      
      private var _buildingEntity:BuildingEntity;
      
      private var _level:int = -1;
      
      private var _maxLevel:int;
      
      private var _craftingCategories:Vector.<String>;
      
      private var _productionResource:String;
      
      private var _productionRate:Number;
      
      private var _security:int;
      
      private var _storageResource:String;
      
      private var _resourceCapacity:int = 0;
      
      private var _resourceValue:Number = 0;
      
      private var _scavengeTime:Number = 0;
      
      private var _minScavengeTime:Number = 0;
      
      private var _scavengable:Boolean = false;
      
      private var _forceScavengable:Boolean = false;
      
      private var _rotation:int;
      
      private var _upgradeTimer:TimerData;
      
      private var _purchaseOnly:Boolean;
      
      private var _notPurchasable:Boolean;
      
      private var _repairTimer:TimerData;
      
      private var _tasks:Vector.<Task>;
      
      private var _xml:XML;
      
      private var _disarmTime:Number = 0;
      
      private var _disarmChance:Number = 0;
      
      private var _detectRangeMod:Number = 0;
      
      private var _trapDamageModifier:Number = 0;
      
      private var _doorPos:Point;
      
      private var _mountedSurvivor:Survivor;
      
      private var _customName:String;
      
      private var _destroyable:Boolean;
      
      private var _traversalArea:TraversalArea;
      
      private var _missionBuilding:Boolean;
      
      private var _coverRatingModifier:Number = 0;
      
      public var tileX:int;
      
      public var tileY:int;
      
      public var upgradeStarted:Signal;
      
      public var repairStarted:Signal;
      
      public var repairCompleted:Signal;
      
      public var recycled:Signal;
      
      public var resourcesCollected:Signal;
      
      public var resourceValueChanged:Signal;
      
      public var entityClicked:Signal;
      
      public var assignmentChanged:Signal;
      
      private var _researchEffectMods:Object = {};
      
      public function Building(param1:XML = null, param2:int = 0, param3:Boolean = false)
      {
         super();
         this.entityClicked = new Signal(Building);
         this.upgradeStarted = new Signal(Building,Boolean);
         this.repairStarted = new Signal(Building,Boolean);
         this.repairCompleted = new Signal(Building);
         this.recycled = new Signal(Building);
         this.resourcesCollected = new Signal(Building,Number);
         this.resourceValueChanged = new Signal(Building);
         this.assignmentChanged = new Signal(Building,Survivor,int);
         this._tasks = new Vector.<Task>();
         this._assignedSurvivors = new Vector.<Survivor>();
         this._missionBuilding = param3;
         agentData.canBeSuppressed = true;
         this._id = GUID.create().toUpperCase();
         if(param1)
         {
            this.setXML(param1);
            this.setLevel(param2);
         }
      }
      
      public static function getBuildingXML(param1:String) : XML
      {
         var buildingType:String = param1;
         return ResourceManager.getInstance().getResource("xml/buildings.xml").content.item.(@id == buildingType)[0];
      }
      
      public static function getMinNumOfBuilding(param1:String) : int
      {
         var _loc2_:XML = getBuildingXML(param1);
         return _loc2_.hasOwnProperty("@min") ? int(_loc2_.@min.toString()) : 0;
      }
      
      public static function getMaxNumOfBuilding(param1:String) : int
      {
         var _loc2_:XML = getBuildingXML(param1);
         return _loc2_.hasOwnProperty("@max") ? int(_loc2_.@max.toString()) : 0;
      }
      
      public static function getBuildingMaxLevel(param1:String) : int
      {
         var xml:XML = null;
         var c:int = 0;
         var lvlNode:XML = null;
         var level:int = 0;
         var buildingType:String = param1;
         xml = ResourceManager.getInstance().getResource("xml/buildings.xml").content.item.(@id == buildingType)[0];
         if(xml == null)
         {
            return 0;
         }
         c = 0;
         for each(lvlNode in xml.lvl)
         {
            level = int(lvlNode.@n.toString());
            if(level > c)
            {
               c = level;
            }
         }
         return c;
      }
      
      public static function getBuildingXP(param1:String, param2:int) : int
      {
         var xml:XML = null;
         var lvlNode:XML = null;
         var buildingType:String = param1;
         var level:int = param2;
         xml = ResourceManager.getInstance().getResource("xml/buildings.xml").content.item.(@id == buildingType)[0];
         if(xml == null)
         {
            return 0;
         }
         lvlNode = xml.lvl.(@n == level.toString())[0];
         if(lvlNode == null)
         {
            return 0;
         }
         return int(lvlNode.xp.toString());
      }
      
      public static function getBuildingUpgradeFuelCost(param1:String, param2:int) : int
      {
         var xml:XML = null;
         var lvlNode:XML = null;
         var costResource:Dictionary = null;
         var totalResCost:int = 0;
         var resType:String = null;
         var buildTime:int = 0;
         var constructionCosts:Object = null;
         var cost:int = 0;
         var buildingType:String = param1;
         var level:int = param2;
         xml = ResourceManager.getInstance().getResource("xml/buildings.xml").content.item.(@id == buildingType)[0];
         if(xml == null)
         {
            return 0;
         }
         lvlNode = xml.lvl.(@n == level.toString())[0];
         if(lvlNode == null)
         {
            return 0;
         }
         if(xml.@purchase == "1")
         {
            return int(lvlNode.cost.toString());
         }
         costResource = new Dictionary(true);
         getBuildingUpgradeResourceItemCost(buildingType,level,costResource);
         totalResCost = 0;
         for(resType in costResource)
         {
            totalResCost += Math.floor(costResource[resType]);
         }
         buildTime = int(lvlNode.time.toString());
         constructionCosts = Network.getInstance().data.costTable.getItemByKey("constructionCosts");
         cost = Math.floor(totalResCost * Number(constructionCosts.coinsPerResUnit) + buildTime * Number(constructionCosts.coinsPerSecond));
         return Math.max(cost,1);
      }
      
      public static function getBuildingUpgradeResourceItemCost(param1:String, param2:int, param3:Dictionary = null, param4:Dictionary = null) : void
      {
         var xml:XML = null;
         var lvlNode:XML = null;
         var resNode:XML = null;
         var multiplier:Number = NaN;
         var n:XML = null;
         var type:String = null;
         var cost:Number = NaN;
         var i:int = 0;
         var totalCost:Number = NaN;
         var itemType:String = null;
         var buildingType:String = param1;
         var level:int = param2;
         var out_resourceCost:Dictionary = param3;
         var out_itemCost:Dictionary = param4;
         xml = ResourceManager.getInstance().getResource("xml/buildings.xml").content.item.(@id == buildingType)[0];
         if(!xml)
         {
            Network.getInstance().client.errorLog.writeError("Building type definition does not exist",buildingType,null,{"type":buildingType},null,null);
            return;
         }
         lvlNode = xml.lvl.(@n == level.toString())[0];
         if(!lvlNode)
         {
            Network.getInstance().client.errorLog.writeError("Building level definition does not exist",buildingType,null,{
               "type":buildingType,
               "level":level
            },null,null);
            return;
         }
         if(out_resourceCost != null)
         {
            resNode = xml.res[0];
            if(resNode != null)
            {
               multiplier = "@m" in resNode ? Number(resNode.@m.toString()) : 1;
               for each(n in resNode.res)
               {
                  type = n.@id.toString();
                  cost = Number(n.toString());
                  i = 0;
                  while(i < level)
                  {
                     cost = Math.floor(cost * multiplier);
                     i++;
                  }
                  totalCost = type in out_resourceCost ? Number(out_resourceCost[type]) : 0;
                  out_resourceCost[type] = Math.floor(totalCost + Math.floor(cost / 5) * 5);
               }
            }
            for each(n in lvlNode.req.res)
            {
               type = n.@id.toString();
               cost = int(n.toString());
               if(cost == 0)
               {
                  delete out_resourceCost[type];
               }
               else
               {
                  out_resourceCost[type] = cost;
               }
            }
         }
         if(out_itemCost != null)
         {
            for each(n in lvlNode.req.itm)
            {
               itemType = n.@id.toString();
               out_itemCost[itemType] = int(n.toString());
            }
         }
      }
      
      public static function getBuildingRepairResourceItemCost(param1:String, param2:int, param3:Dictionary = null, param4:Dictionary = null) : void
      {
         var resType:String = null;
         var cost:Number = NaN;
         var costEffect:Number = NaN;
         var lvlXML:XML = null;
         var n:XML = null;
         var type:String = null;
         var totalCost:Number = NaN;
         var buildingType:String = param1;
         var level:int = param2;
         var out_resourceCost:Dictionary = param3;
         var out_itemCost:Dictionary = param4;
         costEffect = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("RepairCost")) / 100;
         lvlXML = getBuildingXML(buildingType).lvl.(@n == level.toString())[0];
         if(lvlXML.hasOwnProperty("repair"))
         {
            if(lvlXML.repair.@req == "1")
            {
               getBuildingUpgradeResourceItemCost(buildingType,level,out_resourceCost,out_itemCost);
               return;
            }
            if(out_resourceCost != null)
            {
               for each(n in lvlXML.repair.res)
               {
                  type = n.@id.toString();
                  totalCost = type in out_resourceCost ? Number(out_resourceCost[type]) : 0;
                  out_resourceCost[type] = totalCost + Number(n.toString());
               }
            }
            if(out_itemCost != null)
            {
               for each(n in lvlXML.repair.itm)
               {
                  type = n.@id.toString();
                  totalCost = type in out_itemCost ? Number(out_itemCost[type]) : 0;
                  out_itemCost[type] = totalCost + Number(n.toString());
               }
            }
         }
         else
         {
            getBuildingUpgradeResourceItemCost(buildingType,level,out_resourceCost,out_itemCost);
            if(out_resourceCost != null)
            {
               for(resType in out_resourceCost)
               {
                  cost = Math.floor(Number(out_resourceCost[resType]) * Config.constant.REPAIR_COST_MULTIPLIER);
                  out_resourceCost[resType] = cost;
               }
            }
         }
         if(out_resourceCost != null)
         {
            for(resType in out_resourceCost)
            {
               cost = Math.floor(out_resourceCost[resType]);
               out_resourceCost[resType] = Math.floor(cost + cost * costEffect);
            }
         }
      }
      
      public static function getBuildingRepairFuelCost(param1:String, param2:int) : uint
      {
         var lvlXML:XML = null;
         var costResource:Dictionary = null;
         var totalResCost:int = 0;
         var resType:String = null;
         var buildTime:int = 0;
         var constructionCosts:Object = null;
         var cost:int = 0;
         var strCost:String = null;
         var buildingType:String = param1;
         var level:int = param2;
         lvlXML = getBuildingXML(buildingType).lvl.(@n == level.toString())[0];
         if(lvlXML.hasOwnProperty("repair"))
         {
            if("@cost" in lvlXML.repair)
            {
               strCost = lvlXML.repair.@cost.toString();
               if(strCost == "buy")
               {
                  return getBuildingUpgradeFuelCost(buildingType,level);
               }
               return int(strCost);
            }
         }
         costResource = new Dictionary(true);
         getBuildingRepairResourceItemCost(buildingType,level,costResource);
         totalResCost = 0;
         for(resType in costResource)
         {
            totalResCost += Math.floor(costResource[resType]);
         }
         buildTime = getBuildingRepairTime(buildingType,level);
         constructionCosts = Network.getInstance().data.costTable.getItemByKey("constructionCosts");
         cost = Math.floor(totalResCost * Number(constructionCosts.coinsPerResUnit) + buildTime * Number(constructionCosts.coinsPerSecond));
         return Math.max(cost,1);
      }
      
      public static function getBuildingRepairTime(param1:String, param2:int) : int
      {
         var time:Number = NaN;
         var repairEffect:Number = NaN;
         var lvlXML:XML = null;
         var timePerLevel:int = 0;
         var round:int = 0;
         var repairNode:XML = null;
         var buildingType:String = param1;
         var level:int = param2;
         time = 0;
         repairEffect = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("RepairTime")) / 100;
         lvlXML = getBuildingXML(buildingType).lvl.(@n == level.toString())[0];
         if(lvlXML != null && Boolean(lvlXML.hasOwnProperty("repair")))
         {
            repairNode = lvlXML.repair[0];
            if("@time" in repairNode)
            {
               time = int(repairNode.@time.toString());
               return Math.floor(time + time * repairEffect);
            }
         }
         timePerLevel = level * Config.constant.REPAIR_TIME_PER_LEVEL;
         round = int(Config.constant.REPAIR_TIME_ROUND);
         time = Math.floor(timePerLevel + timePerLevel * repairEffect);
         return int(Math.max(1,Math.floor(time / round)) * round);
      }
      
      public static function isWithinCompoundBounds(param1:int, param2:int) : Boolean
      {
         var _loc3_:XML = XML(ResourceManager.getInstance().get("xml/scenes/compound.xml"));
         var _loc4_:int = int(_loc3_.map.@width);
         var _loc5_:int = int(_loc3_.map.@height);
         return param1 >= 0 && param1 < _loc4_ && (param2 >= 0 && param2 < _loc5_);
      }
      
      public static function getResourceCapacity(param1:Building) : Number
      {
         var _loc4_:Number = NaN;
         var _loc2_:Number = param1._resourceCapacity;
         var _loc3_:CompoundData = Network.getInstance().playerData.compound;
         if(param1._productionResource != null)
         {
            _loc4_ = 0;
            switch(param1._productionResource)
            {
               case GameResources.FOOD:
               case GameResources.WATER:
                  _loc4_ += _loc3_.player.researchState.getEffectValue(ResearchEffect.FoodWaterProductionCapacity);
                  break;
               case GameResources.AMMUNITION:
                  _loc4_ += _loc3_.player.researchState.getEffectValue(ResearchEffect.AmmoProductionCapacity);
                  break;
               case GameResources.WOOD:
               case GameResources.METAL:
               case GameResources.CLOTH:
                  _loc4_ += _loc3_.player.researchState.getEffectValue(ResearchEffect.BuildingMaterialProductionCapacity);
                  break;
               case GameResources.CASH:
                  _loc4_ += _loc3_.player.researchState.getEffectValue(ResearchEffect.FuelProductionCapacity);
            }
            return _loc2_ + _loc2_ * _loc4_;
         }
         if(param1._storageResource != null)
         {
            _loc4_ = 0;
            switch(param1._storageResource)
            {
               case GameResources.FOOD:
               case GameResources.WATER:
                  _loc4_ += _loc3_.player.researchState.getEffectValue(ResearchEffect.FoodWaterStorageCapacity);
                  break;
               case GameResources.AMMUNITION:
                  _loc4_ += _loc3_.player.researchState.getEffectValue(ResearchEffect.AmmoStorageCapacity);
                  break;
               case GameResources.WOOD:
               case GameResources.METAL:
               case GameResources.CLOTH:
                  _loc4_ += _loc3_.player.researchState.getEffectValue(ResearchEffect.BuildingMaterialStorageCapacity);
            }
            return _loc2_ + _loc2_ * _loc4_;
         }
         return _loc2_;
      }
      
      public static function getProductionRate(param1:Building) : Number
      {
         var _loc4_:Number = NaN;
         var _loc5_:uint = 0;
         var _loc2_:Number = param1._productionRate;
         var _loc3_:CompoundData = Network.getInstance().playerData.compound;
         if(param1._productionResource != null)
         {
            _loc4_ = 0;
            if(param1._productionResource == GameResources.CASH)
            {
               _loc4_ += _loc3_.getEffectValue(EffectType.getTypeValue("FuelProduction")) / 100;
            }
            else
            {
               _loc5_ = uint(EffectType.getResourceProductionTypeValue(param1._productionResource));
               _loc4_ += _loc3_.getEffectValue(EffectType.getTypeValue("ResourceProduction")) / 100;
               _loc4_ = _loc4_ + _loc3_.getEffectValue(_loc5_) / 100;
            }
            switch(param1._productionResource)
            {
               case GameResources.FOOD:
               case GameResources.WATER:
                  _loc4_ += _loc3_.player.researchState.getEffectValue(ResearchEffect.FoodWaterProductionRate);
                  break;
               case GameResources.AMMUNITION:
                  _loc4_ += _loc3_.player.researchState.getEffectValue(ResearchEffect.AmmoProductionRate);
                  break;
               case GameResources.WOOD:
               case GameResources.METAL:
               case GameResources.CLOTH:
                  _loc4_ += _loc3_.player.researchState.getEffectValue(ResearchEffect.BuildingMaterialProductionRate);
                  break;
               case GameResources.CASH:
                  _loc4_ += _loc3_.player.researchState.getEffectValue(ResearchEffect.FuelProductionRate);
            }
            return _loc2_ + _loc2_ * _loc4_;
         }
         return _loc2_;
      }
      
      public function assignSurvivor(param1:Survivor, param2:int) : void
      {
         var _loc3_:Survivor = null;
         var _loc4_:int = 0;
         if(!this._assignable)
         {
            return;
         }
         if(param2 < 0 || param2 >= this.numAssignableSurvivors)
         {
            return;
         }
         if(param1 == null)
         {
            _loc3_ = this._assignedSurvivors[param2];
            if(_loc3_ != null)
            {
               _loc3_.rallyAssignment = null;
               _loc3_.loadoutOffence.changed.remove(this.onAssignedSurvivorLoadoutChanged);
            }
         }
         else
         {
            _loc4_ = int(this._assignedSurvivors.indexOf(param1));
            if(_loc4_ == param2)
            {
               return;
            }
            if(_loc4_ > -1)
            {
               this._assignedSurvivors[_loc4_] = null;
               this.assignmentChanged.dispatch(this,null,_loc4_);
            }
            if(param1.rallyAssignment != null && param1.rallyAssignment != this)
            {
               param1.rallyAssignment.unassignSurvivor(param1);
            }
            param1.rallyAssignment = this;
            param1.loadoutOffence.changed.add(this.onAssignedSurvivorLoadoutChanged);
         }
         this._assignedChanged = true;
         this._assignedSurvivors[param2] = param1;
         this._buildingEntity.showAssignFlags();
         this.assignmentChanged.dispatch(this,param1,param2);
      }
      
      public function unassignSurvivor(param1:Survivor) : void
      {
         var _loc2_:int = int(this._assignedSurvivors.indexOf(param1));
         if(_loc2_ <= -1)
         {
            return;
         }
         this._assignedChanged = true;
         this._assignedSurvivors[_loc2_] = null;
         this._buildingEntity.showAssignFlags();
         param1.rallyAssignment = null;
         this.assignmentChanged.dispatch(this,null,_loc2_);
      }
      
      public function clearAssignedSurvivors() : void
      {
         var _loc2_:Survivor = null;
         if(!this._assignable)
         {
            return;
         }
         var _loc1_:int = 0;
         while(_loc1_ < this._assignedSurvivors.length)
         {
            _loc2_ = this._assignedSurvivors[_loc1_];
            if(_loc2_ != null)
            {
               _loc2_.rallyAssignment = null;
            }
            this._assignedSurvivors[_loc1_] = null;
            _loc1_++;
         }
         this._assignedChanged = true;
         this.assignmentChanged.dispatch(this,null,-1);
      }
      
      public function getAttackRanges() : Object
      {
         var _loc7_:Survivor = null;
         var _loc8_:WeaponData = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc1_:XML = this.getLevelXML();
         var _loc2_:Number = 0;
         var _loc3_:Number = 0;
         var _loc4_:Number = 0;
         var _loc5_:Number = _loc1_.hasOwnProperty("rng_max") ? Number(_loc1_.rng_max) : 0;
         var _loc6_:Number = _loc1_.hasOwnProperty("rng_min") ? Number(_loc1_.rng_min) : 0;
         for each(_loc7_ in this._assignedSurvivors)
         {
            if(_loc7_ != null)
            {
               _loc8_ = new WeaponData();
               _loc8_.populate(_loc7_,_loc7_.loadoutDefence.weapon.item as Weapon,_loc7_.loadoutDefence.type);
               if(_loc8_.isMelee && this._doorPos != null)
               {
                  _loc8_.setRangeModifiers(0,-int.MAX_VALUE);
               }
               else
               {
                  _loc8_.setRangeModifiers(_loc6_,_loc5_);
               }
               _loc9_ = _loc8_.range;
               if(_loc9_ > _loc2_)
               {
                  _loc2_ = _loc9_;
               }
               _loc10_ = _loc8_.minRange;
               if(_loc10_ > _loc3_)
               {
                  _loc3_ = _loc10_;
               }
               _loc11_ = _loc8_.minEffectiveRange;
               if(_loc11_ > _loc4_)
               {
                  _loc4_ = _loc11_;
               }
            }
         }
         return {
            "minEffective":_loc4_,
            "min":_loc3_,
            "max":_loc2_
         };
      }
      
      public function canBuildIndoors() : Boolean
      {
         return this._xml != null ? this._xml.@indoor.toString() == "1" : true;
      }
      
      public function canBuildOutdoors() : Boolean
      {
         return this._xml != null ? this._xml.@outdoor.toString() == "1" : true;
      }
      
      override public function dispose() : void
      {
         var _loc1_:Survivor = null;
         super.dispose();
         this._xml = null;
         this._assetURI = null;
         this._assetDamagedURI = null;
         this.tileX = this.tileY = 0;
         this._buildingEntity.dispose();
         this._buildingEntity = null;
         this._tasks.length = 0;
         this._tasks = null;
         if(this._upgradeTimer != null)
         {
            TimerManager.getInstance().removeTimer(this._upgradeTimer);
            this._upgradeTimer.dispose();
            this._upgradeTimer = null;
         }
         if(this._repairTimer != null)
         {
            TimerManager.getInstance().removeTimer(this._repairTimer);
            this._repairTimer.dispose();
            this._repairTimer = null;
         }
         for each(_loc1_ in this._assignedSurvivors)
         {
            if(_loc1_ != null)
            {
               _loc1_.rallyAssignment = null;
               _loc1_.loadoutOffence.changed.remove(this.onAssignedSurvivorLoadoutChanged);
            }
         }
         this._assignedSurvivors = null;
         this._mountedSurvivor = null;
         this.upgradeStarted.removeAll();
         this.repairStarted.removeAll();
         this.repairCompleted.removeAll();
         this.entityClicked.removeAll();
         this.resourcesCollected.removeAll();
         this.resourceValueChanged.removeAll();
         this.recycled.removeAll();
         this.assignmentChanged.removeAll();
      }
      
      override public function die(param1:Object) : Boolean
      {
         if(super.die(param1))
         {
            handleMarkedForDeath();
            return true;
         }
         return false;
      }
      
      override protected function onDie(param1:Object) : void
      {
         var _loc2_:String = null;
         this.setDestroyedState(true);
         if(this._buildingEntity.scene != null)
         {
            if(!this._isTrap && !this._isDecoyTrap)
            {
               _loc2_ = this.getSound("death");
               if(_loc2_ == null)
               {
                  _loc2_ = Math.random() < 0.5 ? "sound/buildings/building-break1.mp3" : "sound/buildings/building-break2.mp3";
               }
            }
            soundSource.play(_loc2_);
         }
         stateMachine.clear();
         super.onDie(param1);
      }
      
      public function getName() : String
      {
         return this._customName || Language.getInstance().getString("blds." + this.type);
      }
      
      public function setName(param1:String) : void
      {
         this._customName = param1;
      }
      
      public function getUpgradeName() : String
      {
         if(this._upgradeTimer == null)
         {
            return this.getName();
         }
         return Language.getInstance().getString("blds." + this.type) + " " + Language.getInstance().getString("level",int(this._upgradeTimer.data.level) + 1);
      }
      
      public function getRecycleItems() : Vector.<Item>
      {
         var _loc2_:Dictionary = null;
         var _loc3_:String = null;
         var _loc4_:Item = null;
         var _loc1_:Vector.<Item> = new Vector.<Item>();
         if(this._xml != null)
         {
            _loc2_ = new Dictionary(true);
            Building.getBuildingUpgradeResourceItemCost(this._type,this._level,_loc2_);
            for(_loc3_ in _loc2_)
            {
               _loc4_ = ItemFactory.createItemFromTypeId(_loc3_);
               if(_loc4_ != null)
               {
                  if(_loc4_.quantifiable)
                  {
                     _loc4_.quantity = Math.floor(_loc2_[_loc3_] * 0.5);
                  }
                  _loc1_.push(_loc4_);
               }
            }
         }
         return _loc1_;
      }
      
      public function isUnderConstruction() : Boolean
      {
         return this._upgradeTimer != null && !this._upgradeTimer.hasEnded() && this._upgradeTimer.data.level == 0;
      }
      
      public function construct(param1:Boolean, param2:Function) : void
      {
         var self:Building = null;
         var network:Network = null;
         var lvlDef:XML = null;
         var msg:Object = null;
         var cost:uint = 0;
         var buy:Boolean = param1;
         var completeCallback:Function = param2;
         self = this;
         network = Network.getInstance();
         lvlDef = this._xml.lvl.(@n == "0")[0];
         if(!lvlDef)
         {
            Network.getInstance().client.errorLog.writeError("Building level definition does not exist",this.type + ", lvl " + this.level,null,null,null,null);
            completeCallback(false);
            return;
         }
         if(buy && !this.isBuyable)
         {
            completeCallback(false);
            return;
         }
         msg = {
            "id":this._id,
            "type":this._type,
            "tx":this.tileX,
            "ty":this.tileY,
            "rotation":this._rotation
         };
         if(buy)
         {
            cost = uint(Building.getBuildingUpgradeFuelCost(this.type,0));
            if(network.playerData.compound.resources.getAmount(GameResources.CASH) < cost)
            {
               PaymentSystem.getInstance().openBuyCoinsScreen();
               return;
            }
            network.startAsyncOp();
            network.save(msg,SaveDataMethod.BUILDING_CREATE_BUY,function(param1:Object):void
            {
               network.completeAsyncOp();
               if(param1 == null || param1.success !== true)
               {
                  completeCallback(false);
                  return;
               }
               if("levelPts" in param1)
               {
                  network.playerData.levelPoints = int(param1.levelPts);
               }
               Tracking.trackEvent("Player","BuildingConstructed_buy",type);
               Tracking.trackEvent("Player","BuildingConstructed_buy_playerLvl_" + network.playerData.getPlayerSurvivor().level,type);
               completeCallback(true);
               upgradeStarted.dispatch(self,true);
            });
         }
         else
         {
            network.startAsyncOp();
            network.save(msg,SaveDataMethod.BUILDING_CREATE,function(param1:Object):void
            {
               network.completeAsyncOp();
               if(param1 == null || param1.success !== true)
               {
                  completeCallback(false);
                  return;
               }
               if(param1.items != null)
               {
                  network.playerData.inventory.updateQuantities(param1.items);
               }
               _upgradeTimer = new TimerData(null,0,self);
               _upgradeTimer.readObject(param1.timer);
               _upgradeTimer.data.type = "upgrade";
               _upgradeTimer.data.xp = int(lvlDef.xp[0]);
               _upgradeTimer.cancelled.addOnce(onUpgradeCancelled);
               _upgradeTimer.completed.addOnce(onUpgradeComplete);
               TimerManager.getInstance().addTimer(_upgradeTimer);
               Tracking.trackEvent("Player","BuildingConstructed",type);
               Tracking.trackEvent("Player","BuildingConstructed_playerLvl_" + network.playerData.getPlayerSurvivor().level,type);
               completeCallback(true);
               upgradeStarted.dispatch(self,false);
            });
         }
      }
      
      public function repair(param1:Boolean = false) : void
      {
         var self:Building = null;
         var network:Network = null;
         var cost:uint = 0;
         var time:int = 0;
         var buy:Boolean = param1;
         self = this;
         network = Network.getInstance();
         if(this._repairTimer != null)
         {
            return;
         }
         if(buy)
         {
            cost = Building.getBuildingRepairFuelCost(this.type,this.level);
            if(network.playerData.compound.resources.getAmount(GameResources.CASH) < cost)
            {
               PaymentSystem.getInstance().openBuyCoinsScreen();
               return;
            }
            network.startAsyncOp();
            network.save({
               "id":this._id,
               "level":this.level
            },SaveDataMethod.BUILDING_REPAIR_BUY,function(param1:Object):void
            {
               network.completeAsyncOp();
               if(param1 == null || param1.success !== true)
               {
                  return;
               }
               health = maxHealth;
               Tracking.trackEvent("Player","BuildingRepaired_buy",type + "_" + level,level);
               repairStarted.dispatch(self,true);
               repairCompleted.dispatch(self);
            });
         }
         else
         {
            time = Building.getBuildingRepairTime(this.type,this.level);
            network.startAsyncOp();
            network.save({"id":this._id},SaveDataMethod.BUILDING_REPAIR,function(param1:Object):void
            {
               var _loc3_:String = null;
               network.completeAsyncOp();
               if(param1 == null || param1.success !== true)
               {
                  return;
               }
               if(param1.items != null)
               {
                  network.playerData.inventory.updateQuantities(param1.items);
               }
               _repairTimer = new TimerData(null,0,self);
               _repairTimer.readObject(param1.timer);
               _repairTimer.data.type = "repair";
               _repairTimer.completed.addOnce(onRepairComplete);
               TimerManager.getInstance().addTimer(_repairTimer);
               repairStarted.dispatch(self,false);
               Tracking.trackEvent("Player","BuildingRepaired",type + "_" + level,level);
               var _loc2_:Dictionary = new Dictionary();
               Building.getBuildingRepairResourceItemCost(type,level,_loc2_,null);
               for(_loc3_ in _loc2_)
               {
                  Tracking.trackEvent("Player","BuildingRepairedResources",_loc3_,Number(_loc2_[_loc3_]));
               }
            });
         }
      }
      
      public function upgrade(param1:Boolean = false) : void
      {
         var self:Building = null;
         var network:Network = null;
         var upgradeLevel:int = 0;
         var lvlDef:XML = null;
         var cost:uint = 0;
         var buy:Boolean = param1;
         self = this;
         network = Network.getInstance();
         upgradeLevel = this.level + 1;
         lvlDef = this._xml.lvl.(@n == upgradeLevel)[0];
         if(!lvlDef)
         {
            Network.getInstance().client.errorLog.writeError("Building level definition does not exist",this.type + ", lvl " + this.level,null,null,null,null);
            return;
         }
         if(this._upgradeTimer != null)
         {
            return;
         }
         if(buy)
         {
            cost = uint(Building.getBuildingUpgradeFuelCost(this.type,upgradeLevel));
            if(network.playerData.compound.resources.getAmount(GameResources.CASH) < cost)
            {
               PaymentSystem.getInstance().openBuyCoinsScreen();
               return;
            }
            network.startAsyncOp();
            network.save({"id":this._id},SaveDataMethod.BUILDING_UPGRADE_BUY,function(param1:Object):void
            {
               network.completeAsyncOp();
               if(param1 == null || param1.success !== true)
               {
                  return;
               }
               setLevel(int(param1.level));
               if("levelPts" in param1)
               {
                  network.playerData.levelPoints = int(param1.levelPts);
               }
               upgradeStarted.dispatch(self,true);
               Tracking.trackEvent("Player","BuildingUpgraded_buy",type + "_" + level,level);
               Tracking.trackEvent("Player","BuildingUpgraded_buy_playerLvl_" + network.playerData.getPlayerSurvivor().level,type + "_" + level,level);
            });
         }
         else
         {
            network.startAsyncOp();
            network.save({"id":this._id},SaveDataMethod.BUILDING_UPGRADE,function(param1:Object):void
            {
               network.completeAsyncOp();
               if(param1 == null || param1.success !== true)
               {
                  return;
               }
               if(param1.items != null)
               {
                  network.playerData.inventory.updateQuantities(param1.items);
               }
               _upgradeTimer = new TimerData(null,0,self);
               _upgradeTimer.readObject(param1.timer);
               _upgradeTimer.data.type = "upgrade";
               _upgradeTimer.data.xp = int(param1.xp);
               _upgradeTimer.cancelled.addOnce(onUpgradeCancelled);
               _upgradeTimer.completed.addOnce(onUpgradeComplete);
               TimerManager.getInstance().addTimer(_upgradeTimer);
               upgradeStarted.dispatch(self,false);
               Tracking.trackEvent("Player","BuildingUpgraded",type + "_" + level,level);
               Tracking.trackEvent("Player","BuildingUpgraded_playerLvl_" + network.playerData.getPlayerSurvivor().level,type + "_" + level,level);
            });
         }
      }
      
      public function cancelUpgrade() : void
      {
         var lang:Language;
         var underConstruction:Boolean;
         var msgId:String;
         var msg:MessageBox;
         if(this._upgradeTimer == null)
         {
            return;
         }
         lang = Language.getInstance();
         underConstruction = this.isUnderConstruction();
         msgId = underConstruction ? "bld_control_cancel_construct_" : "bld_control_cancel_upgrade_";
         msg = new MessageBox(lang.getString(msgId + "msg"));
         msg.addTitle(lang.getString(msgId + "title"));
         msg.addButton(lang.getString(msgId + "ok")).clicked.addOnce(function(param1:MouseEvent):void
         {
            var network:Network = null;
            var e:MouseEvent = param1;
            if(_upgradeTimer == null)
            {
               return;
            }
            network = Network.getInstance();
            network.startAsyncOp();
            network.save({"id":_id},SaveDataMethod.BUILDING_CANCEL,function(param1:Object):void
            {
               var _loc2_:int = 0;
               var _loc3_:Object = null;
               var _loc4_:Item = null;
               var _loc5_:Item = null;
               network.completeAsyncOp();
               if(param1 == null || param1.success !== true)
               {
                  return;
               }
               if(param1.items != null)
               {
                  _loc2_ = 0;
                  while(_loc2_ < param1.items.length)
                  {
                     _loc3_ = param1.items[_loc2_];
                     _loc4_ = network.playerData.inventory.getItemById(_loc3_.id);
                     if(_loc4_ != null)
                     {
                        _loc4_.readObject(_loc3_);
                        _loc4_.isNew = _loc4_.isNew || Boolean(_loc3_["new"]);
                        network.playerData.inventory.itemAdded.dispatch(_loc4_);
                     }
                     else
                     {
                        _loc5_ = ItemFactory.createItemFromObject(_loc3_);
                        network.playerData.giveItem(_loc5_);
                     }
                     _loc2_++;
                  }
               }
               TimerManager.getInstance().cancelTimer(_upgradeTimer).dispose();
            });
         });
         msg.addButton(lang.getString(msgId + "cancel"));
         msg.open();
      }
      
      public function speedUpUpgrade(param1:Object, param2:Function = null) : void
      {
         var speedUpCost:int;
         var cash:int;
         var network:Network = null;
         var option:Object = param1;
         var onComplete:Function = param2;
         if(this._upgradeTimer == null)
         {
            return;
         }
         network = Network.getInstance();
         speedUpCost = network.data.costTable.getCostForTime(option,this._upgradeTimer.getSecondsRemaining());
         cash = network.playerData.compound.resources.getAmount(GameResources.CASH);
         if(cash < speedUpCost)
         {
            PaymentSystem.getInstance().openBuyCoinsScreen();
         }
         else if(!this._upgradeTimer.hasEnded() && this._upgradeTimer.getSecondsRemaining() > 3)
         {
            network.startAsyncOp();
            network.save({
               "id":this._id,
               "option":option.key
            },SaveDataMethod.BUILDING_SPEED_UP,function(param1:Object):void
            {
               network.completeAsyncOp();
               if(param1 == null)
               {
                  return;
               }
               if(param1.error == PlayerIOError.NotEnoughCoins.errorID)
               {
                  PaymentSystem.getInstance().openBuyCoinsScreen();
               }
               if(param1.success === false)
               {
                  return;
               }
               if(_upgradeTimer != null)
               {
                  _upgradeTimer.speedUpByPurchaseOption(option);
               }
               Tracking.trackEvent("SpeedUp",option.key,"building_" + type + "_" + level,int(param1.cost));
               if(onComplete != null)
               {
                  onComplete();
               }
            });
         }
      }
      
      public function speedUpRepair(param1:Object, param2:Function = null) : void
      {
         var speedUpCost:int;
         var cash:int;
         var network:Network = null;
         var option:Object = param1;
         var onComplete:Function = param2;
         if(this._repairTimer == null)
         {
            return;
         }
         network = Network.getInstance();
         speedUpCost = network.data.costTable.getCostForTime(option,this._repairTimer.getSecondsRemaining());
         cash = network.playerData.compound.resources.getAmount(GameResources.CASH);
         if(cash < speedUpCost)
         {
            PaymentSystem.getInstance().openBuyCoinsScreen();
         }
         else if(!this._repairTimer.hasEnded() && this._repairTimer.getSecondsRemaining() > 3)
         {
            network.startAsyncOp();
            network.save({
               "id":this._id,
               "option":option.key
            },SaveDataMethod.BUILDING_REPAIR_SPEED_UP,function(param1:Object):void
            {
               network.completeAsyncOp();
               if(param1 == null)
               {
                  return;
               }
               if(param1.error == PlayerIOError.NotEnoughCoins.errorID)
               {
                  PaymentSystem.getInstance().openBuyCoinsScreen();
               }
               if(param1.success === false)
               {
                  return;
               }
               if(_repairTimer != null)
               {
                  _repairTimer.speedUpByPurchaseOption(option);
               }
               Tracking.trackEvent("SpeedUp",option.key,"building_repair_" + type + "_" + level,int(param1.cost));
               if(onComplete != null)
               {
                  onComplete();
               }
            });
         }
      }
      
      public function getLevelXML(param1:int = -1) : XML
      {
         var level:int = param1;
         return this._xml.lvl.(@n == (level < 0 ? this._level : level))[0];
      }
      
      public function getSound(param1:String) : String
      {
         if(this._xml == null)
         {
            return null;
         }
         var _loc2_:XMLList = this._xml.snd[param1];
         if(_loc2_.length() == 0)
         {
            return null;
         }
         return _loc2_[int(Math.random() * _loc2_.length())].toString();
      }
      
      public function resetHealth() : void
      {
         if(_dead)
         {
            this.setDestroyedState(true);
            return;
         }
         if(this.isUnderConstruction())
         {
            this.health = this.maxHealth * Math.max(0.01,this._upgradeTimer.getProgress());
         }
         else
         {
            this.health = this.maxHealth;
         }
      }
      
      public function saveAssignments() : void
      {
         var assignList:Array;
         var i:int;
         if(!this._assignedChanged)
         {
            Network.getInstance().playerData.saveSurvivorDefensiveLoadout();
            return;
         }
         assignList = [];
         i = 0;
         while(i < this._assignedSurvivors.length)
         {
            if(this._assignedSurvivors[i] != null)
            {
               assignList.push(this._assignedSurvivors[i].id);
            }
            else
            {
               assignList.push(null);
            }
            i++;
         }
         Network.getInstance().save({
            "id":this._id,
            "survivors":assignList
         },SaveDataMethod.RALLY_ASSIGNMENT,function(param1:Object):void
         {
            if(param1 == null || param1.success === false)
            {
               return;
            }
            Network.getInstance().playerData.saveSurvivorDefensiveLoadout();
         });
         this._assignedChanged = false;
      }
      
      public function canCraft(param1:String) : Boolean
      {
         return this._craftingCategories.indexOf(param1) > -1;
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         return null;
      }
      
      public function readObject(param1:Object) : void
      {
         var upgradeTimer:TimerData = null;
         var repairTimer:TimerData = null;
         var input:Object = param1;
         this._id = input.id.toUpperCase();
         this._customName = input.name != null ? String(input.name) : null;
         this.setXML(ResourceManager.getInstance().getResource("xml/buildings.xml").content.item.(@id == String(input.type))[0]);
         this.setLevel(int(input.level));
         this.rotation = int(input.rotation);
         this.tileX = int(input.tx);
         this.tileY = int(input.ty);
         if(!isWithinCompoundBounds(this.tileX,this.tileY))
         {
            this.tileX = this.tileY = 0;
         }
         this.health = input.destroyed === true ? 0 : this.maxHealth;
         this.resourceValue = Boolean(input.hasOwnProperty("resourceValue")) && !isNaN(input.resourceValue) ? Number(input.resourceValue) : 0;
         if(input.upgrade != null)
         {
            upgradeTimer = new TimerData(null,0,this);
            upgradeTimer.readObject(input.upgrade);
            if(!upgradeTimer.hasEnded() && upgradeTimer.length > 0)
            {
               this._upgradeTimer = upgradeTimer;
               this._upgradeTimer.data.type = "upgrade";
               if(!("xp" in this._upgradeTimer.data))
               {
                  this._upgradeTimer.data.xp = this._xml.lvl.(@n == _upgradeTimer.data.level)[0].xp[0];
               }
               this._upgradeTimer.completed.addOnce(this.onUpgradeComplete);
               this._upgradeTimer.cancelled.addOnce(this.onUpgradeCancelled);
               TimerManager.getInstance().addTimer(this._upgradeTimer);
            }
            else
            {
               upgradeTimer.dispose();
            }
         }
         if(input.repair != null)
         {
            repairTimer = new TimerData(null,0,this);
            repairTimer.readObject(input.repair);
            if(!repairTimer.hasEnded() && repairTimer.length > 0)
            {
               this._repairTimer = repairTimer;
               this._repairTimer.data.type = "repair";
               this._repairTimer.completed.addOnce(this.onRepairComplete);
               TimerManager.getInstance().addTimer(this._repairTimer);
            }
            else
            {
               repairTimer.dispose();
            }
         }
      }
      
      public function setLevel(param1:int) : void
      {
         var lvlDef:XML;
         var level:int = param1;
         this._level = level;
         if(this._xml == null)
         {
            return;
         }
         lvlDef = this._xml.lvl.(@n == level)[0];
         if(lvlDef == null)
         {
            this._assetURI = this._xml.mdl.@uri.toString();
            this._assetDamagedURI = this._xml.hasOwnProperty("damaged_mdl") ? this._xml.damaged_mdl.@uri.toString() : null;
            this._comfort = this._security = 0;
            this._buildingEntity.coverRating = 0;
            this._disarmTime = this._disarmChance = 0;
         }
         else
         {
            this._security = lvlDef.hasOwnProperty("security") ? int(lvlDef.security) : 0;
            this._comfort = lvlDef.hasOwnProperty("comfort") ? int(lvlDef.comfort) : 0;
            this._buildingEntity.coverRating = lvlDef.hasOwnProperty("cover") ? int(lvlDef.cover) : 0;
            this._disarmTime = lvlDef.hasOwnProperty("disarm_time") ? Number(lvlDef.disarm_time) : 0;
            this._disarmChance = lvlDef.hasOwnProperty("disarm_chance") ? Number(lvlDef.disarm_chance) : 0;
            this._scavengeTime = lvlDef.hasOwnProperty("scav_time") ? Number(lvlDef.scav_time) : 0;
            this._minScavengeTime = lvlDef.hasOwnProperty("scav_time_min") ? Number(lvlDef.scav_time_min) : 0;
            if(lvlDef.hasOwnProperty("cap"))
            {
               this._resourceCapacity = int(lvlDef.cap);
            }
            if(lvlDef.hasOwnProperty("rate"))
            {
               this._productionRate = Number(lvlDef.rate);
            }
            this._assetURI = lvlDef.hasOwnProperty("mdl") ? lvlDef.mdl.@uri.toString() : this._xml.mdl.@uri.toString();
            this._assetDamagedURI = lvlDef.hasOwnProperty("damaged_mdl") ? lvlDef.damaged_mdl.@uri.toString() : (this._xml.hasOwnProperty("damaged_mdl") ? this._xml.damaged_mdl.@uri.toString() : null);
         }
         if(this._buildingEntity.scene != null)
         {
            this._buildingEntity.setMesh(this._assetURI,this._assetDamagedURI);
         }
         else
         {
            this._buildingEntity.addedToScene.addOnce(this.onAddedToScene);
         }
      }
      
      private function getModifier(param1:String) : Number
      {
         return Number(this._researchEffectMods[param1]) || 0;
      }
      
      private function getModifiedStat(param1:String, param2:Number) : Number
      {
         var _loc3_:Number = this.getModifier(param1);
         return param2 + param2 * _loc3_;
      }
      
      protected function setXML(param1:XML) : void
      {
         var _loc2_:XML = null;
         var _loc3_:XML = null;
         var _loc4_:int = 0;
         this._xml = param1;
         this._type = this._xml.@id.toString();
         this._purchaseOnly = Boolean(this._xml.hasOwnProperty("@purchase")) && this._xml.@purchase == "1";
         this._notPurchasable = Boolean(this._xml.hasOwnProperty("@notbuyable")) && this._xml.@notbuyable == "1";
         this._assignable = Boolean(this._xml.@assignable == "1");
         this._connectable = Boolean(this._xml.@connect == "1");
         this._destroyable = Boolean(this._xml.@destroy == "1");
         this._scavengable = Boolean(this._xml.@scav == "1");
         this._isDoor = Boolean(this._xml.@door == "1");
         this._isTrap = Boolean(this._xml.@trap == "1");
         this._isDecoyTrap = Boolean(this._xml.@decoy == "1");
         this._isExplosive = Boolean(this._xml.@explosive == "1");
         this._doorwayOnly = Boolean(this._xml.@doorway == "1");
         _maxHealth = this._xml.hasOwnProperty("health") ? Number(this.xml.health) : 1;
         this._assignedSurvivors.length = this.numAssignableSurvivors;
         if(this._isTrap && this._xml.@detected == "1")
         {
            flags |= EntityFlags.TRAP_DETECTED;
         }
         if(this._xml.hasOwnProperty("door"))
         {
            this._doorPos = new Point(int(this._xml.door.@x),int(this._xml.door.@y));
         }
         this._productionResource = this.xml.hasOwnProperty("prod") ? this.xml.prod.toString() : null;
         this._storageResource = this.xml.hasOwnProperty("store") ? this.xml.store.toString() : null;
         this._craftingCategories = new Vector.<String>();
         for each(_loc2_ in this.xml.craft)
         {
            this._craftingCategories.push(_loc2_.toString());
         }
         this._maxLevel = 0;
         for each(_loc3_ in this._xml.lvl)
         {
            _loc4_ = int(_loc3_.@n);
            if(_loc4_ > this._maxLevel)
            {
               this._maxLevel = _loc4_;
            }
         }
         _entity = this._buildingEntity = BuildingEntityFactory.create(this._xml);
         this._buildingEntity.buildingData = this;
         this._buildingEntity.assetMouseDown.add(this.onEntityClicked);
         if(this._xml.@type != "junk")
         {
            this._buildingEntity.setFootprint(int(this._xml.size.@x),int(this._xml.size.@y),this._xml.@nobuffer != "1");
         }
         this._buildingEntity.passable = Boolean(this._xml.hasOwnProperty("@passable")) && this._xml.@passable == "1";
         this._buildingEntity.rotation = this.rotation;
         if(Boolean(this._xml.hasOwnProperty("@los")) && this._xml.@los != "0")
         {
            this._buildingEntity.losVisible = true;
         }
         if(this._buildingEntity.passable)
         {
            this._buildingEntity.flags &= ~GameEntityFlags.FORCE_UNPASSABLE;
         }
         switch(this._type)
         {
            case "windmill":
               this._buildingEntity.actions.push(new WindmillAction());
               break;
            case "resource-fuel":
            case "incinerator":
               this._buildingEntity.actions.push(new SmokeEmissionAction());
         }
         if(this._productionResource != null)
         {
            this._buildingEntity.actions.push(new ResourceBuildingAction(this,5));
         }
         if(this._storageResource != null)
         {
            this._buildingEntity.actions.push(new ResourceBuildingAction(this,3));
         }
      }
      
      public function setTraversalAreaEnabledState(param1:Boolean) : void
      {
         var _loc2_:NavEdge = null;
         var _loc3_:Cell = null;
         var _loc4_:Cell = null;
         if(this._traversalArea == null)
         {
            return;
         }
         for each(_loc2_ in this._traversalArea.edges)
         {
            if(param1)
            {
               _loc2_.cost = 15;
               _loc2_.flags |= NavEdgeFlag.TRAVERSAL_AREA;
            }
            else
            {
               _loc2_.cost = 0;
               _loc2_.flags &= ~NavEdgeFlag.TRAVERSAL_AREA;
            }
         }
         for each(_loc3_ in this._traversalArea.nodes)
         {
            _loc4_ = this._buildingEntity.scene.map.cellMap.getCell(_loc3_.x,_loc3_.y);
            if(param1)
            {
               _loc4_.flags |= CellFlag.FORCE_WAYPOINT | CellFlag.TRAVERSAL_AREA;
               _loc3_.flags |= CellFlag.FORCE_WAYPOINT | CellFlag.TRAVERSAL_AREA;
            }
            else
            {
               _loc4_.flags &= ~CellFlag.FORCE_WAYPOINT;
               _loc4_.flags &= ~CellFlag.TRAVERSAL_AREA;
               _loc3_.flags &= ~CellFlag.FORCE_WAYPOINT;
               _loc3_.flags &= ~CellFlag.TRAVERSAL_AREA;
            }
         }
      }
      
      private function setDestroyedState(param1:Boolean) : void
      {
         if(!this._destroyable)
         {
            return;
         }
         if(this._buildingEntity.scene != null)
         {
            if(param1)
            {
               if(this._missionBuilding)
               {
                  this._buildingEntity.losVisible = false;
                  this._buildingEntity.mesh_hitArea.mouseEnabled = false;
                  this._buildingEntity.mesh_hitArea.visible = false;
               }
               this._buildingEntity.flags &= ~GameEntityFlags.FORCE_UNPASSABLE;
               this._buildingEntity.flags |= GameEntityFlags.FORCE_PASSABLE | EntityFlags.DESTROYED;
            }
            else
            {
               this._buildingEntity.flags &= ~GameEntityFlags.FORCE_PASSABLE;
               this._buildingEntity.flags &= ~EntityFlags.DESTROYED;
               if(!this._buildingEntity.passable)
               {
                  this._buildingEntity.flags |= GameEntityFlags.FORCE_UNPASSABLE;
               }
            }
            this.setTraversalAreaEnabledState(!param1);
            this._buildingEntity.scene.map.updateCellsForEntity(this._buildingEntity,true);
            this._buildingEntity.scene.updateLOSForEntity(this._buildingEntity);
         }
         this._buildingEntity.showDamaged(param1);
      }
      
      private function onAddedToScene(param1:GameEntity) : void
      {
         this._buildingEntity.addedToScene.remove(this.onAddedToScene);
         if(this._assetURI != null)
         {
            this._buildingEntity.setMesh(this._assetURI,this._assetDamagedURI);
         }
      }
      
      private function onEntityClicked(param1:BuildingEntity) : void
      {
         this.entityClicked.dispatch(this);
      }
      
      private function onUpgradeCancelled(param1:TimerData) : void
      {
         if(this._upgradeTimer != null)
         {
            this._upgradeTimer.cancelled.remove(this.onUpgradeCancelled);
            this._upgradeTimer.completed.remove(this.onUpgradeComplete);
         }
         this._upgradeTimer = null;
      }
      
      private function onUpgradeComplete(param1:TimerData) : void
      {
         this.setLevel(param1.data.level);
         this._upgradeTimer = null;
         Tracking.trackEvent("Player","BuildingComplete_playerLvl_" + Network.getInstance().playerData.getPlayerSurvivor().level,this.type + "_" + this.level,this.level);
      }
      
      private function onRepairComplete(param1:TimerData) : void
      {
         this.health = this.maxHealth;
         this._repairTimer = null;
         this.repairCompleted.dispatch(this);
      }
      
      private function onAssignedSurvivorLoadoutChanged() : void
      {
         if(this._buildingEntity != null)
         {
            this._buildingEntity.updateRangeDisplay();
         }
      }
      
      public function get assignable() : Boolean
      {
         return this._assignable;
      }
      
      public function get connectable() : Boolean
      {
         return this._connectable;
      }
      
      public function get assignedSurvivors() : Vector.<Survivor>
      {
         return this._assignedSurvivors;
      }
      
      public function get numAssignedSurvivors() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this._assignedSurvivors.length)
         {
            if(this._assignedSurvivors[_loc2_] != null)
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      override public function set health(param1:Number) : void
      {
         if(_dead && param1 > 0)
         {
            this.setDestroyedState(false);
         }
         else if(!_dead && param1 <= 0)
         {
            this.setDestroyedState(true);
         }
         super.health = param1;
      }
      
      override public function get maxHealth() : Number
      {
         return (this._level + 1) / (this._maxLevel + 1) * this.getModifiedStat("health",_maxHealth);
      }
      
      public function set maxHealth(param1:Number) : void
      {
         _maxHealth = param1;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get assetURI() : String
      {
         return this._assetURI;
      }
      
      public function get comfort() : int
      {
         return this._comfort;
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function get buildingEntity() : BuildingEntity
      {
         return this._buildingEntity;
      }
      
      public function set buildingEntity(param1:BuildingEntity) : void
      {
         this._buildingEntity = param1;
      }
      
      public function get level() : int
      {
         return this._level;
      }
      
      public function get maxLevel() : int
      {
         return this._maxLevel;
      }
      
      public function set maxLevel(param1:int) : void
      {
         this._maxLevel = param1;
      }
      
      public function get productionResource() : String
      {
         return this._productionResource;
      }
      
      public function get productionRate() : Number
      {
         return getProductionRate(this);
      }
      
      public function get purchaseOnly() : Boolean
      {
         return this._purchaseOnly;
      }
      
      public function get isBuyable() : Boolean
      {
         return !this._notPurchasable;
      }
      
      public function get recyclable() : Boolean
      {
         if(this.type == "workbench" && Tutorial.getInstance().active)
         {
            return false;
         }
         return !this._xml.hasOwnProperty("@recyclable") || this._xml.@recyclable == "1";
      }
      
      public function get storageResource() : String
      {
         return this._storageResource;
      }
      
      public function get resourceCapacity() : int
      {
         return getResourceCapacity(this);
      }
      
      public function get resourceValue() : Number
      {
         return this._resourceValue;
      }
      
      public function set resourceValue(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._resourceValue = param1;
         this.resourceValueChanged.dispatch(this);
      }
      
      public function get rotation() : int
      {
         return this._rotation;
      }
      
      public function set rotation(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 += 4;
         }
         else if(param1 > 3)
         {
            param1 -= 4;
         }
         this._rotation = param1;
         this._buildingEntity.rotation = param1;
      }
      
      public function get security() : int
      {
         return this._security;
      }
      
      public function get numAssignableSurvivors() : int
      {
         if(!this._assignable)
         {
            return 0;
         }
         return this._xml.assign.length();
      }
      
      public function get repairTimer() : TimerData
      {
         return this._repairTimer;
      }
      
      public function get upgradeTimer() : TimerData
      {
         return this._upgradeTimer;
      }
      
      public function get xml() : XML
      {
         return this._xml;
      }
      
      public function get tasks() : Vector.<Task>
      {
         return this._tasks;
      }
      
      public function get craftingCategories() : Vector.<String>
      {
         return this._craftingCategories;
      }
      
      public function get isDoor() : Boolean
      {
         return this._isDoor;
      }
      
      public function get isTrap() : Boolean
      {
         return this._isTrap;
      }
      
      public function get isExplosive() : Boolean
      {
         return this._isExplosive;
      }
      
      public function get coverRating() : int
      {
         return this._buildingEntity.coverRating;
      }
      
      public function get coverRatingModifier() : Number
      {
         return this.getModifier("cover_mod");
      }
      
      public function get dead() : Boolean
      {
         return _dead && _health <= 0;
      }
      
      public function get destroyable() : Boolean
      {
         return this._destroyable;
      }
      
      public function set destroyable(param1:Boolean) : void
      {
         this._destroyable = param1;
      }
      
      public function get doorwayOnly() : Boolean
      {
         return this._doorwayOnly;
      }
      
      public function get disarmTime() : Number
      {
         return this.getModifiedStat("disarm_time",this._disarmTime);
      }
      
      public function get disarmChance() : Number
      {
         return this.getModifiedStat("disarm_chance",this._disarmChance);
      }
      
      public function get isDecoyTrap() : Boolean
      {
         return this._isDecoyTrap;
      }
      
      public function get doorPosition() : Point
      {
         return this._doorPos;
      }
      
      public function get mountedSurvivor() : Survivor
      {
         return this._mountedSurvivor;
      }
      
      public function set mountedSurvivor(param1:Survivor) : void
      {
         if(!this._assignable || this._doorPos == null)
         {
            return;
         }
         this._mountedSurvivor = param1;
      }
      
      public function get scavengeTime() : Number
      {
         return this._scavengeTime;
      }
      
      public function get minScavengeTime() : Number
      {
         return this._minScavengeTime;
      }
      
      public function get scavengable() : Boolean
      {
         return this._scavengable || this._forceScavengable;
      }
      
      public function set scavengable(param1:Boolean) : void
      {
         this._scavengable = param1;
      }
      
      public function get forceScavengable() : Boolean
      {
         return this._forceScavengable;
      }
      
      public function set forceScavengable(param1:Boolean) : void
      {
         this._forceScavengable = param1;
      }
      
      public function get traversalArea() : TraversalArea
      {
         return this._traversalArea;
      }
      
      public function set traversalArea(param1:TraversalArea) : void
      {
         this._traversalArea = param1;
         this.setTraversalAreaEnabledState(!(this._destroyable && _dead));
      }
      
      public function get isMissionBuilding() : Boolean
      {
         return this._missionBuilding;
      }
      
      public function get detectRangeModifier() : Number
      {
         return this.getModifier("detect_rng");
      }
      
      public function get damageModifier() : Number
      {
         return this.getModifier("dmg_mod");
      }
      
      public function get researchEffectModifiers() : Object
      {
         return this._researchEffectMods;
      }
   }
}

