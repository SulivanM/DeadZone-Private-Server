package thelaststand.app.game.data.itemfilters
{
   import flash.utils.getQualifiedClassName;
   import thelaststand.app.game.data.Item;
   
   public class ItemFilter
   {
      
      protected var _filterClass:Class;
      
      protected var _willSort:Boolean = false;
      
      private var _data:IFilterData;
      
      public function ItemFilter()
      {
         super();
      }
      
      public function get willSort() : Boolean
      {
         return this._willSort;
      }
      
      public function get data() : IFilterData
      {
         return this._data;
      }
      
      public function set data(param1:IFilterData) : void
      {
         if(!(param1 is this._filterClass))
         {
            throw new Error("Invalid filter data supplied. Expected type " + getQualifiedClassName(this._filterClass) + ", got " + getQualifiedClassName(param1));
         }
         this._data = param1;
      }
      
      public function filter(param1:Vector.<Item>, param2:Vector.<Item> = null) : Vector.<Item>
      {
         throw new Error("This method must be overridden by subclasses");
      }
   }
}

