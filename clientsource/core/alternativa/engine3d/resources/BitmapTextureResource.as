package alternativa.engine3d.resources
{
   import alternativa.engine3d.alternativa3d;
   import flash.display.BitmapData;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DTextureFormat;
   import flash.display3D.textures.Texture;
   import flash.filters.ConvolutionFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   use namespace alternativa3d;
   
   public class BitmapTextureResource extends TextureResource
   {
      
      private static const rect:Rectangle = new Rectangle();
      
      private static const filter:ConvolutionFilter = new ConvolutionFilter(2,2,[1,1,1,1],4,0,false,true);
      
      private static const matrix:Matrix = new Matrix(0.5,0,0,0.5);
      
      private static const resizeMatrix:Matrix = new Matrix(1,0,0,1);
      
      private static const point:Point = new Point();
      
      public var data:BitmapData;
      
      public var resizeForGPU:Boolean = false;
      
      public function BitmapTextureResource(param1:BitmapData, param2:Boolean = false)
      {
         super();
         this.data = param1;
         this.resizeForGPU = param2;
      }
      
      alternativa3d static function createMips(param1:Texture, param2:BitmapData) : void
      {
         rect.width = param2.width;
         rect.height = param2.height;
         var _loc3_:int = 1;
         var _loc4_:BitmapData = new BitmapData(rect.width,rect.height,param2.transparent);
         var _loc5_:BitmapData = param2;
         while(rect.width % 2 == 0 || rect.height % 2 == 0)
         {
            _loc4_.copyPixels(_loc5_,rect,point);
            rect.width >>= 1;
            rect.height >>= 1;
            if(rect.width == 0)
            {
               rect.width = 1;
            }
            if(rect.height == 0)
            {
               rect.height = 1;
            }
            if(_loc5_ != param2)
            {
               _loc5_.dispose();
            }
            _loc5_ = new BitmapData(rect.width,rect.height,param2.transparent,0);
            _loc5_.draw(_loc4_,matrix,null,null,null,true);
            param1.uploadFromBitmapData(_loc5_,_loc3_++);
         }
         if(_loc5_ != param2)
         {
            _loc5_.dispose();
         }
         _loc4_.dispose();
      }
      
      override public function upload(param1:Context3D) : void
      {
         var _loc2_:BitmapData = null;
         var _loc3_:int = 0;
         var _loc4_:BitmapData = null;
         var _loc5_:BitmapData = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         if(alternativa3d::_texture != null)
         {
            alternativa3d::_texture.dispose();
         }
         if(this.data != null)
         {
            _loc2_ = this.data;
            if(this.resizeForGPU)
            {
               _loc6_ = Math.log(this.data.width) / Math.LN2;
               _loc7_ = Math.log(this.data.height) / Math.LN2;
               _loc8_ = Math.ceil(_loc6_);
               _loc9_ = Math.ceil(_loc7_);
               if(_loc8_ != _loc6_ || _loc9_ != _loc7_ || _loc8_ > 11 || _loc9_ > 11)
               {
                  _loc8_ = _loc8_ > 11 ? 11 : _loc8_;
                  _loc9_ = _loc9_ > 11 ? 11 : _loc9_;
                  _loc2_ = new BitmapData(1 << _loc8_,1 << _loc9_,this.data.transparent,0);
                  resizeMatrix.a = (1 << _loc8_) / this.data.width;
                  resizeMatrix.d = (1 << _loc9_) / this.data.height;
                  _loc2_.draw(this.data,resizeMatrix,null,null,null,true);
               }
            }
            alternativa3d::_texture = param1.createTexture(_loc2_.width,_loc2_.height,Context3DTextureFormat.BGRA,false);
            Texture(alternativa3d::_texture).uploadFromBitmapData(_loc2_,0);
            filter.preserveAlpha = !_loc2_.transparent;
            _loc3_ = 1;
            _loc4_ = new BitmapData(_loc2_.width,_loc2_.height,_loc2_.transparent);
            _loc5_ = _loc2_;
            rect.width = _loc2_.width;
            rect.height = _loc2_.height;
            while(rect.width % 2 == 0 || rect.height % 2 == 0)
            {
               _loc4_.copyPixels(_loc5_,rect,point);
               rect.width >>= 1;
               rect.height >>= 1;
               if(rect.width == 0)
               {
                  rect.width = 1;
               }
               if(rect.height == 0)
               {
                  rect.height = 1;
               }
               if(_loc5_ != _loc2_)
               {
                  _loc5_.dispose();
               }
               _loc5_ = new BitmapData(rect.width,rect.height,_loc2_.transparent,0);
               _loc5_.draw(_loc4_,matrix,null,null,null,true);
               Texture(alternativa3d::_texture).uploadFromBitmapData(_loc5_,_loc3_++);
            }
            if(_loc5_ != _loc2_)
            {
               _loc5_.dispose();
            }
            _loc4_.dispose();
            _disposed = false;
            return;
         }
         alternativa3d::_texture = null;
         throw new Error("Cannot upload without data");
      }
      
      alternativa3d function createMips(param1:Texture, param2:BitmapData) : void
      {
         rect.width = param2.width;
         rect.height = param2.height;
         var _loc3_:int = 1;
         var _loc4_:BitmapData = new BitmapData(rect.width,rect.height,param2.transparent);
         var _loc5_:BitmapData = param2;
         while(rect.width % 2 == 0 || rect.height % 2 == 0)
         {
            _loc4_.copyPixels(_loc5_,rect,point);
            rect.width >>= 1;
            rect.height >>= 1;
            if(rect.width == 0)
            {
               rect.width = 1;
            }
            if(rect.height == 0)
            {
               rect.height = 1;
            }
            if(_loc5_ != param2)
            {
               _loc5_.dispose();
            }
            _loc5_ = new BitmapData(rect.width,rect.height,param2.transparent,0);
            _loc5_.draw(_loc4_,matrix,null,null,null,true);
            param1.uploadFromBitmapData(_loc5_,_loc3_++);
         }
         if(_loc5_ != param2)
         {
            _loc5_.dispose();
         }
         _loc4_.dispose();
      }
   }
}

