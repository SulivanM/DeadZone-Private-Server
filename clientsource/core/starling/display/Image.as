package starling.display
{
   import flash.display.Bitmap;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.core.RenderSupport;
   import starling.textures.Texture;
   import starling.textures.TextureSmoothing;
   import starling.utils.VertexData;
   
   public class Image extends Quad
   {
      
      private var mTexture:Texture;
      
      private var mSmoothing:String;
      
      private var mVertexDataCache:VertexData;
      
      private var mVertexDataCacheInvalid:Boolean;
      
      public function Image(param1:Texture)
      {
         var _loc2_:Rectangle = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Boolean = false;
         if(param1)
         {
            _loc2_ = param1.frame;
            _loc3_ = _loc2_ ? _loc2_.width : param1.width;
            _loc4_ = _loc2_ ? _loc2_.height : param1.height;
            _loc5_ = param1.premultipliedAlpha;
            super(_loc3_,_loc4_,16777215,_loc5_);
            mVertexData.setTexCoords(0,0,0);
            mVertexData.setTexCoords(1,1,0);
            mVertexData.setTexCoords(2,0,1);
            mVertexData.setTexCoords(3,1,1);
            this.mTexture = param1;
            this.mSmoothing = TextureSmoothing.BILINEAR;
            this.mVertexDataCache = new VertexData(4,_loc5_);
            this.mVertexDataCacheInvalid = true;
            return;
         }
         throw new ArgumentError("Texture cannot be null");
      }
      
      public static function fromBitmap(param1:Bitmap) : Image
      {
         return new Image(Texture.fromBitmap(param1));
      }
      
      override protected function onVertexDataChanged() : void
      {
         this.mVertexDataCacheInvalid = true;
      }
      
      public function readjustSize() : void
      {
         var _loc1_:Rectangle = this.texture.frame;
         var _loc2_:Number = _loc1_ ? _loc1_.width : this.texture.width;
         var _loc3_:Number = _loc1_ ? _loc1_.height : this.texture.height;
         mVertexData.setPosition(0,0,0);
         mVertexData.setPosition(1,_loc2_,0);
         mVertexData.setPosition(2,0,_loc3_);
         mVertexData.setPosition(3,_loc2_,_loc3_);
         this.onVertexDataChanged();
      }
      
      public function setTexCoords(param1:int, param2:Point) : void
      {
         mVertexData.setTexCoords(param1,param2.x,param2.y);
         this.onVertexDataChanged();
      }
      
      public function getTexCoords(param1:int, param2:Point = null) : Point
      {
         if(param2 == null)
         {
            param2 = new Point();
         }
         mVertexData.getTexCoords(param1,param2);
         return param2;
      }
      
      override public function copyVertexDataTo(param1:VertexData, param2:int = 0) : void
      {
         if(this.mVertexDataCacheInvalid)
         {
            this.mVertexDataCacheInvalid = false;
            mVertexData.copyTo(this.mVertexDataCache);
            this.mTexture.adjustVertexData(this.mVertexDataCache,0,4);
         }
         this.mVertexDataCache.copyTo(param1,param2);
      }
      
      public function get texture() : Texture
      {
         return this.mTexture;
      }
      
      public function set texture(param1:Texture) : void
      {
         if(param1 == null)
         {
            throw new ArgumentError("Texture cannot be null");
         }
         if(param1 != this.mTexture)
         {
            this.mTexture = param1;
            mVertexData.setPremultipliedAlpha(this.mTexture.premultipliedAlpha);
            this.onVertexDataChanged();
         }
      }
      
      public function get smoothing() : String
      {
         return this.mSmoothing;
      }
      
      public function set smoothing(param1:String) : void
      {
         if(TextureSmoothing.isValid(param1))
         {
            this.mSmoothing = param1;
            return;
         }
         throw new ArgumentError("Invalid smoothing mode: " + param1);
      }
      
      override public function render(param1:RenderSupport, param2:Number) : void
      {
         param1.batchQuad(this,param2,this.mTexture,this.mSmoothing);
      }
   }
}

