package thelaststand.app.game.gui.map
{
   import com.greensock.TweenMax;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.gui.UIImage;
   
   public class UIMapFilterButton extends Sprite
   {
      
      private var _enabled:Boolean = true;
      
      private var _selected:Boolean;
      
      private var _type:String;
      
      private var mc_background:LoadoutSlotBase;
      
      private var mc_image:UIImage;
      
      public function UIMapFilterButton()
      {
         super();
         buttonMode = true;
         mouseChildren = false;
         this.mc_background = new LoadoutSlotBase();
         addChild(this.mc_background);
         this.mc_image = new UIImage(32,32,0,0);
         this.mc_image.x = this.mc_image.y = 1;
         addChild(this.mc_image);
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
         removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         this.mc_image.dispose();
         this.mc_image = null;
         if(contains(this.mc_background))
         {
            removeChild(this.mc_background);
         }
         this.mc_background = null;
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         Audio.sound.play("sound/interface/int-over.mp3");
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
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
            TweenMax.to(this.mc_image,0.15,{"glowFilter":{
               "color":16777215,
               "alpha":1,
               "blurX":4,
               "blurY":4,
               "strength":10,
               "quality":1
            }});
         }
         else
         {
            TweenMax.to(this.mc_image,0.25,{"glowFilter":{
               "alpha":0,
               "remove":true
            }});
         }
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function set type(param1:String) : void
      {
         this._type = param1;
         this.mc_image.uri = "images/items/" + this._type + ".jpg";
      }
   }
}

