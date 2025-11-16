package alternativa.engine3d.resources
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Resource;
   import flash.display3D.textures.TextureBase;
   
   use namespace alternativa3d;
   
   public class TextureResource extends Resource
   {
      
      alternativa3d var _texture:TextureBase;
      
      public function TextureResource()
      {
         super();
      }
      
      override public function get isUploaded() : Boolean
      {
         return this.alternativa3d::_texture != null;
      }
      
      override public function dispose() : void
      {
         _disposed = true;
         if(this.alternativa3d::_texture != null)
         {
            this.alternativa3d::_texture.dispose();
            this.alternativa3d::_texture = null;
         }
      }
   }
}

