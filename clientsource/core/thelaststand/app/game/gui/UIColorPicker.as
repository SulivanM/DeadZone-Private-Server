package thelaststand.app.game.gui
{
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import org.osflash.signals.Signal;
   import thelaststand.app.gui.buttons.PushButton;
   
   public class UIColorPicker extends Sprite
   {
      
      public var onChange:Signal;
      
      private var _icon:Shape;
      
      private var _btn:PushButton;
      
      private var _grid:ColorGrid;
      
      private var _stage:Stage;
      
      private var _colorTransform:ColorTransform;
      
      public function UIColorPicker()
      {
         super();
         this.onChange = new Signal(int,uint);
         this._colorTransform = new ColorTransform();
         this._icon = new Shape();
         this._icon.graphics.beginFill(16777215);
         this._icon.graphics.drawRect(0,0,20,20);
         this._btn = new PushButton("",this._icon);
         this._btn.clicked.add(this.onButtonClicked);
         addChild(this._btn);
         this.width = this._btn.width;
         this.height = this._btn.height;
         this._grid = new ColorGrid();
         this._grid.onChange.add(this.onGridChange);
         this._grid.onSelect.add(this.onGridSelect);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this._btn.dispose();
         this._grid.dispose();
         this.onChange.removeAll();
      }
      
      private function onButtonClicked(param1:MouseEvent) : void
      {
         this.showGrid();
      }
      
      private function showGrid() : void
      {
         this._stage = stage;
         this._stage.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,true,100,true);
         this._stage.addEventListener(Event.RESIZE,this.onStageResize,false,0,true);
         this._stage.addChild(this._grid);
         this.onStageResize();
      }
      
      private function hideGrid() : void
      {
         this._stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,true);
         this._stage.removeEventListener(Event.RESIZE,this.onStageResize);
         if(this._grid.parent)
         {
            this._grid.parent.removeChild(this._grid);
         }
      }
      
      private function onStageResize(param1:Event = null) : void
      {
         var _loc2_:Point = new Point();
         _loc2_.x = this._btn.width + 2;
         _loc2_.y = int(this._btn.y + (this._btn.height - this._grid.height) * 0.5);
         _loc2_ = localToGlobal(_loc2_);
         this._grid.x = _loc2_.x;
         this._grid.y = _loc2_.y;
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(!(param1.target == this._grid || Boolean(this._grid.contains(param1.target as DisplayObject))))
         {
            this.hideGrid();
            param1.stopImmediatePropagation();
         }
      }
      
      private function onGridChange(param1:int, param2:uint) : void
      {
         this.onChange.dispatch(param1,param2);
         this.changeSwatchColor(param2);
      }
      
      private function onGridSelect(param1:int, param2:uint) : void
      {
         this.onChange.dispatch(param1,param2);
         this.changeSwatchColor(param2);
         this.hideGrid();
      }
      
      private function changeSwatchColor(param1:uint) : void
      {
         this._colorTransform.color = param1;
         this._icon.transform.colorTransform = this._colorTransform;
      }
      
      override public function get width() : Number
      {
         return this._btn.width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._icon.width = param1 - 6;
         this._btn.width = param1;
      }
      
      override public function get height() : Number
      {
         return this._btn.height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._icon.height = param1 - 6;
         this._btn.height = param1;
      }
      
      public function get showBorder() : Boolean
      {
         return this._btn.showBorder;
      }
      
      public function set showBorder(param1:Boolean) : void
      {
         this._btn.showBorder = param1;
      }
      
      public function get selectedIndex() : int
      {
         return this._grid.selectedIndex;
      }
      
      public function set selectedIndex(param1:int) : void
      {
         this._grid.selectedIndex = param1;
         this.changeSwatchColor(this._grid.selectedColor);
      }
   }
}

import com.exileetiquette.math.MathUtils;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import org.osflash.signals.Signal;

class ColorGrid extends Sprite
{
   
   public var onSelect:Signal;
   
   public var onChange:Signal;
   
   private var _paletteClass:Class;
   
   private var _swatchContainer:Sprite;
   
   private var _swatches:Vector.<ColorSwatch>;
   
   private var _highlight:Shape;
   
   private var _selectedIndex:int = 0;
   
   public function ColorGrid()
   {
      var _loc7_:int = 0;
      var _loc8_:ColorSwatch = null;
      this._paletteClass = ColorGrid__paletteClass;
      this._swatches = new Vector.<ColorSwatch>();
      super();
      this.onSelect = new Signal(int,uint);
      this.onChange = new Signal(int,uint);
      this._swatchContainer = new Sprite();
      addChild(this._swatchContainer);
      var _loc1_:int = 8;
      var _loc2_:int = 0;
      var _loc3_:int = 0;
      var _loc4_:int = 0;
      var _loc5_:BitmapData = Bitmap(new this._paletteClass()).bitmapData;
      var _loc6_:int = 0;
      while(_loc6_ < _loc5_.height)
      {
         _loc7_ = 0;
         while(_loc7_ < _loc5_.width)
         {
            _loc8_ = new ColorSwatch(_loc4_,_loc5_.getPixel(_loc7_,_loc6_));
            _loc8_.x = 1 + _loc2_ * (_loc8_.width + 1);
            _loc8_.y = 1 + _loc3_ * (_loc8_.height + 1);
            _loc8_.onOver.add(this.onSwatchOver);
            _loc8_.onSelect.add(this.onSwatchSelect);
            this._swatchContainer.addChild(_loc8_);
            this._swatches.push(_loc8_);
            _loc4_++;
            _loc2_ += 1;
            if(_loc2_ == _loc1_)
            {
               _loc2_ = 0;
               _loc3_ += 1;
            }
            _loc7_++;
         }
         _loc6_++;
      }
      this._swatchContainer.graphics.beginFill(4079166);
      this._swatchContainer.graphics.drawRect(0,0,this._swatchContainer.width + 2,this._swatchContainer.height + 2);
      this._swatchContainer.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
      this._highlight = new Shape();
      this._highlight.graphics.beginFill(16777215);
      this._highlight.graphics.drawRect(-1,-1,_loc8_.width + 2,_loc8_.height + 2);
      this._highlight.graphics.drawRect(0,0,_loc8_.width,_loc8_.height);
      addChild(this._highlight);
   }
   
   public function dispose() : void
   {
      var _loc1_:ColorSwatch = null;
      if(parent)
      {
         parent.removeChild(this);
      }
      for each(_loc1_ in this._swatches)
      {
         _loc1_.dispose();
      }
      this._swatches = null;
      this.onSelect.removeAll();
      this.onChange.removeAll();
   }
   
   private function onSwatchOver(param1:ColorSwatch) : void
   {
      this._highlight.x = param1.x;
      this._highlight.y = param1.y;
      this.onChange.dispatch(param1.index,param1.color);
   }
   
   private function onSwatchSelect(param1:ColorSwatch) : void
   {
      this.selectedIndex = param1.index;
      this.onSelect.dispatch(param1.index,param1.color);
   }
   
   private function onRollOut(param1:MouseEvent) : void
   {
      this.onSwatchOver(this._swatches[this._selectedIndex]);
   }
   
   public function get selectedIndex() : int
   {
      return this._selectedIndex;
   }
   
   public function set selectedIndex(param1:int) : void
   {
      this._selectedIndex = MathUtils.clamp(param1,0,this._swatches.length - 1);
      this._highlight.x = this._swatches[this._selectedIndex].x;
      this._highlight.y = this._swatches[this._selectedIndex].y;
   }
   
   public function get selectedColor() : uint
   {
      return this._swatches[this._selectedIndex].color;
   }
}

class ColorSwatch extends Sprite
{
   
   public var onOver:Signal;
   
   public var onSelect:Signal;
   
   public var index:int;
   
   public var color:int;
   
   public function ColorSwatch(param1:int, param2:int)
   {
      super();
      this.index = param1;
      this.color = param2;
      this.onOver = new Signal(ColorSwatch);
      this.onSelect = new Signal(ColorSwatch);
      graphics.beginFill(param2);
      graphics.drawRect(0,0,12,8);
      addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
      addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
   }
   
   public function dispose() : void
   {
      removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
      removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
      this.onOver.removeAll();
      this.onSelect.removeAll();
   }
   
   private function onMouseOver(param1:MouseEvent) : void
   {
      this.onOver.dispatch(this);
   }
   
   private function onMouseDown(param1:MouseEvent) : void
   {
      this.onSelect.dispatch(this);
   }
}
