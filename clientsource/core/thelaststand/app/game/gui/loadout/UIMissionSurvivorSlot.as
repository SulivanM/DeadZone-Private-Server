package thelaststand.app.game.gui.loadout
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.getDefinitionByName;
   import org.osflash.signals.natives.NativeSignal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorClass;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.SurvivorLoadoutData;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.survivor.UISurvivorHealthBarLarge;
   import thelaststand.app.game.logic.DialogueController;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class UIMissionSurvivorSlot extends Sprite
   {
      
      private static const BMP_SEPARATOR:BitmapData = new BmpSurvivorLoadoutSeparator();
      
      public static const SHOW_NONE:uint = 0;
      
      public static const SHOW_TITLE:uint = 1;
      
      public static const SHOW_HEAL:uint = 2;
      
      public static const SHOW_BORDER:uint = 4;
      
      public static const SHOW_ALL:uint = 255;
      
      private var _lang:Language;
      
      private var _tooltip:TooltipManager;
      
      private var _enabled:Boolean = true;
      
      private var _width:int = 191;
      
      private var _height:int = 83;
      
      private var _survivor:Survivor;
      
      private var _loadout:SurvivorLoadout;
      
      private var _readOnly:Boolean;
      
      private var bmp_classIcon:Bitmap;
      
      private var bmp_separator:Bitmap;
      
      private var btn_heal:PushButton;
      
      private var mc_bg:Sprite;
      
      private var mc_title:UITitleBar;
      
      private var mc_classBg:Shape;
      
      private var txt_level:BodyTextField;
      
      private var ui_portrait:UILoadoutPortrait;
      
      private var ui_slotWeapon:UILoadoutSlot;
      
      private var ui_slotGearPassive:UILoadoutSlot;
      
      private var ui_slotGearActive:UILoadoutSlot;
      
      private var ui_itemInfo:UIItemInfo;
      
      private var ui_health:UISurvivorHealthBarLarge;
      
      public var clicked:NativeSignal;
      
      public function UIMissionSurvivorSlot(param1:uint = 255, param2:int = 226, param3:int = 83, param4:String = "38x38", param5:Boolean = false)
      {
         super();
         this._lang = Language.getInstance();
         this._tooltip = TooltipManager.getInstance();
         this._width = param2;
         this._height = param3;
         this._readOnly = param5;
         this.mc_bg = new Sprite();
         if(param1 & SHOW_BORDER)
         {
            this.mc_bg.graphics.beginFill(7631988);
            this.mc_bg.graphics.drawRect(0,0,this._width,this._height);
            this.mc_bg.graphics.endFill();
         }
         this.mc_bg.graphics.beginFill(2434341);
         if(param1 & SHOW_BORDER)
         {
            this.mc_bg.graphics.drawRect(1,1,this._width - 2,this._height - 2);
         }
         else
         {
            this.mc_bg.graphics.drawRect(0,0,this._width,this._height);
         }
         this.mc_bg.graphics.endFill();
         addChild(this.mc_bg);
         var _loc6_:int = 0;
         if(param1 & SHOW_TITLE)
         {
            this.mc_title = new UITitleBar({
               "padding":28,
               "font":this._lang.getFontName("body"),
               "bold":true,
               "size":12,
               "color":10658466
            },9671571);
            this.mc_title.title = this._lang.getString("mission_add_survivor");
            this.mc_title.x = this.mc_title.y = 2;
            this.mc_title.width = int(this._width - this.mc_title.x * 2);
            this.mc_title.height = 20;
            this.mc_title.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
            this.mc_title.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
            this.mc_title.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
            addChild(this.mc_title);
            this.mc_classBg = new Shape();
            this.mc_classBg.graphics.beginFill(0,0.2);
            this.mc_classBg.graphics.drawRect(0,0,26,this.mc_title.height);
            this.mc_classBg.graphics.endFill();
            this.mc_classBg.x = this.mc_title.x;
            this.mc_classBg.y = this.mc_title.y;
            addChild(this.mc_classBg);
            this.bmp_classIcon = new Bitmap();
            addChild(this.bmp_classIcon);
            this.txt_level = new BodyTextField({
               "color":15252056,
               "size":12,
               "bold":true
            });
            this.txt_level.text = this._lang.getString("lvl",0);
            this.txt_level.y = Math.round(this.mc_title.y + (this.mc_title.height - this.txt_level.height) * 0.5);
            this.txt_level.filters = [Effects.TEXT_SHADOW_DARK];
            addChild(this.txt_level);
            _loc6_ = int(this.mc_title.y + this.mc_title.height);
         }
         this.ui_portrait = new UILoadoutPortrait(param4,!this._readOnly);
         this.ui_portrait.y = int(_loc6_ + (this._height - _loc6_ - this.ui_portrait.height) * 0.5);
         this.ui_portrait.x = int(this.ui_portrait.y - _loc6_);
         this.ui_portrait.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         this.ui_portrait.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         this.ui_portrait.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         addChild(this.ui_portrait);
         this.bmp_separator = new Bitmap(BMP_SEPARATOR,"auto",true);
         this.bmp_separator.x = int(this.ui_portrait.width + this.ui_portrait.x * 2 - 2);
         this.bmp_separator.y = _loc6_ + 2;
         this.bmp_separator.height = int(this._height - _loc6_ - 4);
         addChild(this.bmp_separator);
         this.ui_slotWeapon = new UILoadoutSlot(this._readOnly);
         this.ui_slotWeapon.x = int(this.bmp_separator.x + this.bmp_separator.width + this.ui_portrait.x - 4);
         this.ui_slotWeapon.y = int(_loc6_ + (this._height - _loc6_ - this.ui_slotWeapon.height - 1) * 0.5);
         this.ui_slotWeapon.clicked.add(this.onSlotClicked);
         this.ui_slotWeapon.mouseOver.add(this.onMouseOverSlot);
         addChild(this.ui_slotWeapon);
         this.ui_slotGearPassive = new UILoadoutSlot(this._readOnly);
         this.ui_slotGearPassive.x = int(this.ui_slotWeapon.x + this.ui_slotWeapon.width + 6);
         this.ui_slotGearPassive.y = this.ui_slotWeapon.y;
         this.ui_slotGearPassive.clicked.add(this.onSlotClicked);
         this.ui_slotGearPassive.mouseOver.add(this.onMouseOverSlot);
         addChild(this.ui_slotGearPassive);
         this.ui_slotGearActive = new UILoadoutSlot(this._readOnly);
         this.ui_slotGearActive.x = int(this.ui_slotGearPassive.x + this.ui_slotGearPassive.width + 6);
         this.ui_slotGearActive.y = this.ui_slotWeapon.y;
         this.ui_slotGearActive.clicked.add(this.onSlotClicked);
         this.ui_slotGearActive.mouseOver.add(this.onMouseOverSlot);
         addChild(this.ui_slotGearActive);
         if(param1 & SHOW_HEAL)
         {
            this.btn_heal = new PushButton(null,new BmpIconInjuries());
            this.btn_heal.height = int(this.ui_slotGearActive.height * 0.8);
            this.btn_heal.width = this.btn_heal.height;
            this.btn_heal.x = int(this.ui_slotGearActive.x + this.ui_slotGearActive.width + 10);
            this.btn_heal.y = int(this.ui_slotGearActive.y + (this.ui_slotGearActive.height - this.btn_heal.height) * 0.5);
            this.btn_heal.showBorder = false;
            this.btn_heal.clicked.add(this.onHealClicked);
            this._tooltip.add(this.btn_heal,this._lang.getString("srv_heal_btn"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
            addChild(this.btn_heal);
         }
         this.ui_health = new UISurvivorHealthBarLarge();
         this.ui_health.width = int(this.ui_portrait.width * 0.8);
         this.ui_health.x = int(this.ui_portrait.x + (this.ui_portrait.width - this.ui_health.width) * 0.5);
         this.ui_health.y = int(this.ui_portrait.y + this.ui_portrait.height - this.ui_health.height - (this.ui_health.x - this.ui_portrait.x));
         this.ui_itemInfo = new UIItemInfo();
         this.updateDisplay();
         this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this._lang = null;
         this._tooltip.removeAllFromParent(this);
         this._tooltip = null;
         if(this._loadout != null)
         {
            this._loadout.changed.remove(this.onLoadoutChanged);
         }
         if(this._survivor != null)
         {
            this._survivor.injuries.changed.remove(this.onInjuriedChanged);
         }
         this._survivor = null;
         this._loadout = null;
         this.clicked.removeAll();
         if(this.bmp_classIcon != null)
         {
            if(this.bmp_classIcon.bitmapData != null)
            {
               this.bmp_classIcon.bitmapData.dispose();
               this.bmp_classIcon.bitmapData = null;
            }
            this.bmp_classIcon = null;
         }
         this.bmp_separator.bitmapData = null;
         this.bmp_separator = null;
         if(this.mc_title != null)
         {
            this.mc_title.dispose();
            this.mc_title = null;
         }
         if(this.txt_level != null)
         {
            this.txt_level.dispose();
            this.txt_level = null;
         }
         this.ui_health.dispose();
         this.ui_portrait.dispose();
         this.ui_portrait = null;
         this.ui_slotWeapon.dispose();
         this.ui_slotWeapon = null;
         this.ui_slotGearPassive.dispose();
         this.ui_slotGearPassive = null;
         this.ui_slotGearActive.dispose();
         this.ui_slotGearActive = null;
         this.ui_itemInfo.dispose();
         this.ui_itemInfo = null;
         if(this.btn_heal != null)
         {
            this.btn_heal.dispose();
         }
      }
      
      public function setSurvivor(param1:Survivor, param2:SurvivorLoadout) : void
      {
         var _loc3_:String = null;
         if(param1 != null && param2 == null)
         {
            throw new Error("A loadout must be supplied.");
         }
         if(this._loadout != null)
         {
            this._loadout.changed.remove(this.onLoadoutChanged);
         }
         if(this._survivor != null)
         {
            this._survivor.injuries.changed.remove(this.onInjuriedChanged);
         }
         this._survivor = param1;
         this._loadout = param2;
         this.ui_slotWeapon.loadoutData = this._loadout ? this._loadout.weapon : null;
         this.ui_slotGearPassive.loadoutData = this._loadout ? this._loadout.gearPassive : null;
         this.ui_slotGearActive.loadoutData = this._loadout ? this._loadout.gearActive : null;
         this.updateDisplay();
         if(this._survivor != null)
         {
            this._survivor.injuries.changed.add(this.onInjuriedChanged);
         }
         if(this._loadout != null)
         {
            this._loadout.changed.add(this.onLoadoutChanged);
         }
         if(this._survivor != null)
         {
            _loc3_ = this._lang.getString("lvl",this._survivor.level + 1);
            this._tooltip.add(this.ui_portrait,this._survivor.fullName + " - " + _loc3_,new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0.2);
         }
         else
         {
            this._tooltip.remove(this.ui_portrait);
         }
      }
      
      private function updateDisplay() : void
      {
         var _loc1_:Class = null;
         this.ui_portrait.survivor = this._survivor;
         if(this._survivor == null || this._loadout == null)
         {
            mouseChildren = false;
            mouseEnabled = true;
            if(this.txt_level != null && this.txt_level.parent != null)
            {
               this.txt_level.parent.removeChild(this.txt_level);
            }
            if(this.mc_title != null)
            {
               this.mc_title.setTitleProperties({
                  "color":10658466,
                  "bold":true
               });
               this.mc_title.title = this._lang.getString("mission_add_survivor");
               this.mc_title.color = 9671571;
               this.bmp_classIcon.bitmapData = null;
            }
            this.ui_slotWeapon.alpha = this.ui_slotGearPassive.alpha = this.ui_slotGearActive.alpha = this._enabled ? 0.5 : 0.3;
            if(this.btn_heal != null)
            {
               this.btn_heal.enabled = false;
               this.btn_heal.alpha = this._enabled ? 1 : 0.1;
               this.btn_heal.backgroundColor = 2960942;
            }
            if(this.ui_health.parent != null)
            {
               this.ui_health.parent.removeChild(this.ui_health);
            }
         }
         else
         {
            mouseChildren = true;
            this.ui_slotWeapon.alpha = this.ui_slotGearPassive.alpha = this.ui_slotGearActive.alpha = this._enabled ? 1 : 0.3;
            this.ui_health.survivor = this._survivor;
            if(this.btn_heal != null)
            {
               this.btn_heal.enabled = this._enabled && this._survivor.injuries.length > 0;
               this.btn_heal.alpha = this._enabled ? 1 : 0.1;
               this.btn_heal.backgroundColor = this.btn_heal.enabled ? 10108462 : 2960942;
            }
            if(this.mc_title != null)
            {
               this.mc_title.setTitleProperties({
                  "color":16777215,
                  "bold":true
               });
               this.mc_title.color = 6326675;
               this.mc_title.title = this._survivor.fullName.toUpperCase();
            }
            if(this.txt_level != null)
            {
               this.txt_level.text = this._lang.getString("lvl",this._survivor.level + 1);
               this.txt_level.x = int(this.mc_title.x + this.mc_title.width - this.txt_level.width - 2);
               addChild(this.txt_level);
            }
            if(this.bmp_classIcon != null)
            {
               if(this._survivor.classId != SurvivorClass.UNASSIGNED)
               {
                  _loc1_ = getDefinitionByName("BmpIconClass_" + this._survivor.classId) as Class;
                  if(_loc1_ != null)
                  {
                     this.bmp_classIcon.bitmapData = new _loc1_();
                  }
                  this.bmp_classIcon.x = int(this.mc_classBg.x + (this.mc_classBg.width - this.bmp_classIcon.width) * 0.5);
                  this.bmp_classIcon.y = int(this.mc_classBg.y + (this.mc_classBg.height - this.bmp_classIcon.height) * 0.5);
               }
               else
               {
                  this.bmp_classIcon.bitmapData = null;
               }
            }
         }
         this.onLoadoutChanged();
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
         else if(this._readOnly)
         {
            this.ui_itemInfo.removeRolloverTarget(param1);
            this._tooltip.remove(param1);
         }
         else
         {
            this.ui_itemInfo.removeRolloverTarget(param1);
            this._tooltip.add(param1,this._lang.getString("tooltip.equip_" + param1.loadoutData.type),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(this.mc_title != null)
         {
            TweenMax.to(this.mc_title,0,{
               "colorTransform":{"exposure":1.05},
               "overwrite":true
            });
         }
         if(this._survivor != null && this._survivor.injuries.length > 0)
         {
            addChild(this.ui_health);
         }
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(this.mc_title != null)
         {
            TweenMax.to(this.mc_title,0.25,{
               "colorTransform":{"exposure":1},
               "overwrite":true
            });
         }
         if(this.ui_health.parent != null)
         {
            this.ui_health.parent.removeChild(this.ui_health);
         }
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(this.mc_title != null)
         {
            TweenMax.to(this.mc_title,0,{"colorTransform":{"exposure":1.25}});
            TweenMax.to(this.mc_title,0.25,{
               "delay":0.01,
               "colorTransform":{"exposure":1}
            });
         }
         if(!(param1.target is UILoadoutSlot))
         {
            Audio.sound.play("sound/interface/int-click.mp3");
         }
      }
      
      private function onLoadoutChanged() : void
      {
         this.updateLoadoutSlotTooltip(this.ui_slotWeapon);
         this.updateLoadoutSlotTooltip(this.ui_slotGearPassive);
         this.updateLoadoutSlotTooltip(this.ui_slotGearActive);
      }
      
      private function onInjuriedChanged(param1:Survivor) : void
      {
         if(this.btn_heal != null)
         {
            this.btn_heal.enabled = this._enabled && this._survivor.injuries.length > 0;
            this.btn_heal.alpha = this._enabled ? 1 : 0.1;
            this.btn_heal.backgroundColor = this.btn_heal.enabled ? 10108462 : 2960942;
         }
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
      
      private function onSlotClicked(param1:MouseEvent) : void
      {
         var _loc2_:UILoadoutSlot = UILoadoutSlot(param1.currentTarget);
         param1.stopPropagation();
         if(this._readOnly || _loc2_.locked || this._survivor == null || _loc2_.loadoutData == null)
         {
            return;
         }
         Network.getInstance().playerData.loadoutManager.openEquipDialogue(_loc2_.loadoutData);
      }
      
      private function onHealClicked(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DialogueController.getInstance().openHeal(this._survivor);
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
         if(this._enabled)
         {
            mouseEnabled = true;
            mouseChildren = this._survivor != null;
         }
         else
         {
            mouseEnabled = mouseChildren = false;
         }
         var _loc2_:Number = this._enabled ? 1 : 0.3;
         if(this.mc_title != null)
         {
            this.mc_title.alpha = _loc2_;
         }
         this.ui_slotWeapon.alpha = this.ui_slotGearPassive.alpha = this.ui_slotGearActive.alpha = this.ui_portrait.alpha = _loc2_;
      }
      
      public function get survivor() : Survivor
      {
         return this._survivor;
      }
   }
}

