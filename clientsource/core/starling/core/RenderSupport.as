package starling.core
{
   import flash.geom.*;
   import starling.display.*;
   import starling.textures.Texture;
   import starling.utils.*;
   
   public class RenderSupport
   {
      
      private var mProjectionMatrix:Matrix;
      
      private var mModelViewMatrix:Matrix;
      
      private var mMvpMatrix:Matrix;
      
      private var mMvpMatrix3D:Matrix3D;
      
      private var mMatrixStack:Vector.<Matrix>;
      
      private var mMatrixStackSize:int;
      
      private var mDrawCount:int;
      
      private var mRenderTarget:Texture;
      
      private var mBlendMode:String;
      
      private var mQuadBatches:Vector.<QuadBatch>;
      
      private var mCurrentQuadBatchID:int;
      
      public function RenderSupport()
      {
         super();
         this.mProjectionMatrix = new Matrix();
         this.mModelViewMatrix = new Matrix();
         this.mMvpMatrix = new Matrix();
         this.mMvpMatrix3D = new Matrix3D();
         this.mMatrixStack = new Vector.<Matrix>(0);
         this.mMatrixStackSize = 0;
         this.mDrawCount = 0;
         this.mRenderTarget = null;
         this.mBlendMode = BlendMode.NORMAL;
         this.mCurrentQuadBatchID = 0;
         this.mQuadBatches = new <QuadBatch>[new QuadBatch()];
         this.loadIdentity();
         this.setOrthographicProjection(0,0,400,300);
      }
      
      public static function transformMatrixForObject(param1:Matrix, param2:DisplayObject) : void
      {
         MatrixUtil.prependMatrix(param1,param2.transformationMatrix);
      }
      
      public static function setDefaultBlendFactors(param1:Boolean) : void
      {
         setBlendFactors(param1);
      }
      
      public static function setBlendFactors(param1:Boolean, param2:String = "normal") : void
      {
         var _loc3_:Array = BlendMode.getBlendFactors(param2,param1);
         Starling.context.setBlendFactors(_loc3_[0],_loc3_[1]);
      }
      
      public static function clear(param1:uint = 0, param2:Number = 0) : void
      {
         Starling.context.clear(Color.getRed(param1) / 255,Color.getGreen(param1) / 255,Color.getBlue(param1) / 255,param2);
      }
      
      public function dispose() : void
      {
         var _loc1_:QuadBatch = null;
         for each(_loc1_ in this.mQuadBatches)
         {
            _loc1_.dispose();
         }
      }
      
      public function setOrthographicProjection(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         this.mProjectionMatrix.setTo(2 / param3,0,0,-2 / param4,-(2 * param1 + param3) / param3,(2 * param2 + param4) / param4);
      }
      
      public function loadIdentity() : void
      {
         this.mModelViewMatrix.identity();
      }
      
      public function translateMatrix(param1:Number, param2:Number) : void
      {
         MatrixUtil.prependTranslation(this.mModelViewMatrix,param1,param2);
      }
      
      public function rotateMatrix(param1:Number) : void
      {
         MatrixUtil.prependRotation(this.mModelViewMatrix,param1);
      }
      
      public function scaleMatrix(param1:Number, param2:Number) : void
      {
         MatrixUtil.prependScale(this.mModelViewMatrix,param1,param2);
      }
      
      public function prependMatrix(param1:Matrix) : void
      {
         MatrixUtil.prependMatrix(this.mModelViewMatrix,param1);
      }
      
      public function transformMatrix(param1:DisplayObject) : void
      {
         MatrixUtil.prependMatrix(this.mModelViewMatrix,param1.transformationMatrix);
      }
      
      public function pushMatrix() : void
      {
         if(this.mMatrixStack.length < this.mMatrixStackSize + 1)
         {
            this.mMatrixStack.push(new Matrix());
         }
         this.mMatrixStack[this.mMatrixStackSize++].copyFrom(this.mModelViewMatrix);
      }
      
      public function popMatrix() : void
      {
         this.mModelViewMatrix.copyFrom(this.mMatrixStack[--this.mMatrixStackSize]);
      }
      
      public function resetMatrix() : void
      {
         this.mMatrixStackSize = 0;
         this.loadIdentity();
      }
      
      public function get mvpMatrix() : Matrix
      {
         this.mMvpMatrix.copyFrom(this.mModelViewMatrix);
         this.mMvpMatrix.concat(this.mProjectionMatrix);
         return this.mMvpMatrix;
      }
      
      public function get mvpMatrix3D() : Matrix3D
      {
         return MatrixUtil.convertTo3D(this.mvpMatrix,this.mMvpMatrix3D);
      }
      
      public function get modelViewMatrix() : Matrix
      {
         return this.mModelViewMatrix;
      }
      
      public function get projectionMatrix() : Matrix
      {
         return this.mProjectionMatrix;
      }
      
      public function applyBlendMode(param1:Boolean) : void
      {
         setBlendFactors(param1,this.mBlendMode);
      }
      
      public function get blendMode() : String
      {
         return this.mBlendMode;
      }
      
      public function set blendMode(param1:String) : void
      {
         if(param1 != BlendMode.AUTO)
         {
            this.mBlendMode = param1;
         }
      }
      
      public function get renderTarget() : Texture
      {
         return this.mRenderTarget;
      }
      
      public function set renderTarget(param1:Texture) : void
      {
         this.mRenderTarget = param1;
         if(param1)
         {
            Starling.context.setRenderToTexture(param1.base);
         }
         else
         {
            Starling.context.setRenderToBackBuffer();
         }
      }
      
      public function batchQuad(param1:Quad, param2:Number, param3:Texture = null, param4:String = null) : void
      {
         if(this.mQuadBatches[this.mCurrentQuadBatchID].isStateChange(param1.tinted,param2,param3,param4,this.mBlendMode))
         {
            this.finishQuadBatch();
         }
         this.mQuadBatches[this.mCurrentQuadBatchID].addQuad(param1,param2,param3,param4,this.mModelViewMatrix,this.mBlendMode);
      }
      
      public function finishQuadBatch() : void
      {
         var _loc1_:QuadBatch = this.mQuadBatches[this.mCurrentQuadBatchID];
         if(_loc1_.numQuads != 0)
         {
            _loc1_.renderCustom(this.mProjectionMatrix);
            _loc1_.reset();
            ++this.mCurrentQuadBatchID;
            ++this.mDrawCount;
            if(this.mQuadBatches.length <= this.mCurrentQuadBatchID)
            {
               this.mQuadBatches.push(new QuadBatch());
            }
         }
      }
      
      public function nextFrame() : void
      {
         this.resetMatrix();
         this.mBlendMode = BlendMode.NORMAL;
         this.mCurrentQuadBatchID = 0;
         this.mDrawCount = 0;
      }
      
      public function clear(param1:uint = 0, param2:Number = 0) : void
      {
         RenderSupport.clear(param1,param2);
      }
      
      public function raiseDrawCount(param1:uint = 1) : void
      {
         this.mDrawCount += param1;
      }
      
      public function get drawCount() : int
      {
         return this.mDrawCount;
      }
   }
}

