package thelaststand.app.game.gui.header
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.Tutorial;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.data.assignment.AssignmentData;
   import thelaststand.app.game.data.research.ResearchTask;
   import thelaststand.app.game.gui.UIBarBackground;
   import thelaststand.app.game.gui.compound.UIAssignedDisplay;
   import thelaststand.app.game.gui.compound.UIComfortDisplay;
   import thelaststand.app.game.gui.compound.UIMoraleDisplay;
   import thelaststand.app.game.gui.compound.UIReputationDisplay;
   import thelaststand.app.game.gui.compound.UISecurityDisplay;
   import thelaststand.app.game.gui.dialogues.CompoundReportDialogue;
   import thelaststand.app.game.gui.dialogues.PlayerSurvivorDialogue;
   import thelaststand.app.game.gui.survivor.UISurvivorArrivalProgress;
   import thelaststand.app.game.gui.tooltip.UIMoraleTooltip;
   import thelaststand.app.game.logic.TimerManager;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   
   public class UIHeader extends Sprite
   {
      
      private static const STATE_PLAYER_COMPOUND:String = "compound";
      
      private static const STATE_NEIGHBOR_COMPOUND:String = "neighborCompound";
      
      private static const STATE_MISSION:String = "mission";
      
      private const UPDATE_TIME:Number = 30;
      
      private var _lang:Language;
      
      private var _state:String;
      
      private var _stateData:Object;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _playerData:PlayerData;
      
      private var _timerManager:TimerManager;
      
      private var _tutorial:Tutorial;
      
      private var mc_container:Sprite;
      
      private var mc_bar:UIBarBackground;
      
      private var mc_survivorArrival:UISurvivorArrivalProgress;
      
      private var morale_player:UIMoraleDisplay;
      
      private var rep_player:UIReputationDisplay;
      
      private var res_cash:UICashDisplay;
      
      private var sec_player:UISecurityDisplay;
      
      private var com_player:UIComfortDisplay;
      
      private var assign_player:UIAssignedDisplay;
      
      private var txt_location:BodyTextField;
      
      private var xp_enemy:UIXPDisplay;
      
      private var xp_player:UIXPDisplay;
      
      private var morale_tooltip:UIMoraleTooltip;
      
      public function UIHeader()
      {
         super();
         this._lang = Language.getInstance();
         this._playerData = Network.getInstance().playerData;
         this._playerData.restedXPChanged.add(this.onRestedXPChanged);
         this._playerData.getPlayerSurvivor().levelIncreased.add(this.onPlayerLevelIncreased);
         this._timerManager = TimerManager.getInstance();
         this._timerManager.timerCompleted.add(this.onTimerCompleted);
         this.mc_container = new Sprite();
         addChild(this.mc_container);
         this.mc_bar = new UIBarBackground();
         this.mc_bar.width += 4;
         this.mc_bar.height += 1;
         this.mc_container.addChild(this.mc_bar);
         this.xp_player = new UIXPDisplay(this._playerData.getPlayerSurvivor(),UIXPDisplay.ALIGN_LEFT,15180544,3552822);
         this.xp_player.addEventListener(MouseEvent.CLICK,this.onClickPlayer,false,0,true);
         this.xp_player.restedXP = this._playerData.restedXP;
         this.mc_container.addChild(this.xp_player);
         this.morale_player = new UIMoraleDisplay();
         this.morale_player.value = this._playerData.compound.morale.getRoundedTotal();
         this.rep_player = new UIReputationDisplay();
         this.rep_player.visible = false;
         this.sec_player = new UISecurityDisplay();
         this.sec_player.value = this._playerData.compound.getSecurityRating();
         this.com_player = new UIComfortDisplay();
         this.com_player.value = this._playerData.compound.getComfortRating();
         this.assign_player = new UIAssignedDisplay();
         this.assign_player.maxValue = this._playerData.compound.survivors.length;
         this.assign_player.value = this._playerData.compound.survivors.getNumAssignedSurvivors();
         this.xp_enemy = new UIXPDisplay(null,UIXPDisplay.ALIGN_RIGHT,13369344,13113111);
         this.mc_survivorArrival = new UISurvivorArrivalProgress();
         this.mc_survivorArrival.progress = this._playerData.getNextSurvivorProgress();
         this.mc_survivorArrival.addEventListener(MouseEvent.CLICK,this.onClickSurvivor,false,0,true);
         this.res_cash = new UICashDisplay();
         this.res_cash.clicked.add(this.onClickAddCash);
         this.txt_location = new BodyTextField({
            "color":16777215,
            "size":16,
            "bold":true
         });
         this.txt_location.filters = [Effects.STROKE];
         this.txt_location.text = " ";
         this._width = this.mc_bar.width;
         this._height = this.mc_bar.height;
         this.morale_tooltip = new UIMoraleTooltip();
         this.morale_tooltip.morale = this._playerData.compound.morale;
         var _loc1_:TooltipManager = TooltipManager.getInstance();
         _loc1_.add(this.morale_player,this.morale_tooltip,new Point(10,12),TooltipDirection.DIRECTION_UP,0);
         _loc1_.add(this.rep_player,this._lang.getString("tooltip.reputation"),new Point(10,12),TooltipDirection.DIRECTION_UP,0);
         _loc1_.add(this.sec_player,this._lang.getString("tooltip.security"),new Point(10,12),TooltipDirection.DIRECTION_UP,0);
         _loc1_.add(this.com_player,this._lang.getString("tooltip.comfort"),new Point(10,12),TooltipDirection.DIRECTION_UP,0);
         _loc1_.add(this.assign_player,this.getAssignedTooltip,new Point(10,12),TooltipDirection.DIRECTION_UP,0);
         _loc1_.add(this.res_cash,this._lang.getString("tooltip.res_fuel"),new Point(this.res_cash.width - 10,this.res_cash.y + this.res_cash.height - 4),TooltipDirection.DIRECTION_UP,0);
         _loc1_.add(this.xp_player,this.getXPTooltip,new Point(NaN,this.xp_player.height - 10),TooltipDirection.DIRECTION_UP);
         _loc1_.add(this.mc_survivorArrival,this._lang.getString("tooltip.srv_arrival"),new Point(this.mc_survivorArrival.width - 14,this.mc_survivorArrival.height),TooltipDirection.DIRECTION_UP);
         this._tutorial = Tutorial.getInstance();
         this._tutorial.stepChanged.add(this.onTutorialStepChanged);
         this._playerData.compound.buildings.buildingRemoved.add(this.onBuildingRemoved);
         this._playerData.compound.survivors.survivorAdded.add(this.onSurvivorAddedOrChanged);
         this._playerData.compound.survivors.survivorRallyAssignmentChanged.add(this.onSurvivorAddedOrChanged);
         this._playerData.compound.resources.resourceChanged.add(this.onResourceChanged);
         this._playerData.stateUpdated.add(this.onPlayerStateUpdated);
         this._playerData.researchState.researchCompleted.add(this.onPlayerResearchCompleted);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         TooltipManager.getInstance().removeAllFromParent(this,true);
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         TweenMax.killChildTweensOf(this);
         this._timerManager.timerCompleted.remove(this.onTimerCompleted);
         this._timerManager = null;
         this._tutorial.stepChanged.remove(this.onTutorialStepChanged);
         this._tutorial = null;
         this._playerData.getPlayerSurvivor().levelIncreased.remove(this.onPlayerLevelIncreased);
         this._playerData.restedXPChanged.remove(this.onRestedXPChanged);
         this._playerData.compound.buildings.buildingRemoved.remove(this.onBuildingRemoved);
         this._playerData.compound.survivors.survivorAdded.remove(this.onSurvivorAddedOrChanged);
         this._playerData.compound.survivors.survivorRallyAssignmentChanged.remove(this.onSurvivorAddedOrChanged);
         this._playerData.compound.resources.resourceChanged.remove(this.onResourceChanged);
         this._playerData.stateUpdated.remove(this.onPlayerStateUpdated);
         this._playerData.researchState.researchCompleted.remove(this.onPlayerResearchCompleted);
         this._playerData = null;
         this._state = null;
         this._stateData = null;
         this.xp_enemy.dispose();
         this.xp_enemy = null;
         this.xp_player.dispose();
         this.xp_player = null;
         this.res_cash.dispose();
         this.res_cash = null;
         this.mc_bar.dispose();
         this.mc_bar = null;
         this.morale_player.dispose();
         this.morale_player = null;
         this.rep_player.dispose();
         this.rep_player = null;
         this.sec_player.dispose();
         this.sec_player = null;
         this.com_player.dispose();
         this.com_player = null;
         this.assign_player.dispose();
         this.assign_player = null;
         this.mc_survivorArrival.dispose();
         this.mc_survivorArrival = null;
      }
      
      private function positionElements() : void
      {
         var _loc1_:Number = NaN;
         this.mc_bar.y = -1;
         this.mc_container.x = 0;
         if(!TweenMax.isTweening(this.mc_container))
         {
            this.mc_container.y = 0;
         }
         this.xp_player.x = Math.max(16,this.mc_bar.x + 16);
         this.xp_player.y = 8;
         switch(this._state)
         {
            case STATE_PLAYER_COMPOUND:
               this.morale_player.x = int(this.xp_player.x + this.xp_player.width + 12);
               this.morale_player.y = int(this.mc_bar.height * 0.5);
               this.sec_player.x = int(this.morale_player.x + 60);
               this.sec_player.y = int(this.morale_player.y);
               this.com_player.x = int(this.sec_player.x + 50);
               this.com_player.y = int(this.sec_player.y);
               this.assign_player.x = int(this.com_player.x + 56);
               this.assign_player.y = int(this.com_player.y);
               this.res_cash.x = int(Math.min(this.mc_bar.width - 20,this._width - 16) - this.res_cash.width);
               this.res_cash.y = int((this.mc_bar.height - this.res_cash.height) * 0.5);
               _loc1_ = Math.min(1,this._width / this.mc_bar.width);
               this.mc_survivorArrival.width = _loc1_ * _loc1_ * 200;
               this.mc_survivorArrival.x = int(this.res_cash.x - this.mc_survivorArrival.width - 30);
               this.mc_survivorArrival.y = int((this.mc_bar.height - this.mc_survivorArrival.height) * 0.5);
               break;
            case STATE_NEIGHBOR_COMPOUND:
               break;
            case STATE_MISSION:
               this.txt_location.x = int((this._width - this.txt_location.width) * 0.5);
               this.txt_location.y = int((this.mc_bar.height - this.txt_location.height) * 0.5);
               this.xp_enemy.x = int(Math.min(this.mc_bar.width - 20,this._width - 16) - this.xp_enemy.width);
               this.xp_enemy.y = this.xp_player.y;
         }
      }
      
      private function getXPTooltip() : String
      {
         var _loc1_:Survivor = this._playerData.getPlayerSurvivor();
         var _loc2_:String = NumberFormatter.format(_loc1_.XP,0) + " / " + NumberFormatter.format(_loc1_.getXPForNextLevel(),0);
         if(_loc1_.level >= _loc1_.levelMax)
         {
            _loc2_ += " (" + this._lang.getString("max").toUpperCase() + ")";
         }
         var _loc3_:String = "";
         if(this._playerData.restedXP > 0)
         {
            _loc3_ += this._lang.getString("tooltip.xp_rested");
         }
         if(this._playerData.levelPoints > 0)
         {
            _loc3_ += this._lang.getString("tooltip.xp_levelUp");
         }
         return this._lang.getString("tooltip.xp_bar",_loc3_,_loc2_);
      }
      
      private function getAssignedTooltip() : String
      {
         return this._lang.getString("tooltip.assigned",this._playerData.compound.survivors.getNumAssignedSurvivors(),this._playerData.compound.survivors.length);
      }
      
      private function gotoState(param1:String, param2:Object = null) : void
      {
         var _loc4_:RemotePlayerData = null;
         var _loc5_:MissionData = null;
         var _loc6_:AssignmentData = null;
         var _loc7_:PlayerData = null;
         var _loc8_:* = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         if(param1 == this._state && this._stateData == param2)
         {
            return;
         }
         var _loc3_:Number = this._state == null ? 0.25 : 0;
         switch(this._state)
         {
            case STATE_NEIGHBOR_COMPOUND:
            case STATE_PLAYER_COMPOUND:
               _loc3_ += this.transitionOutCompoundGUI(_loc3_);
               break;
            case STATE_MISSION:
               _loc3_ += this.transitionOutMissionGUI(_loc3_);
         }
         this._state = param1;
         this._stateData = param2;
         this.positionElements();
         switch(this._state)
         {
            case STATE_PLAYER_COMPOUND:
               this.xp_player.data = this._playerData.getPlayerSurvivor();
               this.xp_player.restedXP = this._playerData.restedXP;
               this.res_cash.value = this._playerData.compound.resources.getAmount(GameResources.CASH);
               this.transitionInPlayerCompoundGUI(_loc3_);
               TooltipManager.getInstance().add(this.xp_player,this.getXPTooltip,new Point(NaN,this.xp_player.height - 10),TooltipDirection.DIRECTION_UP);
               break;
            case STATE_NEIGHBOR_COMPOUND:
               this.xp_player.data = RemotePlayerData(param2);
               this.xp_player.restedXP = 0;
               this.transitionInNeighborCompoundGUI(_loc3_);
               TooltipManager.getInstance().remove(this.xp_player);
               break;
            case STATE_MISSION:
               if(param2 is RemotePlayerData)
               {
                  _loc4_ = param2 as RemotePlayerData;
                  this.txt_location.text = this._lang.getString("viewing_player",_loc4_.nickname).toUpperCase();
                  this.xp_enemy.data = _loc4_;
               }
               else if(param2 as MissionData)
               {
                  _loc5_ = param2 as MissionData;
                  this.xp_enemy.data = _loc5_.opponent;
                  _loc7_ = Network.getInstance().playerData;
                  if(Boolean(_loc5_.assignmentId) && (Boolean(_loc6_ = _loc7_.assignments.getById(_loc5_.assignmentId))))
                  {
                     _loc8_ = _loc6_.type.toLowerCase() + ".";
                     _loc9_ = Language.getInstance().getString(_loc8_ + _loc6_.name + ".name");
                     _loc10_ = Language.getInstance().getString(_loc8_ + _loc6_.name + ".stage_" + _loc6_.getStage(_loc6_.currentStageIndex).stageXml.@id.toString());
                     this.txt_location.text = (_loc9_ + " - " + _loc10_).toUpperCase();
                  }
                  else if(_loc5_.opponent.isPlayer)
                  {
                     this.txt_location.text = this._lang.getString("attacking_player",_loc5_.opponent.nickname).toUpperCase();
                  }
                  else if(_loc5_.type == "compound")
                  {
                     this.txt_location.text = "";
                  }
                  else
                  {
                     this.txt_location.text = this._lang.getString("locations." + _loc5_.type,this._lang.getString("suburbs." + _loc5_.suburb)).toUpperCase();
                  }
               }
               this.txt_location.x = int((this._width - this.txt_location.width) * 0.5);
               this.transitionInMissionGUI(_loc3_);
               TooltipManager.getInstance().add(this.xp_player,this.getXPTooltip,new Point(NaN,this.xp_player.height - 10),TooltipDirection.DIRECTION_UP);
         }
      }
      
      private function transitionInPlayerCompoundGUI(param1:Number = 0) : Number
      {
         var delay:Number = param1;
         TweenMax.to(this.mc_container,0.25,{
            "delay":delay,
            "y":0,
            "onInit":function():void
            {
               mc_container.addChild(morale_player);
               mc_container.addChild(rep_player);
               mc_container.addChild(sec_player);
               mc_container.addChild(com_player);
               mc_container.addChild(assign_player);
               mc_container.addChild(res_cash);
               mc_container.addChild(mc_survivorArrival);
            }
         });
         return 0.25;
      }
      
      private function transitionOutCompoundGUI(param1:Number = 0) : Number
      {
         var delay:Number = param1;
         var length:Number = 0.25;
         TweenMax.to(this.mc_container,length,{
            "delay":delay,
            "y":-int(this.mc_bar.height + 50),
            "ease":Quad.easeIn,
            "onComplete":function():void
            {
               if(morale_player.parent != null)
               {
                  morale_player.parent.removeChild(morale_player);
               }
               if(rep_player.parent != null)
               {
                  rep_player.parent.removeChild(rep_player);
               }
               if(sec_player.parent != null)
               {
                  sec_player.parent.removeChild(sec_player);
               }
               if(com_player.parent != null)
               {
                  com_player.parent.removeChild(com_player);
               }
               if(assign_player.parent != null)
               {
                  assign_player.parent.removeChild(assign_player);
               }
               if(res_cash.parent != null)
               {
                  res_cash.parent.removeChild(res_cash);
               }
               if(mc_survivorArrival.parent != null)
               {
                  mc_survivorArrival.parent.removeChild(mc_survivorArrival);
               }
            }
         });
         return length;
      }
      
      private function transitionInNeighborCompoundGUI(param1:Number = 0) : Number
      {
         var _loc2_:Number = 0.25;
         TweenMax.to(this.mc_container,_loc2_,{
            "delay":param1,
            "y":0
         });
         return _loc2_;
      }
      
      private function transitionInMissionGUI(param1:Number = 0) : Number
      {
         var delay:Number = param1;
         var length:Number = 0.25;
         TweenMax.to(this.mc_container,length,{
            "delay":delay,
            "y":0,
            "onInit":function():void
            {
               mc_container.addChild(txt_location);
               mc_container.addChild(xp_enemy);
            }
         });
         return length;
      }
      
      private function transitionOutMissionGUI(param1:Number = 0) : Number
      {
         var delay:Number = param1;
         var length:Number = 0.25;
         TweenMax.to(this.mc_container,length,{
            "delay":delay,
            "y":-int(this.mc_bar.height + 50),
            "ease":Quad.easeIn,
            "onComplete":function():void
            {
               if(txt_location.parent != null)
               {
                  txt_location.parent.removeChild(txt_location);
               }
               if(xp_enemy.parent != null)
               {
                  xp_enemy.parent.removeChild(xp_enemy);
               }
            }
         });
         return length;
      }
      
      private function setLocationName(param1:String) : void
      {
         this.txt_location.text = param1.toUpperCase();
         this.txt_location.x = int((this._width - this.txt_location.width) * 0.5);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         stage.addEventListener(NavigationEvent.REQUEST,this.onNavigationRequest,false,-1);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         stage.removeEventListener(NavigationEvent.REQUEST,this.onNavigationRequest);
      }
      
      private function onNavigationRequest(param1:NavigationEvent) : void
      {
         switch(param1.location)
         {
            case NavigationLocation.PLAYER_COMPOUND:
            case NavigationLocation.WORLD_MAP:
               this.gotoState(STATE_PLAYER_COMPOUND,param1.data);
               break;
            case NavigationLocation.NEIGHBOR_COMPOUND:
               this.gotoState(STATE_NEIGHBOR_COMPOUND,param1.data);
               break;
            case NavigationLocation.MISSION:
            case NavigationLocation.MISSION_PLANNING:
               this.gotoState(STATE_MISSION,param1.data);
         }
      }
      
      private function onPlayerStateUpdated() : void
      {
         if(this.morale_player.parent != null)
         {
            this.morale_player.value = this._playerData.compound.morale.getRoundedTotal();
         }
         if(this.mc_survivorArrival.parent != null)
         {
            this.mc_survivorArrival.progress = this._playerData.getNextSurvivorProgress();
         }
         this.res_cash.value = this._playerData.compound.resources.getAmount(GameResources.CASH);
      }
      
      private function onResourceChanged(param1:String, param2:Number) : void
      {
         if(param1 != GameResources.CASH || this.res_cash == null)
         {
            return;
         }
         this.res_cash.value = param2;
      }
      
      private function onClickAddCash(param1:MouseEvent) : void
      {
         Tracking.trackEvent("Header","GetMoreFuel");
         PaymentSystem.getInstance().openBuyCoinsScreen(false);
      }
      
      private function onClickSurvivor(param1:MouseEvent) : void
      {
         if(DialogueManager.getInstance().getDialogueById("compound-report-dialogue") != null)
         {
            return;
         }
         Tracking.trackEvent("Header","CompoundReport");
         var _loc2_:CompoundReportDialogue = new CompoundReportDialogue();
         _loc2_.open();
      }
      
      private function onClickPlayer(param1:MouseEvent) : void
      {
         if(DialogueManager.getInstance().numDialoguesOpen > 0)
         {
            return;
         }
         if(this._state != STATE_PLAYER_COMPOUND)
         {
            return;
         }
         Tracking.trackEvent("Header","PlayerProfile");
         var _loc2_:* = this._state == STATE_PLAYER_COMPOUND;
         var _loc3_:PlayerSurvivorDialogue = new PlayerSurvivorDialogue(_loc2_);
         _loc3_.open();
      }
      
      private function onBuildingRemoved(param1:Building) : void
      {
         this.com_player.value = this._playerData.compound.getComfortRating();
         this.sec_player.value = this._playerData.compound.getSecurityRating();
      }
      
      private function onSurvivorAddedOrChanged(param1:Survivor) : void
      {
         this.assign_player.maxValue = this._playerData.compound.survivors.length;
         this.assign_player.value = this._playerData.compound.survivors.getNumAssignedSurvivors();
      }
      
      private function onTimerCompleted(param1:TimerData) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(param1.target is Building)
         {
            if(this._playerData == null)
            {
               return;
            }
            this.com_player.value = this._playerData.compound.getComfortRating();
            this.sec_player.value = this._playerData.compound.getSecurityRating();
         }
      }
      
      private function onTutorialStepChanged() : void
      {
         switch(this._tutorial.step)
         {
            case Tutorial.STEP_MORE_SURIVOVRS:
               this._tutorial.addArrow(this.mc_survivorArrival,-25,new Point(6,this.mc_survivorArrival.height - 4));
               break;
            case Tutorial.STEP_MORALE:
               this._tutorial.addArrow(this.morale_player,-90,new Point(this.morale_player.width * 0.5,this.morale_player.height + 4));
         }
      }
      
      private function onRestedXPChanged() : void
      {
         if(this.xp_player.data == this._playerData.getPlayerSurvivor())
         {
            this.xp_player.restedXP = this._playerData.restedXP;
         }
      }
      
      private function onPlayerLevelIncreased(param1:Survivor, param2:int) : void
      {
         this.onRestedXPChanged();
      }
      
      private function onPlayerResearchCompleted(param1:ResearchTask) : void
      {
         this.com_player.value = this._playerData.compound.getComfortRating();
         this.sec_player.value = this._playerData.compound.getSecurityRating();
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         if(param1 > this.mc_bar.width)
         {
            param1 = this.mc_bar.width;
         }
         this._width = param1;
         this.positionElements();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      public function get playerXPDisplay() : UIXPDisplay
      {
         return this.xp_player;
      }
   }
}

