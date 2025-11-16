package thelaststand.app.game.data
{
   import thelaststand.common.resources.ResourceManager;
   
   public class SurvivorAppearance extends HumanAppearance
   {
      
      public static const SLOT_UPPER_BODY:String = "clothing_upper";
      
      public static const SLOT_LOWER_BODY:String = "clothing_lower";
      
      private var _survivor:Survivor;
      
      private var _activeLoadout:SurvivorLoadout;
      
      public function SurvivorAppearance(param1:Survivor)
      {
         super();
         this._survivor = param1;
         this._survivor.activeLoadoutChanged.add(this.onActiveLoadoutChanged);
         this._survivor.accessoriesChanged.add(this.onAccessoriesChanged);
         this._activeLoadout = this._survivor.activeLoadout;
         if(this._activeLoadout != null)
         {
            this._activeLoadout.gearPassive.changed.add(this.onLoadoutItemChanged);
         }
         this.rebuildAccessoryList();
      }
      
      public function get survivor() : Survivor
      {
         return this._survivor;
      }
      
      public function setToCurrentClass(param1:String) : void
      {
         var xml:XML;
         var upperNode:XML = null;
         var lowerNode:XML = null;
         var gender:String = param1;
         var cls:String = this._survivor.classId;
         if(cls == SurvivorClass.UNASSIGNED)
         {
            return;
         }
         xml = ResourceManager.getInstance().getResource("xml/attire.xml").content;
         if(cls == SurvivorClass.PLAYER)
         {
            upperNode = xml.item.(@type == "upper" && @id == _upperBody.id)[0];
            lowerNode = xml.item.(@type == "lower" && @id == _lowerBody.id)[0];
         }
         else
         {
            upperNode = xml.item.(@type == "upper" && @id == "class_" + cls)[0];
            lowerNode = xml.item.(@type == "lower" && @id == "class_" + cls)[0];
            if(upperNode == null)
            {
               throw new Error("No upper definition found for class \'" + cls + "\'");
            }
            if(lowerNode == null)
            {
               throw new Error("No lower definition found for class \'" + cls + "\'");
            }
         }
         if(upperNode != null)
         {
            upperBody.parseXML(upperNode,gender);
         }
         if(lowerNode != null)
         {
            lowerBody.parseXML(lowerNode,gender);
         }
         this.invalidate();
         changed.dispatch();
      }
      
      override public function invalidate() : void
      {
         this.rebuildAccessoryList();
         super.invalidate();
      }
      
      public function serialize() : Object
      {
         var _loc1_:Object = {};
         if(skin.id != null)
         {
            _loc1_.skinColor = skin.id;
         }
         if(upperBody.id != null)
         {
            _loc1_.upper = upperBody.id;
         }
         if(lowerBody.id != null)
         {
            _loc1_.lower = lowerBody.id;
         }
         if(hair.id != null)
         {
            _loc1_.hair = hair.id;
         }
         if(this._survivor.gender != Gender.FEMALE && facialHair.id != null)
         {
            _loc1_.facialHair = facialHair.id;
         }
         if(hairColor != null)
         {
            _loc1_.hairColor = hairColor;
         }
         _loc1_.forceHair = forceHair;
         _loc1_.hideGear = hideGear;
         return _loc1_;
      }
      
      private function setLoadout(param1:SurvivorLoadout, param2:Boolean = false) : void
      {
         if(param1 == this._activeLoadout)
         {
            return;
         }
         if(this._activeLoadout != null)
         {
            this._activeLoadout.gearPassive.changed.remove(this.onLoadoutItemChanged);
         }
         this._activeLoadout = param1;
         if(this._activeLoadout != null)
         {
            this._activeLoadout.gearPassive.changed.add(this.onLoadoutItemChanged);
         }
         this.invalidate();
         if(!param2)
         {
            changed.dispatch();
         }
      }
      
      private function onActiveLoadoutChanged(param1:Survivor) : void
      {
         this.setLoadout(param1.activeLoadout,false);
      }
      
      private function onLoadoutItemChanged(param1:SurvivorLoadoutData, param2:Item = null, param3:Item = null) : void
      {
         if(param2 == param3)
         {
            return;
         }
         this.invalidate();
         changed.dispatch();
      }
      
      private function onAccessoriesChanged(param1:Survivor) : void
      {
         this.invalidate();
         changed.dispatch();
      }
      
      private function rebuildAccessoryList() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Gear = null;
         accessories.length = 0;
         if(this._survivor.accessories != null)
         {
            _loc1_ = 0;
            while(_loc1_ < this._survivor.accessories.length)
            {
               _loc2_ = this._survivor.accessories[_loc1_] as Gear;
               this.addGearAccessories(_loc2_);
               _loc1_++;
            }
         }
         if(this._activeLoadout != null)
         {
            this.addGearAccessories(this._activeLoadout.gearPassive.item as Gear);
         }
      }
      
      private function addGearAccessories(param1:Gear) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:Vector.<AttireData> = param1.getAttireList(this._survivor.gender);
         var _loc3_:int = 0;
         var _loc4_:int = int(_loc2_.length);
         while(_loc3_ < _loc4_)
         {
            accessories.push(_loc2_[_loc3_]);
            _loc3_++;
         }
      }
   }
}

