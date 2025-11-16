package thelaststand.app.gui.dialogues
{
   import flash.display.Sprite;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.UIBusySpinner;
   
   public class BusyDialogue extends BaseDialogue
   {
      
      private var txt_message:BodyTextField;
      
      private var mc_spinner:UIBusySpinner = new UIBusySpinner(1);
      
      private var mc_container:Sprite = new Sprite();
      
      public function BusyDialogue(param1:String, param2:String = null, param3:Boolean = true)
      {
         this.mc_spinner.width = this.mc_spinner.height = 18;
         this.mc_spinner.x = int(this.mc_spinner.width * 0.5);
         this.mc_spinner.y = int(this.mc_spinner.height * 0.5);
         this.txt_message = new BodyTextField({
            "text":param1,
            "color":16777215,
            "size":14,
            "bold":true,
            "leading":1
         });
         this.txt_message.filters = [Effects.TEXT_SHADOW];
         this.txt_message.x = int(this.mc_spinner.x + this.mc_spinner.width + 4);
         this.txt_message.y = int(this.mc_spinner.y - this.txt_message.height * 0.5);
         this.mc_container.addChild(this.txt_message);
         this.mc_container.addChild(this.mc_spinner);
         super(param2,this.mc_container,false,param3);
         playSounds = false;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.txt_message.dispose();
         this.txt_message = null;
         this.mc_spinner.dispose();
         this.mc_spinner = null;
      }
   }
}

