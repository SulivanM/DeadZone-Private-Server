package alternativa.engine3d.effects
{
   import alternativa.engine3d.resources.TextureResource;
   
   public class TextureAtlas
   {
      
      public var diffuse:TextureResource;
      
      public var opacity:TextureResource;
      
      public var columnsCount:int;
      
      public var rowsCount:int;
      
      public var rangeBegin:int;
      
      public var rangeLength:int;
      
      public var fps:int;
      
      public var loop:Boolean;
      
      public var originX:Number;
      
      public var originY:Number;
      
      public function TextureAtlas(param1:TextureResource, param2:TextureResource = null, param3:int = 1, param4:int = 1, param5:int = 0, param6:int = 1, param7:int = 30, param8:Boolean = false, param9:Number = 0.5, param10:Number = 0.5)
      {
         super();
         this.diffuse = param1;
         this.opacity = param2;
         this.columnsCount = param3;
         this.rowsCount = param4;
         this.rangeBegin = param5;
         this.rangeLength = param6;
         this.fps = param7;
         this.loop = param8;
         this.originX = param9;
         this.originY = param10;
      }
   }
}

