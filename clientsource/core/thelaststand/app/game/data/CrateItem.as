package thelaststand.app.game.data
{
   import com.dynamicflash.util.Base64;
   import com.exileetiquette.utils.NumberFormatter;
   import flash.utils.ByteArray;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.game.data.effects.Effect;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class CrateItem extends Item
   {
      
      protected var _series:int = 0;
      
      protected var _version:int = 0;
      
      protected var _contents:Vector.<Item>;
      
      public var unlocked:Signal = new Signal(CrateItem,Item);
      
      public function CrateItem(param1:Object = null)
      {
         super();
         this._contents = new Vector.<Item>();
         _quantifiable = false;
         quantity = 1;
         if(param1 != null)
         {
            this.readObject(param1);
         }
      }
      
      public static function getKeyListForCrate(param1:CrateItem) : Vector.<String>
      {
         var xml:XML = null;
         var strSeries:String = null;
         var keyNode:XML = null;
         var crate:CrateItem = param1;
         var out:Vector.<String> = new Vector.<String>();
         if(crate.type == "crate-tutorial")
         {
            out.push("key-herc-level-1");
         }
         else
         {
            xml = ResourceManager.getInstance().getResource("xml/items.xml").content;
            strSeries = crate.series.toString();
            for each(keyNode in xml.item.(@type == "crate-key"))
            {
               if(keyNode.key.crate_type.(toString() == crate.type).length() != 0)
               {
                  if(keyNode.key.series.(toString() == strSeries).length() != 0)
                  {
                     out.push(keyNode.@id.toString());
                  }
               }
            }
         }
         return out;
      }
      
      override public function dispose() : void
      {
         var _loc1_:Item = null;
         super.dispose();
         for each(_loc1_ in this._contents)
         {
            _loc1_.dispose();
         }
         this._contents = null;
         this._series = this._version = 0;
         this.unlocked.removeAll();
      }
      
      override public function getName() : String
      {
         return Language.getInstance().getString("items." + _type,NumberFormatter.addLeadingZero(this._series),NumberFormatter.addLeadingZero(this._version));
      }
      
      override public function getImageURI() : String
      {
         var imageURI:String = null;
         var imgSeriesNode:XML = null;
         imageURI = _xml.img.@uri.toString();
         imgSeriesNode = _xml.crate.img.(@series == _series.toString())[0];
         if(imgSeriesNode != null)
         {
            return imgSeriesNode.@uri.toString();
         }
         return imageURI;
      }
      
      public function open(param1:Function = null) : void
      {
         var self:CrateItem = null;
         var network:Network = null;
         var keyList:Vector.<String> = null;
         var key:Item = null;
         var keyType:String = null;
         var keyItems:Vector.<Item> = null;
         var onComplete:Function = param1;
         var keyId:String = null;
         if(_type != "crate-tutorial")
         {
            keyList = CrateItem.getKeyListForCrate(this);
            if(keyList.length == 0)
            {
               Network.getInstance().client.errorLog.writeError("CrateItem.open() failed, no key defined",_type + ", series=" + this._series + ", version=" + this._version,"",{},null);
               onComplete(false);
               return;
            }
            key = null;
            for each(keyType in keyList)
            {
               keyItems = Network.getInstance().playerData.inventory.getItemsOfType(keyType);
               if(keyItems.length > 0)
               {
                  key = keyItems[0];
                  break;
               }
            }
            if(key == null)
            {
               onComplete(false);
               return;
            }
            keyId = key.id;
         }
         self = this;
         network = Network.getInstance();
         network.save({
            "crateId":_id,
            "keyId":keyId
         },SaveDataMethod.CRATE_UNLOCK,function(param1:Object):void
         {
            var _loc3_:Effect = null;
            var _loc5_:Item = null;
            if(param1 == null || param1.success !== true)
            {
               onComplete(false);
               return;
            }
            var _loc2_:Item = ItemFactory.createItemFromObject(param1.item);
            if(_loc2_ != null)
            {
               network.playerData.giveItem(_loc2_,true);
            }
            if(param1.effect != null)
            {
               _loc3_ = new Effect();
               _loc3_.readObject(Base64.decodeToByteArray(param1.effect));
               network.playerData.compound.globalEffects.addEffect(_loc3_);
            }
            if(param1.cooldown != null)
            {
               network.playerData.cooldowns.parse(Base64.decodeToByteArray(param1.cooldown));
            }
            if(param1.keyId != null)
            {
               _loc5_ = network.playerData.inventory.getItemById(param1.keyId);
               if(_loc5_ != null)
               {
                  _loc5_.quantity = int(param1.keyQty);
                  if(_loc5_.quantity <= 0)
                  {
                     network.playerData.inventory.removeItem(_loc5_);
                  }
               }
            }
            var _loc4_:CrateItem = self;
            if(param1.crateId != null)
            {
               _loc4_ = network.playerData.inventory.removeItemById(param1.crateId) as CrateItem || self;
            }
            network.playerData.crateUnlocked.dispatch(_loc4_);
            if(onComplete != null)
            {
               onComplete(true,_loc2_,_loc3_);
            }
            Tracking.trackEvent("Player","CrateOpen",_loc4_.getTradeTrackingName());
            unlocked.dispatch(self,_loc2_);
         });
      }
      
      override public function toChatObject() : Object
      {
         var _loc3_:Item = null;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc1_:Object = super.toChatObject();
         var _loc2_:Object = _loc1_.data;
         _loc2_.series = this._series;
         _loc2_.version = this._version;
         _loc2_.contents = [];
         for each(_loc3_ in this._contents)
         {
            _loc4_ = _loc3_.writeObject();
            delete _loc4_._type;
            delete _loc4_.id;
            delete _loc4_.bought;
            for(_loc5_ in _loc4_)
            {
               if(_loc4_[_loc5_] is ByteArray)
               {
                  _loc4_[_loc5_] = Base64.encodeByteArray(_loc4_[_loc5_]);
               }
            }
            _loc2_.contents.push(_loc4_);
         }
         return _loc1_;
      }
      
      override public function readObject(param1:Object) : void
      {
         var _loc2_:XML = null;
         var _loc3_:int = 0;
         var _loc4_:Item = null;
         if(param1 is XML)
         {
            _loc2_ = XML(param1);
            setXML(ItemFactory.getItemDefinition(_loc2_.@type.toString()));
            _id = _loc2_.hasOwnProperty("@id") ? String(_loc2_.@id.toString()) : GUID.create();
            _level = _baseLevel = _loc2_.hasOwnProperty("@l") ? int(_loc2_.@l.toString()) : 0;
            _qualityType = ItemQualityType.PREMIUM;
            this._series = int(_loc2_.@s.toString());
            this._version = int(_loc2_.@v.toString());
            _bought = false;
            _level = _baseLevel = 0;
            _quantifiable = true;
            quantity = 1;
            return;
         }
         setXML(ItemFactory.getItemDefinition(param1.type));
         _id = param1.hasOwnProperty("id") ? param1.id.toUpperCase() : GUID.create();
         _qualityType = ItemQualityType.PREMIUM;
         _new = param1.hasOwnProperty("new") ? Boolean(param1["new"]) : false;
         _bought = param1.storeId != null ? true : (param1.hasOwnProperty("bought") ? Boolean(param1.bought) : false);
         _level = _baseLevel = param1.hasOwnProperty("level") ? int(param1.level) : 0;
         _quantifiable = false;
         quantity = 1;
         this._series = int(param1.series) || 0;
         this._version = int(param1.version) || 0;
         this._contents.length = 0;
         if(param1.contents is Array)
         {
            _loc3_ = 0;
            while(_loc3_ < param1.contents.length)
            {
               if(param1.contents[_loc3_] != null)
               {
                  _loc4_ = ItemFactory.createItemFromObject(param1.contents[_loc3_]);
                  if(_loc4_ != null)
                  {
                     this._contents.push(_loc4_);
                  }
               }
               _loc3_++;
            }
         }
      }
      
      override public function clone() : Item
      {
         var _loc2_:Item = null;
         var _loc1_:CrateItem = new CrateItem(null);
         cloneBaseProperties(_loc1_);
         _loc1_._series = this._series;
         _loc1_._version = this._version;
         for each(_loc2_ in this._contents)
         {
            _loc1_._contents.push(_loc2_.clone());
         }
         return _loc1_;
      }
      
      override public function getTradeTrackingName() : String
      {
         return this.getName() + "-[" + this._version + "-" + this._series + "]";
      }
      
      public function get contents() : Vector.<Item>
      {
         return this._contents;
      }
      
      public function get series() : int
      {
         return this._series;
      }
      
      public function get version() : int
      {
         return this._version;
      }
   }
}

