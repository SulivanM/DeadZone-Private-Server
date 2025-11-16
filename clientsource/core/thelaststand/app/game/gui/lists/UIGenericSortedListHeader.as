package thelaststand.app.game.gui.lists
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.text.AntiAliasType;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   
   public class UIGenericSortedListHeader extends Sprite
   {
      
      public static const ICON_ASCENDING:BitmapData = new BmpIconButtonUp();
      
      public static const ICON_DESCENDING:BitmapData = new BmpIconButtonDown();
      
      private static const COLOR_NORMAL:int = 2434341;
      
      private static const COLOR_OVER:int = 3158064;
      
      private static const COLOR_SELECTED:int = 5000268;
      
      private static const TEXT_NORMAL:int = 5987163;
      
      private static const TEXT_SELECTED:int = 16777215;
      
      private var _dir:int = -1;
      
      private var _selected:Boolean;
      
      private var _width:int = 100;
      
      private var _height:int = 24;
      
      private var mc_background:Sprite;
      
      private var bmp_arrow:Bitmap;
      
      private var txt_label:BodyTextField;
      
      public var data:*;
      
      public function UIGenericSortedListHeader(param1:String = "")
      {
         super();
         mouseChildren = false;
         buttonMode = true;
         this.mc_background = new Sprite();
         addChild(this.mc_background);
         this.bmp_arrow = new Bitmap(ICON_DESCENDING);
         this.bmp_arrow.visible = false;
         addChild(this.bmp_arrow);
         this.txt_label = new BodyTextField({
            "text":param1,
            "color":TEXT_NORMAL,
            "size":12,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_label.y = 4;
         addChild(this.txt_label);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         TweenMax.killChildTweensOf(this);
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this.bmp_arrow.bitmapData = null;
         this.bmp_arrow = null;
         this.txt_label.dispose();
      }
      
      private function draw() : void
      {
         if(!stage)
         {
            return;
         }
         this.mc_background.graphics.clear();
         this.mc_background.graphics.beginFill(COLOR_NORMAL);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         this.positionTextAndArrow();
      }
      
      private function positionTextAndArrow() : void
      {
         var _loc1_:int = 0;
         if(this._selected)
         {
            _loc1_ = this.txt_label.text == "" ? 0 : 4;
            this.txt_label.x = int((this._width - (this.txt_label.width + this.bmp_arrow.width + _loc1_)) * 0.5);
            this.bmp_arrow.x = this.txt_label.x + this.txt_label.width + _loc1_;
            this.bmp_arrow.y = int((this._height - this.bmp_arrow.height) * 0.5);
            this.bmp_arrow.visible = true;
         }
         else
         {
            this.txt_label.x = int((this._width - this.txt_label.width) * 0.5);
            this.bmp_arrow.visible = false;
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.draw();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(this.selected)
         {
            return;
         }
         var _loc2_:ColorTransform = new ColorTransform();
         _loc2_.color = COLOR_OVER;
         this.mc_background.transform.colorTransform = _loc2_;
         Audio.sound.play("sound/interface/int-over.mp3");
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(this.selected)
         {
            return;
         }
         var _loc2_:ColorTransform = new ColorTransform();
         _loc2_.color = COLOR_NORMAL;
         this.mc_background.transform.colorTransform = _loc2_;
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         TweenMax.to(this.mc_background,0,{"colorTransform":{"exposure":1.1}});
         Audio.sound.play("sound/interface/int-click.mp3");
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         TweenMax.to(this.mc_background,0.15,{"colorTransform":{"tint":(this._selected ? COLOR_SELECTED : COLOR_NORMAL)}});
      }
      
      public function get dir() : int
      {
         return this._dir;
      }
      
      public function set dir(param1:int) : void
      {
         this._dir = param1;
         this.bmp_arrow.bitmapData = this._dir == -1 ? ICON_DESCENDING : ICON_ASCENDING;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         this.draw();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
         this.draw();
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this._selected = param1;
         this.bmp_arrow.visible = this._selected;
         TweenMax.killTweensOf(this.mc_background);
         var _loc2_:ColorTransform = new ColorTransform();
         _loc2_.color = this._selected ? uint(COLOR_SELECTED) : uint(COLOR_NORMAL);
         this.mc_background.transform.colorTransform = _loc2_;
         this.txt_label.textColor = this._selected ? uint(TEXT_SELECTED) : uint(TEXT_NORMAL);
         this.positionTextAndArrow();
      }
      
      public function get label() : String
      {
         return this.txt_label.text;
      }
      
      public function set label(param1:String) : void
      {
         this.txt_label.text = param1;
         this.positionTextAndArrow();
      }
   }
}

