package thelaststand.app.game.gui.attacklog
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.StyleSheet;
   import flash.text.TextFieldAutoSize;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.logic.MissionEventTypes;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.lang.Language;
   
   public class AttackLogScrollListItem extends Sprite
   {
      
      public static const RED:uint = 6757145;
      
      public static const RED_TEXT:uint = 13745082;
      
      public static const GREEN:uint = 1927195;
      
      public static const GREEN_TEXT:uint = 12309179;
      
      public static const ORANGE:uint = 6962688;
      
      public static const ORANGE_TEXT:uint = 13813171;
      
      public static const GREY_TEXT:uint = 12763842;
      
      private static var BD_SKULL:BitmapData = new BmpIconDangerHigh();
      
      public var onTooltip:Signal;
      
      private var bg:Shape;
      
      private var txt_time:BodyTextField;
      
      private var txt_content:BodyTextField;
      
      private var bmp_icon:Bitmap;
      
      private var _attackersLookup:Dictionary;
      
      private var _defendersLookup:Dictionary;
      
      private var survId1:String = "";
      
      private var survId2:String = "";
      
      public function AttackLogScrollListItem(param1:Object, param2:ByteArray, param3:Boolean, param4:Dictionary, param5:Dictionary)
      {
         var _loc6_:Language = null;
         var _loc13_:String = null;
         var _loc14_:String = null;
         var _loc15_:BitmapData = null;
         var _loc20_:int = 0;
         super();
         _loc6_ = Language.getInstance();
         var _loc7_:PlayerData = Network.getInstance().playerData;
         mouseChildren = false;
         this.onTooltip = new Signal(AttackLogScrollListItem,String,String);
         this._attackersLookup = param4;
         this._defendersLookup = param5;
         var _loc8_:String = param2.readUTF();
         var _loc9_:int = param2.readInt();
         var _loc10_:uint = param3 ? 3487029 : 2368548;
         var _loc11_:uint = GREY_TEXT;
         var _loc12_:String = _loc8_;
         switch(_loc8_)
         {
            case MissionEventTypes.LOG_START:
               _loc12_ = _loc6_.getString("attack_log_item_start");
               _loc9_ = -1;
               break;
            case MissionEventTypes.LOG_END:
               _loc12_ = _loc6_.getString("attack_log_item_end");
               _loc9_ = -1;
               break;
            case MissionEventTypes.PROTECTION_ADDED:
               _loc20_ = param2.readInt();
               _loc12_ = _loc6_.getString("attack_log_item_protection",DateTimeUtils.secondsToString(_loc20_));
               _loc9_ = -1;
               _loc10_ = GREEN;
               _loc11_ = GREEN_TEXT;
               break;
            case MissionEventTypes.TIMER_EXPIRED:
               _loc12_ = _loc6_.getString("attack_log_item_timerExpired");
               break;
            case MissionEventTypes.ATTACKERS_LEFT:
               _loc12_ = _loc6_.getString("attack_log_item_attackersLeft");
               break;
            case MissionEventTypes.FAILED_MISSION:
               _loc12_ = _loc6_.getString("attack_log_item_raidFailed");
               _loc10_ = GREEN;
               _loc11_ = GREEN_TEXT;
               break;
            case MissionEventTypes.BUILDING_SCAVENGED:
               _loc13_ = param2.readUTF();
               param2.readBoolean();
               _loc10_ = ORANGE;
               _loc11_ = ORANGE_TEXT;
               _loc12_ = _loc6_.getString("attack_log_item_bldRaided",_loc6_.getString("blds." + _loc13_));
               break;
            case MissionEventTypes.BUILDING_DESTROYED:
               _loc13_ = param2.readUTF();
               _loc10_ = RED;
               _loc11_ = RED_TEXT;
               _loc12_ = _loc6_.getString("attack_log_item_bldDestroyed",_loc6_.getString("blds." + _loc13_));
               break;
            case MissionEventTypes.TRAP_DISARMED:
               _loc13_ = param2.readUTF();
               _loc10_ = ORANGE;
               _loc11_ = ORANGE_TEXT;
               _loc12_ = _loc6_.getString("attack_log_item_trapDisarmed",_loc6_.getString("blds." + _loc13_));
               break;
            case MissionEventTypes.TRAP_TRIGGERED:
               _loc13_ = param2.readUTF();
               _loc12_ = _loc6_.getString("attack_log_item_trapTriggered",_loc6_.getString("blds." + _loc13_));
               break;
            case MissionEventTypes.ATTACKER_DIE_WEAPON:
               this.survId1 = param2.readUTF();
               this.survId2 = param2.readUTF();
               _loc12_ = _loc6_.getString("attack_log_item_downedBy");
               _loc12_ = _loc12_.replace("%1",this.getSurvivorName(this.survId1));
               _loc12_ = _loc12_.replace("%2",this.getSurvivorName(this.survId2));
               _loc15_ = BD_SKULL;
               _loc10_ = GREEN;
               _loc11_ = GREEN_TEXT;
               break;
            case MissionEventTypes.ATTACKER_DIE_EXPLOSIVE:
               this.survId1 = param2.readUTF();
               this.survId2 = param2.readUTF();
               _loc14_ = param2.readUTF();
               _loc12_ = _loc6_.getString("attack_log_item_downedByGren");
               _loc12_ = _loc12_.replace("%1",this.getSurvivorName(this.survId1));
               _loc12_ = _loc12_.replace("%2",this.getSurvivorName(this.survId2));
               _loc12_ = _loc12_.replace("%3",_loc6_.getString("items." + _loc14_));
               _loc15_ = BD_SKULL;
               _loc10_ = GREEN;
               _loc11_ = GREEN_TEXT;
               break;
            case MissionEventTypes.ATTACKER_DIE_TRAP:
               this.survId1 = param2.readUTF();
               _loc13_ = param2.readUTF();
               _loc12_ = _loc6_.getString("attack_log_item_downedByTrap");
               _loc12_ = _loc12_.replace("%1",this.getSurvivorName(this.survId1));
               _loc12_ = _loc12_.replace("%2",_loc6_.getString("blds." + _loc13_));
               _loc15_ = BD_SKULL;
               _loc10_ = GREEN;
               _loc11_ = GREEN_TEXT;
               break;
            case MissionEventTypes.DEFENDER_DIE_WEAPON:
               this.survId1 = param2.readUTF();
               this.survId2 = param2.readUTF();
               _loc12_ = _loc6_.getString("attack_log_item_downedBy");
               _loc12_ = _loc12_.replace("%1",this.getSurvivorName(this.survId1));
               _loc12_ = _loc12_.replace("%2",this.getSurvivorName(this.survId2));
               _loc15_ = BD_SKULL;
               _loc10_ = RED;
               _loc11_ = RED_TEXT;
               break;
            case MissionEventTypes.DEFENDER_DIE_EXPLOSIVE:
               this.survId1 = param2.readUTF();
               this.survId2 = param2.readUTF();
               _loc14_ = param2.readUTF();
               _loc12_ = _loc6_.getString("attack_log_item_downedByGren");
               _loc12_ = _loc12_.replace("%1",this.getSurvivorName(this.survId1));
               _loc12_ = _loc12_.replace("%2",this.getSurvivorName(this.survId2));
               _loc12_ = _loc12_.replace("%3",_loc6_.getString("items." + _loc14_));
               _loc15_ = BD_SKULL;
               _loc10_ = RED;
               _loc11_ = RED_TEXT;
               break;
            case MissionEventTypes.ALLIANCE_FLAG_STOLEN:
               this.survId1 = param2.readUTF();
               _loc12_ = _loc6_.getString("attack_log_item_flagStolen",this.getSurvivorName(this.survId1));
               _loc10_ = RED;
               _loc11_ = RED_TEXT;
               break;
            case MissionEventTypes.EXPLOSIVE_PLACED:
               _loc14_ = param2.readUTF();
               this.survId1 = param2.readUTF();
               _loc12_ = _loc6_.getString("attack_log_item_explPlaced");
               _loc12_ = _loc12_.replace("%1",_loc6_.getString("items." + _loc14_));
               _loc12_ = _loc12_.replace("%2",this.getSurvivorName(this.survId1));
               break;
            case MissionEventTypes.GRENADE_THROWN:
               _loc14_ = param2.readUTF();
               this.survId1 = param2.readUTF();
               _loc12_ = _loc6_.getString("attack_log_item_grenThrown");
               _loc12_ = _loc12_.replace("%1",_loc6_.getString("items." + _loc14_));
               _loc12_ = _loc12_.replace("%2",this.getSurvivorName(this.survId1));
         }
         var _loc16_:Number = 336;
         var _loc17_:Number = 26;
         this.txt_time = new BodyTextField({
            "color":10592673,
            "size":14,
            "bold":false,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_time.text = _loc9_ > 0 ? _loc9_ + "s" : "";
         this.txt_time.x = 38 - this.txt_time.width;
         this.txt_time.y = 2;
         this.txt_time.alpha = 0.8;
         addChild(this.txt_time);
         var _loc18_:Number = 0;
         if(_loc15_ != null)
         {
            this.bmp_icon = new Bitmap(_loc15_);
            this.bmp_icon.x = 44;
            this.bmp_icon.y = this.txt_time.y + int((this.txt_time.height - this.bmp_icon.height) * 0.5);
            addChild(this.bmp_icon);
            _loc18_ = this.bmp_icon.width + 4;
         }
         var _loc19_:StyleSheet = new StyleSheet();
         _loc19_.setStyle("b",{"color":16777215});
         this.txt_content = new BodyTextField({
            "color":_loc11_,
            "size":14,
            "bold":false,
            "autoSize":TextFieldAutoSize.LEFT,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_content.wordWrap = true;
         this.txt_content.multiline = true;
         this.txt_content.mouseWheelEnabled = false;
         this.txt_content.x = 44 + _loc18_;
         this.txt_content.y = this.txt_time.y;
         this.txt_content.width = 281 - _loc18_;
         this.txt_content.styleSheet = _loc19_;
         this.txt_content.htmlText = _loc12_;
         addChild(this.txt_content);
         this.bg = new Shape();
         addChildAt(this.bg,0);
         this.bg.graphics.beginFill(_loc10_);
         this.bg.graphics.drawRect(0,0,350,Math.max(_loc17_,this.txt_content.y + this.txt_content.height + 2));
         if(this.survId1 != "")
         {
            addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
            addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
         }
      }
      
      private function getSurvivorName(param1:String) : String
      {
         if(this._attackersLookup[param1] != null)
         {
            return Survivor(this._attackersLookup[param1]).fullName;
         }
         if(this._defendersLookup[param1] != null)
         {
            return Survivor(this._defendersLookup[param1]).fullName;
         }
         return "[unknown]";
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this._attackersLookup = null;
         this._defendersLookup = null;
         if(this.bmp_icon != null)
         {
            this.bmp_icon = null;
         }
         removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         TweenMax.killDelayedCallsTo(this.triggerTip);
         this.onTooltip.removeAll();
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         TweenMax.delayedCall(0.3,this.triggerTip);
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         TweenMax.killDelayedCallsTo(this.triggerTip);
      }
      
      private function triggerTip() : void
      {
         this.onTooltip.dispatch(this,this.survId1,this.survId2);
      }
   }
}

