package versions.version2.a3d.animation
{
   public class A3D2Track
   {
      
      private var _id:int;
      
      private var _keyframes:Vector.<A3D2Keyframe>;
      
      private var _objectName:String;
      
      public function A3D2Track(param1:int, param2:Vector.<A3D2Keyframe>, param3:String)
      {
         super();
         this._id = param1;
         this._keyframes = param2;
         this._objectName = param3;
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function set id(param1:int) : void
      {
         this._id = param1;
      }
      
      public function get keyframes() : Vector.<A3D2Keyframe>
      {
         return this._keyframes;
      }
      
      public function set keyframes(param1:Vector.<A3D2Keyframe>) : void
      {
         this._keyframes = param1;
      }
      
      public function get objectName() : String
      {
         return this._objectName;
      }
      
      public function set objectName(param1:String) : void
      {
         this._objectName = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3D2Track [";
         _loc1_ += "id = " + this.id + " ";
         _loc1_ += "keyframes = " + this.keyframes + " ";
         _loc1_ += "objectName = " + this.objectName + " ";
         return _loc1_ + "]";
      }
   }
}

