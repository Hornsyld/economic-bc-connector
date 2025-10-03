codeunit 51001 "Economic Profile Setup"
{
    /// <summary>
    /// Creates the Economic Integration profile to make the role center selectable
    /// </summary>
    procedure CreateEconomicProfile()
    var
        AllProfile: Record "All Profile";
    begin
        // Create in All Profile table
        if not AllProfile.Get('', 'ECONOMIC INTEGRATION') then begin
            AllProfile.Init();
            AllProfile.Scope := AllProfile.Scope::System;
            AllProfile."Profile ID" := 'ECONOMIC INTEGRATION';
            AllProfile.Description := 'Economic Integration';
            AllProfile."Role Center ID" := 51005;
            AllProfile.Enabled := true;
            AllProfile.Promoted := true;
            AllProfile.Insert(true);
            Message('Economic Integration profile has been created and is now available in the Roles list.');
        end else begin
            Message('Economic Integration profile already exists.');
        end;
    end;

    /// <summary>
    /// Removes the Economic Integration profile
    /// </summary>
    procedure RemoveEconomicProfile()
    var
        AllProfile: Record "All Profile";
    begin
        if AllProfile.Get('', 'ECONOMIC INTEGRATION') then begin
            AllProfile.Delete(true);
            Message('Economic Integration profile has been removed.');
        end else begin
            Message('Economic Integration profile not found.');
        end;
    end;
}