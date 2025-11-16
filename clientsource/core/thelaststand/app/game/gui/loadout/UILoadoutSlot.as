package thelaststand.app.game.gui.loadout
{
   import com.greensock.TweenMax;
   import com.quasimondo.geom.ColorMatrix;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import org.osflash.signals.natives.NativeSignal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.game.data.Gear;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.SurvivorLoadoutData;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.gui.UIItemImage;
   
   public class UILoadoutSlot extends LoadoutSlotBase
   {
      
      private static const BMP_GEAR:BitmapData = new BmpIconLoadoutGear();
      
      private static const BMP_GEAR_READONLY:BitmapData = new BmpIconLoadoutGearNoPlus();
      
      private static const BMP_LOCKED:BitmapData = new BmpIconLoadoutLocked();
      
      private static const BMP_WEAPON:BitmapData = new BmpIconLoadoutWeapon();
      
      private static const BMP_WEAPON_READONLY:BitmapData = new BmpIconLoadoutWeaponNoPlus();
      
      private static const BMP_SPECIALIZED:BitmapData = new BmpIconSpecialized();
      
      private static const STROKE_INEFFECTIVE:GlowFilter = new GlowFilter(8978432,1,4,4,5,1);
      
      private static const COLOR_INEFFECTIVE:ColorMatrix = new ColorMatrix();
      
      COLOR_INEFFECTIVE.colorize(13369344,1);
      COLOR_INEFFECTIVE.adjustBrightness(0.75);
      
      private var _enabled:Boolean = true;
      
      private var _locked:Boolean;
      
      private var _loadoutData:SurvivorLoadoutData;
      
      private var _readOnly:Boolean;
      
      private var bmp_typeIcon:Bitmap;
      
      private var bmp_specialized:Bitmap;
      
      private var mc_itemIcon:UIItemImage;
      
      public var clicked:NativeSignal;
      
      public var mouseOver:NativeSignal;
      
      public function UILoadoutSlot(param1:Boolean = false)
      {
         super();
         mouseChildren = false;
         this._readOnly = param1;
         this.mc_itemIcon = new UIItemImage(32,32);
         this.mc_itemIcon.x = this.mc_itemIcon.y = 1;
         this.mc_itemIcon.showQuantity = true;
         this.mc_itemIcon.quantityFieldSize = 12;
         addChild(this.mc_itemIcon);
         this.bmp_typeIcon = new Bitmap();
         addChild(this.bmp_typeIcon);
         this.bmp_specialized = new Bitmap(BMP_SPECIALIZED);
         this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
         this.mouseOver = new NativeSignal(this,MouseEvent.MOUSE_OVER,MouseEvent);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         TweenMax.killChildTweensOf(this);
         if(this._loadoutData != null)
         {
            this._loadoutData.changed.remove(this.onLoadoutChanged);
            this._loadoutData = null;
         }
         this.clicked.removeAll();
         this.mouseOver.removeAll();
         this.bmp_typeIcon.bitmapData = null;
         this.bmp_typeIcon = null;
         this.bmp_specialized.bitmapData = null;
         this.bmp_specialized = null;
         this.mc_itemIcon.dispose();
         this.mc_itemIcon = null;
      }
      
      private function updateIcon() : void
      {
         if(this._locked)
         {
            this.bmp_typeIcon.bitmapData = BMP_LOCKED;
         }
         else if(this._loadoutData == null)
         {
            this.bmp_typeIcon.bitmapData = null;
         }
         else
         {
            switch(this._loadoutData.type)
            {
               case SurvivorLoadout.SLOT_WEAPON:
                  this.bmp_typeIcon.bitmapData = this._readOnly ? BMP_WEAPON_READONLY : BMP_WEAPON;
                  break;
               case SurvivorLoadout.SLOT_GEAR_PASSIVE:
               case SurvivorLoadout.SLOT_GEAR_ACTIVE:
                  this.bmp_typeIcon.bitmapData = this._readOnly ? BMP_GEAR_READONLY : BMP_GEAR;
                  break;
               default:
                  this.bmp_typeIcon.bitmapData = null;
            }
         }
         this.bmp_typeIcon.x = Math.round(mc_slot.x + (mc_slot.width - this.bmp_typeIcon.width) * 0.5);
         this.bmp_typeIcon.y = Math.round(mc_slot.y + (mc_slot.height - this.bmp_typeIcon.height) * 0.5);
      }
      
      private function onLoadoutChanged(param1:SurvivorLoadoutData, param2:Item = null, param3:Item = null) : void
      {
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         if(this._loadoutData != null && this._loadoutData.item != null)
         {
            this.bmp_typeIcon.visible = false;
            this.mc_itemIcon.item = this._loadoutData.item;
            this.mc_itemIcon.quantity = this._loadoutData.quantity;
            this.mc_itemIcon.showQuantity = this._loadoutData.item.quantifiable;
            _loc4_ = this._loadoutData.item is Gear ? Gear(this._loadoutData.item).supportsWeapon(this._loadoutData.loadout.weapon.item as Weapon) : true;
            this.mc_itemIcon.filters = _loc4_ ? [] : [STROKE_INEFFECTIVE,COLOR_INEFFECTIVE.filter];
            _loc5_ = this._loadoutData.item is Weapon ? this._loadoutData.loadout.survivor.sClass.isSpecialisedWithWeapon(Weapon(this._loadoutData.item)) : false;
            if(_loc5_)
            {
               addChild(this.bmp_specialized);
               this.bmp_specialized.x = int(width - this.bmp_specialized.width - 2);
               this.bmp_specialized.y = int(height - this.bmp_specialized.height - 2);
            }
            else if(this.bmp_specialized.parent != null)
            {
               this.bmp_specialized.parent.removeChild(this.bmp_specialized);
            }
         }
         else
         {
            this.bmp_typeIcon.visible = true;
            this.mc_itemIcon.item = null;
            this.mc_itemIcon.showQuantity = false;
            this.mc_itemIcon.filters = [];
            if(this.bmp_specialized.parent != null)
            {
               this.bmp_specialized.parent.removeChild(this.bmp_specialized);
            }
         }
         this.updateIcon();
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         TweenMax.to(mc_glow,0,{"colorTransform":{"exposure":1.05}});
         if(this._loadoutData == null)
         {
            Audio.sound.play("sound/interface/int-over.mp3");
         }
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         TweenMax.to(mc_glow,0.25,{"colorTransform":{"exposure":1}});
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(this._readOnly)
         {
            return;
         }
         TweenMax.to(this.mc_itemIcon,0,{"colorTransform":{"exposure":1.1}});
         TweenMax.to(this.mc_itemIcon,0.25,{
            "delay":0.01,
            "colorTransform":{"exposure":1}
         });
         Audio.sound.play("sound/interface/int-click.mp3");
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
         mouseEnabled = this._enabled;
         alpha = this._enabled ? 1 : 0.3;
      }
      
      public function get loadoutData() : SurvivorLoadoutData
      {
         return this._loadoutData;
      }
      
      public function set loadoutData(param1:SurvivorLoadoutData) : void
      {
         if(this._loadoutData != null)
         {
            this._loadoutData.changed.remove(this.onLoadoutChanged);
         }
         this._loadoutData = param1;
         if(this._loadoutData != null)
         {
            this._loadoutData.changed.add(this.onLoadoutChanged);
         }
         this.onLoadoutChanged(this._loadoutData);
      }
      
      public function get locked() : Boolean
      {
         return this._locked;
      }
      
      public function set locked(param1:Boolean) : void
      {
         this._locked = param1;
         this.updateIcon();
      }
   }
}

