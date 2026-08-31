# Mac Desktop Sorter

Una app ligera de barra de menús para macOS que ordena los iconos del Escritorio por su fecha de creación.

## Qué hace

- Más recientes primero.
- Más antiguos primero.
- Alterna entre ambos sentidos.
- Conserva las posiciones disponibles de la cuadrícula actual, en lugar de inventar una resolución o distribución nueva.
- Puede iniciarse al abrir sesión (macOS 13 o posterior).

La app no lee ni modifica el contenido de los archivos. Solo consulta su fecha de creación y pide a Finder que actualice la posición visual de cada icono.

## Abrir y ejecutar

1. Abre `MacDesktopSorter.xcodeproj` con Xcode 15 o posterior.
2. En **Signing & Capabilities**, selecciona tu equipo de desarrollo si Xcode lo solicita.
3. Elige el destino **My Mac** y pulsa Ejecutar.
4. Busca el icono de flechas en la barra de menús.

Antes de ordenar, en el Escritorio usa clic secundario y elige **Ordenar por > Ninguno**. Si Finder conserva un orden automático, puede recolocar los iconos después de que la app termine.

## Permisos

En el primer intento macOS solicitará autorización para que la app controle Finder. Pulsa **Permitir**. Si la rechazaste, actívala en:

`Configuración del Sistema > Privacidad y seguridad > Automatización > Desktop Date Sorter > Finder`

No necesita Accesibilidad ni acceso total al disco.

## Publicación open source

El repositorio está preparado para publicarse con licencia MIT. El identificador de la app es `io.horas.macdesktopsorter`; añade capturas de pantalla al README antes de publicarlo si quieres.

## Limitaciones conocidas

- Finder controla la representación del Escritorio; la app automatiza la posición de los iconos mediante su interfaz de scripting.
- En varios monitores, conserva y reutiliza todas las posiciones existentes; no mueve iconos entre pantallas ni intenta adivinar su geometría.
- Los volúmenes externos que Finder muestre en el Escritorio pueden no aceptar un cambio de posición; se omiten sin interrumpir el resto.
