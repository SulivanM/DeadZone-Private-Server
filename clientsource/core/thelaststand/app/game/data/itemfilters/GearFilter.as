package thelaststand.app.game.data.itemfilters
{
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemQualityType;
   
   public class GearFilter extends ItemFilter
   {
      
      public function GearFilter(param1:GearFilterData = null)
      {
         super();
         _filterClass = GearFilterData;
         _willSort = true;
         this.data = param1 || new GearFilterData();
      }
      
      override public function filter(param1:Vector.<Item>, param2:Vector.<Item> = null) : Vector.<Item>
      {
         var _loc5_:Function = null;
         var _loc6_:Item = null;
         param2 ||= new Vector.<Item>();
         var _loc3_:GearFilterData = GearFilterData(this.data);
         var _loc4_:int = int(param1.length - 1);
         for(; _loc4_ >= 0; _loc4_--)
         {
            _loc6_ = param1[_loc4_];
            if(_loc6_ != null)
            {
               if(!(_loc6_.level < _loc3_.levelMin || _loc6_.level > _loc3_.levelMax))
               {
                  switch(_loc3_.quality)
                  {
                     case "all":
                        break;
                     default:
                        if(ItemQualityType.getName(_loc6_.qualityType) == _loc3_.quality.toUpperCase())
                        {
                           break;
                        }
                        continue;
                  }
                  param2.push(_loc6_);
               }
            }
         }
         switch(_loc3_.sortField)
         {
            case "alpha":
               _loc5_ = this.sortByAlpha;
               break;
            case "level":
               _loc5_ = this.sortByLevel;
         }
         param2.sort(_loc5_);
         return param2;
      }
      
      private function sortByAlpha(param1:Item, param2:Item) : int
      {
         var _loc3_:int = int(param1.getBaseName().toLowerCase().localeCompare(param2.getBaseName().toLowerCase()));
         if(_loc3_ != 0)
         {
            return _loc3_;
         }
         var _loc4_:int = param2.level - param1.level;
         if(_loc4_ != 0)
         {
            return _loc4_;
         }
         return param1.id.localeCompare(param2.id);
      }
      
      private function sortByLevel(param1:Item, param2:Item) : int
      {
         if(param1.level != param2.level)
         {
            return param2.level - param1.level;
         }
         var _loc3_:int = int(param1.getBaseName().toLowerCase().localeCompare(param2.getBaseName().toLowerCase()));
         if(_loc3_ != 0)
         {
            return _loc3_;
         }
         return param1.id.localeCompare(param2.id);
      }
   }
}

