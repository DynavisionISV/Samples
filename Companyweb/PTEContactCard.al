pageextension 50100 "PTE Contact Card" extends "Contact Card" // 5050
{
    layout
    {
        modify("Country/Region Code")
        {
            #region OnAfterValidate
            trigger OnAfterValidate()
            begin
                if Rec."Country/Region Code" <> xRec."Country/Region Code" then
                    UpdateFactboxes(false);
            end;
            #endregion OnAfterValidate
        }
        modify("VAT Registration No.")
        {
            #region OnAfterValidate
            trigger OnAfterValidate()
            begin
                if Rec."VAT Registration No." <> xRec."VAT Registration No." then
                    UpdateFactboxes(false);
            end;
            #endregion OnAfterValidate
        }
        modify("Registration Number")
        {
            #region OnAfterValidate
            trigger OnAfterValidate()
            begin
                if Rec."Registration Number" <> xRec."Registration Number" then
                    UpdateFactboxes(false);
            end;
            #endregion OnAfterValidate
        }
        addfirst(factboxes)
        {
            part("PTE Data Factbox"; "CWEBF Data Factbox")
            {
                ApplicationArea = All;
                Visible = DataVisible;
            }
            part("PTE Payment Experience"; "CWEBF Payment Experience")
            {
                ApplicationArea = All;
                Visible = PaymentExperienceVisible;
            }
        }
    }

    actions
    {
        addlast("F&unctions")
        {
            action("PTE Get Data")
            {
                ApplicationArea = All;
                Caption = 'Get Data';
                Image = AnalysisViewDimension;
                Visible = CountrySupported;

                #region OnAction
                trigger OnAction()
                var
                    GetCompanyData: Codeunit "CWEBF Get Company Data";
                begin
                    GetCompanyData.GetData(Rec.RecordId(), Rec."CWEBF Clean VAT No.", Rec."CWEBF Clean Registration No.", Rec."Country/Region Code");
                    Rec.Get(Rec."No."); // Contacts are sorted by name in the list, making the record disappear after updating the contact details
                    UpdateFactboxes(true);
                end;
                #endregion OnAction
            }
        }
        addlast(Promoted)
        {
            group("PTE Category_Provider")
            {
                Caption = 'Provider'; // Change to Liza or Companyweb

                actionref("PTE Get Data_Promoted"; "CWEBF Get Data") {}
            }
        }
    }

    #region OnAfterGetCurrRecord
    trigger OnAfterGetCurrRecord()
    begin
        UpdateFactboxes(false);
    end;
    #endregion OnAfterGetCurrRecord

    #region UpdateFactboxes
    internal procedure UpdateFactboxes(Force: Boolean)
    var
        Data: Record "CWEBF Company Data";
    begin
        CountrySupported := PageTools.IsSupportedCountry(Rec."Country/Region Code");

        if (PrevVATNumber <> Rec."CWEBF Clean VAT No.") or (PrevCountryCode <> Rec."Country/Region Code") or Force then begin
            PageTools.GetData(Rec."CWEBF Clean VAT No.", Rec."CWEBF Clean Registration No.", Rec."Country/Region Code", DataVisible, PaymentExperienceVisible, Data);

            PrevVATNumber := Rec."CWEBF Clean VAT No.";
            PrevCountryCode := Rec."Country/Region Code";

            CurrPage."PTE Data Factbox".Page.SetRecordId(Rec.RecordId());
            CurrPage."PTE Data Factbox".Page.SetTableView(Data);
            CurrPage."PTE Data Factbox".Page.Update();
            CurrPage."PTE Payment Experience".Page.SetTableView(Data);
            CurrPage."PTE Payment Experience".Page.Update();
        end;

        DataVisible := true;
    end;
    #endregion UpdateFactboxes

    var
        PageTools: Codeunit "CWEBF Page Tools";
        CountrySupported, DataVisible, PaymentExperienceVisible: Boolean;
        PrevCountryCode: Code[10];
        PrevVATNumber: Code[50];
}
