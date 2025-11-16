package thelaststand.app.game.data.skills
{
   import com.exileetiquette.math.MathUtils;
   import org.osflash.signals.Signal;
   
   public class SkillState
   {
      
      private var _id:String;
      
      private var _xp:int;
      
      private var _level:int;
      
      private var _maxLevel:int;
      
      private var _xml:XML;
      
      public var changed:Signal = new Signal(SkillState,int,int);
      
      public function SkillState(param1:XML)
      {
         super();
         this._xml = param1;
         this._id = param1.@id.toString();
         this._maxLevel = param1.lvl.length() - 1;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get xp() : int
      {
         return this._xp;
      }
      
      public function get level() : int
      {
         return this._level;
      }
      
      public function get maxLevel() : int
      {
         return this._maxLevel;
      }
      
      public function get isAtMaxLevel() : Boolean
      {
         return this._level >= this._maxLevel;
      }
      
      public function get levelProgress() : Number
      {
         if(this._level < 0)
         {
            return 0;
         }
         if(this._level >= this._maxLevel)
         {
            return 1;
         }
         return this._xp / this.getXpForLevel(this._level + 1);
      }
      
      public function getXpForLevel(param1:int) : Number
      {
         param1 = MathUtils.clamp(param1,0,this._maxLevel);
         return int(this._xml.lvl[param1].@xp);
      }
      
      public function read(param1:Object) : void
      {
         this._xp = int(param1.xp);
         this._level = int(param1.level);
      }
      
      public function append(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:int = int(param1.xp);
         var _loc3_:int = int(param1.level);
         var _loc4_:int = int(param1.xpGained);
         var _loc5_:int = int(param1.levelsGained);
         if(_loc2_ != this.xp || _loc3_ != this.level)
         {
            this._xp = _loc2_;
            this._level = _loc3_;
            this.changed.dispatch(this,_loc4_,_loc5_);
         }
      }
      
      public function getLevelValue(param1:int, param2:String) : int
      {
         var _loc3_:String = this._xml.lvl[param1][param2][0];
         return int(_loc3_);
      }
   }
}

