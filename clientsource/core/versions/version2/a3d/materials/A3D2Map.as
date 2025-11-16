package versions.version2.a3d.materials
{
   public class A3D2Map
   {
      
      private var _channel:uint;
      
      private var _id:int;
      
      private var _imageId:int;
      
      public function A3D2Map(param1:uint, param2:int, param3:int)
      {
         super();
         this._channel = param1;
         this._id = param2;
         this._imageId = param3;
      }
      
      public function get channel() : uint
      {
         return this._channel;
      }
      
      public function set channel(param1:uint) : void
      {
         this._channel = param1;
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function set id(param1:int) : void
      {
         this._id = param1;
      }
      
      public function get imageId() : int
      {
         return this._imageId;
      }
      
      public function set imageId(param1:int) : void
      {
         this._imageId = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3D2Map [";
         _loc1_ += "channel = " + this.channel + " ";
         _loc1_ += "id = " + this.id + " ";
         _loc1_ += "imageId = " + this.imageId + " ";
         return _loc1_ + "]";
      }
   }
}

