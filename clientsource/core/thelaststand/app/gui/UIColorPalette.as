package thelaststand.app.gui
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   
   public class UIColorPalette extends Sprite
   {
      
      private var _colors:Vector.<uint>;
      
      private var _selectedColor:uint;
      
      private var _swatches:Vector.<ColorSwatch>;
      
      private var _width:int = 260;
      
      private var _height:int = 26;
      
      private var mc_colors:Sprite;
      
      public var changed:Signal;
      
      public function UIColorPalette(param1:Vector.<uint>)
      {
         super();
         this._colors = param1;
         this._swatches = new Vector.<ColorSwatch>();
         this.changed = new Signal(UIColorPalette);
         this.updateColors();
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this._colors = null;
         this.changed.removeAll();
      }
      
      public function selectColor(param1:uint) : void
      {
         var _loc2_:ColorSwatch = null;
         this._selectedColor = param1;
         for each(_loc2_ in this._swatches)
         {
            _loc2_.selected = _loc2_.color == this._selectedColor;
         }
      }
      
      private function updateColors() : void
      {
         var _loc1_:ColorSwatch = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:uint = 0;
         for each(_loc1_ in this._swatches)
         {
            _loc1_.dispose();
         }
         this._swatches.length = 0;
         _loc2_ = 0;
         _loc3_ = 0;
         while(_loc3_ < this._colors.length)
         {
            _loc4_ = this._colors[_loc3_];
            _loc1_ = new ColorSwatch(_loc4_);
            _loc1_.addEventListener(MouseEvent.CLICK,this.onClickSwatch,false,0,true);
            _loc1_.x = _loc2_;
            _loc2_ += _loc1_.width + 5;
            this._swatches.push(_loc1_);
            addChild(_loc1_);
            _loc3_++;
         }
      }
      
      private function onClickSwatch(param1:MouseEvent) : void
      {
         var _loc2_:ColorSwatch = ColorSwatch(param1.currentTarget);
         this.selectColor(_loc2_.color);
         Audio.sound.play("sound/interface/int-click.mp3");
         this.changed.dispatch(this);
      }
      
      public function get colors() : Vector.<uint>
      {
         return this._colors;
      }
      
      public function set colors(param1:Vector.<uint>) : void
      {
         this._colors = param1;
         this.updateColors();
      }
      
      public function get selectedColor() : uint
      {
         return this._selectedColor;
      }
   }
}

import com.greensock.TweenMax;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;

class ColorSwatch extends Sprite
{
   
   private var _border:int = 2;
   
   private var _color:uint;
   
   private var _selected:Boolean;
   
   private var _width:int = 21;
   
   private var _height:int = 21;
   
   private var mc_background:Shape;
   
   private var mc_color:Shape;
   
   public function ColorSwatch(param1:uint)
   {
      super();
      this._color = param1;
      this.mc_background = new Shape();
      addChild(this.mc_background);
      this.mc_color = new Shape();
      this.mc_color.x = this.mc_color.y = this._border;
      this.mc_color.filters = [new GlowFilter(0,1,3,3,1,1,true)];
      addChild(this.mc_color);
      this.draw();
   }
   
   public function dispose() : void
   {
      if(parent != null)
      {
         parent.removeChild(this);
      }
   }
   
   private function draw() : void
   {
      this.mc_background.graphics.clear();
      this.mc_background.graphics.beginFill(7039594);
      this.mc_background.graphics.drawRect(0,0,this._width,this._height);
      this.mc_background.graphics.endFill();
      this.mc_color.graphics.clear();
      this.mc_color.graphics.beginFill(this._color);
      this.mc_color.graphics.drawRect(0,0,this._width - this._border * 2,this._height - this._border * 2);
      this.mc_color.graphics.endFill();
   }
   
   public function get selected() : Boolean
   {
      return this._selected;
   }
   
   public function set selected(param1:Boolean) : void
   {
      var _loc2_:ColorTransform = null;
      if(param1 == this._selected)
      {
         return;
      }
      this._selected = param1;
      if(stage)
      {
         TweenMax.to(this.mc_background,0.15,{"tint":(this._selected ? 268435455 : null)});
      }
      else
      {
         _loc2_ = new ColorTransform();
         if(this._selected)
         {
            _loc2_.color = 16777215;
         }
         this.mc_background.transform.colorTransform = _loc2_;
      }
   }
   
   public function get color() : uint
   {
      return this._color;
   }
}
