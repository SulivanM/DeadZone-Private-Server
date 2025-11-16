package thelaststand.app.game.gui.loadout
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.MouseEvent;
   import org.osflash.signals.natives.NativeSignal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.gui.UISurvivorPortrait;
   
   public class UILoadoutPortrait extends LoadoutSlotBase
   {
      
      private static const BMP_ADD:BitmapData = new BmpIconLoadoutSurvivor();
      
      private var _enabled:Boolean = true;
      
      private var _survivor:Survivor;
      
      private var bmp_addIcon:Bitmap;
      
      private var ui_portrait:UISurvivorPortrait;
      
      public var clicked:NativeSignal;
      
      public var mouseOver:NativeSignal;
      
      public function UILoadoutPortrait(param1:String = "38x38", param2:Boolean = true)
      {
         super();
         mouseChildren = false;
         this.ui_portrait = new UISurvivorPortrait(param1,1973790);
         this.ui_portrait.x = this.ui_portrait.y = 1;
         addChild(this.ui_portrait);
         mc_slot.width = mc_glow.width = mc_shadow.width = this.ui_portrait.width + 2;
         mc_slot.height = mc_glow.height = mc_shadow.height = this.ui_portrait.height + 2;
         this.bmp_addIcon = new Bitmap(BMP_ADD);
         this.bmp_addIcon.x = int(mc_slot.x + (mc_slot.width - this.bmp_addIcon.width) * 0.5 + 2);
         this.bmp_addIcon.y = int(mc_slot.y + (mc_slot.height - this.bmp_addIcon.height) * 0.5 + 1);
         this.bmp_addIcon.alpha = 0.5;
         if(param2)
         {
            addChild(this.bmp_addIcon);
         }
         this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
         this.mouseOver = new NativeSignal(this,MouseEvent.MOUSE_OVER,MouseEvent);
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
         TweenMax.killChildTweensOf(this);
         this._survivor = null;
         this.clicked.removeAll();
         this.mouseOver.removeAll();
         this.bmp_addIcon.bitmapData = null;
         this.ui_portrait.dispose();
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         TweenMax.to(mc_glow,0,{"colorTransform":{"exposure":1.05}});
         if(this._survivor == null)
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
         TweenMax.to(this.bmp_addIcon,0,{"colorTransform":{"exposure":1.1}});
         TweenMax.to(this.bmp_addIcon,0.25,{
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
         this.bmp_addIcon.visible = this._survivor == null && this._enabled;
      }
      
      public function get survivor() : Survivor
      {
         return this._survivor;
      }
      
      public function set survivor(param1:Survivor) : void
      {
         this._survivor = param1;
         this.ui_portrait.survivor = this._survivor;
         this.bmp_addIcon.visible = this._survivor == null && this._enabled;
      }
   }
}

