package starling.filters
{
   import com.adobe.utils.AGALMiniAssembler;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DProgramType;
   import flash.display3D.Context3DVertexBufferFormat;
   import flash.display3D.IndexBuffer3D;
   import flash.display3D.Program3D;
   import flash.display3D.VertexBuffer3D;
   import flash.errors.IllegalOperationError;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import flash.utils.getQualifiedClassName;
   import starling.core.RenderSupport;
   import starling.core.Starling;
   import starling.core.starling_internal;
   import starling.display.BlendMode;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.display.QuadBatch;
   import starling.display.Stage;
   import starling.errors.AbstractClassError;
   import starling.errors.MissingContextError;
   import starling.events.Event;
   import starling.textures.Texture;
   import starling.utils.MatrixUtil;
   import starling.utils.VertexData;
   import starling.utils.getNextPowerOfTwo;
   
   use namespace starling_internal;
   
   public class FragmentFilter
   {
      
      private static var sBounds:Rectangle = new Rectangle();
      
      private static var sTransformationMatrix:Matrix = new Matrix();
      
      protected const PMA:Boolean = true;
      
      protected const STD_VERTEX_SHADER:String = "m44 op, va0, vc0 \n" + "mov v0, va1      \n";
      
      protected const STD_FRAGMENT_SHADER:String = "tex oc, v0, fs0 <2d, clamp, linear, mipnone>";
      
      private var mNumPasses:int;
      
      private var mPassTextures:Vector.<Texture>;
      
      private var mMode:String;
      
      private var mResolution:Number;
      
      private var mMarginX:Number;
      
      private var mMarginY:Number;
      
      private var mOffsetX:Number;
      
      private var mOffsetY:Number;
      
      private var mVertexData:VertexData;
      
      private var mVertexBuffer:VertexBuffer3D;
      
      private var mIndexData:Vector.<uint>;
      
      private var mIndexBuffer:IndexBuffer3D;
      
      private var mCacheRequested:Boolean;
      
      private var mCache:QuadBatch;
      
      private var mProjMatrix:Matrix = new Matrix();
      
      public function FragmentFilter(param1:int = 1, param2:Number = 1)
      {
         super();
         if(Capabilities.isDebugger && getQualifiedClassName(this) == "starling.filters::FragmentFilter")
         {
            throw new AbstractClassError();
         }
         if(param1 < 1)
         {
            throw new ArgumentError("At least one pass is required.");
         }
         this.mNumPasses = param1;
         this.mMarginX = this.mMarginY = 0;
         this.mOffsetX = this.mOffsetY = 0;
         this.mResolution = param2;
         this.mMode = FragmentFilterMode.REPLACE;
         this.mVertexData = new VertexData(4);
         this.mVertexData.setTexCoords(0,0,0);
         this.mVertexData.setTexCoords(1,1,0);
         this.mVertexData.setTexCoords(2,0,1);
         this.mVertexData.setTexCoords(3,1,1);
         this.mIndexData = new <uint>[0,1,2,1,3,2];
         this.mIndexData.fixed = true;
         this.createPrograms();
         Starling.current.stage3D.addEventListener(Event.CONTEXT3D_CREATE,this.onContextCreated,false,0,true);
      }
      
      public function dispose() : void
      {
         if(this.mVertexBuffer)
         {
            this.mVertexBuffer.dispose();
         }
         if(this.mIndexBuffer)
         {
            this.mIndexBuffer.dispose();
         }
         this.disposePassTextures();
         this.disposeCache();
      }
      
      private function onContextCreated(param1:Object) : void
      {
         this.mVertexBuffer = null;
         this.mIndexBuffer = null;
         this.mPassTextures = null;
         this.createPrograms();
      }
      
      public function render(param1:DisplayObject, param2:RenderSupport, param3:Number) : void
      {
         if(this.mode == FragmentFilterMode.ABOVE)
         {
            param1.render(param2,param3);
         }
         if(this.mCacheRequested)
         {
            this.mCacheRequested = false;
            this.mCache = this.renderPasses(param1,param2,1,true);
            this.disposePassTextures();
         }
         if(this.mCache)
         {
            this.mCache.render(param2,param1.alpha * param3);
         }
         else
         {
            this.renderPasses(param1,param2,param3,false);
         }
         if(this.mode == FragmentFilterMode.BELOW)
         {
            param1.render(param2,param3);
         }
      }
      
      private function renderPasses(param1:DisplayObject, param2:RenderSupport, param3:Number, param4:Boolean = false) : QuadBatch
      {
         var _loc11_:Texture = null;
         var _loc12_:QuadBatch = null;
         var _loc13_:Image = null;
         var _loc5_:Texture = null;
         var _loc6_:Stage = param1.stage;
         var _loc7_:Context3D = Starling.context;
         var _loc8_:Number = Starling.current.contentScaleFactor;
         if(_loc6_ == null)
         {
            throw new Error("Filtered object must be on the stage.");
         }
         if(_loc7_ == null)
         {
            throw new MissingContextError();
         }
         param2.finishQuadBatch();
         param2.raiseDrawCount(this.mNumPasses);
         param2.pushMatrix();
         param2.blendMode = BlendMode.NORMAL;
         RenderSupport.setBlendFactors(this.PMA);
         this.mProjMatrix.copyFrom(param2.projectionMatrix);
         var _loc9_:Texture = param2.renderTarget;
         if(_loc9_)
         {
            throw new IllegalOperationError("It\'s currently not possible to stack filters! " + "This limitation will be removed in a future Stage3D version.");
         }
         this.calculateBounds(param1,_loc6_,sBounds);
         this.updateBuffers(_loc7_,sBounds);
         this.updatePassTextures(sBounds.width,sBounds.height,this.mResolution * _loc8_);
         if(param4)
         {
            _loc5_ = Texture.empty(sBounds.width,sBounds.height,this.PMA,true,this.mResolution * _loc8_);
         }
         param2.renderTarget = this.mPassTextures[0];
         param2.clear();
         param2.setOrthographicProjection(sBounds.x,sBounds.y,sBounds.width,sBounds.height);
         param1.render(param2,param3);
         param2.finishQuadBatch();
         param2.loadIdentity();
         _loc7_.setVertexBufferAt(0,this.mVertexBuffer,VertexData.POSITION_OFFSET,Context3DVertexBufferFormat.FLOAT_2);
         _loc7_.setVertexBufferAt(1,this.mVertexBuffer,VertexData.TEXCOORD_OFFSET,Context3DVertexBufferFormat.FLOAT_2);
         var _loc10_:int = 0;
         while(_loc10_ < this.mNumPasses)
         {
            if(_loc10_ < this.mNumPasses - 1)
            {
               param2.renderTarget = this.getPassTexture(_loc10_ + 1);
               param2.clear();
            }
            else if(param4)
            {
               param2.renderTarget = _loc5_;
               param2.clear();
            }
            else
            {
               param2.renderTarget = _loc9_;
               param2.projectionMatrix.copyFrom(this.mProjMatrix);
               param2.translateMatrix(this.mOffsetX,this.mOffsetY);
               param2.blendMode = param1.blendMode;
               param2.applyBlendMode(this.PMA);
            }
            _loc11_ = this.getPassTexture(_loc10_);
            _loc7_.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,0,param2.mvpMatrix3D,true);
            _loc7_.setTextureAt(0,_loc11_.base);
            this.activate(_loc10_,_loc7_,_loc11_);
            _loc7_.drawTriangles(this.mIndexBuffer,0,2);
            this.deactivate(_loc10_,_loc7_,_loc11_);
            _loc10_++;
         }
         _loc7_.setVertexBufferAt(0,null);
         _loc7_.setVertexBufferAt(1,null);
         _loc7_.setTextureAt(0,null);
         param2.popMatrix();
         if(param4)
         {
            param2.renderTarget = _loc9_;
            param2.projectionMatrix.copyFrom(this.mProjMatrix);
            _loc12_ = new QuadBatch();
            _loc13_ = new Image(_loc5_);
            _loc6_.getTransformationMatrix(param1,sTransformationMatrix);
            MatrixUtil.prependTranslation(sTransformationMatrix,sBounds.x + this.mOffsetX,sBounds.y + this.mOffsetY);
            _loc12_.addImage(_loc13_,1,sTransformationMatrix);
            return _loc12_;
         }
         return null;
      }
      
      private function updateBuffers(param1:Context3D, param2:Rectangle) : void
      {
         this.mVertexData.setPosition(0,param2.x,param2.y);
         this.mVertexData.setPosition(1,param2.right,param2.y);
         this.mVertexData.setPosition(2,param2.x,param2.bottom);
         this.mVertexData.setPosition(3,param2.right,param2.bottom);
         if(this.mVertexBuffer == null)
         {
            this.mVertexBuffer = param1.createVertexBuffer(4,VertexData.ELEMENTS_PER_VERTEX);
            this.mIndexBuffer = param1.createIndexBuffer(6);
            this.mIndexBuffer.uploadFromVector(this.mIndexData,0,6);
         }
         this.mVertexBuffer.uploadFromVector(this.mVertexData.rawData,0,4);
      }
      
      private function updatePassTextures(param1:int, param2:int, param3:Number) : void
      {
         var _loc6_:int = 0;
         var _loc7_:Texture = null;
         var _loc4_:int = this.mNumPasses > 1 ? 2 : 1;
         var _loc5_:Boolean = this.mPassTextures == null || this.mPassTextures.length != _loc4_ || this.mPassTextures[0].width != param1 || this.mPassTextures[0].height != param2;
         if(_loc5_)
         {
            if(this.mPassTextures)
            {
               for each(_loc7_ in this.mPassTextures)
               {
                  _loc7_.dispose();
               }
               this.mPassTextures.length = _loc4_;
            }
            else
            {
               this.mPassTextures = new Vector.<Texture>(_loc4_);
            }
            _loc6_ = 0;
            while(_loc6_ < _loc4_)
            {
               this.mPassTextures[_loc6_] = Texture.empty(param1,param2,this.PMA,true,param3);
               _loc6_++;
            }
         }
      }
      
      private function getPassTexture(param1:int) : Texture
      {
         return this.mPassTextures[param1 % 2];
      }
      
      private function calculateBounds(param1:DisplayObject, param2:Stage, param3:Rectangle) : void
      {
         if(param1 == param2 || param1 == Starling.current.root)
         {
            param3.setTo(0,0,param2.stageWidth,param2.stageHeight);
         }
         else
         {
            param1.getBounds(param2,param3);
         }
         var _loc4_:Number = this.mResolution == 1 ? 0 : 1 / this.mResolution;
         param3.x -= this.mMarginX + _loc4_;
         param3.y -= this.mMarginY + _loc4_;
         param3.width += 2 * (this.mMarginX + _loc4_);
         param3.height += 2 * (this.mMarginY + _loc4_);
         param3.width = getNextPowerOfTwo(param3.width * this.mResolution) / this.mResolution;
         param3.height = getNextPowerOfTwo(param3.height * this.mResolution) / this.mResolution;
      }
      
      private function disposePassTextures() : void
      {
         var _loc1_:Texture = null;
         for each(_loc1_ in this.mPassTextures)
         {
            _loc1_.dispose();
         }
         this.mPassTextures = null;
      }
      
      private function disposeCache() : void
      {
         if(this.mCache)
         {
            this.mCache.texture.dispose();
            this.mCache.dispose();
            this.mCache = null;
         }
      }
      
      protected function createPrograms() : void
      {
         throw new Error("Method has to be implemented in subclass!");
      }
      
      protected function activate(param1:int, param2:Context3D, param3:Texture) : void
      {
         throw new Error("Method has to be implemented in subclass!");
      }
      
      protected function deactivate(param1:int, param2:Context3D, param3:Texture) : void
      {
      }
      
      protected function assembleAgal(param1:String = null, param2:String = null) : Program3D
      {
         if(param1 == null)
         {
            param1 = this.STD_FRAGMENT_SHADER;
         }
         if(param2 == null)
         {
            param2 = this.STD_VERTEX_SHADER;
         }
         var _loc3_:AGALMiniAssembler = new AGALMiniAssembler();
         _loc3_.assemble(Context3DProgramType.VERTEX,param2);
         var _loc4_:AGALMiniAssembler = new AGALMiniAssembler();
         _loc4_.assemble(Context3DProgramType.FRAGMENT,param1);
         var _loc5_:Context3D = Starling.context;
         var _loc6_:Program3D = _loc5_.createProgram();
         _loc6_.upload(_loc3_.agalcode,_loc4_.agalcode);
         return _loc6_;
      }
      
      public function cache() : void
      {
         this.mCacheRequested = true;
         this.disposeCache();
      }
      
      public function clearCache() : void
      {
         this.mCacheRequested = false;
         this.disposeCache();
      }
      
      starling_internal function compile(param1:DisplayObject) : QuadBatch
      {
         var _loc2_:RenderSupport = null;
         var _loc3_:Stage = null;
         if(this.mCache)
         {
            return this.mCache;
         }
         _loc3_ = param1.stage;
         if(_loc3_ == null)
         {
            throw new Error("Filtered object must be on the stage.");
         }
         _loc2_ = new RenderSupport();
         param1.getTransformationMatrix(_loc3_,_loc2_.modelViewMatrix);
         return this.renderPasses(param1,_loc2_,1,true);
      }
      
      public function get isCached() : Boolean
      {
         return Boolean(this.mCache) || this.mCacheRequested;
      }
      
      public function get resolution() : Number
      {
         return this.mResolution;
      }
      
      public function set resolution(param1:Number) : void
      {
         if(param1 <= 0)
         {
            throw new ArgumentError("Resolution must be > 0");
         }
         this.mResolution = param1;
      }
      
      public function get mode() : String
      {
         return this.mMode;
      }
      
      public function set mode(param1:String) : void
      {
         this.mMode = param1;
      }
      
      public function get offsetX() : Number
      {
         return this.mOffsetX;
      }
      
      public function set offsetX(param1:Number) : void
      {
         this.mOffsetX = param1;
      }
      
      public function get offsetY() : Number
      {
         return this.mOffsetY;
      }
      
      public function set offsetY(param1:Number) : void
      {
         this.mOffsetY = param1;
      }
      
      protected function get marginX() : Number
      {
         return this.mMarginX;
      }
      
      protected function set marginX(param1:Number) : void
      {
         this.mMarginX = param1;
      }
      
      protected function get marginY() : Number
      {
         return this.mMarginY;
      }
      
      protected function set marginY(param1:Number) : void
      {
         this.mMarginY = param1;
      }
      
      protected function set numPasses(param1:int) : void
      {
         this.mNumPasses = param1;
      }
      
      protected function get numPasses() : int
      {
         return this.mNumPasses;
      }
   }
}

