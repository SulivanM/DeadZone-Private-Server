package alternativa.engine3d.loaders.collada
{
   use namespace collada;
   
   public class DaeImage extends DaeElement
   {
      
      public function DaeImage(param1:XML, param2:DaeDocument)
      {
         super(param1,param2);
      }
      
      public function get init_from() : String
      {
         var _loc2_:XML = null;
         var _loc1_:XML = data.init_from[0];
         if(_loc1_ != null)
         {
            if(document.versionMajor > 4)
            {
               _loc2_ = _loc1_.ref[0];
               return _loc2_ == null ? null : _loc2_.text().toString();
            }
            return _loc1_.text().toString();
         }
         return null;
      }
   }
}

