# Installer_TinyCoders
Repositorio que alberga el código desarrollado para el instalador con una interfaz gráfica de usuario para el proyecto. Este instalador se desarrolló para facilitar su ejecución y puesta en marcha del aplicativo.
Enlace para descargar el instalador => [Instrucciones de Descarga](https://github.com/TinyCodersPUJ/Installer_TinyCoders/releases/tag/v2.0)
# Explicación del Código Fuente
Este instalador fue desarrollado usando un script de Inno Setup, un constructor de instaladores para aplicaciones Windows de código abierto. Para la creación de nuevas versiones del instalador, deberá tener en cuenta la siguiente estructura:
```
  /Arduino_For_Education #Clone the repository from [](https://github.com/Hardware-For-Education/Arduino_For_Education)
  /Python_For_Education #Clone the repository from [](https://github.com/TinyCodersPUJ/Python_For_Education_TinyCoders)
  /Installer
    setup.iss
    launcher.bat
    python_installer.exe #Download the .exe from the official Python website.
    arduino_installer.exe #Download the .exe from the official Arduino website.
```
- Deberá descargar Inno Setup desde la web oficial para adquirir el compilador que le permitirá _compilar_ el archivo setup.iss y crear un nuevo instalador. Los nuevos instaladores en formato _.exe_ se crearan en un directorio, dentro de la misma carpeta, que recibirá como nombre por defecto _/dist_.
- Dentro del archivo _setup.iss_ encontrará el código fuente de creación del instalador, en este encontrará resaltado con comentarios las rutas que deberá ajustar en caso de ser necesario dentro de su dispositivo para poder seguir trabajando en el instalador, además de información importante con respecto las propiedades de los instaladores generados, como el nombre y la versión. Para más información, consulte la documentación de Inno Setup [aqui](https://jrsoftware.org/isinfo.php).
