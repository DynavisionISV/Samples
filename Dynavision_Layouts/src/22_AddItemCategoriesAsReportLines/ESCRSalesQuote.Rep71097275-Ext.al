reportextension 50001 DYN22SalesQuote extends "ESCR Sales Quote" // 71097275
{
    dataset
    {
        modify(Line)
        {
            trigger OnAfterAfterGetRecord()
            begin
                // When the line is skipped in the OnAfterGetRecord, we still get into this trigger.
                // https://github.com/microsoft/AL/issues/7039
                // So we need to check if the line is skipped and exit if it is.
                if ReportDocumentLine."Source SystemId" <> Line.SystemId then
                    exit;

                if not ReportLayoutSetup."DYN Print Quote Categories" then
                    exit;

                ReportDocumentLine."DYN Parent Item Category" := GetParentItemCategory(Line."Item Category Code");
                ReportDocumentLine.SetCategorySortingValue();
                ReportDocumentLine.Modify(false);

                AddHeader(ReportDocumentLine, ReportDocumentLine."DYN Parent Item Category", ReportDocumentLine.Group - 2);
                AddSubHeader(ReportDocumentLine, ReportDocumentLine."DYN Parent Item Category", Line."Item Category Code", ReportDocumentLine.Group - 1);
            end;
        }
        modify(CopyLoop)
        {
            trigger OnBeforeAfterGetRecord()
            begin
                Clear(HeaderList);
                Clear(SubheaderList);
            end;
        }
    }

    var
        HeaderList, SubheaderList : List of [Text];

    local procedure AddHeader(var ReportDocumentLine: Record "ESCA Report Document Line"; ItemCategoryCode: Code[20]; NewGroup: Integer)
    var
        ItemCategory: Record "Item Category";
        NextId: Integer;
    begin
        if HeaderList.Contains(ItemCategoryCode) then
            exit;
        if not ItemCategory.Get(ItemCategoryCode) then
            exit;

        NextId := ReportDocumentLine.Id + 1;

        ReportDocumentLine.Init();
        ReportDocumentLine.Id := NextId;
        ReportDocumentLine."Line Type" := ReportDocumentLine."Line Type"::"Group Header";
        ReportDocumentLine."Group" := NewGroup;
        ReportDocumentLine.Level := 1;
        ReportDocumentLine.Description := CopyStr(ItemCategory.Description, 1, MaxStrLen(ReportDocumentLine.Description));
        ReportDocumentLine."Item Category Code" := '';
        ReportDocumentLine."DYN Parent Item Category" := ItemCategoryCode;
        ReportDocumentLine.SetCategorySortingValue();
        ReportDocumentLine.Insert();

        HeaderList.Add(ItemCategoryCode);
    end;

    local procedure AddSubHeader(var ReportDocumentLine: Record "ESCA Report Document Line"; ParentItemCategoryCode: Code[20]; ItemCategoryCode: Code[20]; NewGroup: Integer)
    var
        ItemCategory: Record "Item Category";
        NextId: Integer;
    begin
        if HeaderList.Contains(ItemCategoryCode) then
            exit;
        if SubheaderList.Contains(ItemCategoryCode) then
            exit;
        if not ItemCategory.Get(ItemCategoryCode) then
            exit;

        NextId := ReportDocumentLine.Id + 1;

        ReportDocumentLine.Init();
        ReportDocumentLine.Id := NextId;
        ReportDocumentLine."Line Type" := ReportDocumentLine."Line Type"::"DYN Group Subheader";
        ReportDocumentLine."Group" := NewGroup;
        ReportDocumentLine.Level := 1;
        ReportDocumentLine.Description := CopyStr(ItemCategory.Description, 1, MaxStrLen(ReportDocumentLine.Description));
        ReportDocumentLine."Item Category Code" := ItemCategoryCode;
        ReportDocumentLine."DYN Parent Item Category" := ParentItemCategoryCode;
        ReportDocumentLine.SetCategorySortingValue();
        ReportDocumentLine.Insert();

        SubheaderList.Add(ItemCategoryCode);
    end;

    local procedure GetParentItemCategory(ItemCategoryCode: Code[20]): Code[20]
    var
        ItemCategory: Record "Item Category";
        Stop: Boolean;
    begin
        if ItemCategoryCode = '' then
            exit('');
        if not ItemCategory.Get(ItemCategoryCode) then
            exit('');

        repeat
            if ItemCategory."Parent Category" <> '' then
                ItemCategory.Get(ItemCategory."Parent Category")
            else
                Stop := true;
        until Stop;

        exit(ItemCategory.Code);
    end;
}