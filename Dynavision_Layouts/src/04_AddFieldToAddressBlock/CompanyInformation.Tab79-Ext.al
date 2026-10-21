tableextension 50004 DYN04CompanyInformation extends "Company Information" // 79
{
    fields
    {
        field(50000; "DYN RPR"; Text[150])
        {
            AllowInCustomizations = AsReadWrite;
            Caption = 'RPR';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the value of the RPR field.';
        }
    }
}