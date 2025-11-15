[Setup]
AppName=Hardware para Educación
AppVersion=1.0
AppPublisher=Hardware For Education Team
DefaultDirName={autopf}\Hardware para Educación
DefaultGroupName=Hardware para Educación
AllowNoIcons=yes
OutputDir=dist
OutputBaseFilename=Installer_HardwareForEducation_v3.0
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
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"kf
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
spanish.PythonInstallTitle=Instalación de Python
spanish.PythonInstallDescription=¿Desea instalar Python 3.13.5?
spanish.PythonInstallText=Python es requerido para ejecutar esta aplicación. Si no tiene Python instalado o tiene una versión anterior, se recomienda instalar Python 3.13.5.%n%n¿Desea continuar con la instalación de Python?
spanish.ArduinoInstallTitle=Instalación de Arduino IDE
spanish.ArduinoInstallDescription=¿Desea instalar Arduino IDE?
spanish.ArduinoInstallText=Arduino IDE es requerido para programar dispositivos Arduino. Si no tiene Arduino IDE instalado, se recomienda instalarlo.%n%n¿Desea continuar con la instalación de Arduino IDE?

english.PythonInstallTitle=Python Installation
english.PythonInstallDescription=Do you want to install Python 3.13.5?
english.PythonInstallText=Python is required to run this application. If you don't have Python installed or have an older version, it's recommended to install Python 3.13.5.%n%nDo you want to continue with Python installation?
english.ArduinoInstallTitle=Arduino IDE Installation
english.ArduinoInstallDescription=Do you want to install Arduino IDE?
english.ArduinoInstallText=Arduino IDE is required to program Arduino devices. If you don't have Arduino IDE installed, it's recommended to install it.%n%nDo you want to continue with Arduino IDE installation?

[Files]
; Application files - Go up 2 levels to reach Instalador folder, then access the folders
Source: "..\..\Python_For_Education\*"; DestDir: "{app}\Python_For_Education"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\Arduino_For_Education\*"; DestDir: "{app}\Arduino_For_Education"; Flags: ignoreversion recursesubdirs createallsubdirs

; Create launcher batch files - Go up 2 levels to reach Instalador folder
Source: "launcher.bat"; DestDir: "{app}"; Flags: ignoreversion

; External installers - Go up 2 levels to reach Instalador folder
Source: "python-3.13.5-amd64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall; Check: ShouldInstallPython
Source: "arduino-ide_2.3.6_Windows_64bit.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall; Check: ShouldInstallArduino

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
; Install Python if user agreed and not already installed
Filename: "{tmp}\python-3.13.5-amd64.exe"; Parameters: "/quiet InstallAllUsers=1 PrependPath=1 AssociateFiles=1 Shortcuts=0 Include_doc=0 Include_test=0"; StatusMsg: "Installing Python..."; Check: ShouldInstallPython; Flags: waituntilterminated

; Install Arduino IDE if user agreed and not already installed
Filename: "{tmp}\arduino-ide_2.3.6_Windows_64bit.exe"; Parameters: "/S"; StatusMsg: "Installing Arduino IDE..."; Check: ShouldInstallArduino; Flags: waituntilterminated

; Wait for installations to complete
Filename: "cmd"; Parameters: "/c timeout /t 10 /nobreak > nul"; StatusMsg: "Waiting for installations to complete..."; Check: ShouldInstallPython or ShouldInstallArduino; Flags: waituntilterminated runhidden

; Install Python dependencies using full path approach
Filename: "cmd"; Parameters: "/c ""{app}\launcher.bat"" --install-only"; StatusMsg: "Installing Python dependencies ..."; Flags: waituntilterminated runhidden; WorkingDir: "{app}"

[Code]
var
  InstallPython: Boolean;
  InstallArduino: Boolean;
  PythonPage: TInputOptionWizardPage;
  ArduinoPage: TInputOptionWizardPage;

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

function ShouldInstallPython: Boolean;
begin
  Result := InstallPython and (not IsPythonInstalled);
end;

function ShouldInstallArduino: Boolean;
begin
  Result := InstallArduino and (not IsArduinoInstalled);
end;

procedure InitializeWizard;
begin
  // Create Python installation page
  if not IsPythonInstalled then
  begin
    PythonPage := CreateInputOptionPage(wpSelectTasks,
      ExpandConstant('{cm:PythonInstallTitle}'),
      ExpandConstant('{cm:PythonInstallDescription}'),
      ExpandConstant('{cm:PythonInstallText}'),
      True, False);
    PythonPage.Add('Sí, instalar Python 3.13.5 (Recomendado)');
    PythonPage.Add('No, ya tengo Python instalado');
    PythonPage.SelectedValueIndex := 0; // Default to "Yes"
  end;

  // Create Arduino installation page
  if not IsArduinoInstalled then
  begin
    ArduinoPage := CreateInputOptionPage(wpSelectTasks,
      ExpandConstant('{cm:ArduinoInstallTitle}'),
      ExpandConstant('{cm:ArduinoInstallDescription}'),
      ExpandConstant('{cm:ArduinoInstallText}'),
      True, False);
    ArduinoPage.Add('Sí, instalar Arduino IDE (Recomendado)');
    ArduinoPage.Add('No, ya tengo Arduino IDE instalado');
    ArduinoPage.SelectedValueIndex := 0; // Default to "Yes"
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  
  // Handle Python installation choice
  if (PythonPage <> nil) and (CurPageID = PythonPage.ID) then
  begin
    InstallPython := PythonPage.SelectedValueIndex = 0;
  end;
  
  // Handle Arduino installation choice
  if (ArduinoPage <> nil) and (CurPageID = ArduinoPage.ID) then
  begin
    InstallArduino := ArduinoPage.SelectedValueIndex = 0;
  end;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := False;
  
  // Skip Python page if already installed
  if (PythonPage <> nil) and (PageID = PythonPage.ID) and IsPythonInstalled then
    Result := True;
    
  // Skip Arduino page if already installed
  if (ArduinoPage <> nil) and (PageID = ArduinoPage.ID) and IsArduinoInstalled then
    Result := True;
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
var
  S: String;
begin
  S := MemoDirInfo + NewLine + NewLine + MemoGroupInfo + NewLine + NewLine + MemoTasksInfo;
  
  // Add information about what will be installed
  if ShouldInstallPython then
    S := S + NewLine + NewLine + 'Python 3.13.5 will be installed';
    
  if ShouldInstallArduino then
    S := S + NewLine + 'Arduino IDE will be installed';
    
  Result := S;
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