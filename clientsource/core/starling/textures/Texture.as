package starling.textures
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DTextureFormat;
   import flash.display3D.textures.Texture;
   import flash.display3D.textures.TextureBase;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import flash.utils.ByteArray;
   import flash.utils.getQualifiedClassName;
   import starling.core.Starling;
   import starling.errors.AbstractClassError;
   import starling.errors.MissingContextError;
   import starling.utils.VertexData;
   import starling.utils.getNextPowerOfTwo;
   
   public class Texture
   {
      
      private static var sOrigin:Point = new Point();
      
      private var mFrame:Rectangle;
      
      private var mRepeat:Boolean;
      
      public function Texture()
      {
         super();
         if(Capabilities.isDebugger && getQualifiedClassName(this) == "starling.textures::Texture")
         {
            throw new AbstractClassError();
         }
         this.mRepeat = false;
      }
      
      public static function fromBitmap(param1:Bitmap, param2:Boolean = true, param3:Boolean = false, param4:Number = 1) : starling.textures.Texture
      {
         return fromBitmapData(param1.bitmapData,param2,param3,param4);
      }
      
      public static function fromBitmapData(param1:BitmapData, param2:Boolean = true, param3:Boolean = false, param4:Number = 1) : starling.textures.Texture
      {
         var _loc10_:BitmapData = null;
         var _loc5_:int = param1.width;
         var _loc6_:int = param1.height;
         var _loc7_:int = getNextPowerOfTwo(_loc5_);
         var _loc8_:int = getNextPowerOfTwo(_loc6_);
         var _loc9_:Context3D = Starling.context;
         if(_loc9_ == null)
         {
            throw new MissingContextError();
         }
         var _loc11_:flash.display3D.textures.Texture = _loc9_.createTexture(_loc7_,_loc8_,Context3DTextureFormat.BGRA,param3);
         if(_loc7_ > _loc5_ || _loc8_ > _loc6_)
         {
            _loc10_ = new BitmapData(_loc7_,_loc8_,true,0);
            _loc10_.copyPixels(param1,param1.rect,sOrigin);
            param1 = _loc10_;
         }
         uploadBitmapData(_loc11_,param1,param2);
         var _loc12_:ConcreteTexture = new ConcreteTexture(_loc11_,Context3DTextureFormat.BGRA,_loc7_,_loc8_,param2,true,param3,param4);
         if(Starling.handleLostContext)
         {
            _loc12_.restoreOnLostContext(param1);
         }
         else if(_loc10_)
         {
            _loc10_.dispose();
         }
         if(_loc5_ == _loc7_ && _loc6_ == _loc8_)
         {
            return _loc12_;
         }
         return new SubTexture(_loc12_,new Rectangle(0,0,_loc5_ / param4,_loc6_ / param4),true);
      }
      
      public static function fromAtfData(param1:ByteArray, param2:Number = 1) : starling.textures.Texture
      {
         var _loc3_:Context3D = Starling.context;
         if(_loc3_ == null)
         {
            throw new MissingContextError();
         }
         var _loc4_:AtfData = new AtfData(param1);
         var _loc5_:flash.display3D.textures.Texture = _loc3_.createTexture(_loc4_.width,_loc4_.height,_loc4_.format,false);
         uploadAtfData(_loc5_,param1);
         var _loc6_:ConcreteTexture = new ConcreteTexture(_loc5_,_loc4_.format,_loc4_.width,_loc4_.height,_loc4_.numTextures > 1,false,false,param2);
         if(Starling.handleLostContext)
         {
            _loc6_.restoreOnLostContext(_loc4_);
         }
         return _loc6_;
      }
      
      public static function fromColor(param1:int, param2:int, param3:uint = 4294967295, param4:Boolean = false, param5:Number = -1) : starling.textures.Texture
      {
         if(param5 <= 0)
         {
            param5 = Starling.contentScaleFactor;
         }
         var _loc6_:BitmapData = new BitmapData(param1 * param5,param2 * param5,true,param3);
         var _loc7_:starling.textures.Texture = fromBitmapData(_loc6_,false,param4,param5);
         if(!Starling.handleLostContext)
         {
            _loc6_.dispose();
         }
         return _loc7_;
      }
      
      public static function empty(param1:int = 64, param2:int = 64, param3:Boolean = false, param4:Boolean = true, param5:Number = -1) : starling.textures.Texture
      {
         if(param5 <= 0)
         {
            param5 = Starling.contentScaleFactor;
         }
         var _loc6_:int = param1 * param5;
         var _loc7_:int = param2 * param5;
         var _loc8_:int = getNextPowerOfTwo(_loc6_);
         var _loc9_:int = getNextPowerOfTwo(_loc7_);
         var _loc10_:String = Context3DTextureFormat.BGRA;
         var _loc11_:Context3D = Starling.context;
         if(_loc11_ == null)
         {
            throw new MissingContextError();
         }
         var _loc12_:flash.display3D.textures.Texture = _loc11_.createTexture(_loc8_,_loc9_,Context3DTextureFormat.BGRA,param4);
         var _loc13_:ConcreteTexture = new ConcreteTexture(_loc12_,_loc10_,_loc8_,_loc9_,false,param3,param4,param5);
         if(_loc6_ == _loc8_ && _loc7_ == _loc9_)
         {
            return _loc13_;
         }
         return new SubTexture(_loc13_,new Rectangle(0,0,param1,param2),true);
      }
      
      public static function fromTexture(param1:starling.textures.Texture, param2:Rectangle = null, param3:Rectangle = null) : starling.textures.Texture
      {
         var _loc4_:starling.textures.Texture = new SubTexture(param1,param2);
         _loc4_.mFrame = param3;
         return _loc4_;
      }
      
      internal static function uploadBitmapData(param1:flash.display3D.textures.Texture, param2:BitmapData, param3:Boolean) : void
      {
         var _loc4_:* = 0;
         var _loc5_:* = 0;
         var _loc6_:int = 0;
         var _loc7_:BitmapData = null;
         var _loc8_:Matrix = null;
         var _loc9_:Rectangle = null;
         param1.uploadFromBitmapData(param2);
         if(param3 && param2.width > 1 && param2.height > 1)
         {
            _loc4_ = param2.width >> 1;
            _loc5_ = param2.height >> 1;
            _loc6_ = 1;
            _loc7_ = new BitmapData(_loc4_,_loc5_,true,0);
            _loc8_ = new Matrix(0.5,0,0,0.5);
            _loc9_ = new Rectangle();
            while(_loc4_ >= 1 || _loc5_ >= 1)
            {
               _loc9_.width = _loc4_;
               _loc9_.height = _loc5_;
               _loc7_.fillRect(_loc9_,0);
               _loc7_.draw(param2,_loc8_,null,null,null,true);
               param1.uploadFromBitmapData(_loc7_,_loc6_++);
               _loc8_.scale(0.5,0.5);
               _loc4_ >>= 1;
               _loc5_ >>= 1;
            }
            _loc7_.dispose();
         }
      }
      
      internal static function uploadAtfData(param1:flash.display3D.textures.Texture, param2:ByteArray, param3:int = 0) : void
      {
         param1.uploadCompressedTextureFromByteArray(param2,param3);
      }
      
      public function dispose() : void
      {
      }
      
      public function adjustVertexData(param1:VertexData, param2:int, param3:int) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(this.mFrame)
         {
            if(param3 != 4)
            {
               throw new ArgumentError("Textures with a frame can only be used on quads");
            }
            _loc4_ = this.mFrame.width + this.mFrame.x - this.width;
            _loc5_ = this.mFrame.height + this.mFrame.y - this.height;
            param1.translateVertex(param2,-this.mFrame.x,-this.mFrame.y);
            param1.translateVertex(param2 + 1,-_loc4_,-this.mFrame.y);
            param1.translateVertex(param2 + 2,-this.mFrame.x,-_loc5_);
            param1.translateVertex(param2 + 3,-_loc4_,-_loc5_);
         }
      }
      
      public function get frame() : Rectangle
      {
         return this.mFrame ? this.mFrame.clone() : new Rectangle(0,0,this.width,this.height);
      }
      
      public function get repeat() : Boolean
      {
         return this.mRepeat;
      }
      
      public function set repeat(param1:Boolean) : void
      {
         this.mRepeat = param1;
      }
      
      public function get width() : Number
      {
         return 0;
      }
      
      public function get height() : Number
      {
         return 0;
      }
      
      public function get scale() : Number
      {
         return 1;
      }
      
      public function get base() : TextureBase
      {
         return null;
      }
      
      public function get format() : String
      {
         return Context3DTextureFormat.BGRA;
      }
      
      public function get mipMapping() : Boolean
      {
         return false;
      }
      
      public function get premultipliedAlpha() : Boolean
      {
         return false;
      }
   }
}

