package thelaststand.app.game.gui.compound
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.text.AntiAliasType;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   
   public class UIBuildingJobPanel extends Sprite
   {
      
      private var _jobTitle:String;
      
      private var _width:int;
      
      private var _height:int;
      
      private var mc_background:Shape;
      
      private var mc_stripe1:ConstructionStripes;
      
      private var mc_stripe2:ConstructionStripes;
      
      private var mc_stripeContainer:Sprite;
      
      private var mc_stripeMask:Shape;
      
      private var txt_job:TitleTextField;
      
      public function UIBuildingJobPanel(param1:int, param2:int)
      {
         super();
         this._width = param1;
         this._height = param2;
         this.mc_background = new Shape();
         this.mc_background.graphics.beginFill(5460561);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         this.mc_background.graphics.beginBitmapFill(BaseDialogue.BMP_GRIME);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         this.mc_background.filters = [BaseDialogue.INNER_SHADOW,BaseDialogue.STROKE,BaseDialogue.DROP_SHADOW];
         addChild(this.mc_background);
         this.mc_stripeMask = new Shape();
         this.mc_stripeMask.graphics.beginFill(16711680);
         this.mc_stripeMask.graphics.drawRect(-1,-1,this._width + 2,this._height + 2);
         this.mc_stripeMask.graphics.endFill();
         this.mc_stripeMask.cacheAsBitmap = true;
         addChild(this.mc_stripeMask);
         this.mc_stripeContainer = new Sprite();
         this.mc_stripeContainer.mask = this.mc_stripeMask;
         this.mc_stripeContainer.cacheAsBitmap = true;
         addChild(this.mc_stripeContainer);
         this.mc_stripe1 = new ConstructionStripes();
         this.mc_stripe1.x = int(this.mc_background.x + this.mc_background.width - this.mc_stripe1.width + 1);
         this.mc_stripe1.y = -1;
         this.mc_stripeContainer.addChild(this.mc_stripe1);
         this.mc_stripe2 = new ConstructionStripes();
         this.mc_stripe2.x = int(this.mc_stripe1.x);
         this.mc_stripe2.y = int(this._height - this.mc_stripe2.height + 1);
         this.mc_stripeContainer.addChild(this.mc_stripe2);
         this.txt_job = new TitleTextField({
            "text":" ",
            "color":11908533,
            "size":16,
            "multiline":true,
            "align":"center",
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_job.x = 2;
         this.txt_job.width = int(this._width - this.txt_job.x);
         this.txt_job.maxWidth = int(this._width - 10);
         addChild(this.txt_job);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this.txt_job.dispose();
      }
      
      public function get jobTitle() : String
      {
         return this._jobTitle;
      }
      
      public function set jobTitle(param1:String) : void
      {
         this._jobTitle = param1;
         this.txt_job.text = this._jobTitle.toUpperCase();
         this.txt_job.y = Math.round(this.mc_stripe1.y + this.mc_stripe1.height + 4);
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

