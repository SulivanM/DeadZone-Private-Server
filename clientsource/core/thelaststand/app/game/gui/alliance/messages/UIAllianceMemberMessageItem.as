package thelaststand.app.game.gui.alliance.messages
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextFieldAutoSize;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.data.alliance.AllianceMessage;
   import thelaststand.app.game.data.alliance.AllianceRankPrivilege;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   
   public class UIAllianceMemberMessageItem extends UIAllianceMessageItem
   {
      
      private static var header_bd:BitmapData;
      
      private var _canDelete:Boolean;
      
      private var mc_background:Sprite;
      
      private var btn_delete:Sprite;
      
      private var bmp_delete:Bitmap;
      
      private var txt_subject:BodyTextField;
      
      private var txt_dateName:BodyTextField;
      
      private var txt_body:BodyTextField;
      
      public function UIAllianceMemberMessageItem(param1:AllianceMessage, param2:int)
      {
         var _loc4_:Bitmap = null;
         super(param1,param2);
         if(!header_bd)
         {
            header_bd = new BmpAllianceMessageHeader();
         }
         this._canDelete = AllianceSystem.getInstance().clientMember.hasPrivilege(AllianceRankPrivilege.DeleteMessages) || param1.playerId == AllianceSystem.getInstance().clientMember.id;
         var _loc3_:Number = 20;
         this.txt_dateName = new BodyTextField({
            "size":11,
            "color":12499111,
            "autoSize":"left"
         });
         this.txt_dateName.text = (param1.playerName ? param1.playerName + " - " : "") + getPostDate();
         this.txt_dateName.y = 8;
         addChild(this.txt_dateName);
         if(this._canDelete)
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
            this.txt_dateName.x = int(this.btn_delete.x - this.txt_dateName.width - 4);
         }
         else
         {
            this.txt_dateName.x = int(param2 - this.txt_dateName.width - 10);
         }
         this.txt_subject = new BodyTextField({
            "size":14,
            "color":16777215,
            "autoSize":TextFieldAutoSize.NONE
         });
         this.txt_subject.text = param1.subject;
         this.txt_subject.x = 12;
         this.txt_subject.y = 6;
         this.txt_subject.width = int(this.txt_dateName.x - (this.txt_subject.x + 5));
         addChild(this.txt_subject);
         this.txt_body = new BodyTextField({
            "size":14,
            "color":13618111,
            "wordWrap":true,
            "autoSize":"left"
         });
         this.txt_body.text = param1.body;
         this.txt_body.x = 14;
         this.txt_body.y = 30;
         this.txt_body.width = int(param2 - this.txt_body.x * 2);
         addChild(this.txt_body);
         this.mc_background = new Sprite();
         this.mc_background.cacheAsBitmap = true;
         addChildAt(this.mc_background,0);
         _loc4_ = new Bitmap(header_bd);
         _loc4_.x = _loc4_.y = 6;
         _loc4_.width = int(param2 - _loc4_.x * 2);
         this.mc_background.addChild(_loc4_);
         var _loc5_:Graphics = this.mc_background.graphics;
         _loc5_.beginFill(6183770,1);
         _loc5_.drawRect(0,0,param2,this.txt_body.y + this.txt_body.height + 6);
         _loc5_.beginFill(4078134,1);
         _loc5_.drawRect(3,3,param2 - 6,this.mc_background.height - 6);
         _loc4_ = new Bitmap(tape_bd);
         _loc4_.x = -4;
         _loc4_.y = -6;
         addChild(_loc4_);
         _loc4_ = new Bitmap(tape_bd);
         _loc4_.x = int(param2 - _loc4_.width + 5);
         _loc4_.y = int(this.mc_background.height - _loc4_.height + 6);
         addChild(_loc4_);
         _height = this.mc_background.height;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this.bmp_delete != null)
         {
            this.bmp_delete.bitmapData.dispose();
         }
         this.txt_dateName.dispose();
         this.txt_subject.dispose();
         this.txt_body.dispose();
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

