package thelaststand.app.game.gui.attacklog
{
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.gui.UIScrollBar;
   import thelaststand.app.utils.GraphicUtils;
   
   public class AttackLogScrollList extends Sprite
   {
      
      private var itemContainer:Sprite;
      
      private var _items:Vector.<AttackLogScrollListItem>;
      
      private var _mask:Shape;
      
      private var _attackersLookup:Dictionary;
      
      private var _defendersLookup:Dictionary;
      
      private var ui_scroll:UIScrollBar;
      
      private var popup:AttackLogSurvivorTooltip;
      
      public function AttackLogScrollList(param1:Object, param2:ByteArray, param3:Dictionary, param4:Dictionary)
      {
         var _loc9_:AttackLogScrollListItem = null;
         super();
         var _loc5_:Number = 360;
         var _loc6_:Number = 278;
         GraphicUtils.drawUIBlock(this.graphics,_loc5_,_loc6_);
         this._attackersLookup = param3;
         this._defendersLookup = param4;
         this._mask = new Shape();
         this._mask.x = this._mask.y = 5;
         this._mask.graphics.beginFill(16711680,1);
         this._mask.graphics.drawRect(0,0,_loc5_ - 24,_loc6_ - 10);
         addChild(this._mask);
         this.itemContainer = new Sprite();
         this.itemContainer.x = this._mask.x;
         this.itemContainer.y = this._mask.y;
         addChild(this.itemContainer);
         this.popup = new AttackLogSurvivorTooltip();
         this.itemContainer.mask = this._mask;
         this._items = new Vector.<AttackLogScrollListItem>();
         var _loc7_:int = param2.readInt();
         var _loc8_:int = 0;
         while(_loc8_ < _loc7_)
         {
            _loc9_ = new AttackLogScrollListItem(param1,param2,_loc8_ % 2 == 0,param3,param4);
            if(_loc8_ > 0)
            {
               _loc9_.y = this._items[_loc8_ - 1].y + this._items[_loc8_ - 1].height + 3;
            }
            this.itemContainer.addChild(_loc9_);
            this._items.push(_loc9_);
            _loc9_.onTooltip.add(this.onItemTooltip);
            _loc8_++;
         }
         this.ui_scroll = new UIScrollBar();
         this.ui_scroll.wheelArea = this;
         this.ui_scroll.x = _loc5_ - this.ui_scroll.width - 4;
         this.ui_scroll.y = 1;
         this.ui_scroll.height = _loc6_ - 2;
         this.ui_scroll.contentHeight = this.itemContainer.height;
         this.ui_scroll.changed.add(this.onScrollbarChanged);
         if(this.itemContainer.height > this._mask.height)
         {
            addChild(this.ui_scroll);
         }
         else
         {
            this._mask.width = _loc5_ - this._mask.x * 2;
         }
      }
      
      public function dispose() : void
      {
         var _loc1_:AttackLogScrollListItem = null;
         if(parent)
         {
            parent.removeChild(this);
         }
         for each(_loc1_ in this._items)
         {
            _loc1_.dispose();
         }
         this._items = null;
         this.popup.dispose();
         this.ui_scroll.destroy();
         this._attackersLookup = null;
         this._defendersLookup = null;
      }
      
      private function onScrollbarChanged(param1:Number) : void
      {
         this.itemContainer.y = this._mask.y - (this.itemContainer.height - this._mask.height) * param1;
         if(this.popup.parent)
         {
            this.popup.parent.removeChild(this.popup);
         }
      }
      
      private function onItemTooltip(param1:AttackLogScrollListItem, param2:String, param3:String) : void
      {
         var _loc4_:* = this._attackersLookup[param2] != null;
         var _loc5_:Survivor = _loc4_ ? this._attackersLookup[param2] : this._defendersLookup[param2];
         var _loc6_:SurvivorLoadout = _loc4_ ? _loc5_.loadoutOffence : _loc5_.loadoutDefence;
         var _loc7_:* = this._attackersLookup[param3] != null;
         var _loc8_:Survivor = _loc7_ ? this._attackersLookup[param3] : this._defendersLookup[param3];
         var _loc9_:SurvivorLoadout = null;
         if(_loc8_ != null)
         {
            _loc9_ = _loc7_ ? _loc8_.loadoutOffence : _loc5_.loadoutDefence;
         }
         this.popup.populate(_loc5_,_loc6_,_loc8_,_loc9_,this._mask.width,param1.height);
         this.popup.x = this.itemContainer.x + int((param1.width - this.popup.panelOnlyWidth) * 0.5);
         this.popup.y = this.itemContainer.y + param1.y - (this.popup.height - param1.height);
         addChild(this.popup);
      }
      
      public function generateBitmapData() : BitmapData
      {
         var _loc1_:BitmapData = new BitmapData(this.itemContainer.width + 10,this.itemContainer.height + 10,false,7631988);
         _loc1_.fillRect(new Rectangle(1,1,_loc1_.width - 2,_loc1_.height - 2),2500134);
         var _loc2_:Matrix = new Matrix();
         _loc2_.translate(5,5);
         this.itemContainer.mask = null;
         _loc1_.draw(this.itemContainer,_loc2_);
         this.itemContainer.mask = this._mask;
         return _loc1_;
      }
   }
}

