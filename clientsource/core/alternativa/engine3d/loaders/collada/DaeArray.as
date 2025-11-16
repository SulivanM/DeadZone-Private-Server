package alternativa.engine3d.loaders.collada
{
   use namespace collada;
   
   public class DaeArray extends DaeElement
   {
      
      public var array:Array;
      
      public function DaeArray(param1:XML, param2:DaeDocument)
      {
         super(param1,param2);
      }
      
      public function get type() : String
      {
         return String(data.localName());
      }
      
      override protected function parseImplementation() : Boolean
      {
         var _loc2_:int = 0;
         this.array = parseStringArray(data);
         var _loc1_:XML = data.@count[0];
         if(_loc1_ != null)
         {
            _loc2_ = parseInt(_loc1_.toString(),10);
            if(this.array.length < _loc2_)
            {
               document.logger.logNotEnoughDataError(data.@count[0]);
               return false;
            }
            this.array.length = _loc2_;
            return true;
         }
         return false;
      }
   }
}

