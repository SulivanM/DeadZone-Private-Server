package thelaststand.app.game.gui.alliance.messages
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceMessage;
   import thelaststand.app.game.data.alliance.AllianceRankPrivilege;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.common.lang.Language;
   
   public class UIAllianceAdminMessageItem extends UIAllianceMessageItem
   {
      
      private var mc_background:Sprite;
      
      private var txt_date:BodyTextField;
      
      private var txt_message:BodyTextField;
      
      private var btn_delete:Sprite;
      
      private var bmp_delete:Bitmap;
      
      public function UIAllianceAdminMessageItem(param1:AllianceMessage, param2:int)
      {
         var _loc5_:Array = null;
         var _loc6_:Bitmap = null;
         var _loc7_:Array = null;
         var _loc8_:Array = null;
         var _loc9_:Array = null;
         super(param1,param2);
         this.txt_date = new BodyTextField({
            "size":11,
            "color":4564293,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_date.text = getPostDate();
         this.txt_date.y = 8;
         this.txt_date.x = int(param2 - this.txt_date.width - 10);
         addChild(this.txt_date);
         if(AllianceSystem.getInstance().clientMember.hasPrivilege(AllianceRankPrivilege.DeleteMessages))
         {
            this.bmp_delete = new Bitmap(new BmpIconButtonClose(),"auto",false);
            this.bmp_delete.width = this.bmp_delete.height = 8;
            this.btn_delete = new Sprite();
            this.btn_delete.alpha = 0.5;
            this.btn_delete.addChild(this.bmp_delete);
            this.btn_delete.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverDelete,false,0,true);
            this.btn_delete.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutDelete,false,0,true);
            this.btn_delete.addEventListener(MouseEvent.CLICK,this.onClickDelete,false,0,true);
            addChild(this.btn_delete);
            this.btn_delete.x = int(param2 - this.btn_delete.width - 12);
            this.btn_delete.y = 13;
            this.txt_date.x = int(this.btn_delete.x - this.txt_date.width - 4);
         }
         else
         {
            this.txt_date.x = int(param2 - this.txt_date.width - 10);
         }
         this.txt_message = new BodyTextField({
            "size":14,
            "color":11855540,
            "multiline":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         var _loc3_:Language = Language.getInstance();
         var _loc4_:String = "alliance.messages_" + param1.subject;
         switch(param1.subject)
         {
            case "whiteflag":
               _loc5_ = param1.body.split("|");
               this.txt_message.htmlText = _loc3_.getString(_loc4_,_loc5_[0],_loc5_[1]);
               break;
            case "userpointsdeducted":
               _loc5_ = param1.body.split("|");
               this.txt_message.htmlText = _loc3_.getString(_loc4_,_loc5_[0],_loc5_[1]);
               break;
            case "memberJoined":
               _loc5_ = param1.body.split("|");
               if(_loc5_.length < 2)
               {
                  _loc5_.push("N/A");
               }
               this.txt_message.htmlText = _loc3_.getString(_loc4_,_loc5_[0],_loc5_[1]);
               break;
            case "memberLeave":
               this.txt_message.htmlText = _loc3_.getString(_loc4_,param1.body);
               break;
            case "memberKicked":
               _loc7_ = param1.body.split("|");
               this.txt_message.htmlText = _loc3_.getString(_loc4_,_loc7_[0],_loc7_[1]);
               break;
            case "effectAdded":
               _loc8_ = param1.body.split("|");
               this.txt_message.htmlText = _loc3_.getString(_loc4_,_loc3_.getString("effect_names." + _loc8_[0]),_loc8_[1]);
               break;
            case "bonusEffect":
               this.txt_message.htmlText = _loc3_.getString(_loc4_,_loc3_.getString("effect_names." + param1.body));
               break;
            case "taskComplete":
               _loc9_ = param1.body.split("|");
               this.txt_message.htmlText = _loc3_.getString(_loc4_,_loc3_.getString("alliance.task_" + _loc9_[0]),NumberFormatter.format(int(_loc9_[1]),0));
         }
         this.txt_message.x = 12;
         this.txt_message.y = 6;
         this.txt_message.width = int(this.txt_date.x - (this.txt_message.x + 5));
         addChild(this.txt_message);
         this.mc_background = new Sprite();
         this.mc_background.cacheAsBitmap = true;
         addChildAt(this.mc_background,0);
         this.mc_background.graphics.beginFill(5867609,1);
         this.mc_background.graphics.drawRect(0,0,param2,this.txt_message.y + this.txt_message.height + 6);
         this.mc_background.graphics.beginFill(3100207,1);
         this.mc_background.graphics.drawRect(3,3,param2 - 6,this.mc_background.height - 6);
         _height = this.mc_background.height;
         _loc6_ = new Bitmap(tape_bd);
         _loc6_.x = -4;
         _loc6_.y = -6;
         addChild(_loc6_);
         _loc6_ = new Bitmap(tape_bd);
         _loc6_.x = int(param2 - _loc6_.width + 5);
         _loc6_.y = int(_height - _loc6_.height + 6);
         addChild(_loc6_);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this.bmp_delete != null)
         {
            this.bmp_delete.bitmapData.dispose();
         }
         this.txt_date.dispose();
         this.txt_message.dispose();
      }
      
      private function onClickDelete(param1:MouseEvent) : void
      {
         dispatchEvent(new Event("msgDelete"));
      }
      
      private function onMouseOverDelete(param1:MouseEvent) : void
      {
         this.btn_delete.alpha = 1;
      }
      
      private function onMouseOutDelete(param1:MouseEvent) : void
      {
         this.btn_delete.alpha = 0.5;
      }
   }
}

