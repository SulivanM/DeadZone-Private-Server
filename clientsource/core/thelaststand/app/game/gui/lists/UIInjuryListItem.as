package thelaststand.app.game.gui.lists
{
   import com.greensock.TweenMax;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.injury.Injury;
   import thelaststand.app.game.data.injury.InjurySeverity;
   import thelaststand.common.lang.Language;
   
   public class UIInjuryListItem extends UIPagedListItem
   {
      
      internal static const COLOR_NORMAL:int = 2434341;
      
      internal static const COLOR_ALT:int = 1447446;
      
      internal static const COLOR_SELECTED:int = 5000268;
      
      internal static const COLOR_OVER:int = 3158064;
      
      private var _alternating:Boolean;
      
      private var _injury:Injury;
      
      private var _lang:Language;
      
      private var mc_background:Sprite;
      
      private var txt_title:BodyTextField;
      
      private var mc_severity:Shape;
      
      public function UIInjuryListItem()
      {
         super();
         _width = 184;
         _height = 27;
         this._lang = Language.getInstance();
         this.mc_background = new Sprite();
         this.mc_background.mouseEnabled = false;
         this.mc_background.graphics.clear();
         this.mc_background.graphics.beginFill(COLOR_NORMAL);
         this.mc_background.graphics.drawRect(0,0,_width,_height);
         this.mc_background.graphics.endFill();
         addChild(this.mc_background);
         this.mc_severity = new Shape();
         this.mc_severity.filters = [Effects.ICON_SHADOW];
         addChild(this.mc_severity);
         this.txt_title = new BodyTextField({
            "text":" ",
            "color":11250603,
            "size":12,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_title.x = int(this.mc_background.x + 20);
         this.txt_title.y = int(this.mc_background.y + (this.mc_background.height - this.txt_title.height) * 0.5);
         addChild(this.txt_title);
         hitArea = this.mc_background;
      }
      
      public function get injury() : Injury
      {
         return this._injury;
      }
      
      public function set injury(param1:Injury) : void
      {
         if(this._injury != null)
         {
            removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
            removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         }
         this._injury = param1;
         if(this._injury != null)
         {
            this.mc_severity.visible = true;
            this.mc_severity.graphics.beginFill(InjurySeverity.getColor(this._injury.severity));
            this.mc_severity.graphics.drawRect(0,0,10,10);
            this.mc_severity.graphics.endFill();
            this.mc_severity.y = int((_height - this.mc_severity.height) * 0.5);
            this.mc_severity.x = int(this.mc_severity.y);
            this.txt_title.text = this._injury.getName().toUpperCase();
            this.txt_title.x = int(this.mc_severity.x + this.mc_severity.width + 6);
            this.txt_title.visible = true;
            addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
            addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
            addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         }
         else
         {
            this.mc_severity.visible = this.txt_title.visible = false;
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
            TweenMax.killTweensOf(this.mc_background);
            _loc2_ = this.mc_background.transform.colorTransform;
            _loc2_.color = this.getBackgroundColor();
            this.mc_background.transform.colorTransform = _loc2_;
         }
      }
      
      override public function set selected(param1:Boolean) : void
      {
         if(this._injury == null)
         {
            param1 = false;
         }
         super.selected = param1;
         TweenMax.killTweensOf(this.mc_background);
         var _loc2_:ColorTransform = this.mc_background.transform.colorTransform;
         _loc2_.color = this.getBackgroundColor();
         this.mc_background.transform.colorTransform = _loc2_;
         this.txt_title.textColor = super.selected ? 16777215 : 11250603;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._injury = null;
         this._lang = null;
         this.txt_title.dispose();
         this.mc_severity.filters = [];
      }
      
      private function getBackgroundColor() : uint
      {
         return selected ? uint(COLOR_SELECTED) : (this._alternating ? uint(COLOR_ALT) : uint(COLOR_NORMAL));
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(selected)
         {
            return;
         }
         TweenMax.to(this.mc_background,0,{"tint":COLOR_OVER});
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(selected)
         {
            return;
         }
         TweenMax.to(this.mc_background,0,{"tint":this.getBackgroundColor()});
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(selected)
         {
            return;
         }
         Audio.sound.play("sound/interface/int-click.mp3");
      }
   }
}

