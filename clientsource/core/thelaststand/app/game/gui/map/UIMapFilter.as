package thelaststand.app.game.gui.map
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Config;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.common.lang.Language;
   
   public class UIMapFilter extends Sprite
   {
      
      private var _buttons:Vector.<UIMapFilterButton>;
      
      private var _selectedFilter:UIMapFilterButton;
      
      private var bmp_background:Bitmap;
      
      private var mc_tape1:ClearTapeGraphic;
      
      private var mc_tape2:ClearTapeGraphic;
      
      public var filterChanged:Signal;
      
      public function UIMapFilter()
      {
         var _loc2_:XML = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:UIMapFilterButton = null;
         super();
         this.filterChanged = new Signal(String);
         var _loc1_:Array = [];
         for each(_loc2_ in Config.xml.location_filter.param)
         {
            _loc1_.push(_loc2_.toString());
         }
         this._buttons = new Vector.<UIMapFilterButton>();
         _loc3_ = 10;
         _loc4_ = 10;
         _loc5_ = 0;
         while(_loc5_ < _loc1_.length)
         {
            _loc6_ = new UIMapFilterButton();
            _loc6_.addEventListener(MouseEvent.CLICK,this.onFilterClicked,false,0,true);
            _loc6_.type = _loc1_[_loc5_].toString();
            _loc6_.x = _loc3_;
            _loc6_.y = _loc4_;
            TooltipManager.getInstance().add(_loc6_,Language.getInstance().getString("itm_types." + _loc1_[_loc5_]),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0.15);
            _loc3_ += _loc6_.width + 10;
            addChild(_loc6_);
            this._buttons.push(_loc6_);
            _loc5_++;
         }
         this.bmp_background = new Bitmap(new BmpTopBarBackground());
         this.bmp_background.width = _loc3_;
         this.bmp_background.height = int(_loc6_.height + _loc4_ * 2);
         this.bmp_background.transform.colorTransform = new ColorTransform(1.5,1.5,1.5);
         this.bmp_background.filters = [new DropShadowFilter(1,45,0,1,10,10,1,1)];
         addChildAt(this.bmp_background,0);
         this.mc_tape1 = new ClearTapeGraphic();
         this.mc_tape1.x = 0;
         this.mc_tape1.y = int(this.bmp_background.height * 0.5);
         this.mc_tape1.rotation = 92;
         addChild(this.mc_tape1);
         this.mc_tape2 = new ClearTapeGraphic();
         this.mc_tape2.x = this.bmp_background.width;
         this.mc_tape2.y = int(this.bmp_background.height * 0.5);
         this.mc_tape2.rotation = -89;
         addChild(this.mc_tape2);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      }
      
      public function dispose() : void
      {
         var _loc1_:UIMapFilterButton = null;
         TooltipManager.getInstance().removeAllFromParent(this,true);
         if(parent != null)
         {
            parent.removeChild(this);
         }
         for each(_loc1_ in this._buttons)
         {
            _loc1_.dispose();
         }
         this._buttons = null;
         this._selectedFilter = null;
         this.bmp_background.bitmapData.dispose();
         this.bmp_background.bitmapData = null;
         this.bmp_background = null;
         this.filterChanged.removeAll();
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
      }
      
      private function onFilterClicked(param1:MouseEvent) : void
      {
         var _loc2_:UIMapFilterButton = param1.currentTarget as UIMapFilterButton;
         if(this._selectedFilter == _loc2_)
         {
            this._selectedFilter = null;
            _loc2_.selected = false;
         }
         else
         {
            if(this._selectedFilter != null)
            {
               this._selectedFilter.selected = false;
               this._selectedFilter = null;
            }
            this._selectedFilter = _loc2_;
            this._selectedFilter.selected = true;
         }
         this.filterChanged.dispatch(this._selectedFilter != null ? this._selectedFilter.type : null);
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
   }
}

