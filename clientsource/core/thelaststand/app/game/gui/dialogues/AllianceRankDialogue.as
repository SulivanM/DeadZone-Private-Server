package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceData;
   import thelaststand.app.game.data.alliance.AllianceMember;
   import thelaststand.app.game.data.alliance.AllianceRank;
   import thelaststand.app.game.data.alliance.AllianceRankPrivilege;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.lists.UIAllianceRankList;
   import thelaststand.app.game.gui.lists.UIAllianceRankListItem;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.RPCResponse;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.app.utils.StringUtils;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   
   public class AllianceRankDialogue extends BaseDialogue
   {
      
      public static const MODE_EDIT_PLAYER_RANK:String = "editPlayer";
      
      public static const MODE_PREVIEW_RANKS:String = "previewRanks";
      
      private var _lang:Language;
      
      private var _allianceSystem:AllianceSystem;
      
      private var _alliance:AllianceData;
      
      private var _mode:String;
      
      private var _member:AllianceMember;
      
      private var _descWidth:Number;
      
      private var mc_container:Sprite;
      
      private var ui_rankList:UIAllianceRankList;
      
      private var btn_assign:PushButton;
      
      private var btn_cancel:PushButton;
      
      private var txt_rankTitle:BodyTextField;
      
      private var txt_rankDesc:BodyTextField;
      
      public function AllianceRankDialogue(param1:String = "previewRanks", param2:AllianceMember = null)
      {
         var _loc8_:Array = null;
         var _loc9_:Array = null;
         var _loc10_:int = 0;
         this.mc_container = new Sprite();
         super("alliance-editRank",this.mc_container,true);
         if(param1 == MODE_EDIT_PLAYER_RANK && param2 == null)
         {
            throw new Error("A reference to an AllianceMember object must be supplied when editing a member\'s rank.");
         }
         this._member = param2;
         this._allianceSystem = AllianceSystem.getInstance();
         this._allianceSystem.disconnected.add(this.onAllianceSystemDisconnected);
         this._allianceSystem.clientMember.rankChanged.add(this.onClientRankChanged);
         this._alliance = this._allianceSystem.alliance;
         this._alliance.rankNameChanged.add(this.onRankNameChanged);
         this._mode = param1;
         this._lang = Language.getInstance();
         _autoSize = false;
         _width = 480;
         _height = this._mode == MODE_PREVIEW_RANKS ? 300 : 336;
         var _loc3_:int = _padding * 0.5;
         var _loc4_:Boolean = param1 == MODE_PREVIEW_RANKS && this._allianceSystem.clientMember.hasPrivilege(AllianceRankPrivilege.EditRankNames);
         this.ui_rankList = new UIAllianceRankList(_loc4_);
         this.ui_rankList.width = 180;
         this.ui_rankList.height = 255;
         this.ui_rankList.x = 0;
         this.ui_rankList.y = _loc3_;
         this.ui_rankList.changed.add(this.onRankListChanged);
         this.ui_rankList.editRank.add(this.onEditRankName);
         this.mc_container.addChild(this.ui_rankList);
         var _loc5_:int = 4;
         var _loc6_:Rectangle = new Rectangle(int(this.ui_rankList.x + this.ui_rankList.width + 10),int(this.ui_rankList.y),int(_width - _padding * 2 - (this.ui_rankList.x + this.ui_rankList.width) - 10),int(this.ui_rankList.height));
         this._descWidth = int(_loc6_.width - _loc5_ * 2);
         GraphicUtils.drawUIBlock(this.mc_container.graphics,_loc6_.width,_loc6_.height,_loc6_.x,_loc6_.y,1250067);
         this.txt_rankTitle = new BodyTextField({
            "text":" ",
            "color":14540253,
            "size":18,
            "bold":true,
            "maxWidth":this._descWidth,
            "x":_loc6_.x + _loc5_,
            "y":_loc6_.y + _loc5_
         });
         this.mc_container.addChild(this.txt_rankTitle);
         this.txt_rankDesc = new BodyTextField({
            "text":" ",
            "color":14540253,
            "size":14,
            "width":_loc6_.width,
            "x":_loc6_.x + _loc5_,
            "y":_loc6_.y + _loc5_,
            "autoSize":"left",
            "multiline":true
         });
         this.mc_container.addChild(this.txt_rankDesc);
         if(param1 == MODE_EDIT_PLAYER_RANK)
         {
            addTitle(this._lang.getString("alliance.editrank_title",this._member.nickname),TITLE_COLOR_GREY);
            this.btn_assign = new PushButton(this._lang.getString("alliance.editrank_assignBtn"));
            this.btn_assign.x = _width - _padding * 2 - this.btn_assign.width;
            this.btn_assign.y = _height - _padding * 2.5 - this.btn_assign.height;
            this.btn_assign.clicked.add(this.onButtonClick);
            this.mc_container.addChild(this.btn_assign);
            this.btn_cancel = new PushButton(this._lang.getString("alliance.editrank_cancelBtn"));
            this.btn_cancel.x = this.btn_assign.x - this.btn_assign.width - 10;
            this.btn_cancel.y = this.btn_assign.y;
            this.btn_cancel.clicked.add(this.onButtonClick);
            this.mc_container.addChild(this.btn_cancel);
            _loc8_ = AllianceRank.getAllRanks();
            if(this._allianceSystem.clientMember.rank == AllianceRank.FOUNDER)
            {
               this.ui_rankList.rankList = _loc8_;
            }
            else
            {
               _loc9_ = [];
               _loc10_ = 0;
               while(_loc10_ < _loc8_.length)
               {
                  if(_loc8_[_loc10_] < this._allianceSystem.clientMember.rank)
                  {
                     _loc9_.push(_loc8_[_loc10_]);
                  }
                  _loc10_++;
               }
               this.ui_rankList.rankList = _loc9_;
            }
         }
         else if(param1 == MODE_PREVIEW_RANKS)
         {
            addTitle(this._lang.getString("alliance.viewrank_title"),TITLE_COLOR_GREY);
            this.ui_rankList.rankList = AllianceRank.getAllRanks();
         }
         var _loc7_:int = this._member != null ? int(this._member.rank) : int(this._allianceSystem.clientMember.rank);
         this.ui_rankList.selectItemById(String(_loc7_));
         this.onRankListChanged();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this.btn_cancel)
         {
            this.btn_cancel.dispose();
         }
         if(this.btn_assign)
         {
            this.btn_assign.dispose();
         }
         this.ui_rankList.dispose();
         this.txt_rankDesc.dispose();
         this.txt_rankTitle.dispose();
         this._lang = null;
         this._member = null;
         if(this._alliance != null)
         {
            this._alliance.rankNameChanged.remove(this.onRankNameChanged);
         }
         if(this._allianceSystem.clientMember != null)
         {
            this._allianceSystem.clientMember.rankChanged.remove(this.onClientRankChanged);
         }
         this._allianceSystem.disconnected.remove(this.onAllianceSystemDisconnected);
         this._allianceSystem = null;
         this._alliance = null;
      }
      
      override public function open() : void
      {
         if(!this._allianceSystem.alliancesEnabled || !this._allianceSystem.inAlliance || this._allianceSystem.alliance == null)
         {
            close();
            return;
         }
         super.open();
      }
      
      private function onEditRankName(param1:int) : void
      {
         var defaultName:String = null;
         var currentName:String = null;
         var dlg:GenericTextInputDialogue = null;
         var rank:int = param1;
         defaultName = this._lang.getString("alliance.rank_" + rank);
         currentName = this._alliance.getRankName(rank);
         dlg = new GenericTextInputDialogue(this._lang.getString("alliance.editrankname_title"),this._lang.getString("alliance.editrankname_desc"),currentName,this._lang.getString("alliance.editrankname_submit"));
         dlg.input.textField.maxChars = 30;
         dlg.allowBlank = true;
         dlg.onSubmit.add(function(param1:String):void
         {
            var busyDlg:BusyDialogue = null;
            var newName:String = param1;
            newName = newName.replace(/^\s*|\s*$/ig,"");
            if(newName.toLowerCase() == defaultName.toLowerCase())
            {
               newName = "";
            }
            if(newName.replace(/\s*\ig/,"") == "")
            {
               newName = "";
               if(currentName == defaultName)
               {
                  dlg.close();
                  return;
               }
            }
            if(newName == currentName)
            {
               dlg.close();
               return;
            }
            busyDlg = new BusyDialogue(_lang.getString("alliance.editrankname_saving"));
            busyDlg.open();
            _allianceSystem.changeRankName(rank,newName,function(param1:RPCResponse):void
            {
               var _loc3_:MessageBox = null;
               busyDlg.close();
               var _loc2_:Language = Language.getInstance();
               if(!param1.success)
               {
                  _loc3_ = new MessageBox(_loc2_.getString("alliance.editrankname_errorMsg"));
                  _loc3_.addTitle(_loc2_.getString("alliance.editrankname_errorTitle"),BaseDialogue.TITLE_COLOR_RUST);
                  _loc3_.addButton(_loc2_.getString("alliance.editrankname_errorOk"));
                  _loc3_.open();
                  return;
               }
               dlg.close();
            });
         });
         dlg.open();
      }
      
      private function doRankChange(param1:Event = null) : void
      {
         var item:UIAllianceRankListItem;
         var rankName:String;
         var memberId:String;
         var busyStr:String;
         var memberName:String = null;
         var busyDlg:BusyDialogue = null;
         var e:Event = param1;
         if(this._allianceSystem == null || this._alliance == null || this._member == null)
         {
            return;
         }
         item = UIAllianceRankListItem(this.ui_rankList.selectedItem);
         rankName = this._alliance.getRankName(item.rank);
         memberId = this._member.id;
         memberName = this._member.nickname;
         busyStr = this._lang.getString("alliance.editrank_busy");
         busyStr = busyStr.replace("%user",memberName);
         busyStr = busyStr.replace("%rank",rankName);
         busyDlg = new BusyDialogue(busyStr);
         busyDlg.open();
         this._allianceSystem.changeMemberRank(memberId,item.rank,function(param1:RPCResponse):void
         {
            var lang:Language;
            var newRank:int;
            var newRankName:String;
            var twoICRankName:String;
            var successStr:String;
            var successMsg:MessageBox;
            var errDlg:MessageBox = null;
            var response:RPCResponse = param1;
            busyDlg.close();
            lang = Language.getInstance();
            if(!response.success)
            {
               errDlg = new MessageBox(lang.getString("alliance.editrank_failMsg",memberName));
               errDlg.addTitle(lang.getString("alliance.editrank_failTitle"),BaseDialogue.TITLE_COLOR_RUST);
               errDlg.addButton(lang.getString("alliance.editrank_btnOk"));
               errDlg.open();
               return;
            }
            if(AllianceSystem.getInstance().alliance == null)
            {
               return;
            }
            newRank = int(response.data.rank);
            newRankName = AllianceSystem.getInstance().alliance.getRankName(newRank);
            twoICRankName = AllianceSystem.getInstance().alliance.getRankName(AllianceRank.RANK_9);
            successStr = lang.getString(newRank == AllianceRank.FOUNDER ? "alliance.editrank_successMsgLeader" : "alliance.editrank_successMsg");
            successStr = successStr.replace("%user",memberName);
            successStr = successStr.replace("%rank",newRankName);
            successStr = successStr.replace("%2ic",twoICRankName);
            successMsg = new MessageBox(successStr);
            successMsg.addTitle(lang.getString("alliance.editrank_successTitle"));
            successMsg.addButton(lang.getString("alliance.editrank_btnOk"));
            successMsg.open();
            if(newRank == AllianceRank.FOUNDER)
            {
               DialogueManager.getInstance().closeDialogue("allianceDialogue");
               successMsg.closed.addOnce(function(param1:Dialogue):void
               {
                  new AllianceDialogue(AllianceDialogue.ID_MEMBERS).open();
               });
            }
            close();
         });
      }
      
      private function warnAboutLeadershipChangePart1(param1:MouseEvent = null) : void
      {
         var _loc2_:String = this._lang.getString("alliance.editrank_leadershipMsg1");
         _loc2_ = _loc2_.replace("%leader",this._alliance.getRankName(AllianceRank.FOUNDER));
         _loc2_ = _loc2_.replace("%2ic",this._alliance.getRankName(AllianceRank.TWO_IC));
         var _loc3_:MessageBox = new MessageBox(_loc2_,null,true);
         _loc3_.addTitle(this._lang.getString("alliance.editrank_leadershipTitle1"));
         _loc3_.addButton(this._lang.getString("alliance.editrank_btnCancel"));
         _loc3_.addButton(this._lang.getString("alliance.editrank_btnOk"),true,{"backgroundColor":Effects.BUTTON_WARNING_RED}).clicked.addOnce(this.warnAboutLeadershipChangePart2);
         _loc3_.open();
      }
      
      private function warnAboutLeadershipChangePart2(param1:MouseEvent = null) : void
      {
         var _loc2_:MessageBox = new MessageBox(this._lang.getString("alliance.editrank_leadershipMsg2"),null,true,true,100,240);
         _loc2_.addTitle(this._lang.getString("alliance.editrank_leadershipTitle2"));
         _loc2_.addButton(this._lang.getString("alliance.editrank_btnCancel"));
         _loc2_.addButton(this._lang.getString("alliance.editrank_btnOk"),true,{"backgroundColor":Effects.BUTTON_WARNING_RED}).clicked.addOnce(this.doRankChange);
         _loc2_.open();
      }
      
      private function onRankListChanged() : void
      {
         var _loc2_:Boolean = false;
         if(this._alliance == null)
         {
            return;
         }
         var _loc1_:UIAllianceRankListItem = UIAllianceRankListItem(this.ui_rankList.selectedItem);
         this.txt_rankTitle.text = this._alliance.getRankName(_loc1_.rank).toUpperCase();
         this.txt_rankDesc.htmlText = StringUtils.htmlSetDoubleBreakLeading(this._lang.getString("alliance.rank_" + _loc1_.rank + "_desc"));
         this.txt_rankDesc.y = this.txt_rankTitle.y + this.txt_rankTitle.height;
         this.txt_rankDesc.width = this._descWidth;
         if(this._mode == MODE_EDIT_PLAYER_RANK && this._member != null)
         {
            _loc2_ = _loc1_.rank != this._member.rank && (_loc1_.rank < this._allianceSystem.clientMember.rank || this._allianceSystem.clientMember.rank == AllianceRank.FOUNDER);
            this.btn_assign.enabled = _loc2_;
            this.btn_assign.backgroundColor = _loc1_.rank == AllianceRank.FOUNDER ? Effects.BUTTON_WARNING_RED : 2960942;
         }
      }
      
      private function onRankNameChanged(param1:int) : void
      {
         var _loc3_:String = null;
         var _loc2_:UIAllianceRankListItem = this.ui_rankList.getItemByRank(param1);
         if(_loc2_ != null)
         {
            _loc3_ = this._alliance.getRankName(param1);
            _loc2_.label = _loc3_;
            if(_loc2_ == this.ui_rankList.selectedItem)
            {
               this.txt_rankTitle.text = _loc3_.toUpperCase();
            }
         }
      }
      
      private function onButtonClick(param1:MouseEvent) : void
      {
         switch(param1.target)
         {
            case this.btn_cancel:
               close();
               break;
            case this.btn_assign:
               if(this._allianceSystem.clientMember.rank == AllianceRank.FOUNDER && UIAllianceRankListItem(this.ui_rankList.selectedItem).rank == AllianceRank.FOUNDER)
               {
                  this.warnAboutLeadershipChangePart1();
                  break;
               }
               this.doRankChange();
         }
      }
      
      private function onAllianceSystemDisconnected() : void
      {
         close();
      }
      
      private function onClientRankChanged(param1:AllianceMember) : void
      {
         close();
      }
   }
}

