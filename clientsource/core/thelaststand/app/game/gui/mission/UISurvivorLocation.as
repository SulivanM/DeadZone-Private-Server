package thelaststand.app.game.gui.mission
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.geom.Point;
   import org.osflash.signals.natives.NativeSignal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.gui.UISurvivorPortrait;
   import thelaststand.app.game.gui.survivor.UISurvivorHealthBarLarge;
   
   public class UISurvivorLocation extends Sprite
   {
      
      private static const BMP_HEALING:BitmapData = new BmpIconHealing();
      
      public static const DIR_TOP:String = "t";
      
      public static const DIR_TOP_LEFT:String = "tl";
      
      public static const DIR_TOP_RIGHT:String = "tr";
      
      public static const DIR_RIGHT:String = "r";
      
      public static const DIR_BOTTOM_RIGHT:String = "br";
      
      public static const DIR_BOTTOM:String = "b";
      
      public static const DIR_BOTTOM_LEFT:String = "lb";
      
      public static const DIR_LEFT:String = "l";
      
      private const COLOR_HEALTH_GOOD:uint = 5692748;
      
      private const COLOR_HEALTH_BAD:uint = 15597568;
      
      private var _dir:String;
      
      private var _survivor:Survivor;
      
      private var bmp_healing:Bitmap;
      
      private var mc_background:UISurvivorLocationBackground;
      
      private var mc_portrait:UISurvivorPortrait;
      
      private var mc_healthBar:UISurvivorHealthBarLarge;
      
      public var clicked:NativeSignal;
      
      public var targetPoint:Point;
      
      public function UISurvivorLocation(param1:Survivor)
      {
         super();
         mouseChildren = false;
         buttonMode = true;
         this._survivor = param1;
         this._survivor.healthChanged.add(this.onHealthChanged);
         this._survivor.healingStarted.add(this.onHealingStarted);
         this._survivor.healingCompleted.add(this.onHealingCompleted);
         this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
         this.targetPoint = new Point();
         this.mc_background = new UISurvivorLocationBackground();
         this.mc_background.x = -int(this.mc_background.width * 0.5);
         this.mc_background.y = -int(this.mc_background.height * 0.5);
         this.mc_background.filters = [new DropShadowFilter(1,45,0,1,6,6,0.8,2)];
         addChild(this.mc_background);
         this.mc_portrait = new UISurvivorPortrait(UISurvivorPortrait.SIZE_40x40,4210752);
         this.mc_portrait.x = int(this.mc_background.x + 2);
         this.mc_portrait.y = int(this.mc_background.y + 2);
         this.mc_portrait.survivor = param1;
         addChild(this.mc_portrait);
         this.mc_healthBar = new UISurvivorHealthBarLarge(this._survivor);
         this.mc_healthBar.width = int(this.mc_portrait.width - 8);
         this.mc_healthBar.x = int(this.mc_background.x + (this.mc_background.width - this.mc_healthBar.width) * 0.5);
         this.mc_healthBar.y = int(this.mc_background.y + (this.mc_background.height - this.mc_healthBar.height - (this.mc_healthBar.x - this.mc_background.x)));
         addChild(this.mc_healthBar);
         this.bmp_healing = new Bitmap(BMP_HEALING);
         this.bmp_healing.x = int(this.mc_background.x + 2);
         this.bmp_healing.y = int(this.mc_healthBar.y - this.bmp_healing.height - 2);
         this.setDirection(DIR_RIGHT);
         this.onHealthChanged(null);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      }
      
      public function alert(param1:uint, param2:Number = 1) : void
      {
         TweenMax.killTweensOf(this.mc_portrait);
         this.mc_portrait.filters = [];
         TweenMax.from(this.mc_portrait,param2,{"colorMatrixFilter":{
            "colorize":param1,
            "brightness":2,
            "amount":1,
            "remove":true
         }});
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         TweenMax.killTweensOf(this.mc_portrait);
         this._survivor.healthChanged.remove(this.onHealthChanged);
         this._survivor.healingStarted.remove(this.onHealingStarted);
         this._survivor.healingCompleted.remove(this.onHealingCompleted);
         this._survivor = null;
         this.clicked.removeAll();
         this.mc_portrait.dispose();
         this.mc_healthBar.dispose();
         this.targetPoint = null;
         this.bmp_healing.bitmapData = null;
      }
      
      public function setDirection(param1:String) : void
      {
         if(param1 == this._dir)
         {
            return;
         }
         this._dir = param1;
         var _loc2_:int = this.mc_background.width * 0.5;
         var _loc3_:int = this.mc_background.height * 0.5;
         switch(this._dir)
         {
            case DIR_TOP_LEFT:
               this.targetPoint.x = _loc2_;
               this.targetPoint.y = _loc3_;
               break;
            case DIR_TOP:
               this.targetPoint.x = 0;
               this.targetPoint.y = _loc3_;
               break;
            case DIR_TOP_RIGHT:
               this.targetPoint.x = -_loc2_;
               this.targetPoint.y = _loc3_;
               break;
            case DIR_RIGHT:
               this.targetPoint.x = -_loc2_;
               this.targetPoint.y = 0;
               break;
            case DIR_BOTTOM_RIGHT:
               this.targetPoint.x = -_loc2_;
               this.targetPoint.y = -_loc3_;
               break;
            case DIR_BOTTOM:
               this.targetPoint.x = 0;
               this.targetPoint.y = -_loc3_;
               break;
            case DIR_BOTTOM_LEFT:
               this.targetPoint.x = _loc2_;
               this.targetPoint.y = -_loc3_;
               break;
            case DIR_LEFT:
               this.targetPoint.x = _loc2_;
               this.targetPoint.y = 0;
         }
      }
      
      private function onHealthChanged(param1:Survivor) : void
      {
         this.mc_healthBar.visible = this._survivor.injuries.length > 0 || this.mc_healthBar.progress > 0 && this.mc_healthBar.progress < 1;
      }
      
      private function onHealingStarted(param1:Survivor) : void
      {
         this.bmp_healing.visible = true;
      }
      
      private function onHealingCompleted(param1:Survivor) : void
      {
         this.bmp_healing.visible = false;
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         Audio.sound.play("sound/interface/int-click.mp3");
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.onHealthChanged(this._survivor);
      }
   }
}

