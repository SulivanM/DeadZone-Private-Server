package thelaststand.app.game.data
{
   import flash.utils.Dictionary;
   import thelaststand.common.resources.ResourceManager;
   
   public class ItemFactory
   {
      
      private static var _itemTable:XML;
      
      private static var _modTable:XML;
      
      private static var _cache:Dictionary = new Dictionary(true);
      
      private static var _modCache:Dictionary = new Dictionary(true);
      
      public function ItemFactory()
      {
         super();
         throw new Error("ItemFactory cannot be directly instantiated.");
      }
      
      public static function get itemTable() : XML
      {
         return _itemTable;
      }
      
      public static function createItemFromTypeId(param1:String) : Item
      {
         var _loc2_:Item = null;
         var _loc3_:XML = getItemDefinition(param1);
         if(_loc3_ == null)
         {
            return null;
         }
         switch(_loc3_.@type.toString())
         {
            case "clothing":
               _loc2_ = new ClothingAccessory(param1);
               break;
            case "weapon":
               _loc2_ = new Weapon(param1);
               break;
            case "gear":
               _loc2_ = new Gear(param1);
               break;
            case "crate":
               _loc2_ = new CrateItem();
               break;
            case "crate-mystery":
               _loc2_ = new CrateMysteryItem(param1);
               break;
            case "schematic":
               _loc2_ = new SchematicItem();
               break;
            case "effect":
               _loc2_ = new EffectItem();
               break;
            case "medical":
               _loc2_ = new MedicalItem();
               break;
            default:
               _loc2_ = new Item(param1);
         }
         _loc2_.xml = _loc3_;
         if(_loc2_ is SchematicItem && SchematicItem(_loc2_).schematicItem == null)
         {
            _loc2_.dispose();
            return null;
         }
         return _loc2_;
      }
      
      public static function getModDefinition(param1:String) : XML
      {
         var node:XML;
         var id:String = param1;
         if(id in _modCache)
         {
            return _modCache[id];
         }
         if(_modTable == null)
         {
            _modTable = ResourceManager.getInstance().getResource("xml/itemmods.xml").content;
         }
         node = _modTable.mod.(@id.toString() == id)[0];
         if(node == null)
         {
            return null;
         }
         _modCache[id] = node;
         return node;
      }
      
      public static function getItemDefinition(param1:String) : XML
      {
         var node:XML;
         var type:String = param1;
         if(type in _cache)
         {
            return _cache[type];
         }
         if(_itemTable == null)
         {
            _itemTable = ResourceManager.getInstance().getResource("xml/items.xml").content;
         }
         node = _itemTable.item.(@id.toString() == type)[0];
         if(node == null)
         {
            return null;
         }
         _cache[type] = node;
         return node;
      }
      
      public static function createItemFromObject(param1:Object) : Item
      {
         var itemData:XML;
         var item:Item = null;
         var obj:Object = param1;
         if(obj == null)
         {
            return null;
         }
         itemData = getItemDefinition(String(obj.type));
         if(itemData == null)
         {
            return null;
         }
         switch(itemData.@type.toString())
         {
            case "clothing":
               item = new ClothingAccessory();
               break;
            case "weapon":
               item = new Weapon();
               break;
            case "gear":
               item = new Gear();
               break;
            case "crate":
               item = new CrateItem();
               break;
            case "crate-mystery":
               item = new CrateMysteryItem();
               break;
            case "schematic":
               item = new SchematicItem();
               break;
            case "effect":
               item = new EffectItem();
               break;
            case "medical":
               item = new MedicalItem();
               break;
            default:
               item = new Item();
         }
         try
         {
            item.readObject(obj);
            if(item is SchematicItem && SchematicItem(item).schematicItem == null)
            {
               item.dispose();
               return null;
            }
         }
         catch(error:Error)
         {
            return null;
         }
         return item;
      }
      
      public static function createItemFromXML(param1:XML) : Item
      {
         var itemTypeId:String;
         var item:Item = null;
         var xml:XML = param1;
         var itemData:XML = getItemDefinition(xml.@type.toString());
         if(itemData == null)
         {
            return null;
         }
         itemTypeId = itemData.@id.toString();
         switch(itemData.@type.toString())
         {
            case "clothing":
               item = new ClothingAccessory(itemTypeId);
               break;
            case "weapon":
               item = new Weapon(itemTypeId);
               break;
            case "gear":
               item = new Gear(itemTypeId);
               break;
            case "crate":
               item = new CrateItem();
               break;
            case "crate-mystery":
               item = new CrateMysteryItem();
               break;
            case "schematic":
               item = new SchematicItem();
               break;
            case "effect":
               item = new EffectItem();
               break;
            case "medical":
               item = new MedicalItem();
               break;
            default:
               item = new Item(itemTypeId);
         }
         try
         {
            item.readObject(xml);
            if(item is SchematicItem && SchematicItem(item).schematicItem == null)
            {
               item.dispose();
               return null;
            }
         }
         catch(error:Error)
         {
            if(item != null)
            {
               item.dispose();
            }
            return null;
         }
         return item;
      }
      
      public static function createItemFromRecycleXML(param1:XML) : Item
      {
         var _loc2_:XML = param1.copy();
         _loc2_.@type = _loc2_.@id.toString();
         _loc2_.@id = GUID.create();
         if("@lvl" in _loc2_)
         {
            _loc2_.@l = int(_loc2_.@lvl.toString());
         }
         var _loc3_:Item = createItemFromXML(_loc2_);
         if(_loc3_ == null)
         {
            return null;
         }
         if(_loc3_.quantifiable)
         {
            _loc3_.quantity = int(_loc2_.toString());
         }
         return _loc3_;
      }
   }
}

