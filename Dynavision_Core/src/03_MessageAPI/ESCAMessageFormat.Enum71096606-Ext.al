enumextension 50301 DYN03MessageFormat extends "ESCA Message Format" // 71096606
{
    value(50300; "DYN Message API Push Example")
    {
        Caption = 'Message API Push Example';
        Implementation = "ESCA Message Format" = "DYN Message API Push Example", "ESCA Message API" = "DYN Message API Push Example";
    }
    value(50301; "DYN Message API Pull Example")
    {
        Caption = 'Message API Pull Example';
        Implementation = "ESCA Message Format" = "DYN Message API Pull Example", "ESCA Message API" = "DYN Message API Pull Example", "ESCA Message Request API" = "DYN Message API Pull Example";
    }
}