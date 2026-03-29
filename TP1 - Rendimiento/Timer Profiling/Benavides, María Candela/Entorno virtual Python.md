## Creación de un entorno virtual de python 

Para el uso de las herramientas necesarias para la generación del diagrama de flujo y gráficos de llamas,configure 
un entorno virtual de Python. Este paso fue fundamental, ya que evitar el error  `externally-managed-environment`


### Error 

Al querer instalar `pip install gprof2dot`, sn el entorno virtual  

``` pip install gprof2dot
error: externally-managed-environment

× This environment is externally managed
╰─> To install Python packages system-wide, try apt install
    python3-xyz, where xyz is the package you are trying to
    install.
    
    If you wish to install a non-Debian-packaged Python package,
    create a virtual environment using python3 -m venv path/to/venv.
    Then use path/to/venv/bin/python and path/to/venv/bin/pip. Make
    sure you have python3-full installed.
    
    If you wish to install a non-Debian packaged Python application,
    it may be easiest to use pipx install xyz, which will manage a
    virtual environment for you. Make sure you have pipx installed.
    
    See /usr/share/doc/python3.13/README.venv for more information.

note: If you believe this is a mistake, please contact your Python installation or OS distribution provider. You can override this, at the risk of breaking your Python installation or OS, by passing --break-system-packages.
hint: See PEP 668 for the detailed specification.
```


### Solución 

Crear y  activar el entorno   
1. Creación del entorno: `python3 -m venv venv`
2. Activar el entorno: `source venv/bin/activate` 


### Instalación de las herramientas 

Utilicé los siguientes comandos: 
  `pip install gprof2dot` 
  `sudo apt install graph`


