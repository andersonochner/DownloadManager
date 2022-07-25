unit WindowsDirectoryValidation;

interface

uses
  DirectoryValidation;
type

  TWindowsDirectoryValidation = class (TInterfacedObject , IDirectoryValidation)

    function ValidateDirectory(const csDirectory : String) : Boolean;
  end;

implementation

uses
  System.IOUtils, System.SysUtils;

{ TWindowsDirectoryValidation }

function TWindowsDirectoryValidation.ValidateDirectory(
  const csDirectory: String): Boolean;
begin
  result := true;
  if not TDirectory.Exists(csDirectory) then
     begin
       if (csDirectory = '')
       or (not System.SysUtils.ForceDirectories(csDirectory)) then
           result := false;
     end;
end;

end.
