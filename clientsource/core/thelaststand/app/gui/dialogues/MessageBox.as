package thelaststand.app.gui.dialogues
{
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.text.TextLineMetrics;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.utils.GraphicUtils;
   
   public class MessageBox extends BaseDialogue
   {
      
      private var _message:String;
      
      private var _minTextWidth:int;
      
      private var _maxTextWidth:int;
      
      private var mc_container:Sprite;
      
      private var mc_image:UIImage;
      
      private var txt_message:BodyTextField;
      
      private var _showCloseButton:Boolean;
      
      public function MessageBox(param1:String, param2:String = null, param3:Boolean = false, param4:Boolean = true, param5:int = 100, param6:int = 340)
      {
         this._minTextWidth = param5;
         this._maxTextWidth = param6;
         this._showCloseButton = param3;
         var _loc7_:String = "<textformat leading=\'-8\'><br/><br/></textformat>";
         this._message = param1.replace(/\<br\/?\>\<br\/?\>/ig,_loc7_);
         this.txt_message = new BodyTextField({
            "color":16777215,
            "size":14,
            "leading":1
         });
         this.txt_message.filters = [Effects.TEXT_SHADOW];
         this.updateText();
         this.mc_container = new Sprite();
         this.mc_container.addChild(this.txt_message);
         this.adjustContentSize();
         super(param2,this.mc_container,param3,param4);
         _buttonSpacing = 10;
         _buttonClass = PushButton;
      }
      
      public function addImage(param1:*, param2:int = 64, param3:int = 64) : UIImage
      {
         var _loc4_:int = 3;
         var _loc5_:Shape = new Shape();
         GraphicUtils.drawUIBlock(_loc5_.graphics,param2 + _loc4_ * 2,param3 + _loc4_ * 2);
         this.mc_image = new UIImage(param2,param3);
         this.mc_image.x = this.mc_image.y = _loc4_;
         if(param1 is String)
         {
            this.mc_image.uri = String(param1);
         }
         else if(param1 is Function)
         {
            this.mc_image.getURIViaFunction(param1);
         }
         this.updateText();
         this.txt_message.x = int(_loc5_.x + _loc5_.width + 6);
         this.mc_container.addChild(_loc5_);
         this.mc_container.addChild(this.mc_image);
         this.adjustContentSize();
         return this.mc_image;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         _buttonClass = null;
         this.txt_message.dispose();
         this.txt_message = null;
         if(this.mc_image != null)
         {
            this.mc_image.dispose();
            this.mc_image = null;
         }
      }
      
      private function updateText() : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc5_:TextLineMetrics = null;
         var _loc6_:Number = NaN;
         var _loc1_:int = this.mc_image != null ? int(Math.max(this._maxTextWidth,200)) : this._maxTextWidth;
         var _loc2_:Boolean = this._message.indexOf("<br/>") > -1 || this._message.indexOf("<br>") > -1 || this._message.indexOf("\r") > -1;
         this.txt_message.multiline = this.txt_message.wordWrap = _loc2_;
         if(_loc2_)
         {
            this.txt_message.width = int.MAX_VALUE;
         }
         this.txt_message.htmlText = this._message;
         if(_loc2_)
         {
            _loc3_ = 0;
            _loc4_ = 0;
            while(_loc4_ < this.txt_message.numLines)
            {
               _loc5_ = this.txt_message.getLineMetrics(_loc4_);
               _loc6_ = _loc5_.x + _loc5_.width;
               if(_loc6_ > _loc3_)
               {
                  _loc3_ = _loc6_;
               }
               _loc4_++;
            }
            this.txt_message.width = _loc3_ + 10;
            if(this.txt_message.width < this._minTextWidth)
            {
               this.txt_message.width = this._minTextWidth;
            }
         }
         if(this.txt_message.width > _loc1_)
         {
            this.txt_message.multiline = this.txt_message.wordWrap = true;
            this.txt_message.width = _loc1_;
         }
      }
      
      private function adjustContentSize() : void
      {
         if(this._showCloseButton == false)
         {
            return;
         }
         var _loc1_:Graphics = this.mc_container.graphics;
         _loc1_.clear();
         _loc1_.beginFill(0,0);
         _loc1_.drawRect(0,0,this.txt_message.x + this.txt_message.width + 40,10);
      }
   }
}

