package thelaststand.app.game.data.effects
{
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.EffectItem;
   import thelaststand.app.game.data.ItemAttributes;
   import thelaststand.app.game.data.ItemQualityType;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.logic.TimerManager;
   import thelaststand.common.io.ISerializable;
   import thelaststand.common.resources.ResourceManager;
   
   public class Effect implements ISerializable
   {
      
      protected var _id:String;
      
      protected var _active:Boolean;
      
      protected var _cooldownTime:int;
      
      protected var _type:String;
      
      protected var _timer:TimerData;
      
      protected var _lockoutTimer:TimerData;
      
      protected var _iconURI:String;
      
      protected var _imageURI:String;
      
      protected var _group:String;
      
      protected var _lockTime:int;
      
      protected var _started:Boolean;
      
      protected var _effectList:Vector.<EffectData>;
      
      protected var _isChallenge:Boolean = false;
      
      protected var _itemId:String;
      
      protected var _item:EffectItem;
      
      protected var _rawData:ByteArray;
      
      protected var _attributes:ItemAttributes;
      
      protected var _quality:int;
      
      public var expired:Signal;
      
      public var lockoutComplete:Signal;
      
      public function Effect()
      {
         super();
         this._effectList = new Vector.<EffectData>();
         this.expired = new Signal(Effect);
         this.lockoutComplete = new Signal(Effect);
      }
      
      public function dispose() : void
      {
         this.expired.removeAll();
         this.lockoutComplete.removeAll();
         this._type = null;
         if(this._timer != null)
         {
            this._timer.completed.remove(this.onTimerCompleted);
            this._timer.dispose();
            this._timer = null;
         }
         if(this._lockoutTimer != null)
         {
            this._lockoutTimer.completed.remove(this.onLockoutTimerCompleted);
            this._lockoutTimer.dispose();
            this._lockoutTimer = null;
         }
      }
      
      public function getEffect(param1:int) : EffectData
      {
         if(param1 < 0 || param1 >= this._effectList.length)
         {
            return null;
         }
         return this._effectList[param1];
      }
      
      public function getValue(param1:uint) : Number
      {
         var _loc3_:EffectData = null;
         var _loc2_:Number = 0;
         for each(_loc3_ in this._effectList)
         {
            if(_loc3_.type == param1)
            {
               _loc2_ += _loc3_.value;
            }
         }
         return _loc2_;
      }
      
      public function hasEffectType(param1:uint) : Boolean
      {
         var _loc2_:EffectData = null;
         for each(_loc2_ in this._effectList)
         {
            if(_loc2_.type == param1)
            {
               return true;
            }
         }
         return false;
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         return null;
      }
      
      public function readLootXML(param1:XML) : void
      {
         var effectId:String = null;
         var effectVar:String = null;
         var xml:XML = null;
         var node:XML = null;
         var varNode:XML = null;
         var numEffects:int = 0;
         var i:int = 0;
         var data:EffectData = null;
         var effNode:XML = null;
         var lootNode:XML = param1;
         effectId = lootNode.@e.toString();
         effectVar = lootNode.@v.toString();
         this._type = effectId;
         this._id = GUID.create();
         this.readFromXmlDescriptor();
         xml = ResourceManager.getInstance().getResource("xml/effects.xml").content;
         node = xml.effect.(@id == _type)[0];
         varNode = node.version.(@id == effectVar)[0];
         this._lockTime = int(varNode.lock);
         this._cooldownTime = int(varNode.cool);
         if(varNode.time.length() > 0)
         {
            this._started = false;
            this._timer = new TimerData(null,int(varNode.time[0].toString()),this);
         }
         else
         {
            this._timer = null;
         }
         numEffects = int(varNode.effect.length());
         this._effectList.length = numEffects;
         i = 0;
         while(i < numEffects)
         {
            data = new EffectData();
            effNode = varNode.effect[i];
            data.type = EffectType.getTypeValue(effNode.type.toString());
            data.value = int(effNode.val);
            this._effectList[i] = data;
            i++;
         }
      }
      
      public function readObject(param1:Object) : void
      {
         var _loc5_:Date = null;
         var _loc6_:Date = null;
         var _loc7_:EffectData = null;
         var _loc2_:ByteArray = ByteArray(param1);
         _loc2_.endian = Endian.LITTLE_ENDIAN;
         _loc2_.position = 0;
         this._rawData = _loc2_;
         this._type = _loc2_.readUTF();
         this._id = _loc2_.readUTF();
         _loc2_.readByte();
         this._lockTime = _loc2_.readInt();
         this._cooldownTime = _loc2_.readInt();
         this._timer = null;
         if(_loc2_.readUnsignedByte() != 0)
         {
            this._started = _loc2_.readBoolean();
            this._timer = new TimerData(null,_loc2_.readInt(),this);
            if(this._started)
            {
               _loc5_ = new Date(_loc2_.readDouble());
               this._timer.timeStart = _loc5_;
               if(!this._timer.hasEnded())
               {
                  this._timer.data.type = "consume";
                  this._timer.completed.addOnce(this.onTimerCompleted);
                  TimerManager.getInstance().addTimer(this._timer);
               }
               else
               {
                  this._timer.dispose();
               }
            }
         }
         if(_loc2_.readUnsignedByte() != 0)
         {
            _loc6_ = new Date(_loc2_.readDouble());
            this._lockoutTimer = new TimerData(_loc6_,this._lockTime,this);
            if(!this._lockoutTimer.hasEnded())
            {
               this._lockoutTimer.data.type = "lockout";
               this._lockoutTimer.completed.addOnce(this.onLockoutTimerCompleted);
               TimerManager.getInstance().addTimer(this._lockoutTimer);
            }
            else
            {
               this._lockoutTimer.dispose();
            }
         }
         var _loc3_:int = int(_loc2_.readUnsignedByte());
         this._effectList.length = _loc3_;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc7_ = new EffectData();
            _loc7_.type = _loc2_.readShort();
            _loc7_.value = _loc2_.readFloat();
            this._effectList[_loc4_] = _loc7_;
            _loc4_++;
         }
         this._itemId = null;
         if(_loc2_.readUnsignedByte() != 0)
         {
            this._itemId = _loc2_.readUTF();
         }
         this.readFromXmlDescriptor();
      }
      
      private function readFromXmlDescriptor() : void
      {
         var xml:XML = null;
         var node:XML = null;
         var attNode:XML = null;
         if(!this._type)
         {
            return;
         }
         xml = ResourceManager.getInstance().getResource("xml/effects.xml").content;
         node = xml.effect.(@id == _type)[0];
         this._isChallenge = Boolean(node.@chg == "1");
         this._group = node.group.toString();
         this._iconURI = node.icon.@uri.toString();
         this._imageURI = node.img.@uri.toString();
         this._quality = node.hasOwnProperty("@quality") ? int(ItemQualityType.getValue(node.@quality)) : ItemQualityType.NONE;
         attNode = node.attributes[0];
         if(attNode != null)
         {
            this._attributes = new ItemAttributes();
            this._attributes.addModValuesFromXML(ItemAttributes.GROUP_SURVIVOR,attNode.srv.children(),0,0);
            this._attributes.addModValuesFromXML(ItemAttributes.GROUP_WEAPON,attNode.weap.children(),0,0);
            this._attributes.addModValuesFromXML(ItemAttributes.GROUP_GEAR,attNode.gear.children(),0,0);
         }
      }
      
      private function onTimerCompleted(param1:TimerData) : void
      {
         this._timer.completed.remove(this.onTimerCompleted);
         this.expired.dispatch(this);
      }
      
      private function onLockoutTimerCompleted(param1:TimerData) : void
      {
         this._lockoutTimer.completed.remove(this.onLockoutTimerCompleted);
         this._lockoutTimer = null;
         this.lockoutComplete.dispatch(this);
      }
      
      public function get active() : Boolean
      {
         return this._active;
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function get timer() : TimerData
      {
         return this._timer;
      }
      
      public function get lockoutTimer() : TimerData
      {
         return this._lockoutTimer;
      }
      
      public function get lockoutTime() : int
      {
         return this._lockTime;
      }
      
      public function get iconURI() : String
      {
         return this._iconURI;
      }
      
      public function get imageURI() : String
      {
         return this._imageURI;
      }
      
      public function get time() : int
      {
         return this._timer != null ? this._timer.length : 0;
      }
      
      public function get isChallenge() : Boolean
      {
         return this._isChallenge;
      }
      
      public function get group() : String
      {
         return this._group;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get itemId() : String
      {
         return this._itemId;
      }
      
      public function get item() : EffectItem
      {
         return this._item;
      }
      
      public function set item(param1:EffectItem) : void
      {
         this._item = param1;
      }
      
      public function get numEffects() : int
      {
         return this._effectList.length;
      }
      
      public function get cooldownTime() : int
      {
         return this._cooldownTime;
      }
      
      public function get rawData() : ByteArray
      {
         return this._rawData;
      }
      
      public function get attributes() : ItemAttributes
      {
         return this._attributes;
      }
      
      public function get quality() : int
      {
         return this._quality;
      }
   }
}

