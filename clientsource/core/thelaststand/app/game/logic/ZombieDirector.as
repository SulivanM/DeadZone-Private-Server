package thelaststand.app.game.logic
{
   import com.exileetiquette.math.MathUtils;
   import flash.geom.Vector3D;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Config;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.Zombie;
   import thelaststand.app.game.data.assignment.AssignmentType;
   import thelaststand.app.game.data.enemies.EnemyFactory;
   import thelaststand.app.game.logic.ai.AIAgent;
   import thelaststand.app.game.logic.ai.AIStateMachine;
   import thelaststand.app.game.logic.ai.ThreatData;
   import thelaststand.app.game.logic.ai.states.ZombieAlertedState;
   import thelaststand.app.game.logic.ai.states.ZombieHuntState;
   import thelaststand.app.game.logic.navigation.NavigatorAgent;
   import thelaststand.app.game.scenes.BaseScene;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.map.Cell;
   import thelaststand.engine.map.Path;
   
   public class ZombieDirector
   {
      
      private static var _consecutiveSessionsWithoutRush:int = 0;
      
      private static const MAP_SIZE_MULTIPLIERS:Array = [[0,0.5],[750,0.75],[1500,1],[2000,1.1]];
      
      private static var ahsaved:Boolean = false;
      
      private var _zombies:Vector.<AIAgent>;
      
      private var _scene:BaseScene;
      
      private var _nextSpawnTime:Number = 0;
      
      private var _nextWaveTime:Number = 0;
      
      private var _nextWaveSpawns:Vector.<Vector3D> = new Vector.<Vector3D>();
      
      private var _nextZombieId:int;
      
      private var _waveSpawnCount:int = 0;
      
      private var _waveSpawnTotal:int = 0;
      
      private var _waveSpawnMax:int;
      
      private var _maxZombiesInWorld:int = 0;
      
      private var _numZombiesSpawned:int = 0;
      
      private var _zombieLevel:int;
      
      private var _tileSize:int;
      
      private var _tileMinX:int;
      
      private var _tileMaxX:int;
      
      private var _tileMinY:int;
      
      private var _tileMaxY:int;
      
      private var _zombieDefinitions:XML;
      
      private var _agentThreatIndex:int = 0;
      
      private var _startTime:Number = 0;
      
      private var _lastTime:Number = 0;
      
      private var _isCompoundAttack:Boolean;
      
      private var _waveActive:Boolean = false;
      
      private var _waveTimeThreatDecay:Number;
      
      private var _waveTimeMin:int;
      
      private var _waveTimeMax:int;
      
      private var _waveIsRush:Boolean = false;
      
      private var _missionData:MissionData;
      
      private var _spawnPointSelector:Function;
      
      private var _spawnPointWaveSetup:Function;
      
      private var _threatRating:Number = 0;
      
      private var _zombieNoiseThreatMult:Number = 0;
      
      private var _zombieQueue:Array;
      
      private var _arenaEliteZombie:ZombieData;
      
      private var _arenaEliteZombieSpawnTime:Number;
      
      private var _arenaSpawnPtIndex:int = 0;
      
      private var _requestingZombies:Boolean = false;
      
      private var _spawnRequestCount:int = 0;
      
      private var _spawnRequestPts:Array;
      
      private var _disposed:Boolean;
      
      private var _gettingZombies:Boolean = false;
      
      private var _rushCount:int;
      
      private var _rushChance:Number;
      
      private var _rushEndTime:int = 0;
      
      private var _rushIntensity:int = 0;
      
      private var _mapSizeMultiplier:Number = 1;
      
      private var _forceRushWave:Boolean;
      
      private var _randomPortalSpawning:Boolean;
      
      public var spawningEnabled:Boolean = true;
      
      public var minSpawnTime:int = 1000;
      
      public var zombieSpawned:Signal = new Signal(Zombie);
      
      public var rushStarted:Signal = new Signal(int);
      
      public var rushEnded:Signal = new Signal();
      
      private var serverSpawningDisabled:Boolean = false;
      
      public function ZombieDirector()
      {
         this._spawnPointSelector = this.selectNextRandomSpawnPoint;
         this._spawnPointWaveSetup = this.setupRegularWaveSpawns;
         super();
         this._zombies = new Vector.<AIAgent>();
         this._waveTimeMin = int(Config.constant.WAVE_TIME_MIN);
         this._waveTimeMax = int(Config.constant.WAVE_TIME_MAX);
         this._waveTimeThreatDecay = Number(Config.constant.THREAT_WAVE_TIME_DECAY);
         this._zombieNoiseThreatMult = Number(Config.constant.ZOMBIE_NOISE_THREAT_MULT);
         this._zombieDefinitions = ResourceManager.getInstance().getResource("xml/zombie.xml").content;
      }
      
      public static function getZombieDefinitionsForLevel(param1:int) : XMLList
      {
         var level:int = param1;
         var xml:XML = ResourceManager.getInstance().getResource("xml/zombie.xml").content;
         return xml.zombies.zombie.(@id.toString().length > 0 && int(lvl) <= level);
      }
      
      public function dispose() : void
      {
         var _loc1_:Zombie = null;
         if(this._disposed)
         {
            return;
         }
         this._disposed = true;
         for each(_loc1_ in this._zombies)
         {
            _loc1_.dispose();
         }
         this.zombieSpawned.removeAll();
         this.rushStarted.removeAll();
         this.rushEnded.removeAll();
         if(this._rushCount == 0)
         {
            ++_consecutiveSessionsWithoutRush;
         }
         this._zombies = null;
         this._scene = null;
         this._zombieDefinitions = null;
         this._missionData = null;
      }
      
      public function start(param1:Number, param2:BaseScene, param3:MissionData) : void
      {
         var i:int = 0;
         var baseWaveCount:int = 0;
         var areaLevelMod:int = 0;
         var areaBaseWaveCount:int = 0;
         var numTiles:int = 0;
         var queueStart:int = 0;
         var availableSpawns:Vector.<Vector3D> = null;
         var initZs:Array = null;
         var zombieXML:XML = null;
         var j:int = 0;
         var t:Number = param1;
         var scene:BaseScene = param2;
         var missionData:MissionData = param3;
         this._lastTime = t;
         this._startTime = t;
         this._scene = scene;
         this._zombieLevel = missionData.opponent.level;
         this._missionData = missionData;
         this._numZombiesSpawned = 0;
         this._maxZombiesInWorld = Config.constant.MAX_ZOMBIES;
         this._isCompoundAttack = missionData.type == "compound";
         this._threatRating = 0;
         this._randomPortalSpawning = this._scene.xmlDescriptor.tag.(text() == "randomizePortals").length() > 0;
         this._tileSize = this._scene.map.cellSize;
         this._tileMinX = this._scene.map.position.x;
         this._tileMaxX = this._scene.map.position.x + this._tileSize * this._scene.map.size.x;
         this._tileMinY = this._scene.map.position.y - this._tileSize * this._scene.map.size.y;
         this._tileMaxY = this._scene.map.position.y;
         this._zombieQueue = [];
         this._spawnRequestPts = [];
         if(this._isCompoundAttack)
         {
            this._nextSpawnTime = t + this.minSpawnTime;
            this._waveSpawnMax = 0;
            this._waveSpawnTotal = 0;
            this._rushCount = this._rushChance = 0;
            this._spawnPointWaveSetup = this.setupRegularWaveSpawns;
            this._spawnPointSelector = this.selectNextRandomSpawnPoint;
         }
         else
         {
            baseWaveCount = int(Config.constant.BASE_WAVE_COUNT);
            areaLevelMod = int(Config.xml.location_levels.param.(@type == _missionData.type)[0]);
            areaBaseWaveCount = Math.max(baseWaveCount + int(areaLevelMod * 2),int(baseWaveCount * 0.5));
            numTiles = scene.map.size.x * scene.map.size.y;
            this._mapSizeMultiplier = 1;
            i = 0;
            while(i < MAP_SIZE_MULTIPLIERS.length)
            {
               if(numTiles <= MAP_SIZE_MULTIPLIERS[i][0])
               {
                  break;
               }
               this._mapSizeMultiplier = MAP_SIZE_MULTIPLIERS[i][1];
               i++;
            }
            this._waveSpawnMax = int(areaBaseWaveCount * this._mapSizeMultiplier);
            this._waveSpawnTotal = 0;
            this.resetNextWaveTime(t);
            this._rushCount = 0;
            this._rushChance = Number(Config.constant.RUSH_CHANCE_BASE);
            queueStart = 0;
            if(missionData.assignmentType == AssignmentType.Arena)
            {
               this._spawnPointWaveSetup = this.setupArenaWaveSpawns;
               this._spawnPointSelector = this.selectNextArenaSpawnPoint;
               initZs = this._missionData.initZombieData;
               zombieXML = this._zombieDefinitions.zombies.zombie.(@id == initZs[1])[0];
               if(zombieXML != null && Boolean(zombieXML.hasOwnProperty("@elite")))
               {
                  this._arenaEliteZombie = new ZombieData(int(initZs[0]),initZs[1],initZs[2]);
                  this._arenaEliteZombieSpawnTime = 15 * 1000;
                  queueStart++;
               }
            }
            else
            {
               this._spawnPointWaveSetup = this.setupRegularWaveSpawns;
               this._spawnPointSelector = this.selectNextRandomSpawnPoint;
            }
            this.populateZombieQueue(this._missionData.initZombieData,queueStart);
            if(this._zombieQueue.length > this._maxZombiesInWorld)
            {
               this._zombieQueue.length = this._maxZombiesInWorld;
            }
            this._spawnPointWaveSetup();
            availableSpawns = this._scene.spawnPointsStatic.concat();
            while(this._zombieQueue.length > 0 && availableSpawns.length > 0)
            {
               j = int(Math.random() * availableSpawns.length);
               this.spawnNextZombie(availableSpawns[j]);
               availableSpawns.splice(j,1);
            }
         }
      }
      
      public function direct(param1:Number, param2:Number) : void
      {
         var _loc4_:Vector3D = null;
         var _loc5_:Zombie = null;
         var _loc6_:Zombie = null;
         var _loc7_:Vector3D = null;
         var _loc8_:AIStateMachine = null;
         var _loc9_:Vector3D = null;
         var _loc10_:Cell = null;
         var _loc11_:Path = null;
         if(this.spawningEnabled)
         {
            if(this._isCompoundAttack)
            {
               if(this._zombieQueue.length <= 2)
               {
                  this.getZombies(10);
               }
               if(param2 >= this._nextSpawnTime)
               {
                  this._nextSpawnTime = param2 + this.minSpawnTime + int(1000 - this._missionData.opponent.level * 50);
                  this.spawnNextZombie(this._scene.spawnPointsPortals[int(Math.random() * this._scene.spawnPointsPortals.length)]);
               }
            }
            else if(this._waveIsRush)
            {
               if(this._zombieQueue.length == 0)
               {
                  this.getZombies(10,true);
               }
               else if(param2 >= this._rushEndTime)
               {
                  this._waveIsRush = false;
                  this._waveSpawnCount = this._waveSpawnTotal = 0;
                  this.resetNextWaveTime(param2);
                  this.rushEnded.dispatch();
               }
               else if(param2 >= this._nextSpawnTime && this._nextWaveSpawns.length > 0)
               {
                  this._nextSpawnTime = param2 + int(Number(Config.constant.RUSH_SPAWN_RATE) / this._rushIntensity * 1000);
                  this.spawnNextZombie(this._spawnPointSelector());
               }
            }
            else
            {
               if(this._waveActive)
               {
                  if(this._waveSpawnCount >= this._waveSpawnTotal)
                  {
                     if(this._zombies.length < 5)
                     {
                        this._waveActive = false;
                        this.resetNextWaveTime(param2);
                     }
                  }
                  else if(param2 >= this._nextSpawnTime && this._nextWaveSpawns.length > 0)
                  {
                     this._nextSpawnTime = param2 + 500;
                     this.spawnNextZombie(this._spawnPointSelector());
                  }
               }
               else if(param2 >= this._nextWaveTime)
               {
                  this.startNextWave(param2);
               }
               if(this._arenaEliteZombie != null)
               {
                  if(param2 - this._startTime > this._arenaEliteZombieSpawnTime)
                  {
                     _loc4_ = this._spawnPointSelector();
                     _loc5_ = this.spawnZombie(this._arenaEliteZombie,_loc4_,true);
                     if(_loc5_ != null)
                     {
                        this._arenaEliteZombie = null;
                        this.onArenaEliteSpawned(_loc5_);
                     }
                     else
                     {
                        this._arenaEliteZombieSpawnTime += 3000;
                     }
                  }
               }
            }
         }
         var _loc3_:int = int(this._zombies.length - 1);
         while(_loc3_ >= 0)
         {
            _loc6_ = this._zombies[_loc3_] as Zombie;
            if(_loc6_.health >= 0)
            {
               _loc7_ = _loc6_.actor.transform.position;
               _loc8_ = _loc6_.stateMachine;
               _loc6_.allowEvalThreats = this._agentThreatIndex == _loc3_;
               if(!_loc6_.inGameWorld)
               {
                  if(_loc6_.navigator.path == null && (_loc7_.x < this._tileMinX || _loc7_.x > this._tileMaxX || _loc7_.y < this._tileMinY || _loc7_.y > this._tileMaxY))
                  {
                     _loc9_ = new Vector3D(_loc7_.x < this._tileMinX ? this._tileMinX + this._tileSize : (_loc7_.x > this._tileMaxX ? this._tileMaxX - this._tileSize : _loc7_.x),_loc7_.y < this._tileMinY ? this._tileMinY + this._tileSize : (_loc7_.y > this._tileMaxY ? this._tileMaxY - this._tileSize : _loc7_.y),_loc7_.z);
                     _loc10_ = this._scene.map.getCellAtCoords(_loc9_.x,_loc9_.y);
                     _loc11_ = new Path();
                     _loc11_.waypoints.push(0,_loc10_.x,_loc10_.y);
                     _loc11_.numWaypoints = 1;
                     _loc11_.found = true;
                     _loc6_.stateMachine.clear();
                     _loc6_.navigator.ignore = true;
                     _loc6_.navigator.ignoreMap = true;
                     _loc6_.navigator.followPath(_loc11_);
                     _loc6_.navigator.pathCompleted.addOnce(this.onZombieEnterMap);
                  }
               }
               else
               {
                  if(_loc8_.state == null)
                  {
                     _loc6_.navigator.pathCompleted.removeAll();
                     _loc8_.setState(new ZombieHuntState(_loc6_));
                     _loc6_.allowEvalThreats = true;
                     _loc6_.agentData.attacking = false;
                     _loc6_.alertRating = 0;
                  }
                  _loc6_.agentData.inLOS = this._isCompoundAttack;
                  if(_loc6_.agentData.mustHaveLOSToTarget && !_loc6_.agentData.attacking)
                  {
                     _loc6_.checkLOSToAgents(_loc6_.blackboard.enemies);
                  }
               }
            }
            _loc6_.update(param1,param2);
            _loc3_--;
         }
         if(++this._agentThreatIndex >= this._zombies.length)
         {
            this._agentThreatIndex = 0;
         }
         this._lastTime = param2;
      }
      
      public function removeZombie(param1:Zombie) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:int = int(this._zombies.indexOf(param1));
         if(_loc2_ > -1)
         {
            this._zombies.splice(_loc2_,1);
         }
         param1.navigator.targetUnreachable.removeAll();
         param1.navigator.map = null;
         param1.dispose();
      }
      
      public function forceRushWave() : void
      {
         this._forceRushWave = true;
      }
      
      private function populateZombieQueue(param1:Array, param2:int = 0) : int
      {
         var _loc7_:ZombieData = null;
         if(param1 == null)
         {
            return 0;
         }
         var _loc3_:int = 0;
         var _loc4_:int = 3;
         var _loc5_:int = param2 * _loc4_;
         var _loc6_:int = int(param1.length);
         while(_loc5_ < _loc6_)
         {
            _loc7_ = new ZombieData(int(param1[_loc5_]),param1[_loc5_ + 1],param1[_loc5_ + 2]);
            this._zombieQueue.push(_loc7_);
            _loc3_++;
            _loc5_ += _loc4_;
         }
         return _loc3_;
      }
      
      private function resetNextWaveTime(param1:Number) : void
      {
         var _loc2_:Number = this._waveTimeMin + (this._waveTimeMax - this._waveTimeMin) * Math.random();
         var _loc3_:Number = int((_loc2_ - this._threatRating) * 1000);
         this._nextWaveTime = param1 + _loc3_;
      }
      
      private function setupArenaWaveSpawns() : void
      {
         var _loc1_:Vector.<Vector3D> = this._scene.spawnPointsPortals;
         if(_loc1_.length <= 0)
         {
            this._nextWaveSpawns.length = 0;
            return;
         }
         this._nextWaveSpawns.length = _loc1_.length;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            this._nextWaveSpawns[_loc2_] = _loc1_[_loc2_];
            _loc2_++;
         }
         this._nextWaveSpawns.sort(this.randomizeArray);
         this._arenaSpawnPtIndex = 0;
      }
      
      private function setupRegularWaveSpawns() : void
      {
         this._nextWaveSpawns.length = 0;
         var _loc1_:Vector.<Vector3D> = this.getSortedPortals();
         if(_loc1_.length <= 0)
         {
            this._nextWaveSpawns.length = 0;
            return;
         }
         var _loc2_:int = this._randomPortalSpawning ? int(_loc1_.length) : int(Math.min(2,_loc1_.length));
         this._nextWaveSpawns.length = _loc2_;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            this._nextWaveSpawns[_loc3_] = _loc1_[_loc3_];
            _loc3_++;
         }
      }
      
      private function selectNextRandomSpawnPoint() : Vector3D
      {
         var _loc1_:int = int(Math.random() * this._nextWaveSpawns.length);
         return this._nextWaveSpawns[_loc1_];
      }
      
      private function selectNextArenaSpawnPoint() : Vector3D
      {
         var _loc1_:Vector3D = this._nextWaveSpawns[this._arenaSpawnPtIndex++];
         if(this._arenaSpawnPtIndex >= this._nextWaveSpawns.length)
         {
            this.setupArenaWaveSpawns();
         }
         return _loc1_;
      }
      
      private function startNextWave(param1:Number) : void
      {
         var chance:Number = NaN;
         var timeIntensityMult:Number = NaN;
         var spawnMax:Number = NaN;
         var time:Number = param1;
         if(this.serverSpawningDisabled)
         {
            return;
         }
         this._waveActive = true;
         this._waveSpawnCount = 0;
         this._nextSpawnTime = 0;
         this._spawnPointWaveSetup();
         if(this._nextWaveSpawns.length == 0)
         {
            return;
         }
         if(this._forceRushWave)
         {
            this._waveIsRush = true;
            this._forceRushWave = false;
         }
         else if(this._missionData.assignmentType == AssignmentType.Arena)
         {
            this._waveIsRush = false;
         }
         else if(this._zombieLevel >= Config.constant.RUSH_MIN_LEVEL && this._rushCount < Config.constant.RUSH_MAX && time - this._startTime > Config.constant.RUSH_MIN_MISSION_TIME_PASSED * 1000)
         {
            chance = this._rushChance;
            if(_consecutiveSessionsWithoutRush > 2)
            {
               chance *= 1.5;
            }
            if(this._missionData.highActivityIndex > -1)
            {
               chance *= Config.constant.HAZ_ZOMBIE_RUSH_CHANCE_MULTIPLIER;
            }
            this._waveIsRush = Math.random() < chance;
         }
         if(this._waveIsRush)
         {
            this._rushIntensity = 1 + int(MathUtils.clamp01(this._zombieLevel / 50)) * 3;
            if(Math.random() < 0.25)
            {
               ++this._rushIntensity;
            }
            if(this._rushIntensity > 3)
            {
               this._rushIntensity = 3;
            }
            timeIntensityMult = 0.5 + this._rushIntensity / 3 * 0.5;
            this._rushEndTime = time + Math.max(int((Config.constant.RUSH_MAX_TIME - Config.constant.RUSH_MIN_TIME) * 1000 * this._mapSizeMultiplier * timeIntensityMult),Config.constant.RUSH_MIN_TIME);
            this._rushChance *= Config.constant.RUSH_CHANCE_MOD;
            ++this._rushCount;
            this._waveSpawnTotal = 20;
         }
         else
         {
            spawnMax = this._waveSpawnMax;
            if(this._missionData.highActivityIndex > -1)
            {
               spawnMax *= Config.constant.HAZ_ZOMBIE_WAVE_COUNT_MULTIPLIER;
            }
            this._waveSpawnTotal = Math.min(int(spawnMax * 0.5 + spawnMax * Math.random()),spawnMax);
         }
         Network.getInstance().save({
            "n":this._waveSpawnTotal,
            "r":this._waveIsRush
         },SaveDataMethod.MISSION_ZOMBIES,function(param1:Object):void
         {
            if(_disposed || param1 == null)
            {
               return;
            }
            if(param1.error != null || param1.max === true)
            {
               serverSpawningDisabled = true;
               return;
            }
            if(!param1.z)
            {
               return;
            }
            _waveSpawnTotal = populateZombieQueue(param1.z);
            if(_waveIsRush)
            {
               _consecutiveSessionsWithoutRush = 0;
               rushStarted.dispatch(_rushIntensity);
            }
         });
      }
      
      private function getSortedPortals() : Vector.<Vector3D>
      {
         var spawns:Vector.<Vector3D> = this._scene.spawnPointsPortals.concat();
         if(this._missionData.assignmentType == AssignmentType.Arena)
         {
            return spawns;
         }
         spawns.sort(function(param1:Vector3D, param2:Vector3D):int
         {
            var _loc5_:Survivor = null;
            var _loc6_:Number = NaN;
            var _loc7_:Number = NaN;
            var _loc8_:Number = NaN;
            var _loc9_:Number = NaN;
            var _loc3_:Number = Number.MAX_VALUE;
            var _loc4_:Number = Number.MAX_VALUE;
            for each(_loc5_ in _missionData.survivors)
            {
               if(!(_loc5_ == null || _loc5_.health <= 0))
               {
                  _loc6_ = _loc5_.navigator.position.x - param1.x;
                  _loc7_ = _loc5_.navigator.position.y - param1.y;
                  _loc8_ = _loc6_ * _loc6_ + _loc7_ * _loc7_;
                  if(_loc8_ < _loc3_)
                  {
                     _loc3_ = _loc8_;
                  }
                  _loc6_ = _loc5_.navigator.position.x - param2.x;
                  _loc7_ = _loc5_.navigator.position.y - param2.y;
                  _loc9_ = _loc6_ * _loc6_ + _loc7_ * _loc7_;
                  if(_loc9_ < _loc4_)
                  {
                     _loc4_ = _loc9_;
                  }
               }
            }
            return _loc3_ - _loc4_;
         });
         return spawns;
      }
      
      private function getZombies(param1:int, param2:Boolean = false) : void
      {
         var num:int = param1;
         var rushOnly:Boolean = param2;
         if(this._gettingZombies)
         {
            return;
         }
         if(this.serverSpawningDisabled)
         {
            return;
         }
         this._gettingZombies = true;
         Network.getInstance().save({
            "n":num,
            "r":rushOnly
         },SaveDataMethod.MISSION_ZOMBIES,function(param1:Object):void
         {
            _gettingZombies = false;
            if(_disposed || param1 == null)
            {
               return;
            }
            if(param1.error != null || param1.max === true)
            {
               serverSpawningDisabled = true;
               return;
            }
            populateZombieQueue(param1.z);
         });
      }
      
      private function spawnNextZombie(param1:Vector3D) : void
      {
         if(this._zombies.length >= this._maxZombiesInWorld)
         {
            return;
         }
         if(!ahsaved && this._maxZombiesInWorld > 20)
         {
            ahsaved = true;
            Network.getInstance().save({
               "id":"maxzc",
               "count":this._maxZombiesInWorld
            },SaveDataMethod.AH_EVENT);
         }
         if(this._zombieQueue == null || this._zombieQueue.length == 0)
         {
            return;
         }
         var _loc2_:ZombieData = this._zombieQueue.shift();
         this.spawnZombie(_loc2_,param1);
      }
      
      private function spawnZombie(param1:ZombieData, param2:Vector3D, param3:Boolean = false) : Zombie
      {
         var zombieXML:XML = null;
         var zombie:Zombie = null;
         var zombieWeaponXML:XML = null;
         var pos:Vector3D = null;
         var timeElapsed:Number = NaN;
         var timeRemaining:Number = NaN;
         var zombieData:ZombieData = param1;
         var spawnPt:Vector3D = param2;
         var ignoreEliteRules:Boolean = param3;
         zombieXML = this._zombieDefinitions.zombies.zombie.(@id == zombieData.type)[0];
         if(zombieXML == null)
         {
            return null;
         }
         zombie = EnemyFactory.createEnemy(zombieXML["@class"].toString());
         if(zombie == null)
         {
            return null;
         }
         zombieWeaponXML = this._zombieDefinitions.weapons.item.(@id == zombieData.weapon)[0];
         zombie.enemyId = zombieData.id;
         zombie.setDefinition(zombieXML,this._zombieLevel,zombieWeaponXML);
         zombie.actor.name = "zombie" + zombie.enemyId;
         if(!ignoreEliteRules && zombie.isElite)
         {
            if(this._waveIsRush)
            {
               zombie.dispose();
               return null;
            }
            timeElapsed = Math.max(this._lastTime - this._startTime,0) / 1000;
            timeRemaining = this._missionData.missionTime - timeElapsed;
            if(timeRemaining < Number(Config.constant.MISSION_ZOMBIE_ELITE_MIN_TIME))
            {
               zombie.dispose();
               return null;
            }
         }
         pos = zombie.actor.transform.position;
         pos.x = spawnPt.x;
         pos.y = spawnPt.y;
         pos.z = spawnPt.z;
         zombie.actor.transform.setRotationEuler(0,0,spawnPt.w);
         zombie.actor.targetForward = null;
         zombie.actor.alpha = 0;
         zombie.isRushZombie = this._waveIsRush;
         zombie.spawnTime = this._lastTime;
         zombie.inGameWorld = !(pos.x < this._tileMinX || pos.x > this._tileMaxX || pos.y < this._tileMinY || pos.y > this._tileMaxY);
         zombie.maxPathLength = this._tileSize * 400;
         if(this._isCompoundAttack || this._waveIsRush || this._missionData.assignmentType == AssignmentType.Arena)
         {
            zombie.agentData.mustHaveLOSToTarget = false;
            zombie.agentData.visionRange = Number.POSITIVE_INFINITY;
            zombie.switchToChase();
         }
         else
         {
            zombie.agentData.mustHaveLOSToTarget = true;
            zombie.switchToWander();
         }
         zombie.navigator.pathOptions.allowClosestNodeToGoal = true;
         zombie.stateMachine.clear();
         if(zombie.inGameWorld)
         {
            zombie.stateMachine.setState(new ZombieHuntState(zombie));
         }
         zombie.damageTaken.add(this.onZombieDamageTaken);
         this._zombies.push(zombie);
         ++this._numZombiesSpawned;
         ++this._waveSpawnCount;
         this.zombieSpawned.dispatch(zombie);
         if(zombie.isElite)
         {
            Network.getInstance().save(null,SaveDataMethod.MISSION_ELITE_SPAWNED);
         }
         return zombie;
      }
      
      private function setZombieHuntTarget(param1:Zombie, param2:ThreatData) : void
      {
         var alreadyAlerted:Boolean;
         var targetPt:Vector3D = null;
         var altertedState:ZombieAlertedState = null;
         var zombie:Zombie = param1;
         var threat:ThreatData = param2;
         if(zombie.health <= 0)
         {
            return;
         }
         alreadyAlerted = zombie.alertRating == 0 || zombie.blackboard.lastKnownAgentPos[threat.agent] != null;
         if(threat.agent != null)
         {
            targetPt = threat.agent.entity.transform.position;
            zombie.alertRating = int.MAX_VALUE;
         }
         else
         {
            if(threat.noise == null)
            {
               return;
            }
            targetPt = threat.noise.position;
            zombie.alertRating = threat.noise.volume;
         }
         if(!alreadyAlerted && !this._isCompoundAttack && zombie.spawnTime < this._lastTime - 1000)
         {
            altertedState = new ZombieAlertedState(zombie,targetPt);
            altertedState.completed.addOnce(function(param1:Zombie):void
            {
               zombie.stateMachine.setState(new ZombieHuntState(zombie));
            });
            zombie.stateMachine.setState(altertedState);
            return;
         }
         zombie.stateMachine.setState(new ZombieHuntState(zombie));
      }
      
      public function onZombieDamageTaken(param1:Zombie, param2:Number, param3:Object = null, param4:Boolean = false) : void
      {
         if(param1.health <= 0 || param1.agentData.target != null)
         {
            return;
         }
         if(param3 is AIAgent)
         {
            param1.alertRating = 100;
            param1.agentData.target = param3 as AIAgent;
            param1.agentData.targetNoise = null;
            param1.stateMachine.setState(new ZombieHuntState(param1));
         }
      }
      
      private function onZombieEnterMap(param1:NavigatorAgent, param2:Path) : void
      {
         param1.ignore = false;
         param1.ignoreMap = false;
         var _loc3_:Zombie = Zombie(param1.aiAgent);
         _loc3_.inGameWorld = true;
         _loc3_.allowEvalThreats = true;
         _loc3_.stateMachine.clear();
         _loc3_.stateMachine.setState(new ZombieHuntState(_loc3_));
      }
      
      private function onArenaEliteSpawned(param1:Zombie) : void
      {
      }
      
      private function randomizeArray(param1:*, param2:*) : int
      {
         return Math.random() > 0.5 ? 1 : -1;
      }
      
      public function get threatRating() : Number
      {
         return this._threatRating;
      }
      
      public function get maxWaveTime() : Number
      {
         return this._waveTimeMax;
      }
   }
}

class ZombieData
{
   
   public var id:int;
   
   public var type:String;
   
   public var weapon:String;
   
   public function ZombieData(param1:int, param2:String, param3:String)
   {
      super();
      this.id = param1;
      this.type = param2;
      this.weapon = param3;
   }
}
