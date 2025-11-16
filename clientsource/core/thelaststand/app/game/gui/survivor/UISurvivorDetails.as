package thelaststand.app.game.gui.survivor
{
   import com.deadreckoned.threshold.display.Color;
   import com.exileetiquette.utils.StringUtils;
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.utils.getDefinitionByName;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Config;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.game.data.AttireData;
   import thelaststand.app.game.data.AttireFlags;
   import thelaststand.app.game.data.Attributes;
   import thelaststand.app.game.data.ClothingAccessory;
   import thelaststand.app.game.data.Gear;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorClass;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.SurvivorLoadoutData;
   import thelaststand.app.game.data.SurvivorState;
   import thelaststand.app.game.data.Task;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.compound.UIMoraleDisplay;
   import thelaststand.app.game.gui.dialogues.LeaderRetrainDialogue;
   import thelaststand.app.game.gui.dialogues.SpeedUpDialogue;
   import thelaststand.app.game.gui.dialogues.SurvivorClassAssignmentDialogue;
   import thelaststand.app.game.gui.lists.UIInventoryListItem;
   import thelaststand.app.game.gui.tooltip.UIMoraleTooltip;
   import thelaststand.app.game.gui.tooltip.UISurvivorClassTooltip;
   import thelaststand.app.game.logic.DialogueController;
   import thelaststand.app.game.logic.TimerManager;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIInputField;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.buttons.UIIconButton;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.lang.Language;
   
   public class UISurvivorDetails extends Sprite
   {
      
      private static const DEFAULT_ATTRIBUTES:Attributes = new Attributes();
      
      private static const BMP_LOADOUT_WEAPON:BitmapData = new BmpIconLoadoutWeapon();
      
      private static const BMP_LOADOUT_GEAR:BitmapData = new BmpIconLoadoutGear();
      
      private static const BMP_LOADOUT_ACCESSORY:BitmapData = new BmpIconLoadoutAccessory();
      
      private static const BMP_LOADOUT_CLOTHING_UPPER:BitmapData = new BmpIconLoadoutClothingUpper();
      
      private static const BMP_LOADOUT_CLOTHING_LOWER:BitmapData = new BmpIconLoadoutClothingLower();
      
      private static const BMP_INJURED:BitmapData = new BmpIconInjuries();
      
      public static const MODE_VIEW:uint = 0;
      
      public static const MODE_EDIT:uint = 1;
      
      public static const MODE_LEVEL:uint = 2;
      
      private var _lang:Language;
      
      private var _survivor:Survivor;
      
      private var _mode:uint = 0;
      
      private var _width:int = 270;
      
      private var _height:int = 414;
      
      private var _levelPoints:int;
      
      private var _tooltip:TooltipManager;
      
      private var _timeManager:TimerManager;
      
      private var _loadoutEnabled:Boolean = true;
      
      private var _loadoutType:String = "offence";
      
      private var _showEditName:Boolean = true;
      
      private var _showingDetails:Boolean = false;
      
      private var _invalid:Boolean = true;
      
      private var _appearanceChanged:Boolean = false;
      
      private var _genderChanged:Boolean = false;
      
      private var _voiceChanged:Boolean = false;
      
      private var _originalGender:String;
      
      private var _clothingSlots:Vector.<UIInventoryListItem>;
      
      private var btn_assign:PushButton;
      
      private var btn_heal:PushButton;
      
      private var btn_speedUp:PurchasePushButton;
      
      private var btn_editName:UIIconButton;
      
      private var btn_details:PushButton;
      
      private var btn_skillReset:PushButton;
      
      private var mc_skills:IUISkillsTable;
      
      private var bmp_classIcon:Bitmap;
      
      private var mc_background:Shape;
      
      private var mc_nameBar:UITitleBar;
      
      private var mc_morale:UIMoraleDisplay;
      
      private var mc_injured:Sprite;
      
      private var mc_stateBG:Shape;
      
      private var txt_assign:BodyTextField;
      
      private var txt_className:TitleTextField;
      
      private var txt_level:TitleTextField;
      
      private var txt_state:BodyTextField;
      
      private var txt_levelPoints:BodyTextField;
      
      private var ui_slotWeapon:UIInventoryListItem;
      
      private var ui_slotGearPassive:UIInventoryListItem;
      
      private var ui_slotGearActive:UIInventoryListItem;
      
      private var ui_slotAccessory1:UIInventoryListItem;
      
      private var ui_slotAccessory2:UIInventoryListItem;
      
      private var ui_slotClothingUpper:UIInventoryListItem;
      
      private var ui_slotClothingLower:UIInventoryListItem;
      
      private var ui_itemInfo:UIItemInfo;
      
      private var ui_editName:UIInputField;
      
      private var ui_details:UISurvivorSkillDetails;
      
      private var ui_editAppearance:UISurvivorEditAppearance;
      
      private var morale_tooltip:UIMoraleTooltip;
      
      private var mc_modelView:UISurvivorModelView;
      
      private var mc_classInfoHitArea:Sprite;
      
      private var ui_classTooltip:UISurvivorClassTooltip = new UISurvivorClassTooltip();
      
      public var modeChanged:Signal;
      
      public function UISurvivorDetails()
      {
         super();
         this.modeChanged = new Signal();
         this._lang = Language.getInstance();
         this._tooltip = TooltipManager.getInstance();
         this._timeManager = TimerManager.getInstance();
         this._timeManager.timerCompleted.add(this.onTimerCompleted);
         this.ui_itemInfo = new UIItemInfo();
         this.ui_itemInfo.displayClothingPreview = false;
         this.mc_background = new Shape();
         this.mc_background.graphics.beginFill(7566195);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         this.mc_background.graphics.beginFill(2434341);
         this.mc_background.graphics.drawRect(1,1,this._width - 2,this._height - 2);
         this.mc_background.graphics.endFill();
         addChild(this.mc_background);
         this.mc_nameBar = new UITitleBar({
            "color":16777215,
            "size":22
         });
         this.mc_nameBar.width = int(this._width - 8);
         this.mc_nameBar.height = 28;
         this.mc_nameBar.x = this.mc_nameBar.y = 4;
         this.mc_nameBar.addEventListener(MouseEvent.CLICK,this.onClickEditName,false,0,true);
         addChild(this.mc_nameBar);
         this.btn_editName = new UIIconButton(new BmpIconEditSurvivorName());
         this.btn_editName.x = int(this.mc_nameBar.x + this.mc_nameBar.width - this.btn_editName.width - 6);
         this.btn_editName.y = int(this.mc_nameBar.y + (this.mc_nameBar.height - this.btn_editName.height) * 0.5);
         this.btn_editName.addEventListener(MouseEvent.CLICK,this.onClickEditName,false,0,true);
         addChild(this.btn_editName);
         this.ui_editName = new UIInputField();
         this.ui_editName.x = this.mc_nameBar.x + 2;
         this.ui_editName.y = this.mc_nameBar.y + 2;
         this.ui_editName.width = int(this.btn_editName.x - this.ui_editName.x - 6);
         this.ui_editName.height = int(this.mc_nameBar.height - 4);
         this.ui_editName.textField.restrict = Config.constant.RESTRICT_NAME_CHARS;
         this.ui_editName.textField.maxChars = int(Config.constant.RESTRICT_NAME_MAX_LENGTH);
         this.ui_editName.textField.addEventListener(FocusEvent.FOCUS_OUT,this.onNameFocusOut,false,0,true);
         this.mc_modelView = new UISurvivorModelView(this._width,260);
         this.mc_modelView.x = int((this._width - this.mc_modelView.width) * 0.5);
         this.mc_modelView.y = int(this.mc_nameBar.y + this.mc_nameBar.height + 10);
         this.mc_modelView.cameraPosition.y = 5;
         this.mc_modelView.showWeapon = this._loadoutType;
         this.mc_modelView.showInjured = true;
         addChildAt(this.mc_modelView,getChildIndex(this.mc_background) + 1);
         this.bmp_classIcon = new Bitmap();
         this.bmp_classIcon.x = this.mc_nameBar.x;
         this.bmp_classIcon.y = int(this.mc_nameBar.y + this.mc_nameBar.height + 3);
         this.txt_className = new TitleTextField({
            "color":12237498,
            "size":17,
            "bold":true,
            "antiAliasType":"advanced"
         });
         this.txt_className.x = 22;
         this.txt_className.y = int(this.mc_nameBar.y + this.mc_nameBar.height + 3);
         this.txt_className.text = " ";
         this.txt_className.filters = [Effects.TEXT_SHADOW_DARK];
         this.txt_level = new TitleTextField({
            "color":16434707,
            "size":17,
            "bold":true,
            "antiAliasType":"advanced"
         });
         this.txt_level.text = " ";
         this.txt_level.x = this.mc_nameBar.x + this.mc_nameBar.width - this.txt_level.width;
         this.txt_level.y = this.txt_className.y;
         this.txt_level.filters = [Effects.TEXT_SHADOW_DARK];
         addChild(this.txt_level);
         var _loc1_:Matrix = new Matrix();
         _loc1_.createGradientBox(this._width,22);
         this.mc_stateBG = new Shape();
         this.mc_stateBG.graphics.beginGradientFill("linear",[16777215,16777215,16777215,16777215],[0,0.5,0.5,0],[10,80,175,245],_loc1_);
         this.mc_stateBG.graphics.drawRect(0,0,this._width,22);
         this.mc_stateBG.graphics.endFill();
         this.txt_state = new BodyTextField({
            "color":Effects.COLOR_WARNING,
            "size":13,
            "bold":true,
            "antiAliasType":"advanced"
         });
         this.txt_state.text = " ";
         this.txt_state.filters = [Effects.TEXT_SHADOW_DARK];
         this.txt_levelPoints = new BodyTextField({
            "color":Effects.COLOR_GOOD,
            "size":14,
            "bold":true,
            "antiAliasType":"advanced"
         });
         this.txt_levelPoints.text = " ";
         this.txt_levelPoints.filters = [Effects.TEXT_SHADOW_DARK];
         this.txt_assign = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "size":13,
            "bold":true,
            "multiline":true,
            "align":"center",
            "antiAliaType":"advanced"
         });
         this.txt_assign.text = " ";
         this.txt_assign.x = 20;
         this.txt_assign.width = int(this._width - this.txt_assign.x * 2);
         this.btn_assign = new PushButton(this._lang.getString("srv_assign_btn"),null,-1,null,3958902);
         this.btn_assign.clicked.add(this.onAssignClicked);
         this.btn_assign.x = int((this._width - this.btn_assign.width) * 0.5);
         this.btn_heal = new PushButton(this._lang.getString("srv_heal_btn"),null,-1,null,10108462);
         this.btn_heal.clicked.add(this.onHealClicked);
         this.btn_heal.width = 120;
         this.btn_heal.x = int((this._width - this.btn_heal.width) * 0.5);
         this.btn_speedUp = new PurchasePushButton();
         this.btn_speedUp.showIcon = false;
         this.btn_speedUp.clicked.add(this.onSpeedUpClicked);
         this.btn_speedUp.width = 120;
         this.btn_speedUp.x = int((this._width - this.btn_speedUp.width) * 0.5);
         this.mc_morale = new UIMoraleDisplay();
         this.mc_morale.showValue = false;
         this.mc_morale.x = int(this.txt_level.x - this.mc_morale.width - 4);
         this.mc_morale.y = int(this.txt_level.y + this.txt_level.height * 0.5);
         addChild(this.mc_morale);
         this.mc_injured = new Sprite();
         this.mc_injured.addChild(new Bitmap(BMP_INJURED));
         this.ui_slotWeapon = new UIInventoryListItem(48);
         this.ui_slotWeapon.clicked.add(this.onLoadoutSlotClicked);
         this.ui_slotWeapon.mouseOver.add(this.onSlotMouseOver);
         this.ui_slotWeapon.showEquippedIcon = false;
         this.ui_slotWeapon.showNewIcon = false;
         this.ui_slotWeapon.x = 10;
         this.ui_slotWeapon.y = this._height - this.ui_slotWeapon.height - 10;
         addChild(this.ui_slotWeapon);
         this.ui_slotGearActive = new UIInventoryListItem(48);
         this.ui_slotGearActive.clicked.add(this.onLoadoutSlotClicked);
         this.ui_slotGearActive.mouseOver.add(this.onSlotMouseOver);
         this.ui_slotGearActive.showEquippedIcon = false;
         this.ui_slotGearActive.showNewIcon = false;
         this.ui_slotGearActive.x = this._width - this.ui_slotGearActive.width - 10;
         this.ui_slotGearActive.y = this._height - this.ui_slotWeapon.height - 10;
         addChild(this.ui_slotGearActive);
         this.ui_slotGearPassive = new UIInventoryListItem(48);
         this.ui_slotGearPassive.clicked.add(this.onLoadoutSlotClicked);
         this.ui_slotGearPassive.mouseOver.add(this.onSlotMouseOver);
         this.ui_slotGearPassive.showEquippedIcon = false;
         this.ui_slotGearPassive.showNewIcon = false;
         this.ui_slotGearPassive.x = this.ui_slotGearActive.x - this.ui_slotGearPassive.width - 6;
         this.ui_slotGearPassive.y = this._height - this.ui_slotGearPassive.height - 10;
         addChild(this.ui_slotGearPassive);
         this.ui_slotAccessory1 = new UIInventoryListItem(32);
         this.ui_slotAccessory1.clicked.add(this.OnAccessorySlotClicked);
         this.ui_slotAccessory1.mouseOver.add(this.onSlotMouseOver);
         this.ui_slotAccessory1.showEquippedIcon = false;
         this.ui_slotAccessory1.showNewIcon = false;
         this.ui_slotAccessory1.x = int(this._width - this.ui_slotAccessory1.width - 10);
         this.ui_slotAccessory1.y = int(this.txt_level.y + this.txt_level.height + 18);
         addChild(this.ui_slotAccessory1);
         this.ui_slotAccessory2 = new UIInventoryListItem(32);
         this.ui_slotAccessory2.clicked.add(this.OnAccessorySlotClicked);
         this.ui_slotAccessory2.mouseOver.add(this.onSlotMouseOver);
         this.ui_slotAccessory2.showEquippedIcon = false;
         this.ui_slotAccessory2.showNewIcon = false;
         this.ui_slotAccessory2.x = int(this.ui_slotAccessory1.x);
         this.ui_slotAccessory2.y = int(this.ui_slotAccessory1.y + this.ui_slotAccessory1.height + 4);
         addChild(this.ui_slotAccessory2);
         this.ui_slotClothingUpper = new UIInventoryListItem(32);
         this.ui_slotClothingUpper.clicked.add(this.OnAccessorySlotClicked);
         this.ui_slotClothingUpper.mouseOver.add(this.onSlotMouseOver);
         this.ui_slotClothingUpper.showEquippedIcon = false;
         this.ui_slotClothingUpper.showNewIcon = false;
         this.ui_slotClothingUpper.x = 10;
         this.ui_slotClothingUpper.y = int(this.ui_slotAccessory1.y);
         addChild(this.ui_slotClothingUpper);
         this.ui_slotClothingLower = new UIInventoryListItem(32);
         this.ui_slotClothingLower.clicked.add(this.OnAccessorySlotClicked);
         this.ui_slotClothingLower.mouseOver.add(this.onSlotMouseOver);
         this.ui_slotClothingLower.showEquippedIcon = false;
         this.ui_slotClothingLower.showNewIcon = false;
         this.ui_slotClothingLower.x = int(this.ui_slotClothingUpper.x);
         this.ui_slotClothingLower.y = int(this.ui_slotClothingUpper.y + this.ui_slotClothingUpper.height + 4);
         addChild(this.ui_slotClothingLower);
         this._clothingSlots = new <UIInventoryListItem>[this.ui_slotAccessory1,this.ui_slotAccessory2,this.ui_slotClothingUpper,this.ui_slotClothingLower];
         this.ui_details = new UISurvivorSkillDetails(this._width - 12,250);
         this.ui_details.x = 6;
         this.btn_details = new PushButton("+");
         this.btn_details.width = this.btn_details.height = 14;
         this.btn_details.showBorder = false;
         this.btn_details.clicked.add(this.onDetailsClicked);
         this.btn_skillReset = new PushButton(this._lang.getString("survivor_edit_respec"),null,-1,{"size":11});
         this.btn_skillReset.height = this.btn_details.height;
         this.btn_skillReset.width = 54;
         this.btn_skillReset.showBorder = false;
         this.btn_skillReset.clicked.add(this.onSkillResetClicked);
         this.mc_classInfoHitArea = new Sprite();
         this.mc_classInfoHitArea.graphics.beginFill(0,0);
         this.mc_classInfoHitArea.graphics.drawRect(0,0,10,10);
         this.mc_classInfoHitArea.graphics.endFill();
         addChild(this.mc_classInfoHitArea);
         this.morale_tooltip = new UIMoraleTooltip();
         this._tooltip.add(this.mc_morale,this.morale_tooltip,new Point(0,NaN),TooltipDirection.DIRECTION_RIGHT);
         this._tooltip.add(this.btn_editName,this._lang.getString("survivor_rename"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this._tooltip.add(this.btn_details,this.getDetailsTooltip,new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this._tooltip.add(this.btn_skillReset,this.getRespecTip,new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this._tooltip.add(this.mc_classInfoHitArea,this.getClassTooltip,new Point(NaN,NaN),TooltipDirection.DIRECTION_LEFT,0.1);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         if(this._survivor != null)
         {
            if(this._survivor.task != null)
            {
               this._survivor.task.completed.remove(this.onTaskCompleted);
            }
            this._survivor.accessoriesChanged.remove(this.onClothingAccessoryChanged);
            this._survivor.classChanged.remove(this.onClassChanged);
            this._survivor.nameChanged.remove(this.onNameChanged);
            this._survivor.loadoutOffence.changed.remove(this.onLoadoutChanged);
            this._survivor.loadoutDefence.changed.remove(this.onLoadoutChanged);
            this._survivor.injuries.changed.remove(this.onInjuriesChanged);
            this._survivor = null;
         }
         this.modeChanged.removeAll();
         this._timeManager.timerCompleted.remove(this.onTimerCompleted);
         this._timeManager = null;
         this._tooltip.removeAllFromParent(this);
         this._tooltip = null;
         this._lang = null;
         this.mc_modelView.dispose();
         this.mc_modelView = null;
         this.mc_morale.dispose();
         this.mc_morale = null;
         this.mc_nameBar.dispose();
         this.mc_nameBar = null;
         if(this.mc_skills != null)
         {
            this.mc_skills.dispose();
            this.mc_skills = null;
         }
         if(this.btn_editName != null)
         {
            this.btn_editName.dispose();
            this.btn_editName = null;
         }
         this.ui_itemInfo.dispose();
         this.ui_itemInfo = null;
         this.ui_classTooltip.dispose();
         this.ui_slotGearPassive.dispose();
         this.ui_slotGearPassive = null;
         this.ui_slotGearActive.dispose();
         this.ui_slotGearActive = null;
         this.ui_slotWeapon.dispose();
         this.ui_slotWeapon = null;
         this.ui_slotAccessory1.dispose();
         this.ui_slotAccessory2.dispose();
         this.ui_slotClothingLower.dispose();
         this.ui_slotClothingUpper.dispose();
         if(this.ui_editAppearance != null)
         {
            this.ui_editAppearance.dispose();
         }
         this.btn_heal.dispose();
         this.btn_heal = null;
         this.btn_speedUp.dispose();
         this.btn_speedUp = null;
         this.btn_assign.dispose();
         this.btn_assign = null;
         this.txt_assign.dispose();
         this.txt_assign = null;
         this.txt_className.dispose();
         this.txt_className = null;
         this.txt_level.dispose();
         this.txt_level = null;
         this.txt_levelPoints.dispose();
         this.txt_levelPoints = null;
         this.txt_state.dispose();
         this.txt_state = null;
         this.ui_editName.dispose();
         this.ui_editName = null;
      }
      
      public function setSurvivor(param1:Survivor, param2:uint, param3:Boolean = true) : void
      {
         var _loc4_:SurvivorLoadout = null;
         if(param3)
         {
            this.saveAppearance();
         }
         if(param1 != this._survivor)
         {
            if(this._survivor != null)
            {
               if(this._survivor.task != null)
               {
                  this._survivor.task.completed.remove(this.onTaskCompleted);
               }
               this._survivor.accessoriesChanged.remove(this.onClothingAccessoryChanged);
               this._survivor.classChanged.remove(this.onClassChanged);
               this._survivor.nameChanged.remove(this.onNameChanged);
               this._survivor.loadoutOffence.changed.remove(this.onLoadoutChanged);
               this._survivor.loadoutDefence.changed.remove(this.onLoadoutChanged);
               this._survivor.injuries.changed.remove(this.onInjuriesChanged);
               this._survivor = null;
            }
            this._survivor = param1;
            this._originalGender = this._survivor.gender;
            this._survivor.accessoriesChanged.add(this.onClothingAccessoryChanged);
            this._survivor.classChanged.add(this.onClassChanged);
            this._survivor.nameChanged.add(this.onNameChanged);
            this._survivor.setActiveLoadout(this._loadoutType);
            this._survivor.activeLoadout.changed.add(this.onLoadoutChanged);
            this._survivor.injuries.changed.add(this.onInjuriesChanged);
            this.mc_modelView.survivor = this._survivor;
         }
         if(param2 != this._mode)
         {
            this._mode = param2;
            this.modeChanged.dispatch();
         }
         this.updateDisplay();
      }
      
      public function setMode(param1:uint) : void
      {
         if(param1 == this._mode)
         {
            return;
         }
         if(this._mode == UISurvivorDetails.MODE_EDIT)
         {
            this.saveAppearance();
         }
         this._mode = param1;
         if(this._mode == UISurvivorDetails.MODE_EDIT)
         {
            this.showMoreDetails(false);
         }
         this.updateDisplay();
         this.modeChanged.dispatch();
      }
      
      public function getPlayerAttributeTable() : UIPlayerSkillsTable
      {
         return this.mc_skills as UIPlayerSkillsTable;
      }
      
      public function showMoreDetails(param1:Boolean) : void
      {
         this._showingDetails = param1;
         this.mc_modelView.visible = !this._showingDetails;
         if(this.mc_skills == null)
         {
            this._showingDetails = false;
            if(this.btn_details.parent != null)
            {
               this.btn_details.parent.removeChild(this.btn_details);
            }
            if(this.btn_skillReset.parent != null)
            {
               this.btn_skillReset.parent.removeChild(this.btn_skillReset);
            }
            if(this.ui_details.parent != null)
            {
               this.ui_details.parent.removeChild(this.ui_details);
            }
            return;
         }
         Sprite(this.mc_skills).visible = this.btn_heal.visible = this.btn_assign.visible = this.btn_speedUp.visible = this.btn_skillReset.visible = this.txt_state.visible = this.mc_stateBG.visible = this.ui_slotAccessory1.visible = this.ui_slotAccessory2.visible = this.ui_slotClothingUpper.visible = this.ui_slotClothingLower.visible = !this._showingDetails;
         if(this._showingDetails)
         {
            this.ui_details.x = int(Sprite(this.mc_skills).x);
            this.ui_details.y = int(this.ui_slotWeapon.y - this.ui_details.height - 2);
            this.btn_details.label = "-";
            this.btn_details.y = int(this.ui_details.y - this.btn_details.height - 6);
            addChild(this.ui_details);
         }
         else
         {
            this.btn_details.label = "+";
            this.btn_details.y = int(Sprite(this.mc_skills).y - this.btn_details.height - 6);
            if(this.ui_details.parent != null)
            {
               this.ui_details.parent.removeChild(this.ui_details);
            }
         }
         this.btn_skillReset.y = int(this.btn_details.y);
      }
      
      public function saveAppearance() : void
      {
         var _loc1_:uint = 0;
         if(this._survivor == null)
         {
            return;
         }
         if(this._appearanceChanged)
         {
            _loc1_ |= Survivor.SAVE_OPTION_APPEARANCE;
         }
         if(this._genderChanged)
         {
            _loc1_ |= Survivor.SAVE_OPTION_GENDER;
         }
         if(this._voiceChanged)
         {
            _loc1_ |= Survivor.SAVE_OPTION_VOICE;
         }
         if(_loc1_ != 0)
         {
            this._survivor.saveAppearance(_loc1_);
            this._survivor.updatePortrait();
         }
         this._appearanceChanged = false;
         this._voiceChanged = false;
         this._genderChanged = false;
      }
      
      private function getClassTooltip() : Sprite
      {
         if(this._survivor.classId == SurvivorClass.UNASSIGNED)
         {
            return null;
         }
         this.ui_classTooltip.survivorClassId = this._survivor.classId;
         return this.ui_classTooltip;
      }
      
      private function getDetailsTooltip() : String
      {
         return this._lang.getString(this._showingDetails ? "srv_assign_lessdetails" : "srv_assign_moredetails");
      }
      
      private function canRespecLeader() : Boolean
      {
         var _loc1_:Object = Network.getInstance().data.costTable.getItemByKey("AttributeReset");
         return Network.getInstance().playerData.getPlayerSurvivor().level >= int(_loc1_.minLevel) && Network.getInstance().playerData.compound.buildings.getNumBuildingsOfType("trainingCenter",false) >= 1;
      }
      
      private function getRespecTip() : String
      {
         var _loc1_:Object = Network.getInstance().data.costTable.getItemByKey("AttributeReset");
         return this.canRespecLeader() ? this._lang.getString("survivor_edit_respec_tip") : this._lang.getString("survivor_edit_respec_tip_req",int(_loc1_.minLevel) + 1);
      }
      
      private function invalidate() : void
      {
         this._invalid = true;
         if(stage)
         {
            stage.invalidate();
         }
      }
      
      private function updateDisplay() : void
      {
         var _loc4_:Sprite = null;
         var _loc5_:String = null;
         var _loc6_:Class = null;
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         if(this.mc_skills != null)
         {
            this.mc_skills.dispose();
         }
         this.mc_skills = null;
         if(this.ui_editAppearance != null)
         {
            this.ui_editAppearance.dispose();
            this.ui_editAppearance = null;
         }
         if(this.mc_injured.parent != null)
         {
            this.mc_injured.parent.removeChild(this.mc_injured);
         }
         if(this.btn_heal.parent != null)
         {
            this.btn_heal.parent.removeChild(this.btn_heal);
         }
         if(this.bmp_classIcon.parent != null)
         {
            this.bmp_classIcon.parent.removeChild(this.bmp_classIcon);
         }
         if(this.txt_className.parent != null)
         {
            this.txt_className.parent.removeChild(this.txt_className);
         }
         if(this.txt_levelPoints.parent != null)
         {
            this.txt_levelPoints.parent.removeChild(this.txt_levelPoints);
         }
         if(this.txt_level.parent != null)
         {
            this.txt_level.parent.removeChild(this.txt_level);
         }
         if(this.txt_assign.parent != null)
         {
            this.txt_assign.parent.removeChild(this.txt_assign);
         }
         if(this.btn_assign.parent != null)
         {
            this.btn_assign.parent.removeChild(this.btn_assign);
         }
         if(this.btn_details.parent != null)
         {
            this.btn_details.parent.removeChild(this.btn_details);
         }
         if(this.btn_skillReset.parent != null)
         {
            this.btn_skillReset.parent.removeChild(this.btn_skillReset);
         }
         if(this.txt_state.parent != null)
         {
            this.txt_state.parent.removeChild(this.txt_state);
         }
         if(this.mc_stateBG.parent != null)
         {
            this.mc_stateBG.parent.removeChild(this.mc_stateBG);
         }
         if(this.btn_speedUp.parent != null)
         {
            this.btn_speedUp.parent.removeChild(this.btn_speedUp);
         }
         if(this.ui_slotWeapon.parent != null)
         {
            this.ui_slotWeapon.parent.removeChild(this.ui_slotWeapon);
         }
         if(this.ui_slotGearActive.parent != null)
         {
            this.ui_slotGearActive.parent.removeChild(this.ui_slotGearActive);
         }
         if(this.ui_slotGearPassive.parent != null)
         {
            this.ui_slotGearPassive.parent.removeChild(this.ui_slotGearPassive);
         }
         if(this.ui_slotAccessory1.parent != null)
         {
            this.ui_slotAccessory1.parent.removeChild(this.ui_slotAccessory1);
         }
         if(this.ui_slotAccessory2.parent != null)
         {
            this.ui_slotAccessory2.parent.removeChild(this.ui_slotAccessory2);
         }
         if(this.ui_slotClothingUpper.parent != null)
         {
            this.ui_slotClothingUpper.parent.removeChild(this.ui_slotClothingUpper);
         }
         if(this.ui_slotClothingLower.parent != null)
         {
            this.ui_slotClothingLower.parent.removeChild(this.ui_slotClothingLower);
         }
         if(this._survivor == null)
         {
            this._invalid = false;
            return;
         }
         var _loc1_:Number = 0;
         var _loc2_:Number = 0;
         var _loc3_:Boolean = false;
         this.mc_nameBar.title = this._survivor.fullName;
         this.txt_className.textColor = 12237498;
         this.txt_level.textColor = this._mode == MODE_LEVEL ? 5812176 : 16434707;
         this.txt_level.text = this._mode == MODE_LEVEL ? this._lang.getString("levelup_levelup") : this._lang.getString("level",this._survivor.level + 1).toUpperCase() + (this._survivor.level >= this._survivor.levelMax ? " (" + this._lang.getString("max").toUpperCase() + ")" : "");
         this.morale_tooltip.morale = this._survivor.morale;
         if(this._survivor.classId == SurvivorClass.UNASSIGNED)
         {
            this.txt_className.text = this._lang.getString("survivor_classes." + this._survivor.classId).toUpperCase();
            this.txt_className.textColor = Effects.COLOR_WARNING;
            this.txt_className.x = int(this.bmp_classIcon.x);
            addChild(this.txt_className);
            this.mc_classInfoHitArea.visible = false;
         }
         else if(this._survivor.classId == SurvivorClass.PLAYER)
         {
            _loc6_ = getDefinitionByName("BmpIconClass_" + this._survivor.classId) as Class;
            if(_loc6_ != null)
            {
               this.bmp_classIcon.bitmapData = new _loc6_();
            }
            this.bmp_classIcon.y = Math.round(this.txt_className.y + (this.txt_className.height - this.bmp_classIcon.height) * 0.5);
            this.txt_className.text = this._lang.getString("survivor_classes." + this._survivor.classId).toUpperCase();
            this.txt_className.x = int(this.bmp_classIcon.x + this.bmp_classIcon.width + 2);
            if(this._mode == MODE_LEVEL)
            {
               this.txt_levelPoints.text = this._lang.getString("levelup_points",this._levelPoints);
               this.txt_levelPoints.x = int(this.mc_nameBar.x + this.mc_nameBar.width - this.txt_levelPoints.width);
               this.txt_levelPoints.y = int(this.txt_className.y + this.txt_className.height - 4);
               addChild(this.txt_levelPoints);
            }
            else if(this.txt_levelPoints.parent != null)
            {
               this.txt_levelPoints.parent.removeChild(this.txt_levelPoints);
            }
            addChild(this.txt_className);
            addChild(this.txt_level);
            addChild(this.bmp_classIcon);
            this.mc_classInfoHitArea.visible = true;
         }
         else
         {
            _loc6_ = getDefinitionByName("BmpIconClass_" + this._survivor.classId) as Class;
            if(_loc6_ != null)
            {
               this.bmp_classIcon.bitmapData = new _loc6_();
            }
            this.bmp_classIcon.y = Math.round(this.txt_className.y + (this.txt_className.height - this.bmp_classIcon.height) * 0.5);
            this.txt_className.text = this._lang.getString("survivor_classes." + this._survivor.classId).toUpperCase();
            this.txt_className.x = int(this.bmp_classIcon.x + this.bmp_classIcon.width + 2);
            addChild(this.txt_className);
            addChild(this.txt_level);
            addChild(this.bmp_classIcon);
            this.mc_classInfoHitArea.visible = true;
         }
         this.mc_classInfoHitArea.x = this.bmp_classIcon.x;
         this.mc_classInfoHitArea.y = this.txt_className.y - 2;
         this.mc_classInfoHitArea.width = int(this.txt_className.x + this.txt_className.width - this.mc_classInfoHitArea.x);
         this.mc_classInfoHitArea.height = int(this.txt_className.height + 4);
         this.txt_level.x = int(this.mc_nameBar.x + this.mc_nameBar.width - this.txt_level.width);
         this.mc_morale.value = this._survivor.morale.getTotal();
         this.mc_morale.x = this.txt_level.parent != null ? int(this.txt_level.x - this.mc_morale.width - 4) : int(this.mc_nameBar.x + this.mc_nameBar.width - this.mc_morale.width);
         switch(this._mode)
         {
            case MODE_VIEW:
            case MODE_LEVEL:
               this.drawViewLevelMode();
               break;
            case MODE_EDIT:
               this.drawEditMode();
         }
         if(this._survivor.classId != SurvivorClass.UNASSIGNED)
         {
            addChild(this.ui_slotAccessory1);
            addChild(this.ui_slotAccessory2);
            addChild(this.ui_slotClothingUpper);
            addChild(this.ui_slotClothingLower);
            this.updateAllClothingSlots();
         }
         this._invalid = false;
      }
      
      private function drawViewLevelMode() : void
      {
         var _loc7_:Survivor = null;
         var _loc1_:* = this._survivor == Network.getInstance().playerData.getPlayerSurvivor();
         var _loc2_:Number = 0.5;
         var _loc3_:Number = 1;
         TweenMax.to(this.mc_modelView.actorMesh,_loc2_,{
            "scaleX":_loc3_,
            "scaleY":_loc3_,
            "scaleZ":_loc3_,
            "ease":Quad.easeOut
         });
         TweenMax.to(this.mc_modelView.cameraPosition,_loc2_,{
            "x":0,
            "y":5,
            "onUpdate":this.mc_modelView.updateCamera,
            "ease":Quad.easeOut
         });
         var _loc4_:SurvivorLoadout = this._loadoutType == SurvivorLoadout.TYPE_OFFENCE ? this._survivor.loadoutOffence : this._survivor.loadoutDefence;
         if(this._survivor.classId == SurvivorClass.PLAYER)
         {
            this.mc_skills = new UIPlayerSkillsTable(this._width - 12);
            this.mc_skills.setSurvivor(this._survivor,_loc4_);
            UIPlayerSkillsTable(this.mc_skills).showModifyButtons = this._mode == MODE_LEVEL;
            UIPlayerSkillsTable(this.mc_skills).attributeModified.add(this.onLevelUpAttributeModified);
         }
         else if(this._survivor.classId == SurvivorClass.UNASSIGNED)
         {
            this.txt_assign.text = this._lang.getString("srv_assign_msg",this._survivor.firstName).toUpperCase();
            this.txt_assign.y = int(this.mc_modelView.y + this.mc_modelView.height - 40);
            this.btn_assign.y = int(this.txt_assign.y + this.txt_assign.height + 10);
            addChild(this.txt_assign);
            addChild(this.btn_assign);
         }
         else
         {
            this.mc_skills = new UISurvivorSkillsTable(this._width - 12);
            this.mc_skills.setSurvivor(this._survivor,_loc4_);
         }
         if(this.mc_skills != null)
         {
            addChild(Sprite(this.mc_skills));
            Sprite(this.mc_skills).x = 6;
            Sprite(this.mc_skills).y = Math.min(this.ui_slotWeapon.y - Sprite(this.mc_skills).height - 2,int(this.mc_modelView.y + this.mc_modelView.height));
            this.btn_details.x = int(Sprite(this.mc_skills).x + Sprite(this.mc_skills).width - this.btn_details.width - 2);
            addChild(this.btn_details);
            _loc7_ = Network.getInstance().playerData.getPlayerSurvivor();
            if(this._survivor == _loc7_ && _loc7_.level > 0)
            {
               this.btn_skillReset.enabled = this.canRespecLeader();
               this.btn_skillReset.x = int(this.btn_details.x - this.btn_skillReset.width - 6);
               addChild(this.btn_skillReset);
            }
            this.ui_details.showSurvivorStats(this._survivor,_loc4_);
            this.showMoreDetails(this._showingDetails);
         }
         else
         {
            this.showMoreDetails(false);
         }
         var _loc5_:* = this._survivor.injuries.length > 0;
         if(_loc5_)
         {
            this._tooltip.add(this.mc_injured,this._survivor.injuries.getTooltip,new Point(0,NaN),TooltipDirection.DIRECTION_RIGHT);
            this.mc_injured.x = int(this.mc_morale.x - this.mc_injured.width - 2);
            this.mc_injured.y = int(this.mc_morale.y - this.mc_injured.height * 0.5);
            addChild(this.mc_injured);
         }
         var _loc6_:Boolean = false;
         if(this._survivor.state & SurvivorState.ON_ASSIGNMENT)
         {
            _loc6_ = false;
            TweenMax.to(this.mc_stateBG,0,{"colorMatrixFilter":{"colorize":new Color(Effects.COLOR_WARNING).adjustBrightness(0.5).RGB}});
            addChild(this.mc_stateBG);
            addChild(this.txt_state);
            this.mc_modelView.showInjured = false;
            this.txt_state.textColor = Effects.COLOR_WARNING;
            this.txt_state.text = this._lang.getString("survivor_state.assignment").toUpperCase();
            this.txt_state.x = int((this._width - this.txt_state.width) * 0.5);
            if(this.mc_skills == null)
            {
               this.txt_state.y = int(this.btn_assign.y + this.btn_assign.height + 30);
            }
            else
            {
               this.txt_state.y = int(Sprite(this.mc_skills).y - this.txt_state.height - 24);
            }
            this.mc_stateBG.y = int(this.txt_state.y + (this.txt_state.height - this.mc_stateBG.height) * 0.5);
         }
         else if(this._survivor.state & SurvivorState.ON_MISSION)
         {
            _loc6_ = true;
            this.txt_state.textColor = Effects.COLOR_WARNING;
            TweenMax.to(this.mc_stateBG,0,{"colorMatrixFilter":{"colorize":new Color(Effects.COLOR_WARNING).adjustBrightness(0.5).RGB}});
            this.btn_speedUp.label = this._lang.getString("btn_speed_up_return");
            addChild(this.mc_stateBG);
            addChild(this.txt_state);
            addChild(this.btn_speedUp);
            this.mc_modelView.showInjured = false;
            addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
            this.updateMissionReturnTime();
         }
         else if(this._survivor.state & SurvivorState.REASSIGNING)
         {
            _loc6_ = true;
            this.txt_state.textColor = Effects.COLOR_WARNING;
            TweenMax.to(this.mc_stateBG,0,{"colorMatrixFilter":{"colorize":new Color(Effects.COLOR_WARNING).adjustBrightness(0.5).RGB}});
            this.btn_speedUp.label = this._lang.getString("btn_speed_up_reassign");
            addChild(this.mc_stateBG);
            addChild(this.txt_state);
            addChild(this.btn_speedUp);
            this.mc_modelView.showInjured = false;
            addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
            this.updateReassignTime();
         }
         else if(Boolean(this._survivor.state & SurvivorState.ON_TASK) && this._survivor.task != null)
         {
            _loc6_ = true;
            this.txt_state.textColor = 16763904;
            TweenMax.to(this.mc_stateBG,0,{"colorMatrixFilter":{"colorize":new Color(16763904).adjustBrightness(0.5).RGB}});
            this.btn_speedUp.label = this._lang.getString("btn_speed_up_task");
            addChild(this.mc_stateBG);
            addChild(this.txt_state);
            addChild(this.btn_speedUp);
            this._survivor.task.completed.addOnce(this.onTaskCompleted);
            addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
            this.updateTaskTime();
         }
         if(_loc6_)
         {
            if(this.mc_skills == null)
            {
               this.btn_speedUp.y = int(this.btn_assign.y + this.btn_assign.height + 30);
            }
            else
            {
               this.btn_speedUp.y = int(Sprite(this.mc_skills).y - this.btn_speedUp.height - 12);
            }
            if(_loc1_)
            {
               this.btn_speedUp.y -= 18;
            }
            this.txt_state.y = int(this.btn_speedUp.y - this.txt_state.height - 8);
            this.mc_stateBG.y = int(this.txt_state.y + (this.txt_state.height - this.mc_stateBG.height) * 0.5);
         }
         else if(_loc5_)
         {
            addChild(this.btn_heal);
            this.btn_heal.enabled = !(this._survivor.state & SurvivorState.ON_MISSION || this._survivor.state & SurvivorState.ON_ASSIGNMENT);
            this.btn_heal.x = int((this._width - this.btn_heal.width) * 0.5);
            if(this.mc_skills == null)
            {
               this.btn_heal.y = int(this.btn_assign.y + this.btn_assign.height + 30);
            }
            else
            {
               this.btn_heal.y = int(Sprite(this.mc_skills).y - this.btn_heal.height - 12);
            }
            if(_loc1_)
            {
               this.btn_heal.y -= 18;
            }
         }
         addChild(this.ui_slotWeapon);
         addChild(this.ui_slotGearPassive);
         addChild(this.ui_slotGearActive);
         this.updateLoadoutSlot(this.ui_slotWeapon,_loc4_.weapon);
         this.updateLoadoutSlot(this.ui_slotGearPassive,_loc4_.gearPassive);
         this.updateLoadoutSlot(this.ui_slotGearActive,_loc4_.gearActive);
         this.ui_slotWeapon.showSpecializedIcon = _loc4_.weapon.item != null ? this._survivor.sClass.isSpecialisedWithWeapon(_loc4_.weapon.item as Weapon) : Boolean(null);
         this.ui_slotGearPassive.effective = this.ui_slotGearPassive.itemData != null ? Gear(this.ui_slotGearPassive.itemData).supportsWeapon(_loc4_.weapon.item as Weapon) : true;
         this.ui_slotGearActive.effective = this.ui_slotGearActive.itemData != null ? Gear(this.ui_slotGearActive.itemData).supportsWeapon(_loc4_.weapon.item as Weapon) : true;
         this.ui_slotWeapon.enabled = this.ui_slotGearPassive.enabled = this.ui_slotGearActive.enabled = this._survivor.classId != SurvivorClass.UNASSIGNED;
         if(_loc1_)
         {
            this.levelPoints = Network.getInstance().playerData.levelPoints;
         }
      }
      
      private function drawEditMode() : void
      {
         var _loc1_:Number = 0.5;
         var _loc2_:Number = 1.2;
         TweenMax.to(this.mc_modelView.actorMesh,_loc1_,{
            "scaleX":_loc2_,
            "scaleY":_loc2_,
            "scaleZ":_loc2_,
            "ease":Quad.easeInOut
         });
         TweenMax.to(this.mc_modelView.cameraPosition,_loc1_,{
            "y":0,
            "onUpdate":this.mc_modelView.updateCamera,
            "ease":Quad.easeInOut
         });
         var _loc3_:* = this._survivor.classId == SurvivorClass.PLAYER;
         this.ui_editAppearance = new UISurvivorEditAppearance(this._width - 12,_loc3_ ? UISurvivorEditAppearance.PLAYER_EDIT : UISurvivorEditAppearance.SURVIVOR_EDIT);
         this.ui_editAppearance.appearanceChanged.add(this.onAppearanceChanged);
         this.ui_editAppearance.genderChanged.add(this.onGenderChanged);
         this.ui_editAppearance.voiceChanged.add(this.onVoiceChanged);
         this.ui_editAppearance.appearance = this._survivor.appearance;
         this.ui_editAppearance.x = 6;
         this.ui_editAppearance.y = int(this._height - this.ui_editAppearance.height - 4);
         addChild(this.ui_editAppearance);
         this.ui_slotWeapon.enabled = this.ui_slotGearPassive.enabled = this.ui_slotGearActive.enabled = this._survivor.classId != SurvivorClass.UNASSIGNED;
      }
      
      private function updateLoadoutSlot(param1:UIInventoryListItem, param2:SurvivorLoadoutData) : void
      {
         var _loc4_:BitmapData = null;
         var _loc3_:String = "";
         switch(param1)
         {
            case this.ui_slotWeapon:
               _loc4_ = BMP_LOADOUT_WEAPON;
               break;
            case this.ui_slotGearPassive:
               _loc4_ = BMP_LOADOUT_GEAR;
               break;
            case this.ui_slotGearActive:
               _loc4_ = BMP_LOADOUT_GEAR;
         }
         if(param2.item != null)
         {
            param1.setOverlay(null);
            param1.itemData = param2.item;
            param1.image.quantity = param2.quantity;
            this.ui_itemInfo.addRolloverTarget(param1);
            this._tooltip.remove(param1);
         }
         else
         {
            param1.itemData = null;
            param1.setOverlay(_loc4_);
            this.ui_itemInfo.removeRolloverTarget(param1);
            this._tooltip.add(param1,this._lang.getString("tooltip.equip_" + param2.type),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         }
      }
      
      private function canUseClothingSlot(param1:UIInventoryListItem) : Boolean
      {
         var _loc2_:UIInventoryListItem = null;
         var _loc5_:AttireData = null;
         if(this.survivor.classId == SurvivorClass.UNASSIGNED)
         {
            return false;
         }
         var _loc3_:uint = 0;
         switch(param1)
         {
            case this.ui_slotClothingUpper:
               _loc2_ = this.ui_slotClothingLower;
               _loc3_ = AttireFlags.UPPER_BODY;
               break;
            case this.ui_slotClothingLower:
               _loc2_ = this.ui_slotClothingUpper;
               _loc3_ = AttireFlags.LOWER_BODY;
               break;
            default:
               return true;
         }
         var _loc4_:ClothingAccessory = _loc2_.itemData as ClothingAccessory;
         if(_loc4_ == null)
         {
            return true;
         }
         for each(_loc5_ in _loc4_.getAttireList(this.survivor.gender))
         {
            if((_loc5_.flags & _loc3_) != 0)
            {
               return false;
            }
         }
         return true;
      }
      
      private function updateAllClothingSlots() : void
      {
         var _loc1_:UIInventoryListItem = null;
         this.updateClothingSlot(this.ui_slotAccessory1);
         this.updateClothingSlot(this.ui_slotAccessory2);
         this.updateClothingSlot(this.ui_slotClothingLower);
         this.updateClothingSlot(this.ui_slotClothingUpper);
         for each(_loc1_ in this._clothingSlots)
         {
            _loc1_.enabled = this.canUseClothingSlot(_loc1_);
         }
      }
      
      private function updateClothingSlot(param1:UIInventoryListItem) : void
      {
         var _loc2_:int = 0;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         switch(param1)
         {
            case this.ui_slotAccessory1:
               _loc2_ = 0;
               break;
            case this.ui_slotAccessory2:
               _loc2_ = 1;
               break;
            case this.ui_slotClothingUpper:
               _loc2_ = 2;
               break;
            case this.ui_slotClothingLower:
               _loc2_ = 3;
         }
         var _loc3_:SurvivorLoadout = this._loadoutType == SurvivorLoadout.TYPE_OFFENCE ? this._survivor.loadoutOffence : this._survivor.loadoutDefence;
         var _loc4_:ClothingAccessory = this._survivor.getAccessory(_loc2_);
         if(_loc4_ != null)
         {
            param1.setOverlay(null);
            param1.itemData = _loc4_;
            param1.effective = ClothingAccessory(param1.itemData).supportsWeapon(_loc3_.weapon.item as Weapon);
            this.ui_itemInfo.addRolloverTarget(param1);
            this._tooltip.remove(param1);
         }
         else
         {
            param1.itemData = null;
            param1.effective = true;
            this.ui_itemInfo.removeRolloverTarget(param1);
            switch(param1)
            {
               case this.ui_slotAccessory1:
               case this.ui_slotAccessory2:
                  param1.setOverlay(BMP_LOADOUT_ACCESSORY);
                  _loc5_ = this._lang.getString("tooltip.equip_accessory");
                  _loc6_ = TooltipDirection.DIRECTION_RIGHT;
                  _loc7_ = 0;
                  break;
               case this.ui_slotClothingUpper:
                  param1.setOverlay(BMP_LOADOUT_CLOTHING_UPPER);
                  _loc5_ = this._lang.getString("tooltip.equip_clothing_upper");
                  _loc6_ = TooltipDirection.DIRECTION_LEFT;
                  _loc7_ = param1.width;
                  break;
               case this.ui_slotClothingLower:
                  param1.setOverlay(BMP_LOADOUT_CLOTHING_LOWER);
                  _loc5_ = this._lang.getString("tooltip.equip_clothing_lower");
                  _loc6_ = TooltipDirection.DIRECTION_LEFT;
                  _loc7_ = param1.width;
            }
            if(_loc5_)
            {
               this._tooltip.add(param1,_loc5_,new Point(_loc7_,NaN),_loc6_);
            }
         }
      }
      
      private function updateLevelUpPoints() : void
      {
         this.txt_levelPoints.text = this._lang.getString("levelup_points",UIPlayerSkillsTable(this.mc_skills).points);
         this.txt_levelPoints.x = int(this.mc_nameBar.x + this.mc_nameBar.width - this.txt_levelPoints.width);
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
         this.txt_state.x = int((this._width - this.txt_state.width) * 0.5);
      }
      
      private function updateReassignTime() : void
      {
         if(this._survivor.reassignTimer == null)
         {
            return;
         }
         var _loc1_:String = DateTimeUtils.timeDataToString(this._survivor.reassignTimer.getTimeRemaining(),true,true);
         this.txt_state.text = this._lang.getString("survivor_state.reassign").toUpperCase() + " " + _loc1_;
         this.txt_state.x = int((this._width - this.txt_state.width) * 0.5);
      }
      
      private function updateTaskTime() : void
      {
         if(this._survivor.task == null)
         {
            return;
         }
         this._survivor.task.updateTimer();
         var _loc1_:String = DateTimeUtils.secondsToString((this._survivor.task.length - this._survivor.task.time) / this._survivor.task.survivors.length,true,true);
         this.txt_state.text = this._lang.getString("survivor_tasks." + this._survivor.task.type).toUpperCase() + " " + _loc1_;
         this.txt_state.x = int((this._width - this.txt_state.width) * 0.5);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         stage.addEventListener(Event.RENDER,this.onStageRender,false,0,true);
         if(this._invalid)
         {
            stage.invalidate();
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         stage.removeEventListener(Event.RENDER,this.onStageRender);
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function onStageRender(param1:Event) : void
      {
         if(this._invalid)
         {
            this.updateDisplay();
         }
      }
      
      private function onSlotMouseOver(param1:MouseEvent) : void
      {
         if(!this._loadoutEnabled)
         {
            return;
         }
         var _loc2_:UIInventoryListItem = UIInventoryListItem(param1.currentTarget);
         var _loc3_:SurvivorLoadout = this._loadoutType == SurvivorLoadout.TYPE_OFFENCE ? this._survivor.loadoutOffence : this._survivor.loadoutDefence;
         this.ui_itemInfo.setItem(_loc2_.itemData,_loc3_,{"showEquippedQuantity":true});
      }
      
      private function OnAccessorySlotClicked(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:UIInventoryListItem = UIInventoryListItem(param1.currentTarget);
         switch(_loc2_)
         {
            case this.ui_slotAccessory1:
               _loc3_ = 0;
               break;
            case this.ui_slotAccessory2:
               _loc3_ = 1;
               break;
            case this.ui_slotClothingUpper:
               _loc3_ = 2;
               break;
            case this.ui_slotClothingLower:
               _loc3_ = 3;
         }
         Network.getInstance().playerData.loadoutManager.openAccessoryEquipDialog(this._survivor,_loc3_);
      }
      
      private function onLoadoutSlotClicked(param1:MouseEvent) : void
      {
         var _loc4_:SurvivorLoadoutData = null;
         if(!this._loadoutEnabled)
         {
            return;
         }
         var _loc2_:UIInventoryListItem = UIInventoryListItem(param1.currentTarget);
         var _loc3_:SurvivorLoadout = this._loadoutType == SurvivorLoadout.TYPE_OFFENCE ? this._survivor.loadoutOffence : this._survivor.loadoutDefence;
         switch(_loc2_)
         {
            case this.ui_slotWeapon:
               _loc4_ = _loc3_.weapon;
               break;
            case this.ui_slotGearPassive:
               _loc4_ = _loc3_.gearPassive;
               break;
            case this.ui_slotGearActive:
               _loc4_ = _loc3_.gearActive;
         }
         if(_loc4_ == null)
         {
            return;
         }
         Network.getInstance().playerData.loadoutManager.openEquipDialogue(_loc4_);
      }
      
      private function onAssignClicked(param1:MouseEvent) : void
      {
         var dlg:SurvivorClassAssignmentDialogue = null;
         var e:MouseEvent = param1;
         dlg = new SurvivorClassAssignmentDialogue(this._survivor,this._lang.getString("srv_assign_title",this._survivor.fullName));
         dlg.selected.addOnce(function(param1:String, param2:Boolean = false):void
         {
            _survivor.sClass = Network.getInstance().data.getSurvivorClass(param1);
            Network.getInstance().save({
               "survivorId":_survivor.id,
               "classId":param1
            },SaveDataMethod.SURVIVOR_CLASS);
            dlg.close();
         });
         dlg.open();
      }
      
      private function onSpeedUpClicked(param1:MouseEvent) : void
      {
         var _loc2_:* = null;
         if(this._survivor.state & SurvivorState.ON_MISSION)
         {
            _loc2_ = Network.getInstance().playerData.missionList.getMissionById(this._survivor.missionId);
         }
         else if(this._survivor.state & SurvivorState.REASSIGNING)
         {
            _loc2_ = this._survivor;
         }
         else if(Boolean(this._survivor.state & SurvivorState.ON_TASK) && this._survivor.task != null)
         {
            _loc2_ = this._survivor.task;
         }
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:SpeedUpDialogue = new SpeedUpDialogue(_loc2_);
         _loc3_.open();
      }
      
      private function onLoadoutChanged() : void
      {
         var _loc1_:Weapon = this.ui_slotWeapon.itemData as Weapon;
         var _loc2_:SurvivorLoadout = this._loadoutType == SurvivorLoadout.TYPE_OFFENCE ? this._survivor.loadoutOffence : this._survivor.loadoutDefence;
         this.updateLoadoutSlot(this.ui_slotWeapon,_loc2_.weapon);
         this.updateLoadoutSlot(this.ui_slotGearPassive,_loc2_.gearPassive);
         this.updateLoadoutSlot(this.ui_slotGearActive,_loc2_.gearActive);
         this.ui_slotWeapon.showSpecializedIcon = _loc2_.weapon.item != null ? this._survivor.sClass.isSpecialisedWithWeapon(_loc2_.weapon.item as Weapon) : Boolean(null);
         this.ui_slotGearPassive.effective = this.ui_slotGearPassive.itemData != null ? Gear(this.ui_slotGearPassive.itemData).supportsWeapon(_loc2_.weapon.item as Weapon) : true;
         this.ui_slotGearActive.effective = this.ui_slotGearActive.itemData != null ? Gear(this.ui_slotGearActive.itemData).supportsWeapon(_loc2_.weapon.item as Weapon) : true;
         if(this.mc_skills != null)
         {
            this.mc_skills.setSurvivor(this._survivor,_loc2_);
         }
         if(this.ui_details != null)
         {
            this.ui_details.showSurvivorStats(this._survivor,_loc2_);
         }
         if(this.mc_modelView != null)
         {
            this.mc_modelView.update();
         }
      }
      
      private function onClothingAccessoryChanged(param1:Survivor) : void
      {
         var _loc2_:SurvivorLoadout = this._loadoutType == SurvivorLoadout.TYPE_OFFENCE ? this._survivor.loadoutOffence : this._survivor.loadoutDefence;
         this.updateAllClothingSlots();
         if(this.mc_skills != null)
         {
            this.mc_skills.setSurvivor(this._survivor,_loc2_);
         }
         if(this.ui_details != null)
         {
            this.ui_details.showSurvivorStats(this._survivor,_loc2_);
         }
         this.onAppearanceChanged();
      }
      
      private function onInjuriesChanged(param1:Survivor) : void
      {
         if(this._survivor.injuries.length > 0)
         {
            this._tooltip.add(this.mc_injured,this._survivor.injuries.getTooltip,new Point(0,NaN),TooltipDirection.DIRECTION_RIGHT);
            this.mc_injured.x = int(this.mc_morale.x - this.mc_injured.width - 2);
            this.mc_injured.y = int(this.mc_morale.y - this.mc_injured.height * 0.5);
            addChild(this.mc_injured);
            if(this.btn_speedUp.parent == null)
            {
               addChild(this.btn_heal);
               this.btn_heal.enabled = !(this._survivor.state & SurvivorState.ON_MISSION || this._survivor.state & SurvivorState.ON_ASSIGNMENT);
               this.btn_heal.x = int((this._width - this.btn_heal.width) * 0.5);
               if(this.mc_skills == null)
               {
                  this.btn_heal.y = int(this.btn_assign.y + this.btn_assign.height + 30);
               }
               else
               {
                  this.btn_heal.y = int(Sprite(this.mc_skills).y - this.btn_heal.height - 12);
               }
            }
         }
         else
         {
            if(this.mc_injured.parent != null)
            {
               this.mc_injured.parent.removeChild(this.mc_injured);
            }
            if(this.btn_heal.parent != null)
            {
               this.btn_heal.parent.removeChild(this.btn_heal);
            }
         }
         var _loc2_:SurvivorLoadout = this._loadoutType == SurvivorLoadout.TYPE_OFFENCE ? this._survivor.loadoutOffence : this._survivor.loadoutDefence;
         if(this.mc_skills != null)
         {
            this.mc_skills.setSurvivor(this._survivor,_loc2_);
         }
         if(this.ui_details != null)
         {
            this.ui_details.showSurvivorStats(this._survivor,_loc2_);
         }
      }
      
      private function onClassChanged(param1:Survivor) : void
      {
         if(this._survivor == null)
         {
            return;
         }
         this.invalidate();
         this.mc_modelView.update();
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
         this.invalidate();
      }
      
      private function onTimerCompleted(param1:TimerData) : void
      {
         var _loc2_:Survivor = null;
         var _loc3_:MissionData = param1.target as MissionData;
         if(_loc3_ != null)
         {
            if(param1.data.type == "return" && _loc3_.returnTimer == param1)
            {
               for each(_loc2_ in _loc3_.survivors)
               {
                  if(_loc2_ == this._survivor)
                  {
                     this.invalidate();
                     this.mc_modelView.update();
                     break;
                  }
               }
            }
            return;
         }
         _loc2_ = param1.target as Survivor;
         if(_loc2_ != null && _loc2_ == this._survivor)
         {
            this.invalidate();
            if(this.mc_modelView != null)
            {
               this.mc_modelView.update();
            }
         }
      }
      
      private function onLevelUpAttributeModified(param1:String) : void
      {
         this.updateLevelUpPoints();
      }
      
      private function onClickEditName(param1:MouseEvent) : void
      {
         addChild(this.ui_editName);
         stage.focus = this.ui_editName.textField;
         this.ui_editName.defaultValue = this.ui_editName.value = this._survivor.fullName;
         this.ui_editName.textField.setSelection(0,this.ui_editName.value.length);
         this.ui_editName.enterPressed.add(this.onSaveEditName);
      }
      
      private function onNameFocusOut(param1:FocusEvent) : void
      {
         this.ui_editName.enterPressed.remove(this.onSaveEditName);
         if(this.ui_editName.parent != null)
         {
            this.ui_editName.parent.removeChild(this.ui_editName);
         }
         this._tooltip.remove(this.mc_nameBar);
      }
      
      private function onEditNameError() : void
      {
         this._tooltip.add(this.mc_nameBar,this._lang.getString("player_create_error_nickname"),new Point(10,this.mc_nameBar.height),TooltipDirection.DIRECTION_UP,0);
         this._tooltip.show(this.mc_nameBar);
      }
      
      private function onSaveEditName() : void
      {
         var network:Network = null;
         var busy:BusyDialogue = null;
         var name:String = this.ui_editName.value;
         network = Network.getInstance();
         if(this._survivor == network.playerData.getPlayerSurvivor())
         {
            return;
         }
         if(name == null || name == "" || name.length < Config.constant.RESTRICT_NAME_MIN_LENGTH || name.length > Config.constant.RESTRICT_NAME_MAX_LENGTH)
         {
            this.onEditNameError();
            return;
         }
         this.onNameFocusOut(null);
         name = StringUtils.trimWhiteSpace(name);
         if(name == this._survivor.fullName)
         {
            return;
         }
         busy = new BusyDialogue(this._lang.getString("survivor_renaming",this._survivor.fullName));
         busy.open();
         network.save({
            "id":this._survivor.id,
            "name":this.ui_editName.value
         },SaveDataMethod.SURVIVOR_RENAME,function(param1:Object):void
         {
            busy.close();
            if(param1 == null || param1.success === false)
            {
               network.throwSyncError();
               return;
            }
            if(param1.error != null)
            {
               switch(param1.error)
               {
                  case "name_short":
                  case "name_long":
                  case "name_invalid":
                     onEditNameError();
               }
               return;
            }
            var _loc2_:String = String(param1.name);
            var _loc3_:String = String(param1.id);
            if(_loc3_.toLowerCase() == _survivor.id.toLowerCase())
            {
               _survivor.setName(_loc2_);
            }
         });
      }
      
      private function onNameChanged(param1:Survivor) : void
      {
         this.mc_nameBar.title = param1.fullName.toUpperCase();
      }
      
      private function onDetailsClicked(param1:MouseEvent) : void
      {
         this.showMoreDetails(!this._showingDetails);
      }
      
      private function onAppearanceChanged() : void
      {
         this._appearanceChanged = true;
         this.mc_modelView.update();
         if(this.ui_editAppearance != null)
         {
            this.ui_editAppearance.updateForceHairOption();
         }
      }
      
      private function onGenderChanged(param1:String) : void
      {
         this._genderChanged = true;
         this._appearanceChanged = true;
         this._voiceChanged = true;
         this.mc_modelView.update();
         this.ui_editAppearance.updateForceHairOption();
      }
      
      private function onVoiceChanged() : void
      {
         this._appearanceChanged = true;
         this._voiceChanged = true;
      }
      
      private function onHealClicked(param1:MouseEvent) : void
      {
         DialogueController.getInstance().openHeal(this._survivor);
      }
      
      private function onSkillResetClicked(param1:MouseEvent) : void
      {
         var _loc2_:LeaderRetrainDialogue = new LeaderRetrainDialogue();
         _loc2_.resetSuccessful.addOnce(this.onSkillResetSuccess);
         _loc2_.open();
      }
      
      private function onSkillResetSuccess() : void
      {
         this.setMode(MODE_LEVEL);
      }
      
      public function get levelPoints() : int
      {
         return this._levelPoints;
      }
      
      public function set levelPoints(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._levelPoints = param1;
         if(this.mc_skills is UIPlayerSkillsTable)
         {
            UIPlayerSkillsTable(this.mc_skills).points = this._levelPoints;
            this.updateLevelUpPoints();
         }
      }
      
      public function get loadoutEnabled() : Boolean
      {
         return this._loadoutEnabled;
      }
      
      public function set loadoutEnabled(param1:Boolean) : void
      {
         this._loadoutEnabled = param1;
      }
      
      public function get loadoutType() : String
      {
         return this._loadoutType;
      }
      
      public function set loadoutType(param1:String) : void
      {
         if(this._survivor != null)
         {
            this._survivor.loadoutOffence.changed.remove(this.onLoadoutChanged);
            this._survivor.loadoutDefence.changed.remove(this.onLoadoutChanged);
         }
         this._loadoutType = param1;
         this.mc_modelView.showWeapon = this._loadoutType;
         if(this._survivor != null)
         {
            this._survivor.setActiveLoadout(this._loadoutType);
            this._survivor.activeLoadout.changed.add(this.onLoadoutChanged);
            this.onLoadoutChanged();
         }
      }
      
      public function get mode() : uint
      {
         return this._mode;
      }
      
      public function get survivor() : Survivor
      {
         return this._survivor;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      public function get showEditName() : Boolean
      {
         return this._showEditName;
      }
      
      public function set showEditName(param1:Boolean) : void
      {
         this._showEditName = param1;
         this.btn_editName.visible = param1;
         this.mc_nameBar.mouseEnabled = this._showEditName;
      }
   }
}

