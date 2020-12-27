library Dsmodel113;
  {-Berekening nat-, droogte- en totale schade aan landbouwgewassen (grasland of bouwland)
  afhankelijk van bodemtype (HELP indeling 1987), GHG en GLG. Zie "Help-tabellen 1987.xls"}

  { Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  ShareMem,
  windows,
  SysUtils,
  Classes,
  LargeArrays,
  ExtParU,
  USpeedProc,
  uDCfunc,
  UdsModel,
  UdsModelS,
  xyTable,
  DUtils,
  uError,
  Math,
  vcl.Dialogs;

Const
  cModelID      = 113;  {-Uniek modelnummer}

  {-Beschrijving van de array met afhankelijke variabelen}
  cNrOfDepVar   = 3;    {-Lengte van de array met afhankelijke variabelen}
  cy1           = 1;    {-GEMIDDELDE Natschade (%)}
  cy2           = 2;    {-GEMIDDELDE Droogteschade (%)}
  cy3           = 3;    {-GEMIDDELDE opbrengstdepressie door nat- en droogteschade (%)}

  {-Aantal keren dat een discontinuiteitsfunctie wordt aangeroepen in de procedure met
    snelheidsvergelijkingen (DerivsProc)}
  nDC = 0;

  {-Variabelen die samenhangen met het aanroepen van het model vanuit de Shell}
  cnRP    = 4;   {-Aantal RP-tijdreeksen die door de Shell moeten worden aangeleverd (in
                   de externe parameter Array EP (element EP[ indx-1 ]))}
  cnSQ    = 0;   {-Idem punt-tijdreeksen}
  cnRQ    = 0;   {-Idem lijn-tijdreeksen}

  {-Beschrijving van het eerste element van de externe parameter-array (EP[cEP0])}
  cNrXIndepTblsInEP0 = 7;  {-Aantal XIndep-tables in EP[cEP0]}
  cNrXdepTblsInEP0   = 0;  {-Aantal Xdep-tables   in EP[cEP0]}
  {-Nummering van de xIndep-tabellen in EP[cEP0]. De nummers 0&1 zijn gereserveerd}
  cTb_MinMaxValKeys            = 2;
  cTb_coeff_Gras_Natschade     = 3; {-Coefficienten in regressiefunctie grasland natschade}
  cTb_coeff_Bouw_Natschade     = 4; {-Coefficienten in regressiefunctie bouwland natschade}
  cTb_Coeff_Gras_Droogteschade = 5; {-Coefficienten in regressiefunctie grasland droogteschade}
  cTb_Coeff_Bouw_Droogteschade = 6; {-Coefficienten in regressiefunctie bouwland droogteschade}

  {-Beschrijving van het tweede element van de externe parameter-array (EP[cEP1])}
  {-Opmerking: table 0 van de xIndep-tabellen is gereserveerd}
  {-Nummering van de xdep-tabellen in EP[cEP1]}
  cTb_Landgebruik     = 0; {1=Grasland; 2=Bouwland}
  cTb_Bodemtype       = 1; {1-70, (HELP indeling 1987)}
  cTb_GHG             = 2; {-m-mv}
  cTb_GLG             = 3; {-m-mv}

  {-Model specifieke fout-codes DSModel113: -9840..-9849}
  {cInvld_KeyValue1     = -###;
  cInvld_KeyValue2     = -###;
                 ###}
  cInvld_ParFromShell_Landgebruik = -9840;
  cInvld_ParFromShell_Bodemtype = -9841;
  cInvld_ParFromShell_GHG = -9842;
  cInvld_ParFromShell_GLG = -9843;
  cInvld_ParFromShell_Soil_Crop_Combination = -9844;

                 {###
  cInvld_DefaultPar1   = -###;
  cInvld_DefaultPar2   = -###;
                 ###
  cInvld_Init_Val1     = -###;
  cInvld_Init_Val2     = -###;
                 ###}
  cGrasland = 1;
  cBouwland = 2;
  cInvalid_Coeff = -1; {-Als ongeldige combinatie bodemtype-gewas}
  cNoResult = -999;

var
  Indx: Integer; {-Door de Boot-procedure moet de waarde van deze index worden ingevuld,
                   zodat de snelheidsprocedure 'weet' waar (op de externe parameter-array)
				   hij zijn gegevens moet zoeken}
  ModelProfile: TModelProfile;
                 {-Object met met daarin de status van de discontinuiteitsfuncties
				   (zie nDC) }

  {-Globally defined parameters from EP[0]}
  {###}

  {-Geldige range van key-/parameter/initiele waarden. De waarden van deze  variabelen moeten
    worden ingevuld door de Boot-procedure}
  cMin_KeyValue_Landgebruik, cMax_KeyValue_Landgebruik,
  cMin_KeyValue_Bodemtype, cMax_KeyValue_Bodemtype : Integer;
  cMin_ParValueGHG, cMax_ParValueGHG,
  cMin_ParValueGLG, cMax_ParValueGLG{,
  cMin_InitVal1,  cMax_InitVal1,  ###,} : Double;

Procedure MyDllProc( Reason: Integer );
begin
  if Reason = DLL_PROCESS_DETACH then begin {-DLL is unloading}
    {-Cleanup code here}
	if ( nDC > 0 ) then
      ModelProfile.Free;
  end;
end;


Procedure DerivsProc( var x: Double; var y, dydx: TLargeRealArray;
                      var EP: TExtParArray; var Direction: TDirection;
                      var Context: Tcontext; var aModelProfile: PModelProfile; var IErr: Integer );
{-Deze procedure verschaft de array met afgeleiden 'dydx', gegeven het tijdstip 'x' en
  de toestand die beschreven wordt door de array 'y' en de externe condities die beschreven
  worden door de 'external parameter-array EP'. Als er geen fout op is getreden bij de
  berekening van 'dydx' dan wordt in deze procedure de variabele 'IErr' gelijk gemaakt aan de
  constante 'cNoError'. Opmerking: in de array 'y' staan dus de afhankelijke variabelen,
  terwijl 'x' de onafhankelijke variabele is (meestal de tijd)}
var
  Landgebruik, Bodemtype: Integer;     {-Sleutel-waarden voor de default-tabellen in EP[cEP0]}
  GHG, GLG,                            {-Parameter-waarden afkomstig van de Shell}
  {DefaultPar1, DefaultPar2,}          {-Default parameter-waarden in EP[cEP0]}
  {CalcPar1, CalcPar2, ###}            {-Afgeleide (berekende) parameter-waarden}
  A_coeff,                             {-Coefficienten in opbrengstdepressie functies}
  B_coeff,
  C_coeff,
  D_coeff,
  E_coeff,
  NatschadePerc,                       {-Berekeningsresultaat: natschade (%)}
  DroogteschadePerc,                   {-Berekeningsresultaat: droogteschade (%)}
  TotaleSchadePerc: Double;
  i: Integer;            {-Berekeningsresultaat: totale schade (%)}

Function SetParValuesFromEP0( var IErr: Integer ): Boolean;
  {-Fill globally defined parameters from EP[0]. If memory is allocated here,
    free first with 'try .. except' for those cases that the model is used repeatedly}
begin
  Result := true;
end;

Function SetKeyAndParValues( var IErr: Integer ): Boolean;

  Function GetKeyValue_Landgebruik( const x: Double ): Integer;
  begin
    with EP[ indx-1 ].xDep do
      Result := Trunc( Items[ cTb_Landgebruik ].EstimateY( x, Direction ) );
  end;

  Function GetKeyValue_Bodemtype( const x: Double ): Integer;
  begin
    with EP[ indx-1 ].xDep do
      Result := Trunc( Items[ cTb_Bodemtype ].EstimateY( x, Direction ) );
  end;

  Function GetParFromShell_GHG( const x: Double ): Double;
  begin
    with EP[ indx-1 ].xDep do
      Result := Items[ cTb_GHG ].EstimateY( x, Direction );
  end;

  Function GetParFromShell_GLG( const x: Double ): Double;
  begin
    with EP[ indx-1 ].xDep do
      Result := Items[ cTb_GLG ].EstimateY( x, Direction );
  end;

{  Function GetKeyValue1( const x: Double ): Integer;
  begin
    with EP[ indx-1 ].xDep do
      Result := Trunc( Items[ cTb_KeyValue1 ].EstimateY( x, Direction ) );
  end;

  ###

  Function GetParFromShell1( const x: Double ): Double;
  begin
    with EP[ indx-1 ].xDep do
      Result := Items[ cTb_ParFromShell1 ].EstimateY( x, Direction );
  end;

  ###}

// Function GetDefaultPar1( const KeyValue1: Integer ): Double;
// begin
//    with EP[ cEP0 ].xInDep.Items[ cTb_DefaultPar1 ] do
//      Result := GetValue( 1, KeyValue1 );} {row, column}
// end;

   Procedure Set_Coefficients_ForNatschade( const landgebruik, bodemtype: integer );
   begin
    with EP[ cEP0 ].xInDep do begin
      case landgebruik of
        cGrasland:
          with Items[ cTb_coeff_Gras_Natschade ] do begin
            A_coeff := GetValue( bodemtype, 1 ); {row, column}
            B_coeff := GetValue( bodemtype, 2 );
            C_coeff := GetValue( bodemtype, 3 );
            D_coeff := GetValue( bodemtype, 4 );
            E_coeff := GetValue( bodemtype, 5 );
          end;
        cBouwland:
          with Items[ cTb_coeff_Bouw_Natschade ] do begin
            A_coeff := GetValue( bodemtype, 1 ); {row, column}
            B_coeff := GetValue( bodemtype, 2 );
            C_coeff := GetValue( bodemtype, 3 );
            D_coeff := GetValue( bodemtype, 4 );
            E_coeff := GetValue( bodemtype, 5 );
          end;
      end;
    end; {-with}
   end;

   Procedure Set_Coefficients_ForDroogteschade( const landgebruik, bodemtype: integer );
   begin
    with EP[ cEP0 ].xInDep do begin
      case landgebruik of
        cGrasland:
          with Items[ cTb_Coeff_Gras_Droogteschade ] do begin
            A_coeff := GetValue( bodemtype, 1 ); {row, column}
            B_coeff := GetValue( bodemtype, 2 );
            C_coeff := GetValue( bodemtype, 3 );
            D_coeff := GetValue( bodemtype, 4 );
            E_coeff := GetValue( bodemtype, 5 );
          end;
        cBouwland:
          with Items[ cTb_Coeff_Bouw_Droogteschade ] do begin
            A_coeff := GetValue( bodemtype, 1 ); {row, column}
            B_coeff := GetValue( bodemtype, 2 );
            C_coeff := GetValue( bodemtype, 3 );
            D_coeff := GetValue( bodemtype, 4 );
            E_coeff := GetValue( bodemtype, 5 );
          end;
      end;
    end; {-with}
   end;


{  Function GetDefaultPar2( const KeyValue1, KeyValue2: Integer ): Double;
  begin
    with EP[ cEP0 ].xInDep.Items[ cTb_DefaultPar2 ] do
      Result := GetValue( KeyValue1, KeyValue2 );} {row, column}
{  end;

  ###}

  {- User defined functions/procedures to calculate CalcPar1, CalcPar2... etc.}

  {###}

begin {-Function SetKeyAndParValues}
  Result            := False;
  IErr              := cUnknownError;
  NatschadePerc     := cNoResult;
  DroogteschadePerc := cNoResult;
  TotaleSchadePerc  := cNoResult;

  Landgebruik := GetKeyValue_Landgebruik( x );
  if ( Landgebruik < cMin_KeyValue_Landgebruik ) or ( Landgebruik > cMax_KeyValue_Landgebruik ) then begin
    IErr := cInvld_ParFromShell_Landgebruik; Exit;
  end;
  Bodemtype := GetKeyValue_Bodemtype( x );
  if ( Bodemtype < cMin_KeyValue_Bodemtype ) or ( Bodemtype > cMax_KeyValue_Bodemtype ) then begin
    IErr := cInvld_ParFromShell_Bodemtype; Exit;
  end;

  GHG := GetParFromShell_GHG( x );
  if ( GHG < cMin_ParValueGHG ) or ( GHG > cMax_ParValueGHG ) then begin
    IErr := cInvld_ParFromShell_GHG; Exit;
  end;
  GLG := GetParFromShell_GLG( x );
  if ( GLG < cMin_ParValueGLG ) or ( GLG > cMax_ParValueGLG ) then begin
    IErr := cInvld_ParFromShell_GLG; Exit;
  end;

  {DefaultPar1 := GetDefaultPar1( KeyValue1 );
  if ( DefaultPar1 < cMin_ParValue1 ) or ( DefaultPar1 > cMax_ParValue1 ) then begin
    IErr := cInvld_DefaultPar1; Exit;
  end;

  ###

  DefaultPar2 := GetDefaultPar2( KeyValue1, KeyValue2 );
  if ( DefaultPar2 < cMinParValue2 ) or ( DefaultPar2 > cMaxParValue2 ) then begin
    IErr := cInvld_DefaultPar2; Exit;
  end;

  ###

  CalcPar1 := ###
  if (CalcPar1 < cMinCalcPar) or ###}
  GHG := max( min( GHG * 100, 999 ), 0 ); {-Regressiefunctie verwacht waarde in cm-mv; gekuist anders risico op overflow in berekening}
  GLG := max( min( GLG * 100, 999 ), 0 ); {-Regressiefunctie verwacht waarde in cm-mv; gekuist anders risico op overflow in berekening}

  Set_Coefficients_ForNatschade( landgebruik, bodemtype );
  if ( A_coeff = cInvalid_Coeff ) then begin
    IErr := cInvld_ParFromShell_Soil_Crop_Combination; Exit;
  end;

  NatschadePerc := min( 100, max( A_coeff + B_coeff * ( Power(GHG + C_coeff,-D_coeff) + Power(GLG + C_coeff,-D_coeff ) ), E_coeff ) );

  Set_Coefficients_ForDroogteschade( landgebruik, bodemtype );
  if ( A_coeff = cInvalid_Coeff ) then begin
    IErr := cInvld_ParFromShell_Soil_Crop_Combination; Exit;
  end;

  DroogteschadePerc := min( 100, max( E_coeff + A_coeff * ( 1 - 1 / ( 1 + Power( B_coeff*(max(GLG-C_coeff,0.01)),D_coeff ) ) ), E_coeff ) );
  TotaleSchadePerc := ( 1 - ( (100-NatschadePerc)/100 )* ( (100-DroogteschadePerc)/100) ) * 100;

  Result := True; IErr := cNoError;
end; {-Function SetKeyAndParValues}

Function Replace_InitialValues_With_ShellValues( var IErr: Integer): Boolean;
  {-Als de Shell 1-of meer initiele waarden aanlevert voor de array met afhankelijke
    variabelen ('y'), dan kunnen deze waarden hier op deze array worden geplaatst en
    gecontroleerd}
begin
    IErr := cNoError; Result := True;
//  with EP[ indx-1 ].xDep do
//    y[ ### ] := Items[ cTB_### ].EstimateY( 0, Direction ); {Opm.: x=0}
//  if ( y[ ### ] < cMin_InitVal1 ) or
//     ( y[ ### ] > cMax_InitVal1 ) then begin
//    IErr := cInvld_Init_Val1; Result := False; Exit;
//  end;
end; {-Replace_InitialValues_With_ShellValues}


begin {-Procedure DerivsProc}
  for i := 1 to cNrOfDepVar do
    dydx[ i ] := 0;

  IErr := cUnknownError;

  {-Geef de aanroepende procedure een handvat naar het ModelProfiel}
  if ( nDC > 0 ) then
    aModelProfile := @ModelProfile
  else
    aModelProfile := NIL;

  if not SetKeyAndParValues( IErr ) then begin
    {ShowMessage( IErr.ToString );}
    exit;
  end;

  if ( Context = UpdateYstart ) then begin {-Run fase 1}

    {-Fill globally defined parameters from EP[0]}
    if not SetParValuesFromEP0( IErr ) then Exit;

    {-Optioneel: initiele waarden vervangen door Shell-waarden}
//    if not Replace_InitialValues_With_ShellValues( IErr ) then
//	  Exit;

    {-Bij Shell-gebruik van het model (indx = cBoot2) dan kan het wenselijk zijn de tijd-as
	  van alle Shell-gegevens te converteren, bijvoorbeeld naar jaren}
//      ### if ( indx = cBoot2 ) then
//        ScaleTimesFromShell( cFromDayToYear, EP ); ###

    IErr := cNoError;

  end else begin {-Run fase 2}

    {-Bereken de array met afgeleiden 'dydx'.
	  Gebruik hierbij 'DCfunc' van 'ModelProfile' i.p.v.
	  'if'-statements! Als hierbij de 'AsSoonAs'-optie
	  wordt gebruikt, moet de statement worden aangevuld
	  met een extra conditie ( Context = Trigger ). Dus
	  bijv.: if DCfunc( AsSoonAs, h, LE, BodemNiveau, Context, cDCfunc0 )
	     and ( Context = Trigger ) then begin...}
    dydx[ cy1 ] := NatschadePerc;
    dydx[ cy2 ] := DroogteschadePerc;
    dydx[ cy3 ] := TotaleSchadePerc;

  end;
end; {-DerivsProc}

Function DefaultBootEP( const EpDir: String; const BootEpArrayOption: TBootEpArrayOption; var EP: TExtParArray ): Integer;
  {-Initialiseer de meest elementaire gegevens van het model. Shell-gegevens worden door deze
    procedure NIET verwerkt}
Procedure SetMinMaxKeyAndParValues;
begin
  with EP[ cEP0 ].xInDep.Items[ cTb_MinMaxValKeys ] do begin
    cMin_KeyValue_Landgebruik := Trunc( GetValue( 1, 1 ) ); {rij, kolom}
    cMax_KeyValue_Landgebruik := Trunc( GetValue( 1, 2 ) );
    cMin_KeyValue_Bodemtype   := Trunc( GetValue( 1, 3 ) );
    cMax_KeyValue_Bodemtype   := Trunc( GetValue( 1, 4 ) );
    cMin_ParValueGHG :=                 GetValue( 1, 5 );
    cMax_ParValueGHG :=                 GetValue( 1, 6 );
    cMin_ParValueGLG :=                 GetValue( 1, 7 );
    cMax_ParValueGLG :=                 GetValue( 1, 8 );
  end;

end;
Begin
  Result := DefaultBootEPFromTextFile( EpDir, BootEpArrayOption, cModelID, cNrOfDepVar, nDC, cNrXIndepTblsInEP0,
                                       cNrXdepTblsInEP0, Indx, EP );
  if ( Result = cNoError ) then begin
    SetMinMaxKeyAndParValues;
    {###SetAnalytic_DerivsProc( True, EP );} {-Ref. 'USpeedProc.pas'}
  end;
end;

Function TestBootEP( const EpDir: String; const BootEpArrayOption: TBootEpArrayOption; var EP: TExtParArray ): Integer;
  {-Deze boot-procedure verwerkt alle basisgegevens van het model en leest de Shell-gegevens
    uit een bestand. Na initialisatie met deze boot-procedure is het model dus gereed om
	'te draaien'. Deze procedure kan dus worden gebruikt om het model 'los' van de Shell te
	testen}
Begin
  Result := DefaultBootEP( EpDir, BootEpArrayOption, EP );
  if ( Result <> cNoError ) then
    exit;
  Result := DefaultTestBootEPFromTextFile( EpDir, BootEpArrayOption, cModelID, cnRP + cnSQ + cnRQ, Indx, EP );
  if ( Result <> cNoError ) then
    exit;
  SetReadyToRun( EP);
end;

Function BootEPForShell( const EpDir: String; const BootEpArrayOption: TBootEpArrayOption; var EP: TExtParArray ): Integer;
  {-Deze procedure maakt het model gereed voor Shell-gebruik.
    De xDep-tables in EP[ indx-1 ] worden door deze procedure NIET geinitialiseerd omdat deze
	gegevens door de Shell worden verschaft }
begin
  Result := DefaultBootEP( EpDir, cBootEPFromTextFile, EP );
  if ( Result = cNoError ) then
    Result := DefaultBootEPForShell( cnRP, cnSQ, cnRQ, Indx, EP );
end;

Exports DerivsProc       index cModelIndxForTDSmodels, {999}
        DefaultBootEP    index cBoot0, {1}
        TestBootEP       index cBoot1, {2}
        BootEPForShell   index cBoot2; {3}

begin
  {-Dit zgn. 'DLL-Main-block' wordt uitgevoerd als de DLL voor het eerst in het geheugen wordt
    gezet (Reason = DLL_PROCESS_ATTACH)}
  DLLProc := @MyDllProc;
  Indx := cBootEPArrayVariantIndexUnknown;
  if ( nDC > 0 ) then
    ModelProfile := TModelProfile.Create( nDC );
end.

