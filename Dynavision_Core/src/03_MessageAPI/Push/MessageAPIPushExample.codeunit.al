codeunit 50304 "DYN Message API Push Example" implements "ESCA Message Format", "ESCA Message API"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    // Message Format

    procedure GetDefaultMessageTypeCode(): Code[30]
    var
        CodeLbl: Label 'Message API Push Example', MaxLength = 30;
    begin
        exit(CodeLbl);
    end;

    procedure ApplyDefaultMessageTypeSettings(var MessageType: Record "ESCA Message Type")
    var
        DescriptionLbl: Label 'Message API Push Example', MaxLength = 100;
    begin
        MessageType.Validate(Description, DescriptionLbl);
        MessageType.Validate("Message Type", MessageType."Message Type"::"DYN Message API Push Example");
        MessageType.Validate(Direction, MessageType.Direction::Both);
        MessageType.Validate("Communication Method", MessageType."Communication Method"::API);
        MessageType.Validate("Auto Process", true);
    end;

    procedure SupportsFormatFields(): Boolean
    begin
        exit(false);
    end;

    procedure GetMessageContent(Message: Record "ESCA Message"; var Source: Variant; Operation: Enum "ESCA Operation"; var TempBlob: Codeunit "Temp Blob"; var DocumentNo: Code[20])
    var
        DataTypeManagement: Codeunit "Data Type Management";
        JsonTools: Codeunit "DYN Json Tools";
        RecRef: RecordRef;
        OutStr: OutStream;
    begin
        if not DataTypeManagement.GetRecordRef(Source, RecRef) then exit;

        TempBlob.CreateOutStream(OutStr);
        JsonTools.Rec2Json(Source).WriteTo(OutStr);
        DocumentNo := '';
    end;

    procedure ProcessIncomingMessage(var Message: Record "ESCA Message")
    var
        MessageAPITest: Record "DYN Message API Test";
        JsonTools: Codeunit "DYN Json Tools";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        RecObject: JsonObject;
    begin
        if not Message.GetAttachmentAsStream(TempBlob, InStr) then exit;

        RecObject.ReadFrom(InStr);

        MessageAPITest := JsonTools.Json2Rec(RecObject, Database::"DYN Message API Test");
        MessageAPITest.Validate(Direction, MessageAPITest.Direction::Incoming);
        MessageAPITest.Validate("Original ID", MessageAPITest.ID);
        MessageAPITest.Validate(ID, CreateGuid());
        MessageAPITest.Insert(true);
    end;

    // Message API

    procedure SupportsMessageAPI(): Boolean
    begin
        exit(true);
    end;
}
