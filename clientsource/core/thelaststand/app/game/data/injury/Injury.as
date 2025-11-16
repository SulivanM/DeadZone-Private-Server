package thelaststand.app.game.data.injury
{
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.logic.TimerManager;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class Injury
   {
      
      private var _id:String;
      
      private var _type:String;
      
      private var _damage:Number = 0;
      
      private var _morale:Number = 0;
      
      private var _location:String;
      
      private var _severity:String;
      
      private var _severityGroup:String;
      
      private var _name:String;
      
      private var _effects:Dictionary;
      
      private var _effectAttributes:Array;
      
      private var _reqItem:Dictionary;
      
      private var _timer:TimerData;
      
      public var timerCompleted:Signal = new Signal(Injury);
      
      public function Injury()
      {
         super();
         this._effects = new Dictionary(true);
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function get location() : String
      {
         return this._location;
      }
      
      public function get severity() : String
      {
         return this._severity;
      }
      
      public function get severityGroup() : String
      {
         return this._severityGroup;
      }
      
      public function get damage() : Number
      {
         return this._damage;
      }
      
      public function get morale() : Number
      {
         return this._morale;
      }
      
      public function get timer() : TimerData
      {
         return this._timer;
      }
      
      public function getName() : String
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(this._name == null)
         {
            _loc1_ = Language.getInstance().getString("injury_sev." + this._severity);
            _loc2_ = Language.getInstance().getString("injury_loc." + this._location);
            _loc3_ = Language.getInstance().getString("injury_type." + this._type);
            this._name = _loc1_ + " " + _loc2_ + " " + _loc3_;
         }
         return this._name;
      }
      
      public function getAttributes() : Array
      {
         var _loc1_:String = null;
         if(this._effectAttributes == null)
         {
            this._effectAttributes = [];
            for(_loc1_ in this._effects)
            {
               this._effectAttributes.push(_loc1_);
            }
         }
         return this._effectAttributes;
      }
      
      public function getAttributeModifier(param1:String) : Number
      {
         var _loc2_:Number = Number(this._effects[param1]);
         return isNaN(_loc2_) ? 0 : _loc2_ - 1;
      }
      
      public function getXML() : XML
      {
         var xml:XML = null;
         var node:XML = null;
         xml = ResourceManager.getInstance().getResource("xml/injury.xml").content;
         node = xml.injury.(@type == _type).loc.(@id == _location).sev.(@type == _severity)[0];
         return node;
      }
      
      public function readObject(param1:Object) : void
      {
         var injXML:XML;
         var xml:XML = null;
         var node:XML = null;
         var data:Object = param1;
         this._id = data.id;
         this._type = data.type;
         this._location = data.location;
         this._severity = data.severity;
         this._damage = data.damage;
         this._morale = data.morale;
         if(data.timer != null)
         {
            this._timer = new TimerData(null,0,this);
            this._timer.readObject(data.timer);
            if(!this._timer.hasEnded())
            {
               this._timer.completed.addOnce(this.onTimerCompleted);
               TimerManager.getInstance().addTimer(this._timer);
            }
            else
            {
               this._timer.dispose();
            }
         }
         injXML = ResourceManager.getInstance().getResource("xml/injury.xml").content;
         this._severityGroup = injXML.severity..severity.(@type == _severity)[0].parent().localName();
         xml = this.getXML();
         if(xml == null)
         {
            throw new Error("Invalid injury type: " + data.type + " " + data.location + " " + data.severity);
         }
         for each(node in xml.children())
         {
            if(node.localName() != "recipe")
            {
               this._effects[node.localName()] = Number(node.toString());
            }
         }
      }
      
      private function onTimerCompleted(param1:TimerData) : void
      {
         this.timerCompleted.dispatch(this);
      }
   }
}

