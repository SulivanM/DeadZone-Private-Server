package thelaststand.app.utils
{
   public class XMLUtils
   {
      
      public function XMLUtils()
      {
         super();
         throw new Error("XMLUtils cannot be directly instantiated.");
      }
      
      public static function sortXMLList(param1:XMLList, param2:Function) : XMLList
      {
         var _loc6_:XML = null;
         var _loc7_:XMLList = null;
         var _loc3_:int = 0;
         var _loc4_:int = int(param1.length());
         var _loc5_:Vector.<XML> = new Vector.<XML>(_loc4_,true);
         for each(_loc6_ in param1)
         {
            var _loc10_:*;
            _loc5_[_loc10_ = _loc3_++] = _loc6_;
         }
         _loc5_.sort(param2);
         _loc7_ = new XMLList();
         _loc3_ = 0;
         while(_loc3_ < _loc4_)
         {
            _loc7_ += _loc5_[_loc3_];
            _loc3_++;
         }
         return _loc7_;
      }
   }
}

