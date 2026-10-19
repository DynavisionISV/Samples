codeunit 50302 "DYN Message API Pull Example" implements "ESCA Message Format", "ESCA Message API", "ESCA Message Request API"
{
    Access = Internal;
    SingleInstance = true;

    // Message Format

    procedure GetDefaultMessageTypeCode(): Code[30]
    var
        CodeLbl: Label 'Message API Pull Example', MaxLength = 30;
    begin
        exit(CodeLbl);
    end;

    procedure ApplyDefaultMessageTypeSettings(var MessageType: Record "ESCA Message Type")
    var
        DescriptionLbl: Label 'Message API Pull Example', MaxLength = 100;
    begin
        MessageType.Validate(Description, DescriptionLbl);
        MessageType.Validate("Message Type", MessageType."Message Type"::"DYN Message API Pull Example");
        MessageType.Validate(Direction, MessageType.Direction::Both);
        MessageType.Validate("Communication Method", MessageType."Communication Method"::API);
        MessageType.Validate("Auto Process", true);
    end;

    procedure SupportsFormatFields(): Boolean
    begin
        exit(false);
    end;

#pragma warning disable AA0150
    procedure GetMessageContent(Message: Record "ESCA Message"; var Source: Variant; Operation: Enum "ESCA Operation"; var TempBlob: Codeunit "Temp Blob"; var DocumentNo: Code[20])
#pragma warning restore AA0150
    begin
        // Not supported
    end;

    procedure ProcessIncomingMessage(var Message: Record "ESCA Message")
    var
        Item: Record Item;
        JsonTools: Codeunit "DYN Json Tools";
        PageManagement: Codeunit "Page Management";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        RecObject: JsonObject;
        ItemCouldNotBeRetrievedErr: Label 'Item with no. %1 could not be retrieved';
    begin
        if not Message.GetAPIResponseFromAttachment(TempBlob, InStr) then
            Error(ItemCouldNotBeRetrievedErr, ExistingItemNo);

        RecObject.ReadFrom(InStr);

        Item := JsonTools.Json2Rec(RecObject, Database::Item);
        Item.Validate("No.", NewItemNo);
        Item.Insert(true);

        Page.Run(PageManagement.GetPageID(Item), Item);
    end;

    // Message API

    procedure SupportsMessageAPI(): Boolean
    begin
        exit(true);
    end;

    // Message Request API

    procedure SupportsMessageRequestAPI(): Boolean;
    begin
        exit(true);
    end;

    procedure ProcessIncomingRequest(Request: Codeunit "Temp Blob"; var Response: Codeunit "Temp Blob");
    var
        Item: Record Item;
        TempItem: Record Item temporary;
        JsonTools: Codeunit "DYN Json Tools";
        InStr: InStream;
        RequestJObject, ResponseJObject : JsonObject;
        ItemNoToken: JsonToken;
    begin
        Request.CreateInStream(InStr);
        RequestJObject.ReadFrom(InStr);
        RequestJObject.Get(ItemNoTok, ItemNoToken);
        Item.Get(CopyStr(ItemNoToken.AsValue().AsCode(), 1, 20));

        // Create a temp item to avoid the need of retrieving additional data in this example
        TempItem."No." := Item."No.";
        TempItem.Description := Item.Description;
        TempItem."Description 2" := Item."Description 2";
        TempItem."Search Description" := Item."Search Description";
        TempItem."Unit Price" := Item."Unit Price";
        TempItem."Unit Cost" := Item."Unit Cost";
        TempItem.Insert();

        ResponseJObject := JsonTools.Rec2Json(TempItem);
        ReadJsonObjectIntoTempBlob(ResponseJObject, Response);
    end;

    // Other
    internal procedure ImportItem()
    var
        MessageType: Record "ESCA Message Type";
        GetItemNoInfo: Page "DYN Get Item No. Info";
    begin
        MessageType := GetMessageType();
        GetItemNoInfo.AskItemInfo(ExistingItemNo, NewItemNo);
        MessageType.ImportData(GetItemRequestContent(ExistingItemNo), false);
    end;

    // Locals
    local procedure GetItemRequestContent(ItemNo: Code[20]) Content: Codeunit "Temp Blob"
    var
        RequestJObject: JsonObject;
        OutStr: OutStream;
    begin
        RequestJObject.Add(ItemNoTok, ItemNo);
        Content.CreateOutStream(OutStr);
        RequestJObject.WriteTo(OutStr);
    end;

    local procedure GetMessageType() MessageType: Record "ESCA Message Type";
    begin
        MessageType.Reset();
        MessageType.SetRange("Message Type", MessageType."Message Type"::"DYN Message API Pull Example");
        MessageType.SetRange("Message Format", MessageType."Message Format"::"DYN Message API Pull Example");
        MessageType.FindFirst();
    end;

    internal procedure ReadJsonObjectIntoTempBlob(JsonObjectToProcess: JsonObject; var TempBlob: Codeunit "Temp Blob")
    var
        OutStream: OutStream;
        JSONText: Text;
    begin
        JsonObjectToProcess.WriteTo(JSONText);
        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText(JSONText);
    end;

    var
        ExistingItemNo, NewItemNo : Code[20];
        ItemNoTok: Label 'itemNo', Locked = true;
}
