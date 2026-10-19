table 50301 "DYN Message API Test"
{
    Access = Internal;
    Caption = 'Message API Test';
    DataClassification = SystemMetadata;
    DrillDownPageId = "DYN Message API Push Example";
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    LookupPageId = "DYN Message API Push Example";

    fields
    {
        field(1; ID; Guid)
        {
            Caption = 'ID';
            ToolTip = 'Specifies the value of the ID field.';
        }
        field(2; "AAD Tenant ID"; Guid)
        {
            Caption = 'AAD Tenant ID';
            ToolTip = 'Specifies the value of the AAD Tenant ID field.';
        }
        field(3; "Environment Name"; Text[250])
        {
            Caption = 'Environment Name';
            ToolTip = 'Specifies the value of the Environment Name field.';
        }
        field(4; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            ToolTip = 'Specifies the value of the Company Name field.';
        }
        field(5; Direction; Enum "DYN Message Direction")
        {
            Caption = 'Direction';
            ToolTip = 'Specifies the value of the Direction field.';
        }
        field(6; "Message Entry No."; Integer)
        {
            Caption = 'Message Entry No.';
            TableRelation = "ESCA Message"."Entry No.";
        }
        field(7; "Error"; Boolean)
        {
            Caption = 'Error';
            ToolTip = 'Specifies the value of the Error field.';
        }
        field(8; "Error Message"; Text[2048])
        {
            Caption = 'Error Message';
            ToolTip = 'Specifies the value of the Error Message field.';
        }
        field(9; "Original ID"; Guid)
        {
            Caption = 'Original ID';
            ToolTip = 'Specifies the value of the Original ID field.';
        }
    }
    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }

    // Internals
    internal procedure CreateAndSendMessage()
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        Init();
        Validate(ID, CreateGuid());
        Validate("AAD Tenant ID", AzureADTenant.GetAadTenantId());
        Validate("Environment Name", CopyStr(EnvironmentInformation.GetEnvironmentName(), 1, MaxStrLen("Environment Name")));
        Validate("Company Name", CopyStr(CompanyName(), 1, MaxStrLen("Company Name")));
        Validate(Direction, "DYN Message Direction"::Outgoing);
        Insert(true);
        if not TrySendMessage(Rec, "ESCA Message Type"::"DYN Message API Push Example", "Message Entry No.") then begin
            Validate(Error, true);
            Validate("Error Message", CopyStr(GetLastErrorText(), 1, MaxStrLen("Error Message")));
        end;
        Modify(true);
    end;

    // Locals
    [TryFunction]
    local procedure TrySendMessage(NewSource: Variant; NewMessageType: Enum "ESCA Message Type"; var MessageEntryNo: Integer)
    var
        Message: Codeunit "ESCA Message";
    begin
        MessageEntryNo := Message.Send(NewSource, NewMessageType)
    end;
}