package thelaststand.app.game.gui.attacklog
{
   import flash.display.Sprite;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class AttackLogSummary extends Sprite
   {
      
      private var titleBar:UITitleBar;
      
      private var title:TitleTextField;
      
      private var _lang:Language;
      
      private var _lines:Vector.<LogSummaryLine>;
      
      public function AttackLogSummary(param1:Object, param2:Vector.<Survivor>, param3:Vector.<Survivor>)
      {
         var _loc13_:LogSummaryLine = null;
         super();
         var _loc4_:Number = 182;
         var _loc5_:Number = 278;
         this._lang = Language.getInstance();
         GraphicUtils.drawUIBlock(this.graphics,_loc4_,_loc5_);
         this.titleBar = new UITitleBar(null,2236962);
         this.titleBar.x = this.titleBar.y = 4;
         this.titleBar.width = _loc4_ - 8;
         this.titleBar.height = 28;
         addChild(this.titleBar);
         this.title = new TitleTextField({
            "color":10066329,
            "size":16
         });
         this.title.text = this._lang.getString("attack_log_summaryTitle");
         this.title.x = this.titleBar.x + int((this.titleBar.width - this.title.width) * 0.5);
         this.title.y = this.titleBar.y + int((this.titleBar.height - this.title.height) * 0.5);
         addChild(this.title);
         this._lines = new Vector.<LogSummaryLine>();
         var _loc6_:Number = this.titleBar.x;
         var _loc7_:Number = this.titleBar.y + this.titleBar.height + 4;
         var _loc8_:String = this._lang.getString("attack_report_vs");
         _loc8_ = _loc8_.replace("%1",String(param1.attackerName));
         _loc8_ = _loc8_.replace("%2",Network.getInstance().playerData.nickname);
         var _loc9_:int = param1.srvDown != null ? int(param1.srvDown.length) : 0;
         var _loc10_:Array = [true,_loc8_,"",false,this._lang.getString("attack_report_survivorsDowned"),(param1.numSrvDown != null ? String(param1.numSrvDown) : _loc9_.toString()) + "/" + param3.length,false,this._lang.getString("attack_report_survivorsInjured"),_loc9_.toString(),false,this._lang.getString("attack_report_attackersKilled"),String(param1.attackerInjured) + "/" + param2.length,false,this._lang.getString("attack_report_buildingsLooted"),String(param1.bldLooted),false,this._lang.getString("attack_report_buildingsDestroyed"),param1.destBlds != null ? String(param1.destBlds.length) : "0",false,this._lang.getString("attack_report_trapsDisarmed"),String(param1.trpDism),false,this._lang.getString("attack_report_trapsTriggered"),String(param1.trpTrig)];
         var _loc11_:* = false;
         var _loc12_:int = 0;
         while(_loc12_ < _loc10_.length)
         {
            _loc13_ = new LogSummaryLine(this.titleBar.width,_loc10_[_loc12_ + 1],_loc10_[_loc12_ + 2],_loc11_,_loc10_[_loc12_]);
            _loc13_.x = _loc6_;
            _loc13_.y = _loc7_;
            addChild(_loc13_);
            _loc7_ += _loc13_.height;
            _loc11_ = !_loc11_;
            this._lines.push(_loc13_);
            _loc12_ += 3;
         }
      }
      
      public function dispose() : void
      {
         var _loc1_:LogSummaryLine = null;
         this._lang = null;
         this.titleBar.dispose();
         this.title.dispose();
         for each(_loc1_ in this._lines)
         {
            _loc1_.dispose();
         }
      }
   }
}

import flash.display.Sprite;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;

class LogSummaryLine extends Sprite
{
   
   private var txt_label:BodyTextField;
   
   private var txt_value:BodyTextField;
   
   public function LogSummaryLine(param1:Number, param2:String, param3:String, param4:Boolean, param5:Boolean)
   {
      super();
      graphics.beginFill(1447446,param4 ? 0 : 1);
      graphics.drawRect(0,0,param1,25);
      var _loc6_:uint = param5 ? 8947848 : 13381383;
      this.txt_label = new BodyTextField({
         "color":_loc6_,
         "size":13,
         "bold":false,
         "filters":[Effects.TEXT_SHADOW_DARK]
      });
      this.txt_label.x = 4;
      this.txt_label.y = 3;
      this.txt_label.text = param2;
      addChild(this.txt_label);
      if(param3 == "")
      {
         this.txt_label.x = int((param1 - this.txt_label.width) * 0.5);
      }
      this.txt_value = new BodyTextField({
         "color":_loc6_,
         "size":13,
         "bold":false,
         "filters":[Effects.TEXT_SHADOW_DARK]
      });
      this.txt_value.text = param3;
      this.txt_value.y = 3;
      this.txt_value.x = param1 - this.txt_value.width - 4;
      addChild(this.txt_value);
   }
   
   public function dispose() : void
   {
      this.txt_label.dispose();
      this.txt_value.dispose();
   }
}
