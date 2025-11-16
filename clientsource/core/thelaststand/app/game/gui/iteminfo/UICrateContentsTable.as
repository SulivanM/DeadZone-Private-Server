package thelaststand.app.game.gui.iteminfo
{
   import flash.display.Sprite;
   import thelaststand.app.display.BodyTextField;
   
   public class UICrateContentsTable extends Sprite
   {
      
      private var _ty:int;
      
      private var _rowCount:int = 0;
      
      private var _rowColor:uint = 2763563;
      
      private var _rowHeight:int = 20;
      
      private var _width:int;
      
      public function UICrateContentsTable(param1:int)
      {
         super();
         this._width = param1;
         mouseEnabled = mouseChildren = false;
      }
      
      public function addRow(param1:String, param2:uint) : void
      {
         if(this._rowCount % 2 == 0)
         {
            graphics.beginFill(this._rowColor);
            graphics.drawRect(0,this._ty,this._width,this._rowHeight);
            graphics.endFill();
         }
         var _loc3_:BodyTextField = new BodyTextField({
            "color":param2,
            "size":14,
            "autoSize":"none",
            "align":"center",
            "width":this._width
         });
         _loc3_.htmlText = param1;
         _loc3_.x = 2;
         _loc3_.y = this._ty - 1;
         _loc3_.maxWidth = this._width;
         addChild(_loc3_);
         ++this._rowCount;
         this._ty += this._rowHeight;
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         var _loc1_:int = numChildren - 1;
         while(_loc1_ >= 0)
         {
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

