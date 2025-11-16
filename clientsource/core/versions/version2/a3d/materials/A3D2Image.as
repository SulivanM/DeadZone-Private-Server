package versions.version2.a3d.materials
{
   public class A3D2Image
   {
      
      private var _id:int;
      
      private var _url:String;
      
      public function A3D2Image(param1:int, param2:String)
      {
         super();
         this._id = param1;
         this._url = param2;
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function set id(param1:int) : void
      {
         this._id = param1;
      }
      
      public function get url() : String
      {
         return this._url;
      }
      
      public function set url(param1:String) : void
      {
         this._url = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3D2Image [";
         _loc1_ += "id = " + this.id + " ";
         _loc1_ += "url = " + this.url + " ";
         return _loc1_ + "]";
      }
   }
}

