package alternativa.engine3d.materials.compiler
{
   public class CommandType
   {
      
      public static const MOV:uint = 0;
      
      public static const ADD:uint = 1;
      
      public static const SUB:uint = 2;
      
      public static const MUL:uint = 3;
      
      public static const DIV:uint = 4;
      
      public static const RCP:uint = 5;
      
      public static const MIN:uint = 6;
      
      public static const MAX:uint = 7;
      
      public static const FRC:uint = 8;
      
      public static const SQT:uint = 9;
      
      public static const RSQ:uint = 10;
      
      public static const POW:uint = 11;
      
      public static const LOG:uint = 12;
      
      public static const EXP:uint = 13;
      
      public static const NRM:uint = 14;
      
      public static const SIN:uint = 15;
      
      public static const COS:uint = 16;
      
      public static const CRS:uint = 17;
      
      public static const DP3:uint = 18;
      
      public static const DP4:uint = 19;
      
      public static const ABS:uint = 20;
      
      public static const NEG:uint = 21;
      
      public static const SAT:uint = 22;
      
      public static const M33:uint = 23;
      
      public static const M44:uint = 24;
      
      public static const M34:uint = 25;
      
      public static const DDX:uint = 26;
      
      public static const DDY:uint = 27;
      
      public static const IFE:uint = 28;
      
      public static const INE:uint = 29;
      
      public static const IFG:uint = 30;
      
      public static const IFL:uint = 31;
      
      public static const ELS:uint = 32;
      
      public static const EIF:uint = 33;
      
      public static const TED:uint = 38;
      
      public static const KIL:uint = 39;
      
      public static const TEX:uint = 40;
      
      public static const SGE:uint = 41;
      
      public static const SLT:uint = 42;
      
      public static const SGN:uint = 43;
      
      public static const SEQ:uint = 44;
      
      public static const SNE:uint = 45;
      
      public static const COMMAND_NAMES:Array = [];
      
      COMMAND_NAMES[MOV] = "mov";
      COMMAND_NAMES[ADD] = "add";
      COMMAND_NAMES[SUB] = "sub";
      COMMAND_NAMES[MUL] = "mul";
      COMMAND_NAMES[DIV] = "div";
      COMMAND_NAMES[RCP] = "rcp";
      COMMAND_NAMES[MIN] = "min";
      COMMAND_NAMES[MAX] = "max";
      COMMAND_NAMES[FRC] = "frc";
      COMMAND_NAMES[SQT] = "sqt";
      COMMAND_NAMES[RSQ] = "rsq";
      COMMAND_NAMES[POW] = "pow";
      COMMAND_NAMES[LOG] = "log";
      COMMAND_NAMES[EXP] = "exp";
      COMMAND_NAMES[NRM] = "nrm";
      COMMAND_NAMES[SIN] = "sin";
      COMMAND_NAMES[COS] = "cos";
      COMMAND_NAMES[CRS] = "crs";
      COMMAND_NAMES[DP3] = "dp3";
      COMMAND_NAMES[DP4] = "dp4";
      COMMAND_NAMES[ABS] = "abs";
      COMMAND_NAMES[NEG] = "neg";
      COMMAND_NAMES[SAT] = "sat";
      COMMAND_NAMES[M33] = "m33";
      COMMAND_NAMES[M44] = "m44";
      COMMAND_NAMES[M34] = "m34";
      COMMAND_NAMES[DDX] = "ddx";
      COMMAND_NAMES[DDY] = "ddy";
      COMMAND_NAMES[IFE] = "ife";
      COMMAND_NAMES[INE] = "ine";
      COMMAND_NAMES[IFG] = "ifg";
      COMMAND_NAMES[IFL] = "ifl";
      COMMAND_NAMES[ELS] = "els";
      COMMAND_NAMES[EIF] = "eif";
      COMMAND_NAMES[TED] = "ted";
      COMMAND_NAMES[KIL] = "kil";
      COMMAND_NAMES[TEX] = "tex";
      COMMAND_NAMES[SGE] = "sge";
      COMMAND_NAMES[SLT] = "slt";
      COMMAND_NAMES[SGN] = "sgn";
      COMMAND_NAMES[SEQ] = "seq";
      COMMAND_NAMES[SNE] = "sne";
      
      public function CommandType()
      {
         super();
      }
   }
}

