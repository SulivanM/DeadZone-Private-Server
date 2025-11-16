package thelaststand.app.gui
{
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.ui.Mouse;
   import flash.ui.MouseCursor;
   import flash.ui.MouseCursorData;
   import org.osflash.signals.Signal;
   
   public class MouseCursors
   {
      
      private static var _initialized:Boolean;
      
      public static const OS:String = MouseCursor.AUTO;
      
      public static const DEFAULT:String = "default";
      
      public static const ACTION_MODE:String = "actionMode";
      
      public static const INTERACT:String = "interact";
      
      public static const ATTACK:String = "attack";
      
      public static const ATTACK_MELEE:String = "attackMelee";
      
      public static const ATTACK_SUPPRESS:String = "attackSuppress";
      
      public static const TRAP_DISARM:String = "trapDisarm";
      
      public static const HEAL:String = "heal";
      
      public static const COVER_GREEN:String = "coverGreen";
      
      public static const COVER_YELLOW:String = "coverYellow";
      
      public static const COVER_RED:String = "coverRed";
      
      public static const MOUNT_BUILDING:String = "buildingMount";
      
      public static const DISMOUNT_BUILDING:String = "buildingDismount";
      
      public static var cursorChanged:Signal = new Signal();
      
      public function MouseCursors()
      {
         super();
         throw new Error("MouseCursors cannot be directly instantiated.");
      }
      
      public static function init() : void
      {
         var _loc1_:MouseCursorData = null;
         if(_initialized)
         {
            return;
         }
         _initialized = true;
         _loc1_ = new MouseCursorData();
         _loc1_.data = Vector.<BitmapData>([new BmpCursorDefault()]);
         _loc1_.hotSpot = new Point();
         Mouse.registerCursor(DEFAULT,_loc1_);
         _loc1_ = new MouseCursorData();
         _loc1_.data = Vector.<BitmapData>([new BmpCursorAction()]);
         _loc1_.hotSpot = new Point();
         Mouse.registerCursor(ACTION_MODE,_loc1_);
         _loc1_ = new MouseCursorData();
         _loc1_.data = Vector.<BitmapData>([new BmpCursorInteract()]);
         _loc1_.hotSpot = new Point();
         Mouse.registerCursor(INTERACT,_loc1_);
         _loc1_ = new MouseCursorData();
         _loc1_.data = Vector.<BitmapData>([new BmpCursorInteract()]);
         _loc1_.hotSpot = new Point();
         Mouse.registerCursor(TRAP_DISARM,_loc1_);
         _loc1_ = new MouseCursorData();
         _loc1_.data = Vector.<BitmapData>([new BmpCursorHeal()]);
         _loc1_.hotSpot = new Point();
         Mouse.registerCursor(HEAL,_loc1_);
         _loc1_ = new MouseCursorData();
         _loc1_.data = Vector.<BitmapData>([new BmpCursorAttack()]);
         _loc1_.hotSpot = new Point(_loc1_.data[0].width * 0.5,_loc1_.data[0].height * 0.5);
         Mouse.registerCursor(ATTACK,_loc1_);
         _loc1_ = new MouseCursorData();
         _loc1_.data = Vector.<BitmapData>([new BmpCursorAttackMelee()]);
         _loc1_.hotSpot = new Point(_loc1_.data[0].width * 0.5,_loc1_.data[0].height * 0.5);
         Mouse.registerCursor(ATTACK_MELEE,_loc1_);
         _loc1_ = new MouseCursorData();
         _loc1_.data = Vector.<BitmapData>([new BmpCursorSuppress()]);
         _loc1_.hotSpot = new Point(_loc1_.data[0].width * 0.5,_loc1_.data[0].height * 0.5);
         Mouse.registerCursor(ATTACK_SUPPRESS,_loc1_);
         _loc1_ = new MouseCursorData();
         _loc1_.data = Vector.<BitmapData>([new BmpCursorCoverGreen()]);
         _loc1_.hotSpot = new Point();
         Mouse.registerCursor(COVER_GREEN,_loc1_);
         _loc1_ = new MouseCursorData();
         _loc1_.data = Vector.<BitmapData>([new BmpCursorCoverYellow()]);
         _loc1_.hotSpot = new Point();
         Mouse.registerCursor(COVER_YELLOW,_loc1_);
         _loc1_ = new MouseCursorData();
         _loc1_.data = Vector.<BitmapData>([new BmpCursorCoverRed()]);
         _loc1_.hotSpot = new Point();
         Mouse.registerCursor(COVER_RED,_loc1_);
         _loc1_ = new MouseCursorData();
         _loc1_.data = Vector.<BitmapData>([new BmpCursorMount()]);
         _loc1_.hotSpot = new Point();
         Mouse.registerCursor(MOUNT_BUILDING,_loc1_);
         _loc1_ = new MouseCursorData();
         _loc1_.data = Vector.<BitmapData>([new BmpCursorDismount()]);
         _loc1_.hotSpot = new Point();
         Mouse.registerCursor(DISMOUNT_BUILDING,_loc1_);
      }
      
      public static function setCursor(param1:String) : void
      {
         if(Mouse.cursor == param1)
         {
            return;
         }
         Mouse.cursor = param1;
         cursorChanged.dispatch();
      }
   }
}

