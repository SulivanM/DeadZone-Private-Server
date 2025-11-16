package thelaststand.app.game.gui.raid
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.assignment.AssignmentData;
   import thelaststand.app.game.gui.dialogues.StoreDialogue;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.GraphicUtils;
   
   public class AssignmentAmmoView extends UIComponent
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _assignment:AssignmentData;
      
      private var bmp_ammo:Bitmap;
      
      private var txt_ammo:BodyTextField;
      
      private var btn_addAmmo:PushButton;
      
      public function AssignmentAmmoView()
      {
         super();
         this.bmp_ammo = new Bitmap(new BmpIconAmmunition(),"auto",true);
         this.bmp_ammo.width = 26;
         this.bmp_ammo.scaleY = this.bmp_ammo.scaleX;
         this.bmp_ammo.filters = [new GlowFilter(13997568,0.5,6,6,1,1)];
         addChild(this.bmp_ammo);
         this.txt_ammo = new BodyTextField({
            "color":13997568,
            "size":18,
            "bold":true
         });
         this.txt_ammo.text = "0 / 0";
         addChild(this.txt_ammo);
         this.btn_addAmmo = new PushButton("",new BmpIconAddResource(),-1,null,4226049);
         this.btn_addAmmo.showBorder = false;
         this.btn_addAmmo.clicked.add(this.onClickAddAmmo);
         this.btn_addAmmo.width = this.btn_addAmmo.height = 18;
         addChild(this.btn_addAmmo);
         Network.getInstance().playerData.compound.resources.resourceChanged.add(this.onResourceChanged);
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         invalidate();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
         invalidate();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         Network.getInstance().playerData.compound.resources.resourceChanged.remove(this.onResourceChanged);
         this.bmp_ammo.bitmapData.dispose();
         this.txt_ammo.dispose();
         this._assignment.survivorsChanged.remove(this.onSurvivorsChanged);
         this._assignment = null;
      }
      
      public function setData(param1:AssignmentData) : void
      {
         this._assignment = param1;
         this._assignment.survivorsChanged.add(this.onSurvivorsChanged);
         invalidate();
      }
      
      override protected function draw() : void
      {
         graphics.clear();
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         var _loc1_:int = 10;
         this.bmp_ammo.x = int(this.bmp_ammo.width * 0.5);
         this.bmp_ammo.y = int((this._height - this.bmp_ammo.height) * 0.5);
         this.txt_ammo.x = int((this._width - this.txt_ammo.width) * 0.5);
         this.txt_ammo.y = int((this._height - this.txt_ammo.height) * 0.5);
         this.btn_addAmmo.x = int(this._width - this.btn_addAmmo.width - _loc1_);
         this.btn_addAmmo.y = int((this._height - this.btn_addAmmo.height) * 0.5);
         this.updateAmmo();
      }
      
      private function updateAmmo() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this._assignment.currentStageIndex == 0)
         {
            _loc1_ = Network.getInstance().playerData.compound.resources.getAmount(GameResources.AMMUNITION);
            _loc2_ = MissionData.calculateAmmoCost(this._assignment.getSurvivorList());
            this.txt_ammo.text = NumberFormatter.format(_loc2_,0) + " / " + NumberFormatter.format(_loc1_,0);
            this.txt_ammo.textColor = _loc2_ > _loc1_ ? Effects.COLOR_WARNING : 13997568;
            mouseEnabled = true;
            mouseChildren = true;
            filters = [];
         }
         else
         {
            this.txt_ammo.text = "- / -";
            mouseEnabled = false;
            mouseChildren = false;
            filters = [Effects.GREYSCALE.filter];
         }
         this.txt_ammo.x = int((this._width - this.txt_ammo.width) * 0.5);
      }
      
      private function onResourceChanged(param1:String, param2:int) : void
      {
         if(param1 == GameResources.AMMUNITION)
         {
            this.updateAmmo();
         }
      }
      
      private function onSurvivorsChanged() : void
      {
         this.updateAmmo();
      }
      
      private function onClickAddAmmo(param1:MouseEvent) : void
      {
         var _loc2_:StoreDialogue = new StoreDialogue("resource",GameResources.AMMUNITION);
         _loc2_.open();
      }
   }
}

