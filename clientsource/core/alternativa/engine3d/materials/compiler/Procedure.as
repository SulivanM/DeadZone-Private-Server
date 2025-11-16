package alternativa.engine3d.materials.compiler
{
   import alternativa.engine3d.alternativa3d;
   import flash.display3D.Context3DProgramType;
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   
   use namespace alternativa3d;
   
   public class Procedure
   {
      
      alternativa3d static const crc32Table:Vector.<uint> = createCRC32Table();
      
      public var name:String;
      
      alternativa3d var crc32:uint = 0;
      
      public var byteCode:ByteArray = new ByteArray();
      
      public var variablesUsages:Vector.<Vector.<Variable>> = new Vector.<Vector.<Variable>>();
      
      public var slotsCount:int = 0;
      
      public var commandsCount:int = 0;
      
      alternativa3d var reservedConstants:uint = 0;
      
      private const agalParser:RegExp = /[A-Za-z]+(((\[.+\])|(\d+))(\.[xyzw]{1,4})?(\ *\<.*>)?)?/g;
      
      public function Procedure(param1:Array = null, param2:String = null)
      {
         super();
         this.byteCode.endian = Endian.LITTLE_ENDIAN;
         this.name = param2;
         if(param1 != null)
         {
            this.compileFromArray(param1);
         }
      }
      
      private static function createCRC32Table() : Vector.<uint>
      {
         var _loc2_:uint = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc1_:Vector.<uint> = new Vector.<uint>(256);
         _loc3_ = 0;
         while(_loc3_ < 256)
         {
            _loc2_ = uint(_loc3_);
            _loc4_ = 0;
            while(_loc4_ < 8)
            {
               _loc2_ = _loc2_ & 1 ? uint(_loc2_ >> 1 ^ 0xEDB88320) : uint(_loc2_ >> 1);
               _loc4_++;
            }
            _loc1_[_loc3_] = _loc2_;
            _loc3_++;
         }
         return _loc1_;
      }
      
      public static function compileFromArray(param1:Array, param2:String = null) : Procedure
      {
         return new Procedure(param1,param2);
      }
      
      public static function compileFromString(param1:String, param2:String = null) : Procedure
      {
         var _loc3_:Procedure = new Procedure(null,param2);
         _loc3_.compileFromString(param1);
         return _loc3_;
      }
      
      alternativa3d static function createCRC32(param1:ByteArray) : uint
      {
         var _loc4_:int = 0;
         param1.position = 0;
         var _loc2_:uint = param1.length;
         var _loc3_:uint = 4294967295;
         while(_loc2_--)
         {
            _loc4_ = param1.readByte();
            _loc3_ = uint(alternativa3d::crc32Table[(_loc3_ ^ _loc4_) & 0xFF] ^ _loc3_ >> 8);
         }
         return _loc3_ ^ 0xFFFFFFFF;
      }
      
      public function getByteCode(param1:String, param2:uint = 1) : ByteArray
      {
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.endian = Endian.LITTLE_ENDIAN;
         _loc3_.writeByte(160);
         _loc3_.writeUnsignedInt(param2);
         _loc3_.writeByte(161);
         _loc3_.writeByte(param1 == Context3DProgramType.FRAGMENT ? 1 : 0);
         _loc3_.writeBytes(this.byteCode);
         return _loc3_;
      }
      
      private function addVariableUsage(param1:Variable) : void
      {
         var _loc2_:Vector.<Variable> = this.variablesUsages[param1.type];
         var _loc3_:int = param1.index;
         if(_loc3_ >= _loc2_.length)
         {
            _loc2_.length = _loc3_ + 1;
         }
         else
         {
            param1.next = _loc2_[_loc3_];
         }
         _loc2_[_loc3_] = param1;
      }
      
      public function assignVariableName(param1:uint, param2:uint, param3:String, param4:uint = 1) : void
      {
         var _loc5_:Variable = this.variablesUsages[param1][param2];
         while(_loc5_ != null)
         {
            _loc5_.size = param4;
            _loc5_.name = param3;
            _loc5_ = _loc5_.next;
         }
      }
      
      public function compileFromString(param1:String) : void
      {
         var _loc2_:Array = param1.split("\n");
         this.compileFromArray(_loc2_);
      }
      
      public function compileFromArray(param1:Array) : void
      {
         var _loc6_:String = null;
         var _loc7_:Array = null;
         var _loc8_:Array = null;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc11_:String = null;
         var _loc2_:int = 0;
         while(_loc2_ < 8)
         {
            this.variablesUsages[_loc2_] = new Vector.<Variable>();
            _loc2_++;
         }
         this.byteCode.length = 0;
         this.commandsCount = 0;
         this.slotsCount = 0;
         var _loc3_:RegExp = /# *[acvs]\d{1,3} *= *[a-zA-Z0-9_]*/i;
         var _loc4_:Vector.<String> = new Vector.<String>();
         var _loc5_:int = int(param1.length);
         _loc2_ = 0;
         while(_loc2_ < _loc5_)
         {
            _loc6_ = param1[_loc2_];
            _loc7_ = _loc6_.match(_loc3_);
            if(_loc7_ != null && _loc7_.length > 0)
            {
               _loc4_.push(_loc7_[0]);
            }
            else
            {
               this.writeAGALExpression(_loc6_);
            }
            _loc2_++;
         }
         _loc2_ = 0;
         _loc5_ = int(_loc4_.length);
         while(_loc2_ < _loc5_)
         {
            _loc8_ = _loc4_[_loc2_].split("=");
            _loc9_ = _loc8_[0].match(/[acvs]/i);
            _loc10_ = int(_loc8_[0].match(/\d{1,3}/i));
            _loc11_ = _loc8_[1].match(/[a-zA-Z0-9]*/i);
            switch(_loc9_.toLowerCase())
            {
               case "a":
                  this.assignVariableName(VariableType.ATTRIBUTE,_loc10_,_loc11_);
                  break;
               case "c":
                  this.assignVariableName(VariableType.CONSTANT,_loc10_,_loc11_);
                  break;
               case "v":
                  this.assignVariableName(VariableType.VARYING,_loc10_,_loc11_);
                  break;
               case "s":
                  this.assignVariableName(VariableType.SAMPLER,_loc10_,_loc11_);
            }
            _loc2_++;
         }
         this.alternativa3d::crc32 = alternativa3d::createCRC32(this.byteCode);
      }
      
      public function assignConstantsArray(param1:uint = 1) : void
      {
         this.alternativa3d::reservedConstants = param1;
      }
      
      private function writeAGALExpression(param1:String) : void
      {
         var _loc5_:DestinationVariable = null;
         var _loc6_:SourceVariable = null;
         var _loc7_:Variable = null;
         var _loc8_:uint = 0;
         var _loc9_:SourceVariable = null;
         var _loc2_:int = int(param1.indexOf("//"));
         if(_loc2_ >= 0)
         {
            param1 = param1.substr(0,_loc2_);
         }
         var _loc3_:Array = param1.match(this.agalParser);
         var _loc4_:String = _loc3_[0];
         if(_loc4_ == "kil" || _loc4_ == "ife" || _loc4_ == "ine" || _loc4_ == "ifg" || _loc4_ == "ifl")
         {
            _loc6_ = new SourceVariable(_loc3_[1]);
            this.addVariableUsage(_loc6_);
         }
         else if(_loc4_ == "els" || _loc4_ == "eif")
         {
            _loc6_ = null;
            _loc7_ = null;
         }
         else
         {
            _loc5_ = new DestinationVariable(_loc3_[1]);
            this.addVariableUsage(_loc5_);
            _loc6_ = new SourceVariable(_loc3_[2]);
            this.addVariableUsage(_loc6_);
         }
         switch(_loc4_)
         {
            case "mov":
               _loc8_ = CommandType.MOV;
               ++this.slotsCount;
               break;
            case "add":
               _loc8_ = CommandType.ADD;
               _loc7_ = new SourceVariable(_loc3_[3]);
               this.addVariableUsage(_loc7_);
               ++this.slotsCount;
               break;
            case "sub":
               _loc8_ = CommandType.SUB;
               _loc7_ = new SourceVariable(_loc3_[3]);
               this.addVariableUsage(_loc7_);
               ++this.slotsCount;
               break;
            case "mul":
               _loc8_ = CommandType.MUL;
               _loc7_ = new SourceVariable(_loc3_[3]);
               this.addVariableUsage(_loc7_);
               ++this.slotsCount;
               break;
            case "div":
               _loc8_ = CommandType.DIV;
               _loc7_ = new SourceVariable(_loc3_[3]);
               this.addVariableUsage(_loc7_);
               ++this.slotsCount;
               break;
            case "rcp":
               _loc8_ = CommandType.RCP;
               ++this.slotsCount;
               break;
            case "min":
               _loc8_ = CommandType.MIN;
               _loc7_ = new SourceVariable(_loc3_[3]);
               this.addVariableUsage(_loc7_);
               ++this.slotsCount;
               break;
            case "max":
               _loc8_ = CommandType.MAX;
               _loc7_ = new SourceVariable(_loc3_[3]);
               this.addVariableUsage(_loc7_);
               ++this.slotsCount;
               break;
            case "frc":
               _loc8_ = CommandType.FRC;
               ++this.slotsCount;
               break;
            case "sqt":
               _loc8_ = CommandType.SQT;
               ++this.slotsCount;
               break;
            case "rsq":
               _loc8_ = CommandType.RSQ;
               ++this.slotsCount;
               break;
            case "pow":
               _loc8_ = CommandType.POW;
               _loc7_ = new SourceVariable(_loc3_[3]);
               this.addVariableUsage(_loc7_);
               this.slotsCount += 3;
               break;
            case "log":
               _loc8_ = CommandType.LOG;
               ++this.slotsCount;
               break;
            case "exp":
               _loc8_ = CommandType.EXP;
               ++this.slotsCount;
               break;
            case "nrm":
               _loc8_ = CommandType.NRM;
               this.slotsCount += 3;
               break;
            case "sin":
               _loc8_ = CommandType.SIN;
               this.slotsCount += 8;
               break;
            case "cos":
               _loc8_ = CommandType.COS;
               this.slotsCount += 8;
               break;
            case "crs":
               _loc8_ = CommandType.CRS;
               _loc7_ = new SourceVariable(_loc3_[3]);
               this.addVariableUsage(_loc7_);
               this.slotsCount += 2;
               break;
            case "dp3":
               _loc8_ = CommandType.DP3;
               _loc7_ = new SourceVariable(_loc3_[3]);
               this.addVariableUsage(_loc7_);
               ++this.slotsCount;
               break;
            case "dp4":
               _loc8_ = CommandType.DP4;
               _loc7_ = new SourceVariable(_loc3_[3]);
               this.addVariableUsage(_loc7_);
               ++this.slotsCount;
               break;
            case "abs":
               _loc8_ = CommandType.ABS;
               ++this.slotsCount;
               break;
            case "neg":
               _loc8_ = CommandType.NEG;
               ++this.slotsCount;
               break;
            case "sat":
               _loc8_ = CommandType.SAT;
               ++this.slotsCount;
               break;
            case "m33":
               _loc8_ = CommandType.M33;
               _loc7_ = new SourceVariable(_loc3_[3]);
               this.addVariableUsage(_loc7_);
               this.slotsCount += 3;
               break;
            case "m44":
               _loc8_ = CommandType.M44;
               _loc7_ = new SourceVariable(_loc3_[3]);
               this.addVariableUsage(_loc7_);
               this.slotsCount += 4;
               break;
            case "m34":
               _loc8_ = CommandType.M34;
               _loc7_ = new SourceVariable(_loc3_[3]);
               this.addVariableUsage(_loc7_);
               this.slotsCount += 3;
               break;
            case "ddx":
               _loc8_ = CommandType.DDX;
               this.slotsCount += 2;
               break;
            case "ddy":
               _loc8_ = CommandType.DDY;
               this.slotsCount += 2;
               break;
            case "ife":
               _loc8_ = CommandType.IFE;
               _loc7_ = new SourceVariable(_loc3_[2]);
               this.addVariableUsage(_loc7_);
               ++this.slotsCount;
               break;
            case "ine":
               _loc8_ = CommandType.INE;
               _loc7_ = new SourceVariable(_loc3_[2]);
               this.addVariableUsage(_loc7_);
               ++this.slotsCount;
               break;
            case "ifg":
               _loc8_ = CommandType.IFG;
               _loc7_ = new SourceVariable(_loc3_[2]);
               this.addVariableUsage(_loc7_);
               ++this.slotsCount;
               break;
            case "ifl":
               _loc8_ = CommandType.IFL;
               _loc7_ = new SourceVariable(_loc3_[2]);
               this.addVariableUsage(_loc7_);
               ++this.slotsCount;
               break;
            case "els":
               _loc8_ = CommandType.ELS;
               ++this.slotsCount;
               break;
            case "eif":
               _loc8_ = CommandType.EIF;
               ++this.slotsCount;
               break;
            case "ted":
               _loc8_ = CommandType.TED;
               _loc7_ = new SamplerVariable(_loc3_[3]);
               this.addVariableUsage(_loc7_);
               ++this.slotsCount;
               break;
            case "kil":
               _loc8_ = CommandType.KIL;
               ++this.slotsCount;
               break;
            case "tex":
               _loc8_ = CommandType.TEX;
               _loc7_ = new SamplerVariable(_loc3_[3]);
               this.addVariableUsage(_loc7_);
               ++this.slotsCount;
               break;
            case "sge":
               _loc8_ = CommandType.SGE;
               _loc7_ = new SourceVariable(_loc3_[3]);
               this.addVariableUsage(_loc7_);
               ++this.slotsCount;
               break;
            case "slt":
               _loc8_ = CommandType.SLT;
               _loc7_ = new SourceVariable(_loc3_[3]);
               this.addVariableUsage(_loc7_);
               ++this.slotsCount;
               break;
            case "sgn":
               _loc8_ = CommandType.SGN;
               ++this.slotsCount;
               break;
            case "seq":
               _loc8_ = CommandType.SEQ;
               _loc7_ = new SourceVariable(_loc3_[3]);
               this.addVariableUsage(_loc7_);
               ++this.slotsCount;
               break;
            case "sne":
               _loc8_ = CommandType.SNE;
               _loc7_ = new SourceVariable(_loc3_[3]);
               this.addVariableUsage(_loc7_);
               ++this.slotsCount;
         }
         this.byteCode.writeUnsignedInt(_loc8_);
         if(_loc5_ != null)
         {
            _loc5_.position = this.byteCode.position;
            this.byteCode.writeUnsignedInt(_loc5_.lowerCode);
         }
         else
         {
            this.byteCode.writeUnsignedInt(0);
         }
         if(_loc6_ != null)
         {
            _loc6_.position = this.byteCode.position;
            if(_loc6_.relative != null)
            {
               this.addVariableUsage(_loc6_.relative);
               _loc6_.relative.position = this.byteCode.position;
            }
            this.byteCode.writeUnsignedInt(_loc6_.lowerCode);
            this.byteCode.writeUnsignedInt(_loc6_.upperCode);
         }
         else
         {
            this.byteCode.position = this.byteCode.length = this.byteCode.length + 8;
         }
         if(_loc7_ != null)
         {
            _loc7_.position = this.byteCode.position;
            _loc9_ = _loc7_ as SourceVariable;
            if(_loc9_ != null && _loc9_.relative != null)
            {
               this.addVariableUsage(_loc9_.relative);
               _loc9_.relative.position = _loc9_.position;
            }
            this.byteCode.writeUnsignedInt(_loc7_.lowerCode);
            this.byteCode.writeUnsignedInt(_loc7_.upperCode);
         }
         else
         {
            this.byteCode.position = this.byteCode.length = this.byteCode.length + 8;
         }
         ++this.commandsCount;
      }
      
      public function newInstance() : Procedure
      {
         var _loc1_:Procedure = new Procedure();
         _loc1_.byteCode = this.byteCode;
         _loc1_.variablesUsages = this.variablesUsages;
         _loc1_.slotsCount = this.slotsCount;
         _loc1_.alternativa3d::reservedConstants = this.alternativa3d::reservedConstants;
         _loc1_.commandsCount = this.commandsCount;
         _loc1_.name = this.name;
         return _loc1_;
      }
   }
}

