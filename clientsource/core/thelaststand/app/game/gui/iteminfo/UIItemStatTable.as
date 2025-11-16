package thelaststand.app.game.gui.iteminfo
{
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import thelaststand.app.display.BodyTextField;
   
   public class UIItemStatTable extends Sprite
   {
      
      private var _ty:int;
      
      private var _rowCount:int = 0;
      
      private var _rowColor:uint = 2763563;
      
      private var _rowHeight:int = 20;
      
      private var _width:int;
      
      public function UIItemStatTable(param1:int)
      {
         super();
         this._width = param1;
         mouseEnabled = mouseChildren = false;
      }
      
      public function addRow(param1:String, param2:*, param3:uint, param4:Number = NaN, param5:uint = 0) : void
      {
         var _loc8_:ColorTransform = null;
         var _loc9_:Bitmap = null;
         if(this._rowCount % 2 == 0)
         {
            graphics.beginFill(this._rowColor);
            graphics.drawRect(0,this._ty,this._width,this._rowHeight);
            graphics.endFill();
         }
         var _loc6_:BodyTextField = new BodyTextField({
            "color":param3,
            "size":14
         });
         _loc6_.text = param1;
         _loc6_.x = 2;
         _loc6_.y = this._ty - 1;
         addChild(_loc6_);
         var _loc7_:BodyTextField = new BodyTextField({
            "color":param3,
            "size":14
         });
         _loc7_.text = String(param2);
         _loc7_.y = _loc6_.y;
         addChild(_loc7_);
         if(!isNaN(param4))
         {
            if(param4 != 0)
            {
               _loc8_ = new ColorTransform();
               _loc8_.color = param5;
               _loc9_ = new Bitmap(new BmpIconCompareArrow());
               _loc9_.x = int(this._width - _loc9_.width - 4);
               _loc9_.y = int(this._ty + (this._rowHeight - _loc9_.height) * 0.5);
               _loc9_.transform.colorTransform = _loc8_;
               addChild(_loc9_);
               if(param4 < 0)
               {
                  _loc9_.scaleY = -1;
                  _loc9_.y += _loc9_.height;
               }
            }
            _loc7_.x = int(this._width - 18 - _loc7_.width);
         }
         else
         {
            _loc7_.x = int(this._width - _loc7_.width - 2);
         }
         ++this._rowCount;
         this._ty += this._rowHeight;
      }
      
      public function dispose() : void
      {
         var _loc2_:DisplayObject = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
         var _loc1_:int = numChildren - 1;
         while(_loc1_ >= 0)
         {
            _loc2_ = getChildAt(_loc1_);
            if(_loc2_ is Bitmap)
            {
               Bitmap(_loc2_).bitmapData.dispose();
            }
            removeChildAt(_loc1_);
            _loc1_--;
         }
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
         return this._ty;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

