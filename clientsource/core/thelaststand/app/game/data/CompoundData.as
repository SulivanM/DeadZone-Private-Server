package thelaststand.app.game.data
{
   import com.exileetiquette.utils.NumberFormatter;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.game.data.alliance.AllianceData;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.data.effects.Effect;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.data.notification.NotificationFactory;
   import thelaststand.app.game.data.notification.NotificationType;
   import thelaststand.app.game.data.research.ResearchEffect;
   import thelaststand.app.game.data.task.JunkRemovalTask;
   import thelaststand.app.game.gui.dialogues.ItemPurchasedDialogue;
   import thelaststand.app.game.logic.NotificationSystem;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.lang.Language;
   
   public class CompoundData
   {
      
      private var _player:PlayerData;
      
      private var _buildings:BuildingCollection;
      
      private var _resources:GameResources;
      
      private var _survivors:SurvivorCollection;
      
      private var _tasks:TaskCollection;
      
      private var _effects:EffectCollection;
      
      private var _globalEffects:EffectCollection;
      
      private var _morale:Morale;
      
      private var _moraleFilter:Vector.<String> = new <String>[Morale.EFFECT_FOOD,Morale.EFFECT_WATER,Morale.EFFECT_SECURITY,Morale.EFFECT_COMFORT];
      
      public function CompoundData(param1:PlayerData = null)
      {
         super();
         this._player = param1;
         this._morale = new Morale();
         this._buildings = new BuildingCollection(this);
         this._buildings.buildingAdded.add(this.onBuildingAdded);
         this._buildings.buildingRemoved.add(this.onBuildingRemoved);
         this._survivors = new SurvivorCollection(this);
         this._resources = new GameResources(this);
         this._resources.resourceChanged.add(this.onResourceChanged);
         this._effects = new EffectCollection(this,Config.constant.NUM_EFFECT_SLOTS);
         this._globalEffects = new EffectCollection(this);
         this._tasks = new TaskCollection(this);
         this._tasks.taskCompleted.add(this.onTaskCompleted);
      }
      
      public function dispose() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < this._survivors.length)
         {
            this._survivors.getSurvivor(_loc1_).dispose();
            _loc1_++;
         }
         this._survivors.dispose();
         this._survivors = null;
         _loc1_ = 0;
         while(_loc1_ < this._buildings.numBuildings)
         {
            this._buildings.getBuilding(_loc1_).dispose();
            _loc1_++;
         }
         this._buildings.dispose();
         this._buildings = null;
         _loc1_ = 0;
         while(_loc1_ < this._tasks.length)
         {
            this._tasks.getTask(_loc1_).dispose();
            _loc1_++;
         }
         this._tasks.dispose();
         this._tasks = null;
         this._effects.dispose();
         this._globalEffects.dispose();
         this._resources.dispose();
         this._resources = null;
         AllianceSystem.getInstance().connected.remove(this.onAllianceSystemConnected);
         AllianceSystem.getInstance().disconnected.remove(this.onAllianceSystemDisconnected);
      }
      
      public function init() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Building = null;
         this.distributeAllResourcesToStorageBuildings();
         this.applyMoraleEffects();
         _loc1_ = 0;
         _loc2_ = this._buildings.numBuildings;
         while(_loc1_ < _loc2_)
         {
            _loc3_ = this._buildings.getBuilding(_loc1_);
            if(_loc3_ != null)
            {
               _loc3_.upgradeStarted.add(this.onBuildingUpgradeStarted);
               if(_loc3_.upgradeTimer != null && !_loc3_.upgradeTimer.hasEnded())
               {
                  _loc3_.upgradeTimer.completed.addOnce(this.onBuildingUpgradeComplete);
               }
            }
            _loc1_++;
         }
         if(this._player != null)
         {
            AllianceSystem.getInstance().connected.add(this.onAllianceSystemConnected);
            AllianceSystem.getInstance().disconnected.add(this.onAllianceSystemDisconnected);
         }
      }
      
      public function addXP(param1:int) : void
      {
         var _loc3_:Survivor = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._survivors.length)
         {
            _loc3_ = this._survivors.getSurvivor(_loc2_);
            _loc3_.XP += param1;
            _loc2_++;
         }
      }
      
      public function applyMoraleEffects() : void
      {
         var _loc2_:int = 0;
         var _loc22_:Survivor = null;
         this._morale.clear();
         var _loc1_:int = this._survivors.length;
         var _loc3_:int = 24 * 60 * 60;
         var _loc4_:Number = Number(Config.constant.SURVIVOR_SECURITY_REQ);
         var _loc5_:Number = Number(Config.constant.SURVIVOR_COMFORT_REQ);
         var _loc6_:Number = Number(Config.constant.SURVIVOR_FOOD_DAYS_REQ);
         var _loc7_:Number = Number(Config.constant.SURVIVOR_WATER_DAYS_REQ);
         var _loc8_:int = int(Config.constant.SURVIVOR_ADULT_FOOD_CONSUMPTION);
         var _loc9_:int = int(Config.constant.SURVIVOR_ADULT_WATER_CONSUMPTION);
         var _loc10_:Number = this._resources.getResourceDaysRemaining(GameResources.FOOD,false) - _loc6_;
         if(_loc10_ < 0)
         {
            _loc10_ = _loc10_ * Math.abs(_loc10_) * _loc1_;
         }
         else if(_loc10_ > 0)
         {
            _loc10_ = _loc10_ / 11 * 12.25;
         }
         var _loc11_:Number = this._resources.getResourceDaysRemaining(GameResources.WATER,false) - _loc7_;
         if(_loc11_ < 0)
         {
            _loc11_ = _loc11_ * Math.abs(_loc11_) * _loc1_;
         }
         else if(_loc11_ > 0)
         {
            _loc11_ = _loc11_ / 11 * 12.25;
         }
         var _loc12_:Number = 0;
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            _loc12_ += _loc4_ * _loc2_;
            _loc2_++;
         }
         var _loc13_:Number = this.getSecurityRating() - _loc12_;
         var _loc14_:Number = 0;
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            _loc14_ += _loc5_ * _loc2_;
            _loc2_++;
         }
         var _loc15_:Number = this.getComfortRating() - _loc14_;
         var _loc16_:Number = _loc10_ / _loc1_;
         var _loc17_:Number = _loc11_ / _loc1_;
         var _loc18_:Number = _loc13_ / _loc1_;
         var _loc19_:Number = _loc15_ / _loc1_;
         var _loc20_:Number = 0;
         var _loc21_:Number = this.getEffectValue(EffectType.getTypeValue("GlobalMorale")) / 100;
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            _loc22_ = this._survivors.getSurvivor(_loc2_);
            _loc22_.morale.setEffect(Morale.EFFECT_FOOD,_loc16_);
            _loc22_.morale.setEffect(Morale.EFFECT_WATER,_loc17_);
            _loc22_.morale.setEffect(Morale.EFFECT_SECURITY,_loc18_);
            _loc22_.morale.setEffect(Morale.EFFECT_COMFORT,_loc19_);
            _loc22_.morale.multiplier = _loc21_;
            _loc20_ += _loc22_.morale.getTotal(this._moraleFilter);
            _loc2_++;
         }
         _loc20_ /= _loc1_;
         this._morale.setEffect(Morale.EFFECT_AVERAGE_SURVIVOR,_loc20_);
         this._morale.setEffect(Morale.EFFECT_FOOD,_loc10_);
         this._morale.setEffect(Morale.EFFECT_WATER,_loc11_);
         this._morale.setEffect(Morale.EFFECT_SECURITY,_loc13_);
         this._morale.setEffect(Morale.EFFECT_COMFORT,_loc15_);
      }
      
      public function collectResources(param1:Building) : void
      {
         var building:Building = param1;
         if(building.productionResource == null || building.resourceValue < 1)
         {
            return;
         }
         Network.getInstance().startAsyncOp();
         Network.getInstance().save({"id":building.id},SaveDataMethod.BUILDING_COLLECT,function(param1:Object):void
         {
            var _loc6_:Number = NaN;
            var _loc7_:ItemPurchasedDialogue = null;
            Network.getInstance().completeAsyncOp();
            if(param1 == null || param1.success === false)
            {
               return;
            }
            if(param1.locked === true)
            {
               return;
            }
            var _loc2_:String = String(param1.resource);
            if(!_loc2_)
            {
               return;
            }
            var _loc3_:int = int(param1.collected);
            var _loc4_:Number = Number(param1.remainder);
            var _loc5_:Number = Number(param1.total);
            if(_loc3_ > 0)
            {
               _resources.setAmount(_loc2_,_loc5_);
               building.resourceValue = _loc4_;
               building.resourcesCollected.dispatch(building,_loc3_);
               Tracking.trackEvent("Player","ResourceCollected",_loc2_,_loc3_);
               if(param1.bonus > 0)
               {
                  _loc6_ = Number(param1.bonus);
                  _loc7_ = new ItemPurchasedDialogue(Language.getInstance().getString("bonus_" + _loc2_),Language.getInstance().getString("bonus_" + _loc2_ + "_desc",NumberFormatter.format(_loc6_,0)),"images/ui/production-bonus-" + _loc2_ + ".jpg",167,135,BaseDialogue.TITLE_COLOR_GREY);
                  _loc7_.open();
               }
            }
            if(param1.destroyed === true)
            {
               building.die(null);
            }
         });
      }
      
      public function distributeAllResourcesToStorageBuildings() : void
      {
         var _loc2_:String = null;
         var _loc1_:Array = GameResources.getResourceList();
         for each(_loc2_ in _loc1_)
         {
            if(_loc2_ != GameResources.CASH)
            {
               this.distributeResourceToStorageBuildings(_loc2_);
            }
         }
      }
      
      public function getComfortRating() : int
      {
         var _loc5_:Building = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = this._buildings.numBuildings;
         while(_loc2_ < _loc3_)
         {
            _loc5_ = this._buildings.getBuilding(_loc2_);
            if(!(_loc5_ == null || _loc5_.isUnderConstruction()))
            {
               _loc1_ += _loc5_.comfort;
            }
            _loc2_++;
         }
         var _loc4_:Number = 0;
         _loc4_ = _loc4_ + this._player.researchState.getEffectValue(ResearchEffect.IndoorComfort);
         _loc4_ = _loc4_ + this._player.researchState.getEffectValue(ResearchEffect.OutdoorComfort);
         return int(_loc1_ + Math.ceil(_loc1_ * _loc4_));
      }
      
      public function getSecurityRating() : int
      {
         var _loc5_:Building = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = this._buildings.numBuildings;
         while(_loc2_ < _loc3_)
         {
            _loc5_ = this._buildings.getBuilding(_loc2_);
            if(!(_loc5_ == null || _loc5_.isUnderConstruction()))
            {
               _loc1_ += _loc5_.security;
            }
            _loc2_++;
         }
         var _loc4_:Number = 0;
         _loc4_ = _loc4_ + this._player.researchState.getEffectValue(ResearchEffect.BarricadeSecurity);
         _loc4_ = _loc4_ + this._player.researchState.getEffectValue(ResearchEffect.BarrierSecurity);
         _loc4_ = _loc4_ + this._player.researchState.getEffectValue(ResearchEffect.WatchtowerSecurity);
         _loc4_ = _loc4_ + this._player.researchState.getEffectValue(ResearchEffect.DoorSecurity);
         return int(_loc1_ + Math.ceil(_loc1_ * _loc4_));
      }
      
      public function setRallyAssignments(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         var _loc4_:Building = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:Survivor = null;
         if(param1 == null)
         {
            return;
         }
         for(_loc2_ in param1)
         {
            _loc3_ = param1[_loc2_] as Array;
            if(_loc3_ != null)
            {
               _loc4_ = this._buildings.getBuildingById(_loc2_);
               if(_loc4_ != null)
               {
                  _loc5_ = 0;
                  while(_loc5_ < _loc3_.length)
                  {
                     _loc6_ = _loc3_[_loc5_];
                     if(_loc6_ != null)
                     {
                        _loc7_ = this._survivors.getSurvivorById(_loc6_);
                        if(_loc7_ != null)
                        {
                           _loc4_.assignSurvivor(_loc7_,_loc5_);
                        }
                     }
                     _loc5_++;
                  }
               }
            }
         }
      }
      
      public function getEffectValue(param1:uint) : Number
      {
         var _loc2_:Number = 0;
         _loc2_ += this._effects.getValue(param1);
         return _loc2_ + this._globalEffects.getValue(param1);
      }
      
      public function hasPermanentEffect(param1:uint) : Boolean
      {
         return this._effects.hasPermanentEffect(param1) || this._globalEffects.hasPermanentEffect(param1);
      }
      
      public function updateProductionResources(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Building = null;
         if(param1 == null)
         {
            return;
         }
         for(_loc2_ in param1)
         {
            _loc3_ = this._buildings.getBuildingById(_loc2_);
            if(_loc3_ != null)
            {
               _loc3_.resourceValue = Number(param1[_loc2_]);
            }
         }
      }
      
      private function distributeResourceToStorageBuildings(param1:String) : void
      {
         var _loc5_:Building = null;
         var _loc6_:int = 0;
         var _loc2_:Number = this._resources.getAmount(param1);
         var _loc3_:Vector.<Building> = this.buildings.getBuildingsOfType("storage-" + param1);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = _loc3_[_loc4_];
            if(!(_loc5_ == null || _loc5_.storageResource != param1))
            {
               _loc6_ = Math.floor(Math.min(_loc2_,_loc5_.resourceCapacity));
               _loc5_.resourceValue = _loc6_;
               _loc2_ -= _loc6_;
            }
            _loc4_++;
         }
      }
      
      private function onTaskCompleted(param1:Task) : void
      {
         this.addXP(param1.getXP());
         switch(param1.type)
         {
            case TaskType.JUNK_REMOVAL:
               this._buildings.removeBuilding(JunkRemovalTask(param1).target);
         }
      }
      
      private function onBuildingAdded(param1:Building) : void
      {
         param1.upgradeStarted.add(this.onBuildingUpgradeStarted);
         if(param1.upgradeTimer != null)
         {
            this.onBuildingUpgradeStarted(param1);
         }
         if(param1.storageResource != null)
         {
            this.distributeAllResourcesToStorageBuildings();
            this.resources.storageCapacityChanged.dispatch(param1.storageResource);
         }
      }
      
      private function onBuildingRemoved(param1:Building) : void
      {
         param1.upgradeStarted.remove(this.onBuildingUpgradeStarted);
         if(param1.upgradeTimer != null)
         {
            param1.upgradeTimer.completed.remove(this.onBuildingUpgradeComplete);
         }
         if(param1.assignable)
         {
            param1.clearAssignedSurvivors();
         }
         if(param1.storageResource != null)
         {
            this.distributeAllResourcesToStorageBuildings();
            this.resources.storageCapacityChanged.dispatch(param1.storageResource);
         }
      }
      
      private function onBuildingUpgradeStarted(param1:Building, param2:Boolean = false) : void
      {
         var _loc3_:int = 0;
         if(param1.upgradeTimer != null)
         {
            param1.upgradeTimer.completed.addOnce(this.onBuildingUpgradeComplete);
         }
         if(param2)
         {
            _loc3_ = Building.getBuildingXP(param1.type,param1.level);
            if(_loc3_ > 0 && this._buildings.containsBuilding(param1))
            {
               this.addXP(_loc3_);
               NotificationSystem.getInstance().addNotification(NotificationFactory.createNotification(NotificationType.BUILDING_COMPLETE,param1.id));
            }
            if(param1.storageResource != null)
            {
               this.distributeAllResourcesToStorageBuildings();
               this.resources.storageCapacityChanged.dispatch(param1.storageResource);
            }
         }
      }
      
      private function onBuildingUpgradeComplete(param1:TimerData) : void
      {
         var _loc2_:Building = param1.target as Building;
         if(_loc2_ == null)
         {
            return;
         }
         this.addXP(param1.data.xp);
         if(_loc2_.storageResource != null)
         {
            this.distributeResourceToStorageBuildings(_loc2_.storageResource);
            this.resources.storageCapacityChanged.dispatch(_loc2_.storageResource);
         }
      }
      
      private function onResourceChanged(param1:String, param2:Number) : void
      {
         if(param1 == GameResources.CASH)
         {
            return;
         }
         this.distributeResourceToStorageBuildings(param1);
      }
      
      private function onAllianceSystemConnected() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Effect = null;
         var _loc1_:AllianceData = AllianceSystem.getInstance().alliance;
         if(AllianceSystem.getInstance().canContributeToRound)
         {
            _loc2_ = 0;
            while(_loc2_ < _loc1_.numEffectSlots)
            {
               _loc3_ = _loc1_.getEffect(_loc2_);
               if(_loc3_ != null)
               {
                  this._globalEffects.addEffect(_loc3_);
               }
               _loc2_++;
            }
         }
         _loc1_.effectAdded.add(this.onAllianceEffectAdded);
         _loc1_.effectRemoved.add(this.onAllianceEffectRemoved);
      }
      
      private function onAllianceSystemDisconnected() : void
      {
         var _loc1_:AllianceData = AllianceSystem.getInstance().alliance;
         _loc1_.effectAdded.remove(this.onAllianceEffectAdded);
         _loc1_.effectRemoved.remove(this.onAllianceEffectRemoved);
      }
      
      private function onAllianceEffectAdded(param1:int, param2:Effect) : void
      {
         if(AllianceSystem.getInstance().canContributeToRound)
         {
            this._globalEffects.addEffect(param2);
         }
      }
      
      private function onAllianceEffectRemoved(param1:int, param2:Effect) : void
      {
         this._globalEffects.removeEffect(param2);
      }
      
      public function get player() : PlayerData
      {
         return this._player;
      }
      
      public function get buildings() : BuildingCollection
      {
         return this._buildings;
      }
      
      public function get effects() : EffectCollection
      {
         return this._effects;
      }
      
      public function get globalEffects() : EffectCollection
      {
         return this._globalEffects;
      }
      
      public function get resources() : GameResources
      {
         return this._resources;
      }
      
      public function get survivors() : SurvivorCollection
      {
         return this._survivors;
      }
      
      public function get tasks() : TaskCollection
      {
         return this._tasks;
      }
      
      public function get morale() : Morale
      {
         return this._morale;
      }
   }
}

