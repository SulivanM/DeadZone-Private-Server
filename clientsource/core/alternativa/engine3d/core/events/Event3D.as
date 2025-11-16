package alternativa.engine3d.core.events
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Object3D;
   import flash.events.Event;
   
   use namespace alternativa3d;
   
   public class Event3D extends Event
   {
      
      public static const ADDED:String = "added3D";
      
      public static const REMOVED:String = "removed3D";
      
      alternativa3d var _target:Object3D;
      
      alternativa3d var _currentTarget:Object3D;
      
      alternativa3d var _bubbles:Boolean;
      
      alternativa3d var _eventPhase:uint = 3;
      
      alternativa3d var stop:Boolean = false;
      
      alternativa3d var stopImmediate:Boolean = false;
      
      public function Event3D(param1:String, param2:Boolean = true)
      {
         super(param1,param2);
         this.alternativa3d::_bubbles = param2;
      }
      
      override public function get bubbles() : Boolean
      {
         return this.alternativa3d::_bubbles;
      }
      
      override public function get eventPhase() : uint
      {
         return this.alternativa3d::_eventPhase;
      }
      
      override public function get target() : Object
      {
         return this.alternativa3d::_target;
      }
      
      override public function get currentTarget() : Object
      {
         return this.alternativa3d::_currentTarget;
      }
      
      override public function stopPropagation() : void
      {
         this.alternativa3d::stop = true;
      }
      
      override public function stopImmediatePropagation() : void
      {
         this.alternativa3d::stopImmediate = true;
      }
      
      override public function clone() : Event
      {
         var _loc1_:Event3D = new Event3D(type,this.alternativa3d::_bubbles);
         _loc1_.alternativa3d::_target = this.alternativa3d::_target;
         _loc1_.alternativa3d::_currentTarget = this.alternativa3d::_currentTarget;
         _loc1_.alternativa3d::_eventPhase = this.alternativa3d::_eventPhase;
         return _loc1_;
      }
      
      override public function toString() : String
      {
         return formatToString("Event3D","type","bubbles","eventPhase");
      }
   }
}

