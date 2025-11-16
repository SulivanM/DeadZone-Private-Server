package thelaststand.app.game.data.research
{
   import com.exileetiquette.math.MathUtils;
   import thelaststand.common.resources.ResourceManager;
   
   public class ResearchTask
   {
      
      private var _id:String;
      
      private var _startTime:Date;
      
      private var _duration:int;
      
      private var _category:String;
      
      private var _group:String;
      
      private var _level:int;
      
      private var _xmlGroup:XML;
      
      private var _xmlLevel:XML;
      
      private var _completed:Boolean;
      
      public function ResearchTask()
      {
         super();
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get isCompleted() : Boolean
      {
         return this._completed;
      }
      
      public function get level() : int
      {
         return this._level;
      }
      
      public function get duration() : int
      {
         return this._duration;
      }
      
      public function get startTime() : Date
      {
         return this._startTime;
      }
      
      public function get category() : String
      {
         return this._category;
      }
      
      public function get group() : String
      {
         return this._group;
      }
      
      public function get timeReamining() : int
      {
         return this.getTimeRemaining();
      }
      
      public function get progress() : Number
      {
         return this._completed ? 1 : MathUtils.clamp((this._duration - this.getTimeRemaining()) / this._duration,0,1);
      }
      
      public function get xmlGroup() : XML
      {
         return this._xmlGroup;
      }
      
      public function get xmlLevel() : XML
      {
         return this._xmlLevel;
      }
      
      public function parse(param1:Object) : void
      {
         if(param1.start is Date)
         {
            this._startTime = param1.start as Date;
         }
         else
         {
            this._startTime = new Date(param1.start);
            this._startTime.minutes -= this._startTime.getTimezoneOffset();
         }
         this._id = String(param1.id);
         this._duration = int(param1.length);
         this._category = String(param1.category);
         this._group = String(param1.group);
         this._level = int(param1.level);
         this._completed = Boolean(param1.completed);
         this.updateXMLNodes();
      }
      
      private function getTimeRemaining() : int
      {
         var _loc1_:Date = new Date();
         var _loc2_:int = (_loc1_.time - this._startTime.time) / 1000;
         return Math.max(this._duration - _loc2_,0);
      }
      
      private function updateXMLNodes() : void
      {
         var xml:XML = XML(ResourceManager.getInstance().get("xml/research.xml"));
         if(xml == null)
         {
            return;
         }
         this._xmlGroup = xml.research.(@id == _category).group.(@id == _group)[0];
         this._xmlLevel = this._xmlGroup.level.(@n == this._level.toString())[0];
      }
   }
}

