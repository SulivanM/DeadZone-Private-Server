package alternativa.engine3d.loaders.collada
{
   use namespace collada;
   
   public class DaeEffectParam extends DaeElement
   {
      
      private var effect:DaeEffect;
      
      public function DaeEffectParam(param1:XML, param2:DaeEffect)
      {
         super(param1,param2.document);
         this.effect = param2;
      }
      
      public function getFloat(param1:Object) : Number
      {
         var _loc4_:DaeParam = null;
         var _loc2_:XML = data.float[0];
         if(_loc2_ != null)
         {
            return parseNumber(_loc2_);
         }
         var _loc3_:XML = data.param.@ref[0];
         if(_loc3_ != null)
         {
            _loc4_ = this.effect.getParam(_loc3_.toString(),param1);
            if(_loc4_ != null)
            {
               return _loc4_.getFloat();
            }
         }
         return NaN;
      }
      
      public function getColor(param1:Object) : Array
      {
         var _loc4_:DaeParam = null;
         var _loc2_:XML = data.color[0];
         if(_loc2_ != null)
         {
            return parseNumbersArray(_loc2_);
         }
         var _loc3_:XML = data.param.@ref[0];
         if(_loc3_ != null)
         {
            _loc4_ = this.effect.getParam(_loc3_.toString(),param1);
            if(_loc4_ != null)
            {
               return _loc4_.getFloat4();
            }
         }
         return null;
      }
      
      private function get texture() : String
      {
         var _loc1_:XML = data.texture.@texture[0];
         return _loc1_ == null ? null : _loc1_.toString();
      }
      
      public function getSampler(param1:Object) : DaeParam
      {
         var _loc2_:String = this.texture;
         if(_loc2_ != null)
         {
            return this.effect.getParam(_loc2_,param1);
         }
         return null;
      }
      
      public function getImage(param1:Object) : DaeImage
      {
         var _loc3_:String = null;
         var _loc4_:DaeParam = null;
         var _loc2_:DaeParam = this.getSampler(param1);
         if(_loc2_ != null)
         {
            _loc3_ = _loc2_.surfaceSID;
            if(_loc3_ != null)
            {
               _loc4_ = this.effect.getParam(_loc3_,param1);
               if(_loc4_ != null)
               {
                  return _loc4_.image;
               }
               return null;
            }
            return _loc2_.image;
         }
         return document.findImageByID(this.texture);
      }
      
      public function get texCoord() : String
      {
         var _loc1_:XML = data.texture.@texcoord[0];
         return _loc1_ == null ? null : _loc1_.toString();
      }
   }
}

