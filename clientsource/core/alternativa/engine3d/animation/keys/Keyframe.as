package alternativa.engine3d.animation.keys
{
   import alternativa.engine3d.alternativa3d;
   
   use namespace alternativa3d;
   
   public class Keyframe
   {
      
      alternativa3d var _time:Number = 0;
      
      public function Keyframe()
      {
         super();
      }
      
      public function get time() : Number
      {
         return this.alternativa3d::_time;
      }
      
      public function get value() : Object
      {
         return null;
      }
      
      public function set value(param1:Object) : void
      {
      }
      
      alternativa3d function get nextKeyFrame() : Keyframe
      {
         return null;
      }
      
      alternativa3d function set nextKeyFrame(param1:Keyframe) : void
      {
      }
      
      public function toString() : String
      {
         return "[Keyframe time = " + this.alternativa3d::_time.toFixed(2) + " value = " + this.value + "]";
      }
   }
}

