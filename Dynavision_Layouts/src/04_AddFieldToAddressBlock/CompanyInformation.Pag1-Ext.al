pageextension 50001 DYN04CompanyInformation extends "Company Information" // 1
{
    layout
    {
        addlast(General)
        {
            field("DYN RPR"; Rec."DYN RPR")
            {
                ApplicationArea = All;
            }
        }
    }
}