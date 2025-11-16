package thelaststand.app.game.logic
{
   import flash.utils.Dictionary;
   import thelaststand.app.game.Game;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.BuildingCollection;
   import thelaststand.app.game.data.alliance.AllianceDataSummary;
   import thelaststand.app.game.data.alliance.AllianceSummaryCache;
   import thelaststand.app.game.entities.buildings.AllianceFlagEntity;
   import thelaststand.app.game.entities.buildings.BuildingEntity;
   import thelaststand.app.game.gui.GameGUI;
   import thelaststand.app.game.gui.UIEntityRollover;
   import thelaststand.app.game.gui.compound.NeighborCompoundGUILayer;
   import thelaststand.app.game.gui.compound.UIBuildingControl;
   import thelaststand.app.game.gui.compound.UIConstructionProgress;
   import thelaststand.app.game.scenes.CompoundScene;
   import thelaststand.app.gui.MouseCursors;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.NetworkMessage;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class CompoundDirector implements ISceneDirector
   {
      
      private var _buildings:Vector.<Building>;
      
      private var _game:Game;
      
      private var _gui:GameGUI;
      
      private var _guiCompound:NeighborCompoundGUILayer;
      
      private var _neighbor:RemotePlayerData;
      
      private var _resources:ResourceManager;
      
      private var _timeManager:TimerManager;
      
      private var _lang:Language;
      
      private var _scene:CompoundScene;
      
      private var _selectedBuilding:Building;
      
      private var _ui_constructionProgressByBuilding:Dictionary;
      
      private var ui_buildingControl:UIBuildingControl;
      
      private var ui_entityRollover:UIEntityRollover;
      
      public function CompoundDirector(param1:Game, param2:CompoundScene, param3:GameGUI)
      {
         super();
         this._game = param1;
         this._scene = param2;
         this._buildings = new Vector.<Building>();
         this._gui = param3;
         this._guiCompound = new NeighborCompoundGUILayer();
         this._ui_constructionProgressByBuilding = new Dictionary(true);
         this.ui_entityRollover = new UIEntityRollover();
         this.ui_buildingControl = new UIBuildingControl(true);
         this._resources = ResourceManager.getInstance();
         this._timeManager = TimerManager.getInstance();
         this._lang = Language.getInstance();
      }
      
      public function dispose() : void
      {
         this.ui_buildingControl.dispose();
         this.ui_buildingControl = null;
         this.ui_entityRollover.dispose();
         this.ui_entityRollover = null;
         if(this._neighbor != null)
         {
            this._neighbor.compound.dispose();
         }
         this._neighbor = null;
         this._buildings = null;
         this._gui = null;
         this._guiCompound = null;
         this._game = null;
         this._scene = null;
         this._resources = null;
         this._timeManager = null;
         this._lang = null;
         this._ui_constructionProgressByBuilding = null;
      }
      
      public function start(param1:Number, ... rest) : void
      {
         this._neighbor = rest[0] as RemotePlayerData;
         this._gui.addLayer("compound",this._guiCompound);
         this.ui_buildingControl.helpClicked.add(this.helpBuilding);
         this.ui_buildingControl.hidden.add(this.onBuildingControlHidden);
         this.addBuildings(this._neighbor.compound.buildings);
         this.updateAllianceFlag(this._neighbor.allianceId);
      }
      
      public function end() : void
      {
         var _loc1_:UIConstructionProgress = null;
         this._gui.clearLayer(this._gui.getLayer(this._gui.SCENE_LAYER_NAME));
         this._gui.removeLayer(this._guiCompound,true,this._guiCompound.dispose);
         this.ui_buildingControl.helpClicked.remove(this.helpBuilding);
         this.ui_buildingControl.hidden.remove(this.onBuildingControlHidden);
         for each(_loc1_ in this._ui_constructionProgressByBuilding)
         {
            this._ui_constructionProgressByBuilding[_loc1_.building] = null;
            delete this._ui_constructionProgressByBuilding[_loc1_.building];
            _loc1_.dispose();
         }
         this.removeBuildings();
      }
      
      public function update(param1:Number, param2:Number) : void
      {
      }
      
      private function addBuildings(param1:BuildingCollection) : void
      {
         var _loc4_:Building = null;
         this.removeBuildings();
         var _loc2_:int = 0;
         var _loc3_:int = param1.numBuildings;
         while(_loc2_ < _loc3_)
         {
            _loc4_ = param1.getBuilding(_loc2_);
            _loc4_.buildingEntity.footprintVisible = false;
            _loc4_.buildingEntity.showAssignFlags(false);
            if(_loc4_.type == "rally" || _loc4_.isTrap)
            {
               this._scene.removeEntity(_loc4_.entity);
            }
            else
            {
               if(_loc4_.entity.asset != null)
               {
                  _loc4_.entity.asset.mouseChildren = true;
               }
               this._buildings.push(_loc4_);
               this.updateBuildingState(_loc4_);
            }
            _loc2_++;
         }
      }
      
      private function removeBuildings() : void
      {
         var _loc3_:Building = null;
         var _loc1_:int = 0;
         var _loc2_:int = int(this._buildings.length);
         while(_loc1_ < _loc2_)
         {
            _loc3_ = this._buildings[_loc1_];
            _loc3_.entityClicked.remove(this.selectBuilding);
            _loc3_.entity.assetMouseOver.remove(this.onBuildingEntityMouseOver);
            _loc3_.entity.assetMouseOut.remove(this.onBuildingEntityMouseOut);
            _loc1_++;
         }
         this._buildings.length = 0;
      }
      
      private function helpBuilding(param1:Building) : void
      {
         var data:Object;
         var building:Building = param1;
         if(Network.getInstance().isBusy)
         {
            return;
         }
         building.entityClicked.remove(this.selectBuilding);
         data = {
            "neighborId":this._neighbor.id,
            "buildingId":building.id
         };
         Network.getInstance().startAsyncOp();
         Network.getInstance().send(NetworkMessage.HELP_PLAYER,data,function(param1:Object):void
         {
            var _loc2_:MessageBox = null;
            var _loc3_:String = null;
            var _loc4_:int = 0;
            Network.getInstance().completeAsyncOp();
            if(_neighbor == null || building == null)
            {
               return;
            }
            if(param1 == null || param1.success === false)
            {
               Network.getInstance().client.errorLog.writeError("CompoundDirector: helpBuilding: NetworkMessage.HELP_PLAYER: Null or invalid response object received","","",{});
               Network.getInstance().throwSyncError();
               return;
            }
            if(param1.status == "error")
            {
               _loc2_ = new MessageBox(_lang.getString("help_error_msg",_neighbor.nickname),null,true);
               _loc2_.addTitle(_lang.getString("help_error_title"));
               _loc2_.addButton(_lang.getString("help_error_ok"));
            }
            else if(param1.status == "maxed")
            {
               _loc2_ = new MessageBox(_lang.getString("help_maxed_msg",building.getUpgradeName()),null,true);
               _loc2_.addTitle(_lang.getString("help_maxed_title"));
               _loc2_.addButton(_lang.getString("help_maxed_ok"));
            }
            else if(param1.status == "success" && building.upgradeTimer != null)
            {
               _loc4_ = int(param1.secRemoved);
               _loc3_ = building.getUpgradeName();
               building.upgradeTimer.speedUp(_loc4_);
               _loc2_ = new MessageBox(_lang.getString("help_success_msg",_neighbor.nickname,DateTimeUtils.secondsToString(_loc4_),_loc3_),null,true);
               _loc2_.addTitle(_lang.getString("help_success_title"));
               _loc2_.addButton(_lang.getString("help_success_ok"));
            }
            if(_loc2_ != null)
            {
               _loc2_.open();
            }
            updateBuildingState(building);
            building.entityClicked.add(selectBuilding);
         });
         this._selectedBuilding = null;
         this.ui_buildingControl.hide();
      }
      
      private function selectBuilding(param1:Building) : void
      {
         if(Network.getInstance().isBusy)
         {
            return;
         }
         if(param1 == this._selectedBuilding)
         {
            return;
         }
         if(this._selectedBuilding != null)
         {
            this._selectedBuilding = null;
            this.ui_buildingControl.hide();
         }
         if(param1 == null)
         {
            return;
         }
         this._selectedBuilding = param1;
         this.ui_buildingControl.building = param1;
         this.ui_buildingControl.show(this._gui);
      }
      
      private function updateBuildingState(param1:Building) : void
      {
         var _loc2_:Boolean = param1.upgradeTimer != null || param1.tasks.length > 0;
         var _loc3_:UIConstructionProgress = this._ui_constructionProgressByBuilding[param1];
         if(_loc2_ && _loc3_ == null)
         {
            _loc3_ = new UIConstructionProgress(param1);
            this._ui_constructionProgressByBuilding[param1] = _loc3_;
         }
         if(_loc2_)
         {
            _loc3_.updateLabel();
            this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(_loc3_);
            param1.entityClicked.add(this.selectBuilding);
            param1.entity.assetMouseOver.add(this.onBuildingEntityMouseOver);
            param1.entity.assetMouseOut.add(this.onBuildingEntityMouseOut);
         }
         else if(_loc3_ != null && _loc3_.parent != null)
         {
            _loc3_.parent.removeChild(_loc3_);
            param1.entityClicked.remove(this.selectBuilding);
            param1.entity.assetMouseOver.remove(this.onBuildingEntityMouseOver);
            param1.entity.assetMouseOut.remove(this.onBuildingEntityMouseOut);
         }
      }
      
      private function updateAllianceFlag(param1:String) : void
      {
         if(param1 == "")
         {
            return;
         }
         AllianceSummaryCache.getInstance().getSummary(param1,this.handleAllianceLoaded);
      }
      
      private function handleAllianceLoaded(param1:AllianceDataSummary) : void
      {
         if(param1 == null || this._neighbor == null)
         {
            return;
         }
         var _loc2_:Building = this._neighbor.compound.buildings.getFirstBuildingOfType("alliance-flag");
         if(_loc2_ != null && _loc2_.entity != null)
         {
            AllianceFlagEntity(_loc2_.entity).bannerData = param1.banner;
         }
      }
      
      private function onBuildingEntityMouseOver(param1:BuildingEntity) : void
      {
         this.ui_entityRollover.entity = param1;
         this.ui_entityRollover.label = null;
         if(!this._gui.contains(this.ui_entityRollover))
         {
            this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChildAt(this.ui_entityRollover,0);
         }
         MouseCursors.setCursor(MouseCursors.INTERACT);
      }
      
      private function onBuildingEntityMouseOut(param1:BuildingEntity) : void
      {
         this.ui_entityRollover.entity = null;
         this.ui_entityRollover.label = null;
         if(this.ui_entityRollover.parent != null)
         {
            this.ui_entityRollover.parent.removeChild(this.ui_entityRollover);
         }
         MouseCursors.setCursor(MouseCursors.DEFAULT);
      }
      
      private function onBuildingControlHidden() : void
      {
         this.selectBuilding(null);
      }
   }
}

