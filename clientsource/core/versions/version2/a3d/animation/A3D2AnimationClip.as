package versions.version2.a3d.animation
{
   import alternativa.types.Long;
   
   public class A3D2AnimationClip
   {
      
      private var _id:int;
      
      private var _loop:Boolean;
      
      private var _name:String;
      
      private var _objectIDs:Vector.<Long>;
      
      private var _tracks:Vector.<int>;
      
      public function A3D2AnimationClip(param1:int, param2:Boolean, param3:String, param4:Vector.<Long>, param5:Vector.<int>)
      {
         super();
         this._id = param1;
         this._loop = param2;
         this._name = param3;
         this._objectIDs = param4;
         this._tracks = param5;
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function set id(param1:int) : void
      {
         this._id = param1;
      }
      
      public function get loop() : Boolean
      {
         return this._loop;
      }
      
      public function set loop(param1:Boolean) : void
      {
         this._loop = param1;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function set name(param1:String) : void
      {
         this._name = param1;
      }
      
      public function get objectIDs() : Vector.<Long>
      {
         return this._objectIDs;
      }
      
      public function set objectIDs(param1:Vector.<Long>) : void
      {
         this._objectIDs = param1;
      }
      
      public function get tracks() : Vector.<int>
      {
         return this._tracks;
      }
      
      public function set tracks(param1:Vector.<int>) : void
      {
         this._tracks = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3D2AnimationClip [";
         _loc1_ += "id = " + this.id + " ";
         _loc1_ += "loop = " + this.loop + " ";
         _loc1_ += "name = " + this.name + " ";
         _loc1_ += "objectIDs = " + this.objectIDs + " ";
         _loc1_ += "tracks = " + this.tracks + " ";
         return _loc1_ + "]";
      }
   }
}

