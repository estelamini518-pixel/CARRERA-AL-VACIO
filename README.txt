CARRERA AL VACÍO — PROYECTO FLUTTER

Este ZIP contiene el código fuente del juego, no un APK ya compilado.
Incluye un workflow corregido para generar el APK en GitHub Actions.

CARPETAS/ARCHIVOS:
- lib/main.dart: juego espacial.
- pubspec.yaml: configuración Flutter con una sola clave sdk.
- .github/workflows/build-apk.yml: compilación automática del APK.
- No se incluye test/widget_test.dart, para evitar el error anterior de MyApp.

SUBIR A GITHUB:
1. Extrae este ZIP en tu computadora.
2. Abre tu repositorio LABORATORIO en GitHub.
3. En Code, sube los archivos y carpetas de DENTRO de esta carpeta.
4. Reemplaza pubspec.yaml, lib/main.dart y .github/workflows/build-apk.yml si ya existen.
5. Confirma que la ruta del workflow sea exactamente .github/workflows/build-apk.yml.
6. Entra a Actions y espera que termine “Compilar Carrera al Vacío”.
7. Si aparece Success, descarga el artefacto “Carrera-al-Vacio-APK” y extrae app-release.apk.

JUEGO:
- La nave espacial se mueve con las flechas de izquierda y derecha.
- Las estrellas dan puntos.
- La sombra persigue a la nave; tienes 3 vidas.
- Cuando la sombra está cerca, encuentra el agujero negro para saltar de nivel.
- Llega al nivel 5 para ganar.
