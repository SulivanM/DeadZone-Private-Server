package alternativa.engine3d.animation.keys
{
   import alternativa.engine3d.alternativa3d;
   
   use namespace alternativa3d;
   
   public class NumberKey extends Keyframe
   {
      
      alternativa3d var _value:Number = 0;
      
      alternativa3d var next:NumberKey;
      
      public function NumberKey()
      {
         super();
      }
      
      public function interpolate(param1:NumberKey, param2:NumberKey, param3:Number) : void
      {
         this.alternativa3d::_value = (1 - param3) * param1.alternativa3d::_value + param3 * param2.alternativa3d::_value;
      }
      
      override public function get value() : Object
      {
         return this.alternativa3d::_value;
      }
      
      override public function set value(param1:Object) : void
      {
         this.alternativa3d::_value = Number(param1);
      }
      
      override alternativa3d function get nextKeyFrame() : Keyframe
      {
         return this.alternativa3d::next;
      }
      
      override alternativa3d function set nextKeyFrame(param1:Keyframe) : void
      {
         this.alternativa3d::next = NumberKey(param1);
      }
   }
}

