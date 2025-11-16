package thelaststand.app.game.data.skills
{
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.common.resources.ResourceManager;
   
   public class SkillCollection
   {
      
      private var _skillsById:Dictionary;
      
      public var skillChanged:Signal;
      
      public function SkillCollection()
      {
         var _loc2_:XML = null;
         var _loc3_:SkillState = null;
         this._skillsById = new Dictionary(true);
         this.skillChanged = new Signal(SkillState,int,int);
         super();
         var _loc1_:XML = ResourceManager.getInstance().get("xml/skills.xml");
         for each(_loc2_ in _loc1_.skill)
         {
            _loc3_ = new SkillState(_loc2_);
            _loc3_.changed.add(this.onSkillChanged);
            this._skillsById[_loc3_.id] = _loc3_;
         }
      }
      
      public function getSkill(param1:String) : SkillState
      {
         return this._skillsById[param1];
      }
      
      public function append(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:SkillState = null;
         if(param1 == null)
         {
            return;
         }
         for(_loc2_ in param1)
         {
            _loc3_ = this._skillsById[_loc2_];
            if(_loc3_ != null)
            {
               _loc3_.append(param1[_loc2_]);
            }
         }
      }
      
      public function read(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:SkillState = null;
         if(param1 == null)
         {
            return;
         }
         for(_loc2_ in param1)
         {
            _loc3_ = this._skillsById[_loc2_];
            if(_loc3_ != null)
            {
               _loc3_.read(param1[_loc2_]);
            }
         }
      }
      
      private function onSkillChanged(param1:SkillState, param2:int, param3:int) : void
      {
         this.skillChanged.dispatch(param1,param2,param3);
      }
   }
}

