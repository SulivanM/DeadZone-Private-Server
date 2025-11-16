package thelaststand.engine.utils
{
   import com.quasimondo.geom.ColorMatrix;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import thelaststand.app.game.data.AttireData;
   import thelaststand.common.resources.ResourceManager;
   
   public class TextureBuilder
   {
      
      private static var _nextId:int = 0;
      
      private static const POINT_ZERO:Point = new Point();
      
      public function TextureBuilder()
      {
         super();
         throw new Error("TextureBuilder cannot be directly instantiated.");
      }
      
      public static function buildTexture(param1:AttireData, param2:Array = null) : String
      {
         var i:int = 0;
         var len:int = 0;
         var matrixFilter:ColorMatrix = null;
         var sourceBmd:BitmapData = null;
         var targetBmd:BitmapData = null;
         var attireData:AttireData = param1;
         var overlayList:Array = param2;
         var resources:ResourceManager = ResourceManager.getInstance();
         var uri:String = "";
         if(attireData.uniqueTexture)
         {
            uri = "_texture" + _nextId++;
         }
         else
         {
            if(attireData.texture != null)
            {
               uri += attireData.texture;
            }
            if(!isNaN(attireData.hue))
            {
               uri += "|" + attireData.hue;
            }
            if(!isNaN(attireData.brightness))
            {
               uri += "|" + attireData.brightness;
            }
            if(!isNaN(attireData.tint))
            {
               uri += "|" + attireData.tint;
            }
            if(overlayList != null)
            {
               i = 0;
               len = int(overlayList.length);
               while(i < len)
               {
                  uri += "|" + overlayList[i];
                  i++;
               }
            }
         }
         if(attireData.uniqueTexture || resources.materials.getBitmapTextureResource(uri) == null)
         {
            attireData.modifiedTexture = attireData.uniqueTexture && attireData.texture != null || overlayList != null && overlayList.length > 0;
            if(!isNaN(attireData.hue))
            {
               if(matrixFilter == null)
               {
                  matrixFilter = new ColorMatrix();
               }
               matrixFilter.adjustHue(attireData.hue);
               attireData.modifiedTexture = true;
            }
            if(!isNaN(attireData.brightness))
            {
               if(matrixFilter == null)
               {
                  matrixFilter = new ColorMatrix();
               }
               matrixFilter.adjustBrightness(attireData.brightness * 128);
               matrixFilter.adjustSaturation(1 + attireData.brightness);
               attireData.modifiedTexture = true;
            }
            if(!isNaN(attireData.tint))
            {
               if(matrixFilter == null)
               {
                  matrixFilter = new ColorMatrix();
               }
               matrixFilter.colorize(attireData.tint,1);
               attireData.modifiedTexture = true;
            }
            if(attireData.modifiedTexture)
            {
               try
               {
                  sourceBmd = BitmapData(resources.getResource(attireData.texture).content);
                  targetBmd = sourceBmd.clone();
                  if(matrixFilter != null)
                  {
                     targetBmd.applyFilter(targetBmd,targetBmd.rect,POINT_ZERO,matrixFilter.filter);
                  }
                  if(overlayList != null)
                  {
                     i = 0;
                     len = int(overlayList.length);
                     while(i < len)
                     {
                        sourceBmd = resources.getResource(overlayList[i]).content as BitmapData;
                        targetBmd.copyPixels(sourceBmd,sourceBmd.rect,POINT_ZERO,sourceBmd,POINT_ZERO,true);
                        i++;
                     }
                  }
                  resources.addResource(targetBmd,uri,"img");
                  attireData.modifiedTextureURI = uri.toLowerCase();
               }
               catch(e:Error)
               {
                  attireData.modifiedTexture = false;
                  attireData.modifiedTextureURI = null;
                  return attireData.texture.toLowerCase();
               }
            }
            else
            {
               uri = attireData.texture;
            }
         }
         return uri;
      }
   }
}

