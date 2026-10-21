codeunit 50502 "DYN Sample Import To Buffer"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    internal procedure Execute()
    var
        SyncSetup: Record "ESCY Sync Setup";
        PageManagement: Codeunit "Page Management";
    begin
        CreateImportQuotationBufferPropertySyncSetup();
        CreateImportQuotationBufferPropertyValueSyncSetup();

        SyncSetup.SetFilter(Code, '%1|%2', BuffPropTok, BuffPropValTok);
        PageManagement.PageRun(SyncSetup);
    end;

    internal procedure CreateImportQuotationBufferPropertySyncSetup()
    var
        SyncMapping: Record "ESCY Sync Mapping";
        SyncSetup: Record "ESCY Sync Setup";
        QuotationBufferProperty: Record "DYN Quotation Buffer Property";
    begin
        if DYNSyncSetupMgt.CreateOneSyncSetup(BuffPropTok, '/data/1/QuotationProperties', Database::"DYN Quotation Buffer Property", 0, '', Enum::"ESCY Operation"::GetFilter, true, false, false, false, Enum::"ESCY Sync Processor"::" ", Enum::"ESCY Sync Processor"::" ", true, SyncSetup) then begin
            DYNSyncSetupMgt.CreateOneSyncMapping(SyncSetup.Code, 'description', SyncSetup."Table No.", QuotationBufferProperty.FieldNo(Name), 0, false, false, '', Enum::"ESCY Calculated Value"::" ", true, SyncMapping);
            DYNSyncSetupMgt.CreateOneSyncMapping(SyncSetup.Code, 'type', SyncSetup."Table No.", QuotationBufferProperty.FieldNo(Type), 0, false, false, '', Enum::"ESCY Calculated Value"::" ", true, SyncMapping);
            DYNSyncSetupMgt.CreateOneSyncMapping(SyncSetup.Code, 'createdDate', SyncSetup."Table No.", QuotationBufferProperty.FieldNo(SystemCreatedAt), 0, false, false, '', Enum::"ESCY Calculated Value"::" ", false, SyncMapping);
            DYNSyncSetupMgt.CreateOneSyncMapping(SyncSetup.Code, 'updatedDate', SyncSetup."Table No.", QuotationBufferProperty.FieldNo(SystemModifiedAt), 0, false, false, '', Enum::"ESCY Calculated Value"::" ", false, SyncMapping);
            DYNSyncSetupMgt.CreateOneSyncMapping(SyncSetup.Code, 'id', SyncSetup."Table No.", QuotationBufferProperty.FieldNo(Id), 0, true, false, '', Enum::"ESCY Calculated Value"::" ", true, SyncMapping);
        end;
    end;

    internal procedure CreateImportQuotationBufferPropertyValueSyncSetup()
    var
        SyncMapping: Record "ESCY Sync Mapping";
        SyncSetup: Record "ESCY Sync Setup";
        QuotBufferPropValue: Record "DYN Quot. Buffer Prop. Value";
    begin
        if DYNSyncSetupMgt.CreateOneSyncSetup(BuffPropValTok, '/data/1/QuotationPropertyValues', Database::"DYN Quot. Buffer Prop. Value", 0, '?$filter=entityId eq [%1]', Enum::"ESCY Operation"::GetFilter, true, false, false, false, Enum::"ESCY Sync Processor"::" ", Enum::"ESCY Sync Processor"::" ", true, SyncSetup) then begin
            DYNSyncSetupMgt.CreateOneSyncMapping(SyncSetup.Code, 'entityId', SyncSetup."Table No.", QuotBufferPropValue.FieldNo("Quotation Id"), 0, false, false, '', Enum::"ESCY Calculated Value"::" ", true, SyncMapping);
            DYNSyncSetupMgt.CreateOneSyncMapping(SyncSetup.Code, 'entityPropertyId', SyncSetup."Table No.", QuotBufferPropValue.FieldNo("Property Id"), 0, false, false, '', Enum::"ESCY Calculated Value"::" ", true, SyncMapping);
            DYNSyncSetupMgt.CreateOneSyncMapping(SyncSetup.Code, 'value', SyncSetup."Table No.", 0, 0, false, false, '', Enum::"ESCY Calculated Value"::"DYN Quotation Property Value", true, SyncMapping);
            DYNSyncSetupMgt.CreateOneSyncMapping(SyncSetup.Code, 'createdDate', SyncSetup."Table No.", QuotBufferPropValue.FieldNo(SystemCreatedAt), 0, false, false, '', Enum::"ESCY Calculated Value"::" ", false, SyncMapping);
            DYNSyncSetupMgt.CreateOneSyncMapping(SyncSetup.Code, 'updatedDate', SyncSetup."Table No.", QuotBufferPropValue.FieldNo(SystemModifiedAt), 0, false, false, '', Enum::"ESCY Calculated Value"::" ", false, SyncMapping);
            DYNSyncSetupMgt.CreateOneSyncMapping(SyncSetup.Code, 'id', SyncSetup."Table No.", QuotBufferPropValue.FieldNo(Id), 0, true, false, '', Enum::"ESCY Calculated Value"::" ", true, SyncMapping);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ESCY Sync Setup Management", OnAfterExecuteProcessor, '', false, false)]
    local procedure "ESCY Sync Setup Management_OnAfterExecuteProcessor"(var Rec: Record "ESCY Sync Setup"; var RecRef: RecordRef; SyncProcessor: Enum "ESCY Sync Processor"; var ErrorMessage: Text; var OK: Boolean)
    var
        BufferPropertySyncSetup: Record "ESCY Sync Setup";
        BufferPropertyValueSyncSetup: Record "ESCY Sync Setup";
        QuotationBuffer: Record "ESCZ Quotation Buffer";
        APIManagement: Codeunit "ESCY API Management";
        SyncOneEntry: Codeunit "ESCY Sync One Entry";
        QuotationPropertiesCouldNotBeRetrievedErr: Label 'Quotation Properties could not be retrieved.', Comment = 'nl-BE="Offerte-eigenschappen konden niet worden opgehaald."';
        QuotationPropertyValuesCouldNotBeRetrievedErr: Label 'Quotation Property Values could not be retrieved.', Comment = 'nl-BE="Offerte-eigenschap waarden konden niet worden opgehaald."';
    begin
        if not OK then
            exit;

        if RecRef.Number <> Database::"ESCZ Quotation Buffer" then
            exit;

        if SyncProcessor <> Enum::"ESCY Sync Processor"::"ESCZ Import Quotation Details" then
            exit;

        RecRef.SetTable(QuotationBuffer);

        Clear(ErrorMessage);

        // Properties
        BufferPropertySyncSetup.Get(BuffPropTok);

        if not SyncOneEntry.Sync(BufferPropertySyncSetup) then begin
            ErrorMessage := QuotationPropertiesCouldNotBeRetrievedErr;
            OK := false;
            exit;
        end;

        // Property Values
        BufferPropertyValueSyncSetup.Get(BuffPropValTok);
        BufferPropertyValueSyncSetup.AddFilterValue(APIManagement.FormatGuidForODataKeyField(QuotationBuffer.Id));

        if not SyncOneEntry.Sync(BufferPropertyValueSyncSetup) then begin
            ErrorMessage := QuotationPropertyValuesCouldNotBeRetrievedErr;
            OK := false;
            exit;
        end;

        OK := true;
    end;

    #region EventSubscriber Codeunit "ESCZ Import Quotation" OnCreateSalesQuoteOnBeforeShowResult
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ESCZ Import Quotation", OnCreateSalesQuoteOnBeforeShowResult, '', false, false)]
    local procedure "ESCZ Import Quotation_OnCreateSalesQuoteOnBeforeShowResult"(QuotationBuffer: Record "ESCZ Quotation Buffer"; var SalesHeader: Record "Sales Header"; var ShowResult: Boolean)
    var
        QuotBufferPropValue: Record "DYN Quot. Buffer Prop. Value";
    begin
        QuotBufferPropValue.SetRange("Quotation Id", QuotationBuffer.Id);
        if not QuotBufferPropValue.FindSet() then
            exit;

        repeat
        // Do something with the properties
        until QuotBufferPropValue.Next() = 0;
    end;
    #endregion EventSubscriber Codeunit "ESCZ Import Quotation" OnCreateSalesQuoteOnBeforeShowResult

    var
        DYNSyncSetupMgt: Codeunit "DYN Sync Setup Mgt.";
        BuffPropTok: Label 'BUFFPROP', Locked = true;
        BuffPropValTok: Label 'BUFFPROPVAL', Locked = true;
}
