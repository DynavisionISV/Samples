pageextension 50200 DYNContactCard extends "Contact Card" // 5050
{
    layout
    {
        modify("Country/Region Code")
        {
            trigger OnAfterValidate()
            begin
                if Rec."Country/Region Code" <> xRec."Country/Region Code" then
                    UpdateFactboxes(false);
            end;
        }
        modify("VAT Registration No.")
        {
            trigger OnAfterValidate()
            begin
                if Rec."VAT Registration No." <> xRec."VAT Registration No." then
                    UpdateFactboxes(false);
            end;
        }
        modify("Registration Number")
        {
            trigger OnAfterValidate()
            begin
                if Rec."Registration Number" <> xRec."Registration Number" then
                    UpdateFactboxes(false);
            end;
        }
        addfirst(factboxes)
        {
            part("DYN Data Factbox"; "CWEBF Data Factbox")
            {
                ApplicationArea = All;
                Visible = DataVisible;
            }
            part("DYN Payment Experience"; "CWEBF Payment Experience")
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
            action("DYN Get Data")
            {
                ApplicationArea = All;
                Caption = 'Get Data';
                Image = AnalysisViewDimension;
                ToolTip = 'Get Data from Companyweb / Liza';
                Visible = CountrySupported;

                trigger OnAction()
                var
                    GetCompanyData: Codeunit "CWEBF Get Company Data";
                begin
                    GetCompanyData.GetData(Rec.RecordId(), Rec."CWEBF Clean VAT No.", Rec."CWEBF Clean Registration No.", Rec."Country/Region Code");
                    Rec.Get(Rec."No."); // Contacts are sorted by name in the list, making the record disappear after updating the contact details
                    UpdateFactboxes(true);
                end;
            }
        }
        addlast(Promoted)
        {
            group("DYN Category_Provider")
            {
                Caption = 'Provider'; // Change to Liza or Companyweb

                actionref("DYN Get Data_Promoted"; "DYN Get Data") { }
            }
        }
    }

    var
        PageTools: Codeunit "CWEBF Page Tools";
        CountrySupported, DataVisible, PaymentExperienceVisible : Boolean;
        PrevCountryCode: Code[10];
        PrevVATNumber: Code[50];

    trigger OnAfterGetCurrRecord()
    begin
        UpdateFactboxes(false);
    end;

    local procedure UpdateFactboxes(Force: Boolean)
    var
        Data: Record "CWEBF Company Data";
    begin
        CountrySupported := PageTools.IsSupportedCountry(Rec."Country/Region Code");

        if (PrevVATNumber <> Rec."CWEBF Clean VAT No.") or (PrevCountryCode <> Rec."Country/Region Code") or Force then begin
            PageTools.GetData(Rec."CWEBF Clean VAT No.", Rec."CWEBF Clean Registration No.", Rec."Country/Region Code", DataVisible, PaymentExperienceVisible, Data);

            PrevVATNumber := Rec."CWEBF Clean VAT No.";
            PrevCountryCode := Rec."Country/Region Code";

            CurrPage."DYN Data Factbox".Page.SetRecordId(Rec.RecordId());
            CurrPage."DYN Data Factbox".Page.SetTableView(Data);
            CurrPage."DYN Data Factbox".Page.Update();
            CurrPage."DYN Payment Experience".Page.SetTableView(Data);
            CurrPage."DYN Payment Experience".Page.Update();
        end;

        DataVisible := true;
    end;
}