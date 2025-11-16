package thelaststand.app.game.gui.lists
{
   import com.deadreckoned.threshold.display.Color;
   import flash.geom.Point;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.injury.Injury;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.common.lang.Language;
   
   public class UIInjuryList extends UIPagedList
   {
      
      private var _injuries:Vector.<Injury>;
      
      public function UIInjuryList()
      {
         var _loc1_:UIInjuryListItem = null;
         super();
         _paddingX = 3;
         _paddingY = 3;
         listItemClass = UIInjuryListItem;
         _loc1_ = new listItemClass() as UIInjuryListItem;
         _itemWidth = _loc1_.width;
         _itemHeight = _loc1_.height;
         _loc1_.dispose();
      }
      
      public function get injuries() : Vector.<Injury>
      {
         return this._injuries;
      }
      
      public function set injuries(param1:Vector.<Injury>) : void
      {
         this._injuries = param1;
         this.createItems();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._injuries = null;
      }
      
      override protected function createItems() : void
      {
         var _loc1_:UIPagedListItem = null;
         var _loc5_:int = 0;
         var _loc6_:UIInjuryListItem = null;
         for each(_loc1_ in _items)
         {
            _loc1_.dispose();
         }
         this._injuries.sort(this.injurySort);
         _items.length = 0;
         _selectedItem = null;
         var _loc2_:int = 1;
         var _loc3_:int = _pageHeight / _itemHeight;
         var _loc4_:int = _loc2_ * _loc3_ * Math.ceil(Math.max(this._injuries.length,1) / (_loc2_ * _loc3_));
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            _loc1_ = new listItemClass() as UIPagedListItem;
            _loc1_.clicked.add(onItemClicked);
            _loc6_ = _loc1_ as UIInjuryListItem;
            _loc6_.alternating = _loc5_ % 2 != 0;
            if(_loc5_ < this._injuries.length)
            {
               _loc6_.injury = this._injuries[_loc5_];
               _loc6_.mouseEnabled = true;
               TooltipManager.getInstance().add(_loc6_,this.getInjuryTooltip(_loc6_.injury),new Point(_loc6_.width,NaN),TooltipDirection.DIRECTION_LEFT,0);
            }
            else
            {
               _loc6_.injury = null;
               _loc6_.mouseEnabled = false;
               TooltipManager.getInstance().remove(_loc6_);
            }
            mc_pageContainer.addChild(_loc1_);
            _items.push(_loc1_);
            _loc5_++;
         }
         super.createItems();
      }
      
      private function injurySort(param1:Injury, param2:Injury) : int
      {
         return param1.damage - param2.damage;
      }
      
      private function getInjuryTooltip(param1:Injury) : String
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc2_:Array = [];
         var _loc3_:Language = Language.getInstance();
         for each(_loc4_ in param1.getAttributes())
         {
            _loc5_ = _loc3_.getString("att." + _loc4_);
            if(_loc5_ == "?")
            {
               _loc5_ = _loc3_.getString("itm_details." + _loc4_);
            }
            _loc6_ = param1.getAttributeModifier(_loc4_) * 100;
            _loc7_ = Number(_loc6_.toFixed(2));
            _loc2_.push("<b><font color=\'" + Color.colorToHex(_loc7_ < 0 ? Effects.COLOR_WARNING : Effects.COLOR_GOOD) + "\'>" + _loc5_ + " " + (_loc7_ < 0 ? "" : "+") + _loc7_ + "%</font></b>");
         }
         return _loc2_.join("<br/>");
      }
   }
}

