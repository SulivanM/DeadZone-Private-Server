package alternativa.engine3d.core.events
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.objects.Surface;
   import flash.events.Event;
   
   use namespace alternativa3d;
   
   public class MouseEvent3D extends Event3D
   {
      
      public static const CLICK:String = "click3D";
      
      public static const DOUBLE_CLICK:String = "doubleClick3D";
      
      public static const MOUSE_DOWN:String = "mouseDown3D";
      
      public static const MOUSE_UP:String = "mouseUp3D";
      
      public static const RIGHT_CLICK:String = "rightClick3D";
      
      public static const RIGHT_MOUSE_DOWN:String = "rightMouseDown3D";
      
      public static const RIGHT_MOUSE_UP:String = "rightMouseUp3D";
      
      public static const MIDDLE_CLICK:String = "middleClick3D";
      
      public static const MIDDLE_MOUSE_DOWN:String = "middleMouseDown3D";
      
      public static const MIDDLE_MOUSE_UP:String = "middleMouseUp3D";
      
      public static const MOUSE_OVER:String = "mouseOver3D";
      
      public static const MOUSE_OUT:String = "mouseOut3D";
      
      public static const ROLL_OVER:String = "rollOver3D";
      
      public static const ROLL_OUT:String = "rollOut3D";
      
      public static const MOUSE_MOVE:String = "mouseMove3D";
      
      public static const MOUSE_WHEEL:String = "mouseWheel3D";
      
      public var ctrlKey:Boolean;
      
      public var altKey:Boolean;
      
      public var shiftKey:Boolean;
      
      public var buttonDown:Boolean;
      
      public var delta:int;
      
      public var relatedObject:Object3D;
      
      public var localX:Number;
      
      public var localY:Number;
      
      public var localZ:Number;
      
      alternativa3d var _surface:Surface;
      
      public function MouseEvent3D(param1:String, param2:Boolean = true, param3:Number = NaN, param4:Number = NaN, param5:Number = NaN, param6:Object3D = null, param7:Boolean = false, param8:Boolean = false, param9:Boolean = false, param10:Boolean = false, param11:int = 0)
      {
         super(param1,param2);
         this.localX = param3;
         this.localY = param4;
         this.localZ = param5;
         this.relatedObject = param6;
         this.ctrlKey = param7;
         this.altKey = param8;
         this.shiftKey = param9;
         this.buttonDown = param10;
         this.delta = param11;
      }
      
      public function get surface() : Surface
      {
         return this.alternativa3d::_surface;
      }
      
      override public function clone() : Event
      {
         return new MouseEvent3D(type,alternativa3d::_bubbles,this.localX,this.localY,this.localZ,this.relatedObject,this.ctrlKey,this.altKey,this.shiftKey,this.buttonDown,this.delta);
      }
      
      override public function toString() : String
      {
         return formatToString("MouseEvent3D","type","bubbles","eventPhase","localX","localY","localZ","relatedObject","altKey","ctrlKey","shiftKey","buttonDown","delta");
      }
   }
}

