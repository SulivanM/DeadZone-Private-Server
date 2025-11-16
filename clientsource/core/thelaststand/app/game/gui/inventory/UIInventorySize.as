package thelaststand.app.game.gui.inventory
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.logic.DialogueController;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class UIInventorySize extends UIComponent
   {
      
      private var _height:int = 24;
      
      private var _width:int = 194;
      
      private var _panelWidth:int = 0;
      
      private var _panelX:int = 0;
      
      private var _maxSize:int = 0;
      
      private var _size:int = 0;
      
      private var _warningThreshold:int = 0;
      
      private var _showAddMore:Boolean = false;
      
      private var _isUpgraded:Boolean = false;
      
      private var bmp_icon:Bitmap;
      
      private var btn_addMore:PushButton;
      
      private var txt_label:BodyTextField;
      
      public function UIInventorySize()
      {
         super();
         this.bmp_icon = new Bitmap(new BmpIconHUDInventory(),"auto",true);
         this.bmp_icon.width = 34;
         this.bmp_icon.scaleY = this.bmp_icon.scaleX;
         this.bmp_icon.filters = [Effects.ICON_SHADOW];
         addChild(this.bmp_icon);
         this._panelX = int(this.bmp_icon.x + this.bmp_icon.width * 0.5);
         this.txt_label = new BodyTextField({
            "color":16777215,
            "size":16,
            "bold":true
         });
         addChild(this.txt_label);
         this.btn_addMore = new PushButton(null,new BmpIconAddResource(),-1,null,4226049);
         this.btn_addMore.clicked.add(this.onAddMoreClicked);
         this.btn_addMore.showBorder = false;
         this.btn_addMore.height = int(this._height - 6);
         this.btn_addMore.width = int(this.btn_addMore.height);
         addChild(this.btn_addMore);
         TooltipManager.getInstance().add(this.btn_addMore,Language.getInstance().getString("inv_upgrade_buy"),new Point(this.btn_addMore.width,NaN),TooltipDirection.DIRECTION_LEFT,0);
      }
      
      public function get maxSize() : int
      {
         return this._maxSize;
      }
      
      public function set maxSize(param1:int) : void
      {
         this._maxSize = param1;
         if(stage != null)
         {
            this.updateLabel();
         }
         else
         {
            invalidate();
         }
      }
      
      public function get size() : int
      {
         return this._size;
      }
      
      public function set size(param1:int) : void
      {
         this._size = param1;
         if(stage != null)
         {
            this.updateLabel();
         }
         else
         {
            invalidate();
         }
      }
      
      public function get warningThreshold() : int
      {
         return this._warningThreshold;
      }
      
      public function set warningThreshold(param1:int) : void
      {
         this._warningThreshold = param1;
         if(stage != null)
         {
            this.updateLabel();
         }
         else
         {
            invalidate();
         }
      }
      
      public function get isUpgraded() : Boolean
      {
         return this._isUpgraded;
      }
      
      public function set isUpgraded(param1:Boolean) : void
      {
         if(param1 == this._isUpgraded)
         {
            return;
         }
         this._isUpgraded = param1;
         this.bmp_icon.bitmapData.dispose();
         this.bmp_icon.bitmapData = this._isUpgraded ? new BmpIconHUDInventoryUpgrade1() : new BmpIconHUDInventory();
         this.bmp_icon.smoothing = true;
         invalidate();
      }
      
      public function get showAddMore() : Boolean
      {
         return this._showAddMore;
      }
      
      public function set showAddMore(param1:Boolean) : void
      {
         this._showAddMore = param1;
         invalidate();
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         invalidate();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      override public function dispose() : void
      {
         super.dispose();
         TooltipManager.getInstance().removeAllFromParent(this);
         this.bmp_icon.filters = [];
         this.bmp_icon.bitmapData.dispose();
         this.bmp_icon.bitmapData = null;
         this.btn_addMore.dispose();
      }
      
      public function playUpgradeAnimation() : void
      {
         var _loc1_:Object = {"exposure":2};
         var _loc2_:Object = {
            "blurX":10,
            "blurY":10,
            "color":16777215,
            "alpha":1,
            "quality":1,
            "remove":true
         };
         var _loc3_:Number = this.bmp_icon.scaleY * 1.25;
         TweenMax.from(this.bmp_icon,1.25,{
            "delay":0.05,
            "ease":Back.easeOut,
            "transformAroundCenter":{
               "scaleX":_loc3_,
               "scaleY":_loc3_
            },
            "colorTransform":_loc1_,
            "glowFilter":_loc2_
         });
         TweenMax.from(this.txt_label,1.25,{
            "delay":0.05,
            "ease":Back.easeOut,
            "transformAroundCenter":{
               "scaleX":1.25,
               "scaleY":1.25
            },
            "colorTransform":_loc1_,
            "glowFilter":_loc2_
         });
      }
      
      override protected function draw() : void
      {
         graphics.clear();
         var _loc1_:int = this._width - this._panelX;
         GraphicUtils.drawUIBlock(graphics,_loc1_,this._height,this._panelX);
         this.bmp_icon.y = int((this._height - this.bmp_icon.height) * 0.5);
         this.btn_addMore.visible = this._showAddMore;
         this.btn_addMore.y = int((this._height - this.btn_addMore.height) * 0.5);
         this.btn_addMore.x = int(this._width - this.btn_addMore.width - 3);
         this.updateLabel();
      }
      
      private function updateLabel() : void
      {
         this.txt_label.text = NumberFormatter.format(this._size,0) + " / " + NumberFormatter.format(this._maxSize,0);
         this.txt_label.textColor = this._size > this._warningThreshold ? Effects.COLOR_WARNING : 16777215;
         this.txt_label.maxWidth = 70;
         var _loc1_:int = this.btn_addMore.visible ? int(this.btn_addMore.x - this._panelX) : this._width - this._panelX;
         this.txt_label.x = int(this._panelX + (_loc1_ - this.txt_label.width) * 0.5 + this.bmp_icon.width * 0.25 - 1);
         this.txt_label.y = int((this._height - this.txt_label.height) * 0.5 + 1);
      }
      
      private function onAddMoreClicked(param1:MouseEvent) : void
      {
         DialogueController.getInstance().openInventoryUpgrade();
      }
   }
}

