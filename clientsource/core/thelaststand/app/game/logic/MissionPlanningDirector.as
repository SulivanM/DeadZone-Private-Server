package thelaststand.app.game.logic
{
   import alternativa.engine3d.core.Resource;
   import flash.events.TimerEvent;
   import flash.geom.Vector3D;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.AllianceDialogState;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.data.PlayerFlags;
   import thelaststand.app.display.Effects;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.Game;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.DeploymentZone;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.alliance.AllianceDataSummary;
   import thelaststand.app.game.data.alliance.AllianceSummaryCache;
   import thelaststand.app.game.entities.EntityFlags;
   import thelaststand.app.game.entities.buildings.AllianceFlagEntity;
   import thelaststand.app.game.entities.gui.UIDeploymentPip;
   import thelaststand.app.game.gui.GameGUI;
   import thelaststand.app.game.gui.dialogues.MissionLoadoutDialogue;
   import thelaststand.app.game.gui.mission.MissionPlanningGUILayer;
   import thelaststand.app.game.scenes.CompoundScene;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.NetworkMessage;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.map.Cell;
   
   public class MissionPlanningDirector implements ISceneDirector
   {
      
      private var _buildings:Vector.<Building>;
      
      private var _deployLocations:Vector.<Cell>;
      
      private var _locationsSelected:Boolean;
      
      private var _locationsValid:Boolean;
      
      private var _game:Game;
      
      private var _gui:GameGUI;
      
      private var _guiPlanning:MissionPlanningGUILayer;
      
      private var _lang:Language;
      
      private var _missionData:MissionData;
      
      private var _resources:ResourceManager;
      
      private var _scene:CompoundScene;
      
      private var _deploymentZones:Vector.<DeploymentZone>;
      
      private var _endTimer:Timer;
      
      private var _timeMission:Number = 0;
      
      private var _timeRemaining:Number = 0;
      
      private var _timeStart:Number = 0;
      
      private var _planningActive:Boolean = false;
      
      private var _deployPips:Vector.<UIDeploymentPip>;
      
      private var _scoutFlag:Boolean = false;
      
      private var _neighbor:RemotePlayerData;
      
      public function MissionPlanningDirector(param1:Game, param2:CompoundScene, param3:GameGUI)
      {
         super();
         this._game = param1;
         this._scene = param2;
         this._buildings = new Vector.<Building>();
         this._deploymentZones = new Vector.<DeploymentZone>();
         this._endTimer = new Timer(2000,1);
         this._endTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onEndTimerCompleted,false,0,true);
         this._gui = param3;
         this._guiPlanning = new MissionPlanningGUILayer();
         this._deployLocations = new Vector.<Cell>(5,true);
         this._deployPips = new Vector.<UIDeploymentPip>(this._deployLocations.length,true);
         var _loc4_:int = 0;
         while(_loc4_ < this._deployPips.length)
         {
            this._deployPips[_loc4_] = new UIDeploymentPip();
            _loc4_++;
         }
         this._resources = ResourceManager.getInstance();
         this._lang = Language.getInstance();
      }
      
      public function dispose() : void
      {
         var _loc1_:UIDeploymentPip = null;
         for each(_loc1_ in this._deployPips)
         {
            _loc1_.dispose();
         }
         this._buildings = null;
         this._gui = null;
         this._guiPlanning = null;
         this._game = null;
         this._scene = null;
         this._resources = null;
         this._lang = null;
         this._missionData = null;
         this._deploymentZones = null;
         this._deployLocations = null;
         this._endTimer.stop();
         this._endTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onEndTimerCompleted);
         this._endTimer = null;
         this._neighbor = null;
      }
      
      public function start(param1:Number, ... rest) : void
      {
         var _loc3_:UIDeploymentPip = null;
         var _loc4_:int = 0;
         var _loc5_:Building = null;
         this._missionData = rest[0] as MissionData;
         this._planningActive = true;
         this._timeMission = int(Config.constant.MISSION_DEPLOY_TIME);
         this._timeRemaining = this._timeMission;
         this._timeStart = getTimer();
         this._gui.addLayer("planning",this._guiPlanning);
         this._guiPlanning.missionCancelled.add(this.onMissionCancelled);
         for each(_loc3_ in this._deployPips)
         {
            this._scene.addEntity(_loc3_);
            _loc3_.asset.visible = false;
         }
         CompoundScene(this._scene).runPvPBuildingValidation();
         this._scene.buildCoverTable();
         this._scene.centerOn(int(this._scene.map.cellSize * this._scene.map.size.x * 0.6),0);
         this.addDeploymentZones();
         this._neighbor = this._missionData.opponent as RemotePlayerData;
         _loc4_ = 0;
         while(_loc4_ < this._neighbor.compound.buildings.numBuildings)
         {
            _loc5_ = this._neighbor.compound.buildings.getBuilding(_loc4_);
            _loc5_.buildingEntity.showAssignFlags(false);
            if(_loc5_.isTrap)
            {
               _loc5_.buildingEntity.asset.visible = (_loc5_.flags & EntityFlags.TRAP_DETECTED) != 0;
            }
            _loc4_++;
         }
         this._scene.mouseMap.enabled = true;
         this._scene.mouseMap.tileClicked.add(this.onTileClicked);
         this._gui.messageArea.setMessage(this._lang.getString("mission_deploy"),20,Effects.COLOR_GREEN);
         if(this._missionData.isPvPPractice)
         {
            if(!Network.getInstance().playerData.flags.get(PlayerFlags.TutorialPvPPractice))
            {
               DialogueController.getInstance().showPvPPracticeTutorial();
            }
            this.updateAllianceFlag(this._neighbor.allianceId);
         }
         else
         {
            if(this._missionData.sameIP)
            {
               this._guiPlanning.showIPWarning();
            }
            if(this._missionData.bounty > 0)
            {
               this._guiPlanning.setBountyInfo(this._neighbor.nickname,this._missionData.bounty);
            }
            if(this._missionData.allianceMatch || this._missionData.allianceDefenderLocked || this._missionData.allianceAttackerEnlisting || this._missionData.allianceDefenderEnlisting || this._missionData.allianceAttackerLockout)
            {
               this._guiPlanning.setAllianceInfo(this._missionData);
               this.updateAllianceFlag(this._missionData.allianceDefenderAllianceId);
            }
            else
            {
               this.updateAllianceFlag(this._neighbor.allianceId);
            }
         }
         this._guiPlanning.transitionIn(0.5);
         this.updateTimeRemaining();
      }
      
      public function end() : void
      {
         var _loc1_:DeploymentZone = null;
         DialogueManager.getInstance().closeDialogue("mission-loadout");
         this._planningActive = false;
         this._gui.clearLayer(this._gui.getLayer(this._gui.SCENE_LAYER_NAME));
         this._gui.removeLayer(this._guiPlanning,true,this._guiPlanning.dispose);
         this._guiPlanning.missionCancelled.remove(this.onMissionCancelled);
         this._scene.mouseMap.enabled = true;
         this._scene.mouseMap.tileClicked.remove(this.onTileClicked);
         for each(_loc1_ in this._deploymentZones)
         {
            this._scene.container.removeChild(_loc1_.decal);
            _loc1_.dispose();
         }
         this._deploymentZones.length = 0;
         this._endTimer.stop();
      }
      
      private function cellIsInDeploymentZone(param1:Cell) : Boolean
      {
         var _loc2_:DeploymentZone = null;
         for each(_loc2_ in this._deploymentZones)
         {
            if(_loc2_.rect.contains(param1.x,param1.y))
            {
               return true;
            }
         }
         return false;
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         var _loc6_:DeploymentZone = null;
         var _loc7_:UIDeploymentPip = null;
         var _loc8_:int = 0;
         var _loc9_:Cell = null;
         var _loc10_:Vector.<Cell> = null;
         var _loc11_:int = 0;
         var _loc12_:Vector.<Cell> = null;
         var _loc13_:Cell = null;
         var _loc14_:int = 0;
         var _loc15_:Boolean = false;
         var _loc16_:Cell = null;
         if(!this._locationsSelected)
         {
            _loc3_ = this._scene.mouseMap.mouseCell.x;
            _loc4_ = this._scene.mouseMap.mouseCell.y;
            _loc5_ = false;
            for each(_loc6_ in this._deploymentZones)
            {
               if(_loc6_.rect.contains(_loc3_,_loc4_))
               {
                  _loc5_ = true;
                  break;
               }
            }
            if(!_loc5_ || _loc3_ == -1 || _loc4_ == -1)
            {
               for each(_loc7_ in this._deployPips)
               {
                  _loc7_.asset.visible = false;
               }
            }
            else
            {
               _loc9_ = this._scene.map.cellMap.getCell(_loc3_,_loc4_);
               _loc10_ = this._scene.map.getCellsAround(_loc3_,_loc4_,2,true);
               _loc8_ = int(_loc10_.length - 1);
               while(_loc8_ >= 0)
               {
                  if(!this.cellIsInDeploymentZone(_loc10_[_loc8_]))
                  {
                     _loc10_.splice(_loc8_,1);
                  }
                  _loc8_--;
               }
               _loc11_ = 0;
               _loc12_ = this._scene.getCoverCellsInList(_loc10_);
               _loc8_ = 0;
               while(_loc8_ < this._deployPips.length)
               {
                  _loc7_ = this._deployPips[_loc8_];
                  _loc13_ = null;
                  _loc15_ = false;
                  _loc16_ = this._scene.getClosestCoverFromList(_loc9_,_loc12_);
                  if(_loc16_ != null)
                  {
                     _loc13_ = _loc16_;
                     _loc15_ = true;
                     _loc14_ = int(_loc12_.indexOf(_loc16_));
                     if(_loc14_ > -1)
                     {
                        _loc12_.splice(_loc14_,1);
                     }
                  }
                  else
                  {
                     _loc13_ = this._scene.map.getClosestCellFromListToPoint(_loc10_,new Vector3D(this._scene.mouseMap.mousePt.x,this._scene.mouseMap.mousePt.y,0));
                  }
                  if(_loc13_ == null)
                  {
                     _loc7_.asset.visible = false;
                  }
                  else
                  {
                     _loc14_ = int(_loc10_.indexOf(_loc13_));
                     if(_loc14_ > -1)
                     {
                        _loc10_.splice(_loc14_,1);
                     }
                     this._scene.map.getCellCoords(_loc13_.x,_loc13_.y,_loc7_.transform.position);
                     _loc7_.transform.position.z = 5;
                     _loc7_.updateTransform(param1);
                     _loc7_.asset.visible = true;
                     _loc7_.inCover = _loc15_;
                     this._deployLocations[_loc8_] = _loc13_;
                     _loc11_++;
                  }
                  _loc8_++;
               }
               this._locationsValid = _loc11_ >= 5;
               if(!this._locationsValid)
               {
                  _loc8_ = 0;
                  while(_loc8_ < this._deployPips.length)
                  {
                     _loc7_ = this._deployPips[_loc8_];
                     _loc7_.asset.visible = false;
                     this._deployLocations[_loc8_] = null;
                     _loc8_++;
                  }
               }
            }
         }
         if(this._missionData.isPvP && !this._missionData.isPvPPractice && !this._scoutFlag && getTimer() - this._timeStart > 15000)
         {
            this._scoutFlag = true;
            Network.getInstance().save({},SaveDataMethod.MISSION_SCOUTED);
         }
         this.updateTimeRemaining(param2);
      }
      
      private function startMission() : void
      {
         this._planningActive = false;
         this._gui.removeLayer(this._guiPlanning,true);
         this._gui.clearLayer(this._gui.getLayer(this._gui.SCENE_LAYER_NAME));
         this._gui.messageArea.setMessage("");
         AllianceDialogState.getInstance().allianceDialogReturnType = AllianceDialogState.SHOW_NONE;
         this._missionData.startMission(function():void
         {
            Network.getInstance().playerData.missionList.addMission(_missionData);
            _gui.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.MISSION,_missionData));
         });
      }
      
      private function addDeploymentZones() : void
      {
         var _loc1_:XML = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:DeploymentZone = null;
         var _loc5_:Resource = null;
         for each(_loc1_ in this._scene.xmlDescriptor.deploy.rect)
         {
            _loc2_ = int(_loc1_.@width) * this._scene.map.cellSize;
            _loc3_ = int(_loc1_.@height) * this._scene.map.cellSize;
            _loc4_ = new DeploymentZone(this._scene,int(_loc1_.@x),int(_loc1_.@y),int(_loc1_.@width),int(_loc1_.@height));
            this._scene.container.addChild(_loc4_.decal);
            this._deploymentZones.push(_loc4_);
            for each(_loc5_ in _loc4_.decal.getResources(true))
            {
               this._scene.resourceUploadList.push(_loc5_);
            }
         }
      }
      
      private function updateTimeRemaining(param1:Number = 0) : void
      {
         if(!this._planningActive)
         {
            return;
         }
         this._timeRemaining = this._timeMission - (getTimer() - this._timeStart) / 1000;
         this._guiPlanning.ui_timer.time = this._timeRemaining;
         if(this._timeRemaining <= 0 && !this._endTimer.running)
         {
            this._endTimer.start();
         }
      }
      
      private function updateAllianceFlag(param1:String) : void
      {
         var _loc2_:Building = this._neighbor.compound.buildings.getFirstBuildingOfType("alliance-flag");
         if(param1 == "")
         {
            if(_loc2_ != null && _loc2_.entity != null)
            {
               _loc2_.scavengable = false;
            }
            return;
         }
         if(this._missionData.allianceDefenderLocked)
         {
            if(_loc2_ != null && _loc2_.entity != null)
            {
               AllianceFlagEntity(_loc2_.entity).available = false;
               _loc2_.scavengable = false;
            }
            return;
         }
         AllianceSummaryCache.getInstance().getSummary(param1,this.handleAllianceLoaded);
         if(this._missionData.allianceMatch == false && _loc2_ != null && _loc2_.entity != null)
         {
            _loc2_.scavengable = false;
         }
      }
      
      private function handleAllianceLoaded(param1:AllianceDataSummary) : void
      {
         if(this._neighbor == null)
         {
            return;
         }
         var _loc2_:Building = this._neighbor.compound.buildings.getFirstBuildingOfType("alliance-flag");
         if(param1 == null)
         {
            _loc2_.scavengable = false;
            return;
         }
         if(_loc2_ != null && _loc2_.entity != null)
         {
            AllianceFlagEntity(_loc2_.entity).bannerData = param1.banner;
            _loc2_.scavengable = this._missionData.allianceMatch;
         }
      }
      
      private function onMissionCancelled() : void
      {
         if(!this._planningActive)
         {
            return;
         }
         this._planningActive = false;
         this._gui.removeLayer(this._guiPlanning,true);
         this._gui.clearLayer(this._gui.getLayer(this._gui.SCENE_LAYER_NAME));
         this._gui.messageArea.setMessage("");
         Network.getInstance().send(NetworkMessage.PLAYER_ATTACK_RESPONSE,{
            "id":this._missionData.opponent.id,
            "cancelled":true
         },function(param1:Object):void
         {
            if(_missionData.isPvP && !_missionData.isPvPPractice)
            {
               Tracking.trackEvent("PvP","Attack_Cancelled",String(int(_timeMission - (getTimer() - _timeStart) / 1000)));
            }
            _gui.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.WORLD_MAP));
         });
      }
      
      private function onEndTimerCompleted(param1:TimerEvent) : void
      {
         if(this._missionData.isPvP && !this._missionData.isPvPPractice)
         {
            Tracking.trackEvent("PvP","Planning_Timer_Expired");
         }
         this.onMissionCancelled();
      }
      
      private function onTileClicked(param1:int, param2:int) : void
      {
         var dlg:MissionLoadoutDialogue = null;
         var tileX:int = param1;
         var tileY:int = param2;
         if(!this._locationsValid || tileX == -1 || tileY == -1)
         {
            return;
         }
         this._locationsSelected = true;
         this._missionData.deployCells = this._deployLocations.concat();
         this._gui.messageArea.setMessage("");
         dlg = new MissionLoadoutDialogue(this._missionData);
         dlg.launched.add(function(param1:MissionData):void
         {
            dlg.close();
            startMission();
         });
         dlg.closed.add(function(param1:Dialogue):void
         {
            _locationsSelected = false;
            _gui.messageArea.setMessage(_lang.getString("mission_deploy"),20,Effects.COLOR_GREEN);
         });
         dlg.open();
      }
   }
}

