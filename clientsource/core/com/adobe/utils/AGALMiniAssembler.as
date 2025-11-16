package com.adobe.utils
{
   import flash.utils.*;
   
   public class AGALMiniAssembler
   {
      
      protected static const USE_NEW_SYNTAX:Boolean = false;
      
      protected static const REGEXP_OUTER_SPACES:RegExp = /^\s+|\s+$/g;
      
      private static var initialized:Boolean = false;
      
      private static const OPMAP:Dictionary = new Dictionary();
      
      private static const REGMAP:Dictionary = new Dictionary();
      
      private static const SAMPLEMAP:Dictionary = new Dictionary();
      
      private static const MAX_NESTING:int = 4;
      
      private static const MAX_OPCODES:int = 256;
      
      private static const FRAGMENT:String = "fragment";
      
      private static const VERTEX:String = "vertex";
      
      private static const SAMPLER_TYPE_SHIFT:uint = 8;
      
      private static const SAMPLER_DIM_SHIFT:uint = 12;
      
      private static const SAMPLER_SPECIAL_SHIFT:uint = 16;
      
      private static const SAMPLER_REPEAT_SHIFT:uint = 20;
      
      private static const SAMPLER_MIPMAP_SHIFT:uint = 24;
      
      private static const SAMPLER_FILTER_SHIFT:uint = 28;
      
      private static const REG_WRITE:uint = 1;
      
      private static const REG_READ:uint = 2;
      
      private static const REG_FRAG:uint = 32;
      
      private static const REG_VERT:uint = 64;
      
      private static const OP_SCALAR:uint = 1;
      
      private static const OP_INC_NEST:uint = 2;
      
      private static const OP_DEC_NEST:uint = 4;
      
      private static const OP_SPECIAL_TEX:uint = 8;
      
      private static const OP_SPECIAL_MATRIX:uint = 16;
      
      private static const OP_FRAG_ONLY:uint = 32;
      
      private static const OP_NO_DEST:uint = 128;
      
      private static const MOV:String = "mov";
      
      private static const ADD:String = "add";
      
      private static const SUB:String = "sub";
      
      private static const MUL:String = "mul";
      
      private static const DIV:String = "div";
      
      private static const RCP:String = "rcp";
      
      private static const MIN:String = "min";
      
      private static const MAX:String = "max";
      
      private static const FRC:String = "frc";
      
      private static const SQT:String = "sqt";
      
      private static const RSQ:String = "rsq";
      
      private static const POW:String = "pow";
      
      private static const LOG:String = "log";
      
      private static const EXP:String = "exp";
      
      private static const NRM:String = "nrm";
      
      private static const SIN:String = "sin";
      
      private static const COS:String = "cos";
      
      private static const CRS:String = "crs";
      
      private static const DP3:String = "dp3";
      
      private static const DP4:String = "dp4";
      
      private static const ABS:String = "abs";
      
      private static const NEG:String = "neg";
      
      private static const SAT:String = "sat";
      
      private static const M33:String = "m33";
      
      private static const M44:String = "m44";
      
      private static const M34:String = "m34";
      
      private static const IFZ:String = "ifz";
      
      private static const INZ:String = "inz";
      
      private static const IFE:String = "ife";
      
      private static const INE:String = "ine";
      
      private static const IFG:String = "ifg";
      
      private static const IFL:String = "ifl";
      
      private static const IEG:String = "ieg";
      
      private static const IEL:String = "iel";
      
      private static const ELS:String = "els";
      
      private static const EIF:String = "eif";
      
      private static const REP:String = "rep";
      
      private static const ERP:String = "erp";
      
      private static const BRK:String = "brk";
      
      private static const KIL:String = "kil";
      
      private static const TEX:String = "tex";
      
      private static const SGE:String = "sge";
      
      private static const SLT:String = "slt";
      
      private static const SGN:String = "sgn";
      
      private static const SEQ:String = "seq";
      
      private static const SNE:String = "sne";
      
      private static const VA:String = "va";
      
      private static const VC:String = "vc";
      
      private static const VT:String = "vt";
      
      private static const VO:String = USE_NEW_SYNTAX ? "vo" : "op";
      
      private static const I:String = USE_NEW_SYNTAX ? "i" : "v";
      
      private static const FC:String = "fc";
      
      private static const FT:String = "ft";
      
      private static const FS:String = "fs";
      
      private static const FO:String = USE_NEW_SYNTAX ? "fo" : "oc";
      
      private static const D2:String = "2d";
      
      private static const D3:String = "3d";
      
      private static const CUBE:String = "cube";
      
      private static const MIPNEAREST:String = "mipnearest";
      
      private static const MIPLINEAR:String = "miplinear";
      
      private static const MIPNONE:String = "mipnone";
      
      private static const NOMIP:String = "nomip";
      
      private static const NEAREST:String = "nearest";
      
      private static const LINEAR:String = "linear";
      
      private static const CENTROID:String = "centroid";
      
      private static const SINGLE:String = "single";
      
      private static const DEPTH:String = "depth";
      
      private static const REPEAT:String = "repeat";
      
      private static const WRAP:String = "wrap";
      
      private static const CLAMP:String = "clamp";
      
      private static const RGBA:String = "rgba";
      
      private static const DXT1:String = "dxt1";
      
      private static const DXT5:String = "dxt5";
      
      private var _agalcode:ByteArray = null;
      
      private var _error:String = "";
      
      private var debugEnabled:Boolean = false;
      
      public var verbose:Boolean = false;
      
      public function AGALMiniAssembler(param1:Boolean = false)
      {
         super();
         this.debugEnabled = param1;
         if(!initialized)
         {
            init();
         }
      }
      
      private static function init() : void
      {
         initialized = true;
         OPMAP[MOV] = new OpCode(MOV,2,0,0);
         OPMAP[ADD] = new OpCode(ADD,3,1,0);
         OPMAP[SUB] = new OpCode(SUB,3,2,0);
         OPMAP[MUL] = new OpCode(MUL,3,3,0);
         OPMAP[DIV] = new OpCode(DIV,3,4,0);
         OPMAP[RCP] = new OpCode(RCP,2,5,0);
         OPMAP[MIN] = new OpCode(MIN,3,6,0);
         OPMAP[MAX] = new OpCode(MAX,3,7,0);
         OPMAP[FRC] = new OpCode(FRC,2,8,0);
         OPMAP[SQT] = new OpCode(SQT,2,9,0);
         OPMAP[RSQ] = new OpCode(RSQ,2,10,0);
         OPMAP[POW] = new OpCode(POW,3,11,0);
         OPMAP[LOG] = new OpCode(LOG,2,12,0);
         OPMAP[EXP] = new OpCode(EXP,2,13,0);
         OPMAP[NRM] = new OpCode(NRM,2,14,0);
         OPMAP[SIN] = new OpCode(SIN,2,15,0);
         OPMAP[COS] = new OpCode(COS,2,16,0);
         OPMAP[CRS] = new OpCode(CRS,3,17,0);
         OPMAP[DP3] = new OpCode(DP3,3,18,0);
         OPMAP[DP4] = new OpCode(DP4,3,19,0);
         OPMAP[ABS] = new OpCode(ABS,2,20,0);
         OPMAP[NEG] = new OpCode(NEG,2,21,0);
         OPMAP[SAT] = new OpCode(SAT,2,22,0);
         OPMAP[M33] = new OpCode(M33,3,23,OP_SPECIAL_MATRIX);
         OPMAP[M44] = new OpCode(M44,3,24,OP_SPECIAL_MATRIX);
         OPMAP[M34] = new OpCode(M34,3,25,OP_SPECIAL_MATRIX);
         OPMAP[IFZ] = new OpCode(IFZ,1,26,OP_NO_DEST | OP_INC_NEST | OP_SCALAR);
         OPMAP[INZ] = new OpCode(INZ,1,27,OP_NO_DEST | OP_INC_NEST | OP_SCALAR);
         OPMAP[IFE] = new OpCode(IFE,2,28,OP_NO_DEST | OP_INC_NEST | OP_SCALAR);
         OPMAP[INE] = new OpCode(INE,2,29,OP_NO_DEST | OP_INC_NEST | OP_SCALAR);
         OPMAP[IFG] = new OpCode(IFG,2,30,OP_NO_DEST | OP_INC_NEST | OP_SCALAR);
         OPMAP[IFL] = new OpCode(IFL,2,31,OP_NO_DEST | OP_INC_NEST | OP_SCALAR);
         OPMAP[IEG] = new OpCode(IEG,2,32,OP_NO_DEST | OP_INC_NEST | OP_SCALAR);
         OPMAP[IEL] = new OpCode(IEL,2,33,OP_NO_DEST | OP_INC_NEST | OP_SCALAR);
         OPMAP[ELS] = new OpCode(ELS,0,34,OP_NO_DEST | OP_INC_NEST | OP_DEC_NEST);
         OPMAP[EIF] = new OpCode(EIF,0,35,OP_NO_DEST | OP_DEC_NEST);
         OPMAP[REP] = new OpCode(REP,1,36,OP_NO_DEST | OP_INC_NEST | OP_SCALAR);
         OPMAP[ERP] = new OpCode(ERP,0,37,OP_NO_DEST | OP_DEC_NEST);
         OPMAP[BRK] = new OpCode(BRK,0,38,OP_NO_DEST);
         OPMAP[KIL] = new OpCode(KIL,1,39,OP_NO_DEST | OP_FRAG_ONLY);
         OPMAP[TEX] = new OpCode(TEX,3,40,OP_FRAG_ONLY | OP_SPECIAL_TEX);
         OPMAP[SGE] = new OpCode(SGE,3,41,0);
         OPMAP[SLT] = new OpCode(SLT,3,42,0);
         OPMAP[SGN] = new OpCode(SGN,2,43,0);
         OPMAP[SEQ] = new OpCode(SEQ,3,44,0);
         OPMAP[SNE] = new OpCode(SNE,3,45,0);
         REGMAP[VA] = new Register(VA,"vertex attribute",0,7,REG_VERT | REG_READ);
         REGMAP[VC] = new Register(VC,"vertex constant",1,127,REG_VERT | REG_READ);
         REGMAP[VT] = new Register(VT,"vertex temporary",2,7,REG_VERT | REG_WRITE | REG_READ);
         REGMAP[VO] = new Register(VO,"vertex output",3,0,REG_VERT | REG_WRITE);
         REGMAP[I] = new Register(I,"varying",4,7,REG_VERT | REG_FRAG | REG_READ | REG_WRITE);
         REGMAP[FC] = new Register(FC,"fragment constant",1,27,REG_FRAG | REG_READ);
         REGMAP[FT] = new Register(FT,"fragment temporary",2,7,REG_FRAG | REG_WRITE | REG_READ);
         REGMAP[FS] = new Register(FS,"texture sampler",5,7,REG_FRAG | REG_READ);
         REGMAP[FO] = new Register(FO,"fragment output",3,0,REG_FRAG | REG_WRITE);
         SAMPLEMAP[RGBA] = new Sampler(RGBA,SAMPLER_TYPE_SHIFT,0);
         SAMPLEMAP[DXT1] = new Sampler(DXT1,SAMPLER_TYPE_SHIFT,1);
         SAMPLEMAP[DXT5] = new Sampler(DXT5,SAMPLER_TYPE_SHIFT,2);
         SAMPLEMAP[D2] = new Sampler(D2,SAMPLER_DIM_SHIFT,0);
         SAMPLEMAP[D3] = new Sampler(D3,SAMPLER_DIM_SHIFT,2);
         SAMPLEMAP[CUBE] = new Sampler(CUBE,SAMPLER_DIM_SHIFT,1);
         SAMPLEMAP[MIPNEAREST] = new Sampler(MIPNEAREST,SAMPLER_MIPMAP_SHIFT,1);
         SAMPLEMAP[MIPLINEAR] = new Sampler(MIPLINEAR,SAMPLER_MIPMAP_SHIFT,2);
         SAMPLEMAP[MIPNONE] = new Sampler(MIPNONE,SAMPLER_MIPMAP_SHIFT,0);
         SAMPLEMAP[NOMIP] = new Sampler(NOMIP,SAMPLER_MIPMAP_SHIFT,0);
         SAMPLEMAP[NEAREST] = new Sampler(NEAREST,SAMPLER_FILTER_SHIFT,0);
         SAMPLEMAP[LINEAR] = new Sampler(LINEAR,SAMPLER_FILTER_SHIFT,1);
         SAMPLEMAP[CENTROID] = new Sampler(CENTROID,SAMPLER_SPECIAL_SHIFT,1 << 0);
         SAMPLEMAP[SINGLE] = new Sampler(SINGLE,SAMPLER_SPECIAL_SHIFT,1 << 1);
         SAMPLEMAP[DEPTH] = new Sampler(DEPTH,SAMPLER_SPECIAL_SHIFT,1 << 2);
         SAMPLEMAP[REPEAT] = new Sampler(REPEAT,SAMPLER_REPEAT_SHIFT,1);
         SAMPLEMAP[WRAP] = new Sampler(WRAP,SAMPLER_REPEAT_SHIFT,1);
         SAMPLEMAP[CLAMP] = new Sampler(CLAMP,SAMPLER_REPEAT_SHIFT,0);
      }
      
      public function get error() : String
      {
         return this._error;
      }
      
      public function get agalcode() : ByteArray
      {
         return this._agalcode;
      }
      
      public function assemble(param1:String, param2:String) : ByteArray
      {
         var _loc8_:int = 0;
         var _loc10_:String = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Array = null;
         var _loc14_:Array = null;
         var _loc15_:OpCode = null;
         var _loc16_:Array = null;
         var _loc17_:Boolean = false;
         var _loc18_:uint = 0;
         var _loc19_:uint = 0;
         var _loc20_:int = 0;
         var _loc21_:Boolean = false;
         var _loc22_:Array = null;
         var _loc23_:Array = null;
         var _loc24_:Register = null;
         var _loc25_:Array = null;
         var _loc26_:uint = 0;
         var _loc27_:uint = 0;
         var _loc28_:Array = null;
         var _loc29_:Boolean = false;
         var _loc30_:Boolean = false;
         var _loc31_:uint = 0;
         var _loc32_:uint = 0;
         var _loc33_:int = 0;
         var _loc34_:uint = 0;
         var _loc35_:uint = 0;
         var _loc36_:int = 0;
         var _loc37_:Array = null;
         var _loc38_:Register = null;
         var _loc39_:Array = null;
         var _loc40_:Array = null;
         var _loc41_:uint = 0;
         var _loc42_:uint = 0;
         var _loc43_:Number = NaN;
         var _loc44_:Sampler = null;
         var _loc45_:* = null;
         var _loc46_:uint = 0;
         var _loc47_:uint = 0;
         var _loc48_:String = null;
         var _loc3_:uint = uint(getTimer());
         this._agalcode = new ByteArray();
         this._error = "";
         var _loc4_:Boolean = false;
         if(param1 == FRAGMENT)
         {
            _loc4_ = true;
         }
         else if(param1 != VERTEX)
         {
            this._error = "ERROR: mode needs to be \"" + FRAGMENT + "\" or \"" + VERTEX + "\" but is \"" + param1 + "\".";
         }
         this.agalcode.endian = Endian.LITTLE_ENDIAN;
         this.agalcode.writeByte(160);
         this.agalcode.writeUnsignedInt(1);
         this.agalcode.writeByte(161);
         this.agalcode.writeByte(_loc4_ ? 1 : 0);
         var _loc5_:Array = param2.replace(/[\f\n\r\v]+/g,"\n").split("\n");
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc9_:int = int(_loc5_.length);
         _loc8_ = 0;
         while(_loc8_ < _loc9_ && this._error == "")
         {
            _loc10_ = new String(_loc5_[_loc8_]);
            _loc10_ = _loc10_.replace(REGEXP_OUTER_SPACES,"");
            _loc11_ = int(_loc10_.search("//"));
            if(_loc11_ != -1)
            {
               _loc10_ = _loc10_.slice(0,_loc11_);
            }
            _loc12_ = int(_loc10_.search(/<.*>/g));
            if(_loc12_ != -1)
            {
               _loc13_ = _loc10_.slice(_loc12_).match(/([\w\.\-\+]+)/gi);
               _loc10_ = _loc10_.slice(0,_loc12_);
            }
            _loc14_ = _loc10_.match(/^\w{3}/ig);
            if(!_loc14_)
            {
               if(_loc10_.length >= 3)
               {
               }
            }
            else
            {
               _loc15_ = OPMAP[_loc14_[0]];
               if(this.debugEnabled)
               {
               }
               if(_loc15_ == null)
               {
                  if(_loc10_.length >= 3)
                  {
                  }
               }
               else
               {
                  _loc10_ = _loc10_.slice(_loc10_.search(_loc15_.name) + _loc15_.name.length);
                  if(_loc15_.flags & OP_DEC_NEST)
                  {
                     if(--_loc6_ < 0)
                     {
                        this._error = "error: conditional closes without open.";
                        break;
                     }
                  }
                  if(_loc15_.flags & OP_INC_NEST)
                  {
                     if(++_loc6_ > MAX_NESTING)
                     {
                        this._error = "error: nesting to deep, maximum allowed is " + MAX_NESTING + ".";
                        break;
                     }
                  }
                  if(Boolean(_loc15_.flags & OP_FRAG_ONLY) && !_loc4_)
                  {
                     this._error = "error: opcode is only allowed in fragment programs.";
                     break;
                  }
                  if(this.verbose)
                  {
                  }
                  this.agalcode.writeUnsignedInt(_loc15_.emitCode);
                  if(++_loc7_ > MAX_OPCODES)
                  {
                     this._error = "error: too many opcodes. maximum is " + MAX_OPCODES + ".";
                     break;
                  }
                  if(USE_NEW_SYNTAX)
                  {
                     _loc16_ = _loc10_.match(/vc\[([vif][acost]?)(\d*)?(\.[xyzw](\+\d{1,3})?)?\](\.[xyzw]{1,4})?|([vif][acost]?)(\d*)?(\.[xyzw]{1,4})?/gi);
                  }
                  else
                  {
                     _loc16_ = _loc10_.match(/vc\[([vof][actps]?)(\d*)?(\.[xyzw](\+\d{1,3})?)?\](\.[xyzw]{1,4})?|([vof][actps]?)(\d*)?(\.[xyzw]{1,4})?/gi);
                  }
                  if(!_loc16_ || _loc16_.length != _loc15_.numRegister)
                  {
                     this._error = "error: wrong number of operands. found " + _loc16_.length + " but expected " + _loc15_.numRegister + ".";
                     break;
                  }
                  _loc17_ = false;
                  _loc18_ = uint(64 + 64 + 32);
                  _loc19_ = _loc16_.length;
                  _loc20_ = 0;
                  while(_loc20_ < _loc19_)
                  {
                     _loc21_ = false;
                     _loc22_ = _loc16_[_loc20_].match(/\[.*\]/ig);
                     if((Boolean(_loc22_)) && _loc22_.length > 0)
                     {
                        _loc16_[_loc20_] = _loc16_[_loc20_].replace(_loc22_[0],"0");
                        if(this.verbose)
                        {
                        }
                        _loc21_ = true;
                     }
                     _loc23_ = _loc16_[_loc20_].match(/^\b[A-Za-z]{1,2}/ig);
                     if(!_loc23_)
                     {
                        this._error = "error: could not parse operand " + _loc20_ + " (" + _loc16_[_loc20_] + ").";
                        _loc17_ = true;
                        break;
                     }
                     _loc24_ = REGMAP[_loc23_[0]];
                     if(this.debugEnabled)
                     {
                     }
                     if(_loc24_ == null)
                     {
                        this._error = "error: could not parse operand " + _loc20_ + " (" + _loc16_[_loc20_] + ").";
                        _loc17_ = true;
                        break;
                     }
                     if(_loc4_)
                     {
                        if(!(_loc24_.flags & REG_FRAG))
                        {
                           this._error = "error: register operand " + _loc20_ + " (" + _loc16_[_loc20_] + ") only allowed in vertex programs.";
                           _loc17_ = true;
                           break;
                        }
                        if(_loc21_)
                        {
                           this._error = "error: register operand " + _loc20_ + " (" + _loc16_[_loc20_] + ") relative adressing not allowed in fragment programs.";
                           _loc17_ = true;
                           break;
                        }
                     }
                     else if(!(_loc24_.flags & REG_VERT))
                     {
                        this._error = "error: register operand " + _loc20_ + " (" + _loc16_[_loc20_] + ") only allowed in fragment programs.";
                        _loc17_ = true;
                        break;
                     }
                     _loc16_[_loc20_] = _loc16_[_loc20_].slice(_loc16_[_loc20_].search(_loc24_.name) + _loc24_.name.length);
                     _loc25_ = _loc21_ ? _loc22_[0].match(/\d+/) : _loc16_[_loc20_].match(/\d+/);
                     _loc26_ = 0;
                     if(_loc25_)
                     {
                        _loc26_ = uint(_loc25_[0]);
                     }
                     if(_loc24_.range < _loc26_)
                     {
                        this._error = "error: register operand " + _loc20_ + " (" + _loc16_[_loc20_] + ") index exceeds limit of " + (_loc24_.range + 1) + ".";
                        _loc17_ = true;
                        break;
                     }
                     _loc27_ = 0;
                     _loc28_ = _loc16_[_loc20_].match(/(\.[xyzw]{1,4})/);
                     _loc29_ = _loc20_ == 0 && !(_loc15_.flags & OP_NO_DEST);
                     _loc30_ = _loc20_ == 2 && Boolean(_loc15_.flags & OP_SPECIAL_TEX);
                     _loc31_ = 0;
                     _loc32_ = 0;
                     _loc33_ = 0;
                     if(_loc29_ && _loc21_)
                     {
                        this._error = "error: relative can not be destination";
                        _loc17_ = true;
                        break;
                     }
                     if(_loc28_)
                     {
                        _loc27_ = 0;
                        _loc35_ = uint(_loc28_[0].length);
                        _loc36_ = 1;
                        while(_loc36_ < _loc35_)
                        {
                           _loc34_ = _loc28_[0].charCodeAt(_loc36_) - "x".charCodeAt(0);
                           if(_loc34_ > 2)
                           {
                              _loc34_ = 3;
                           }
                           if(_loc29_)
                           {
                              _loc27_ |= 1 << _loc34_;
                           }
                           else
                           {
                              _loc27_ |= _loc34_ << (_loc36_ - 1 << 1);
                           }
                           _loc36_++;
                        }
                        if(!_loc29_)
                        {
                           while(_loc36_ <= 4)
                           {
                              _loc27_ |= _loc34_ << (_loc36_ - 1 << 1);
                              _loc36_++;
                           }
                        }
                     }
                     else
                     {
                        _loc27_ = _loc29_ ? 15 : 228;
                     }
                     if(_loc21_)
                     {
                        _loc37_ = _loc22_[0].match(/[A-Za-z]{1,2}/ig);
                        _loc38_ = REGMAP[_loc37_[0]];
                        if(_loc38_ == null)
                        {
                           this._error = "error: bad index register";
                           _loc17_ = true;
                           break;
                        }
                        _loc31_ = _loc38_.emitCode;
                        _loc39_ = _loc22_[0].match(/(\.[xyzw]{1,1})/);
                        if(_loc39_.length == 0)
                        {
                           this._error = "error: bad index register select";
                           _loc17_ = true;
                           break;
                        }
                        _loc32_ = _loc39_[0].charCodeAt(1) - "x".charCodeAt(0);
                        if(_loc32_ > 2)
                        {
                           _loc32_ = 3;
                        }
                        _loc40_ = _loc22_[0].match(/\+\d{1,3}/ig);
                        if(_loc40_.length > 0)
                        {
                           _loc33_ = int(_loc40_[0]);
                        }
                        if(_loc33_ < 0 || _loc33_ > 255)
                        {
                           this._error = "error: index offset " + _loc33_ + " out of bounds. [0..255]";
                           _loc17_ = true;
                           break;
                        }
                        if(this.verbose)
                        {
                        }
                     }
                     if(this.verbose)
                     {
                     }
                     if(_loc29_)
                     {
                        this.agalcode.writeShort(_loc26_);
                        this.agalcode.writeByte(_loc27_);
                        this.agalcode.writeByte(_loc24_.emitCode);
                        _loc18_ -= 32;
                     }
                     else if(_loc30_)
                     {
                        if(this.verbose)
                        {
                        }
                        _loc41_ = 5;
                        _loc42_ = _loc13_ == null ? 0 : _loc13_.length;
                        _loc43_ = 0;
                        _loc36_ = 0;
                        while(_loc36_ < _loc42_)
                        {
                           if(this.verbose)
                           {
                           }
                           _loc44_ = SAMPLEMAP[_loc13_[_loc36_]];
                           if(_loc44_ == null)
                           {
                              _loc43_ = Number(_loc13_[_loc36_]);
                              if(this.verbose)
                              {
                              }
                           }
                           else
                           {
                              if(_loc44_.flag != SAMPLER_SPECIAL_SHIFT)
                              {
                                 _loc41_ &= ~(15 << _loc44_.flag);
                              }
                              _loc41_ |= uint(_loc44_.mask) << uint(_loc44_.flag);
                           }
                           _loc36_++;
                        }
                        this.agalcode.writeShort(_loc26_);
                        this.agalcode.writeByte(int(_loc43_ * 8));
                        this.agalcode.writeByte(0);
                        this.agalcode.writeUnsignedInt(_loc41_);
                        if(this.verbose)
                        {
                        }
                        _loc18_ -= 64;
                     }
                     else
                     {
                        if(_loc20_ == 0)
                        {
                           this.agalcode.writeUnsignedInt(0);
                           _loc18_ -= 32;
                        }
                        this.agalcode.writeShort(_loc26_);
                        this.agalcode.writeByte(_loc33_);
                        this.agalcode.writeByte(_loc27_);
                        this.agalcode.writeByte(_loc24_.emitCode);
                        this.agalcode.writeByte(_loc31_);
                        this.agalcode.writeShort(_loc21_ ? _loc32_ | 1 << 15 : 0);
                        _loc18_ -= 64;
                     }
                     _loc20_++;
                  }
                  _loc20_ = 0;
                  while(_loc20_ < _loc18_)
                  {
                     this.agalcode.writeByte(0);
                     _loc20_ += 8;
                  }
                  if(_loc17_)
                  {
                     break;
                  }
               }
            }
            _loc8_++;
         }
         if(this._error != "")
         {
            this._error += "\n  at line " + _loc8_ + " " + _loc5_[_loc8_];
            this.agalcode.length = 0;
         }
         if(this.debugEnabled)
         {
            _loc45_ = "generated bytecode:";
            _loc46_ = this.agalcode.length;
            _loc47_ = 0;
            while(_loc47_ < _loc46_)
            {
               if(!(_loc47_ % 16))
               {
                  _loc45_ += "\n";
               }
               if(!(_loc47_ % 4))
               {
                  _loc45_ += " ";
               }
               _loc48_ = this.agalcode[_loc47_].toString(16);
               if(_loc48_.length < 2)
               {
                  _loc48_ = "0" + _loc48_;
               }
               _loc45_ += _loc48_;
               _loc47_++;
            }
         }
         if(this.verbose)
         {
         }
         return this.agalcode;
      }
   }
}

class OpCode
{
   
   private var _emitCode:uint;
   
   private var _flags:uint;
   
   private var _name:String;
   
   private var _numRegister:uint;
   
   public function OpCode(param1:String, param2:uint, param3:uint, param4:uint)
   {
      super();
      this._name = param1;
      this._numRegister = param2;
      this._emitCode = param3;
      this._flags = param4;
   }
   
   public function get emitCode() : uint
   {
      return this._emitCode;
   }
   
   public function get flags() : uint
   {
      return this._flags;
   }
   
   public function get name() : String
   {
      return this._name;
   }
   
   public function get numRegister() : uint
   {
      return this._numRegister;
   }
   
   public function toString() : String
   {
      return "[OpCode name=\"" + this._name + "\", numRegister=" + this._numRegister + ", emitCode=" + this._emitCode + ", flags=" + this._flags + "]";
   }
}

class Register
{
   
   private var _emitCode:uint;
   
   private var _name:String;
   
   private var _longName:String;
   
   private var _flags:uint;
   
   private var _range:uint;
   
   public function Register(param1:String, param2:String, param3:uint, param4:uint, param5:uint)
   {
      super();
      this._name = param1;
      this._longName = param2;
      this._emitCode = param3;
      this._range = param4;
      this._flags = param5;
   }
   
   public function get emitCode() : uint
   {
      return this._emitCode;
   }
   
   public function get longName() : String
   {
      return this._longName;
   }
   
   public function get name() : String
   {
      return this._name;
   }
   
   public function get flags() : uint
   {
      return this._flags;
   }
   
   public function get range() : uint
   {
      return this._range;
   }
   
   public function toString() : String
   {
      return "[Register name=\"" + this._name + "\", longName=\"" + this._longName + "\", emitCode=" + this._emitCode + ", range=" + this._range + ", flags=" + this._flags + "]";
   }
}

class Sampler
{
   
   private var _flag:uint;
   
   private var _mask:uint;
   
   private var _name:String;
   
   public function Sampler(param1:String, param2:uint, param3:uint)
   {
      super();
      this._name = param1;
      this._flag = param2;
      this._mask = param3;
   }
   
   public function get flag() : uint
   {
      return this._flag;
   }
   
   public function get mask() : uint
   {
      return this._mask;
   }
   
   public function get name() : String
   {
      return this._name;
   }
   
   public function toString() : String
   {
      return "[Sampler name=\"" + this._name + "\", flag=\"" + this._flag + "\", mask=" + this.mask + "]";
   }
}
