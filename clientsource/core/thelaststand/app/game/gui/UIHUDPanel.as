package thelaststand.app.game.gui
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.geom.Rectangle;
   import thelaststand.app.game.gui.buttons.UIHUDButton;
   import thelaststand.app.gui.TooltipManager;
   
   public class UIHUDPanel extends Sprite
   {
      
      private static const BMP_BACKGROUND:BitmapData = new BmpTopBarBackground();
      
      private var _buttons:Vector.<UIHUDButton>;
      
      private var _flip:Boolean;
      
      private var _width:int;
      
      private var _height:int;
      
      private var bmp_background:Bitmap;
      
      private var mc_buttons:Sprite;
      
      private var mc_tape1:ClearTapeGraphic;
      
      private var mc_tape2:ClearTapeGraphic;
      
      public function UIHUDPanel(param1:Boolean = false)
      {
         super();
         this._flip = param1;
         this._buttons = new Vector.<UIHUDButton>();
         this.mc_buttons = new Sprite();
         this.bmp_background = new Bitmap(BMP_BACKGROUND,"always",true);
         this.bmp_background.cacheAsBitmap = true;
         this.bmp_background.height = 53;
         this.bmp_background.scaleY = -this.bmp_background.scaleY;
         this.bmp_background.filters = [new DropShadowFilter(1,45,0,1,8,8,0.75,1)];
         this.mc_tape1 = new ClearTapeGraphic();
         this.mc_tape2 = new ClearTapeGraphic();
         if(this._flip)
         {
            this.mc_tape1.rotation = this.mc_tape2.rotation = -46;
            this.mc_tape1.x = this.mc_tape1.y = 3;
         }
         else
         {
            this.mc_tape1.rotation = this.mc_tape2.rotation = 46;
            this.mc_tape1.x = 3;
            this.mc_tape1.y = this.bmp_background.height - 4;
         }
         addChild(this.bmp_background);
         addChild(this.mc_tape1);
         addChild(this.mc_tape2);
         addChild(this.mc_buttons);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      }
      
      public function addButton(param1:UIHUDButton, param2:Number = 0) : UIHUDButton
      {
         addChild(param1);
         this._buttons.push(param1);
         param1.spacing = param2;
         this.refreshLayout();
         return param1;
      }
      
      public function refreshLayout() : void
      {
         var _loc1_:Rectangle = null;
         var _loc5_:UIHUDButton = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = int(this._buttons.length);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = this._buttons[_loc3_];
            if(_loc5_.visible != false)
            {
               _loc1_ = _loc5_.getBounds(_loc5_);
               _loc5_.x = _loc2_ + _loc5_.offset.x;
               _loc5_.y = int(this.bmp_background.height - (_loc1_.height + _loc1_.y) - 8) + _loc5_.offset.y;
               _loc2_ += int(_loc1_.width + _loc1_.x + 6 + _loc5_.spacing);
               this.mc_buttons.addChild(_loc5_);
            }
            _loc3_++;
         }
         this.bmp_background.width = _loc2_ + 24;
         _loc1_ = this.bmp_background.getBounds(this);
         this.mc_buttons.x = int(_loc1_.x + (_loc1_.width - this.mc_buttons.width) * 0.5);
         if(this._flip)
         {
            this.mc_tape1.x = this.mc_tape1.y = 6;
            this.mc_tape2.x = this.bmp_background.width - 8;
            this.mc_tape2.y = this.bmp_background.height - 8;
         }
         else
         {
            this.mc_tape1.x = 6;
            this.mc_tape1.y = this.bmp_background.height - 8;
            this.mc_tape2.x = this.bmp_background.width - 8;
            this.mc_tape2.y = 6;
         }
      }
      
      public function dispose() : void
      {
         var _loc1_:UIHUDButton = null;
         TooltipManager.getInstance().removeAllFromParent(this,true);
         TweenMax.killChildTweensOf(this);
         if(parent)
         {
            parent.removeChild(this);
         }
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         this.bmp_background.bitmapData = null;
         this.bmp_background.filters = [];
         this.bmp_background = null;
         this.mc_buttons = null;
         if(contains(this.mc_tape1))
         {
            removeChild(this.mc_tape1);
         }
         if(contains(this.mc_tape2))
         {
            removeChild(this.mc_tape2);
         }
         this.mc_tape1 = null;
         this.mc_tape2 = null;
         for each(_loc1_ in this._buttons)
         {
            _loc1_.dispose();
         }
         this._buttons = null;
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      override public function get width() : Number
      {
         return this.bmp_background.width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this.bmp_background.height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

