package thelaststand.app.game.gui.alliance.banner
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.BlendMode;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.utils.ByteArray;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.alliance.AllianceBannerData;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   
   public class AllianceBannerDisplay extends Sprite
   {
      
      private static var _instance:AllianceBannerDisplay;
      
      private static const RESOURCE_URI:String = "swf/alliance_banner.swf";
      
      private var _paletteClass:Class;
      
      private var _colors:Vector.<uint>;
      
      private var _ready:Boolean = false;
      
      private var _locked:Boolean = false;
      
      private var _loader:Loader;
      
      private var _base:Sprite;
      
      private var _decal1:MovieClip;
      
      private var _decal1Overlay:MovieClip;
      
      private var _decal2:MovieClip;
      
      private var _decal2Overlay:MovieClip;
      
      private var _decal3:MovieClip;
      
      private var _decal3Overlay:MovieClip;
      
      private var _maskedContainer:Sprite;
      
      private var _spinner:UIBusySpinner;
      
      private var _bannerResourceMC:MovieClip;
      
      private var _bannerMC:Sprite;
      
      private var _bannerData:AllianceBannerData;
      
      private var _randomiseWhenReady:Boolean = false;
      
      public var onReady:Signal;
      
      public function AllianceBannerDisplay()
      {
         var temp:Bitmap;
         var bd:BitmapData;
         var r:int;
         var rm:ResourceManager;
         var c:int = 0;
         this._paletteClass = AllianceBannerDisplay__paletteClass;
         super();
         this._bannerData = new AllianceBannerData();
         this._bannerData.onChange.add(this.applyCurrentSettings);
         this.onReady = new Signal();
         this._colors = new Vector.<uint>();
         temp = new this._paletteClass();
         bd = temp.bitmapData;
         r = 0;
         while(r < bd.height)
         {
            c = 0;
            while(c < bd.width)
            {
               this._colors.push(bd.getPixel(c,r));
               c++;
            }
            r++;
         }
         this._spinner = new UIBusySpinner();
         this._spinner.x = 91;
         this._spinner.y = 102;
         addChild(this._spinner);
         rm = ResourceManager.getInstance();
         if(rm.exists(RESOURCE_URI))
         {
            if(rm.getResource(RESOURCE_URI).loading)
            {
               rm.resourceLoadCompleted.add(function(param1:Resource):void
               {
                  if(param1.uri == RESOURCE_URI)
                  {
                     mainAssetReady();
                  }
               });
            }
            else
            {
               this.mainAssetReady();
            }
         }
         else
         {
            rm.load(RESOURCE_URI,{"onComplete":this.mainAssetReady});
         }
      }
      
      public static function getInstance() : AllianceBannerDisplay
      {
         if(!_instance)
         {
            _instance = new AllianceBannerDisplay();
         }
         return _instance;
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.onReady.removeAll();
         this.onReady = null;
         this._colors = null;
         this._spinner.dispose();
         if(this._bannerData)
         {
            this._bannerData.onChange.remove(this.applyCurrentSettings);
            this._bannerData = null;
         }
         if(this._ready)
         {
            if(this._bannerMC.parent)
            {
               this._bannerMC.parent.removeChild(this._bannerMC);
            }
            this._base = null;
            this._decal1 = null;
            this._decal1Overlay = null;
            this._decal2 = null;
            this._decal2Overlay = null;
            this._decal3 = null;
            this._decal3Overlay = null;
         }
         TweenMax.killChildTweensOf(this);
      }
      
      public function clear() : void
      {
         this.hexString = "0x00";
         this.baseColor = 11;
      }
      
      public function randomise() : void
      {
         this._randomiseWhenReady = true;
         if(this._ready == false)
         {
            return;
         }
         this._locked = true;
         this._bannerData.setProp(AllianceBannerData.BASE_COLOR,Math.floor(Math.random() * this._colors.length));
         this._bannerData.setProp(AllianceBannerData.DECAL_1,this.selectRandomMCFrame(this._decal1));
         this._bannerData.setProp(AllianceBannerData.DECAL_1_COLOR,Math.floor(Math.random() * this._colors.length));
         this._bannerData.setProp(AllianceBannerData.DECAL_2,this.selectRandomMCFrame(this._decal2));
         this._bannerData.setProp(AllianceBannerData.DECAL_2_COLOR,Math.floor(Math.random() * this._colors.length));
         this._bannerData.setProp(AllianceBannerData.DECAL_3,this.selectRandomMCFrame(this._decal3));
         this._bannerData.setProp(AllianceBannerData.DECAL_3_COLOR,Math.floor(Math.random() * this._colors.length));
         this._locked = false;
         this.applyCurrentSettings();
      }
      
      public function generateBitmap(param1:Number = -1) : BitmapData
      {
         if(!this._bannerMC)
         {
            return null;
         }
         var _loc2_:DisplayObject = this._bannerMC.getChildByName("exportRect");
         var _loc3_:Number = 1;
         if(param1 > 0)
         {
            _loc3_ = param1 / _loc2_.height;
         }
         var _loc4_:BitmapData = new BitmapData(_loc2_.width * _loc3_,_loc2_.height * _loc3_,true,0);
         var _loc5_:Matrix = new Matrix();
         _loc5_.translate(-_loc2_.x,-_loc2_.y);
         _loc5_.scale(_loc3_,_loc3_);
         _loc4_.draw(this._bannerMC,_loc5_,null,null,null,true);
         return _loc4_;
      }
      
      public function generateBannerTexture() : BitmapData
      {
         if(!this._bannerMC)
         {
            return null;
         }
         var _loc1_:DisplayObject = this._bannerMC.getChildByName("background");
         _loc1_.visible = false;
         var _loc2_:DisplayObject = this._bannerMC.getChildByName("materialRect");
         var _loc3_:Number = 64 / _loc2_.width;
         var _loc4_:BitmapData = new BitmapData(64,64,false,this._colors[this.capColorIndex(this.baseColor)]);
         var _loc5_:Matrix = new Matrix();
         _loc5_.translate(-_loc2_.x,-_loc2_.y);
         _loc5_.scale(_loc3_,_loc3_);
         _loc4_.draw(this._bannerMC,_loc5_,null,null,null,true);
         _loc1_.visible = true;
         return _loc4_;
      }
      
      public function generateButtonIconTexture() : BitmapData
      {
         if(!this._bannerMC)
         {
            return null;
         }
         var _loc1_:DisplayObject = this._bannerMC.getChildByName("background");
         _loc1_.visible = false;
         var _loc2_:DisplayObject = this._bannerMC.getChildByName("iconRect");
         var _loc3_:Number = 52 / _loc2_.width;
         var _loc4_:BitmapData = new BitmapData(52,Math.round(_loc2_.height * _loc3_),false,this._colors[this.capColorIndex(this.baseColor)]);
         var _loc5_:Matrix = new Matrix();
         _loc5_.translate(-_loc2_.x,-_loc2_.y);
         _loc5_.scale(_loc3_,_loc3_);
         _loc4_.draw(this._bannerMC,_loc5_,null,null,null,true);
         _loc1_.visible = true;
         return _loc4_;
      }
      
      public function generateThumbnail() : BitmapData
      {
         if(!this._bannerMC)
         {
            return null;
         }
         var _loc1_:DisplayObject = this._bannerMC.getChildByName("overlay");
         var _loc2_:DisplayObject = this._bannerMC.getChildByName("background");
         _loc1_.visible = _loc2_.visible = false;
         var _loc3_:DisplayObject = this._bannerMC.getChildByName("thumbRect");
         var _loc4_:Number = 50 / _loc3_.width;
         var _loc5_:BitmapData = new BitmapData(50,50,false,2236962);
         var _loc6_:Matrix = new Matrix();
         _loc6_.translate(-_loc3_.x,-_loc3_.y);
         _loc6_.scale(_loc4_,_loc4_);
         _loc5_.draw(this._bannerMC,_loc6_,null,null,null,true);
         _loc1_.visible = _loc2_.visible = true;
         return _loc5_;
      }
      
      public function generateChatThumbnail() : BitmapData
      {
         if(!this._bannerMC)
         {
            return null;
         }
         var _loc1_:DisplayObject = this._bannerMC.getChildByName("chatRect");
         var _loc2_:Number = 36 / _loc1_.width;
         var _loc3_:BitmapData = new BitmapData(36,39,true,0);
         var _loc4_:Matrix = new Matrix();
         _loc4_.translate(-_loc1_.x,-_loc1_.y);
         _loc4_.scale(_loc2_,_loc2_);
         _loc3_.draw(this._bannerMC,_loc4_,null,null,null,true);
         return _loc3_;
      }
      
      private function mainAssetReady() : void
      {
         this._bannerResourceMC = MovieClip(ResourceManager.getInstance().getResource(RESOURCE_URI).content);
         var _loc1_:Class = this._bannerResourceMC.loaderInfo.applicationDomain.getDefinition("AllianceBanner") as Class;
         if(this._spinner.parent)
         {
            this._spinner.parent.removeChild(this._spinner);
         }
         this._bannerMC = new _loc1_();
         addChild(this._bannerMC);
         TweenMax.from(this._bannerMC,0.2,{"alpha":0});
         var _loc2_:DisplayObject = this._bannerMC.getChildByName("bannerMask");
         this._maskedContainer = new Sprite();
         this._bannerMC.addChildAt(this._maskedContainer,this._bannerMC.getChildIndex(_loc2_));
         this._maskedContainer.mask = _loc2_;
         this._base = this._bannerMC.getChildByName("bannerFill") as Sprite;
         this._decal1 = this._bannerMC.getChildByName("decal1") as MovieClip;
         this._decal1.stop();
         this._maskedContainer.addChild(this._decal1);
         this._decal2 = this._bannerMC.getChildByName("decal2") as MovieClip;
         this._decal2.stop();
         this._maskedContainer.addChild(this._decal2);
         this._decal3 = this._bannerMC.getChildByName("decal3") as MovieClip;
         this._decal3.stop();
         this._maskedContainer.addChild(this._decal3);
         this._decal1Overlay = this.generateOverlay(this._decal1);
         this._decal2Overlay = this.generateOverlay(this._decal2);
         this._decal3Overlay = this.generateOverlay(this._decal3);
         this._ready = true;
         if(this._randomiseWhenReady == true)
         {
            this.randomise();
         }
         else
         {
            this.applyCurrentSettings();
         }
         this.onReady.dispatch();
      }
      
      private function generateOverlay(param1:MovieClip) : MovieClip
      {
         var _loc2_:Class = getDefinitionByName(getQualifiedClassName(param1)) as Class;
         var _loc3_:MovieClip = new _loc2_() as MovieClip;
         _loc3_.stop();
         param1.parent.addChildAt(_loc3_,param1.parent.getChildIndex(param1) + 1);
         _loc3_.x = param1.x;
         _loc3_.y = param1.y;
         _loc3_.blendMode = BlendMode.OVERLAY;
         return _loc3_;
      }
      
      private function applyCurrentSettings() : void
      {
         if(!this._ready || this._locked)
         {
            return;
         }
         var _loc1_:Function = this._bannerData.getProp;
         this.applyColorIndexToObject(_loc1_(AllianceBannerData.BASE_COLOR),this._base);
         this._decal1.gotoAndStop(_loc1_(AllianceBannerData.DECAL_1));
         this._decal1Overlay.gotoAndStop(_loc1_(AllianceBannerData.DECAL_1));
         this.applyColorIndexToObject(_loc1_(AllianceBannerData.DECAL_1_COLOR),this._decal1Overlay);
         this._decal2.gotoAndStop(_loc1_(AllianceBannerData.DECAL_2));
         this._decal2Overlay.gotoAndStop(_loc1_(AllianceBannerData.DECAL_2));
         this.applyColorIndexToObject(_loc1_(AllianceBannerData.DECAL_2_COLOR),this._decal2Overlay);
         this._decal3.gotoAndStop(_loc1_(AllianceBannerData.DECAL_3));
         this._decal3Overlay.gotoAndStop(_loc1_(AllianceBannerData.DECAL_3));
         this.applyColorIndexToObject(_loc1_(AllianceBannerData.DECAL_3_COLOR),this._decal3Overlay);
      }
      
      private function applyColorIndexToObject(param1:int, param2:DisplayObject) : void
      {
         if(param2 == null)
         {
            return;
         }
         param1 = this.capColorIndex(param1);
         var _loc3_:ColorTransform = param2.transform.colorTransform;
         _loc3_.color = this._colors[param1];
         param2.transform.colorTransform = _loc3_;
      }
      
      private function selectRandomMCFrame(param1:MovieClip) : int
      {
         var _loc2_:int = 1;
         do
         {
            _loc2_ = Math.floor(Math.random() * param1.totalFrames) + 1;
            param1.gotoAndStop(_loc2_);
         }
         while(!(param1.width > 0 && param1.height > 0));
         
         return _loc2_;
      }
      
      private function findNextValidFrame(param1:MovieClip, param2:int, param3:Boolean = true) : int
      {
         var _loc4_:int = param2;
         if(_loc4_ > param1.totalFrames)
         {
            _loc4_ = 1;
         }
         else if(_loc4_ < 1)
         {
            _loc4_ = param1.totalFrames;
         }
         while(true)
         {
            param1.gotoAndStop(_loc4_);
            if(param1.width > 0 && param1.height > 0)
            {
               break;
            }
            _loc4_ += param3 ? -1 : 1;
            if(_loc4_ > param1.totalFrames)
            {
               _loc4_ = 1;
            }
            else if(_loc4_ < 1)
            {
               _loc4_ = param1.totalFrames;
            }
         }
         return _loc4_;
      }
      
      private function capColorIndex(param1:int) : int
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         if(param1 > this._colors.length - 1)
         {
            param1 = int(this._colors.length - 1);
         }
         return param1;
      }
      
      public function get ready() : Boolean
      {
         return this._ready;
      }
      
      public function get bannerResourceMC() : MovieClip
      {
         return this._bannerResourceMC;
      }
      
      public function get bannerData() : AllianceBannerData
      {
         return this._bannerData;
      }
      
      public function get byteArray() : ByteArray
      {
         return this._bannerData.byteArray;
      }
      
      public function set byteArray(param1:ByteArray) : void
      {
         this._bannerData.byteArray = param1;
      }
      
      public function get hexString() : String
      {
         return this._bannerData.hexString;
      }
      
      public function set hexString(param1:String) : void
      {
         this._bannerData.hexString = param1;
      }
      
      public function get baseColor() : int
      {
         return this._bannerData.getProp(AllianceBannerData.BASE_COLOR);
      }
      
      public function set baseColor(param1:int) : void
      {
         this._locked = true;
         var _loc2_:int = this.capColorIndex(param1);
         this._bannerData.setProp(AllianceBannerData.BASE_COLOR,_loc2_);
         this.applyColorIndexToObject(_loc2_,this._base);
         this._locked = false;
      }
      
      public function get decal1() : int
      {
         return this._bannerData.getProp(AllianceBannerData.DECAL_1);
      }
      
      public function set decal1(param1:int) : void
      {
         if(!this._ready)
         {
            return;
         }
         this._locked = true;
         this._bannerData.setProp(AllianceBannerData.DECAL_1,this.findNextValidFrame(this._decal1,param1,param1 > this.decal1));
         this._decal1Overlay.gotoAndStop(this._decal1.currentFrame);
         this._locked = false;
      }
      
      public function get decal1Color() : int
      {
         return this._bannerData.getProp(AllianceBannerData.DECAL_1_COLOR);
      }
      
      public function set decal1Color(param1:int) : void
      {
         this._locked = true;
         var _loc2_:int = this.capColorIndex(param1);
         this._bannerData.setProp(AllianceBannerData.DECAL_1_COLOR,_loc2_);
         this.applyColorIndexToObject(_loc2_,this._decal1Overlay);
         this._locked = false;
      }
      
      public function get decal2() : int
      {
         return this._bannerData.getProp(AllianceBannerData.DECAL_2);
      }
      
      public function set decal2(param1:int) : void
      {
         if(!this._ready)
         {
            return;
         }
         this._locked = true;
         this._bannerData.setProp(AllianceBannerData.DECAL_2,this.findNextValidFrame(this._decal2,param1,param1 > this.decal2));
         this._decal2Overlay.gotoAndStop(this._decal2.currentFrame);
         this._locked = false;
      }
      
      public function get decal2Color() : int
      {
         return this._bannerData.getProp(AllianceBannerData.DECAL_2_COLOR);
      }
      
      public function set decal2Color(param1:int) : void
      {
         this._locked = true;
         var _loc2_:int = this.capColorIndex(param1);
         this._bannerData.setProp(AllianceBannerData.DECAL_2_COLOR,_loc2_);
         this.applyColorIndexToObject(_loc2_,this._decal2Overlay);
         this._locked = false;
      }
      
      public function get decal3() : int
      {
         return this._bannerData.getProp(AllianceBannerData.DECAL_3);
      }
      
      public function set decal3(param1:int) : void
      {
         if(!this._ready)
         {
            return;
         }
         this._locked = true;
         this._bannerData.setProp(AllianceBannerData.DECAL_3,this.findNextValidFrame(this._decal3,param1,param1 > this.decal3));
         this._decal3Overlay.gotoAndStop(this._decal3.currentFrame);
         this._locked = false;
      }
      
      public function get decal3Color() : int
      {
         return this._bannerData.getProp(AllianceBannerData.DECAL_3_COLOR);
      }
      
      public function set decal3Color(param1:int) : void
      {
         this._locked = true;
         var _loc2_:int = this.capColorIndex(param1);
         this._bannerData.setProp(AllianceBannerData.DECAL_3_COLOR,_loc2_);
         this.applyColorIndexToObject(_loc2_,this._decal3Overlay);
         this._locked = false;
      }
   }
}

