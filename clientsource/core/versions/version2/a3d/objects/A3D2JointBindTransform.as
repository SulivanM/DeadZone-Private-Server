package versions.version2.a3d.objects
{
   import alternativa.types.Long;
   
   public class A3D2JointBindTransform
   {
      
      private var _bindPoseTransform:A3D2Transform;
      
      private var _id:Long;
      
      public function A3D2JointBindTransform(param1:A3D2Transform, param2:Long)
      {
         super();
         this._bindPoseTransform = param1;
         this._id = param2;
      }
      
      public function get bindPoseTransform() : A3D2Transform
      {
         return this._bindPoseTransform;
      }
      
      public function set bindPoseTransform(param1:A3D2Transform) : void
      {
         this._bindPoseTransform = param1;
      }
      
      public function get id() : Long
      {
         return this._id;
      }
      
      public function set id(param1:Long) : void
      {
         this._id = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3D2JointBindTransform [";
         _loc1_ += "bindPoseTransform = " + this.bindPoseTransform + " ";
         _loc1_ += "id = " + this.id + " ";
         return _loc1_ + "]";
      }
   }
}

