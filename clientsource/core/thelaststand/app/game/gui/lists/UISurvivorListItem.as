package thelaststand.app.game.gui.lists
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.utils.getDefinitionByName;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorClass;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.SurvivorState;
   import thelaststand.app.game.data.Task;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.UISimpleProgressBar;
   import thelaststand.app.game.gui.UISurvivorPortrait;
   import thelaststand.app.game.gui.compound.UIMoraleDisplay;
   import thelaststand.app.game.gui.loadout.UILoadoutSlot;
   import thelaststand.app.game.gui.survivor.UISurvivorHealthBarLarge;
   import thelaststand.app.game.gui.tooltip.UIMoraleTooltip;
   import thelaststand.app.game.gui.tooltip.UISurvivorClassTooltip;
   import thelaststand.app.game.logic.TimerManager;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.lang.Language;
   
   public class UISurvivorListItem extends UIPagedListItem
   {
      
      private static const BMP_INJURED:BitmapData = new BmpIconInjuries();
      
      private static const BMP_RALLY_ASSIGNED:BitmapData = new BmpIconAssign();
      
      internal static const COLOR_NORMAL:int = 2434341;
      
      internal static const COLOR_ALT:int = 1447446;
      
      internal static const COLOR_AWAY:int = 4988446;
      
      internal static const COLOR_SELECTED:int = 5000268;
      
      internal static const COLOR_OVER:int = 3158064;
      
      internal static const COLOR_AWAY_OVER:int = 6433322;
      
      private var _alternating:Boolean;
      
      private var _lang:Language;
      
      private var _survivor:Survivor;
      
      private var _segmentWidth:int = 330;
      
      private var _showLoadout:Boolean;
      
      private var _showMorale:Boolean = true;
      
      private var _showInjuries:Boolean = true;
      
      private var _loadoutType:String = "offence";
      
      private var _tooltip:TooltipManager;
      
      private var _timeManager:TimerManager;
      
      private var ui_classTooltip:UISurvivorClassTooltip = new UISurvivorClassTooltip();
      
      private var mc_background:Sprite;
      
      private var txt_name:BodyTextField;
      
      private var txt_className:BodyTextField;
      
      private var txt_level:BodyTextField;
      
      private var txt_state:BodyTextField;
      
      private var bmp_classIcon:Bitmap;
      
      private var mc_injured:Sprite;
      
      private var mc_rallyAssigned:Sprite;
      
      private var mc_portrait:UISurvivorPortrait;
      
      private var mc_morale:UIMoraleDisplay;
      
      private var mc_separator:Shape;
      
      private var ui_slotWeapon:UILoadoutSlot;
      
      private var ui_slotGearPassive:UILoadoutSlot;
      
      private var ui_slotGearActive:UILoadoutSlot;
      
      private var ui_itemInfo:UIItemInfo;
      
      private var morale_tooltip:UIMoraleTooltip;
      
      private var ui_xp:UISimpleProgressBar;
      
      private var ui_health:UISurvivorHealthBarLarge;
      
      public function UISurvivorListItem(param1:Boolean = true)
      {
         super();
         this._showLoadout = param1;
         _width = this._showLoadout ? 488 : 305;
         _height = 53;
         this._segmentWidth = this._showLoadout ? _width - 158 : _width;
         this._lang = Language.getInstance();
         this._tooltip = TooltipManager.getInstance();
         this._timeManager = TimerManager.getInstance();
         this._timeManager.timerCompleted.add(this.onTimerCompleted);
         this.mc_background = new Sprite();
         this.mc_background.graphics.beginFill(1447446);
         this.mc_background.graphics.drawRect(0,0,_width,_height);
         this.mc_background.graphics.endFill();
         addChild(this.mc_background);
         this.mc_portrait = new UISurvivorPortrait(UISurvivorPortrait.SIZE_40x40,3552822);
         this.mc_portrait.x = 10;
         this.mc_portrait.y = 6;
         this.mc_portrait.filters = [Effects.STROKE];
         this._tooltip.add(this.mc_portrait,this.getPortraitTooltip,new Point(0,NaN),TooltipDirection.DIRECTION_RIGHT,0.2);
         this.ui_health = new UISurvivorHealthBarLarge();
         this.ui_health.width = int(this.mc_portrait.width * 0.8);
         this.ui_health.x = int(this.mc_portrait.x + (this.mc_portrait.width - this.ui_health.width) * 0.5);
         this.ui_health.y = int(this.mc_portrait.y + this.mc_portrait.height - this.ui_health.height - (this.ui_health.x - this.mc_portrait.x));
         this.txt_name = new BodyTextField({
            "color":16777215,
            "size":13,
            "bold":true
         });
         this.txt_name.x = int(this.mc_portrait.x + this.mc_portrait.width + 5);
         this.txt_name.y = int(this.mc_portrait.y + 2);
         this.txt_name.text = " ";
         this.txt_name.filters = [Effects.TEXT_SHADOW_DARK];
         this.txt_className = new BodyTextField({
            "color":12237498,
            "size":12,
            "bold":true
         });
         this.txt_className.x = this.txt_name.x;
         this.txt_className.y = int(this.txt_name.y + this.txt_name.height - 2);
         this.txt_className.text = " ";
         this.txt_className.filters = [Effects.TEXT_SHADOW_DARK];
         this.txt_level = new BodyTextField({
            "color":16434707,
            "size":12,
            "bold":true
         });
         this.txt_level.x = this.txt_name.x;
         this.txt_level.y = this.txt_className.y;
         this.txt_level.text = " ";
         this.txt_level.filters = [Effects.TEXT_SHADOW_DARK];
         this.ui_xp = new UISimpleProgressBar(16434707,0);
         this.ui_xp.width = 35;
         this.ui_xp.height = 5;
         this.bmp_classIcon = new Bitmap();
         this.bmp_classIcon.x = this.txt_name.x;
         this.bmp_classIcon.y = int(this.txt_name.y + this.txt_name.height - 1);
         this.txt_state = new BodyTextField({
            "color":16777215,
            "size":12,
            "bold":true
         });
         this.txt_state.x = this._segmentWidth;
         this.txt_state.y = this.txt_name.y;
         this.txt_state.text = " ";
         this.txt_state.filters = [Effects.TEXT_SHADOW_DARK];
         this.mc_morale = new UIMoraleDisplay();
         this.mc_morale.showValue = false;
         this.mc_morale.y = int(this.txt_state.y + this.txt_state.height - 1 + this.mc_morale.height * 0.5);
         if(this._showLoadout)
         {
            this.mc_separator = new Shape();
            this.mc_separator.graphics.beginFill(9605778,0.25);
            this.mc_separator.graphics.drawRect(0,0,4,_height + 1);
            this.mc_separator.graphics.endFill();
            this.mc_separator.graphics.beginFill(0,1);
            this.mc_separator.graphics.drawRect(1,0,2,_height + 1);
            this.mc_separator.graphics.endFill();
            this.mc_separator.x = this._segmentWidth;
            addChild(this.mc_separator);
            this.ui_slotWeapon = new UILoadoutSlot();
            this.ui_slotWeapon.clicked.add(this.onSlotClicked);
            this.ui_slotWeapon.mouseOver.add(this.onMouseOverSlot);
            this.ui_slotWeapon.y = int((_height - this.ui_slotWeapon.height) * 0.5);
            this.ui_slotGearPassive = new UILoadoutSlot();
            this.ui_slotGearPassive.clicked.add(this.onSlotClicked);
            this.ui_slotGearPassive.mouseOver.add(this.onMouseOverSlot);
            this.ui_slotGearPassive.y = this.ui_slotWeapon.y;
            this.ui_slotGearActive = new UILoadoutSlot();
            this.ui_slotGearActive.clicked.add(this.onSlotClicked);
            this.ui_slotGearActive.mouseOver.add(this.onMouseOverSlot);
            this.ui_slotGearActive.y = this.ui_slotWeapon.y;
            this.ui_itemInfo = new UIItemInfo();
            this.ui_itemInfo.displayClothingPreview = false;
         }
         this.morale_tooltip = new UIMoraleTooltip();
         this._tooltip.add(this.mc_morale,this.morale_tooltip,new Point(0,NaN),TooltipDirection.DIRECTION_RIGHT);
      }
      
      private function getPortraitTooltip() : Sprite
      {
         if(this._survivor.classId == SurvivorClass.UNASSIGNED)
         {
            return null;
         }
         this.ui_classTooltip.survivorClassId = this._survivor.classId;
         return this.ui_classTooltip;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this._tooltip.removeAllFromParent(this);
         this._tooltip = null;
         this._timeManager.timerCompleted.remove(this.onTimerCompleted);
         this._timeManager = null;
         this._lang = null;
         if(this.bmp_classIcon != null && this.bmp_classIcon.bitmapData != null)
         {
            this.bmp_classIcon.bitmapData.dispose();
            this.bmp_classIcon.bitmapData = null;
         }
         this.bmp_classIcon = null;
         if(this._survivor != null)
         {
            if(this._survivor.task != null)
            {
               this._survivor.task.completed.remove(this.onTaskCompleted);
            }
            this._survivor.loadoutOffence.changed.remove(this.onLoadoutChanged);
            this._survivor.loadoutDefence.changed.remove(this.onLoadoutChanged);
            this._survivor.classChanged.remove(this.onClassChanged);
            this._survivor.nameChanged.remove(this.onNameChanged);
            this._survivor.injuries.changed.remove(this.onInjuriesChanged);
            this._survivor = null;
         }
         this.mc_morale.dispose();
         this.mc_morale = null;
         this.mc_portrait.dispose();
         this.mc_portrait = null;
         this.morale_tooltip.dispose();
         this.morale_tooltip = null;
         this.txt_className.dispose();
         this.txt_className = null;
         this.txt_level.dispose();
         this.txt_level = null;
         this.txt_name.dispose();
         this.txt_name = null;
         this.txt_state.dispose();
         this.txt_state = null;
         this.ui_xp.dispose();
         this.ui_xp = null;
         if(this.ui_itemInfo != null)
         {
            this.ui_itemInfo.dispose();
            this.ui_itemInfo = null;
         }
         if(this.ui_slotWeapon != null)
         {
            this.ui_slotWeapon.dispose();
            this.ui_slotWeapon = null;
         }
         if(this.ui_slotGearPassive != null)
         {
            this.ui_slotGearPassive.dispose();
            this.ui_slotGearPassive = null;
         }
         if(this.ui_slotGearActive != null)
         {
            this.ui_slotGearActive.dispose();
            this.ui_slotGearActive = null;
         }
      }
      
      private function getBackgroundColor() : uint
      {
         if(this._survivor != null && (Boolean(this._survivor.state & SurvivorState.ON_MISSION) || Boolean(this._survivor.state & SurvivorState.REASSIGNING) || Boolean(this._survivor.state & SurvivorState.ON_ASSIGNMENT)))
         {
            return COLOR_AWAY;
         }
         if(this._alternating)
         {
            return COLOR_ALT;
         }
         return COLOR_NORMAL;
      }
      
      private function getXPTooltip() : String
      {
         var _loc1_:String = NumberFormatter.format(this._survivor.XP,0) + " / " + NumberFormatter.format(this._survivor.getXPForNextLevel(),0);
         return this._lang.getString("tooltip.xp_srv",_loc1_);
      }
      
      private function update() : void
      {
         var _loc1_:Class = null;
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this.mc_background.width = _width;
         TweenMax.to(this.mc_background,0,{
            "tint":this.getBackgroundColor(),
            "overwrite":true
         });
         if(this.ui_health.parent != null)
         {
            this.ui_health.parent.removeChild(this.ui_health);
         }
         if(this._survivor == null)
         {
            return;
         }
         this.txt_name.text = this._survivor.fullName.toUpperCase();
         this.txt_level.text = this._lang.getString("lvl",this._survivor.level + 1) + (this._survivor.level >= this._survivor.levelMax ? " (" + this._lang.getString("max").toUpperCase() + ")" : "");
         this.ui_xp.progress = this._survivor.XP / this._survivor.getXPForNextLevel();
         this.txt_className.textColor = 12237498;
         this.mc_portrait.survivor = this._survivor;
         this.ui_health.survivor = this._survivor;
         if(this._survivor.level >= this._survivor.levelMax)
         {
            this._tooltip.remove(this.ui_xp);
         }
         else
         {
            this._tooltip.add(this.ui_xp,this.getXPTooltip,new Point(this.ui_xp.width,NaN),TooltipDirection.DIRECTION_LEFT);
         }
         this.morale_tooltip.morale = this._survivor.morale;
         if(this._survivor.classId == SurvivorClass.UNASSIGNED)
         {
            if(this.bmp_classIcon.parent != null)
            {
               this.bmp_classIcon.parent.removeChild(this.bmp_classIcon);
            }
            if(this.txt_level.parent != null)
            {
               this.txt_level.parent.removeChild(this.txt_level);
            }
            if(this.ui_xp.parent != null)
            {
               this.ui_xp.parent.removeChild(this.ui_xp);
            }
            this.txt_className.text = this._lang.getString("survivor_classes.unassigned").toUpperCase();
            this.txt_className.textColor = Effects.COLOR_WARNING;
            this.txt_className.x = int(this.bmp_classIcon.x);
            addChild(this.txt_className);
         }
         else
         {
            _loc1_ = getDefinitionByName("BmpIconClass_" + this._survivor.classId) as Class;
            if(_loc1_ != null)
            {
               this.bmp_classIcon.bitmapData = new _loc1_();
            }
            this.txt_className.text = this._lang.getString("survivor_classes." + this._survivor.classId).toUpperCase();
            this.txt_className.x = int(this.bmp_classIcon.x + this.bmp_classIcon.width + 2);
            this.txt_level.x = int(this.txt_className.x + this.txt_className.width + 8);
            this.ui_xp.x = int(this.txt_level.x + this.txt_level.width + 6);
            this.bmp_classIcon.y = Math.round(this.txt_className.y + (this.txt_className.height - this.bmp_classIcon.height) * 0.5);
            this.ui_xp.y = int(this.txt_level.y + (this.txt_level.height - this.ui_xp.height) * 0.5) + 1;
            addChild(this.bmp_classIcon);
            addChild(this.txt_className);
            addChild(this.txt_level);
            addChild(this.ui_xp);
         }
         if(this._survivor.state & SurvivorState.ON_MISSION)
         {
            this.txt_state.textColor = Effects.COLOR_WARNING;
            addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
            this.updateMissionReturnTime();
         }
         else if(this._survivor.state & SurvivorState.ON_ASSIGNMENT)
         {
            this.txt_state.textColor = Effects.COLOR_WARNING;
            this.txt_state.text = this._lang.getString("survivor_state.assignment").toUpperCase();
            this.txt_state.x = this._showLoadout ? int(this._segmentWidth - this.txt_state.width - 8) : int(_width - this.txt_state.width - 8);
         }
         else if(this._survivor.state & SurvivorState.REASSIGNING)
         {
            this.txt_state.textColor = Effects.COLOR_WARNING;
            addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
            this.updateReassignTime();
         }
         else if(Boolean(this._survivor.state & SurvivorState.ON_TASK) && this._survivor.task != null)
         {
            this.txt_state.textColor = 16763904;
            this._survivor.task.completed.addOnce(this.onTaskCompleted);
            addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
            this.updateTaskTime();
         }
         else if(this._survivor.state == SurvivorState.AVAILABLE)
         {
            this.txt_state.textColor = Effects.COLOR_GREEN;
            this.txt_state.text = this._lang.getString("survivor_state.available").toUpperCase();
            this.txt_state.x = this._showLoadout ? int(this._segmentWidth - this.txt_state.width - 8) : int(_width - this.txt_state.width - 8);
         }
         addChild(this.txt_name);
         addChild(this.txt_state);
         addChild(this.mc_portrait);
         this.updateStateDisplay();
         if(this._showLoadout)
         {
            this.ui_slotWeapon.x = this.mc_separator.x + 20;
            this.ui_slotGearPassive.x = int(this.ui_slotWeapon.x + this.ui_slotWeapon.width + 14);
            this.ui_slotGearActive.x = int(this.ui_slotGearPassive.x + this.ui_slotGearPassive.width + (_width - (this.ui_slotGearPassive.x + this.ui_slotGearPassive.width) - this.ui_slotGearActive.width) * 0.5);
            this.ui_slotWeapon.enabled = this.ui_slotGearPassive.enabled = this.ui_slotGearActive.enabled = this._survivor.classId != SurvivorClass.UNASSIGNED;
            this.onLoadoutChanged();
            addChild(this.ui_slotWeapon);
            addChild(this.ui_slotGearPassive);
            addChild(this.ui_slotGearActive);
         }
         this.selected = super.selected;
      }
      
      private function updateStateDisplay() : void
      {
         var _loc1_:int = int(this._segmentWidth - 10);
         if(this._showMorale)
         {
            _loc1_ -= this.mc_morale.width;
            this.mc_morale.value = this._survivor.morale.getTotal();
            this.mc_morale.x = _loc1_;
            addChild(this.mc_morale);
         }
         else if(this.mc_morale.parent != null)
         {
            this.mc_morale.parent.removeChild(this.mc_morale);
         }
         if(this._survivor.rallyAssignment != null)
         {
            if(this.mc_rallyAssigned == null)
            {
               this.mc_rallyAssigned = new Sprite();
               this.mc_rallyAssigned.addChild(new Bitmap(BMP_RALLY_ASSIGNED));
            }
            _loc1_ -= this.mc_rallyAssigned.width + 4;
            this.mc_rallyAssigned.x = _loc1_;
            this.mc_rallyAssigned.y = int(this.mc_morale.y - this.mc_rallyAssigned.height * 0.5);
            this._tooltip.add(this.mc_rallyAssigned,this._lang.getString("tooltip.rally_assigned",this._survivor.rallyAssignment.getName()),new Point(0,NaN),TooltipDirection.DIRECTION_RIGHT);
            addChild(this.mc_rallyAssigned);
         }
         else if(this.mc_rallyAssigned != null && this.mc_rallyAssigned.parent != null)
         {
            this._tooltip.remove(this.mc_rallyAssigned);
            this.mc_rallyAssigned.parent.removeChild(this.mc_rallyAssigned);
            this.mc_rallyAssigned = null;
         }
         if(this._showInjuries && this._survivor.injuries.length > 0)
         {
            if(this.mc_injured == null)
            {
               this.mc_injured = new Sprite();
               this.mc_injured.addChild(new Bitmap(BMP_INJURED));
            }
            _loc1_ -= this.mc_injured.width + 4;
            this.mc_injured.x = _loc1_;
            this.mc_injured.y = int(this.mc_morale.y - this.mc_injured.height * 0.5);
            this._tooltip.add(this.mc_injured,this._survivor.injuries.getTooltip,new Point(0,NaN),TooltipDirection.DIRECTION_RIGHT);
            addChild(this.mc_injured);
            addChild(this.ui_health);
         }
         else
         {
            if(this.ui_health.parent != null)
            {
               this.ui_health.parent.removeChild(this.ui_health);
            }
            if(this.mc_injured != null && this.mc_injured.parent != null)
            {
               this._tooltip.remove(this.mc_injured);
               this.mc_injured.parent.removeChild(this.mc_injured);
               this.mc_injured = null;
            }
         }
      }
      
      private function updateLoadoutSlotTooltip(param1:UILoadoutSlot) : void
      {
         if(param1.loadoutData == null)
         {
            this.ui_itemInfo.removeRolloverTarget(param1);
            this._tooltip.remove(param1);
            return;
         }
         if(param1.loadoutData.item != null)
         {
            this.ui_itemInfo.addRolloverTarget(param1);
            this._tooltip.remove(param1);
         }
         else
         {
            this.ui_itemInfo.removeRolloverTarget(param1);
            this._tooltip.add(param1,this._lang.getString("tooltip.equip_" + param1.loadoutData.type),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         }
      }
      
      private function updateMissionReturnTime() : void
      {
         var _loc1_:MissionData = Network.getInstance().playerData.missionList.getMissionById(this._survivor.missionId);
         if(_loc1_ == null || _loc1_.returnTimer == null)
         {
            return;
         }
         var _loc2_:String = DateTimeUtils.timeDataToString(_loc1_.returnTimer.getTimeRemaining(),true,true);
         this.txt_state.text = this._lang.getString("survivor_state.away").toUpperCase() + " " + _loc2_;
         this.txt_state.x = this._showLoadout ? int(this._segmentWidth - this.txt_state.width - 14) : int(_width - this.txt_state.width - 8);
      }
      
      private function updateReassignTime() : void
      {
         if(this._survivor.reassignTimer == null)
         {
            return;
         }
         var _loc1_:String = DateTimeUtils.timeDataToString(this._survivor.reassignTimer.getTimeRemaining(),true,true);
         this.txt_state.text = this._lang.getString("survivor_state.reassign").toUpperCase() + " " + _loc1_;
         this.txt_state.x = this._showLoadout ? int(this._segmentWidth - this.txt_state.width - 14) : int(_width - this.txt_state.width - 8);
      }
      
      private function updateTaskTime() : void
      {
         if(this._survivor.task == null)
         {
            return;
         }
         this._survivor.task.updateTimer();
         var _loc1_:String = DateTimeUtils.secondsToString(int((this._survivor.task.length - this._survivor.task.time) / this._survivor.task.survivors.length),true,true);
         this.txt_state.text = this._lang.getString("survivor_tasks." + this._survivor.task.type).toUpperCase() + " " + _loc1_;
         this.txt_state.x = this._showLoadout ? int(this._segmentWidth - this.txt_state.width - 8) : int(_width - this.txt_state.width - 8);
      }
      
      private function onMouseOverSlot(param1:MouseEvent) : void
      {
         var _loc2_:UILoadoutSlot = UILoadoutSlot(param1.currentTarget);
         if(_loc2_.loadoutData == null)
         {
            return;
         }
         this.ui_itemInfo.setItem(_loc2_.loadoutData.item,_loc2_.loadoutData.loadout,{"showEquippedQuantity":true});
      }
      
      private function onClassChanged(param1:Survivor) : void
      {
         this.update();
      }
      
      private function onNameChanged(param1:Survivor) : void
      {
         this.txt_name.text = this._survivor.fullName.toUpperCase();
      }
      
      private function onInjuriesChanged(param1:Survivor) : void
      {
         this.updateStateDisplay();
      }
      
      private function onLoadoutChanged() : void
      {
         var _loc1_:SurvivorLoadout = this._loadoutType == SurvivorLoadout.TYPE_OFFENCE ? this._survivor.loadoutOffence : this._survivor.loadoutDefence;
         this.ui_slotWeapon.loadoutData = _loc1_.weapon;
         this.ui_slotGearPassive.loadoutData = _loc1_.gearPassive;
         this.ui_slotGearActive.loadoutData = _loc1_.gearActive;
         this.updateLoadoutSlotTooltip(this.ui_slotWeapon);
         this.updateLoadoutSlotTooltip(this.ui_slotGearPassive);
         this.updateLoadoutSlotTooltip(this.ui_slotGearActive);
      }
      
      private function onSlotClicked(param1:MouseEvent) : void
      {
         var _loc2_:UILoadoutSlot = param1.currentTarget as UILoadoutSlot;
         if(_loc2_.locked || _loc2_.loadoutData == null)
         {
            return;
         }
         Network.getInstance().playerData.loadoutManager.openEquipDialogue(_loc2_.loadoutData);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(!selected)
         {
            if(this._survivor.injuries.length > 0)
            {
               addChild(this.ui_health);
            }
            TweenMax.to(this.mc_background,0,{"tint":(Boolean(this._survivor.state & SurvivorState.ON_MISSION) || Boolean(this._survivor.state & SurvivorState.REASSIGNING) || Boolean(this._survivor.state & SurvivorState.ON_ASSIGNMENT) ? COLOR_AWAY_OVER : COLOR_OVER)});
         }
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(!selected)
         {
            if(this.ui_health.parent != null)
            {
               this.ui_health.parent.removeChild(this.ui_health);
            }
            TweenMax.to(this.mc_background,0,{"tint":this.getBackgroundColor()});
         }
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(selected)
         {
            return;
         }
         Audio.sound.play("sound/interface/int-click.mp3");
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         if(this._survivor.state & SurvivorState.ON_MISSION)
         {
            this.updateMissionReturnTime();
            return;
         }
         if(this._survivor.state & SurvivorState.REASSIGNING)
         {
            this.updateReassignTime();
            return;
         }
         if(this._survivor.state & SurvivorState.ON_TASK)
         {
            this.updateTaskTime();
            return;
         }
      }
      
      private function onTaskCompleted(param1:Task) : void
      {
         this.update();
      }
      
      private function onTimerCompleted(param1:TimerData) : void
      {
         var _loc2_:Survivor = null;
         if(param1 == null)
         {
            return;
         }
         var _loc3_:MissionData = param1.target as MissionData;
         if(_loc3_ != null)
         {
            if(param1.data.type == "return" && _loc3_.returnTimer == param1)
            {
               for each(_loc2_ in _loc3_.survivors)
               {
                  if(_loc2_ == this._survivor)
                  {
                     this.update();
                     break;
                  }
               }
            }
            return;
         }
         _loc2_ = param1.target as Survivor;
         if(_loc2_ != null)
         {
            if(_loc2_ == this._survivor)
            {
               this.update();
            }
            return;
         }
      }
      
      public function get alternating() : Boolean
      {
         return this._alternating;
      }
      
      public function set alternating(param1:Boolean) : void
      {
         var _loc2_:ColorTransform = null;
         this._alternating = param1;
         if(!selected)
         {
            _loc2_ = this.mc_background.transform.colorTransform;
            _loc2_.color = this.getBackgroundColor();
            this.mc_background.transform.colorTransform = _loc2_;
         }
      }
      
      override public function set selected(param1:Boolean) : void
      {
         super.selected = param1;
         var _loc2_:ColorTransform = this.mc_background.transform.colorTransform;
         _loc2_.color = super.selected ? (Boolean(this._survivor.state & SurvivorState.ON_MISSION) || Boolean(this._survivor.state & SurvivorState.REASSIGNING) || Boolean(this._survivor.state & SurvivorState.ON_ASSIGNMENT) ? uint(COLOR_AWAY_OVER) : uint(COLOR_SELECTED)) : this.getBackgroundColor();
         this.mc_background.transform.colorTransform = _loc2_;
         if(super.selected)
         {
            if(this._survivor.injuries.length > 0)
            {
               addChild(this.ui_health);
            }
         }
         else if(this.ui_health.parent != null)
         {
            this.ui_health.parent.removeChild(this.ui_health);
         }
      }
      
      public function get showMorale() : Boolean
      {
         return this._showMorale;
      }
      
      public function set showMorale(param1:Boolean) : void
      {
         this._showMorale = param1;
         if(stage != null)
         {
            this.update();
         }
      }
      
      public function get showInjuries() : Boolean
      {
         return this._showInjuries;
      }
      
      public function set showInjuries(param1:Boolean) : void
      {
         this._showInjuries = param1;
         if(stage != null)
         {
            this.update();
         }
      }
      
      public function get showLoadout() : Boolean
      {
         return this._showLoadout;
      }
      
      public function set showLoadout(param1:Boolean) : void
      {
         this._showLoadout = param1;
         if(stage != null)
         {
            this.update();
         }
      }
      
      public function get loadoutType() : String
      {
         return this._loadoutType;
      }
      
      public function set loadoutType(param1:String) : void
      {
         var _loc2_:SurvivorLoadout = null;
         if(this._survivor != null)
         {
            this._survivor.loadoutOffence.changed.remove(this.onLoadoutChanged);
            this._survivor.loadoutDefence.changed.remove(this.onLoadoutChanged);
         }
         this._loadoutType = param1;
         if(this._survivor != null)
         {
            _loc2_ = this._loadoutType == SurvivorLoadout.TYPE_OFFENCE ? this._survivor.loadoutOffence : this._survivor.loadoutDefence;
            _loc2_.changed.add(this.onLoadoutChanged);
            this.onLoadoutChanged();
         }
      }
      
      public function get survivor() : Survivor
      {
         return this._survivor;
      }
      
      public function set survivor(param1:Survivor) : void
      {
         var _loc2_:SurvivorLoadout = null;
         if(this._survivor != null)
         {
            removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
            removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
            if(this._survivor.task != null)
            {
               this._survivor.task.completed.remove(this.onTaskCompleted);
            }
            this._survivor.loadoutOffence.changed.remove(this.onLoadoutChanged);
            this._survivor.loadoutDefence.changed.remove(this.onLoadoutChanged);
            this._survivor.classChanged.remove(this.onClassChanged);
            this._survivor.nameChanged.remove(this.onNameChanged);
            this._survivor.injuries.changed.remove(this.onInjuriesChanged);
            this._survivor = null;
            this.ui_slotWeapon.loadoutData = null;
            this.ui_slotGearPassive.loadoutData = null;
            this.ui_slotGearActive.loadoutData = null;
         }
         this._survivor = param1;
         this._survivor.classChanged.add(this.onClassChanged);
         this._survivor.nameChanged.add(this.onNameChanged);
         this._survivor.injuries.changed.add(this.onInjuriesChanged);
         if(this._showLoadout)
         {
            _loc2_ = this._loadoutType == SurvivorLoadout.TYPE_OFFENCE ? this._survivor.loadoutOffence : this._survivor.loadoutDefence;
            _loc2_.changed.add(this.onLoadoutChanged);
            this.onLoadoutChanged();
         }
         this.update();
         if(this._survivor != null)
         {
            addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
            addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
            addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         }
      }
      
      override public function set width(param1:Number) : void
      {
         _width = param1;
         this._segmentWidth = this._showLoadout ? _width - 158 : _width;
         this.update();
      }
   }
}

