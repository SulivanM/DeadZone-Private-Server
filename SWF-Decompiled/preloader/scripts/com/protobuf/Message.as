package com.protobuf
{
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   import flash.utils.getDefinitionByName;
   
   public class Message
   {
      protected var fieldDescriptors:Array;
      
      public function Message()
      {
         super();
         if(fieldDescriptors == null)
         {
            fieldDescriptors = [];
         }
      }
      
      public function writeToCodedStream(param1:CodedOutputStream) : void
      {
         for each(var _loc3_ in fieldDescriptors)
         {
            if(this[_loc3_.fieldName] == null)
            {
               if(_loc3_.isRequired())
               {
                  trace("Missing required field " + _loc3_.fieldName);
               }
            }
            else if(_loc3_.isRepeated() && this[_loc3_.fieldName] is Array)
            {
               for each(var _loc2_ in this[_loc3_.fieldName])
               {
                  if(_loc3_.isMessage())
                  {
                     param1.writeMessage(_loc3_.fieldNumber,_loc2_);
                  }
                  else
                  {
                     param1.writeField(_loc3_.fieldNumber,_loc2_,_loc3_.type);
                  }
               }
            }
            else if(_loc3_.isMessage())
            {
               if(this[_loc3_.fieldName] is Message)
               {
                  param1.writeMessage(_loc3_.fieldNumber,this[_loc3_.fieldName]);
               }
            }
            else
            {
               param1.writeField(_loc3_.fieldNumber,this[_loc3_.fieldName],_loc3_.type);
            }
         }
      }
      
      public function writeToDataOutput(param1:IDataOutput) : void
      {
         var _loc2_:CodedOutputStream = CodedOutputStream.newInstance(param1);
         writeToCodedStream(_loc2_);
      }
      
      public function readFromCodedStream(param1:CodedInputStream) : void
      {
         var _loc2_:int = 0;
         var _loc4_:Descriptor = null;
         var _loc6_:* = undefined;
         var _loc7_:Class = null;
         var _loc8_:int = 0;
         var _loc3_:ByteArray = null;
         var _loc5_:int = param1.readTag();
         while(_loc5_ != 0)
         {
            _loc2_ = WireFormat.getTagFieldNumber(_loc5_);
            _loc4_ = getDescriptorByFieldNumber(_loc2_);
            if(_loc4_ != null)
            {
               if(_loc4_.isMessage())
               {
                  _loc7_ = getDefinitionByName(_loc4_.messageClass) as Class;
                  _loc6_ = new _loc7_();
                  _loc8_ = param1.readRawVarint32();
                  _loc3_ = param1.readRawBytes(_loc8_);
                  _loc3_.position = 0;
                  _loc6_.readFromDataOutput(_loc3_);
               }
               else
               {
                  _loc6_ = param1.readPrimitiveField(_loc4_.type);
               }
               if(_loc4_.isRepeated() && this[_loc4_.fieldName] is Array)
               {
                  this[_loc4_.fieldName].push(_loc6_);
               }
               else
               {
                  this[_loc4_.fieldName] = _loc6_;
               }
            }
            else
            {
               param1.skipField(_loc5_);
            }
            _loc5_ = param1.readTag();
         }
      }
      
      public function readFromDataOutput(param1:IDataInput) : void
      {
         var _loc2_:CodedInputStream = CodedInputStream.newInstance(param1);
         readFromCodedStream(_loc2_);
      }
      
      public function getSerializedSize() : int
      {
         var _loc2_:int = 0;
         for each(var _loc1_ in fieldDescriptors)
         {
            if(this[_loc1_.fieldName] != null)
            {
               _loc2_ += CodedOutputStream.computeFieldSize(_loc1_.fieldNumber,this[_loc1_.fieldName],_loc1_.type);
            }
         }
         return _loc2_;
      }
      
      protected function registerField(param1:String, param2:String, param3:int, param4:int, param5:int) : void
      {
         if(fieldDescriptors[param1] == null)
         {
            fieldDescriptors[param1] = new Descriptor(param1,param2,param3,param4,param5);
         }
      }
      
      public function getDescriptorByFieldNumber(param1:int) : Descriptor
      {
         for each(var _loc2_ in fieldDescriptors)
         {
            if(_loc2_.fieldNumber == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getDescriptor(param1:String) : Descriptor
      {
         return fieldDescriptors[param1];
      }
   }
}

