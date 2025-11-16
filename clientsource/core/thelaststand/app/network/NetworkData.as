package thelaststand.app.network
{
   import flash.utils.Dictionary;
   import thelaststand.app.data.CostTable;
   import thelaststand.app.data.NewsArticle;
   import thelaststand.app.game.data.SurvivorClass;
   
   public class NetworkData
   {
      
      private var _survivorClassesById:Dictionary;
      
      private var _numSurvivorClasses:int;
      
      private var _costTable:CostTable;
      
      private var _news:Vector.<NewsArticle>;
      
      private var _saleCategories:Vector.<String>;
      
      public function NetworkData()
      {
         super();
         this._survivorClassesById = new Dictionary(true);
         this._costTable = new CostTable();
         this._news = new Vector.<NewsArticle>();
         this._saleCategories = new Vector.<String>();
      }
      
      public function dispose() : void
      {
         this._survivorClassesById = null;
         this._costTable = null;
      }
      
      public function getSurvivorClass(param1:String) : SurvivorClass
      {
         return this._survivorClassesById[param1];
      }
      
      public function getNumSurvivorClasses() : int
      {
         return this._numSurvivorClasses;
      }
      
      public function getSurvivorClassIds() : Array
      {
         var _loc2_:String = null;
         var _loc1_:Array = [];
         for(_loc2_ in this._survivorClassesById)
         {
            _loc1_.push(_loc2_);
         }
         return _loc1_;
      }
      
      public function addSurvivorClass(param1:SurvivorClass) : void
      {
         if(this._survivorClassesById[param1.id] == null)
         {
            this._survivorClassesById[param1.id] = param1;
            ++this._numSurvivorClasses;
         }
      }
      
      public function get news() : Vector.<NewsArticle>
      {
         return this._news;
      }
      
      public function get saleCategories() : Vector.<String>
      {
         return this._saleCategories;
      }
      
      public function get costTable() : CostTable
      {
         return this._costTable;
      }
   }
}

