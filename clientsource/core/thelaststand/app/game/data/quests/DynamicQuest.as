package thelaststand.app.game.data.quests
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.StringUtils;
   import thelaststand.common.lang.Language;
   
   public class DynamicQuest extends Quest
   {
      
      private var _accepted:Boolean;
      
      private var _goals:Vector.<Object>;
      
      private var _rewards:Vector.<Object>;
      
      private var _failurePenalties:Vector.<Object>;
      
      private var _questType:int;
      
      public function DynamicQuest(param1:ByteArray)
      {
         super(null);
         _index = -1;
         _isAchievement = false;
         _important = false;
         _type = Quest.TYPE_DYNAMIC;
         _level = 0;
         _secretLevel = Quest.SECRET_NONE;
         this._goals = new Vector.<Object>();
         this._rewards = new Vector.<Object>();
         this._failurePenalties = new Vector.<Object>();
         _startImageURI = "images/quests/" + _type + "-start.jpg";
         _completeImageURI = "images/quests/" + _type + "-complete.jpg";
         if(param1 != null)
         {
            this.deserialize(param1);
         }
      }
      
      public function get questType() : int
      {
         return this._questType;
      }
      
      public function get accepted() : Boolean
      {
         return this._accepted;
      }
      
      public function set accepted(param1:Boolean) : void
      {
         this._accepted = param1;
      }
      
      override public function getGoalTotal(param1:int) : int
      {
         return int(this._goals[param1].goal);
      }
      
      override public function getAllGoalsTotal() : int
      {
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._goals)
         {
            _loc1_ += _loc2_.goal;
         }
         return _loc1_;
      }
      
      override public function getXPReward() : int
      {
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._rewards)
         {
            if(_loc2_.type == "xp")
            {
               _loc1_ += int(_loc2_.value);
            }
         }
         return _loc1_;
      }
      
      public function getMoraleReward() : Number
      {
         var _loc2_:Object = null;
         var _loc1_:Number = 0;
         for each(_loc2_ in this._rewards)
         {
            if(_loc2_.type == "morale")
            {
               _loc1_ += Number(_loc2_.value);
            }
         }
         return _loc1_;
      }
      
      override public function getItemResourceGoals() : Array
      {
         return [];
      }
      
      public function getGoalOfType(param1:String) : Object
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._goals.length)
         {
            if(this._goals[_loc2_].type == param1)
            {
               return this._goals[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      override public function getNonItemResourceGoals() : Array
      {
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:Survivor = null;
         var _loc1_:Language = Language.getInstance();
         var _loc2_:Array = [];
         var _loc3_:int = 0;
         while(_loc3_ < this._goals.length)
         {
            _loc4_ = this._goals[_loc3_];
            _loc5_ = "";
            switch(_loc4_.type)
            {
               case "statInc":
                  _loc5_ = _loc1_.getString("stat." + _loc4_.stat.toString());
                  break;
               case "xpInc":
                  _loc8_ = Network.getInstance().playerData.compound.survivors.getSurvivorById(_loc4_.survivor);
                  _loc5_ = _loc8_.fullName;
            }
            _loc6_ = _loc1_.getString("quests_goal." + _loc4_.type,_loc5_);
            _loc7_ = _conditionProgress[_loc3_];
            _loc2_.push({
               "data":_loc4_,
               "name":_loc6_,
               "prog":_loc7_,
               "total":_loc4_.goal
            });
            _loc3_++;
         }
         return _loc2_;
      }
      
      override public function getRewards() : Array
      {
         var _loc4_:Object = null;
         var _loc1_:int = 0;
         var _loc2_:Number = 0;
         var _loc3_:Array = [];
         for each(_loc4_ in this._rewards)
         {
            switch(_loc4_.type)
            {
               case "itm":
                  _loc3_.push(_loc4_.value as Item);
                  break;
               case "res":
                  throw new Error("Not implemented.");
               case "xp":
                  _loc1_ += int(_loc4_.value);
                  break;
               case "morale":
                  _loc2_ += Number(_loc4_.value);
            }
         }
         if(_loc1_ > 0)
         {
            _loc3_.push({
               "type":"xp",
               "value":_loc1_
            });
         }
         if(_loc2_ > 0)
         {
            _loc3_.push({
               "type":"morale",
               "value":_loc2_
            });
         }
         return _loc3_;
      }
      
      public function getFailurePenalties() : Array
      {
         var _loc3_:Object = null;
         var _loc1_:Number = 0;
         var _loc2_:Array = [];
         for each(_loc3_ in this._failurePenalties)
         {
            switch(_loc3_.type)
            {
               case "morale":
                  _loc1_ += Number(_loc3_.value);
            }
         }
         if(_loc1_ != 0)
         {
            _loc2_.push({
               "type":"morale",
               "value":_loc1_
            });
         }
         return _loc2_;
      }
      
      override public function getDescription() : String
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Survivor = null;
         var _loc1_:String = "";
         for each(_loc2_ in this._goals)
         {
            switch(this._questType)
            {
               case DynamicQuestType.SURVIVOR_REQUEST:
                  _loc3_ = "srv_request_quests";
            }
            switch(_loc2_.type)
            {
               case "statInc":
                  _loc1_ += Language.getInstance().getString(_loc3_ + "." + _loc2_.stat + "_desc",NumberFormatter.format(_loc2_.goal,0)) + "<br/>";
                  break;
               case "xpInc":
                  _loc5_ = Network.getInstance().playerData.compound.survivors.getSurvivorById(_loc2_.survivor);
                  _loc1_ += Language.getInstance().getString(_loc3_ + ".xpIncrease_desc",_loc5_.fullName,_loc5_.firstName) + "<br/>";
            }
         }
         return StringUtils.removeTrailingBreaks(_loc1_);
      }
      
      override public function getShortDescription() : String
      {
         return "";
      }
      
      override public function getName() : String
      {
         switch(this._questType)
         {
            case DynamicQuestType.SURVIVOR_REQUEST:
               return Language.getInstance().getString("srv_request_quests.name");
            default:
               return "?";
         }
      }
      
      public function deserialize(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         param1.endian = Endian.LITTLE_ENDIAN;
         param1.position = 0;
         var _loc4_:ByteArray = new ByteArray();
         _loc4_.endian = Endian.LITTLE_ENDIAN;
         var _loc5_:int = param1.readShort();
         this._questType = param1.readShort();
         _id = param1.readUTF();
         this._accepted = param1.readBoolean();
         _complete = param1.readBoolean();
         _collected = param1.readBoolean();
         _failed = param1.readBoolean();
         _endTime = new Date(param1.readDouble());
         _type = Quest.TYPE_DYNAMIC;
         _new = !this._accepted;
         var _loc6_:int = int(param1.readUnsignedShort());
         _conditionProgress.length = _loc6_;
         this._goals.length = _loc6_;
         _loc2_ = 0;
         while(_loc2_ < _loc6_)
         {
            _loc3_ = int(param1.readUnsignedShort());
            param1.readBytes(_loc4_,0,_loc3_);
            _loc4_.position = 0;
            _loc9_ = _loc4_.readUTF();
            switch(_loc9_)
            {
               case "statInc":
                  this._goals[_loc2_] = {
                     "type":_loc9_,
                     "stat":_loc4_.readUTF(),
                     "goal":_loc4_.readInt()
                  };
                  break;
               case "xpInc":
                  this._goals[_loc2_] = {
                     "type":_loc9_,
                     "survivor":_loc4_.readUTF(),
                     "goal":_loc4_.readInt()
                  };
            }
            _loc2_++;
         }
         var _loc7_:int = int(param1.readUnsignedShort());
         this._rewards.length = _loc7_;
         _loc2_ = 0;
         while(_loc2_ < _loc7_)
         {
            _loc3_ = int(param1.readUnsignedShort());
            param1.readBytes(_loc4_,0,_loc3_);
            _loc4_.position = 0;
            _loc10_ = _loc4_.readShort();
            switch(_loc10_)
            {
               case 0:
                  this._rewards[_loc2_] = {
                     "type":"xp",
                     "value":_loc4_.readInt()
                  };
                  break;
               case 3:
                  this._rewards[_loc2_] = {
                     "type":"itm",
                     "value":ItemFactory.createItemFromXML(new XML(_loc4_.readUTF()))
                  };
                  break;
               case 4:
                  this._rewards[_loc2_] = {
                     "type":"morale",
                     "moraleType":_loc4_.readUTF(),
                     "value":_loc4_.readDouble()
                  };
            }
            _loc2_++;
         }
         var _loc8_:int = int(param1.readUnsignedShort());
         this._failurePenalties.length = _loc8_;
         _loc2_ = 0;
         while(_loc2_ < _loc8_)
         {
            _loc3_ = int(param1.readUnsignedShort());
            param1.readBytes(_loc4_,0,_loc3_);
            _loc4_.position = 0;
            _loc11_ = _loc4_.readShort();
            switch(_loc11_)
            {
               case 2:
                  this._failurePenalties[_loc2_] = {
                     "type":"morale",
                     "moraleType":_loc4_.readUTF(),
                     "value":_loc4_.readDouble()
                  };
            }
            _loc2_++;
         }
         if(_loc5_ > 1)
         {
            _loc12_ = param1.readInt();
         }
         _started = true;
         if(_complete)
         {
            this.completeConditions();
         }
      }
      
      override protected function completeConditions() : void
      {
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         while(_loc1_ < this._goals.length)
         {
            _loc2_ = this._goals[_loc1_];
            _conditionProgress[_loc1_] = _loc2_.goal;
            _loc1_++;
         }
      }
   }
}

