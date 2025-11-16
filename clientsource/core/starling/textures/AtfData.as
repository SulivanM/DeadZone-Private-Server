package starling.textures
{
   import flash.display3D.Context3DTextureFormat;
   import flash.utils.ByteArray;
   
   internal class AtfData
   {
      
      private var mFormat:String;
      
      private var mWidth:int;
      
      private var mHeight:int;
      
      private var mNumTextures:int;
      
      private var mData:ByteArray;
      
      public function AtfData(param1:ByteArray)
      {
         super();
         var _loc2_:String = String.fromCharCode(param1[0],param1[1],param1[2]);
         if(_loc2_ != "ATF")
         {
            throw new ArgumentError("Invalid ATF data");
         }
         switch(param1[6])
         {
            case 0:
            case 1:
               this.mFormat = Context3DTextureFormat.BGRA;
               break;
            case 2:
            case 3:
               this.mFormat = Context3DTextureFormat.COMPRESSED;
               break;
            case 4:
            case 5:
               this.mFormat = "compressedAlpha";
               break;
            default:
               throw new Error("Invalid ATF format");
         }
         this.mWidth = Math.pow(2,param1[7]);
         this.mHeight = Math.pow(2,param1[8]);
         this.mNumTextures = param1[9];
         this.mData = param1;
      }
      
      public function get format() : String
      {
         return this.mFormat;
      }
      
      public function get width() : int
      {
         return this.mWidth;
      }
      
      public function get height() : int
      {
         return this.mHeight;
      }
      
      public function get numTextures() : int
      {
         return this.mNumTextures;
      }
      
      public function get data() : ByteArray
      {
         return this.mData;
      }
   }
}

