package starling.textures
{
   import flash.display.BitmapData;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DTextureFormat;
   import flash.display3D.textures.Texture;
   import flash.display3D.textures.TextureBase;
   import starling.core.Starling;
   import starling.events.Event;
   
   public class ConcreteTexture extends starling.textures.Texture
   {
      
      private var mBase:TextureBase;
      
      private var mFormat:String;
      
      private var mWidth:int;
      
      private var mHeight:int;
      
      private var mMipMapping:Boolean;
      
      private var mPremultipliedAlpha:Boolean;
      
      private var mOptimizedForRenderTexture:Boolean;
      
      private var mData:Object;
      
      private var mScale:Number;
      
      public function ConcreteTexture(param1:TextureBase, param2:String, param3:int, param4:int, param5:Boolean, param6:Boolean, param7:Boolean = false, param8:Number = 1)
      {
         super();
         this.mScale = param8 <= 0 ? 1 : param8;
         this.mBase = param1;
         this.mFormat = param2;
         this.mWidth = param3;
         this.mHeight = param4;
         this.mMipMapping = param5;
         this.mPremultipliedAlpha = param6;
         this.mOptimizedForRenderTexture = param7;
      }
      
      override public function dispose() : void
      {
         if(this.mBase)
         {
            this.mBase.dispose();
         }
         this.restoreOnLostContext(null);
         super.dispose();
      }
      
      public function restoreOnLostContext(param1:Object) : void
      {
         if(this.mData == null && param1 != null)
         {
            Starling.current.addEventListener(Event.CONTEXT3D_CREATE,this.onContextCreated);
         }
         if(param1 == null)
         {
            Starling.current.removeEventListener(Event.CONTEXT3D_CREATE,this.onContextCreated);
         }
         this.mData = param1;
      }
      
      private function onContextCreated(param1:Event) : void
      {
         var _loc5_:flash.display3D.textures.Texture = null;
         var _loc2_:Context3D = Starling.context;
         var _loc3_:BitmapData = this.mData as BitmapData;
         var _loc4_:AtfData = this.mData as AtfData;
         if(_loc3_)
         {
            _loc5_ = _loc2_.createTexture(this.mWidth,this.mHeight,Context3DTextureFormat.BGRA,this.mOptimizedForRenderTexture);
            starling.textures.Texture.uploadBitmapData(_loc5_,_loc3_,this.mMipMapping);
         }
         else if(_loc4_)
         {
            _loc5_ = _loc2_.createTexture(_loc4_.width,_loc4_.height,_loc4_.format,this.mOptimizedForRenderTexture);
            starling.textures.Texture.uploadAtfData(_loc5_,_loc4_.data);
         }
         this.mBase = _loc5_;
      }
      
      public function get optimizedForRenderTexture() : Boolean
      {
         return this.mOptimizedForRenderTexture;
      }
      
      override public function get base() : TextureBase
      {
         return this.mBase;
      }
      
      override public function get format() : String
      {
         return this.mFormat;
      }
      
      override public function get width() : Number
      {
         return this.mWidth / this.mScale;
      }
      
      override public function get height() : Number
      {
         return this.mHeight / this.mScale;
      }
      
      override public function get scale() : Number
      {
         return this.mScale;
      }
      
      override public function get mipMapping() : Boolean
      {
         return this.mMipMapping;
      }
      
      override public function get premultipliedAlpha() : Boolean
      {
         return this.mPremultipliedAlpha;
      }
   }
}

