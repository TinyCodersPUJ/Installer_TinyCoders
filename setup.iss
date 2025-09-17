[Setup]
AppName=Hardware para Educación
AppVersion=1.0
AppPublisher=Hardware For Education Team
DefaultDirName={autopf}\Hardware para Educación
DefaultGroupName=Hardware para Educación
AllowNoIcons=yes
OutputDir=dist
OutputBaseFilename=Installer_HardwareForEducation_v2.0
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; Set installer icon - Go up 2 levels to reach Instalador folder
SetupIconFile=..\..\Python_For_Education\python_for_education\images\Logo_2.ico
; Set uninstaller icon
UninstallDisplayIcon={app}\Python_For_Education\python_for_education\images\Logo_2.ico

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
; Application files - Go up 2 levels to reach Instalador folder, then access the folders
Source: "..\..\Python_For_Education\*"; DestDir: "{app}\Python_For_Education"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\Arduino_For_Education\*"; DestDir: "{app}\Arduino_For_Education"; Flags: ignoreversion recursesubdirs createallsubdirs

; Create launcher batch files - Go up 2 levels to reach Instalador folder
Source: "launcher.bat"; DestDir: "{app}"; Flags: ignoreversion

; External installers - Go up 2 levels to reach Instalador folder
Source: "python-3.13.5-amd64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall; Check: not IsPythonInstalled
Source: "arduino-ide_2.3.6_Windows_64bit.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall; Check: not IsArduinoInstalled

[Icons]
; Python application shortcut using batch launcher (most reliable) with icon
Name: "{group}\Hardware para Educación - Python"; Filename: "{app}\launcher.bat"; WorkingDir: "{app}"; IconFilename: "{app}\Python_For_Education\python_for_education\images\Logo_2.ico"
Name: "{autodesktop}\Hardware para Educación - Python"; Filename: "{app}\launcher.bat"; WorkingDir: "{app}"; IconFilename: "{app}\Python_For_Education\python_for_education\images\Logo_2.ico"; Tasks: desktopicon

; Arduino sketch shortcut WITHOUT custom icon (uses default .ino file icon)
Name: "{group}\Hardware para Educación - Arduino"; Filename: "{app}\Arduino_For_Education\Arduino_For_Education\Arduino_For_Education.ino"
Name: "{autodesktop}\Hardware para Educación - Arduino"; Filename: "{app}\Arduino_For_Education\Arduino_For_Education\Arduino_For_Education.ino"; Tasks: desktopicon

; Uninstall shortcut with icon
Name: "{group}\{cm:UninstallProgram,Hardware para Educación}"; Filename: "{uninstallexe}"; IconFilename: "{app}\Python_For_Education\python_for_education\images\Logo_2.ico"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Run]
; Install Python if not present with enhanced PATH configuration
Filename: "{tmp}\python-3.13.5-amd64.exe"; Parameters: "/quiet InstallAllUsers=1 PrependPath=1 AssociateFiles=1 Shortcuts=0 Include_doc=0 Include_test=0"; StatusMsg: "Installing Python..."; Check: not IsPythonInstalled; Flags: waituntilterminated

; Install Arduino IDE if not present
Filename: "{tmp}\arduino-ide_2.3.6_Windows_64bit.exe"; Parameters: "/S"; StatusMsg: "Installing Arduino IDE..."; Check: not IsArduinoInstalled; Flags: waituntilterminated

; Wait for installations to complete
Filename: "cmd"; Parameters: "/c timeout /t 10 /nobreak > nul"; StatusMsg: "Waiting for the Python installation to complete ..."; Check: not IsPythonInstalled; Flags: waituntilterminated runhidden

; Install Python dependencies using full path approach
Filename: "cmd"; Parameters: "/c ""{app}\launcher.bat"" --install-only"; StatusMsg: "Installing Python dependencies ..."; Flags: waituntilterminated runhidden; WorkingDir: "{app}"

[Code]
function IsPythonInstalled: Boolean;
var
  ResultCode: Integer;
begin
  // First try py launcher (most reliable)
  Result := Exec('py', '--version', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) and (ResultCode = 0);
  
  // If py launcher fails, try python command
  if not Result then
  begin
    Result := Exec('python', '--version', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) and (ResultCode = 0);
  end;
  
  // Also check for Python installation files
  if not Result then
  begin
    Result := FileExists(ExpandConstant('{autopf}\Python313\python.exe')) or
              FileExists(ExpandConstant('{autopf}\Python312\python.exe')) or
              FileExists(ExpandConstant('{autopf}\Python311\python.exe')) or
              FileExists(ExpandConstant('{localappdata}\Programs\Python\Python313\python.exe')) or
              FileExists(ExpandConstant('{localappdata}\Programs\Python\Python312\python.exe'));
  end;
end;

function IsArduinoInstalled: Boolean;
begin
  // Check for Arduino IDE 2.x installations
  Result := FileExists(ExpandConstant('{autopf}\Arduino IDE\Arduino IDE.exe')) or 
            FileExists(ExpandConstant('{localappdata}\Programs\Arduino IDE\Arduino IDE.exe'));
  
  // Check for legacy Arduino IDE 1.x installations
  if not Result then
  begin
    Result := FileExists(ExpandConstant('{autopf}\Arduino\arduino.exe')) or
              FileExists(ExpandConstant('{commonpf32}\Arduino\arduino.exe'));
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Log completion
    Log('Installation completed. Python dependencies should be installed.');
  end;
end;

// Override the wizard page text dynamically
function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
begin
  Result := MemoDirInfo + NewLine + NewLine + MemoGroupInfo + NewLine + NewLine + MemoTasksInfo;
end;

// Function to get localized finish text
function GetFinishText(): String;
begin
  if ActiveLanguage = 'spanish' then
    Result := #13#10 + 'Puede ejecutar la aplicación utilizando los accesos directos creados.' + #13#10#13#10 + 
              'Haga clic en Finalizar para salir del programa de instalación.'
  else
    Result := 'You can run the application using the created shortcuts.' + #13#10#13#10 + 
              'Click Finish to exit Setup.';
end;

// Function to get localized finish heading
function GetFinishHeading(): String;
begin
  if ActiveLanguage = 'spanish' then
    Result := '¡Felicidades! Has completado el proceso de instalación de Hardware para Educación.' + #13#10
  else
    Result := 'Congratulations! You have completed the Hardware para Educación installation.' + #13#10 ;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  // Override the finish page text when it's displayed
  if CurPageID = wpFinished then
  begin
    WizardForm.FinishedHeadingLabel.Caption := GetFinishHeading();
    WizardForm.FinishedLabel.Caption := GetFinishText();
  end;
end;