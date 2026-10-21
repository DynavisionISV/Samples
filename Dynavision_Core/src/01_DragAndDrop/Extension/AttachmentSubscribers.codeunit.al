codeunit 50301 "DYN Attachment Subscribers"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    #region EventSubscriber Codeunit "ESCA Create Document Structure" OnAfterCreateStandardDocumentStructures
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ESCA Create Document Structure", OnAfterCreateStandardDocumentStructures, '', true, true)]
    local procedure CreateDocumentStructure_OnAfterCreateStandardDocumentStructures()
    var
        DocumentStructure: Record "ESCA Document Structure";
    begin
        // Generates a basic document structure to store attachment in a structured way on the external storage location   
        DocumentStructure.CreateSimpleDocStructure(Database::"DYN Book");
    end;
    #endregion EventSubscriber Codeunit "ESCA Create Document Structure" OnAfterCreateStandardDocumentStructures

    #region EventSubscriber Codeunit "Document Attachment Mgmt" OnAfterGetRefTable
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Attachment Mgmt", OnAfterGetRefTable, '', false, false)]
    local procedure OnAfterGetRefTable(var RecRef: RecordRef; DocumentAttachment: Record "Document Attachment")
    var
        Book: Record "DYN Book";
    begin
        if DocumentAttachment."Table ID" = Database::"DYN Book" then begin
            RecRef.Open(Database::"DYN Book");
            if Book.GetBySystemId(DocumentAttachment."ESCA Source System ID") then
                RecRef.GetTable(Book);
        end;
    end;
    #endregion EventSubscriber Codeunit "Document Attachment Mgmt" OnAfterGetRefTable

    #region EventSubscriber Codeunit "Document Attachment Mgmt" OnAfterSetDocumentAttachmentFiltersForRecRef
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Attachment Mgmt", OnAfterSetDocumentAttachmentFiltersForRecRef, '', false, false)]
    local procedure OnAfterSetDocumentAttachmentFiltersForRecRef(var DocumentAttachment: Record "Document Attachment"; RecRef: RecordRef)
    begin
        // Due to the nature of the 'Document Attachment' table design, it is not always possible to link attachments by Document Type, Line No. and/or No.
        // For the 'Book' table, we can use 'Line No.'
        // For tables with composite primary keys, we can maintain a surrogate key, either the 'SystemId' can be used
        // In this example, we link the document attachments to the 'Book' table using the 'SystemId' instead. 
        if RecRef.Number in [Database::"DYN Book"] then
            DocumentAttachment.SetRange("ESCA Source System ID", RecRef.Field(RecRef.SystemIdNo).Value);
    end;
    #endregion EventSubscriber Codeunit "Document Attachment Mgmt" OnAfterSetDocumentAttachmentFiltersForRecRef

    #region EventSubscriber Table "ESC Book" OnAfterDeleteEvent
    [EventSubscriber(ObjectType::Table, Database::"DYN Book", OnAfterDeleteEvent, '', false, false)]
    local procedure DeleteAttachedDocumentsOnAfterDeleteBook(var Rec: Record "DYN Book"; RunTrigger: Boolean)
    var
        DocumentAttachmentMgmt: Codeunit "Document Attachment Mgmt";
        RecRef: RecordRef;
    begin
        // Delete attachment when the parent record is deleted
        if Rec.IsTemporary then
            exit;

        RecRef.GetTable(Rec);
        DocumentAttachmentMgmt.DeleteAttachedDocuments(RecRef);
    end;
    #endregion EventSubscriber Table "ESC Book" OnAfterDeleteEvent
}
