package alternativa.engine3d.loaders.collada
{
   use namespace collada;
   
   public class DaeInput extends DaeElement
   {
      
      private var _offset:int = -1;
      
      public function DaeInput(param1:XML, param2:DaeDocument)
      {
         super(param1,param2);
      }
      
      public function get semantic() : String
      {
         var _loc1_:XML = data.@semantic[0];
         return _loc1_ == null ? null : _loc1_.toString();
      }
      
      public function get source() : XML
      {
         return data.@source[0];
      }
      
      public function get offset() : int
      {
         var _loc1_:XML = null;
         if(this._offset < 0)
         {
            _loc1_ = data.@offset[0];
            this._offset = _loc1_ == null ? 0 : int(parseInt(_loc1_.toString(),10));
         }
         return this._offset;
      }
      
      public function get setNum() : int
      {
         var _loc1_:XML = data.@set[0];
         return _loc1_ == null ? 0 : int(parseInt(_loc1_.toString(),10));
      }
      
      public function prepareSource(param1:int) : DaeSource
      {
         var _loc2_:DaeSource = document.findSource(this.source);
         if(_loc2_ != null)
         {
            _loc2_.parse();
            if(_loc2_.numbers != null && _loc2_.stride >= param1)
            {
               return _loc2_;
            }
         }
         else
         {
            document.logger.logNotFoundError(data.@source[0]);
         }
         return null;
      }
   }
}

