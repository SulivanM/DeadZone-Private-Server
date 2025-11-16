package thelaststand.app.game.data.alliance
{
   import com.dynamicflash.util.Base64;
   import thelaststand.app.core.Config;
   import thelaststand.app.game.data.effects.Effect;
   import thelaststand.app.network.Network;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   
   public class AllianceRound
   {
      
      private var _activeTime:Date;
      
      private var _endTime:Date;
      
      private var _number:int;
      
      private var _effects:Vector.<Effect>;
      
      private var _memberCount:int;
      
      public function AllianceRound()
      {
         super();
         this._effects = new Vector.<Effect>(int(Config.constant.ALLIANCE_EFFECT_BASE_COUNT) + 1,true);
      }
      
      public function get activeTime() : Date
      {
         return this._activeTime;
      }
      
      public function get endTime() : Date
      {
         return this._endTime;
      }
      
      public function get number() : int
      {
         return this._number;
      }
      
      public function get memberCount() : int
      {
         return this._memberCount;
      }
      
      public function get daysRemaining() : int
      {
         return int((this._endTime.time - Network.getInstance().serverTime) / 86400000);
      }
      
      public function getEffect(param1:int) : Effect
      {
         if(param1 < 0 || param1 >= this._effects.length)
         {
            return null;
         }
         return this._effects[param1];
      }
      
      public function getBonusEffect() : Effect
      {
         return this._effects[this._effects.length - 1];
      }
      
      internal function setMemberCount(param1:int) : void
      {
         this._memberCount = param1;
      }
      
      internal function setEffectSet(param1:Array) : void
      {
         var _loc3_:Effect = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._effects.length)
         {
            _loc3_ = new Effect();
            _loc3_.readObject(Base64.decodeToByteArray(param1[_loc2_]));
            this._effects[_loc2_] = _loc3_;
            _loc2_++;
         }
      }
      
      internal function deserialize(param1:Object) : void
      {
         if("roundNum" in param1)
         {
            this._number = int(param1.roundNum);
         }
         if("roundActive" in param1)
         {
            this._activeTime = new Date(param1.roundActive);
         }
         if("roundEnd" in param1)
         {
            this._endTime = new Date(param1.roundEnd);
         }
         if("roundEffects" in param1)
         {
            this.setEffectSet(JSON.parse(param1.roundEffects) as Array);
         }
         if("roundMembers" in param1)
         {
            this._memberCount = int(param1.roundMembers);
         }
      }
      
      public function calculateRoundData() : void
      {
         var _loc4_:Date = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc1_:Resource = ResourceManager.getInstance().getResource("xml/alliances.xml");
         if(_loc1_ == null)
         {
            return;
         }
         var _loc2_:XML = _loc1_.content as XML;
         var _loc3_:XML = AllianceSystem.getInstance().serviceNode;
         if(_loc3_ == null)
         {
            _loc4_ = new Date(2099,1,1);
            _loc5_ = 14;
            _loc6_ = 6;
         }
         else
         {
            _loc4_ = new Date(_loc3_.@zeroday.toString());
            _loc5_ = int(_loc3_.@days);
            _loc6_ = int(_loc3_.@gracehours);
         }
         var _loc7_:Number = Network.getInstance().serverTime;
         if(_loc7_ < _loc4_.time)
         {
            this._number = 0;
            this._endTime = _loc4_;
            this._activeTime = this._endTime;
            return;
         }
         var _loc8_:Number = (_loc7_ - _loc4_.time) / 1000 / 60 / 60 / 24;
         this._number = Math.floor(_loc8_ / _loc5_);
         var _loc9_:Date = new Date(_loc4_.time + this._number * _loc5_ * 24 * 60 * 60 * 1000);
         this._activeTime = new Date(_loc9_.time + _loc6_ * 60 * 60 * 1000);
         this._activeTime.minutes -= this._activeTime.timezoneOffset;
         this._endTime = new Date(_loc4_.time + (this._number + 1) * _loc5_ * 24 * 60 * 60 * 1000);
         this._endTime.minutes -= this._endTime.timezoneOffset;
         this._memberCount = 0;
      }
   }
}

