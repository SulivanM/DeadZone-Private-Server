package versions.version2.a3d.animation
{
   import versions.version2.a3d.objects.A3D2Transform;
   
   public class A3D2Keyframe
   {
      
      private var _time:Number;
      
      private var _transform:A3D2Transform;
      
      public function A3D2Keyframe(param1:Number, param2:A3D2Transform)
      {
         super();
         this._time = param1;
         this._transform = param2;
      }
      
      public function get time() : Number
      {
         return this._time;
      }
      
      public function set time(param1:Number) : void
      {
         this._time = param1;
      }
      
      public function get transform() : A3D2Transform
      {
         return this._transform;
      }
      
      public function set transform(param1:A3D2Transform) : void
      {
         this._transform = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3D2Keyframe [";
         _loc1_ += "time = " + this.time + " ";
         _loc1_ += "transform = " + this.transform + " ";
         return _loc1_ + "]";
      }
   }
}

