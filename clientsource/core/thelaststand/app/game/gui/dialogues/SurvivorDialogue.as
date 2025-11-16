package thelaststand.app.game.gui.dialogues
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.getDefinitionByName;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorClass;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.SurvivorState;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.gui.lists.UISurvivorList;
   import thelaststand.app.game.gui.lists.UISurvivorListItem;
   import thelaststand.app.game.gui.survivor.UISurvivorDetails;
   import thelaststand.app.game.logic.TimerManager;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class SurvivorDialogue extends BaseDialogue
   {
      
      private static var _selectedClass:String = "all";
      
      private var _classButtons:Vector.<PushButton>;
      
      private var _selectedClassButton:PushButton;
      
      private var _selectedSurvivor:Survivor;
      
      private var _lang:Language;
      
      private var bmp_commit:Bitmap;
      
      private var btn_saveLevelUp:PushButton;
      
      private var btn_edit:PushButton;
      
      private var btn_reassign:PushButton;
      
      private var btn_loadout:PushButton;
      
      private var mc_container:Sprite;
      
      private var ui_survivorList:UISurvivorList;
      
      private var ui_survivor:UISurvivorDetails;
      
      private var ui_page:UIPagination;
      
      public function SurvivorDialogue()
      {
         var _loc1_:TooltipManager = null;
         var _loc10_:String = null;
         var _loc11_:Class = null;
         var _loc12_:PushButton = null;
         _loc1_ = TooltipManager.getInstance();
         this.mc_container = new Sprite();
         super("survivor-dialgoue",this.mc_container,true);
         _autoSize = false;
         _width = 806;
         _height = 468;
         this._lang = Language.getInstance();
         closed.add(this.onClosed);
         this.bmp_commit = new Bitmap(new BmpIconButtonArrow());
         this.ui_survivor = new UISurvivorDetails();
         this.ui_survivor.modeChanged.add(this.onSurvivorDisplayModeChanged);
         this.mc_container.addChild(this.ui_survivor);
         this._classButtons = new Vector.<PushButton>();
         var _loc2_:int = int(this.ui_survivor.x + this.ui_survivor.width + 20);
         var _loc3_:Array = Network.getInstance().data.getSurvivorClassIds();
         var _loc4_:int = int(_loc3_.indexOf(SurvivorClass.PLAYER));
         if(_loc4_ > -1)
         {
            _loc3_.splice(_loc4_,1);
         }
         _loc3_.sort(Array.CASEINSENSITIVE);
         _loc3_.unshift(SurvivorClass.PLAYER);
         var _loc5_:int = 0;
         var _loc6_:int = int(_loc3_.length);
         while(_loc5_ < _loc6_)
         {
            _loc10_ = _loc3_[_loc5_];
            if(_loc10_ != SurvivorClass.UNASSIGNED)
            {
               _loc11_ = getDefinitionByName("BmpIconClass_" + _loc10_) as Class;
               _loc12_ = new PushButton("",new _loc11_());
               _loc12_.clicked.add(this.onCategoryButtonClicked);
               _loc12_.data = _loc10_;
               _loc12_.width = 40;
               _loc12_.x = _loc2_;
               _loc12_.selected = _loc10_ == _selectedClass;
               if(_loc12_.selected)
               {
                  this._selectedClassButton = _loc12_;
               }
               _loc2_ += _loc12_.width + 12;
               this._classButtons.push(_loc12_);
               this.mc_container.addChild(_loc12_);
               _loc1_.add(_loc12_,this._lang.getString("survivor_classes." + _loc12_.data),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
            }
            _loc5_++;
         }
         _loc12_ = new PushButton("",new BmpIconClass_all());
         _loc12_.clicked.add(this.onCategoryButtonClicked);
         _loc12_.data = "all";
         _loc12_.width = 40;
         _loc12_.x = _loc2_;
         _loc12_.selected = _selectedClass == _loc12_.data;
         if(_loc12_.selected)
         {
            this._selectedClassButton = _loc12_;
         }
         this._classButtons.push(_loc12_);
         this.mc_container.addChild(_loc12_);
         _loc1_.add(_loc12_,this._lang.getString("survivor_classes.all"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this.ui_survivorList = new UISurvivorList();
         this.ui_survivorList.x = int(this.ui_survivor.x + this.ui_survivor.width + 20) - 4;
         this.ui_survivorList.y = int(_loc12_.y + _loc12_.height + 7);
         this.ui_survivorList.width = int(_width - this.ui_survivorList.x - _padding * 2) + 2;
         this.ui_survivorList.height = 383;
         this.ui_survivorList.survivorList = Network.getInstance().playerData.compound.survivors.getSurvivorsByClass(_selectedClass);
         this.ui_survivorList.changed.add(this.onSurvivorSelected);
         this.mc_container.addChild(this.ui_survivorList);
         this.btn_loadout = new PushButton("",new BmpIconDefence());
         this.btn_loadout.width = this.btn_loadout.height;
         this.btn_loadout.x = int(this.ui_survivorList.x + (this.ui_survivorList.width - 76) - this.btn_loadout.width * 0.5);
         this.btn_loadout.selected = false;
         this.btn_loadout.clicked.add(this.onLoadoutClicked);
         this.mc_container.addChild(this.btn_loadout);
         _loc1_.add(this.btn_loadout,this.getLoadoutTooltip,new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
         this.ui_page = new UIPagination();
         this.ui_page.numPages = this.ui_survivorList.numPages;
         this.ui_page.x = int(this.ui_survivorList.x + (this.ui_survivorList.width - this.ui_page.width) * 0.5);
         this.ui_page.y = int(this.ui_survivorList.y + this.ui_survivorList.height + 8);
         this.ui_page.changed.add(this.onPageChanged);
         this.mc_container.addChild(this.ui_page);
         this.btn_saveLevelUp = new PushButton(this._lang.getString("survivor_edit_save"),this.bmp_commit,3183890);
         this.btn_saveLevelUp.x = int(this.ui_survivor.x + (this.ui_survivor.width - this.btn_saveLevelUp.width) * 0.5);
         this.btn_saveLevelUp.y = this.ui_page.y;
         this.btn_saveLevelUp.clicked.add(this.onSaveClicked);
         var _loc7_:int = 20;
         var _loc8_:int = 4;
         var _loc9_:int = (this.ui_survivor.width - _loc7_ - _loc8_ * 2) / 2;
         this.btn_edit = new PushButton(this._lang.getString("survivor_edit"));
         this.btn_edit.width = _loc9_;
         this.btn_edit.x = int(this.ui_survivor.x + _loc8_);
         this.btn_edit.y = this.ui_page.y;
         this.btn_edit.clicked.add(this.onEditClicked);
         this.btn_reassign = new PushButton(this._lang.getString("survivor_reassign"));
         this.btn_reassign.width = _loc9_;
         this.btn_reassign.x = int(this.btn_edit.x + this.btn_edit.width + _loc7_);
         this.btn_reassign.y = this.btn_edit.y;
         this.btn_reassign.clicked.add(this.onReassignClicked);
         this.selectSurvivor(this.ui_survivorList.survivorList.length > 0 ? this.ui_survivorList.survivorList[0] : Network.getInstance().playerData.getPlayerSurvivor());
         TimerManager.getInstance().timerCompleted.add(this.onTimerCompleted);
      }
      
      override public function dispose() : void
      {
         this.ui_survivor.dispose();
         this.ui_survivor = null;
         this.ui_survivorList.dispose();
         this.ui_survivorList = null;
         this.btn_loadout.dispose();
         this.btn_loadout = null;
         TooltipManager.getInstance().removeAllFromParent(this.mc_container);
         TimerManager.getInstance().timerCompleted.remove(this.onTimerCompleted);
         Network.getInstance().playerData.levelUpPointsChanged.remove(this.onLevelPointsChanged);
         this._selectedSurvivor = null;
         super.dispose();
      }
      
      override public function open() : void
      {
         super.open();
         Tracking.trackPageview("survivors/" + _selectedClass + "/page1");
      }
      
      override public function close() : void
      {
         if(this._selectedSurvivor != null)
         {
            this._selectedSurvivor.setActiveLoadout(null);
         }
         this.ui_survivor.saveAppearance();
         super.close();
      }
      
      private function selectSurvivor(param1:Survivor) : void
      {
         if(this._selectedSurvivor != null)
         {
            this._selectedSurvivor.setActiveLoadout(null);
         }
         this._selectedSurvivor = param1;
         if(this._selectedSurvivor != null)
         {
            this._selectedSurvivor.setActiveLoadout(this.ui_survivorList.loadoutType);
         }
         if(param1 == Network.getInstance().playerData.getPlayerSurvivor())
         {
            this.ui_survivor.showEditName = false;
            this.ui_survivor.setSurvivor(this._selectedSurvivor,UISurvivorDetails.MODE_VIEW);
            this.updateLevelPointsUI();
            Network.getInstance().playerData.levelUpPointsChanged.add(this.onLevelPointsChanged);
         }
         else
         {
            this.ui_survivor.showEditName = true;
            this.ui_survivor.setSurvivor(this._selectedSurvivor,UISurvivorDetails.MODE_VIEW);
            this.ui_survivor.levelPoints = 0;
            Network.getInstance().playerData.levelUpPointsChanged.remove(this.onLevelPointsChanged);
         }
         this.updateSurvivorButtons();
      }
      
      private function updateSurvivorButtons() : void
      {
         if(this.btn_edit.parent != null)
         {
            this.btn_edit.parent.removeChild(this.btn_edit);
         }
         if(this.btn_saveLevelUp.parent != null)
         {
            this.btn_saveLevelUp.parent.removeChild(this.btn_saveLevelUp);
         }
         if(this.btn_reassign.parent != null)
         {
            this.btn_reassign.parent.removeChild(this.btn_reassign);
         }
         switch(this.ui_survivor.mode)
         {
            case UISurvivorDetails.MODE_EDIT:
               this.btn_edit.label = this._lang.getString("survivor_edit_save");
               this.btn_edit.icon = this.bmp_commit;
               this.btn_edit.iconBackgroundColor = 3183890;
               this.mc_container.addChild(this.btn_edit);
               if(this._selectedSurvivor != Network.getInstance().playerData.getPlayerSurvivor() && this._selectedSurvivor.classId != SurvivorClass.UNASSIGNED)
               {
                  this.mc_container.addChild(this.btn_reassign);
               }
               break;
            case UISurvivorDetails.MODE_LEVEL:
               this.btn_saveLevelUp.enabled = false;
               this.mc_container.addChild(this.btn_saveLevelUp);
               break;
            default:
               this.btn_edit.label = this._lang.getString("survivor_edit");
               this.btn_edit.icon = null;
               this.mc_container.addChild(this.btn_edit);
               if(this._selectedSurvivor != Network.getInstance().playerData.getPlayerSurvivor() && this._selectedSurvivor.classId != SurvivorClass.UNASSIGNED)
               {
                  this.mc_container.addChild(this.btn_reassign);
               }
         }
         this.updateSurvivorButtonStates();
      }
      
      private function updateSurvivorButtonStates() : void
      {
         if(this._selectedSurvivor == null)
         {
            return;
         }
         var _loc1_:* = !(this._selectedSurvivor.state & SurvivorState.ON_MISSION || this._selectedSurvivor.state & SurvivorState.REASSIGNING || this._selectedSurvivor.state & SurvivorState.ON_ASSIGNMENT);
         this.btn_edit.enabled = _loc1_;
         this.btn_reassign.enabled = _loc1_ && this.ui_survivor.mode == UISurvivorDetails.MODE_VIEW;
      }
      
      private function getLoadoutTooltip() : String
      {
         if(this.ui_survivorList.loadoutType == SurvivorLoadout.TYPE_DEFENCE)
         {
            return this._lang.getString("survivor_loadout_defence");
         }
         return this._lang.getString("survivor_loadout_offence");
      }
      
      private function onCategoryButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:PushButton = param1.currentTarget as PushButton;
         if(_loc2_ == this._selectedClassButton)
         {
            return;
         }
         if(this._selectedClassButton != null)
         {
            this._selectedClassButton.selected = false;
         }
         this._selectedClassButton = _loc2_;
         this._selectedClassButton.selected = true;
         _selectedClass = _loc2_.data;
         Tracking.trackPageview("survivors/" + _selectedClass + "/page1");
         this.ui_survivorList.survivorList = Network.getInstance().playerData.compound.survivors.getSurvivorsByClass(_selectedClass);
         this.ui_page.numPages = this.ui_survivorList.numPages;
         this.ui_page.x = int(this.ui_survivorList.x + (this.ui_survivorList.width - this.ui_page.width) * 0.5);
      }
      
      private function onSurvivorSelected() : void
      {
         this.selectSurvivor(UISurvivorListItem(this.ui_survivorList.selectedItem).survivor);
      }
      
      private function onClosed(param1:Dialogue) : void
      {
         Network.getInstance().playerData.saveSurvivorOffensiveLoadout();
         Network.getInstance().playerData.saveSurvivorDefensiveLoadout();
         Network.getInstance().playerData.saveSurvivorClothingLoadout();
      }
      
      private function onPageChanged(param1:int) : void
      {
         this.ui_survivorList.gotoPage(param1);
         Tracking.trackPageview("survivors/" + _selectedClass + "/page" + (param1 + 1));
      }
      
      private function onAttributeModified(param1:String) : void
      {
         this.btn_saveLevelUp.enabled = this.playerHasModifiedAttributes();
      }
      
      private function playerHasModifiedAttributes() : Boolean
      {
         var _loc2_:String = null;
         var _loc1_:Object = this.ui_survivor.getPlayerAttributeTable().getModifiedAttriutes();
         for(_loc2_ in _loc1_)
         {
            if(int(_loc1_[_loc2_]) != 0)
            {
               return true;
            }
         }
         return false;
      }
      
      private function onSaveClicked(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         Network.getInstance().playerData.saveCustomization(null,this.ui_survivor.getPlayerAttributeTable().getModifiedAttriutes(),function(param1:Boolean):void
         {
            if(param1)
            {
            }
         });
      }
      
      private function updateLevelPointsUI() : void
      {
         var _loc1_:uint = Network.getInstance().playerData.levelPoints;
         this.ui_survivor.setMode(_loc1_ > 0 ? UISurvivorDetails.MODE_LEVEL : UISurvivorDetails.MODE_VIEW);
         this.ui_survivor.levelPoints = _loc1_;
         this.ui_survivor.getPlayerAttributeTable().attributeModified.add(this.onAttributeModified);
         this.btn_saveLevelUp.visible = _loc1_ > 0;
         this.btn_saveLevelUp.enabled = this.playerHasModifiedAttributes();
      }
      
      private function onEditClicked(param1:MouseEvent) : void
      {
         var _loc3_:MessageBox = null;
         if(this._selectedSurvivor == null || this.ui_survivor.mode == UISurvivorDetails.MODE_LEVEL)
         {
            return;
         }
         if(this.ui_survivor.mode == UISurvivorDetails.MODE_EDIT)
         {
            this.ui_survivor.setMode(UISurvivorDetails.MODE_VIEW);
            return;
         }
         var _loc2_:Language = Language.getInstance();
         if(Boolean(this._selectedSurvivor.state & SurvivorState.ON_MISSION) || Boolean(this._selectedSurvivor.state & SurvivorState.ON_ASSIGNMENT))
         {
            _loc3_ = new MessageBox(_loc2_.getString("srv_edit_cantassign_away_msg"));
            _loc3_.addTitle(_loc2_.getString("srv_edit_cantassign_away_title"));
            _loc3_.addButton(_loc2_.getString("srv_edit_cantassign_away_ok"));
         }
         else if(this._selectedSurvivor.state & SurvivorState.REASSIGNING)
         {
            _loc3_ = new MessageBox(_loc2_.getString("srv_edit_cantassign_reassign_msg"));
            _loc3_.addTitle(_loc2_.getString("srv_edit_cantassign_reassign_title"));
            _loc3_.addButton(_loc2_.getString("srv_edit_cantassign_reassign_ok"));
         }
         if(_loc3_ != null)
         {
            _loc3_.open();
            return;
         }
         this.ui_survivor.setMode(UISurvivorDetails.MODE_EDIT);
      }
      
      private function onReassignClicked(param1:MouseEvent) : void
      {
         var self:SurvivorDialogue = null;
         var dlgAssign:SurvivorClassAssignmentDialogue = null;
         var buildMsg:MessageBox = null;
         var e:MouseEvent = param1;
         var lang:Language = Language.getInstance();
         self = this;
         if(Network.getInstance().playerData.compound.buildings.getNumBuildingsOfType("trainingCenter",false) <= 0)
         {
            buildMsg = new MessageBox(lang.getString("survivor_reassign_build_msg"));
            buildMsg.addTitle(lang.getString("survivor_reassign_build_title"));
            buildMsg.addButton(lang.getString("survivor_reassign_build_ok")).clicked.addOnce(function(param1:MouseEvent):void
            {
               self.close();
               new ConstructionDialogue("trainingCenter").open();
            });
            buildMsg.addButton(lang.getString("survivor_reassign_build_cancel"));
            buildMsg.addImage(Building.getBuildingXML("trainingCenter").img.@uri.toString());
            buildMsg.open();
            return;
         }
         dlgAssign = new SurvivorClassAssignmentDialogue(this._selectedSurvivor,this._lang.getString("srv_reassign_title",this._selectedSurvivor.fullName));
         dlgAssign.selected.addOnce(function(param1:String, param2:Boolean):void
         {
            _selectedSurvivor.reassignClass(param1,param2);
            updateSurvivorButtonStates();
            dlgAssign.close();
         });
         dlgAssign.open();
      }
      
      private function onLoadoutClicked(param1:MouseEvent) : void
      {
         var _loc2_:String = this.ui_survivorList.loadoutType == SurvivorLoadout.TYPE_OFFENCE ? SurvivorLoadout.TYPE_DEFENCE : SurvivorLoadout.TYPE_OFFENCE;
         if(this._selectedSurvivor != null)
         {
            this._selectedSurvivor.setActiveLoadout(_loc2_);
         }
         this.ui_survivorList.loadoutType = _loc2_;
         this.ui_survivor.loadoutType = _loc2_;
         this.btn_loadout.selected = this.ui_survivorList.loadoutType == SurvivorLoadout.TYPE_DEFENCE;
         TooltipManager.getInstance().show(this.btn_loadout);
      }
      
      private function onTimerCompleted(param1:TimerData) : void
      {
         if(param1.target == this._selectedSurvivor || param1.target is MissionData)
         {
            this.updateSurvivorButtonStates();
         }
      }
      
      private function onSurvivorDisplayModeChanged() : void
      {
         this.updateSurvivorButtons();
      }
      
      private function onLevelPointsChanged() : void
      {
         this.updateLevelPointsUI();
      }
   }
}

