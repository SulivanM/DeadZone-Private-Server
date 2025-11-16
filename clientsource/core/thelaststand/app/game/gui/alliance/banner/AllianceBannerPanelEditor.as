package thelaststand.app.game.gui.alliance.banner
{
   import flash.utils.ByteArray;
   import org.osflash.signals.Signal;
   
   public class AllianceBannerPanelEditor extends AllianceBannerPanelAbstract
   {
      
      private var _controls:AllianceBannerControls;
      
      public var changed:Signal = new Signal();
      
      public function AllianceBannerPanelEditor(param1:Boolean = false)
      {
         super(null,param1 ? 368 : 404);
         _bannerDisplay.randomise();
         bmp_titleBar.visible = false;
         if(param1)
         {
            _bannerDisplay.y = 10;
         }
         this._controls = new AllianceBannerControls(_bannerDisplay);
         this._controls.x = int((_width - this._controls.width) * 0.5) + 4;
         this._controls.y = int(_height - this._controls.height) - 10;
         this._controls.changed.add(this.onControlsChanged);
         if(_ready)
         {
            addChild(this._controls);
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._controls.dispose();
      }
      
      override protected function onBannerReady() : void
      {
         if(this._controls)
         {
            addChild(this._controls);
         }
         super.onBannerReady();
      }
      
      private function onControlsChanged() : void
      {
         this.changed.dispatch();
      }
      
      override public function set byteArray(param1:ByteArray) : void
      {
         _bannerDisplay.byteArray = param1;
         this._controls.updateControlsFromBanner();
      }
      
      override public function set hexString(param1:String) : void
      {
         _bannerDisplay.hexString = param1;
         this._controls.updateControlsFromBanner();
      }
   }
}

