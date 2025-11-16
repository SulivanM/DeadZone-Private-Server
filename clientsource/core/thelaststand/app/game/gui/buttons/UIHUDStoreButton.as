package thelaststand.app.game.gui.buttons
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.network.Network;
   
   public class UIHUDStoreButton extends UIHUDButton
   {
      
      private var _ptSale:Point;
      
      private var bmp_sale:Bitmap;
      
      public function UIHUDStoreButton(param1:String)
      {
         super(param1,new Bitmap(new BmpIconHUDStore()));
         offset.y = 10;
         if(Network.getInstance().data.saleCategories.length > 0)
         {
            this.bmp_sale = new Bitmap(new BmpIconItemSale());
            this.bmp_sale.x = 10;
            this.bmp_sale.y = 10;
            addChild(this.bmp_sale);
            this._ptSale = new Point(this.bmp_sale.x,this.bmp_sale.y);
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this.bmp_sale != null)
         {
            this.bmp_sale.bitmapData.dispose();
            this.bmp_sale.bitmapData = null;
            this.bmp_sale = null;
         }
      }
      
      override protected function onMouseOver(param1:MouseEvent) : void
      {
         if(param1.buttonDown || mc_icon == null || !enabled)
         {
            return;
         }
         super.onMouseOver(param1);
         if(this.bmp_sale != null)
         {
            TweenMax.to(this.bmp_sale,0.15,{
               "x":this._ptSale.x - 5,
               "y":this._ptSale.y - 5
            });
         }
      }
      
      override protected function onMouseOut(param1:MouseEvent) : void
      {
         super.onMouseOut(param1);
         if(this.bmp_sale != null)
         {
            TweenMax.to(this.bmp_sale,0.15,{
               "x":this._ptSale.x,
               "y":this._ptSale.y
            });
         }
      }
   }
}

