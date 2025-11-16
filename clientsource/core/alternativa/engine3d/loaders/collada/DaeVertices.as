package alternativa.engine3d.loaders.collada
{
   import alternativa.engine3d.alternativa3d;
   
   use namespace alternativa3d;
   use namespace collada;
   
   public class DaeVertices extends DaeElement
   {
      
      public var positions:DaeSource;
      
      public function DaeVertices(param1:XML, param2:DaeDocument)
      {
         super(param1,param2);
      }
      
      override protected function parseImplementation() : Boolean
      {
         var inputXML:XML = null;
         inputXML = data.input.(@semantic == "POSITION")[0];
         if(inputXML != null)
         {
            this.positions = new DaeInput(inputXML,document).prepareSource(3);
            if(this.positions != null)
            {
               return true;
            }
         }
         return false;
      }
   }
}

