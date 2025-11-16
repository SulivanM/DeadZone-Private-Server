package alternativa.engine3d.loaders.collada
{
   import alternativa.engine3d.loaders.ParserMaterial;
   
   use namespace collada;
   
   public class DaeMaterial extends DaeElement
   {
      
      public var material:ParserMaterial;
      
      public var mainTexCoords:String;
      
      public var used:Boolean = false;
      
      public function DaeMaterial(param1:XML, param2:DaeDocument)
      {
         super(param1,param2);
      }
      
      private function parseSetParams() : Object
      {
         var _loc3_:XML = null;
         var _loc4_:DaeParam = null;
         var _loc1_:Object = {};
         var _loc2_:XMLList = data.instance_effect.setparam;
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = new DaeParam(_loc3_,document);
            _loc1_[_loc4_.ref] = _loc4_;
         }
         return _loc1_;
      }
      
      private function get effectURL() : XML
      {
         return data.instance_effect.@url[0];
      }
      
      override protected function parseImplementation() : Boolean
      {
         var _loc1_:DaeEffect = document.findEffect(this.effectURL);
         if(_loc1_ != null)
         {
            _loc1_.parse();
            this.material = _loc1_.getMaterial(this.parseSetParams());
            this.mainTexCoords = _loc1_.mainTexCoords;
            if(this.material != null)
            {
               this.material.name = cloneString(name);
            }
            return true;
         }
         return false;
      }
   }
}

