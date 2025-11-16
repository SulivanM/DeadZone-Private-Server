package alternativa.engine3d.animation
{
   import alternativa.engine3d.alternativa3d;
   import flash.events.EventDispatcher;
   
   use namespace alternativa3d;
   
   public class AnimationNotify extends EventDispatcher
   {
      
      public var name:String;
      
      alternativa3d var _time:Number = 0;
      
      alternativa3d var next:AnimationNotify;
      
      alternativa3d var updateTime:Number;
      
      alternativa3d var processNext:AnimationNotify;
      
      public function AnimationNotify(param1:String)
      {
         super();
         this.name = param1;
      }
      
      public function get time() : Number
      {
         return this.alternativa3d::_time;
      }
   }
}

