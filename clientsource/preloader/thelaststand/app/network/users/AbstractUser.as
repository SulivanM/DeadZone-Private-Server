package thelaststand.app.network.users
{
   import org.osflash.signals.Signal;
   
   public class AbstractUser
   {
      
      protected var _data:Object;
      
      protected var _defaultCurrency:String;
      
      public var loaded:Signal;
      
      public var loadFailed:Signal;
      
      public function AbstractUser()
      {
         super();
         this.loaded = new Signal();
         this.loadFailed = new Signal();
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function get defaultCurrency() : String
      {
         return this._defaultCurrency;
      }
      
      public function getJoinData() : Object
      {
         throw new Error("Abstract method. Must be implemented by sub classes.");
      }
      
      public function load() : void
      {
         throw new Error("Abstract method. Must be implemented by sub classes.");
      }
   }
}

