codeunit 61101 "DCADV Advanced Move to company"
{
    //(var Document: Record "CDC Document"; var DocCat: Record "CDC Document Category"; var IdentifiedCompanyName: Text[250]; var IsHandled: Boolean)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CDC Doc. - Move to Company", 'OnBeforeIdentifyTargetCompany', '', true, true)]
    local procedure AdvancedIdentifyTargetCompany(var Document: Record "CDC Document"; var DocCat: Record "CDC Document Category"; var IdentifiedCompanyName: Text[250]; var IsHandled: Boolean)
    var
        DCSetup: Record "CDC Document Capture Setup";
        Company: Record Company;
        CompIdentText: Record "CDC Company Identificat. Text";
        DocWord: Record "CDC Document Word";
        BigString: Codeunit "CDC BigString Management";
        SearchText: Text[150];
        FullSymbolText: Text[10];
        ReplaceSymbolText: Text[20];
        KeepSymbolText: Text[10];
        IdentificationTextHasSymbol: Boolean;
        i: Integer;
        XMLBuffer: Record "CDC XML Buffer" temporary;
        CompanyBuffer: Record Company temporary;
        SearchWordFound: Boolean;
        FoundCompany: Text[50];
        MoreFoundCompanies: Boolean;
    begin
        DCSetup.GET;
        if not DCSetup."Use Advanced Move to Company" then
            exit;

        IsHandled := true;

        IF Document."File Type" = Document."File Type"::XML THEN BEGIN
            Document.BuildXmlBuffer(XMLBuffer);
            XMLBuffer.SETRANGE(Type, XMLBuffer.Type::Element);
        END ELSE BEGIN
            DocWord.SETRANGE("Document No.", Document."No.");
            DocWord.SETRANGE("Page No.", 1);
        END;

        IF CompIdentText.ISEMPTY OR ((Document."File Type" <> Document."File Type"::XML) AND DocWord.ISEMPTY) OR
          ((Document."File Type" = Document."File Type"::XML) AND XMLBuffer.ISEMPTY)
        THEN
            IF DocCat."Document with UIC" = DocCat."Document with UIC"::"Import as UIC document" THEN begin
                IdentifiedCompanyName := '';
                exit;
            end else begin
                IdentifiedCompanyName := COMPANYNAME;
                exit;
            end;

        FullSymbolText := ',.-;:/\*+-';
        IF CompIdentText.FINDSET THEN
            REPEAT
                FOR i := 1 TO STRLEN(FullSymbolText) DO
                    IF STRPOS(CompIdentText."Identification Text", FORMAT(FullSymbolText[i])) <> 0 THEN
                        IF STRPOS(KeepSymbolText, FORMAT(FullSymbolText[i])) = 0 THEN
                            KeepSymbolText := KeepSymbolText + FORMAT(FullSymbolText[i]);
            UNTIL CompIdentText.NEXT = 0;

        ReplaceSymbolText := DELCHR(FullSymbolText, '=', KeepSymbolText) + ' ';

        IF Document."File Type" = Document."File Type"::XML THEN BEGIN
            XMLBuffer.FINDSET(FALSE, FALSE);
            REPEAT
                IF IdentificationTextHasSymbol THEN
                    BigString.Append(UPPERCASE(XMLBuffer.Value))
                ELSE
                    BigString.Append(UPPERCASE(DELCHR(XMLBuffer.Value, '=', ReplaceSymbolText)));
            UNTIL XMLBuffer.NEXT = 0;
        END ELSE BEGIN
            if (DCSetup."Letterhead Top" > 0) and (DCSetup."Letterhead Left" > 0) and (DCSetup."Letterhead Bottom" > 0) and (DCSetup."Letterhead Right" > 0) then begin
                DocWord.SETRANGE(Top, DCSetup."Letterhead Top", DCSetup."Letterhead Bottom");
                DocWord.SETRANGE(Bottom, DCSetup."Letterhead Top", DCSetup."Letterhead Bottom");
                DocWord.SETRANGE(Left, DCSetup."Letterhead Left", DCSetup."Letterhead Right");
                DocWord.SETRANGE(Right, DCSetup."Letterhead Left", DCSetup."Letterhead Right");
            end;

            DocWord.FINDSET(FALSE, FALSE);
            REPEAT
                IF IdentificationTextHasSymbol THEN
                    BigString.Append(UPPERCASE(DocWord.Word))
                ELSE
                    BigString.Append(UPPERCASE(DELCHR(DocWord.Word, '=', ReplaceSymbolText)));
            UNTIL DocWord.NEXT = 0;
        END;

        CompIdentText.RESET;
        CompIdentText.SETCURRENTKEY("Identification Text Length");
        CompIdentText.ASCENDING(FALSE);

        // IF CompIdentText.FINDFIRST THEN
        //     REPEAT
        //         IF BigString.IndexOf(UPPERCASE(DELCHR(CompIdentText."Identification Text", '=', ReplaceSymbolText))) <> -1 THEN
        //             IF Company.GET(CompIdentText."Company Name") THEN
        //                 EXIT(Company.Name);
        //     UNTIL CompIdentText.NEXT = 0;

        // IF DocCat."Document with UIC" = DocCat."Document with UIC"::"Import as UIC document" THEN
        //     EXIT('')
        // ELSE
        //     EXIT(COMPANYNAME);

        // 1. Write all configured companies into buffer
        IF CompIdentText.FINDFIRST THEN
            REPEAT
                IF NOT CompanyBuffer.GET(CompIdentText."Company Name") THEN BEGIN
                    CompanyBuffer.Name := CompIdentText."Company Name";
                    CompanyBuffer.INSERT;
                END;
            UNTIL CompIdentText.NEXT = 0;

        // 2. iterate through all companies and check if ALL search words have been found
        IF CompanyBuffer.FINDFIRST THEN
            REPEAT
                CompIdentText.SETRANGE("Company Name", CompanyBuffer.Name);
                IF CompIdentText.FINDFIRST THEN
                    REPEAT
                        SearchWordFound := BigString.IndexOf(UPPERCASE(DELCHR(CompIdentText."Identification Text", '=', ReplaceSymbolText))) <> -1;
                    UNTIL (CompIdentText.NEXT = 0) OR (NOT SearchWordFound);  // direkt aussteigen, wenn keine Úbereinstimmung bei einem Suchbegriff

                IF SearchWordFound THEN
                    IF FoundCompany = '' THEN
                        FoundCompany := CompanyBuffer.Name
                    ELSE
                        MoreFoundCompanies := TRUE;
            UNTIL (CompanyBuffer.NEXT = 0) OR (MoreFoundCompanies);

        IF (FoundCompany <> '') AND (NOT MoreFoundCompanies) THEN begin
            IdentifiedCompanyName := FoundCompany;
        end else begin
            if DocCat."Document with UIC" = DocCat."Document with UIC"::"Import as UIC document" THEN
                IdentifiedCompanyName := ''
            else
                IdentifiedCompanyName := COMPANYNAME;
        end;


    end;
}