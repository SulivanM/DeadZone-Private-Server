package thelaststand.app.utils
{
   import flash.utils.Dictionary;
   
   public class DictionaryUtils
   {
      
      public static const MERGE_NUMERIC:uint = 1;
      
      public static const MERGE_NO_OVERWRITE:uint = 2;
      
      private static var _tmpKeys:Array = [];
      
      public function DictionaryUtils()
      {
         super();
         throw new Error("DictionaryUtils cannot be directly instantiated.");
      }
      
      public static function merge(param1:Dictionary, param2:Dictionary, param3:uint = 0) : Dictionary
      {
         var _loc4_:* = undefined;
         for(_loc4_ in param2)
         {
            if(_loc4_ in param1)
            {
               if(param3 & MERGE_NUMERIC)
               {
                  if(param2[_loc4_] is Number && param1[_loc4_] is Number)
                  {
                     param1[_loc4_] = Number(param1[_loc4_]) + Number(param2[_loc4_]);
                     continue;
                  }
               }
               if(param3 & MERGE_NO_OVERWRITE)
               {
                  continue;
               }
            }
            param1[_loc4_] = param2[_loc4_];
         }
         return param1;
      }
      
      public static function clone(param1:Dictionary, param2:Boolean = true) : Dictionary
      {
         var _loc4_:* = undefined;
         var _loc3_:Dictionary = new Dictionary(param2);
         for(_loc4_ in param1)
         {
            _loc3_[_loc4_] = param1;
         }
         return _loc3_;
      }
      
      public static function clear(param1:Dictionary) : void
      {
         var _loc2_:* = undefined;
         _tmpKeys.length = 0;
         for(_loc2_ in param1)
         {
            _tmpKeys.push(_loc2_);
         }
         for each(_loc2_ in _tmpKeys)
         {
            delete param1[_loc2_];
         }
      }
   }
}

