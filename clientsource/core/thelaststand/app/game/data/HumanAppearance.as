package thelaststand.app.game.data
{
   import com.deadreckoned.threshold.display.Color;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.common.resources.ResourceManager;
   
   public class HumanAppearance implements IActorAppearance
   {
      
      private static var _hairColors:Vector.<uint>;
      
      private static var _skinColors:Vector.<uint>;
      
      private var _changed:Signal = new Signal();
      
      private var _data:Vector.<AttireData> = new Vector.<AttireData>();
      
      protected var _skin:AttireData = new AttireData("skin");
      
      protected var _hair:AttireData = new AttireData("hair");
      
      protected var _hairColor:String = "black";
      
      protected var _facialHair:AttireData = new AttireData("fhair");
      
      protected var _upperBody:AttireData = new AttireData("upper");
      
      protected var _lowerBody:AttireData = new AttireData("lower");
      
      protected var _accessories:Vector.<AttireData> = new Vector.<AttireData>();
      
      private var _baseAttire:Vector.<AttireData>;
      
      private var _overlaysByType:Dictionary = new Dictionary(true);
      
      private var _resourceList:Array = [];
      
      private var _forceHair:Boolean = false;
      
      private var _hideGear:Boolean = false;
      
      private var _invalid:Boolean = true;
      
      private var _flags:uint = 0;
      
      public function HumanAppearance()
      {
         super();
      }
      
      public static function getHairColors() : Vector.<uint>
      {
         var _loc1_:XML = null;
         var _loc2_:XML = null;
         if(_hairColors == null)
         {
            _hairColors = new Vector.<uint>();
            _loc1_ = ResourceManager.getInstance().getResource("xml/attire.xml").content;
            for each(_loc2_ in _loc1_.hair_textures.tex)
            {
               _hairColors.push(Color.hexToColor(_loc2_.@color.toString()));
            }
         }
         return _hairColors;
      }
      
      public static function getSkinColors() : Vector.<uint>
      {
         var xml:XML = null;
         var node:XML = null;
         if(_skinColors == null)
         {
            _skinColors = new Vector.<uint>();
            xml = ResourceManager.getInstance().getResource("xml/attire.xml").content;
            for each(node in xml.item.(@type == "skin"))
            {
               _skinColors.push(Color.hexToColor(node.@color.toString()));
            }
         }
         return _skinColors;
      }
      
      public function get flags() : uint
      {
         if(this._invalid)
         {
            this.rebuildDataList();
         }
         return this._flags;
      }
      
      public function get skin() : AttireData
      {
         return this._skin;
      }
      
      public function set skin(param1:AttireData) : void
      {
         this._skin = param1;
         this.invalidate();
         this._changed.dispatch();
      }
      
      public function get hair() : AttireData
      {
         return this._hair;
      }
      
      public function set hair(param1:AttireData) : void
      {
         this._hair = param1;
         this.invalidate();
         this._changed.dispatch();
      }
      
      public function get hairColor() : String
      {
         return this._hairColor;
      }
      
      public function set hairColor(param1:String) : void
      {
         this._hairColor = param1;
         this.invalidate();
      }
      
      public function get facialHair() : AttireData
      {
         return this._facialHair;
      }
      
      public function set facialHair(param1:AttireData) : void
      {
         this._facialHair = param1;
         this.invalidate();
         this._changed.dispatch();
      }
      
      public function get upperBody() : AttireData
      {
         return this._upperBody;
      }
      
      public function set upperBody(param1:AttireData) : void
      {
         this._upperBody = param1;
         this.invalidate();
         this._changed.dispatch();
      }
      
      public function get lowerBody() : AttireData
      {
         return this._lowerBody;
      }
      
      public function set lowerBody(param1:AttireData) : void
      {
         this._lowerBody = param1;
         this.invalidate();
         this._changed.dispatch();
      }
      
      public function get accessories() : Vector.<AttireData>
      {
         return this._accessories;
      }
      
      public function set accessories(param1:Vector.<AttireData>) : void
      {
         this._accessories = param1;
         this.invalidate();
         this._changed.dispatch();
      }
      
      public function get forceHair() : Boolean
      {
         return this._forceHair;
      }
      
      public function set forceHair(param1:Boolean) : void
      {
         this._forceHair = param1;
         this.invalidate();
         this._changed.dispatch();
      }
      
      public function get hideGear() : Boolean
      {
         return this._hideGear;
      }
      
      public function set hideGear(param1:Boolean) : void
      {
         this._hideGear = param1;
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
      
      public function addAccessory(param1:AttireData) : AttireData
      {
         return this.addAccessoryAt(param1,this._accessories.length);
      }
      
      public function addAccessoryAt(param1:AttireData, param2:int) : AttireData
      {
         if(param2 < 0 || param2 > this._accessories.length)
         {
            return null;
         }
         if(this._accessories.indexOf(param1) > -1)
         {
            return param1;
         }
         this._accessories.splice(param2,0,param1);
         this.invalidate();
         this._changed.dispatch();
         return param1;
      }
      
      public function removeAccessory(param1:AttireData) : AttireData
      {
         return this.removeAccessoryAt(this._accessories.indexOf(param1));
      }
      
      public function removeAccessoryAt(param1:int) : AttireData
      {
         if(param1 < 0 || param1 >= this._accessories.length)
         {
            return null;
         }
         var _loc2_:AttireData = this._accessories[param1];
         this._accessories.splice(param1,1);
         this.invalidate();
         this._changed.dispatch();
         return _loc2_;
      }
      
      public function clone() : HumanAppearance
      {
         var _loc1_:HumanAppearance = new HumanAppearance();
         _loc1_._skin = this._skin.clone();
         _loc1_._hair = this._hair.clone();
         _loc1_._hairColor = this._hairColor;
         _loc1_._facialHair = this._facialHair.clone();
         _loc1_._upperBody = this._upperBody.clone();
         _loc1_._lowerBody = this._lowerBody.clone();
         _loc1_._accessories = new Vector.<AttireData>(this._accessories.length);
         var _loc2_:int = 0;
         while(_loc2_ < this._accessories.length)
         {
            _loc1_._accessories[_loc2_] = this._accessories[_loc2_].clone();
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function clearAccessories() : void
      {
         if(this._accessories.length == 0)
         {
            return;
         }
         this._accessories.length = 0;
         this.invalidate();
         this._changed.dispatch();
      }
      
      public function clear() : void
      {
         this._skin.clear();
         this._hair.clear();
         this._facialHair.clear();
         this._upperBody.clear();
         this._lowerBody.clear();
         this._accessories.length = 0;
         this._data.length = 0;
         this._resourceList.length = 0;
         this.invalidate();
      }
      
      public function invalidate() : void
      {
         this._invalid = true;
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
         if(this._invalid)
         {
            this.rebuildDataList();
         }
         return this._overlaysByType[param1];
      }
      
      public function hasAttireIdEquipped(param1:String) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this._data.length)
         {
            if(this._data[_loc2_].id == param1)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function hasAttireWithFlag(param1:uint) : Boolean
      {
         var _loc3_:AttireData = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._data.length)
         {
            _loc3_ = this._data[_loc2_];
            if((_loc3_.flags & param1) != 0)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function copyFrom(param1:HumanAppearance) : void
      {
         this.clear();
         this._forceHair = param1._forceHair;
         this._hideGear = param1._hideGear;
         this._hairColor = param1._hairColor;
         this._skin = param1._skin.clone();
         this._hair = param1._hair.clone();
         this._facialHair = param1._facialHair.clone();
         this._upperBody = param1._upperBody.clone();
         this._lowerBody = param1._lowerBody.clone();
         this._accessories.length = 0;
         var _loc2_:int = 0;
         while(_loc2_ < param1._accessories.length)
         {
            this._accessories.push(param1._accessories[_loc2_].clone());
            _loc2_++;
         }
         this.invalidate();
      }
      
      public function deserialize(param1:String, param2:Object) : void
      {
         var xml:XML;
         var nodeList:Vector.<XML>;
         var accessories:Array;
         var node:XML = null;
         var i:int = 0;
         var len:int = 0;
         var acc:AttireData = null;
         var gender:String = param1;
         var data:Object = param2;
         this.clear();
         xml = XML(ResourceManager.getInstance().getResource("xml/attire.xml").content);
         nodeList = new Vector.<XML>();
         this._forceHair = data.forceHair === true;
         this._hideGear = data.hideGear === true;
         this._hairColor = data.hairColor != null ? data.hairColor : "black";
         if(data.skinColor)
         {
            node = xml.item.(@type == "skin" && @id == data.skinColor)[0];
            if(node != null)
            {
               this._skin.parseXML(node,gender);
            }
         }
         if(data.hair)
         {
            node = xml.item.(@type == "hair" && @id == data.hair)[0];
            if(node != null)
            {
               this._hair.parseXML(node,gender);
            }
         }
         if(data.facialHair)
         {
            node = xml.item.(@type == "fhair" && @id == data.facialHair)[0];
            if(node != null)
            {
               this._facialHair.parseXML(node,gender);
            }
         }
         if(data.clothing_upper)
         {
            node = xml.item.(@type == "upper" && @id == data.clothing_upper)[0];
            if(node != null)
            {
               this._upperBody.parseXML(node,gender);
            }
         }
         if(data.clothing_lower)
         {
            node = xml.item.(@type == "lower" && @id == data.clothing_lower)[0];
            if(node != null)
            {
               this._lowerBody.parseXML(node,gender);
            }
         }
         accessories = data.accessories as Array;
         if(accessories != null)
         {
            i = 0;
            len = int(accessories.length);
            while(i < len)
            {
               node = xml.item.(@type == "acc" && @id == accessories[i])[0];
               if(node != null)
               {
                  acc = new AttireData();
                  acc.parseXML(node,gender);
                  this._accessories.push(acc);
                  nodeList.push(node);
               }
               i++;
            }
         }
         this.invalidate();
      }
      
      private function rebuildDataList() : void
      {
         var hairTexNode:XML;
         var xml:XML = null;
         var upperReplaced:Boolean = false;
         var lowerReplaced:Boolean = false;
         var d:AttireData = null;
         var i:int = 0;
         var j:int = 0;
         var numOverlays:int = 0;
         var overlay:AttireOverlay = null;
         var overlayList:Array = null;
         this._data.length = 0;
         this._resourceList.length = 0;
         this._flags = AttireFlags.NONE;
         xml = ResourceManager.getInstance().get("xml/attire.xml") as XML;
         if(!xml)
         {
            return;
         }
         hairTexNode = xml.hair_textures.tex.(@id == _hairColor)[0];
         if(hairTexNode != null)
         {
            this._hair.texture = this._facialHair.texture = hairTexNode.@uri.toString();
         }
         upperReplaced = false;
         lowerReplaced = false;
         for each(d in this._accessories)
         {
            this.addToDataListRecursive(d);
            if((d.flags & AttireFlags.UPPER_BODY) != 0)
            {
               upperReplaced = true;
            }
            if((d.flags & AttireFlags.LOWER_BODY) != 0)
            {
               lowerReplaced = true;
            }
         }
         this._baseAttire = new <AttireData>[this._skin,this._hair,this._facialHair];
         if(!upperReplaced)
         {
            this._baseAttire.push(this._upperBody);
         }
         if(!lowerReplaced)
         {
            this._baseAttire.push(this._lowerBody);
         }
         for each(d in this._baseAttire)
         {
            this.addToDataListRecursive(d);
         }
         this._overlaysByType = new Dictionary(true);
         i = int(this._data.length - 1);
         while(i >= 0)
         {
            d = this._data[i];
            if(d.type == "hair" && !this._forceHair && (this._flags & AttireFlags.NO_HAIR) != 0)
            {
               this._data.splice(i,1);
            }
            else if(d.type == "fhair" && (this._flags & AttireFlags.NO_FACIAL_HAIR) != 0)
            {
               this._data.splice(i,1);
            }
            else if(d.type == "gear" && this._hideGear)
            {
               this._data.splice(i,1);
            }
            else
            {
               j = 0;
               numOverlays = int(d.overlays.length);
               while(j < numOverlays)
               {
                  overlay = d.overlays[j];
                  overlayList = this._overlaysByType[overlay.type];
                  if(overlayList == null)
                  {
                     overlayList = this._overlaysByType[overlay.type] = [];
                  }
                  overlayList.push(overlay.texture);
                  j++;
               }
               d.getResourceURIs(this._resourceList);
            }
            i--;
         }
         this._invalid = false;
      }
      
      private function addToDataListRecursive(param1:AttireData) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:uint = uint(this._flags & ~(AttireFlags.NO_HAIR | AttireFlags.NO_FACIAL_HAIR));
         var _loc3_:uint = uint(param1.flags & ~(AttireFlags.NO_HAIR | AttireFlags.NO_FACIAL_HAIR));
         if((_loc2_ & _loc3_) != 0)
         {
            return;
         }
         if(param1.type == "acc" && this.hasAttireIdEquipped(param1.id))
         {
            return;
         }
         this._flags |= param1.flags;
         this._data.push(param1);
         var _loc4_:int = 0;
         while(_loc4_ < param1.children.length)
         {
            this.addToDataListRecursive(param1.children[_loc4_]);
            _loc4_++;
         }
      }
   }
}

