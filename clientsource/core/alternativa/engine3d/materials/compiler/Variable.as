package alternativa.engine3d.materials.compiler
{
   import flash.utils.ByteArray;
   
   public class Variable
   {
      
      private static var collector:Variable;
      
      protected static const X_CHAR_CODE:Number = "x".charCodeAt(0);
      
      public var name:String;
      
      public var index:int;
      
      public var type:uint;
      
      public var position:uint = 0;
      
      public var next:Variable;
      
      public var lowerCode:uint;
      
      public var upperCode:uint;
      
      public var isRelative:Boolean;
      
      private var _size:uint = 1;
      
      public function Variable()
      {
         super();
      }
      
      public static function create() : Variable
      {
         if(collector == null)
         {
            collector = new Variable();
         }
         var _loc1_:Variable = collector;
         collector = collector.next;
         _loc1_.next = null;
         return _loc1_;
      }
      
      public function dispose() : void
      {
         this.next = collector;
         collector = this;
      }
      
      public function get size() : uint
      {
         return this._size;
      }
      
      public function set size(param1:uint) : void
      {
         this._size = param1;
      }
      
      public function writeToByteArray(param1:ByteArray, param2:int, param3:int, param4:int = 0) : void
      {
         param1.position = this.position + param4;
         param1.writeShort(param2);
      }
   }
}

