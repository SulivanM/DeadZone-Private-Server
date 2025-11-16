package thelaststand.app.game.gui.alliance
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.alliance.AllianceData;
   import thelaststand.app.game.data.alliance.AllianceRank;
   import thelaststand.app.game.data.alliance.AllianceRankPrivilege;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.lists.UIAllianceMemberListItem;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class UIAllianceMemberPopupMenu extends Sprite
   {
      
      private var _lang:Language;
      
      private var _alliance:AllianceData;
      
      private var _item:UIAllianceMemberListItem;
      
      private var _allBtns:Vector.<UIAllianceMemberPopupMenuButton> = new Vector.<UIAllianceMemberPopupMenuButton>();
      
      private var mc_background:Shape;
      
      private var btn_kick:UIAllianceMemberPopupMenuButton;
      
      private var btn_rank:UIAllianceMemberPopupMenuButton;
      
      private var btn_compound:UIAllianceMemberPopupMenuButton;
      
      public var itemSelected:Signal = new Signal(String,UIAllianceMemberListItem);
      
      public function UIAllianceMemberPopupMenu()
      {
         super();
         this._alliance = AllianceSystem.getInstance().alliance;
         this._lang = Language.getInstance();
         this.mc_background = new Shape();
         this.mc_background.graphics.beginFill(0,1);
         this.mc_background.graphics.drawRect(0,0,UIAllianceMemberPopupMenuButton.WIDTH,100);
         this.mc_background.filters = [new DropShadowFilter(0,0,0,1,5,5,0.3,1,true),new GlowFilter(6905685,1,1.75,1.75,10,1),new DropShadowFilter(1,45,0,1,8,8,0.6,2)];
         addChild(this.mc_background);
         this.btn_kick = this.createButton(this._lang.getString("alliance.popup_kick"),"kick");
         this.btn_rank = this.createButton(this._lang.getString("alliance.popup_rank"),"rank");
         this.btn_compound = this.createButton(this._lang.getString("alliance.popup_compound"),"view");
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         var _loc1_:UIAllianceMemberPopupMenuButton = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
         for each(_loc1_ in this._allBtns)
         {
            _loc1_.dispose();
         }
         this.itemSelected.removeAll();
         this._lang = null;
         this._item = null;
         this._alliance = null;
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      public function populate(param1:UIAllianceMemberListItem) : void
      {
         var _loc2_:UIAllianceMemberPopupMenuButton = null;
         var _loc3_:int = 0;
         this._item = param1;
         for each(_loc2_ in this._allBtns)
         {
            _loc2_.visible = false;
         }
         _loc3_ = AllianceSystem.getInstance().clientMember != null ? int(AllianceSystem.getInstance().clientMember.rank) : 0;
         if(param1.member.id == Network.getInstance().playerData.id)
         {
            this.btn_kick.visible = true;
            this.btn_kick.label = this._lang.getString("alliance.popup_leave");
         }
         else
         {
            this.btn_kick.label = this._lang.getString("alliance.popup_kick");
            this.btn_kick.visible = AllianceRank.hasPrivilege(_loc3_,AllianceRankPrivilege.RemoveMembers) && param1.member.rank < _loc3_;
            this.btn_rank.visible = AllianceRank.hasPrivilege(_loc3_,AllianceRankPrivilege.DemoteMembers | AllianceRankPrivilege.PromoteMembers) && param1.member.rank < _loc3_;
            this.btn_compound.visible = true;
         }
         var _loc4_:int = 2;
         for each(_loc2_ in this._allBtns)
         {
            if(_loc2_.visible != false)
            {
               addChild(_loc2_);
               _loc2_.y = _loc4_;
               _loc4_ = int(_loc2_.y + _loc2_.height);
            }
         }
         this.mc_background.height = _loc4_ + 2;
      }
      
      private function createButton(param1:String, param2:String) : UIAllianceMemberPopupMenuButton
      {
         var _loc3_:UIAllianceMemberPopupMenuButton = new UIAllianceMemberPopupMenuButton();
         _loc3_.clicked.add(this.onButtonClick);
         _loc3_.label = param1;
         _loc3_.data = param2;
         addChild(_loc3_);
         this._allBtns.push(_loc3_);
         return _loc3_;
      }
      
      private function onButtonClick(param1:UIAllianceMemberPopupMenuButton) : void
      {
         this.itemSelected.dispatch(param1.data,this._item);
         if(parent)
         {
            parent.removeChild(this);
         }
      }
      
      private function onStageMouseDown(param1:MouseEvent) : void
      {
         if(mouseX < 0 || mouseX > this.mc_background.width || mouseY < 0 || mouseY > this.mc_background.height)
         {
            if(parent)
            {
               parent.removeChild(this);
            }
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         stage.addEventListener(MouseEvent.MOUSE_DOWN,this.onStageMouseDown,true,int.MAX_VALUE,true);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onStageMouseDown);
      }
   }
}

import com.greensock.TweenMax;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.AntiAliasType;
import org.osflash.signals.Signal;
import thelaststand.app.display.BodyTextField;

class UIAllianceMemberPopupMenuButton extends Sprite
{
   
   public static const WIDTH:uint = 110;
   
   private var _enabled:Boolean = true;
   
   private var _label:String = "";
   
   private var txt_message:BodyTextField;
   
   private var bg:Shape;
   
   public var data:String;
   
   public var clicked:Signal = new Signal(UIAllianceMemberPopupMenuButton);
   
   public function UIAllianceMemberPopupMenuButton(param1:uint = 13421772)
   {
      super();
      buttonMode = true;
      mouseChildren = false;
      this.bg = new Shape();
      this.bg.graphics.beginFill(4605510,1);
      this.bg.alpha = 0;
      this.bg.graphics.drawRect(0,0,WIDTH,10);
      addChild(this.bg);
      this.txt_message = new BodyTextField({
         "color":param1,
         "size":12,
         "leading":1,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_message.x = 5;
      addChild(this.txt_message);
      addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
      addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
   }
   
   public function dispose() : void
   {
      if(parent)
      {
         parent.removeChild(this);
      }
      removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
      removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
      removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
      this.clicked.removeAll();
   }
   
   public function get label() : String
   {
      return this._label;
   }
   
   public function set label(param1:String) : void
   {
      this._label = param1;
      this.txt_message.text = this._label.toUpperCase();
      this.bg.height = this.txt_message.height;
   }
   
   public function get enabled() : Boolean
   {
      return this._enabled;
   }
   
   public function set enabled(param1:Boolean) : void
   {
      this._enabled = param1;
      mouseEnabled = this._enabled;
      alpha = this._enabled ? 1 : 0.4;
   }
   
   private function onMouseDown(param1:MouseEvent) : void
   {
      this.clicked.dispatch(this);
   }
   
   private function onRollOver(param1:MouseEvent) : void
   {
      TweenMax.to(this.bg,0.05,{"alpha":0.5});
   }
   
   private function onRollOut(param1:MouseEvent) : void
   {
      TweenMax.to(this.bg,0.2,{"alpha":0});
   }
}
