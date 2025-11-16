package thelaststand.app.game.data.itemfilters
{
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemQualityType;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.data.WeaponClass;
   import thelaststand.app.game.data.WeaponData;
   
   public class WeaponsFilter extends ItemFilter
   {
      
      private var _weaponData:WeaponData = new WeaponData();
      
      public function WeaponsFilter(param1:WeaponsFilterData = null)
      {
         super();
         _filterClass = WeaponsFilterData;
         _willSort = true;
         this.data = param1 || new WeaponsFilterData();
      }
      
      override public function filter(param1:Vector.<Item>, param2:Vector.<Item> = null) : Vector.<Item>
      {
         var _loc5_:Function = null;
         var _loc6_:Weapon = null;
         var _loc7_:* = false;
         param2 ||= new Vector.<Item>();
         var _loc3_:WeaponsFilterData = WeaponsFilterData(this.data);
         var _loc4_:int = int(param1.length - 1);
         for(; _loc4_ >= 0; _loc4_--)
         {
            _loc6_ = param1[_loc4_] as Weapon;
            if(_loc6_ != null)
            {
               if(!(_loc6_.level < _loc3_.levelMin || _loc6_.level > _loc3_.levelMax))
               {
                  _loc7_ = _loc6_.weaponClass == WeaponClass.MELEE;
                  if(!(!_loc3_.melee && _loc7_ || !_loc3_.firearms && !_loc7_))
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
         }
         switch(_loc3_.sortField)
         {
            case "alpha":
               _loc5_ = this.sortByAlpha;
               break;
            case "level":
               _loc5_ = this.sortByLevel;
               break;
            case "dps":
               _loc5_ = this.sortByDPS;
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
      
      private function sortByDPS(param1:Weapon, param2:Weapon) : int
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc3_:WeaponsFilterData = WeaponsFilterData(this.data);
         if(_loc3_.loadout != null)
         {
            this._weaponData.populate(_loc3_.loadout.survivor,param1,_loc3_.loadout.type);
            _loc4_ = this._weaponData.getDPS();
            this._weaponData.populate(_loc3_.loadout.survivor,param2,_loc3_.loadout.type);
            _loc5_ = this._weaponData.getDPS();
         }
         else
         {
            this._weaponData.populate(null,param1);
            _loc4_ = this._weaponData.getDPS();
            this._weaponData.populate(null,param2);
            _loc5_ = this._weaponData.getDPS();
         }
         var _loc6_:Number = _loc5_ - _loc4_;
         if(_loc6_ != 0)
         {
            return int(_loc6_ * 1000);
         }
         return this.sortByLevel(param1,param2);
      }
   }
}

