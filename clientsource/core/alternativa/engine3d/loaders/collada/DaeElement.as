package alternativa.engine3d.loaders.collada
{
   import flash.utils.ByteArray;
   
   use namespace collada;
   
   public class DaeElement
   {
      
      private static var _byteArray:ByteArray = new ByteArray();
      
      public var document:DaeDocument;
      
      public var data:XML;
      
      private var _parsed:int = -1;
      
      public function DaeElement(param1:XML, param2:DaeDocument)
      {
         super();
         this.document = param2;
         this.data = param1;
      }
      
      public function cloneString(param1:String) : String
      {
         if(param1 == null)
         {
            return null;
         }
         _byteArray.position = 0;
         _byteArray.writeUTF(param1);
         _byteArray.position = 0;
         return _byteArray.readUTF();
      }
      
      public function parse() : Boolean
      {
         if(this._parsed < 0)
         {
            this._parsed = this.parseImplementation() ? 1 : 0;
            return this._parsed != 0;
         }
         return this._parsed != 0;
      }
      
      protected function parseImplementation() : Boolean
      {
         return true;
      }
      
      protected function parseStringArray(param1:XML) : Array
      {
         return param1.text().toString().split(/\s+/);
      }
      
      protected function parseNumbersArray(param1:XML) : Array
      {
         var _loc5_:String = null;
         var _loc2_:Array = param1.text().toString().split(/\s+/);
         var _loc3_:int = 0;
         var _loc4_:int = int(_loc2_.length);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = _loc2_[_loc3_];
            if(_loc5_.indexOf(",") != -1)
            {
               _loc5_ = _loc5_.replace(/,/,".");
            }
            _loc2_[_loc3_] = parseFloat(_loc5_);
            _loc3_++;
         }
         return _loc2_;
      }
      
      protected function parseIntsArray(param1:XML) : Array
      {
         var _loc5_:String = null;
         var _loc2_:Array = param1.text().toString().split(/\s+/);
         var _loc3_:int = 0;
         var _loc4_:int = int(_loc2_.length);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = _loc2_[_loc3_];
            _loc2_[_loc3_] = parseInt(_loc5_,10);
            _loc3_++;
         }
         return _loc2_;
      }
      
      protected function parseNumber(param1:XML) : Number
      {
         var _loc2_:String = param1.toString().replace(/,/,".");
         return parseFloat(_loc2_);
      }
      
      public function get id() : String
      {
         var _loc1_:XML = this.data.@id[0];
         return _loc1_ == null ? null : _loc1_.toString();
      }
      
      public function get sid() : String
      {
         var _loc1_:XML = this.data.@sid[0];
         return _loc1_ == null ? null : _loc1_.toString();
      }
      
      public function get name() : String
      {
         var _loc1_:XML = this.data.@name[0];
         return _loc1_ == null ? null : _loc1_.toString();
      }
   }
}

