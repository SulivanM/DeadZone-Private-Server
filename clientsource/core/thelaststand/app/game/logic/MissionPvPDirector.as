package thelaststand.app.game.logic
{
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import flash.utils.clearTimeout;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Settings;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.game.Game;
   import thelaststand.app.game.data.AssignmentPosition;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.Gear;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemAttributes;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.entities.EntityFlags;
   import thelaststand.app.game.entities.buildings.AllianceFlagEntity;
   import thelaststand.app.game.entities.buildings.BuildingEntity;
   import thelaststand.app.game.entities.effects.Explosion;
   import thelaststand.app.game.gui.GameGUI;
   import thelaststand.app.game.gui.dialogues.PvPHelpDialogue;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.app.game.logic.ai.states.ActorSuppressedState;
   import thelaststand.app.game.logic.ai.states.BuildingStateFactory;
   import thelaststand.app.game.logic.ai.states.IAITrapState;
   import thelaststand.app.game.logic.ai.states.SurvivorAlertState;
   import thelaststand.app.game.scenes.CompoundScene;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.engine.map.Cell;
   import thelaststand.engine.map.TraversalArea;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   public class MissionPvPDirector extends MissionDirector
   {
      
      private var _neighbor:RemotePlayerData;
      
      private var _compoundScene:CompoundScene;
      
      private var _enemyLOSCheckIndex:int = 0;
      
      private var _helpTimeout:int;
      
      private var _totalDefenderSurvivorKills:int = 0;
      
      private var _timerExpired:Boolean = false;
      
      public function MissionPvPDirector(param1:Game, param2:CompoundScene, param3:GameGUI)
      {
         super(param1,param2,param3);
         this._compoundScene = param2;
         _guiMission.showHelpButton = true;
         _hideUnseenEnemies = false;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._neighbor = null;
         clearTimeout(this._helpTimeout);
      }
      
      override public function end() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Building = null;
         var _loc3_:Survivor = null;
         _loc1_ = 0;
         while(_loc1_ < this._neighbor.compound.buildings.numBuildings)
         {
            _loc2_ = this._neighbor.compound.buildings.getBuilding(_loc1_);
            _loc2_.traversalArea = null;
            _loc2_.entity.assetMouseOver.remove(onMouseOverBuilding);
            _loc2_.entity.assetMouseOut.remove(onMouseOutBuilding);
            _loc2_.entity.assetClicked.remove(onBuildingClicked);
            _loc2_.flags &= ~EntityFlags.TRAP_DETECTED;
            _loc2_.damageTaken.remove(onBuildingDamageTaken);
            _loc2_.died.remove(onBuildingDestroyed);
            _loc2_.stateMachine.clear();
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this._neighbor.compound.survivors.length)
         {
            _loc3_ = this._neighbor.compound.survivors.getSurvivor(_loc1_);
            _loc3_.agentData.clearState();
            _loc1_++;
         }
         if(!_missionData.isPvPPractice)
         {
            Tracking.trackEvent("PvP","AttackerDefenderCount",_missionData.survivors.length + "_" + this._neighbor.compound.survivors.length,0);
            Tracking.trackEvent("PvP","AttackerDefenderRatios","att:" + _totalSurvivorsInjured + "/" + _missionData.survivors.length + "  def:" + this._totalDefenderSurvivorKills + "/" + this._neighbor.compound.survivors.length,0);
            if(_missionData.survivors.length == _totalSurvivorsInjured)
            {
               Tracking.trackEvent("PvP","wipedOutAttacker",_missionData.survivors.length + "_lost_to_" + this._neighbor.compound.survivors.length);
            }
            if(this._neighbor.compound.survivors.length == this._totalDefenderSurvivorKills)
            {
               Tracking.trackEvent("PvP","wipedOutDefender",_missionData.survivors.length + "_defeated_to_" + this._neighbor.compound.survivors.length);
            }
            Tracking.trackEvent("PvP","trapsinCompound",String(this._neighbor.compound.buildings.getNumTraps()),0);
            Tracking.trackEvent("PvP","trapsTriggered",String(_trackingTrapsTriggered),_trackingTrapsTriggered);
         }
         super.end();
         clearTimeout(this._helpTimeout);
      }
      
      override public function start(param1:Number, ... rest) : void
      {
         var healthMod:Number;
         var accMod:Number;
         var i:int;
         var usedCells:Dictionary;
         var footprint:Rectangle;
         var item:Item = null;
         var trackStr:String = null;
         var trackList:Array = null;
         var j:int = 0;
         var spawnPt:Vector3D = null;
         var srv:Survivor = null;
         var spawnCell:Cell = null;
         var modStr:String = null;
         var rallyCell:Cell = null;
         var spawnZ:Number = NaN;
         var cellOK:Boolean = false;
         var k:int = 0;
         var worstWeapon:Weapon = null;
         var rallyIndex:int = 0;
         var pos:AssignmentPosition = null;
         var bufferCell:Cell = null;
         var building:Building = null;
         var tArea:TraversalArea = null;
         var t:Number = param1;
         var args:Array = rest;
         var superArgs:Array = [t];
         superArgs = superArgs.concat(args);
         _useDeployZones = true;
         super.start.apply(this,superArgs);
         if(_missionData.isPvPPractice)
         {
            Tracking.trackEvent("PvP_Practice","start");
         }
         this._neighbor = _missionData.opponent as RemotePlayerData;
         _timeMission = int(Config.constant.MISSION_PVP_TIME);
         healthMod = Number(Config.constant.PVP_SURVIVOR_HEALTH_MODIFIER);
         accMod = Number(Config.constant.PVP_SURVIVOR_ACCURACY_MODIFIER);
         CompoundScene(_scene).runPvPBuildingValidation();
         i = 0;
         while(i < _missionData.survivors.length)
         {
            srv = _missionData.survivors[i];
            addPlayerSurvivor(srv,healthMod);
            if(!_missionData.isPvPPractice)
            {
               trackList = [srv.loadoutOffence.weapon.item,srv.loadoutOffence.gearPassive.item,srv.loadoutOffence.gearActive.item];
               for each(item in trackList)
               {
                  if(item)
                  {
                     modStr = "";
                     j = 0;
                     while(j < item.maxMods)
                     {
                        if(item.getMod(j) != null)
                        {
                           modStr += "-" + item.getMod(j);
                        }
                        j++;
                     }
                     Tracking.trackEvent("PvP","loadout_attacker_" + item.getName(),modStr,0);
                  }
               }
            }
            spawnCell = _missionData.deployCells[i];
            spawnPt = _scene.map.getCellCoords(spawnCell.x,spawnCell.y);
            srv.actor.transform.position.copyFrom(spawnPt);
            srv.actor.transform.rotation.identity();
            srv.agentData.guardPoint.copyFrom(srv.actor.transform.position);
            srv.agentData.waitInCover = true;
            srv.agentData.visionRange = Number.POSITIVE_INFINITY;
            srv.agentData.mustHaveLOSToTarget = true;
            srv.agentData.canCauseBackCriticals = false;
            srv.weaponData.accuracy *= accMod;
            i++;
         }
         usedCells = new Dictionary(true);
         _missionData.enemyResults.survivors.length = 0;
         i = 0;
         while(i < this._neighbor.compound.survivors.length)
         {
            srv = this._neighbor.compound.survivors.getSurvivor(i);
            if(!_missionData.isPvPPractice)
            {
               trackList = [srv.loadoutDefence.weapon.item,srv.loadoutDefence.gearPassive.item,srv.loadoutDefence.gearActive.item];
               for each(item in trackList)
               {
                  if(item)
                  {
                     modStr = "";
                     j = 0;
                     while(j < item.maxMods)
                     {
                        if(item.getMod(j) != null)
                        {
                           modStr += "-" + item.getMod(j);
                        }
                        j++;
                     }
                     Tracking.trackEvent("PvP","loadout_defender_" + item.getName(),modStr,0);
                  }
               }
            }
            if(srv.loadoutDefence.weapon.item == null)
            {
               worstWeapon = ItemFactory.createItemFromTypeId("lawson22") as Weapon;
               srv.loadoutDefence.weapon.item = worstWeapon;
            }
            spawnZ = 0;
            if(srv.rallyAssignment == null || !this._neighbor.compound.buildings.containsBuilding(srv.rallyAssignment))
            {
               rallyCell = this._compoundScene.getRandomUnoccupiedCellIndoors();
               srv.agentData.useGuardPoint = false;
               srv.agentData.pursuitRange = Number.POSITIVE_INFINITY;
            }
            else
            {
               rallyIndex = int(srv.rallyAssignment.assignedSurvivors.indexOf(srv));
               if(rallyIndex > -1)
               {
                  pos = srv.rallyAssignment.buildingEntity.getAssignPositions()[rallyIndex];
                  if(pos.height > 0 && (srv.rallyAssignment.dead || srv.weaponData.isMelee))
                  {
                     bufferCell = srv.rallyAssignment.buildingEntity.getRandomBufferTile();
                     rallyCell = bufferCell;
                     spawnZ = 0;
                     srv.agentData.useGuardPoint = false;
                  }
                  else
                  {
                     rallyCell = pos.cell;
                     spawnZ = pos.height;
                     srv.agentData.useGuardPoint = true;
                     if(srv.rallyAssignment.doorPosition != null)
                     {
                        srv.rallyAssignment.mountedSurvivor = srv;
                        srv.mountedBuilding = srv.rallyAssignment;
                     }
                  }
                  srv.agentData.pursuitRange = _scene.map.cellSize * 20;
               }
            }
            if(rallyCell != null)
            {
               cellOK = false;
               k = 0;
               while(k < 10)
               {
                  if(usedCells[rallyCell.x + "-" + rallyCell.y] == null)
                  {
                     cellOK = true;
                     break;
                  }
                  rallyCell = srv.rallyAssignment.buildingEntity.getRandomBufferTile();
                  spawnZ = 0;
                  srv.agentData.useGuardPoint = false;
                  k++;
               }
               if(cellOK)
               {
                  usedCells[rallyCell.x + "-" + rallyCell.y] = true;
                  addEnemy(srv,healthMod);
                  _missionData.enemyResults.survivors.push(srv);
                  spawnPt = _scene.map.getCellCoords(rallyCell.x,rallyCell.y);
                  srv.actor.transform.position.x = spawnPt.x;
                  srv.actor.transform.position.y = spawnPt.y;
                  srv.actor.transform.position.z = spawnZ;
                  srv.actor.transform.setRotationEuler(0,0,Math.PI * 2 * Math.random());
                  srv.actor.targetForward = null;
                  srv.agentData.guardPoint.copyFrom(srv.actor.transform.position);
                  srv.agentData.pursueTargets = true;
                  srv.agentData.mustHaveLOSToTarget = true;
                  srv.agentData.visionRange = Number.POSITIVE_INFINITY;
                  srv.agentData.canCauseBackCriticals = false;
                  srv.agentData.inLOS = true;
                  srv.weaponData.accuracy *= accMod;
               }
            }
            i++;
         }
         this._neighbor.compound.distributeAllResourcesToStorageBuildings();
         footprint = new Rectangle();
         i = 0;
         while(i < this._neighbor.compound.buildings.numBuildings)
         {
            building = this._neighbor.compound.buildings.getBuilding(i);
            building.buildingEntity.hideAssignPositions();
            building.buildingEntity.showAssignFlags(false);
            building.resetHealth();
            if(building.buildingEntity.passable == false && building.destroyable == true && building.isTrap == false && building.isDecoyTrap == false)
            {
               building.buildingEntity.getFootprintRect(building.tileX,building.tileY,footprint);
               ++footprint.width;
               ++footprint.height;
               tArea = _scene.map.addTraversalArea(footprint,0);
               tArea.data = building;
               building.traversalArea = tArea;
            }
            if(building.health > 0)
            {
               if(building.destroyable || building.isTrap)
               {
                  building.entity.assetMouseOver.add(onMouseOverBuilding);
                  building.entity.assetMouseOut.add(onMouseOutBuilding);
                  building.entity.assetClicked.add(onBuildingClicked);
                  building.damageTaken.add(onBuildingDamageTaken);
                  building.died.add(onBuildingDestroyed);
                  _interactiveBuildings.push(building);
                  _buildingAgents.push(building);
                  _allAgents.push(building);
               }
               if(building.isTrap)
               {
                  building.blackboard.erase();
                  building.blackboard.allAgents = _allAgents;
                  building.blackboard.friends = _enemies;
                  building.blackboard.enemies = _survivors;
                  building.blackboard.scene = _scene;
                  building.stateMachine.setState(BuildingStateFactory.getState(building));
                  IAITrapState(building.stateMachine.state).triggered.addOnce(onTrapTriggered);
                  building.buildingEntity.asset.visible = (building.flags & EntityFlags.TRAP_DETECTED) != 0;
                  _trapAgents.push(building);
               }
            }
            else if(building.isTrap)
            {
               _scene.removeEntity(building.buildingEntity);
            }
            if(building.scavengable)
            {
               if(_interactiveBuildings.indexOf(building) == -1)
               {
                  _interactiveBuildings.push(building);
                  building.entity.assetMouseOver.add(onMouseOverBuilding);
                  building.entity.assetMouseOut.add(onMouseOutBuilding);
                  building.entity.assetClicked.add(onBuildingClicked);
               }
            }
            i++;
         }
         updateCoverRatingsForAgents(_survivors);
         updateCoverRatingsForAgents(_enemies);
         _guiMission.ui_survivorBar.survivors = _missionData.survivors;
         selectSurvivor(_missionData.survivors[0]);
         _scene.panTo(_missionData.survivors[0].actor.transform.position.x,_missionData.survivors[0].actor.transform.position.y,0,0.25,{"delay":0.5});
         if(!Settings.getInstance().getData("pvpHelpViewed_v2",false))
         {
            this._helpTimeout = setTimeout(function():void
            {
               var dlgHelp:*;
               _game.pause(true);
               dlgHelp = new PvPHelpDialogue();
               dlgHelp.closed.add(function(param1:Dialogue):void
               {
                  _game.pause(false);
                  _timeStart = getTimer();
                  Settings.getInstance().setData("pvpHelpViewed_v2",true);
               });
               dlgHelp.open();
            },500);
         }
         _guiMission.setupProgressPanel(this._compoundScene.totalSearchableEntities,0);
      }
      
      override public function update(param1:Number, param2:Number) : void
      {
         var _loc4_:AIActorAgent = null;
         var _loc3_:int = 0;
         while(_loc3_ < _enemies.length)
         {
            _loc4_ = _enemies[_loc3_];
            _loc4_.checkLOSToAgents(_survivors);
            if(_loc4_.health > 0 && _loc4_.stateMachine.state == null)
            {
               if(_loc4_.agentData.suppressed)
               {
                  _loc4_.stateMachine.setState(new ActorSuppressedState(_loc4_));
                  setSuppressionIndicatorState(_loc4_,true);
               }
               else
               {
                  _loc4_.stateMachine.setState(new SurvivorAlertState(_loc4_ as Survivor));
               }
            }
            _loc4_.update(param1,param2);
            _loc3_++;
         }
         super.update(param1,param2);
      }
      
      override protected function setActionModeState(param1:Boolean) : void
      {
         var _loc3_:Building = null;
         super.setActionModeState(param1);
         var _loc2_:Boolean = _actionMode ? _selectedSurvivor != null : false;
         for each(_loc3_ in _interactiveBuildings)
         {
            if(_loc3_.entity.asset != null)
            {
               _loc3_.entity.asset.mouseEnabled = _loc2_;
            }
         }
      }
      
      override protected function onScavengeComplete(param1:Survivor, param2:GameEntity, param3:Number, param4:Number) : void
      {
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:Item = null;
         var _loc5_:Building = param2 is BuildingEntity ? BuildingEntity(param2).buildingData : null;
         if(_loc5_ == null)
         {
            return;
         }
         if(_loc5_.type == "alliance-flag")
         {
            if(!_missionData.isPvPPractice)
            {
               Tracking.trackEvent("PvP","alliance_flag_scavenged","");
            }
            ++_missionData.stats.allianceFlagCaptured;
            _missionData.allianceFlagCaptured = true;
            AllianceFlagEntity(_loc5_.entity).available = false;
            SendMissionEvent(MissionEventTypes.ALLIANCE_FLAG_STOLEN,param1.id);
         }
         else
         {
            _loc6_ = _loc5_.storageResource || _loc5_.productionResource;
            _loc7_ = 0;
            if(_loc5_.productionResource != null)
            {
               _loc7_ = _loc5_.resourceValue;
               _missionData.enemyResults.prodBuildingsRaided.push(_loc5_);
            }
            else
            {
               _loc7_ = Math.floor(_loc5_.resourceValue * Number(Config.constant.PVP_RESOURCE_SCAVENGE_PERC));
            }
            _loc5_.resourceValue = 0;
            if(_loc7_ > 0)
            {
               _loc8_ = ItemFactory.createItemFromTypeId(_loc6_);
               _loc8_.quantity = _loc7_;
               _missionData.loot.push(_loc8_);
               _guiMission.addFoundLoot(_loc8_);
               if(!_missionData.isPvPPractice)
               {
                  Tracking.trackEvent("PvP","buildingLooted",_loc8_ ? _loc8_.getName() : "nothing",_loc8_.quantity);
               }
               ++_missionData.enemyResults.totalBuildingsLooted;
            }
            else
            {
               _guiMission.addFoundLoot(null);
            }
            ++_scavedCount;
            if(_scavedCount >= this._compoundScene.totalSearchableEntities)
            {
               _missionData.allContainersSearched = true;
            }
            _guiMission.updateScavProgressPanel(_scavedCount);
            SendMissionEvent(MissionEventTypes.BUILDING_SCAVENGED,_loc5_.type,_loc7_ > 0);
         }
         super.onScavengeComplete(param1,param2,param3,param4);
      }
      
      override protected function onEnemyDie(param1:AIActorAgent, param2:Object) : void
      {
         var _loc4_:Survivor = null;
         var _loc5_:Explosion = null;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         super.onEnemyDie(param1,param2);
         TweenMaxDelta.killTweensOf(param1.actor.asset);
         var _loc3_:Survivor = param1 as Survivor;
         _missionData.enemyResults.addDownedSurvivor(_loc3_,param1.agentData.lastDamageCause);
         var _loc6_:* = param2 is Explosion;
         if(_loc6_)
         {
            _loc5_ = Explosion(param2);
            _loc4_ = Explosion(param2).owner as Survivor;
         }
         else
         {
            _loc4_ = param2 as Survivor;
         }
         if(_loc4_ != null)
         {
            _loc7_ = Number(Config.constant.BASE_SURVIVOR_KILL_XP);
            _loc8_ = _loc4_.activeLoadout.getLoadoutAttributeMod(ItemAttributes.GROUP_SURVIVOR,"survivor_kill_xp") + Network.getInstance().playerData.compound.effects.attributes.getModValue(ItemAttributes.GROUP_SURVIVOR,"survivor_kill_xp");
            _loc9_ = awardKillXP(_loc7_,param1,_loc8_);
            _missionData.survivorKills.push(_loc3_.id,_loc4_.missionIndex);
            ++_missionData.stats.survivorKills;
            ++this._totalDefenderSurvivorKills;
            if(_loc6_)
            {
               ++_missionData.stats.survivorExplosiveKills;
               _missionData.stats.addGearKill(_loc5_.ownerItem as Gear,"survivor");
               SendMissionEvent(MissionEventTypes.DEFENDER_DIE_EXPLOSIVE,_loc3_.id,_loc4_.id,_loc5_.ownerItem.type);
            }
            else
            {
               _missionData.stats.addWeaponKill(_loc4_.weapon,"survivor");
               SendMissionEvent(MissionEventTypes.DEFENDER_DIE_WEAPON,_loc3_.id,_loc4_.id);
            }
         }
      }
      
      override protected function onTimeExpired() : void
      {
         super.onTimeExpired();
         if(!this._timerExpired)
         {
            if(!_missionData.isPvPPractice)
            {
               Tracking.trackEvent("Mission","TimerExpired",null,0);
            }
            SendMissionEvent(MissionEventTypes.TIMER_EXPIRED);
            this._timerExpired = true;
         }
      }
   }
}

