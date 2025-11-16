package thelaststand.app.game.data
{
   import org.osflash.signals.Signal;
   
   public class SurvivorLoadoutData
   {
      
      private var _type:String;
      
      private var _item:Item;
      
      private var _quantity:int;
      
      private var _loadout:SurvivorLoadout;
      
      public var changed:Signal;
      
      public function SurvivorLoadoutData(param1:SurvivorLoadout, param2:String)
      {
         super();
         this._type = param2;
         this._loadout = param1;
         this.changed = new Signal(SurvivorLoadoutData);
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function get item() : Item
      {
         return this._item;
      }
      
      public function set item(param1:Item) : void
      {
         if(param1 == this._item)
         {
            return;
         }
         var _loc2_:Item = this._item;
         this._item = param1;
         if(this._item == null)
         {
            this._quantity = 0;
         }
         else if(this._quantity == 0)
         {
            this._quantity = 1;
         }
         this.changed.dispatch(this,this._item,_loc2_);
      }
      
      public function get loadout() : SurvivorLoadout
      {
         return this._loadout;
      }
      
      public function get quantity() : int
      {
         return this._quantity;
      }
      
      public function set quantity(param1:int) : void
      {
         if(param1 == this._quantity)
         {
            return;
         }
         if(this._item == null)
         {
            this._quantity = 0;
            this.changed.dispatch(this);
            return;
         }
         if(param1 != 1 && !this._item.quantifiable)
         {
            throw new ArgumentError("Quantity cannot be anything other than 1 for non-quantifiable items.");
         }
         if(param1 <= 0)
         {
            param1 = 0;
            this.item = null;
            return;
         }
         this._quantity = param1;
         this.changed.dispatch(this);
      }
      
      public function dispose() : void
      {
         this._item = null;
         this._quantity = 0;
         this.changed.removeAll();
      }
      
      public function toHashtable() : Object
      {
         if(this._item == null)
         {
            return {};
         }
         return {
            "item":this._item.id.toUpperCase(),
            "qty":this._quantity
         };
      }
   }
}

