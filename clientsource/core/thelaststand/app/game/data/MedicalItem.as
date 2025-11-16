package thelaststand.app.game.data
{
   public class MedicalItem extends Item
   {
      
      protected var _medicalClass:String;
      
      protected var _medicalGrade:int;
      
      public function MedicalItem()
      {
         super();
      }
      
      public function get medicalClass() : String
      {
         return this._medicalClass;
      }
      
      public function get medicalGrade() : int
      {
         return this._medicalGrade;
      }
      
      override public function clone() : Item
      {
         var _loc1_:MedicalItem = new MedicalItem();
         cloneBaseProperties(_loc1_);
         _loc1_._medicalClass = this._medicalClass;
         _loc1_._medicalGrade = this._medicalGrade;
         return _loc1_;
      }
      
      override protected function setXML(param1:XML) : void
      {
         super.setXML(param1);
         this._medicalClass = param1.medical.cls.toString();
         this._medicalGrade = int(param1.medical.grade.toString());
      }
   }
}

