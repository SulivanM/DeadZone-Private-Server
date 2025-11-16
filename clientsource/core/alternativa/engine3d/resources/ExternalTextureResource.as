package alternativa.engine3d.resources
{
   import alternativa.engine3d.alternativa3d;
   import flash.display3D.Context3D;
   import flash.display3D.textures.TextureBase;
   
   use namespace alternativa3d;
   
   public class ExternalTextureResource extends TextureResource
   {
      
      public var url:String;
      
      public function ExternalTextureResource(param1:String)
      {
         super();
         this.url = param1;
      }
      
      override public function upload(param1:Context3D) : void
      {
      }
      
      public function get data() : TextureBase
      {
         return alternativa3d::_texture;
      }
      
      public function set data(param1:TextureBase) : void
      {
         alternativa3d::_texture = param1;
      }
   }
}

