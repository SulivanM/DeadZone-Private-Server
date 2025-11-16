package thelaststand.app.game.data
{
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class SchematicItem extends Item
   {
      
      protected var _item:Item;
      
      protected var _schematicId:String;
      
      protected var _schematicXML:XML;
      
      public function SchematicItem(param1:Object = null)
      {
         super();
         _quantifiable = false;
         quantity = 1;
         if(param1 != null)
         {
            this.readObject(param1);
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._item = null;
         this._schematicId = null;
         this._schematicXML = null;
      }
      
      override public function getName() : String
      {
         return Language.getInstance().getString("items.schematic",this._item.getName());
      }
      
      public function unlock(param1:Function = null) : void
      {
         var dlgBusy:BusyDialogue = null;
         var self:SchematicItem = null;
         var network:Network = null;
         var callback:Function = param1;
         dlgBusy = new BusyDialogue(Language.getInstance().getString("crafting_unlock"));
         dlgBusy.open();
         self = this;
         network = Network.getInstance();
         network.startAsyncOp();
         network.save({"id":_id},SaveDataMethod.CRAFT_SCHEMATIC,function(param1:Object):void
         {
            network.completeAsyncOp();
            dlgBusy.close();
            if(param1 == null || param1.success === false || param1.schematic == null)
            {
               if(callback != null)
               {
                  callback(false);
               }
               return;
            }
            Network.getInstance().playerData.inventory.removeItem(self);
            var _loc2_:Schematic = new Schematic(param1.schematic);
            Network.getInstance().playerData.inventory.addSchematic(_loc2_);
            if(callback != null)
            {
               callback(true);
            }
         });
      }
      
      override public function toChatObject() : Object
      {
         var _loc1_:Object = super.toChatObject();
         _loc1_.data.schem = this._schematicId;
         return _loc1_;
      }
      
      override public function writeObject(param1:Object = null) : Object
      {
         param1 = super.writeObject(param1);
         param1.schem = this._schematicId;
         return param1;
      }
      
      override public function readObject(param1:Object) : void
      {
         var _loc2_:XML = null;
         _quantifiable = false;
         quantity = 1;
         if(param1 is XML)
         {
            _loc2_ = XML(param1);
            setXML(ItemFactory.getItemDefinition(_loc2_.@type.toString()));
            this.setSchematicData(_loc2_.@s.toString());
            _id = _loc2_.hasOwnProperty("@id") ? String(_loc2_.@id.toString()) : GUID.create();
            _level = _baseLevel = this._item.level;
            _qualityType = this._item.qualityType;
            return;
         }
         setXML(ItemFactory.getItemDefinition(param1.type));
         this.setSchematicData(String(param1.schem));
         if(this._item == null)
         {
            return;
         }
         _id = param1.hasOwnProperty("id") ? param1.id.toUpperCase() : GUID.create();
         _new = param1.hasOwnProperty("new") ? Boolean(param1["new"]) : false;
         _bought = param1.storeId != null ? true : (param1.hasOwnProperty("bought") ? Boolean(param1.bought) : false);
         _level = _baseLevel = this._item.level;
         _qualityType = this._item.qualityType;
         _craftData = null;
      }
      
      override public function clone() : Item
      {
         var _loc1_:SchematicItem = new SchematicItem(null);
         cloneBaseProperties(_loc1_);
         if(this._item)
         {
            _loc1_._item = this._item.clone();
         }
         _loc1_._schematicId = this._schematicId;
         _loc1_._schematicXML = this._schematicXML;
         return _loc1_;
      }
      
      private function setSchematicData(param1:String) : void
      {
         var id:String = param1;
         this._schematicId = id;
         this._schematicXML = ResourceManager.getInstance().getResource("xml/crafting.xml").content.schem.(@id == _schematicId)[0];
         if(this._schematicXML != null)
         {
            this._item = ItemFactory.createItemFromXML(this._schematicXML.itm[0]);
         }
         else
         {
            this._schematicId = id;
         }
      }
      
      public function get schematicId() : String
      {
         return this._schematicId;
      }
      
      public function get schematicItem() : Item
      {
         return this._item;
      }
   }
}

