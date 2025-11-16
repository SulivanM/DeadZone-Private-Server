package versions.version1.a3d.materials
{
   import commons.Id;
   
   public class A3DMap
   {
      
      private var _channel:uint;
      
      private var _id:Id;
      
      private var _imageId:Id;
      
      private var _uOffset:Number;
      
      private var _uScale:Number;
      
      private var _vOffset:Number;
      
      private var _vScale:Number;
      
      public function A3DMap(param1:uint, param2:Id, param3:Id, param4:Number, param5:Number, param6:Number, param7:Number)
      {
         super();
         this._channel = param1;
         this._id = param2;
         this._imageId = param3;
         this._uOffset = param4;
         this._uScale = param5;
         this._vOffset = param6;
         this._vScale = param7;
      }
      
      public function get channel() : uint
      {
         return this._channel;
      }
      
      public function set channel(param1:uint) : void
      {
         this._channel = param1;
      }
      
      public function get id() : Id
      {
         return this._id;
      }
      
      public function set id(param1:Id) : void
      {
         this._id = param1;
      }
      
      public function get imageId() : Id
      {
         return this._imageId;
      }
      
      public function set imageId(param1:Id) : void
      {
         this._imageId = param1;
      }
      
      public function get uOffset() : Number
      {
         return this._uOffset;
      }
      
      public function set uOffset(param1:Number) : void
      {
         this._uOffset = param1;
      }
      
      public function get uScale() : Number
      {
         return this._uScale;
      }
      
      public function set uScale(param1:Number) : void
      {
         this._uScale = param1;
      }
      
      public function get vOffset() : Number
      {
         return this._vOffset;
      }
      
      public function set vOffset(param1:Number) : void
      {
         this._vOffset = param1;
      }
      
      public function get vScale() : Number
      {
         return this._vScale;
      }
      
      public function set vScale(param1:Number) : void
      {
         this._vScale = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3DMap [";
         _loc1_ += "channel = " + this.channel + " ";
         _loc1_ += "id = " + this.id + " ";
         _loc1_ += "imageId = " + this.imageId + " ";
         _loc1_ += "uOffset = " + this.uOffset + " ";
         _loc1_ += "uScale = " + this.uScale + " ";
         _loc1_ += "vOffset = " + this.vOffset + " ";
         _loc1_ += "vScale = " + this.vScale + " ";
         return _loc1_ + "]";
      }
   }
}

