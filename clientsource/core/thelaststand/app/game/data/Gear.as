package thelaststand.app.game.data
{
   public class Gear extends Item
   {
      
      private var _attireXMLInvalid:Boolean = false;
      
      private var _animType:String;
      
      protected var _attire:Vector.<AttireData>;
      
      protected var _attireXMLList:XMLList;
      
      protected var _gearType:uint = 1;
      
      protected var _gearClass:String;
      
      protected var _requiredSurvivorClass:String = null;
      
      protected var _carryLimit:int = 0;
      
      public var survivorClasses:Vector.<String>;
      
      public var weaponClasses:Vector.<String>;
      
      public var weaponTypes:uint = 0;
      
      public var ammoTypes:uint = 0;
      
      public var activeAttributes:ItemAttributes;
      
      public function Gear(param1:String = null)
      {
         super();
         this._attire = new Vector.<AttireData>();
         _isUpgradable = true;
         this.survivorClasses = new Vector.<String>();
         this.weaponClasses = new Vector.<String>();
         if(param1 != null)
         {
            this.setXML(ItemFactory.getItemDefinition(param1));
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._attireXMLList = null;
         this._attire = null;
      }
      
      override public function clone() : Item
      {
         var _loc1_:Gear = new Gear(_type);
         cloneBaseProperties(_loc1_);
         _loc1_.survivorClasses = this.survivorClasses.concat();
         _loc1_.weaponClasses = this.weaponClasses.concat();
         _loc1_.weaponTypes = this.weaponTypes;
         _loc1_.ammoTypes = this.ammoTypes;
         return _loc1_;
      }
      
      public function supportsWeapon(param1:Weapon) : Boolean
      {
         if(param1 == null)
         {
            return true;
         }
         if(this.weaponClasses.length > 0)
         {
            if(this.weaponClasses.indexOf(param1.weaponClass) == -1)
            {
               return false;
            }
         }
         if(this.weaponTypes != WeaponType.NONE)
         {
            if((param1.weaponType & this.weaponTypes) == 0)
            {
               return false;
            }
         }
         if(this.ammoTypes != AmmoType.NONE)
         {
            if((param1.ammoType & this.ammoTypes) == 0)
            {
               return false;
            }
         }
         return true;
      }
      
      public function supportsSurvivorClass(param1:String) : Boolean
      {
         if(param1 == SurvivorClass.PLAYER)
         {
            return true;
         }
         if(this.survivorClasses.length > 0)
         {
            return this.survivorClasses.indexOf(param1) > -1;
         }
         return true;
      }
      
      public function getAttireList(param1:String) : Vector.<AttireData>
      {
         var _loc4_:AttireData = null;
         var _loc5_:XML = null;
         if(this._attireXMLInvalid)
         {
            this.updateAttireXMLList();
         }
         var _loc2_:int = int(this._attireXMLList.length());
         this._attire.length = _loc2_;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = this._attire[_loc3_];
            if(_loc4_ == null)
            {
               _loc4_ = this._attire[_loc3_] = new AttireData();
            }
            _loc5_ = this._attireXMLList[_loc3_];
            _loc4_.parseXML(_loc5_,param1);
            if(_loc4_.id == null)
            {
               _loc4_.id = _type + _loc3_;
            }
            _loc3_++;
         }
         return this._attire;
      }
      
      public function getAttireFlags(param1:String) : uint
      {
         var _loc4_:AttireData = null;
         var _loc2_:uint = 0;
         var _loc3_:Vector.<AttireData> = this.getAttireList(param1);
         for each(_loc4_ in _loc3_)
         {
            _loc2_ |= _loc4_.flags;
         }
         return _loc2_;
      }
      
      override public function toString() : String
      {
         return "(Gear id=" + id + ", type=" + type + ", level=" + level + ", mods=" + getMod(0) + "," + getMod(1) + ")";
      }
      
      override protected function setXML(param1:XML) : void
      {
         var _loc2_:XML = null;
         var _loc3_:XMLList = null;
         super.setXML(param1);
         this._gearType = _xml.gear.@active == "1" ? GearType.ACTIVE : GearType.PASSIVE;
         this._gearClass = _xml.gear.cls.toString();
         this._animType = String(_xml.gear.anim[0]);
         this._carryLimit = int(_xml.gear.equip);
         populateSoundsList(_xml.gear.snd.children());
         for each(_loc2_ in _xml.gear.type)
         {
            this._gearType |= GearType[_loc2_.toString().toUpperCase()];
         }
         this.survivorClasses.length = 0;
         for each(_loc2_ in _xml.gear.srv.cls)
         {
            this.survivorClasses.push(_loc2_.toString());
         }
         this.weaponClasses.length = 0;
         for each(_loc2_ in _xml.gear.weap.cls)
         {
            this.weaponClasses.push(_loc2_.toString());
         }
         this.weaponTypes = WeaponType.NONE;
         for each(_loc2_ in _xml.gear.weap.type)
         {
            this.weaponTypes |= WeaponType[_loc2_.toString().toUpperCase()];
         }
         this.ammoTypes = AmmoType.NONE;
         for each(_loc2_ in _xml.gear.weap.ammo)
         {
            this.ammoTypes |= AmmoType[_loc2_.toString().toUpperCase()];
         }
         _loc3_ = _xml.gear.att.children();
         if(_loc3_ != null && _loc3_.length() > 0)
         {
            this.activeAttributes = new ItemAttributes();
            this.activeAttributes.addModValuesFromXML(ItemAttributes.GROUP_SURVIVOR,_loc3_,_level,_minLevel);
         }
         this._attire.length = 0;
         this._attireXMLInvalid = true;
         this.updateAttireXMLList();
      }
      
      private function updateAttireXMLList() : void
      {
         var modId:String = null;
         var modNode:XML = null;
         var modAttire:XML = null;
         var id:String = null;
         var overwrite:Boolean = false;
         var i:int = 0;
         var len:int = 0;
         var attire:XML = null;
         this._attireXMLList = _xml.attire.copy();
         for each(modId in _mods)
         {
            if(modId != null)
            {
               modNode = _xml.mod.children().(@id == modId)[0];
               if(modNode != null)
               {
                  for each(modAttire in modNode.attire)
                  {
                     if("@id" in modAttire)
                     {
                        id = modAttire.@id.toString();
                        overwrite = false;
                        i = 0;
                        len = int(this._attireXMLList.length());
                        while(i < len)
                        {
                           attire = this._attireXMLList[i];
                           if("@id" in attire && attire.@id.toString() == id)
                           {
                              this._attireXMLList[i] = modAttire.copy();
                              overwrite = true;
                              break;
                           }
                           i++;
                        }
                        if(overwrite)
                        {
                           break;
                        }
                     }
                     this._attireXMLList += modAttire.copy();
                  }
               }
            }
         }
         this._attireXMLInvalid = false;
      }
      
      override protected function updateAttributes() : void
      {
         super.updateAttributes();
         _attributes.addBaseValuesFromXML(ItemAttributes.GROUP_GEAR,_xml.gear.children(),_level,_minLevel);
         _attributes.addModValuesFromXML(ItemAttributes.GROUP_WEAPON,_xml.gear.weap.children(),_level,_minLevel);
         _attributes.addModValuesFromXML(ItemAttributes.GROUP_SURVIVOR,_xml.gear.srv.children(),_level,_minLevel);
      }
      
      public function get animType() : String
      {
         return this._animType;
      }
      
      public function get gearType() : uint
      {
         return this._gearType;
      }
      
      public function get gearClass() : String
      {
         return this._gearClass;
      }
      
      public function get carryLimit() : int
      {
         return this._carryLimit;
      }
      
      public function get isActiveGear() : Boolean
      {
         return (this._gearType & GearType.ACTIVE) != 0;
      }
   }
}

