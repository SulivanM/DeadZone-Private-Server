package thelaststand.app.game.gui
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.gui.lists.UIInventoryListItem;
   
   public class UIMysteryItem extends Sprite
   {
      
      private static const BMP_MYSTERY_ICON:BitmapData = new BmpItemMystery();
      
      private static const SHADOW:DropShadowFilter = new DropShadowFilter(0,45,0,1,4,4,1,1);
      
      private const DEFAULT_STROKE_COLOR:uint = 3289650;
      
      private const STROKE:GlowFilter = new GlowFilter(this.DEFAULT_STROKE_COLOR,1,4,4,10,1);
      
      private const GLOW:GlowFilter = new GlowFilter(16777215,1,20,20,2,2);
      
      private var _item:Item;
      
      private var _size:uint;
      
      private var _isRevealed:Boolean;
      
      private var _borderSize:int = 2;
      
      private var _strokeColor:uint = 3289650;
      
      private var _childIndex:int = -1;
      
      private var _width:int;
      
      private var _height:int;
      
      private var mc_shape:Sprite;
      
      private var ui_item:UIItemImage;
      
      private var ui_mystery:Sprite;
      
      public var revealed:Signal = new Signal(UIMysteryItem);
      
      public function UIMysteryItem(param1:int, param2:Item = null)
      {
         super();
         this._item = param2;
         this._strokeColor = this._item != null ? uint(UIInventoryListItem.getStrokeColor(this._item)) : this.DEFAULT_STROKE_COLOR;
         mouseChildren = false;
         this.mc_shape = new Sprite();
         this.mc_shape.graphics.beginFill(0,1);
         this.mc_shape.graphics.drawRect(0,0,param1,param1);
         this.mc_shape.graphics.endFill();
         this.mc_shape.filters = [this.STROKE,SHADOW];
         addChild(this.mc_shape);
         var _loc3_:Bitmap = new Bitmap(BMP_MYSTERY_ICON,"auto",true);
         _loc3_.width = param1;
         _loc3_.height = param1;
         this.ui_mystery = new Sprite();
         this.ui_mystery.addChild(_loc3_);
         addChild(this.ui_mystery);
         this.ui_item = new UIItemImage(param1,param1);
         this.ui_item.item = this._item;
         this.ui_item.visible = false;
         addChild(this.ui_item);
         hitArea = this.mc_shape;
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      }
      
      public function get isRevealed() : Boolean
      {
         return this._isRevealed;
      }
      
      public function get item() : Item
      {
         return this._item;
      }
      
      public function set item(param1:Item) : void
      {
         this._item = param1;
         this._strokeColor = this._item != null ? uint(UIInventoryListItem.getStrokeColor(this._item)) : this.DEFAULT_STROKE_COLOR;
         this.ui_item.item = this._item;
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
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         TweenMax.killChildTweensOf(this);
         this.ui_item.dispose();
         this._item = null;
      }
      
      public function reveal() : void
      {
         var self:UIMysteryItem;
         if(this._isRevealed || this._item == null)
         {
            return;
         }
         this._isRevealed = true;
         self = this;
         TweenMax.to(this,1,{
            "colorTransform":{"exposure":2},
            "ease":Quad.easeOut,
            "onComplete":function():void
            {
               ui_mystery.visible = false;
               ui_item.visible = true;
               STROKE.color = _strokeColor;
            }
         });
         TweenMax.to(this.GLOW,0.95,{
            "delay":1,
            "blurX":0,
            "blurY":0,
            "onUpdate":function():void
            {
               mc_shape.filters = [STROKE,GLOW];
            }
         });
         TweenMax.to(this,1,{
            "delay":1,
            "colorTransform":{"exposure":1},
            "transformAroundCenter":{
               "scaleX":1,
               "scaleY":1
            },
            "ease":Quad.easeInOut,
            "onComplete":function():void
            {
               mc_shape.filters = [STROKE,SHADOW];
            }
         });
         this.revealed.dispatch(this);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         if(this._isRevealed)
         {
            return;
         }
         this.GLOW.color = this._strokeColor;
         this.GLOW.blurX = this.GLOW.blurY = 0;
         TweenMax.to(this.GLOW,0.25,{
            "blurX":20,
            "blurY":20,
            "onUpdate":function():void
            {
               mc_shape.filters = [STROKE,GLOW];
            }
         });
         TweenMax.to(this,0.25,{"transformAroundCenter":{
            "scaleX":1.1,
            "scaleY":1.1
         }});
         if(this.parent != null)
         {
            this._childIndex = this.parent.getChildIndex(this);
            this.parent.setChildIndex(this,this.parent.numChildren - 1);
         }
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         var self:UIMysteryItem;
         var e:MouseEvent = param1;
         if(this._isRevealed)
         {
            return;
         }
         self = this;
         TweenMax.to(self,0.25,{
            "transformAroundCenter":{
               "scaleX":1,
               "scaleY":1
            },
            "ease":Quad.easeInOut,
            "onComplete":function():void
            {
               mc_shape.filters = [STROKE,SHADOW];
            }
         });
         TweenMax.to(this.GLOW,0.2,{
            "blurX":0,
            "blurY":0,
            "onUpdate":function():void
            {
               mc_shape.filters = [STROKE,GLOW];
            }
         });
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(this._isRevealed)
         {
            return;
         }
         this.reveal();
      }
   }
}

