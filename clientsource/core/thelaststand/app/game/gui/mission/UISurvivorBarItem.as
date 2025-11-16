package thelaststand.app.game.gui.mission
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.ui.Keyboard;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.CoverData;
   import thelaststand.app.game.data.Gear;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorLoadoutData;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.data.WeaponClass;
   import thelaststand.app.game.gui.UIItemImage;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.UISurvivorPortrait;
   import thelaststand.app.game.gui.survivor.UISurvivorHealthBarLarge;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.common.lang.Language;
   
   public class UISurvivorBarItem extends Sprite
   {
      
      private static const OUTLINE:GlowFilter = new GlowFilter(0,1,2,2,10,1);
      
      public static const EXIT_ZONE_STATE_NONE:uint = 0;
      
      public static const EXIT_ZONE_STATE_OUT:uint = 1;
      
      public static const EXIT_ZONE_STATE_IN:uint = 2;
      
      private var _exitZoneState:uint = 0;
      
      private var _survivor:Survivor;
      
      private var _selected:Boolean;
      
      private var _width:int = 40;
      
      private var _height:int = 40;
      
      private var _mouseOverItem:UIItemImage;
      
      private var bmp_cover:Bitmap;
      
      private var bmp_healing:Bitmap;
      
      private var bmp_inExitZone:Bitmap;
      
      private var mc_background:Shape;
      
      private var ui_portrait:UISurvivorPortrait;
      
      private var ui_weapon:UIItemImage;
      
      private var ui_gearActive:UIItemImage;
      
      private var ui_health:UISurvivorHealthBarLarge;
      
      private var ui_itemInfo:UIItemInfo;
      
      public var portraitClicked:Signal;
      
      public var weaponClicked:Signal;
      
      public var gearActiveClicked:Signal;
      
      public function UISurvivorBarItem()
      {
         super();
         this.mc_background = new Shape();
         this.mc_background.graphics.beginFill(0);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         this.mc_background.filters = [OUTLINE];
         addChild(this.mc_background);
         this.ui_portrait = new UISurvivorPortrait(UISurvivorPortrait.SIZE_40x40,2631720);
         this.ui_portrait.addEventListener(MouseEvent.CLICK,this.onClickPortrait,false,0,true);
         addChild(this.ui_portrait);
         this.ui_weapon = new UIItemImage(30,30);
         this.ui_weapon.x = int(this.ui_portrait.x + this.ui_portrait.width + 6);
         this.ui_weapon.y = int(this.ui_portrait.y + (this.ui_portrait.height - this.ui_weapon.height) * 0.5);
         this.ui_weapon.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverItem,false,0,true);
         this.ui_weapon.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutItem,false,0,true);
         this.ui_weapon.addEventListener(MouseEvent.CLICK,this.onClickWeapon,false,0,true);
         this.ui_weapon.visible = false;
         this.ui_gearActive = new UIItemImage(30,30);
         this.ui_gearActive.x = int(this.ui_weapon.x + this.ui_weapon.width + 6);
         this.ui_gearActive.y = int(this.ui_weapon.y);
         this.ui_gearActive.quantityFieldSize = 13;
         this.ui_gearActive.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverItem,false,0,true);
         this.ui_gearActive.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutItem,false,0,true);
         this.ui_gearActive.addEventListener(MouseEvent.CLICK,this.onClickActiveGear,false,0,true);
         this.ui_gearActive.addEventListener(MouseEvent.RIGHT_CLICK,this.onClickActiveGear,false,0,true);
         this.ui_gearActive.visible = false;
         this.ui_health = new UISurvivorHealthBarLarge();
         this.ui_health.width = int(this.ui_portrait.width - 8);
         this.ui_health.x = int(this.ui_portrait.x + (this.ui_portrait.width - this.ui_health.width) * 0.5);
         this.ui_health.y = int(this.ui_portrait.y + this.ui_portrait.height - this.ui_health.height - this.ui_health.x);
         this.ui_health.visible = false;
         addChild(this.ui_health);
         this.bmp_cover = new Bitmap();
         this.bmp_cover.x = int(this.ui_portrait.x + 2);
         this.bmp_cover.y = int(this.ui_portrait.y + 2);
         this.bmp_cover.visible = false;
         addChild(this.bmp_cover);
         this.bmp_healing = new Bitmap(new BmpIconHealing());
         this.bmp_healing.x = int(this.ui_portrait.x + 2);
         this.bmp_healing.y = int(this.ui_health.y - this.bmp_healing.height - 2);
         this.bmp_healing.visible = false;
         addChild(this.bmp_healing);
         this.bmp_inExitZone = new Bitmap();
         this.bmp_inExitZone.x = int(this.ui_portrait.x + this.ui_portrait.width - 18);
         this.bmp_inExitZone.y = int(this.ui_portrait.y - 10);
         this.bmp_inExitZone.visible = false;
         addChild(this.bmp_inExitZone);
         this.ui_itemInfo = new UIItemInfo();
         this.ui_itemInfo.useTimer = false;
         this.ui_itemInfo.useCtrlKey = true;
         this.ui_itemInfo.addRolloverTarget(this.ui_weapon);
         this.ui_itemInfo.addRolloverTarget(this.ui_gearActive);
         this.ui_itemInfo.addEventListener(Event.ADDED_TO_STAGE,this.onItemInfoAddedToStage,false,0,true);
         this.portraitClicked = new Signal(UISurvivorBarItem);
         this.weaponClicked = new Signal(UISurvivorBarItem);
         this.gearActiveClicked = new Signal(UISurvivorBarItem);
         this._width = int(this.ui_portrait.x + this.ui_portrait.width);
         this._height = int(this.ui_portrait.y + this.ui_portrait.height);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function get exitZoneState() : uint
      {
         return this._exitZoneState;
      }
      
      public function set exitZoneState(param1:uint) : void
      {
         this._exitZoneState = param1;
         if(this.bmp_inExitZone.bitmapData != null)
         {
            this.bmp_inExitZone.bitmapData.dispose();
            this.bmp_inExitZone.bitmapData = null;
         }
         switch(this._exitZoneState)
         {
            case EXIT_ZONE_STATE_IN:
               this.bmp_inExitZone.bitmapData = new BmpExitZoneOK();
               this.bmp_inExitZone.visible = this._survivor.health > 0;
               break;
            case EXIT_ZONE_STATE_OUT:
               this.bmp_inExitZone.bitmapData = new BmpExitZoneBad();
               this.bmp_inExitZone.visible = this._survivor.health > 0;
               break;
            case EXIT_ZONE_STATE_NONE:
            default:
               this.bmp_inExitZone.visible = false;
         }
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this._selected = param1;
         if(this._selected)
         {
            this.expand();
         }
         else
         {
            this.collapse();
         }
      }
      
      public function get survivor() : Survivor
      {
         return this._survivor;
      }
      
      public function set survivor(param1:Survivor) : void
      {
         this.removeSurvivorListeners();
         this._survivor = param1;
         this.addSurvivorListeners();
         this.update();
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
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this.portraitClicked.removeAll();
         this.weaponClicked.removeAll();
         this.gearActiveClicked.removeAll();
         this.removeSurvivorListeners();
         this._survivor = null;
         this.bmp_cover.bitmapData = null;
         this.bmp_healing.bitmapData.dispose();
         this.bmp_healing.bitmapData = null;
         if(this.bmp_inExitZone.bitmapData != null)
         {
            this.bmp_inExitZone.bitmapData.dispose();
            this.bmp_inExitZone.bitmapData = null;
         }
         this.mc_background.filters = [];
         this.ui_portrait.dispose();
         this.ui_health.dispose();
         this.ui_weapon.dispose();
         this.ui_gearActive.dispose();
         this.ui_itemInfo.dispose();
      }
      
      private function addSurvivorListeners() : void
      {
         if(this._survivor == null)
         {
            return;
         }
         if(this._survivor.activeLoadout != null)
         {
            this._survivor.activeLoadout.gearActive.changed.add(this.onActiveGearChanged);
         }
         this._survivor.agentData.coverRatingChanged.add(this.onCoverRatingChanged);
         this._survivor.damageTaken.add(this.onDamageReceived);
         this._survivor.healthChanged.add(this.onHealthChanged);
         this._survivor.healingStarted.add(this.onHealingStarted);
         this._survivor.healingCompleted.add(this.onHealingCompleted);
         this._survivor.died.add(this.onSurvivorDied);
      }
      
      private function removeSurvivorListeners() : void
      {
         if(this._survivor == null)
         {
            return;
         }
         if(this._survivor.activeLoadout != null)
         {
            this._survivor.activeLoadout.gearActive.changed.remove(this.onActiveGearChanged);
         }
         this._survivor.agentData.coverRatingChanged.remove(this.onCoverRatingChanged);
         this._survivor.damageTaken.remove(this.onDamageReceived);
         this._survivor.healthChanged.remove(this.onHealthChanged);
         this._survivor.healingStarted.remove(this.onHealingStarted);
         this._survivor.healingCompleted.remove(this.onHealingCompleted);
         this._survivor.died.remove(this.onSurvivorDied);
      }
      
      private function expand() : void
      {
         if(this.ui_gearActive.parent != null)
         {
            this._width = int(this.ui_gearActive.x + this.ui_gearActive.width);
         }
         else
         {
            this._width = int(this.ui_weapon.x + this.ui_weapon.width);
         }
         this.ui_weapon.visible = true;
         this.ui_gearActive.visible = true;
         TweenMax.to(this.mc_background,0.25,{"glowFilter":{
            "color":16777215,
            "alpha":1,
            "blurX":2,
            "blurY":2,
            "strength":10,
            "quality":1
         }});
      }
      
      private function collapse() : void
      {
         this._width = int(this.ui_portrait.x + this.ui_portrait.width);
         this.ui_weapon.visible = false;
         this.ui_gearActive.visible = false;
         TweenMax.to(this.mc_background,0.25,{"glowFilter":{
            "color":0,
            "alpha":1,
            "blurX":2,
            "blurY":2,
            "strength":10,
            "quality":1
         }});
      }
      
      private function hideCurrentItemInfo() : void
      {
         this.ui_itemInfo.hide();
         if(this._mouseOverItem != null)
         {
            TooltipManager.getInstance().show(this._mouseOverItem);
         }
      }
      
      private function setCurrentItemInfo() : void
      {
         switch(this._mouseOverItem)
         {
            case this.ui_weapon:
               this.ui_itemInfo.setItem(this.ui_weapon.item,this._survivor.activeLoadout);
               break;
            case this.ui_gearActive:
               this.ui_itemInfo.setItem(this.ui_gearActive.item,this._survivor.activeLoadout,{"showEquippedQuantity":true});
               break;
            default:
               this.ui_itemInfo.setItem(null);
         }
      }
      
      private function update() : void
      {
         if(this.ui_weapon.parent != null)
         {
            this.ui_weapon.parent.removeChild(this.ui_weapon);
         }
         if(this.ui_gearActive.parent != null)
         {
            this.ui_gearActive.parent.removeChild(this.ui_gearActive);
         }
         TooltipManager.getInstance().removeAllFromParent(this);
         this.ui_portrait.survivor = this._survivor;
         this.ui_health.survivor = this._survivor;
         this.ui_weapon.filters = [OUTLINE];
         this.ui_weapon.item = this._survivor.activeLoadout.weapon.item;
         addChild(this.ui_weapon);
         var _loc1_:Gear = this._survivor.activeLoadout.gearActive.item as Gear;
         if(_loc1_ != null)
         {
            this.ui_gearActive.filters = [OUTLINE];
            this.ui_gearActive.item = this._survivor.activeLoadout.gearActive.item;
            this.ui_gearActive.quantity = this._survivor.activeLoadout.gearActive.quantity;
            addChild(this.ui_gearActive);
         }
         this.updateHealth();
         this.updateItemTooltips();
         this.updateCoverRating();
      }
      
      private function updateItemTooltips() : void
      {
         var _loc1_:* = null;
         if(Weapon(this.ui_weapon.item).weaponClass == WeaponClass.MELEE)
         {
            _loc1_ = "<p align=\'center\'>" + this.ui_weapon.item.getName() + "<br/>" + Language.getInstance().getString("tooltip.ctrl_for_info") + "</p>";
         }
         else
         {
            _loc1_ = "<p align=\'center\'>" + this.ui_weapon.item.getName() + "<br/>" + Language.getInstance().getString("tooltip.click_to_reload") + "</p>";
         }
         TooltipManager.getInstance().add(this.ui_weapon,_loc1_,new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
         var _loc2_:Gear = this._survivor.activeLoadout != null ? this._survivor.activeLoadout.gearActive.item as Gear : null;
         if(_loc2_ != null)
         {
            _loc1_ = "<p align=\'center\'>" + _loc2_.getName() + " x " + this._survivor.activeLoadout.gearActive.quantity + "<br/>" + Language.getInstance().getString("tooltip.right_click_to_use") + "</p>";
            TooltipManager.getInstance().add(this.ui_gearActive,_loc1_,new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
         }
         else
         {
            TooltipManager.getInstance().remove(this.ui_gearActive);
         }
      }
      
      private function updateHealth() : void
      {
         this.ui_health.visible = this._survivor.injuries.length > 0 || this.ui_health.progress > 0 && this.ui_health.progress < 1;
      }
      
      private function updateCoverRating() : void
      {
         var _loc1_:int = this._survivor.agentData.coverRating;
         if(_loc1_ <= 0)
         {
            this.bmp_cover.visible = false;
         }
         else
         {
            this.bmp_cover.visible = true;
            this.bmp_cover.bitmapData = CoverData.getCoverIconSmall(_loc1_);
         }
      }
      
      private function onActiveGearChanged(param1:SurvivorLoadoutData, param2:Item = null, param3:Item = null) : void
      {
         this.ui_gearActive.quantity = param1.quantity;
         this.updateItemTooltips();
         if(param1.quantity <= 0)
         {
            TweenMax.to(this.ui_gearActive,0.1,{"colorMatrixFilter":{
               "saturation":0,
               "brightness":0.5,
               "overwrite":true
            }});
            this._survivor.activeLoadout.gearActive.changed.remove(this.onActiveGearChanged);
         }
      }
      
      private function onCoverRatingChanged() : void
      {
         this.updateCoverRating();
      }
      
      private function onHealthChanged(param1:Survivor) : void
      {
         this.updateHealth();
      }
      
      private function onHealingStarted(param1:Survivor) : void
      {
         this.bmp_healing.visible = true;
      }
      
      private function onHealingCompleted(param1:Survivor) : void
      {
         this.bmp_healing.visible = false;
      }
      
      private function onDamageReceived(param1:Survivor, param2:Number, param3:Object, param4:Boolean) : void
      {
         if(param2 > 0)
         {
            this.ui_portrait.filters = [];
            TweenMax.from(this.ui_portrait,1,{"colorMatrixFilter":{
               "colorize":13369344,
               "brightness":2,
               "amount":1,
               "remove":true,
               "overwrite":true
            }});
         }
         this.updateHealth();
      }
      
      private function onSurvivorDied(param1:Survivor, param2:Object) : void
      {
         this._survivor.damageTaken.remove(this.onDamageReceived);
         this._survivor.healingStarted.remove(this.onHealingStarted);
         this._survivor.healingCompleted.remove(this.onHealingCompleted);
         this.bmp_healing.visible = false;
         this.bmp_cover.visible = false;
         this.bmp_inExitZone.visible = false;
         TweenMax.to(this.ui_portrait,0,{"colorMatrixFilter":{
            "saturation":0,
            "remove":true
         }});
         TweenMax.to(this.ui_portrait,0.5,{
            "delay":0.01,
            "colorMatrixFilter":{
               "saturation":0,
               "brightness":0.5,
               "overwrite":true
            }
         });
      }
      
      private function onClickPortrait(param1:MouseEvent) : void
      {
         this.portraitClicked.dispatch(this);
      }
      
      private function onClickWeapon(param1:MouseEvent) : void
      {
         this.weaponClicked.dispatch(this);
      }
      
      private function onClickActiveGear(param1:MouseEvent) : void
      {
         if(this._survivor.activeLoadout.gearActive.item != null && this._survivor.activeLoadout.gearActive.quantity > 0)
         {
            this.gearActiveClicked.dispatch(this);
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyPress,false,0,true);
         stage.addEventListener(KeyboardEvent.KEY_UP,this.onKeyRelease,false,0,true);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyPress);
         stage.removeEventListener(KeyboardEvent.KEY_UP,this.onKeyRelease);
      }
      
      private function onKeyPress(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.CONTROL)
         {
            this.setCurrentItemInfo();
            if(this.ui_itemInfo.item != null)
            {
               this.ui_itemInfo.show(this._mouseOverItem);
            }
         }
      }
      
      private function onKeyRelease(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.CONTROL)
         {
            this.hideCurrentItemInfo();
         }
      }
      
      private function onItemInfoAddedToStage(param1:Event) : void
      {
         TooltipManager.getInstance().hide();
      }
      
      private function onMouseOverItem(param1:MouseEvent) : void
      {
         var _loc2_:UIItemImage = param1.currentTarget as UIItemImage;
         this._mouseOverItem = _loc2_;
         if(_loc2_ == null)
         {
            this.ui_itemInfo.setItem(null);
            return;
         }
         this.setCurrentItemInfo();
      }
      
      private function onMouseOutItem(param1:MouseEvent) : void
      {
         this._mouseOverItem = null;
         this.ui_itemInfo.setItem(null);
         this.ui_itemInfo.hide();
      }
   }
}

