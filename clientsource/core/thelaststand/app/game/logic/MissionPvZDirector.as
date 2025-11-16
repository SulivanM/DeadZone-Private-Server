package thelaststand.app.game.logic
{
   import com.deadreckoned.threshold.navigation.core.NavAgent;
   import com.exileetiquette.sound.SoundData;
   import com.greensock.TweenMax;
   import com.junkbyte.console.Cc;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.game.Game;
   import thelaststand.app.game.data.AssignmentPosition;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.BuildingCollection;
   import thelaststand.app.game.data.Gear;
   import thelaststand.app.game.data.ItemAttributes;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.RaiderOpponentData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.Zombie;
   import thelaststand.app.game.data.assignment.AssignmentType;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.entities.EntityFlags;
   import thelaststand.app.game.entities.buildings.BuildingEntity;
   import thelaststand.app.game.entities.buildings.DoorBuildingEntity;
   import thelaststand.app.game.entities.effects.Explosion;
   import thelaststand.app.game.gui.GameGUI;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.app.game.logic.ai.states.ActorSuppressedState;
   import thelaststand.app.game.logic.ai.states.BuildingStateFactory;
   import thelaststand.app.game.logic.ai.states.IAITrapState;
   import thelaststand.app.game.logic.ai.states.SurvivorAlertState;
   import thelaststand.app.game.scenes.BaseScene;
   import thelaststand.app.game.scenes.HumanSpawnPoint;
   import thelaststand.app.gui.MouseCursors;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   import thelaststand.engine.map.Cell;
   import thelaststand.engine.map.Path;
   import thelaststand.engine.map.TraversalArea;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   
   public class MissionPvZDirector extends MissionDirector
   {
      
      private var _rushActive:Boolean = false;
      
      private var _rushXP:int = 0;
      
      private var _zombieDirector:ZombieDirector;
      
      private var _mouseOverBuilding:BuildingEntity;
      
      private var _buildingThreatLevels:Dictionary;
      
      private var _rushSound:SoundData;
      
      private var _timerExpired:Boolean = false;
      
      public function MissionPvZDirector(param1:Game, param2:BaseScene, param3:GameGUI)
      {
         super(param1,param2,param3);
         _guiMission.showHelpButton = false;
         this._buildingThreatLevels = new Dictionary(true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this._rushSound != null)
         {
            this._rushSound.stop();
            this._rushSound = null;
         }
         this._zombieDirector.dispose();
         this._zombieDirector = null;
      }
      
      override public function end() : void
      {
         var buildings:BuildingCollection = null;
         var numBuildings:int = 0;
         var i:int = 0;
         var building:Building = null;
         if(Network.getInstance().playerData.isAdmin)
         {
            Cc.addSlashCommand("rush",null);
         }
         if(_isCompoundAttack)
         {
            buildings = Network.getInstance().playerData.compound.buildings;
            numBuildings = buildings.numBuildings;
            i = 0;
            while(i < numBuildings)
            {
               building = buildings.getBuilding(i);
               building.buildingEntity.asset.visible = true;
               building.traversalArea = null;
               building.damageTaken.remove(onBuildingDamageTaken);
               building.died.remove(this.onBuildingDestroyed);
               building.entity.assetClicked.remove(this.onBuildingClicked);
               building.entity.assetMouseOver.remove(this.onMouseOverBuilding);
               building.entity.assetMouseOut.remove(this.onMouseOutBuilding);
               building.stateMachine.clear();
               building.mountedSurvivor = null;
               i++;
            }
         }
         super.end();
         this._zombieDirector.zombieSpawned.remove(this.onZombieSpawned);
         this._zombieDirector.rushStarted.remove(this.onZombieRushStarted);
         this._zombieDirector.rushEnded.remove(this.onZombieRushEnded);
         _buildingAgents = null;
         _interactiveBuildings = null;
         if(this._rushSound != null)
         {
            TweenMax.to(this._rushSound,1,{
               "volume":0,
               "onComplete":function():void
               {
                  if(_rushSound != null)
                  {
                     _rushSound.stop();
                     _rushSound = null;
                  }
               }
            });
         }
      }
      
      override public function start(param1:Number, ... rest) : void
      {
         var _loc8_:Survivor = null;
         var _loc9_:Vector3D = null;
         var _loc10_:int = 0;
         var _loc11_:AssignmentPosition = null;
         var _loc12_:Cell = null;
         var _loc13_:int = 0;
         var _loc14_:Cell = null;
         var _loc15_:BuildingCollection = null;
         var _loc16_:int = 0;
         var _loc17_:Rectangle = null;
         var _loc18_:Building = null;
         var _loc19_:TraversalArea = null;
         var _loc20_:Survivor = null;
         var _loc21_:HumanSpawnPoint = null;
         var _loc22_:int = 0;
         var _loc3_:Array = [param1];
         _loc3_ = _loc3_.concat(rest);
         var _loc4_:MissionData = MissionData(rest[0]);
         _useDeployZones = !_loc4_.isCompoundAttack();
         _hudIndicatorsVisible = _loc4_.isCompoundAttack() || !Network.getInstance().playerData.compound.effects.hasEffectType(EffectType.getTypeValue("MissionHUD"));
         if(_loc4_.isCompoundAttack())
         {
            _guiMission.ui_timer.showWarning = false;
         }
         super.start.apply(this,_loc3_);
         if(_assignmentData != null && _assignmentData.type == AssignmentType.Arena)
         {
            _useDeployZones = false;
         }
         this._zombieDirector = new ZombieDirector();
         this._zombieDirector.spawningEnabled = true;
         this._zombieDirector.zombieSpawned.add(this.onZombieSpawned);
         this._zombieDirector.rushStarted.add(this.onZombieRushStarted);
         this._zombieDirector.rushEnded.add(this.onZombieRushEnded);
         _guiMission.showHUD = !_isCompoundAttack && (_assignmentData == null || _assignmentData.type != AssignmentType.Arena);
         if(_isCompoundAttack)
         {
            _guiMission.ui_timer.timeUpMessage = Language.getInstance().getString("mission_time_kill");
            _hideUnseenEnemies = false;
         }
         else
         {
            _xpBonus = 1 + Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("MissionXP")) / 100;
         }
         var _loc5_:Number = 1 + Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("SurvivorHealth")) / 100;
         var _loc6_:XMLList = _scene.xmlDescriptor.player.spawn;
         var _loc7_:int = 0;
         while(_loc7_ < _missionData.survivors.length)
         {
            _loc8_ = _missionData.survivors[_loc7_];
            if(!addPlayerSurvivor(_loc8_,_loc5_))
            {
               if(_loc8_.actor.scene != null)
               {
                  _loc8_.actor.scene.removeEntity(_loc8_.actor);
               }
            }
            else
            {
               if(_isCompoundAttack)
               {
                  _loc8_.blackboard.buildings = null;
               }
               if(_isCompoundAttack)
               {
                  if(_loc8_.rallyAssignment != null)
                  {
                     _loc10_ = int(_loc8_.rallyAssignment.assignedSurvivors.indexOf(_loc8_));
                     if(_loc10_ > -1)
                     {
                        _loc11_ = _loc8_.rallyAssignment.buildingEntity.getAssignPositions()[_loc10_];
                        if(_loc11_ != null)
                        {
                           if(_loc11_.height > 0 && (_loc8_.rallyAssignment.dead || _loc8_.weaponData.isMelee))
                           {
                              _loc12_ = _loc8_.rallyAssignment.buildingEntity.getDoorTile();
                              _loc9_ = _scene.map.getCellCoords(_loc12_.x,_loc12_.y);
                              _loc8_.actor.transform.position.setTo(_loc9_.x,_loc9_.y,0);
                           }
                           else
                           {
                              _loc9_ = _scene.map.getCellCoords(_loc11_.cell.x,_loc11_.cell.y);
                              _loc8_.actor.transform.position.setTo(_loc9_.x,_loc9_.y,_loc11_.height);
                              if(_loc8_.rallyAssignment.doorPosition != null)
                              {
                                 _loc8_.rallyAssignment.mountedSurvivor = _loc8_;
                                 _loc8_.mountedBuilding = _loc8_.rallyAssignment;
                              }
                           }
                           _loc8_.actor.transform.setRotationEuler(0,0,Math.PI * 2 * Math.random());
                        }
                     }
                  }
                  _loc8_.agentData.visionRange = Number.POSITIVE_INFINITY;
                  _loc8_.agentData.waitInCover = false;
               }
               else
               {
                  _loc9_ = _scene.spawnPointsPlayer[_loc7_];
                  _loc8_.actor.transform.position.x = _loc9_.x;
                  _loc8_.actor.transform.position.y = _loc9_.y;
                  _loc8_.actor.transform.setRotationEuler(0,0,_loc9_.w);
                  _loc13_ = 4000;
                  _loc8_.agentData.visionRange = _loc13_ + _loc13_ * (Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("VisionRange")) / 100);
                  _loc8_.agentData.waitInCover = true;
               }
               _loc8_.agentData.mustHaveLOSToTarget = true;
               _loc8_.agentData.guardPoint.copyFrom(_loc8_.actor.transform.position);
               _loc8_.autoTarget = _isCompoundAttack || !Network.getInstance().playerData.compound.effects.hasEffectType(EffectType.getTypeValue("ManualTargeting"));
               if(_loc8_.weaponData.isMelee)
               {
                  if(_useDeployZones)
                  {
                     _loc14_ = _scene.map.getCellAtCoords(_loc8_.actor.transform.position.x,_loc8_.actor.transform.position.y);
                     _loc8_.agentData.pursueTargets = _loc14_ != null && !isTileInDeploymentZone(_loc14_.x,_loc14_.y);
                  }
                  else
                  {
                     _loc8_.agentData.pursueTargets = true;
                  }
               }
            }
            _loc7_++;
         }
         if(_isCompoundAttack)
         {
            _loc15_ = Network.getInstance().playerData.compound.buildings;
            _loc16_ = _loc15_.numBuildings;
            _loc17_ = new Rectangle();
            _loc7_ = 0;
            while(_loc7_ < _loc16_)
            {
               _loc18_ = _loc15_.getBuilding(_loc7_);
               _loc18_.buildingEntity.hideAssignPositions();
               _loc18_.buildingEntity.showAssignFlags(false);
               _loc18_.resetHealth();
               if(!_loc18_.buildingEntity.passable && _loc18_.destroyable && !_loc18_.isTrap && !_loc18_.isDecoyTrap)
               {
                  _loc18_.buildingEntity.getFootprintRect(_loc18_.tileX,_loc18_.tileY,_loc17_);
                  ++_loc17_.width;
                  ++_loc17_.height;
                  _loc19_ = _scene.map.addTraversalArea(_loc17_,15);
                  _loc19_.data = _loc18_;
                  _loc18_.traversalArea = _loc19_;
               }
               if(_loc18_.health <= 0 || _loc18_.isDecoyTrap)
               {
                  if(_loc18_.isTrap)
                  {
                     _loc18_.buildingEntity.asset.visible = false;
                  }
               }
               else if(_loc18_.isTrap && !_missionData.useTraps)
               {
                  _loc18_.buildingEntity.asset.visible = false;
                  _loc18_.stateMachine.setState(null);
               }
               else
               {
                  if(_loc18_.destroyable || _loc18_.isTrap)
                  {
                     _loc18_.damageTaken.add(onBuildingDamageTaken);
                     _loc18_.died.add(this.onBuildingDestroyed);
                     _buildingAgents.push(_loc18_);
                  }
                  if(_loc18_.isDoor || _loc18_.assignable && _loc18_.doorPosition != null)
                  {
                     _loc18_.entity.assetClicked.add(this.onBuildingClicked);
                     _loc18_.entity.assetMouseOver.add(this.onMouseOverBuilding);
                     _loc18_.entity.assetMouseOut.add(this.onMouseOutBuilding);
                     _interactiveBuildings.push(_loc18_);
                     if(_loc18_.isDoor)
                     {
                        if(DoorBuildingEntity(_loc18_.buildingEntity).isOpen)
                        {
                           DoorBuildingEntity(_loc18_.buildingEntity).toggleOpen();
                        }
                     }
                  }
                  if(_loc18_.isTrap)
                  {
                     _loc18_.blackboard.erase();
                     _loc18_.blackboard.allAgents = _allAgents;
                     _loc18_.blackboard.friends = _survivors;
                     _loc18_.blackboard.enemies = _enemies;
                     _loc18_.blackboard.scene = _scene;
                     _loc18_.stateMachine.setState(BuildingStateFactory.getState(_loc18_));
                  }
               }
               _loc7_++;
            }
         }
         else
         {
            _loc17_ = new Rectangle();
            _loc7_ = 0;
            while(_loc7_ < _scene.buildings.length)
            {
               _loc18_ = _scene.buildings[_loc7_];
               _loc18_.resetHealth();
               if(_loc18_.entity.scene != _scene)
               {
                  _scene.addEntity(_loc18_.buildingEntity);
               }
               _scene.map.updateCellsForEntity(_loc18_.buildingEntity);
               if(_loc18_.buildingEntity.passable == false && _loc18_.destroyable == true && _loc18_.isTrap == false && _loc18_.isDecoyTrap == false)
               {
                  if((_loc18_.buildingEntity.flags & GameEntityFlags.USE_FOOTPRINT_FOR_TILEMAP) != 0)
                  {
                     _loc18_.buildingEntity.getFootprintRect(_loc18_.tileX,_loc18_.tileY,_loc17_);
                  }
                  else
                  {
                     _loc17_ = _loc18_.buildingEntity.getOccupyingRectangle();
                  }
                  ++_loc17_.width;
                  ++_loc17_.height;
                  _loc19_ = _scene.map.addTraversalArea(_loc17_,0);
                  _loc19_.data = _loc18_;
                  _loc18_.traversalArea = _loc19_;
               }
               if(_loc18_.health > 0)
               {
                  _interactiveBuildings.push(_loc18_);
                  _buildingAgents.push(_loc18_);
                  _allAgents.push(_loc18_);
                  if(_loc18_.destroyable || _loc18_.isTrap)
                  {
                     _loc18_.entity.assetMouseOver.add(super.onMouseOverBuilding);
                     _loc18_.entity.assetMouseOut.add(super.onMouseOutBuilding);
                     _loc18_.entity.assetClicked.add(super.onBuildingClicked);
                     _loc18_.entity.asset.mouseEnabled = !(_missionData.opponent is RaiderOpponentData);
                     _loc18_.damageTaken.add(onBuildingDamageTaken);
                     _loc18_.died.add(this.onBuildingDestroyed);
                  }
                  if(_loc18_.isTrap)
                  {
                     _loc18_.blackboard.erase();
                     _loc18_.blackboard.allAgents = _allAgents;
                     _loc18_.blackboard.friends = _enemies;
                     _loc18_.blackboard.enemies = _survivors;
                     _loc18_.blackboard.scene = _scene;
                     _loc18_.stateMachine.setState(BuildingStateFactory.getState(_loc18_));
                     IAITrapState(_loc18_.stateMachine.state).triggered.addOnce(onTrapTriggered);
                     _loc18_.buildingEntity.asset.visible = (_loc18_.flags & EntityFlags.TRAP_DETECTED) != 0;
                     _trapAgents.push(_loc18_);
                  }
               }
               else if(_loc18_.isTrap)
               {
                  _scene.removeEntity(_loc18_.buildingEntity);
               }
               _loc7_++;
            }
            _loc7_ = 0;
            while(_loc7_ < _missionData.humanEnemies.length)
            {
               _loc20_ = _missionData.humanEnemies[_loc7_] as Survivor;
               if(_loc20_ != null)
               {
                  _loc21_ = _scene.spawnPointsHuman[_loc7_];
                  addEnemy(_loc20_,1);
                  _loc20_.actor.transform.position.copyFrom(_loc21_.position);
                  _loc20_.actor.transform.setRotationEuler(0,0,Math.PI * 2 * Math.random());
                  _loc20_.actor.targetForward = null;
                  _loc20_.actor.updateTransform();
                  _loc13_ = 4000;
                  _loc20_.agentData.guardPoint.copyFrom(_loc20_.actor.transform.position);
                  _loc20_.agentData.pursueTargets = false;
                  _loc20_.agentData.mustHaveLOSToTarget = true;
                  _loc20_.agentData.visionRange = _loc13_;
                  _loc20_.agentData.waitInCover = true;
                  _loc20_.agentData.canCauseBackCriticals = false;
                  _loc20_.agentData.inLOS = false;
                  _loc20_.weaponData.accuracy *= 1;
                  if(_loc21_.building != null)
                  {
                     if(_loc21_.building.buildingData.doorPosition != null)
                     {
                        _loc21_.building.buildingData.mountedSurvivor = _loc20_;
                        _loc20_.mountedBuilding = _loc21_.building.buildingData;
                     }
                  }
               }
               _loc7_++;
            }
         }
         updateCoverRatingsForAgents(_survivors);
         updateCoverRatingsForAgents(_missionData.humanEnemies);
         _guiMission.ui_survivorBar.survivors = _missionData.survivors;
         if(_survivors.length > 0)
         {
            selectSurvivor(_survivors[0] as Survivor);
            if(!_isCompoundAttack)
            {
               _scene.centerOn(_survivors[0].actor.transform.position.x,_survivors[0].actor.transform.position.y,0);
            }
         }
         this._zombieDirector.start(param1,_scene,_missionData);
         this.updateBuildingInteractivity();
         this.updateBuildingThreatLevels();
         if(Network.getInstance().playerData.isAdmin)
         {
            if(!_isCompoundAttack)
            {
               Cc.addSlashCommand("rush",this._zombieDirector.forceRushWave);
            }
         }
         if(!_isCompoundAttack)
         {
            _loc22_ = 0;
            if(_missionData.allianceMatch && _missionData.allianceAttackerWinPoints > 0)
            {
               _loc22_ = _missionData.allianceAttackerWinPoints;
            }
            _guiMission.setupProgressPanel(_scene.totalSearchableEntities,_loc22_);
         }
      }
      
      override public function update(param1:Number, param2:Number) : void
      {
         var _loc5_:AIActorAgent = null;
         if(!_missionActive)
         {
            return;
         }
         var _loc3_:int = 0;
         var _loc4_:int = int(_missionData.humanEnemies.length);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = _missionData.humanEnemies[_loc3_];
            _loc5_.checkLOSToAgents(_survivors);
            if(_loc5_.health > 0 && _loc5_.stateMachine.state == null)
            {
               if(_loc5_.agentData.suppressed)
               {
                  _loc5_.stateMachine.setState(new ActorSuppressedState(_loc5_));
                  setSuppressionIndicatorState(_loc5_,true);
               }
               else
               {
                  _loc5_.stateMachine.setState(new SurvivorAlertState(_loc5_ as Survivor));
               }
            }
            _loc5_.update(param1,param2);
            _loc3_++;
         }
         this._zombieDirector.direct(param1,param2);
         super.update(param1,param2);
      }
      
      override protected function setActionModeState(param1:Boolean) : void
      {
         if(param1 == _actionMode)
         {
            return;
         }
         super.setActionModeState(param1);
         this.updateBuildingInteractivity();
      }
      
      private function updateBuildingInteractivity() : void
      {
         var _loc1_:Building = null;
         var _loc2_:Boolean = false;
         for each(_loc1_ in _interactiveBuildings)
         {
            _loc2_ = false;
            if(_missionData.opponent is RaiderOpponentData)
            {
               if(_actionMode && _selectedSurvivor != null)
               {
                  _loc2_ = _loc1_.destroyable && _loc1_.health > 0;
               }
               else
               {
                  _loc2_ = false;
               }
               _loc1_.entity.asset.mouseChildren = _loc2_;
               _loc1_.entity.asset.mouseEnabled = _loc2_;
            }
            else
            {
               if(_loc1_.destroyable && _loc1_.health <= 0)
               {
                  _loc2_ = false;
               }
               else if(_loc1_.isDoor)
               {
                  _loc2_ = true;
               }
               else if(_loc1_.doorPosition)
               {
                  if(_loc1_.mountedSurvivor != null || _selectedSurvivor != null)
                  {
                     _loc2_ = true;
                  }
               }
               _loc1_.entity.asset.mouseChildren = _loc2_;
            }
         }
      }
      
      private function dismountSurvivor(param1:Building) : void
      {
         var doorCell:Cell = null;
         var srv:Survivor = null;
         var building:Building = param1;
         doorCell = building.buildingEntity.getDoorTile();
         if(doorCell == null)
         {
            return;
         }
         srv = building.mountedSurvivor;
         srv.actor.fade(0,0.25,0,function():void
         {
            srv.navigator.setPositionToCell(doorCell.x,doorCell.y);
            srv.navigator.position.z = 0;
            srv.agentData.guardPoint.copyFrom(srv.navigator.position);
            srv.agentData.useGuardPoint = true;
            srv.actor.fade(1,0.25);
            building.mountedSurvivor = null;
            srv.mountedBuilding = null;
            updateCoverRating(srv);
            if(_mouseOverBuilding == building.buildingEntity)
            {
               MouseCursors.setCursor(MouseCursors.MOUNT_BUILDING);
            }
         });
      }
      
      private function mountSurvivor(param1:Survivor, param2:Building) : void
      {
         var doorCell:Cell;
         var srv:Survivor = param1;
         var building:Building = param2;
         if(building.mountedSurvivor != null || !building.assignable || building.doorPosition == null)
         {
            return;
         }
         doorCell = building.buildingEntity.getDoorTile();
         srv.navigator.resume();
         srv.navigator.moveToCell(doorCell.x,doorCell.y);
         srv.navigator.pathCompleted.addOnce(function(param1:NavAgent, param2:Path):void
         {
            var agent:NavAgent = param1;
            var path:Path = param2;
            if(building.mountedSurvivor != null || srv.health <= 0)
            {
               return;
            }
            srv.agentData.useGuardPoint = false;
            srv.agentData.guardPoint.copyFrom(srv.actor.transform.position);
            if(!path.goalFound)
            {
               return;
            }
            building.mountedSurvivor = srv;
            srv.mountedBuilding = building;
            if(_mouseOverBuilding == building.buildingEntity)
            {
               MouseCursors.setCursor(MouseCursors.DISMOUNT_BUILDING);
            }
            srv.actor.fade(0,0.25,0,function():void
            {
               var _loc1_:AssignmentPosition = building.buildingEntity.getAssignPositions()[0];
               var _loc2_:Vector3D = _scene.map.getCellCoords(_loc1_.cell.x,_loc1_.cell.y);
               srv.navigator.cancelAndStop();
               srv.actor.transform.position.setTo(_loc2_.x,_loc2_.y,_loc1_.height);
               srv.stateMachine.setState(null);
               updateCoverRating(srv);
               srv.actor.fade(1,0.25);
            });
         });
      }
      
      private function updateBuildingThreatLevels() : void
      {
         var _loc1_:Building = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Survivor = null;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         for each(_loc1_ in _buildingAgents)
         {
            if(_loc1_.dead)
            {
               delete this._buildingThreatLevels[_loc1_];
            }
            else
            {
               _loc2_ = 0;
               _loc3_ = _loc1_.entity.transform.position.x + _loc1_.buildingEntity.centerPoint.x;
               _loc4_ = _loc1_.entity.transform.position.y + _loc1_.buildingEntity.centerPoint.y;
               for each(_loc5_ in _survivors)
               {
                  _loc7_ = _loc5_.navigator.position.x - _loc3_;
                  _loc8_ = _loc5_.navigator.position.y - _loc4_;
                  _loc9_ = _loc7_ * _loc7_ + _loc8_ * _loc8_;
                  _loc2_ -= _loc9_ / 1000;
               }
               _loc6_ = int(_loc1_.buildingEntity.coveredAgents.length);
               _loc2_ += _loc6_ * 10000;
               this._buildingThreatLevels[_loc1_] = _loc2_;
            }
         }
      }
      
      override protected function onScavengeComplete(param1:Survivor, param2:GameEntity, param3:Number, param4:Number) : void
      {
         if(!_missionActive)
         {
            return;
         }
         ++_scavedCount;
         _guiMission.updateScavProgressPanel(_scavedCount);
         super.onScavengeComplete(param1,param2,param3,param4);
      }
      
      private function onZombieSpawned(param1:AIActorAgent) : void
      {
         addEnemy(param1);
         param1.actor.alpha = 0;
         param1.agentData.inLOS = false;
         param1.blackboard.buildings = _buildingAgents;
         param1.blackboard.buildingThreatLevels = this._buildingThreatLevels;
         if(_isCompoundAttack)
         {
            param1.actor.fade(1);
         }
         ++_missionData.stats.zombieSpawned;
      }
      
      private function onZombieRushStarted(param1:int) : void
      {
         var _loc2_:Survivor = null;
         this._rushActive = true;
         _guiMission.setRushState(param1);
         Audio.sound.play("sound/music/music-rush-start.mp3",{"volume":0.5});
         this._rushSound = Audio.sound.play("sound/music/music-rush-" + param1 + ".mp3",{
            "loops":-1,
            "volume":0.5
         });
         _scene.camera.shake(50);
         if(Math.random() < Config.constant.SURVIVOR_TALK_CHANCE_RUSHSTART)
         {
            _loc2_ = getRandomLivingSurvivor();
            if(_loc2_ != null)
            {
               startSurvivorSpeech(_loc2_,"rushstart",true);
            }
         }
      }
      
      private function onZombieRushEnded() : void
      {
         var srv:Survivor = null;
         this._rushActive = false;
         _guiMission.setRushState(0);
         MiniTaskSystem.getInstance().getAchievement("survivor").increment(1,this._rushXP);
         this._rushXP = 0;
         if(this._rushSound != null)
         {
            TweenMax.to(this._rushSound,2,{
               "volume":0,
               "onComplete":function():void
               {
                  if(_rushSound != null)
                  {
                     _rushSound.stop();
                     _rushSound = null;
                  }
               }
            });
         }
         if(Math.random() < Config.constant.SURVIVOR_TALK_CHANCE_RUSHEND)
         {
            srv = getRandomLivingSurvivor();
            if(srv != null)
            {
               startSurvivorSpeech(srv,"rushend",true);
            }
         }
      }
      
      override protected function onEnemyDie(param1:AIActorAgent, param2:Object) : void
      {
         var isExplosive:Boolean;
         var sourceSrv:Survivor = null;
         var sourceExplosion:Explosion = null;
         var srvIndex:int = 0;
         var baseXP:Number = NaN;
         var xp:int = 0;
         var bonusXP:int = 0;
         var zombie:Zombie = null;
         var human:Survivor = null;
         var enemy:AIActorAgent = param1;
         var source:Object = param2;
         super.onEnemyDie(enemy,source);
         if(!_missionActive)
         {
            return;
         }
         isExplosive = source is Explosion;
         if(isExplosive)
         {
            sourceExplosion = Explosion(source);
            sourceSrv = Explosion(source).owner as Survivor;
         }
         else
         {
            sourceSrv = source as Survivor;
         }
         if(sourceSrv != null)
         {
            zombie = enemy as Zombie;
            if(zombie != null)
            {
               baseXP = Number(Config.constant.BASE_ZOMBIE_KILL_XP);
               bonusXP = sourceSrv.activeLoadout.getLoadoutAttributeMod(ItemAttributes.GROUP_SURVIVOR,"infected_kill_xp") + Network.getInstance().playerData.compound.effects.attributes.getModValue(ItemAttributes.GROUP_SURVIVOR,"infected_kill_xp");
               xp = awardKillXP(baseXP,enemy,bonusXP);
               if(this._rushActive)
               {
                  this._rushXP += xp;
               }
               _missionData.zombieKills.push(zombie.enemyId,sourceSrv.missionIndex);
               ++_missionData.stats.zombieKills;
               _missionData.stats.addCustomStat(zombie.enemyType,"kills");
               if(_assignmentData != null)
               {
                  _missionData.stats.addCustomStat(_assignmentData.name,zombie.enemyType,"kills");
                  _missionData.stats.addCustomStat(_assignmentData.name,_assignmentData.getStage(_assignmentData.currentStageIndex).name,zombie.enemyType,"kills");
               }
               else if(_missionData.type == "compound")
               {
                  _missionData.stats.addCustomStat(_missionData.type,zombie.enemyType,"kills");
               }
               else
               {
                  _missionData.stats.addCustomStat(_missionData.locationClass,zombie.enemyType,"kills");
                  _missionData.stats.addCustomStat(_missionData.suburb,zombie.enemyType,"kills");
                  _missionData.stats.addCustomStat(_missionData.suburb,_missionData.locationClass,zombie.enemyType,"kills");
                  _missionData.stats.addCustomStat(_missionData.suburb,"kills");
                  _missionData.stats.addCustomStat(_missionData.suburb,_missionData.locationClass,"kills");
               }
               if(isExplosive)
               {
                  ++_missionData.stats.zombieExplosiveKills;
                  _missionData.stats.addGearKill(sourceExplosion.ownerItem as Gear,zombie.enemyType);
                  MiniTaskSystem.getInstance().getAchievement("expmassacre").increment(1,xp);
               }
               else
               {
                  _missionData.stats.addWeaponKill(sourceSrv.weapon,zombie.enemyType);
                  if(sourceSrv.weaponData.isMelee)
                  {
                     MiniTaskSystem.getInstance().getAchievement("meleemassacre").increment(1,xp);
                  }
                  else
                  {
                     MiniTaskSystem.getInstance().getAchievement("massacre").increment(1,xp);
                  }
               }
            }
            human = enemy as Survivor;
            if(human != null)
            {
               baseXP = Number(Config.constant.BASE_HUMAN_KILL_XP);
               bonusXP = sourceSrv.activeLoadout.getLoadoutAttributeMod(ItemAttributes.GROUP_SURVIVOR,"human_kill_xp") + Network.getInstance().playerData.compound.effects.attributes.getModValue(ItemAttributes.GROUP_SURVIVOR,"human_kill_xp");
               xp = awardKillXP(baseXP,enemy,bonusXP);
               _missionData.humanKills.push(human.enemyHumanId,sourceSrv.missionIndex);
               ++_missionData.stats.humanKills;
               _missionData.stats.addCustomStat(human.statId,"kills");
               if(_assignmentData != null)
               {
                  _missionData.stats.addCustomStat(_assignmentData.name,human.statId,"kills");
                  _missionData.stats.addCustomStat(_assignmentData.name,_assignmentData.getStage(_assignmentData.currentStageIndex).name,human.statId,"kills");
               }
               else
               {
                  _missionData.stats.addCustomStat(_missionData.locationClass,human.statId,"kills");
                  _missionData.stats.addCustomStat(_missionData.suburb,human.statId,"kills");
                  _missionData.stats.addCustomStat(_missionData.suburb,_missionData.locationClass,human.statId,"kills");
                  _missionData.stats.addCustomStat(_missionData.suburb,"kills");
                  _missionData.stats.addCustomStat(_missionData.suburb,_missionData.locationClass,"kills");
               }
               if(isExplosive)
               {
                  ++_missionData.stats.humanExplosiveKills;
                  _missionData.stats.addGearKill(sourceExplosion.ownerItem as Gear,human.statId);
                  MiniTaskSystem.getInstance().getAchievement("expmassacre").increment(1,xp);
               }
               else
               {
                  _missionData.stats.addWeaponKill(sourceSrv.weapon,human.statId);
                  if(sourceSrv.weaponData.isMelee)
                  {
                     MiniTaskSystem.getInstance().getAchievement("meleemassacre").increment(1,xp);
                  }
                  else
                  {
                     MiniTaskSystem.getInstance().getAchievement("massacre").increment(1,xp);
                  }
               }
            }
         }
         enemy.actor.fade(0,0.5,6,function():void
         {
            if(enemy != null && _zombieDirector != null)
            {
               _zombieDirector.removeZombie(enemy as Zombie);
            }
         });
      }
      
      override protected function onTimeExpired() : void
      {
         this._zombieDirector.spawningEnabled = false;
         if(_isCompoundAttack)
         {
            if(_enemies.length == 0)
            {
               super.onTimeExpired();
            }
         }
         else if(!this._timerExpired)
         {
            super.onTimeExpired();
            Tracking.trackEvent("Mission","TimerExpired");
            this._timerExpired = true;
         }
      }
      
      override protected function onMouseOverBuilding(param1:BuildingEntity) : void
      {
         this._mouseOverBuilding = param1;
         ui_entityRollover.entity = param1;
         if(!_gui.contains(ui_entityRollover))
         {
            _gui.getLayerAsSprite(_gui.SCENE_LAYER_NAME).addChildAt(ui_entityRollover,0);
         }
         if(param1.buildingData.assignable && Boolean(param1.buildingData.doorPosition))
         {
            if(_selectedSurvivor != null && param1.buildingData.mountedSurvivor == null)
            {
               MouseCursors.setCursor(MouseCursors.MOUNT_BUILDING);
            }
            else if(param1.buildingData.mountedSurvivor != null)
            {
               MouseCursors.setCursor(MouseCursors.DISMOUNT_BUILDING);
            }
         }
         else
         {
            MouseCursors.setCursor(MouseCursors.INTERACT);
         }
      }
      
      override protected function onMouseOutBuilding(param1:BuildingEntity) : void
      {
         this._mouseOverBuilding = null;
         ui_entityRollover.entity = null;
         if(ui_entityRollover.parent != null)
         {
            ui_entityRollover.parent.removeChild(ui_entityRollover);
         }
         MouseCursors.setCursor(MouseCursors.DEFAULT);
      }
      
      override protected function onBuildingClicked(param1:BuildingEntity) : void
      {
         if(param1 is DoorBuildingEntity)
         {
            DoorBuildingEntity(param1).toggleOpen();
            return;
         }
         if(param1.buildingData.mountedSurvivor != null)
         {
            selectSurvivor(param1.buildingData.mountedSurvivor,false);
            this.dismountSurvivor(param1.buildingData);
         }
         else if(_selectedSurvivor != null)
         {
            this.mountSurvivor(_selectedSurvivor,param1.buildingData);
         }
      }
      
      override protected function onBuildingDestroyed(param1:Building, param2:Object) : void
      {
         param1.entity.assetClicked.remove(this.onBuildingClicked);
         param1.entity.assetMouseOver.remove(this.onMouseOverBuilding);
         param1.entity.assetMouseOut.remove(this.onMouseOutBuilding);
         param1.entity.asset.mouseChildren = false;
         _missionData.addDestroyedPlayerBuilding(param1);
         super.onBuildingDestroyed(param1,param2);
         this.updateBuildingInteractivity();
      }
      
      override protected function onSurvivorMovementStopped(param1:Survivor) : void
      {
         super.onSurvivorMovementStopped(param1);
         this.updateBuildingThreatLevels();
      }
   }
}

