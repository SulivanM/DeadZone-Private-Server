package versions.version1.a3d.materials
{
   import commons.Id;
   
   public class A3DImage
   {
      
      private var _id:Id;
      
      private var _url:String;
      
      public function A3DImage(param1:Id, param2:String)
      {
         super();
         this._id = param1;
         this._url = param2;
      }
      
      public function get id() : Id
      {
         return this._id;
      }
      
      public function set id(param1:Id) : void
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
         var _loc1_:String = "A3DImage [";
         _loc1_ += "id = " + this.id + " ";
         _loc1_ += "url = " + this.url + " ";
         return _loc1_ + "]";
      }
   }
}

