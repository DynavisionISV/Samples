table 50501 "DYN Quotation Buffer Property"
{
    Access = Public;
    Caption = 'Quotation Buffer Property', Locked = true;
    DataClassification = CustomerContent;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;

    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Id', Locked = true;
        }
        field(2; Name; Text[250])
        {
            Caption = 'Name', Locked = true;
        }
        field(3; Type; Enum "ESCZ Property Type")
        {
            Caption = 'Type', Locked = true;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }
}