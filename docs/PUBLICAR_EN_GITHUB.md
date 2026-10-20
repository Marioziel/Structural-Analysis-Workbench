# Publicar Structural Analysis Workbench

La carpeta que debes convertir en repositorio es **`structural-analysis-workbench`**. Incluye todo su contenido, también los archivos ocultos `.gitignore` y `.gitattributes`. No añadas la carpeta superior `mathlab aero`.

El nombre sugerido para el repositorio es **`structural-analysis-workbench`** y el título del proyecto es **Structural Analysis Workbench**. Descripción sugerida:

> MATLAB structural analysis workbench with editable inputs, engineering diagrams, and generated calculation reports.

## Antes de publicar

1. Conserva la estructura completa: `matlab`, `docs`, `assets`, `verification` y los archivos de la raíz.
2. Ejecuta `START_HERE.m` en MATLAB y prueba el ejemplo inicial del integrado.
3. Revisa el README en inglés y elige una licencia si deseas autorizar la reutilización como proyecto de código abierto. Todavía no se ha asignado ninguna.
4. Crea el repositorio con esta carpeta como raíz y revisa la lista de archivos antes del primer commit. Si utilizas GitHub Desktop, la ruta local del repositorio debe corresponder a esta carpeta, no a su carpeta superior.
5. Publica ese repositorio en tu cuenta. Esta preparación no ha creado un repositorio remoto ni ha subido archivos.

Los PDF de referencia, el CAD del soporte, sus resultados `.mat`, las copias de seguridad y los temporales no forman parte del paquete. `.gitignore` también evita incorporar esos tipos de archivo accidentalmente. No uses `git add --force` para incorporarlos.

## Trabajo posterior

Esta carpeta es una copia independiente de la biblioteca de trabajo. Los cambios que hagas posteriormente en la carpeta original no se sincronizan solos. Trabaja en esta copia si será la versión del repositorio, o actualiza sus archivos de forma deliberada y repite las comprobaciones pertinentes.

Las huellas de `verification/source-manifest.json` describen los archivos al preparar esta copia; si los editas, esas huellas dejan de representar la nueva versión.
