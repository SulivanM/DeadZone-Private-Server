package playerio
{
   import flash.utils.ByteArray;
   
   public class Message
   {
      
      private var content:Array;
      
      private var _type:String;
      
      public function Message(param1:String, ... rest)
      {
         var _loc3_:int = 0;
         content = [];
         super();
         this._type = param1;
         _loc3_ = 0;
         while(_loc3_ < rest.length)
         {
            _add(rest[_loc3_]);
            _loc3_++;
         }
      }
      
      public function add(... rest) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < rest.length)
         {
            _add(rest[_loc2_]);
            _loc2_++;
         }
      }
      
      public function getNumber(param1:int) : Number
      {
         return content[param1] as Number;
      }
      
      public function getInt(param1:int) : int
      {
         return content[param1] as int;
      }
      
      public function getUInt(param1:int) : uint
      {
         return content[param1] as uint;
      }
      
      public function getString(param1:int) : String
      {
         return content[param1].toString();
      }
      
      public function getBoolean(param1:int) : Boolean
      {
         return content[param1] as Boolean;
      }
      
      public function getByteArray(param1:int) : ByteArray
      {
         return content[param1] as ByteArray;
      }
      
      public function getObject(param1:int) : *
      {
         return content[param1];
      }
      
      public function clone(param1:Object) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < content.length)
         {
            param1.Add(content[_loc2_]);
            _loc2_++;
         }
      }
      
      public function get length() : int
      {
         return content.length;
      }
      
      public function get type() : String
      {
         return _type;
      }
      
      public function set type(param1:String) : void
      {
         _type = param1;
      }
      
      public function toString() : String
      {
         var _loc3_:int = 0;
         var _loc4_:* = undefined;
         var _loc2_:ByteArray = null;
         var _loc1_:* = "[playerio.Message]\n";
         _loc1_ += "type:\t\t" + type + "\n";
         _loc1_ += "length:\t\t" + length + "\n";
         _loc1_ += "content:\tId\tType\t\tValue\n";
         _loc1_ += "\t\t\t---------------------\n";
         _loc3_ = 0;
         while(_loc3_ < content.length)
         {
            _loc4_ = content[_loc3_];
            if(_loc4_ === undefined)
            {
               _loc1_ += "\t\t\t" + _loc3_ + "\tundefined\t\t" + _loc4_ + "\n";
            }
            else if(_loc4_ is String)
            {
               _loc1_ += "\t\t\t" + _loc3_ + "\tString\t\t" + _loc4_ + "\n";
            }
            else if(_loc4_ is Boolean)
            {
               _loc1_ += "\t\t\t" + _loc3_ + "\tBoolean\t\t" + _loc4_ + "\n";
            }
            else if(_loc4_ is ByteArray)
            {
               _loc1_ += "\t\t\t" + _loc3_ + "\tByteArray\tLength:" + _loc4_.length + "\n";
            }
            else
            {
               _loc2_ = new ByteArray();
               _loc2_.writeInt(_loc4_);
               _loc2_.position = 0;
               switch(_loc4_)
               {
                  case _loc2_.readInt():
                     _loc1_ += "\t\t\t" + _loc3_ + "\tint\t\t\t" + _loc4_ + "\n";
                     break;
                  case _loc2_ = new ByteArray(),_loc2_.writeUnsignedInt(_loc4_),_loc2_.position = 0,_loc2_.readUnsignedInt():
                     _loc1_ += "\t\t\t" + _loc3_ + "\tuint\t\t" + _loc4_ + "\n";
                     break;
                  case _loc2_ = new ByteArray(),_loc2_.writeFloat(_loc4_),_loc2_.position = 0,_loc2_.readFloat():
                     _loc1_ += "\t\t\t" + _loc3_ + "\tFloat\t\t" + _loc4_ + "\n";
                     break;
                  default:
                     _loc1_ += "\t\t\t" + _loc3_ + "\tDouble\t\t" + _loc4_ + "\n";
               }
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      private function _add(param1:*) : void
      {
         if(param1 is Number || param1 is Boolean || param1 is String || param1 is ByteArray)
         {
            content.push(param1);
            return;
         }
         throw new Error(typeof param1 + " is not yet supported");
      }
   }
}

