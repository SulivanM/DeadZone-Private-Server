package alternativa.engine3d.materials.compiler
{
   import alternativa.engine3d.alternativa3d;
   import flash.display3D.Context3DProgramType;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.Endian;
   
   use namespace alternativa3d;
   
   public class Linker
   {
      
      public var data:ByteArray = null;
      
      public var slotsCount:int = 0;
      
      public var commandsCount:int = 0;
      
      public var type:String;
      
      private var procedures:Vector.<Procedure> = new Vector.<Procedure>();
      
      alternativa3d var _linkedVariables:Object;
      
      private var _localVariables:Object = {};
      
      private var _inputParams:Dictionary = new Dictionary();
      
      private var _outputParams:Dictionary = new Dictionary();
      
      private var _locals:Vector.<uint> = new Vector.<uint>(7,true);
      
      private var samplers:Object = {};
      
      private var _varyings:Object = {};
      
      public function Linker(param1:String)
      {
         super();
         this.type = param1;
      }
      
      public function clear() : void
      {
         this.data = null;
         this._locals[0] = this._locals[1] = this._locals[2] = this._locals[3] = this._locals[4] = this._locals[5] = this._locals[6] = 0;
         this.procedures.length = 0;
         this._varyings = {};
         this.samplers = {};
         this.commandsCount = 0;
         this.slotsCount = 0;
         this.alternativa3d::_linkedVariables = null;
         this._inputParams = new Dictionary();
         this._outputParams = new Dictionary();
      }
      
      public function addProcedure(param1:Procedure, ... rest) : void
      {
         var _loc3_:Variable = null;
         var _loc4_:Variable = null;
         for each(_loc3_ in param1.variablesUsages[VariableType.VARYING])
         {
            if(_loc3_ != null)
            {
               _loc4_ = this._varyings[_loc3_.name] = new Variable();
               _loc4_.name = _loc3_.name;
               _loc4_.type = _loc3_.type;
               _loc4_.index = -1;
            }
         }
         this.procedures.push(param1);
         this._inputParams[param1] = rest;
         this.data = null;
      }
      
      public function declareVariable(param1:String, param2:uint = 2) : void
      {
         var _loc3_:Variable = new Variable();
         _loc3_.index = -1;
         _loc3_.type = param2;
         _loc3_.name = param1;
         this._localVariables[param1] = _loc3_;
         if(_loc3_.type == VariableType.VARYING)
         {
            this._varyings[_loc3_.name] = _loc3_;
         }
         this.data = null;
      }
      
      public function declareSampler(param1:String, param2:String, param3:String, param4:String) : void
      {
         if(this._localVariables[param2] == null)
         {
            throw new ArgumentError("Undefined variable " + param2);
         }
         if(this._localVariables[param3] == null)
         {
            throw new ArgumentError("Undefined variable " + param3);
         }
         if(this._localVariables[param1] == null)
         {
            this.declareVariable(param1,2);
         }
         this.data = null;
      }
      
      public function setInputParams(param1:Procedure, ... rest) : void
      {
         this._inputParams[param1] = rest;
         this.data = null;
      }
      
      public function setOutputParams(param1:Procedure, ... rest) : void
      {
         this._outputParams[param1] = rest;
         this.data = null;
      }
      
      public function getVariableIndex(param1:String) : int
      {
         if(this.alternativa3d::_linkedVariables == null)
         {
            throw new Error("Not linked");
         }
         var _loc2_:Variable = this.alternativa3d::_linkedVariables[param1];
         if(_loc2_ == null)
         {
            throw new Error("Variable \"" + param1 + "\" not found");
         }
         return _loc2_.index;
      }
      
      public function findVariable(param1:String) : int
      {
         if(this.alternativa3d::_linkedVariables == null)
         {
            throw new Error("Has not linked");
         }
         var _loc2_:Variable = this.alternativa3d::_linkedVariables[param1];
         if(_loc2_ == null)
         {
            return -1;
         }
         return _loc2_.index;
      }
      
      public function containsVariable(param1:String) : Boolean
      {
         if(this.alternativa3d::_linkedVariables == null)
         {
            throw new Error("Not linked");
         }
         return this.alternativa3d::_linkedVariables[param1] != null;
      }
      
      public function link(param1:uint = 1) : void
      {
         var _loc2_:Variable = null;
         var _loc4_:Procedure = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Variable = null;
         var _loc8_:int = 0;
         var _loc9_:Vector.<Variable> = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:Array = null;
         var _loc13_:Array = null;
         var _loc14_:String = null;
         var _loc15_:int = 0;
         var _loc16_:Vector.<Variable> = null;
         var _loc17_:Variable = null;
         var _loc18_:Variable = null;
         if(this.data != null)
         {
            return;
         }
         var _loc3_:Object = this.alternativa3d::_linkedVariables = {};
         for each(_loc2_ in this._localVariables)
         {
            _loc7_ = _loc3_[_loc2_.name] = new Variable();
            _loc7_.index = -1;
            _loc7_.type = _loc2_.type;
            _loc7_.name = _loc2_.name;
            _loc7_.size = _loc2_.size;
         }
         this.data = new ByteArray();
         this.data.endian = Endian.LITTLE_ENDIAN;
         this.data.writeByte(160);
         this.data.writeUnsignedInt(param1);
         this.data.writeByte(161);
         this.data.writeByte(this.type == Context3DProgramType.FRAGMENT ? 1 : 0);
         this.commandsCount = 0;
         this.slotsCount = 0;
         this._locals[0] = 0;
         this._locals[1] = 0;
         this._locals[2] = 0;
         this._locals[3] = 0;
         this._locals[4] = 0;
         this._locals[5] = 0;
         this._locals[6] = 0;
         for each(_loc4_ in this.procedures)
         {
            this._locals[1] += _loc4_.alternativa3d::reservedConstants;
            _loc8_ = int(_loc4_.variablesUsages.length);
            _loc5_ = 0;
            while(_loc5_ < _loc8_)
            {
               _loc9_ = _loc4_.variablesUsages[_loc5_];
               _loc10_ = int(_loc9_.length);
               _loc6_ = 0;
               while(_loc6_ < _loc10_)
               {
                  _loc2_ = _loc9_[_loc6_];
                  if(!(_loc2_ == null || _loc2_.name == null))
                  {
                     if(_loc2_.name == null && _loc5_ != 2 && _loc5_ != 3 && _loc5_ != 6 && _loc5_ != 7)
                     {
                        throw new Error("Linkage error: Noname variable. Procedure =  " + _loc4_.name + ", type = " + _loc5_.toString() + ", index = " + _loc6_.toString());
                     }
                     _loc7_ = _loc3_[_loc2_.name] = new Variable();
                     _loc7_.index = -1;
                     _loc7_.type = _loc2_.type;
                     _loc7_.name = _loc2_.name;
                     _loc7_.size = _loc2_.size;
                  }
                  _loc6_++;
               }
               _loc5_++;
            }
         }
         for each(_loc4_ in this.procedures)
         {
            _loc11_ = int(this.data.length);
            this.data.position = this.data.length;
            this.data.writeBytes(_loc4_.byteCode,0,_loc4_.byteCode.length);
            _loc12_ = this._inputParams[_loc4_];
            _loc13_ = this._outputParams[_loc4_];
            if(_loc12_ != null)
            {
               _loc15_ = int(_loc12_.length);
               _loc6_ = 0;
               while(_loc6_ < _loc15_)
               {
                  _loc14_ = _loc12_[_loc6_];
                  _loc2_ = _loc3_[_loc14_];
                  if(_loc2_ == null)
                  {
                     throw new Error("Input parameter not set. paramName = " + _loc14_);
                  }
                  if(_loc4_.variablesUsages[7].length > _loc6_)
                  {
                     _loc17_ = _loc4_.variablesUsages[7][_loc6_];
                     if(_loc17_ == null)
                     {
                        throw new Error("Input parameter set, but not used in code. paramName = " + _loc14_ + ", register = i" + _loc6_.toString());
                     }
                     if(_loc2_.index < 0)
                     {
                        _loc2_.index = this._locals[_loc2_.type];
                        this._locals[_loc2_.type] += _loc2_.size;
                     }
                     while(_loc17_ != null)
                     {
                        _loc17_.writeToByteArray(this.data,_loc2_.index,_loc2_.type,_loc11_);
                        _loc17_ = _loc17_.next;
                     }
                  }
                  _loc6_++;
               }
            }
            if(_loc13_ != null)
            {
               _loc15_ = int(_loc13_.length);
               _loc6_ = 0;
               while(_loc6_ < _loc15_)
               {
                  _loc14_ = _loc13_[_loc6_];
                  _loc2_ = _loc3_[_loc14_];
                  if(_loc2_ == null)
                  {
                     if(!(_loc6_ == 0 && _loc5_ == this.procedures.length - 1))
                     {
                        throw new Error("Output parameter not declared. paramName = " + _loc14_);
                     }
                  }
                  else
                  {
                     if(_loc2_.index < 0)
                     {
                        if(_loc2_.type != 2)
                        {
                           throw new Error("Wrong output type:" + VariableType.TYPE_NAMES[_loc2_.type]);
                        }
                        _loc2_.index = this._locals[_loc2_.type];
                        this._locals[_loc2_.type] += _loc2_.size;
                     }
                     _loc18_ = _loc4_.variablesUsages[3][_loc6_];
                     if(_loc18_ == null)
                     {
                        throw new Error("Output parameter set, but not exist in code. paramName = " + _loc14_ + ", register = i" + _loc6_.toString());
                     }
                     while(_loc18_ != null)
                     {
                        _loc18_.writeToByteArray(this.data,_loc2_.index,_loc2_.type,_loc11_);
                        _loc18_ = _loc18_.next;
                     }
                  }
                  _loc6_++;
               }
            }
            _loc16_ = _loc4_.variablesUsages[2];
            _loc6_ = 0;
            while(_loc6_ < _loc16_.length)
            {
               _loc2_ = _loc16_[_loc6_];
               if(_loc2_ != null)
               {
                  while(_loc2_ != null)
                  {
                     _loc2_.writeToByteArray(this.data,this._locals[2] + _loc2_.index,VariableType.TEMPORARY,_loc11_);
                     _loc2_ = _loc2_.next;
                  }
               }
               _loc6_++;
            }
            this.resolveVariablesUsages(this.data,_loc3_,_loc4_.variablesUsages[0],VariableType.ATTRIBUTE,_loc11_);
            this.resolveVariablesUsages(this.data,_loc3_,_loc4_.variablesUsages[1],VariableType.CONSTANT,_loc11_);
            this.resolveVariablesUsages(this.data,this._varyings,_loc4_.variablesUsages[4],VariableType.VARYING,_loc11_);
            this.resolveVariablesUsages(this.data,_loc3_,_loc4_.variablesUsages[5],VariableType.SAMPLER,_loc11_);
            this.commandsCount += _loc4_.commandsCount;
            this.slotsCount += _loc4_.slotsCount;
         }
      }
      
      private function resolveVariablesUsages(param1:ByteArray, param2:Object, param3:Vector.<Variable>, param4:uint, param5:int) : void
      {
         var _loc7_:Variable = null;
         var _loc8_:Variable = null;
         var _loc6_:int = 0;
         while(_loc6_ < param3.length)
         {
            _loc7_ = param3[_loc6_];
            if(_loc7_ != null)
            {
               if(!_loc7_.isRelative)
               {
                  _loc8_ = param2[_loc7_.name];
                  if(_loc8_.index < 0)
                  {
                     _loc8_.index = this._locals[param4];
                     this._locals[param4] += _loc8_.size;
                  }
                  while(_loc7_ != null)
                  {
                     _loc7_.writeToByteArray(param1,_loc8_.index,_loc8_.type,param5);
                     _loc7_ = _loc7_.next;
                  }
               }
            }
            _loc6_++;
         }
      }
      
      public function describeLinkageInfo() : String
      {
         var _loc1_:String = null;
         var _loc6_:Procedure = null;
         var _loc7_:* = undefined;
         var _loc2_:* = "LINKER:\n";
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         var _loc5_:int = 0;
         while(_loc5_ < this.procedures.length)
         {
            _loc6_ = this.procedures[_loc5_];
            if(_loc6_.name != null)
            {
               _loc2_ += _loc6_.name + "(";
            }
            else
            {
               _loc2_ += "#" + _loc5_.toString() + "(";
            }
            _loc7_ = this._inputParams[_loc6_];
            if(_loc7_ != null)
            {
               for each(_loc1_ in _loc7_)
               {
                  _loc2_ += _loc1_ + ",";
               }
               _loc2_ = _loc2_.substr(0,_loc2_.length - 1);
            }
            _loc2_ += ")";
            _loc7_ = this._outputParams[_loc6_];
            if(_loc7_ != null)
            {
               _loc2_ += "->(";
               for each(_loc1_ in _loc7_)
               {
                  _loc2_ += _loc1_ + ",";
               }
               _loc2_ = _loc2_.substr(0,_loc2_.length - 1);
               _loc2_ += ")";
            }
            _loc2_ += " [IS:" + _loc6_.slotsCount.toString() + ", CMDS:" + _loc6_.commandsCount.toString() + "]\n";
            _loc3_ += _loc6_.slotsCount;
            _loc4_ += _loc6_.commandsCount;
            _loc5_++;
         }
         return _loc2_ + ("[IS:" + _loc3_.toString() + ", CMDS:" + _loc4_.toString() + "]\n");
      }
      
      public function get varyings() : Object
      {
         return this._varyings;
      }
      
      public function set varyings(param1:Object) : void
      {
         this._varyings = param1;
         this.data = null;
      }
   }
}

