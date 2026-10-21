table 50300 "DYN Book"
{
    Access = Public;
    AllowInCustomizations = AsReadWrite;
    Caption = 'Book';
    DataClassification = SystemMetadata;
    DrillDownPageId = "DYN Book List";
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    LookupPageId = "DYN Book List";

    fields
    {
        field(1; ID; Integer)
        {
            AllowInCustomizations = AsReadOnly;
            AutoIncrement = true;
            Caption = 'ID';
            ToolTip = 'Specifies the ID of the book.';
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the name of the book.';
        }
        field(3; Publisher; Text[100])
        {
            Caption = 'Publisher';
            ToolTip = 'Specifies the publisher of the book.';
        }
        field(4; Author; Text[100])
        {
            Caption = 'Author';
            ToolTip = 'Specifies the author of the book.';
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; ID, Name, Author, Publisher) { }
        fieldgroup(Dropdown; ID, Name, Author, Publisher) { }
    }
}
