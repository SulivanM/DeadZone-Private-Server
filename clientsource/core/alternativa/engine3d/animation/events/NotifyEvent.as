package alternativa.engine3d.animation.events
{
   import alternativa.engine3d.animation.AnimationNotify;
   import flash.events.Event;
   
   public class NotifyEvent extends Event
   {
      
      public static const NOTIFY:String = "notify";
      
      public function NotifyEvent(param1:AnimationNotify)
      {
         super(NOTIFY);
      }
      
      public function get notify() : AnimationNotify
      {
         return AnimationNotify(target);
      }
   }
}

