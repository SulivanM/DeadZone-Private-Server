package thelaststand.app.game.data
{
   import com.deadreckoned.threshold.core.IDisposable;
   import flash.display.BitmapData;
   import thelaststand.app.game.entities.CoverEntity;
   import thelaststand.app.game.entities.buildings.BuildingEntity;
   import thelaststand.engine.map.Cell;
   
   public class CoverData implements IDisposable
   {
      
      public static const HIGH:String = "high";
      
      public static const MODERATE:String = "moderate";
      
      public static const LOW:String = "low";
      
      public static const NONE:String = "none";
      
      private static const BMP_COVER_HIGH:BitmapData = new BmpIconCoverGreen();
      
      private static const BMP_COVER_MODERATE:BitmapData = new BmpIconCoverYellow();
      
      private static const BMP_COVER_LOW:BitmapData = new BmpIconCoverRed();
      
      private var _cell:Cell;
      
      private var _rating:int = 0;
      
      private var _entities:Vector.<CoverEntity>;
      
      public function CoverData(param1:Cell)
      {
         super();
         this._cell = param1;
         this._entities = new Vector.<CoverEntity>();
      }
      
      public static function getCoverIconLarge(param1:int) : BitmapData
      {
         switch(getCoverLevel(param1))
         {
            case HIGH:
               return new BmpIconCoverHigh();
            case MODERATE:
               return new BmpIconCoverModerate();
            case LOW:
               return new BmpIconCoverLow();
            default:
               return new BmpIconCoverLow();
         }
      }
      
      public static function getCoverIconSmall(param1:int) : BitmapData
      {
         switch(getCoverLevel(param1))
         {
            case HIGH:
               return BMP_COVER_HIGH;
            case MODERATE:
               return BMP_COVER_MODERATE;
            case LOW:
               return BMP_COVER_LOW;
            default:
               return BMP_COVER_LOW;
         }
      }
      
      public static function getCoverLevel(param1:int) : String
      {
         if(param1 <= 0)
         {
            return NONE;
         }
         if(param1 < 33)
         {
            return LOW;
         }
         if(param1 < 66)
         {
            return MODERATE;
         }
         return HIGH;
      }
      
      public function get cell() : Cell
      {
         return this._cell;
      }
      
      public function get rating() : int
      {
         return this._rating;
      }
      
      public function set rating(param1:int) : void
      {
         this._rating = param1;
      }
      
      public function get entities() : Vector.<CoverEntity>
      {
         return this._entities;
      }
      
      public function dispose() : void
      {
         this._entities = null;
         this._cell = null;
      }
      
      public function calculateRating() : void
      {
         var _loc2_:CoverEntity = null;
         var _loc3_:Building = null;
         var _loc4_:int = 0;
         var _loc1_:Number = 0;
         this._rating = 0;
         for each(_loc2_ in this._entities)
         {
            _loc3_ = null;
            if(_loc2_ is BuildingEntity)
            {
               _loc3_ = BuildingEntity(_loc2_).buildingData;
               if(_loc3_.destroyable && _loc3_.dead)
               {
                  continue;
               }
            }
            _loc4_ = _loc2_.coverRating;
            if(_loc4_ > this._rating)
            {
               this._rating = _loc4_;
               _loc1_ = _loc3_ != null ? _loc3_.coverRatingModifier : 0;
            }
         }
         this._rating = Math.ceil(this._rating + this._rating * _loc1_);
      }
   }
}

