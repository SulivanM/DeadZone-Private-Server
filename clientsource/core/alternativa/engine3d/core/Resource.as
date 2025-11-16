package alternativa.engine3d.core
{
   import flash.display3D.Context3D;
   
   public class Resource
   {
      
      protected var _disposed:Boolean;
      
      public function Resource()
      {
         super();
      }
      
      public function get isDisposed() : Boolean
      {
         return this._disposed;
      }
      
      public function get isUploaded() : Boolean
      {
         return false;
      }
      
      public function upload(param1:Context3D) : void
      {
         throw new Error("Cannot upload without data");
      }
      
      public function dispose() : void
      {
         this._disposed = true;
      }
   }
}

