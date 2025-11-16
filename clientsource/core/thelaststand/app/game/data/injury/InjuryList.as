package thelaststand.app.game.data.injury
{
   import com.deadreckoned.threshold.display.Color;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.utils.DictionaryUtils;
   import thelaststand.common.resources.ResourceManager;
   
   public class InjuryList
   {
      
      private var _list:Vector.<Injury> = new Vector.<Injury>();
      
      private var _byId:Dictionary = new Dictionary(true);
      
      private var _survivor:Survivor;
      
      public var added:Signal = new Signal(Survivor,Injury);
      
      public var removed:Signal = new Signal(Survivor,Injury);
      
      public var changed:Signal = new Signal(Survivor);
      
      public function InjuryList(param1:Survivor)
      {
         super();
         this._survivor = param1;
      }
      
      public function get length() : int
      {
         return this._list.length;
      }
      
      public function addInjury(param1:Injury) : void
      {
         if(this._list.indexOf(param1) > -1)
         {
            return;
         }
         this._list.push(param1);
         this._byId[param1.id] = param1;
         param1.timerCompleted.addOnce(this.onTimerCompleted);
         this.added.dispatch(this._survivor,param1);
         this.changed.dispatch(this._survivor);
      }
      
      public function clear() : void
      {
         if(this._list.length <= 0)
         {
            return;
         }
         DictionaryUtils.clear(this._byId);
         this._list.length = 0;
         this.changed.dispatch(this._survivor);
      }
      
      public function getHealAllCost() : int
      {
         var inj:Injury = null;
         var xml:XML = ResourceManager.getInstance().getResource("xml/injury.xml").content;
         var cost:int = 0;
         for each(inj in this._list)
         {
            cost += int(xml.severity..severity.(@type == inj.severity).@cost);
         }
         return cost;
      }
      
      public function getTotalDamage() : Number
      {
         var _loc2_:Injury = null;
         var _loc1_:Number = 0;
         for each(_loc2_ in this._list)
         {
            _loc1_ += _loc2_.damage;
         }
         return _loc1_;
      }
      
      public function getTotalMorale() : Number
      {
         var _loc2_:Injury = null;
         var _loc1_:Number = 0;
         for each(_loc2_ in this._list)
         {
            _loc1_ += _loc2_.morale;
         }
         return _loc1_;
      }
      
      public function getTotalAttributeModifier(param1:String) : Number
      {
         var _loc3_:Injury = null;
         var _loc2_:Number = 0;
         for each(_loc3_ in this._list)
         {
            _loc2_ += _loc3_.getAttributeModifier(param1);
         }
         return _loc2_;
      }
      
      public function getTooltip() : String
      {
         var _loc3_:Injury = null;
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         while(_loc2_ < this._list.length)
         {
            _loc3_ = this._list[_loc2_];
            _loc1_.push("<b><font color=\'" + Color.colorToHex(InjurySeverity.getColor(_loc3_.severity)) + "\'>" + _loc3_.getName() + "</font></b>");
            _loc2_++;
         }
         return _loc1_.join("<br/>");
      }
      
      public function getInjury(param1:int) : Injury
      {
         return this._list[param1];
      }
      
      public function getInjuryById(param1:String) : Injury
      {
         return this._byId[param1];
      }
      
      public function removeInjury(param1:Injury) : void
      {
         var _loc2_:int = int(this._list.indexOf(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         this._list.splice(_loc2_,1);
         delete this._byId[param1.id];
         param1.timerCompleted.remove(this.onTimerCompleted);
         this.removed.dispatch(this._survivor,param1);
         this.changed.dispatch(this._survivor);
      }
      
      public function removeInjuryById(param1:String) : void
      {
         var _loc2_:Injury = this._byId[param1];
         if(_loc2_ == null)
         {
            return;
         }
         this.removeInjury(_loc2_);
      }
      
      public function readObject(param1:Object) : void
      {
         var _loc3_:Injury = null;
         if(!(param1 is Array))
         {
            return;
         }
         this._list.length = 0;
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            if(param1[_loc2_] != null)
            {
               _loc3_ = new Injury();
               _loc3_.readObject(param1[_loc2_]);
               _loc3_.timerCompleted.addOnce(this.onTimerCompleted);
               this._list.push(_loc3_);
               this._byId[_loc3_.id] = _loc3_;
            }
            _loc2_++;
         }
      }
      
      public function toVector() : Vector.<Injury>
      {
         return this._list.concat();
      }
      
      private function onTimerCompleted(param1:Injury) : void
      {
         this.removeInjury(param1);
      }
   }
}

