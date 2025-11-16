package thelaststand.app.game.data
{
   import org.osflash.signals.Signal;
   
   public class AnimalAppearance implements IActorAppearance
   {
      
      private var _changed:Signal = new Signal();
      
      private var _data:Vector.<AttireData>;
      
      private var _body:AttireData = new AttireData("body");
      
      private var _resourceList:Array = [];
      
      private var _invalid:Boolean = true;
      
      public function AnimalAppearance()
      {
         super();
      }
      
      public function get body() : AttireData
      {
         return this._body;
      }
      
      public function set body(param1:AttireData) : void
      {
         this._body = param1;
         this.invalidate();
         this._changed.dispatch();
      }
      
      public function get data() : Vector.<AttireData>
      {
         if(this._invalid)
         {
            this.rebuildDataList();
         }
         return this._data;
      }
      
      public function get changed() : Signal
      {
         return this._changed;
      }
      
      public function clear() : void
      {
         this._body.clear();
         this.invalidate();
      }
      
      public function getResourceURIs() : Array
      {
         if(this._invalid)
         {
            this.rebuildDataList();
         }
         return this._resourceList;
      }
      
      public function getOverlays(param1:String) : Array
      {
         return null;
      }
      
      protected function invalidate() : void
      {
         this._invalid = true;
      }
      
      private function rebuildDataList() : void
      {
         this._data.length = 0;
         this._resourceList.length = 0;
         this._data.push(this._body);
         this._body.getResourceURIs(this._resourceList);
         this._invalid = false;
      }
   }
}

