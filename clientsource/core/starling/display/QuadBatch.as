package starling.display
{
   import com.adobe.utils.AGALMiniAssembler;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DProgramType;
   import flash.display3D.Context3DTextureFormat;
   import flash.display3D.Context3DVertexBufferFormat;
   import flash.display3D.IndexBuffer3D;
   import flash.display3D.VertexBuffer3D;
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import starling.core.RenderSupport;
   import starling.core.Starling;
   import starling.core.starling_internal;
   import starling.errors.MissingContextError;
   import starling.events.Event;
   import starling.filters.FragmentFilter;
   import starling.filters.FragmentFilterMode;
   import starling.textures.Texture;
   import starling.textures.TextureSmoothing;
   import starling.utils.MatrixUtil;
   import starling.utils.VertexData;
   
   use namespace starling_internal;
   
   public class QuadBatch extends DisplayObject
   {
      
      private static const QUAD_PROGRAM_NAME:String = "QB_q";
      
      private static var sHelperMatrix:Matrix = new Matrix();
      
      private static var sRenderAlpha:Vector.<Number> = new <Number>[1,1,1,1];
      
      private static var sRenderMatrix:Matrix3D = new Matrix3D();
      
      private static var sProgramNameCache:Dictionary = new Dictionary();
      
      private var mNumQuads:int;
      
      private var mSyncRequired:Boolean;
      
      private var mTinted:Boolean;
      
      private var mTexture:Texture;
      
      private var mSmoothing:String;
      
      private var mVertexData:VertexData;
      
      private var mVertexBuffer:VertexBuffer3D;
      
      private var mIndexData:Vector.<uint>;
      
      private var mIndexBuffer:IndexBuffer3D;
      
      private var _disposed:Boolean = false;
      
      public function QuadBatch()
      {
         super();
         this.mVertexData = new VertexData(0,true);
         this.mIndexData = new Vector.<uint>(0);
         this.mNumQuads = 0;
         this.mTinted = false;
         this.mSyncRequired = false;
         Starling.current.stage3D.addEventListener(Event.CONTEXT3D_CREATE,this.onContextCreated,false,0,true);
      }
      
      public static function compile(param1:DisplayObject, param2:Vector.<QuadBatch>) : void
      {
         compileObject(param1,param2,-1,new Matrix());
      }
      
      private static function compileObject(param1:DisplayObject, param2:Vector.<QuadBatch>, param3:int, param4:Matrix, param5:Number = 1, param6:String = null, param7:Boolean = false) : int
      {
         var _loc8_:int = 0;
         var _loc9_:QuadBatch = null;
         var _loc16_:int = 0;
         var _loc17_:Matrix = null;
         var _loc18_:DisplayObject = null;
         var _loc19_:Boolean = false;
         var _loc20_:String = null;
         var _loc21_:Texture = null;
         var _loc22_:String = null;
         var _loc23_:Boolean = false;
         var _loc24_:int = 0;
         var _loc25_:Image = null;
         var _loc10_:Boolean = false;
         var _loc11_:Number = param1.alpha;
         var _loc12_:DisplayObjectContainer = param1 as DisplayObjectContainer;
         var _loc13_:Quad = param1 as Quad;
         var _loc14_:QuadBatch = param1 as QuadBatch;
         var _loc15_:FragmentFilter = param1.filter;
         if(param3 == -1)
         {
            _loc10_ = true;
            param3 = 0;
            _loc11_ = 1;
            param6 = param1.blendMode;
            if(param2.length == 0)
            {
               param2.push(new QuadBatch());
            }
            else
            {
               param2[0].reset();
            }
         }
         if(Boolean(_loc15_) && !param7)
         {
            if(_loc15_.mode == FragmentFilterMode.ABOVE)
            {
               param3 = compileObject(param1,param2,param3,param4,param5,param6,true);
            }
            param3 = compileObject(_loc15_.starling_internal::compile(param1),param2,param3,param4,param5,param6);
            if(_loc15_.mode == FragmentFilterMode.BELOW)
            {
               param3 = compileObject(param1,param2,param3,param4,param5,param6,true);
            }
         }
         else if(_loc12_)
         {
            _loc16_ = _loc12_.numChildren;
            _loc17_ = new Matrix();
            _loc8_ = 0;
            while(_loc8_ < _loc16_)
            {
               _loc18_ = _loc12_.getChildAt(_loc8_);
               _loc19_ = _loc18_.alpha != 0 && _loc18_.visible && _loc18_.scaleX != 0 && _loc18_.scaleY != 0;
               if(_loc19_)
               {
                  _loc20_ = _loc18_.blendMode == BlendMode.AUTO ? param6 : _loc18_.blendMode;
                  _loc17_.copyFrom(param4);
                  RenderSupport.transformMatrixForObject(_loc17_,_loc18_);
                  param3 = compileObject(_loc18_,param2,param3,_loc17_,param5 * _loc11_,_loc20_);
               }
               _loc8_++;
            }
         }
         else
         {
            if(!(Boolean(_loc13_) || Boolean(_loc14_)))
            {
               throw new Error("Unsupported display object: " + getQualifiedClassName(param1));
            }
            if(_loc13_)
            {
               _loc25_ = _loc13_ as Image;
               _loc21_ = _loc25_ ? _loc25_.texture : null;
               _loc22_ = _loc25_ ? _loc25_.smoothing : null;
               _loc23_ = _loc13_.tinted;
               _loc24_ = 1;
            }
            else
            {
               _loc21_ = _loc14_.mTexture;
               _loc22_ = _loc14_.mSmoothing;
               _loc23_ = _loc14_.mTinted;
               _loc24_ = _loc14_.mNumQuads;
            }
            _loc9_ = param2[param3];
            if(_loc9_.isStateChange(_loc23_,param5 * _loc11_,_loc21_,_loc22_,param6,_loc24_))
            {
               param3++;
               if(param2.length <= param3)
               {
                  param2.push(new QuadBatch());
               }
               _loc9_ = param2[param3];
               _loc9_.reset();
            }
            if(_loc13_)
            {
               _loc9_.addQuad(_loc13_,param5,_loc21_,_loc22_,param4,param6);
            }
            else
            {
               _loc9_.addQuadBatch(_loc14_,param5,param4,param6);
            }
         }
         if(_loc10_)
         {
            _loc8_ = int(param2.length - 1);
            while(_loc8_ > param3)
            {
               param2.pop().dispose();
               _loc8_--;
            }
         }
         return param3;
      }
      
      private static function registerPrograms() : void
      {
         var _loc4_:* = null;
         var _loc5_:String = null;
         var _loc6_:Boolean = false;
         var _loc7_:Array = null;
         var _loc8_:Array = null;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc11_:String = null;
         var _loc12_:String = null;
         var _loc13_:Array = null;
         var _loc1_:Starling = Starling.current;
         if(_loc1_.hasProgram(QUAD_PROGRAM_NAME))
         {
            return;
         }
         var _loc2_:AGALMiniAssembler = new AGALMiniAssembler();
         var _loc3_:AGALMiniAssembler = new AGALMiniAssembler();
         _loc4_ = "m44 op, va0, vc1 \n" + "mul v0, va1, vc0 \n";
         _loc5_ = "mov oc, v0       \n";
         _loc2_.assemble(Context3DProgramType.VERTEX,_loc4_);
         _loc3_.assemble(Context3DProgramType.FRAGMENT,_loc5_);
         _loc1_.registerProgram(QUAD_PROGRAM_NAME,_loc2_.agalcode,_loc3_.agalcode);
         for each(_loc6_ in [true,false])
         {
            _loc4_ = _loc6_ ? "m44 op, va0, vc1 \n" + "mul v0, va1, vc0 \n" + "mov v1, va2      \n" : "m44 op, va0, vc1 \n" + "mov v1, va2      \n";
            _loc2_.assemble(Context3DProgramType.VERTEX,_loc4_);
            _loc5_ = _loc6_ ? "tex ft1,  v1, fs0 <???> \n" + "mul  oc, ft1,  v0       \n" : "tex  oc,  v1, fs0 <???> \n";
            _loc7_ = [TextureSmoothing.NONE,TextureSmoothing.BILINEAR,TextureSmoothing.TRILINEAR];
            _loc8_ = [Context3DTextureFormat.BGRA,Context3DTextureFormat.COMPRESSED,"compressedAlpha"];
            for each(_loc9_ in [true,false])
            {
               for each(_loc10_ in [true,false])
               {
                  for each(_loc11_ in _loc7_)
                  {
                     for each(_loc12_ in _loc8_)
                     {
                        _loc13_ = ["2d",_loc9_ ? "repeat" : "clamp"];
                        if(_loc12_ == Context3DTextureFormat.COMPRESSED)
                        {
                           _loc13_.push("dxt1");
                        }
                        else if(_loc12_ == "compressedAlpha")
                        {
                           _loc13_.push("dxt5");
                        }
                        if(_loc11_ == TextureSmoothing.NONE)
                        {
                           _loc13_.push("nearest",_loc10_ ? "mipnearest" : "mipnone");
                        }
                        else if(_loc11_ == TextureSmoothing.BILINEAR)
                        {
                           _loc13_.push("linear",_loc10_ ? "mipnearest" : "mipnone");
                        }
                        else
                        {
                           _loc13_.push("linear",_loc10_ ? "miplinear" : "mipnone");
                        }
                        _loc3_.assemble(Context3DProgramType.FRAGMENT,_loc5_.replace("???",_loc13_.join()));
                        _loc1_.registerProgram(getImageProgramName(_loc6_,_loc10_,_loc9_,_loc12_,_loc11_),_loc2_.agalcode,_loc3_.agalcode);
                     }
                  }
               }
            }
         }
      }
      
      private static function getImageProgramName(param1:Boolean, param2:Boolean = true, param3:Boolean = false, param4:String = "bgra", param5:String = "bilinear") : String
      {
         var _loc6_:uint = 0;
         if(param1)
         {
            _loc6_ |= 1;
         }
         if(param2)
         {
            _loc6_ |= 1 << 1;
         }
         if(param3)
         {
            _loc6_ |= 1 << 2;
         }
         if(param5 == TextureSmoothing.NONE)
         {
            _loc6_ |= 1 << 3;
         }
         else if(param5 == TextureSmoothing.TRILINEAR)
         {
            _loc6_ |= 1 << 4;
         }
         if(param4 == Context3DTextureFormat.COMPRESSED)
         {
            _loc6_ |= 1 << 5;
         }
         else if(param4 == "compressedAlpha")
         {
            _loc6_ |= 1 << 6;
         }
         var _loc7_:String = sProgramNameCache[_loc6_];
         if(_loc7_ == null)
         {
            _loc7_ = "QB_i." + _loc6_.toString(16);
            sProgramNameCache[_loc6_] = _loc7_;
         }
         return _loc7_;
      }
      
      override public function dispose() : void
      {
         this._disposed = true;
         Starling.current.stage3D.removeEventListener(Event.CONTEXT3D_CREATE,this.onContextCreated);
         if(this.mVertexBuffer)
         {
            this.mVertexBuffer.dispose();
         }
         if(this.mIndexBuffer)
         {
            this.mIndexBuffer.dispose();
         }
         super.dispose();
      }
      
      private function onContextCreated(param1:Object) : void
      {
         if(!Starling.current || !Starling.current.context || Starling.current.context.driverInfo == "Disposed")
         {
            return;
         }
         this.createBuffers();
         registerPrograms();
      }
      
      public function clone() : QuadBatch
      {
         var _loc1_:QuadBatch = new QuadBatch();
         _loc1_.mVertexData = this.mVertexData.clone(0,this.mNumQuads * 4);
         _loc1_.mIndexData = this.mIndexData.slice(0,this.mNumQuads * 6);
         _loc1_.mNumQuads = this.mNumQuads;
         _loc1_.mTinted = this.mTinted;
         _loc1_.mTexture = this.mTexture;
         _loc1_.mSmoothing = this.mSmoothing;
         _loc1_.mSyncRequired = true;
         _loc1_.blendMode = blendMode;
         _loc1_.alpha = alpha;
         return _loc1_;
      }
      
      private function expand(param1:int = -1) : void
      {
         var _loc2_:int = this.capacity;
         if(param1 < 0)
         {
            param1 = _loc2_ * 2;
         }
         if(param1 == 0)
         {
            param1 = 16;
         }
         if(param1 <= _loc2_)
         {
            return;
         }
         this.mVertexData.numVertices = param1 * 4;
         var _loc3_:int = _loc2_;
         while(_loc3_ < param1)
         {
            this.mIndexData[int(_loc3_ * 6)] = _loc3_ * 4;
            this.mIndexData[int(_loc3_ * 6 + 1)] = _loc3_ * 4 + 1;
            this.mIndexData[int(_loc3_ * 6 + 2)] = _loc3_ * 4 + 2;
            this.mIndexData[int(_loc3_ * 6 + 3)] = _loc3_ * 4 + 1;
            this.mIndexData[int(_loc3_ * 6 + 4)] = _loc3_ * 4 + 3;
            this.mIndexData[int(_loc3_ * 6 + 5)] = _loc3_ * 4 + 2;
            _loc3_++;
         }
         this.createBuffers();
         registerPrograms();
      }
      
      private function createBuffers() : void
      {
         var _loc1_:int = this.mVertexData.numVertices;
         var _loc2_:int = int(this.mIndexData.length);
         var _loc3_:Context3D = Starling.context;
         if(this.mVertexBuffer)
         {
            this.mVertexBuffer.dispose();
         }
         if(this.mIndexBuffer)
         {
            this.mIndexBuffer.dispose();
         }
         if(_loc1_ == 0)
         {
            return;
         }
         if(_loc3_ == null)
         {
            throw new MissingContextError();
         }
         this.mVertexBuffer = _loc3_.createVertexBuffer(_loc1_,VertexData.ELEMENTS_PER_VERTEX);
         this.mVertexBuffer.uploadFromVector(this.mVertexData.rawData,0,_loc1_);
         this.mIndexBuffer = _loc3_.createIndexBuffer(_loc2_);
         this.mIndexBuffer.uploadFromVector(this.mIndexData,0,_loc2_);
         this.mSyncRequired = false;
      }
      
      private function syncBuffers() : void
      {
         if(this.mVertexBuffer == null)
         {
            this.createBuffers();
         }
         else
         {
            this.mVertexBuffer.uploadFromVector(this.mVertexData.rawData,0,this.mVertexData.numVertices);
            this.mSyncRequired = false;
         }
      }
      
      public function renderCustom(param1:Matrix, param2:Number = 1, param3:String = null) : void
      {
         if(this.mNumQuads == 0)
         {
            return;
         }
         if(this.mSyncRequired)
         {
            this.syncBuffers();
         }
         var _loc4_:Boolean = this.mVertexData.premultipliedAlpha;
         var _loc5_:Context3D = Starling.context;
         var _loc6_:Boolean = this.mTinted || param2 != 1;
         var _loc7_:String = this.mTexture ? getImageProgramName(_loc6_,this.mTexture.mipMapping,this.mTexture.repeat,this.mTexture.format,this.mSmoothing) : QUAD_PROGRAM_NAME;
         sRenderAlpha[0] = sRenderAlpha[1] = sRenderAlpha[2] = _loc4_ ? param2 : 1;
         sRenderAlpha[3] = param2;
         MatrixUtil.convertTo3D(param1,sRenderMatrix);
         RenderSupport.setBlendFactors(_loc4_,param3 ? param3 : this.blendMode);
         _loc5_.setProgram(Starling.current.getProgram(_loc7_));
         _loc5_.setProgramConstantsFromVector(Context3DProgramType.VERTEX,0,sRenderAlpha,1);
         _loc5_.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,1,sRenderMatrix,true);
         _loc5_.setVertexBufferAt(0,this.mVertexBuffer,VertexData.POSITION_OFFSET,Context3DVertexBufferFormat.FLOAT_2);
         if(this.mTexture == null || _loc6_)
         {
            _loc5_.setVertexBufferAt(1,this.mVertexBuffer,VertexData.COLOR_OFFSET,Context3DVertexBufferFormat.FLOAT_4);
         }
         if(this.mTexture)
         {
            _loc5_.setTextureAt(0,this.mTexture.base);
            _loc5_.setVertexBufferAt(2,this.mVertexBuffer,VertexData.TEXCOORD_OFFSET,Context3DVertexBufferFormat.FLOAT_2);
         }
         _loc5_.drawTriangles(this.mIndexBuffer,0,this.mNumQuads * 2);
         if(this.mTexture)
         {
            _loc5_.setTextureAt(0,null);
            _loc5_.setVertexBufferAt(2,null);
         }
         _loc5_.setVertexBufferAt(1,null);
         _loc5_.setVertexBufferAt(0,null);
      }
      
      public function reset() : void
      {
         this.mNumQuads = 0;
         this.mTexture = null;
         this.mSmoothing = null;
         this.mSyncRequired = true;
      }
      
      public function addImage(param1:Image, param2:Number = 1, param3:Matrix = null, param4:String = null) : void
      {
         this.addQuad(param1,param2,param1.texture,param1.smoothing,param3,param4);
      }
      
      public function addQuad(param1:Quad, param2:Number = 1, param3:Texture = null, param4:String = null, param5:Matrix = null, param6:String = null) : void
      {
         if(param5 == null)
         {
            param5 = param1.transformationMatrix;
         }
         var _loc7_:Boolean = param3 ? param1.tinted || param2 != 1 : false;
         var _loc8_:Number = param2 * param1.alpha;
         var _loc9_:int = this.mNumQuads * 4;
         if(this.mNumQuads + 1 > this.mVertexData.numVertices / 4)
         {
            this.expand();
         }
         if(this.mNumQuads == 0)
         {
            this.blendMode = param6 ? param6 : param1.blendMode;
            this.mTexture = param3;
            this.mTinted = _loc7_;
            this.mSmoothing = param4;
            this.mVertexData.setPremultipliedAlpha(param3 ? param3.premultipliedAlpha : true,false);
         }
         param1.copyVertexDataTo(this.mVertexData,_loc9_);
         this.mVertexData.transformVertex(_loc9_,param5,4);
         if(_loc8_ != 1)
         {
            this.mVertexData.scaleAlpha(_loc9_,_loc8_,4);
         }
         this.mSyncRequired = true;
         ++this.mNumQuads;
      }
      
      public function addQuadBatch(param1:QuadBatch, param2:Number = 1, param3:Matrix = null, param4:String = null) : void
      {
         if(param3 == null)
         {
            param3 = param1.transformationMatrix;
         }
         var _loc5_:Boolean = param1.mTinted || param2 != 1;
         var _loc6_:Number = param2 * param1.alpha;
         var _loc7_:int = this.mNumQuads * 4;
         var _loc8_:int = param1.numQuads;
         if(this.mNumQuads + _loc8_ > this.capacity)
         {
            this.expand(this.mNumQuads + _loc8_);
         }
         if(this.mNumQuads == 0)
         {
            this.blendMode = param4 ? param4 : param1.blendMode;
            this.mTexture = param1.mTexture;
            this.mTinted = _loc5_;
            this.mSmoothing = param1.mSmoothing;
            this.mVertexData.setPremultipliedAlpha(param1.mVertexData.premultipliedAlpha,false);
         }
         param1.mVertexData.copyTo(this.mVertexData,_loc7_,0,_loc8_ * 4);
         this.mVertexData.transformVertex(_loc7_,param3,_loc8_ * 4);
         if(_loc6_ != 1)
         {
            this.mVertexData.scaleAlpha(_loc7_,_loc6_,_loc8_ * 4);
         }
         this.mSyncRequired = true;
         this.mNumQuads += _loc8_;
      }
      
      public function isStateChange(param1:Boolean, param2:Number, param3:Texture, param4:String, param5:String, param6:int = 1) : Boolean
      {
         if(this.mNumQuads == 0)
         {
            return false;
         }
         if(this.mNumQuads + param6 > 8192)
         {
            return true;
         }
         if(this.mTexture == null && param3 == null)
         {
            return false;
         }
         if(this.mTexture != null && param3 != null)
         {
            return this.mTexture.base != param3.base || this.mTexture.repeat != param3.repeat || this.mSmoothing != param4 || this.mTinted != (param1 || param2 != 1) || this.blendMode != param5;
         }
         return true;
      }
      
      override public function getBounds(param1:DisplayObject, param2:Rectangle = null) : Rectangle
      {
         if(param2 == null)
         {
            param2 = new Rectangle();
         }
         var _loc3_:Matrix = param1 == this ? null : getTransformationMatrix(param1,sHelperMatrix);
         return this.mVertexData.getBounds(_loc3_,0,this.mNumQuads * 4,param2);
      }
      
      override public function render(param1:RenderSupport, param2:Number) : void
      {
         param1.finishQuadBatch();
         param1.raiseDrawCount();
         this.renderCustom(param1.mvpMatrix,alpha * param2,param1.blendMode);
      }
      
      public function get numQuads() : int
      {
         return this.mNumQuads;
      }
      
      public function get tinted() : Boolean
      {
         return this.mTinted;
      }
      
      public function get texture() : Texture
      {
         return this.mTexture;
      }
      
      public function get smoothing() : String
      {
         return this.mSmoothing;
      }
      
      private function get capacity() : int
      {
         return this.mVertexData.numVertices / 4;
      }
   }
}

