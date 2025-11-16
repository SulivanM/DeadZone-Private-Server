package alternativa.engine3d.loaders.collada
{
   use namespace collada;
   
   public class DaeParam extends DaeElement
   {
      
      public function DaeParam(param1:XML, param2:DaeDocument)
      {
         super(param1,param2);
      }
      
      public function get ref() : String
      {
         var _loc1_:XML = data.@ref[0];
         return _loc1_ == null ? null : _loc1_.toString();
      }
      
      public function getFloat() : Number
      {
         var _loc1_:XML = data.float[0];
         if(_loc1_ != null)
         {
            return parseNumber(_loc1_);
         }
         return NaN;
      }
      
      public function getFloat4() : Array
      {
         var _loc2_:Array = null;
         var _loc1_:XML = data.float4[0];
         if(_loc1_ == null)
         {
            _loc1_ = data.float3[0];
            if(_loc1_ != null)
            {
               _loc2_ = parseNumbersArray(_loc1_);
               _loc2_[3] = 1;
            }
         }
         else
         {
            _loc2_ = parseNumbersArray(_loc1_);
         }
         return _loc2_;
      }
      
      public function get surfaceSID() : String
      {
         var _loc1_:XML = data.sampler2D.source[0];
         return _loc1_ == null ? null : _loc1_.text().toString();
      }
      
      public function get wrap_s() : String
      {
         var _loc1_:XML = data.sampler2D.wrap_s[0];
         return _loc1_ == null ? null : _loc1_.text().toString();
      }
      
      public function get image() : DaeImage
      {
         var _loc2_:DaeImage = null;
         var _loc3_:XML = null;
         var _loc4_:XML = null;
         var _loc1_:XML = data.surface[0];
         if(_loc1_ != null)
         {
            _loc3_ = _loc1_.init_from[0];
            if(_loc3_ == null)
            {
               return null;
            }
            _loc2_ = document.findImageByID(_loc3_.text().toString());
         }
         else
         {
            _loc4_ = data.instance_image.@url[0];
            if(_loc4_ == null)
            {
               return null;
            }
            _loc2_ = document.findImage(_loc4_);
         }
         return _loc2_;
      }
   }
}

