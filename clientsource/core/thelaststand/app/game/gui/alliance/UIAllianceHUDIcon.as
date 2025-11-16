package thelaststand.app.game.gui.alliance
{
   import com.quasimondo.geom.ColorMatrix;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import thelaststand.app.game.data.alliance.AllianceData;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.alliance.banner.AllianceBannerDisplay;
   import thelaststand.app.gui.UIBusySpinner;
   
   public class UIAllianceHUDIcon extends AllianceBannerIconBase
   {
      
      private static var BITMAP_DATA:BitmapData = null;
      
      private static var BITMAP_DATA_ID:String = "";
      
      private var _alliance:AllianceData;
      
      private var _bmp:Bitmap;
      
      private var _busy:Boolean = false;
      
      private var _busySpinner:UIBusySpinner;
      
      public function UIAllianceHUDIcon()
      {
         super();
         mouseChildren = false;
         this._bmp = new Bitmap(BITMAP_DATA,"auto",true);
         this._bmp.x = 4;
         this._bmp.y = 1;
         this._bmp.visible = false;
         addChild(this._bmp);
         this._bmp.mask = mc_mask;
         AllianceSystem.getInstance().connectionAttempted.add(this.onAllianceConnectionAttempted);
         AllianceSystem.getInstance().connectionFailed.add(this.onAllianceConnectionFailed);
         AllianceSystem.getInstance().connected.add(this.onAllianceConnected);
         AllianceSystem.getInstance().disconnected.add(this.onAllianceDisconnected);
         if(AllianceSystem.getInstance().alliance != null)
         {
            this.onAllianceConnected();
         }
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         AllianceSystem.getInstance().connectionAttempted.remove(this.onAllianceConnectionAttempted);
         AllianceSystem.getInstance().connectionFailed.remove(this.onAllianceConnectionFailed);
         AllianceSystem.getInstance().connected.remove(this.onAllianceConnected);
         AllianceSystem.getInstance().disconnected.remove(this.onAllianceDisconnected);
         if(this._alliance != null)
         {
            this._alliance.banner.onChange.remove(this.onAllianceBannerChanged);
            this._alliance = null;
         }
         this._bmp.bitmapData = null;
         if(this._busySpinner)
         {
            this._busySpinner.dispose();
         }
         this._busySpinner = null;
      }
      
      private function onAllianceConnected() : void
      {
         this._alliance = AllianceSystem.getInstance().alliance;
         this._alliance.banner.onChange.add(this.onAllianceBannerChanged);
         this.onAllianceBannerChanged();
         this.showBusySpinner(false);
      }
      
      private function onAllianceDisconnected() : void
      {
         var _loc1_:AllianceBannerDisplay = null;
         if(this._alliance != null)
         {
            _loc1_ = AllianceBannerDisplay.getInstance();
            _loc1_.onReady.remove(this.onAllianceBannerChanged);
            this._alliance.banner.onChange.remove(this.onAllianceBannerChanged);
            this._alliance = null;
         }
         this._bmp.visible = false;
         this.showBusySpinner(false);
      }
      
      private function onAllianceConnectionAttempted() : void
      {
         this.showBusySpinner(true);
      }
      
      private function onAllianceConnectionFailed() : void
      {
         this.showBusySpinner(false);
      }
      
      private function onAllianceBannerChanged() : void
      {
         this._alliance = AllianceSystem.getInstance().alliance;
         if(!AllianceSystem.getInstance().inAlliance || this._alliance == null || this._alliance.banner == null)
         {
            this._bmp.visible = false;
            return;
         }
         var _loc1_:AllianceBannerDisplay = AllianceBannerDisplay.getInstance();
         _loc1_.onReady.remove(this.onAllianceBannerChanged);
         if(_loc1_.ready == false)
         {
            _loc1_.onReady.add(this.onAllianceBannerChanged);
            return;
         }
         _loc1_.byteArray = this._alliance.banner.byteArray;
         this._bmp.visible = true;
         if(_loc1_.hexString == BITMAP_DATA_ID)
         {
            this._bmp.bitmapData = BITMAP_DATA;
            this._bmp.smoothing = true;
            return;
         }
         if(BITMAP_DATA)
         {
            BITMAP_DATA.dispose();
         }
         BITMAP_DATA = _loc1_.generateButtonIconTexture();
         BITMAP_DATA_ID = _loc1_.hexString;
         var _loc2_:ColorMatrix = new ColorMatrix();
         _loc2_.adjustSaturation(1.2);
         _loc2_.adjustBrightness(1.8);
         BITMAP_DATA.applyFilter(BITMAP_DATA,BITMAP_DATA.rect,new Point(),_loc2_.filter);
         this._bmp.bitmapData = BITMAP_DATA;
         this._bmp.smoothing = true;
      }
      
      private function showBusySpinner(param1:Boolean) : void
      {
         if(param1 == this._busy)
         {
            return;
         }
         this._busy = param1;
         if(this._busySpinner)
         {
            this._busySpinner.dispose();
         }
         this._busySpinner = null;
         if(this._busy)
         {
            this._busySpinner = new UIBusySpinner();
            this._busySpinner.scaleX = this._busySpinner.scaleY = 1.3;
            this._busySpinner.x = mc_mask.x + mc_mask.width * 0.5;
            this._busySpinner.y = mc_mask.y + mc_mask.height * 0.5;
            addChild(this._busySpinner);
         }
      }
   }
}

