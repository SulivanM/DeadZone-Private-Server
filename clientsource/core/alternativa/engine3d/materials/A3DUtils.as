package alternativa.engine3d.materials
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.materials.compiler.CommandType;
   import alternativa.engine3d.materials.compiler.VariableType;
   import avmplus.getQualifiedSuperclassName;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DTextureFormat;
   import flash.display3D.IndexBuffer3D;
   import flash.display3D.VertexBuffer3D;
   import flash.display3D.textures.Texture;
   import flash.geom.Point;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.Endian;
   import flash.utils.getDefinitionByName;
   
   use namespace alternativa3d;
   
   public class A3DUtils
   {
      
      private static var twoOperandsCommands:Dictionary;
      
      public static const NONE:int = 0;
      
      public static const DXT1:int = 1;
      
      public static const ETC1:int = 2;
      
      public static const PVRTC:int = 3;
      
      private static const DXT1Data:ByteArray = getDXT1();
      
      private static const PVRTCData:ByteArray = getPVRTC();
      
      private static const ETC1Data:ByteArray = getETC1();
      
      private static var programType:Vector.<String> = Vector.<String>(["VERTEX","FRAGMENT"]);
      
      private static var samplerDimension:Vector.<String> = Vector.<String>(["2D","cube","3D"]);
      
      private static var samplerWraping:Vector.<String> = Vector.<String>(["clamp","repeat"]);
      
      private static var samplerMipmap:Vector.<String> = Vector.<String>(["mipnone","mipnearest","miplinear"]);
      
      private static var samplerFilter:Vector.<String> = Vector.<String>(["nearest","linear"]);
      
      private static var swizzleType:Vector.<String> = Vector.<String>(["x","y","z","w"]);
      
      public function A3DUtils()
      {
         super();
      }
      
      private static function getDXT1() : ByteArray
      {
         var _loc1_:Vector.<int> = Vector.<int>([65,84,70,0,2,71,2,2,2,3,0,0,12,0,0,0,16,0,0,85,105,56,0,0,0,0,0,157,73,73,188,1,8,0,0,0,5,0,1,188,1,0,16,0,0,0,74,0,0,0,128,188,4,0,1,0,0,0,1,0,0,0,129,188,4,0,1,0,0,0,2,0,0,0,192,188,4,0,1,0,0,0,90,0,0,0,193,188,4,0,1,0,0,0,66,0,0,0,0,0,0,0,36,195,221,111,3,78,254,75,177,133,61,119,118,141,201,10,87,77,80,72,79,84,79,0,25,0,192,122,0,0,0,1,96,0,160,0,10,0,0,160,0,0,0,4,111,255,0,1,0,0,1,0,224,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,114,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,12,0,0,0,16,0,0,85,105,56,0,0,0,0,0,157,73,73,188,1,8,0,0,0,5,0,1,188,1,0,16,0,0,0,74,0,0,0,128,188,4,0,1,0,0,0,1,0,0,0,129,188,4,0,1,0,0,0,2,0,0,0,192,188,4,0,1,0,0,0,90,0,0,0,193,188,4,0,1,0,0,0,66,0,0,0,0,0,0,0,36,195,221,111,3,78,254,75,177,133,61,119,118,141,201,10,87,77,80,72,79,84,79,0,25,0,192,122,0,0,0,1,96,0,160,0,10,0,0,160,0,0,0,4,111,255,0,1,0,0,1,0,224,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,114,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
         ,0,0,0,0,12,0,0,0,16,0,0,85,105,56,0,0,0,0,0,157,73,73,188,1,8,0,0,0,5,0,1,188,1,0,16,0,0,0,74,0,0,0,128,188,4,0,1,0,0,0,1,0,0,0,129,188,4,0,1,0,0,0,2,0,0,0,192,188,4,0,1,0,0,0,90,0,0,0,193,188,4,0,1,0,0,0,66,0,0,0,0,0,0,0,36,195,221,111,3,78,254,75,177,133,61,119,118,141,201,10,87,77,80,72,79,84,79,0,25,0,192,122,0,0,0,1,96,0,160,0,10,0,0,160,0,0,0,4,111,255,0,1,0,0,1,0,224,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,114,0,7,143,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
         return getData(_loc1_);
      }
      
      private static function getETC1() : ByteArray
      {
         var _loc1_:Vector.<int> = Vector.<int>([65,84,70,0,2,104,2,2,2,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,0,0,0,16,0,0,0,255,252,0,0,0,0,12,0,0,0,16,0,0,127,233,56,0,0,0,0,0,157,73,73,188,1,8,0,0,0,5,0,1,188,1,0,16,0,0,0,74,0,0,0,128,188,4,0,1,0,0,0,1,0,0,0,129,188,4,0,1,0,0,0,2,0,0,0,192,188,4,0,1,0,0,0,90,0,0,0,193,188,4,0,1,0,0,0,66,0,0,0,0,0,0,0,36,195,221,111,3,78,254,75,177,133,61,119,118,141,201,9,87,77,80,72,79,84,79,0,25,0,192,120,0,0,0,1,96,0,160,0,10,0,0,160,0,0,0,4,111,255,0,1,0,0,1,0,208,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,114,0,7,143,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,0,0,0,16,0,0,0,255,252,0,0,0,0,12,0,0,0,16,0,0,127,233,56,0,0,0,0,0,157,73,73,188,1,8,0,0,0,5,0,1,188,1,0,16,0,0,0,74,0,0,0,128,188,4,0,1,0,0,0,1,0,0,0,129,188,4,0,1,0,0,0,2,0,0,0,192,188,4,0,1,0,0,0,90,0,0,0,193,188,4,0,1,0,0,0,66,0,0,0,0,0,0,0,36,195,221,111,3,78,254,75,177,133,61,119,118,141,201,9,87,77,80,72,79,84,79,0,25,0,192,120,0,0,0,1,96,0,160,0,10,0,0,160,0,0,0,4,111,255,0,1,0,0,1,0,208
         ,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,114,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,0,0,0,16,0,0,0,255,252,0,0,0,0,12,0,0,0,16,0,0,127,233,56,0,0,0,0,0,157,73,73,188,1,8,0,0,0,5,0,1,188,1,0,16,0,0,0,74,0,0,0,128,188,4,0,1,0,0,0,1,0,0,0,129,188,4,0,1,0,0,0,2,0,0,0,192,188,4,0,1,0,0,0,90,0,0,0,193,188,4,0,1,0,0,0,66,0,0,0,0,0,0,0,36,195,221,111,3,78,254,75,177,133,61,119,118,141,201,9,87,77,80,72,79,84,79,0,25,0,192,120,0,0,0,1,96,0,160,0,10,0,0,160,0,0,0,4,111,255,0,1,0,0,1,0,208,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,114,0,4,0]);
         return getData(_loc1_);
      }
      
      private static function getPVRTC() : ByteArray
      {
         var _loc1_:Vector.<int> = Vector.<int>([65,84,70,0,2,173,2,2,2,3,0,0,0,0,0,0,0,0,13,0,0,0,16,0,0,0,104,190,153,255,0,0,0,0,15,91,0,0,16,0,0,102,12,228,2,255,225,0,0,0,0,0,223,73,73,188,1,8,0,0,0,5,0,1,188,1,0,16,0,0,0,74,0,0,0,128,188,4,0,1,0,0,0,2,0,0,0,129,188,4,0,1,0,0,0,4,0,0,0,192,188,4,0,1,0,0,0,90,0,0,0,193,188,4,0,1,0,0,0,132,0,0,0,0,0,0,0,36,195,221,111,3,78,254,75,177,133,61,119,118,141,201,9,87,77,80,72,79,84,79,0,25,0,192,120,0,1,0,3,96,0,160,0,10,0,0,160,0,0,0,4,111,255,0,1,0,0,1,0,165,192,0,7,227,99,186,53,197,40,185,134,182,32,130,98,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,143,192,120,64,6,16,34,52,192,196,65,132,90,98,68,16,17,68,60,91,8,48,76,35,192,97,132,71,76,33,164,97,1,2,194,12,19,8,240,29,132,24,38,17,224,48,194,35,166,16,210,48,128,128,24,68,121,132,52,204,32,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,12,0,0,0,16,0,0,0,233,56,90,0,0,0,0,12,0,0,0,16,0,0,127,237,210,0,0,0,0,0,155,73,73,188,1,8,0,0,0,5,0,1,188,1,0,16,0,0,0,74,0,0,0,128,188,4,0,1,0,0,0,2,0,0,0,129,188,4,0,1,0
         ,0,0,4,0,0,0,192,188,4,0,1,0,0,0,90,0,0,0,193,188,4,0,1,0,0,0,64,0,0,0,0,0,0,0,36,195,221,111,3,78,254,75,177,133,61,119,118,141,201,9,87,77,80,72,79,84,79,0,25,0,192,120,0,1,0,3,96,0,160,0,10,0,0,160,0,0,0,4,111,255,0,1,0,0,1,0,188,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,17,200,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,12,0,0,0,16,0,0,0,233,56,90,0,0,0,0,12,0,0,0,16,0,0,127,237,210,0,0,0,0,0,155,73,73,188,1,8,0,0,0,5,0,1,188,1,0,16,0,0,0,74,0,0,0,128,188,4,0,1,0,0,0,2,0,0,0,129,188,4,0,1,0,0,0,4,0,0,0,192,188,4,0,1,0,0,0,90,0,0,0,193,188,4,0,1,0,0,0,64,0,0,0,0,0,0,0,36,195,221,111,3,78,254,75,177,133,61,119,118,141,201,9,87,77,80,72,79,84,79,0,25,0,192,120,0,1,0,3,96,0,160,0,10,0,0,160,0,0,0,4,111,255,0,1,0,0,1,0,188,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,17,200,0,0,0,0,0,0,0,0,0,0]);
         return getData(_loc1_);
      }
      
      private static function getData(param1:Vector.<int>) : ByteArray
      {
         var _loc2_:ByteArray = new ByteArray();
         var _loc3_:int = 0;
         var _loc4_:int = int(param1.length);
         while(_loc3_ < _loc4_)
         {
            _loc2_.writeByte(param1[_loc3_]);
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function getSizeFromATF(param1:ByteArray, param2:Point) : void
      {
         param1.position = 7;
         var _loc3_:int = param1.readByte();
         var _loc4_:int = param1.readByte();
         param2.x = 1 << _loc3_;
         param2.y = 1 << _loc4_;
         param1.position = 0;
      }
      
      public static function getSupportedTextureFormat(param1:Context3D) : int
      {
         var context3D:Context3D = param1;
         var testTexture:Texture = context3D.createTexture(4,4,Context3DTextureFormat.COMPRESSED,false);
         var result:int = NONE;
         try
         {
            testTexture.uploadCompressedTextureFromByteArray(DXT1Data,0);
            result = DXT1;
         }
         catch(e:Error)
         {
            result = NONE;
         }
         if(result == NONE)
         {
            try
            {
               testTexture.uploadCompressedTextureFromByteArray(PVRTCData,0);
               result = PVRTC;
            }
            catch(e:Error)
            {
               result = NONE;
            }
         }
         if(result == NONE)
         {
            try
            {
               testTexture.uploadCompressedTextureFromByteArray(ETC1Data,0);
               result = ETC1;
            }
            catch(e:Error)
            {
               result = NONE;
            }
         }
         testTexture.dispose();
         return result;
      }
      
      public static function vectorNumberToByteArray(param1:Vector.<Number>) : ByteArray
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.endian = Endian.LITTLE_ENDIAN;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_.writeFloat(param1[_loc3_]);
            _loc3_++;
         }
         _loc2_.position = 0;
         return _loc2_;
      }
      
      public static function byteArrayToVectorUint(param1:ByteArray) : Vector.<uint>
      {
         var _loc2_:Vector.<uint> = new Vector.<uint>();
         var _loc3_:uint = 0;
         param1.position = 0;
         param1.endian = Endian.LITTLE_ENDIAN;
         while(param1.bytesAvailable > 0)
         {
            var _loc4_:*;
            _loc2_[_loc4_ = _loc3_++] = param1.readUnsignedShort();
         }
         return _loc2_;
      }
      
      public static function createVertexBufferFromByteArray(param1:Context3D, param2:ByteArray, param3:uint, param4:uint = 3) : VertexBuffer3D
      {
         if(param1 == null)
         {
            throw new ReferenceError("context is not set");
         }
         var _loc5_:VertexBuffer3D = param1.createVertexBuffer(param3,param4);
         _loc5_.uploadFromByteArray(param2,0,0,param3);
         return _loc5_;
      }
      
      public static function createVertexBufferFromVector(param1:Context3D, param2:Vector.<Number>, param3:uint, param4:uint = 3) : VertexBuffer3D
      {
         if(param1 == null)
         {
            throw new ReferenceError("context is not set");
         }
         var _loc5_:VertexBuffer3D = param1.createVertexBuffer(param3,param4);
         var _loc6_:ByteArray = A3DUtils.vectorNumberToByteArray(param2);
         _loc5_.uploadFromByteArray(_loc6_,0,0,param3);
         return _loc5_;
      }
      
      public static function createTextureFromByteArray(param1:Context3D, param2:ByteArray, param3:Number, param4:Number, param5:String) : Texture
      {
         if(param1 == null)
         {
            throw new ReferenceError("context is not set");
         }
         var _loc6_:Texture = param1.createTexture(param3,param4,param5,false);
         _loc6_.uploadCompressedTextureFromByteArray(param2,0);
         return _loc6_;
      }
      
      public static function createIndexBufferFromByteArray(param1:Context3D, param2:ByteArray, param3:uint) : IndexBuffer3D
      {
         if(param1 == null)
         {
            throw new ReferenceError("context is not set");
         }
         var _loc4_:IndexBuffer3D = param1.createIndexBuffer(param3);
         _loc4_.uploadFromByteArray(param2,0,0,param3);
         return _loc4_;
      }
      
      public static function createIndexBufferFromVector(param1:Context3D, param2:Vector.<uint>, param3:int = -1) : IndexBuffer3D
      {
         if(param1 == null)
         {
            throw new ReferenceError("context is not set");
         }
         var _loc4_:uint = param3 > 0 ? uint(param3) : param2.length;
         var _loc5_:IndexBuffer3D = param1.createIndexBuffer(_loc4_);
         _loc5_.uploadFromVector(param2,0,_loc4_);
         var _loc6_:ByteArray = new ByteArray();
         _loc6_.endian = Endian.LITTLE_ENDIAN;
         var _loc7_:int = 0;
         while(_loc7_ < _loc4_)
         {
            _loc6_.writeInt(param2[_loc7_]);
            _loc7_++;
         }
         _loc6_.position = 0;
         _loc5_.uploadFromVector(param2,0,_loc4_);
         return _loc5_;
      }
      
      public static function disassemble(param1:ByteArray) : String
      {
         if(!twoOperandsCommands)
         {
            twoOperandsCommands = new Dictionary();
            twoOperandsCommands[1] = true;
            twoOperandsCommands[2] = true;
            twoOperandsCommands[3] = true;
            twoOperandsCommands[4] = true;
            twoOperandsCommands[6] = true;
            twoOperandsCommands[11] = true;
            twoOperandsCommands[17] = true;
            twoOperandsCommands[18] = true;
            twoOperandsCommands[19] = true;
            twoOperandsCommands[23] = true;
            twoOperandsCommands[24] = true;
            twoOperandsCommands[25] = true;
            twoOperandsCommands[38] = true;
            twoOperandsCommands[40] = true;
            twoOperandsCommands[41] = true;
            twoOperandsCommands[42] = true;
            twoOperandsCommands[44] = true;
            twoOperandsCommands[45] = true;
         }
         var _loc2_:* = "";
         param1.position = 0;
         if(param1.bytesAvailable < 7)
         {
            return "error in byteCode header";
         }
         _loc2_ += "magic = " + param1.readUnsignedByte().toString(16);
         _loc2_ += "\nversion = " + param1.readInt().toString(10);
         _loc2_ += "\nshadertypeid = " + param1.readUnsignedByte().toString(16);
         var _loc3_:String = programType[param1.readByte()];
         _loc2_ += "\nshadertype = " + _loc3_;
         _loc2_ += "\nsource\n";
         _loc3_ = _loc3_.substring(0,1).toLowerCase();
         var _loc4_:uint = 1;
         while(param1.bytesAvailable - 24 >= 0)
         {
            _loc2_ += (_loc4_++).toString() + ": " + getCommand(param1,_loc3_) + "\n";
         }
         if(param1.bytesAvailable > 0)
         {
            _loc2_ += "\nunexpected byteCode length. extra bytes:" + param1.bytesAvailable;
         }
         return _loc2_;
      }
      
      private static function getCommand(param1:ByteArray, param2:String) : String
      {
         var _loc5_:* = null;
         var _loc3_:uint = param1.readUnsignedInt();
         var _loc4_:String = CommandType.COMMAND_NAMES[_loc3_];
         var _loc6_:uint = param1.readUnsignedShort();
         var _loc7_:uint = uint(param1.readByte());
         var _loc8_:* = "";
         var _loc9_:uint = 4;
         if(_loc7_ < 15)
         {
            _loc8_ += ".";
            _loc8_ = _loc8_ + ((_loc7_ & 1) > 0 ? "x" : "");
            _loc8_ = _loc8_ + ((_loc7_ & 2) > 0 ? "y" : "");
            _loc8_ = _loc8_ + ((_loc7_ & 4) > 0 ? "z" : "");
            _loc8_ = _loc8_ + ((_loc7_ & 8) > 0 ? "w" : "");
            _loc9_ = uint(_loc8_.length - 1);
         }
         var _loc10_:int = int(_loc9_);
         if(_loc3_ == CommandType.TEX)
         {
            _loc10_ = 2;
         }
         else if(_loc3_ == CommandType.DP3)
         {
            _loc10_ = 3;
         }
         else if(_loc3_ == CommandType.DP4)
         {
            _loc10_ = 4;
         }
         var _loc11_:String = VariableType.TYPE_NAMES[param1.readUnsignedByte()].charAt(0);
         _loc5_ = _loc4_ + " " + attachProgramPrefix(_loc11_,param2) + _loc6_.toString() + _loc8_ + ", ";
         _loc5_ = _loc5_ + attachProgramPrefix(getSourceVariable(param1,_loc10_),param2);
         if(twoOperandsCommands[_loc3_])
         {
            if(_loc3_ == CommandType.TEX || _loc3_ == CommandType.TED)
            {
               _loc5_ += ", " + attachProgramPrefix(getSamplerVariable(param1),param2);
            }
            else
            {
               _loc5_ += ", " + attachProgramPrefix(getSourceVariable(param1,_loc10_),param2);
            }
         }
         else
         {
            param1.readDouble();
         }
         if(_loc3_ == CommandType.ELS || _loc3_ == CommandType.EIF)
         {
            _loc5_ = " " + _loc4_;
         }
         return _loc5_;
      }
      
      private static function attachProgramPrefix(param1:String, param2:String) : String
      {
         var _loc3_:uint = uint(param1.charCodeAt(0));
         if(_loc3_ == "o".charCodeAt(0))
         {
            return param1 + (param2 == "f" ? "c" : "p");
         }
         if(_loc3_ == "d".charCodeAt(0))
         {
            return "o" + param1;
         }
         if(_loc3_ != "v".charCodeAt(0))
         {
            return param2 + param1;
         }
         return param1;
      }
      
      private static function getSamplerVariable(param1:ByteArray) : String
      {
         var _loc2_:uint = param1.readUnsignedInt();
         param1.readByte();
         var _loc3_:uint = uint(param1.readByte() >> 4);
         var _loc4_:uint = uint(param1.readByte() >> 4);
         var _loc5_:uint = uint(param1.readByte());
         return "s" + _loc2_.toString() + " <" + samplerDimension[_loc3_] + ", " + samplerWraping[_loc4_] + ", " + samplerFilter[_loc5_ >> 4 & 0x0F] + ", " + samplerMipmap[_loc5_ & 0x0F] + ">";
      }
      
      private static function getSourceVariable(param1:ByteArray, param2:uint) : String
      {
         var _loc3_:uint = param1.readUnsignedShort();
         var _loc4_:uint = param1.readUnsignedByte();
         var _loc5_:String = getSourceSwizzle(param1.readUnsignedByte(),param2);
         var _loc6_:String = VariableType.TYPE_NAMES[param1.readUnsignedByte()].charAt(0);
         var _loc7_:String = VariableType.TYPE_NAMES[param1.readUnsignedByte()].charAt(0);
         var _loc8_:String = swizzleType[param1.readUnsignedByte()];
         if(param1.readUnsignedByte() > 0)
         {
            return _loc6_ + "[" + _loc7_ + _loc3_.toString() + "." + _loc8_ + (_loc4_ > 0 ? "+" + _loc4_.toString() : "") + "]" + _loc5_;
         }
         return _loc6_ + _loc3_.toString() + _loc5_;
      }
      
      private static function getSourceSwizzle(param1:uint, param2:uint = 4) : String
      {
         var _loc3_:* = "";
         if(param1 != 228)
         {
            _loc3_ += ".";
            _loc3_ += swizzleType[param1 & 3];
            _loc3_ += swizzleType[param1 >> 2 & 3];
            _loc3_ += swizzleType[param1 >> 4 & 3];
            _loc3_ += swizzleType[param1 >> 6 & 3];
            _loc3_ = param2 < 4 ? _loc3_.substring(0,param2 + 1) : _loc3_;
         }
         return _loc3_;
      }
      
      alternativa3d static function checkParent(param1:Class, param2:Class) : Boolean
      {
         var _loc4_:String = null;
         var _loc3_:Class = param1;
         if(param2 == null)
         {
            return true;
         }
         while(_loc3_ != param2)
         {
            _loc4_ = getQualifiedSuperclassName(_loc3_);
            if(_loc4_ == null)
            {
               return false;
            }
            _loc3_ = getDefinitionByName(_loc4_) as Class;
         }
         return true;
      }
   }
}

