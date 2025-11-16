package thelaststand.app.utils
{
   import com.adobe.images.JPGEncoder;
   import com.adobe.images.PNGEncoder;
   import com.dynamicflash.util.Base64;
   import com.greensock.TweenMax;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import thelaststand.app.core.Config;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemQualityType;
   import thelaststand.app.game.gui.UIItemImage;
   
   public class ImageWriter
   {
      
      private static var jpeg:JPGEncoder = new JPGEncoder(100);
      
      public function ImageWriter()
      {
         super();
      }
      
      public static function saveItem(param1:Item, param2:Function = null) : void
      {
         var img:UIItemImage = null;
         var item:Item = param1;
         var onComplete:Function = param2;
         img = new UIItemImage(64,64,2);
         img.imageDisplayed.addOnce(function(param1:UIItemImage):void
         {
            TweenMax.killTweensOf(img,true);
            TweenMax.killChildTweensOf(img,true);
            var _loc2_:Rectangle = img.getBounds(img);
            var _loc3_:BitmapData = new BitmapData(90,90,false,16777215);
            var _loc4_:int = (_loc3_.width - _loc2_.width) * 0.5 - _loc2_.x;
            var _loc5_:int = (_loc3_.height - _loc2_.height) * 0.5 - _loc2_.y;
            _loc3_.fillRect(new Rectangle(_loc4_ - 4,_loc5_ - 4,_loc2_.width + 4,_loc2_.height + 4),0);
            _loc3_.draw(img,new Matrix(1,0,0,1,_loc4_,_loc5_));
            var _loc6_:String = item.getImageURI().toLowerCase();
            var _loc7_:String = ItemQualityType.getName(item.qualityType).toLowerCase();
            _loc6_ = _loc6_.substr(_loc6_.lastIndexOf("/") + 1);
            _loc6_ = _loc6_.substr(0,_loc6_.lastIndexOf("."));
            var _loc8_:String = _loc7_ + "-" + _loc6_;
            saveImage(_loc8_,_loc3_,onComplete);
         });
         img.item = item;
      }
      
      public static function saveImage(param1:String, param2:BitmapData, param3:Function = null) : void
      {
         var ext:String;
         var script:String;
         var request:URLRequest;
         var loader:URLLoader = null;
         var name:String = param1;
         var bmd:BitmapData = param2;
         var onComplete:Function = param3;
         var vars:URLVariables = new URLVariables();
         vars.f = name;
         ext = name.substr(name.lastIndexOf(".")).toLowerCase();
         switch(ext)
         {
            case ".png":
               vars.d = Base64.encodeByteArray(PNGEncoder.encode(bmd));
               break;
            default:
               vars.d = Base64.encodeByteArray(jpeg.encode(bmd));
         }
         script = Config.getPath("saveimage_url");
         request = new URLRequest(script);
         request.method = URLRequestMethod.POST;
         request.data = vars;
         loader = new URLLoader();
         loader.addEventListener(Event.COMPLETE,function(param1:Event):void
         {
            loader.removeEventListener(Event.COMPLETE,arguments.callee);
            var _loc3_:XML = XML(loader.data);
            var _loc4_:String = _loc3_.img.@uri.toString();
            onComplete(_loc4_);
         });
         loader.addEventListener(IOErrorEvent.IO_ERROR,function(param1:IOErrorEvent):void
         {
            loader.removeEventListener(IOErrorEvent.IO_ERROR,arguments.callee);
            onComplete(null);
         });
         loader.load(request);
      }
   }
}

