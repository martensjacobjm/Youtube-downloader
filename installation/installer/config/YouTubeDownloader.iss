; YouTube Downloader - InnoSetup Installer Script
; Skapar en professionell Windows-installer

#define MyAppName "YouTube Downloader"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "YouTube Downloader Team"
#define MyAppURL "https://github.com/martensjacobjm/Youtube-downloader"
#define MyAppExeName "YouTubeDownloader.exe"

[Setup]
; Grundinställningar
AppId={{E8F5D9C2-4A3B-4F1E-9D2C-8A7B6C5D4E3F}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=..\..\..\LICENSE
OutputDir=..\..\dist
OutputBaseFilename=YouTubeDownloader-Setup-{#MyAppVersion}
SetupIconFile=..\..\..\assets\icon.ico
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
DisableWelcomePage=no
DisableDirPage=no
DisableProgramGroupPage=yes

[Languages]
Name: "swedish"; MessagesFile: "compiler:Languages\Swedish.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
swedish.ChooseOutputDir=Välj var nedladdade videor ska sparas:
english.ChooseOutputDir=Choose where to save downloaded videos:
swedish.OutputDirLabel=Nedladdningsmapp:
english.OutputDirLabel=Download folder:
swedish.DownloadComponents=Laddar ner nödvändiga komponenter (yt-dlp, ffmpeg)...
english.DownloadComponents=Downloading required components (yt-dlp, ffmpeg)...

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1; Check: not IsAdminInstallMode

[Files]
; Programfiler från release-paketet
Source: "..\..\release\app\YouTubeDownloader.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\release\app\scripts\YouTube_Downloader_GUI.ps1"; DestDir: "{app}\scripts"; Flags: ignoreversion
Source: "..\..\release\app\scripts\Download-Dependencies.ps1"; DestDir: "{app}\scripts"; Flags: ignoreversion
Source: "..\..\release\app\version.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\release\app\README.md"; DestDir: "{app}"; Flags: ignoreversion isreadme; Check: FileExists(ExpandConstant('{#SourcePath}\..\..\release\app\README.md'))
Source: "..\..\release\app\LICENSE"; DestDir: "{app}"; Flags: ignoreversion; Check: FileExists(ExpandConstant('{#SourcePath}\..\..\release\app\LICENSE'))

; Assets (om dom finns)
Source: "..\..\..\assets\*"; DestDir: "{app}\assets"; Flags: ignoreversion recursesubdirs createallsubdirs; Check: DirExists(ExpandConstant('{#SourcePath}\..\..\..\assets'))

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Registry]
; Spara output-mapp i registry
Root: HKCU; Subkey: "Software\{#MyAppName}"; Flags: uninsdeletekeyifempty
Root: HKCU; Subkey: "Software\{#MyAppName}\Settings"; ValueType: string; ValueName: "OutputDir"; ValueData: "{code:GetOutputDir}"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\{#MyAppName}\Settings"; ValueType: string; ValueName: "Version"; ValueData: "{#MyAppVersion}"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\{#MyAppName}\Settings"; ValueType: string; ValueName: "InstallDir"; ValueData: "{app}"; Flags: uninsdeletevalue

[Code]
var
  OutputDirPage: TInputDirWizardPage;
  DownloadPage: TOutputProgressWizardPage;

procedure InitializeWizard;
begin
  // Skapa sida för att välja output-mapp
  OutputDirPage := CreateInputDirPage(wpSelectDir,
    CustomMessage('ChooseOutputDir'),
    CustomMessage('OutputDirLabel'),
    'Välj mappen där dina nedladdade YouTube-videor ska sparas.' + #13#10 +
    'Du kan ändra detta senare i inställningarna.',
    False, '');
  OutputDirPage.Add('');
  OutputDirPage.Values[0] := ExpandConstant('{userdocs}\YouTube Downloads');
end;

function GetOutputDir(Param: String): String;
begin
  Result := OutputDirPage.Values[0];
end;

procedure CreateOutputDir;
var
  OutputDir: String;
begin
  OutputDir := OutputDirPage.Values[0];
  if not DirExists(OutputDir) then
    ForceDirectories(OutputDir);
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  Result := '';
  CreateOutputDir;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
  PowerShellCmd: String;
begin
  if CurStep = ssPostInstall then
  begin
    // Skapa output-mappen
    CreateOutputDir;

    // Kör download-script för att hämta yt-dlp och ffmpeg
    PowerShellCmd := 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' +
      ExpandConstant('{app}\scripts\Download-Dependencies.ps1') + '" -InstallDir "' +
      ExpandConstant('{app}') + '"';

    Exec('cmd.exe', '/c ' + PowerShellCmd, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;

function InitializeUninstall(): Boolean;
var
  Response: Integer;
begin
  Response := MsgBox('Vill du även ta bort nedladdade videor och inställningar?',
    mbConfirmation, MB_YESNOCANCEL);

  if Response = IDYES then
  begin
    // Ta bort allt
    Result := True;
  end
  else if Response = IDNO then
  begin
    // Behåll nedladdningar och inställningar
    Result := True;
  end
  else
  begin
    // Avbryt avinstallation
    Result := False;
  end;
end;

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
