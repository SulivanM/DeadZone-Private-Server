package alternativa.engine3d.loaders.collada
{
   use namespace collada;
   
   public class DaeInstanceMaterial extends DaeElement
   {
      
      public function DaeInstanceMaterial(param1:XML, param2:DaeDocument)
      {
         super(param1,param2);
      }
      
      public function get symbol() : String
      {
         var _loc1_:XML = data.@symbol[0];
         return _loc1_ == null ? null : _loc1_.toString();
      }
      
      private function get target() : XML
      {
         return data.@target[0];
      }
      
      public function get material() : DaeMaterial
      {
         var _loc1_:DaeMaterial = document.findMaterial(this.target);
         if(_loc1_ == null)
         {
            document.logger.logNotFoundError(this.target);
         }
         return _loc1_;
      }
      
      public function getBindVertexInputSetNum(param1:String) : int
      {
         var bindVertexInputXML:XML = null;
         var setNumXML:XML = null;
         var semantic:String = param1;
         bindVertexInputXML = data.bind_vertex_input.(@semantic == semantic)[0];
         if(bindVertexInputXML == null)
         {
            return 0;
         }
         setNumXML = bindVertexInputXML.@input_set[0];
         return setNumXML == null ? 0 : int(parseInt(setNumXML.toString(),10));
      }
   }
}

