### README.md

# Proyecto: SSOO-I

Este proyecto es un script en Bash para gestionar citas médicas.

## Uso del Script

Para ejecutar el script, utiliza el siguiente comando:

```bash
./citas.sh [opciones]
```

### Opciones

- `-h`: Muestra esta ayuda.
- `-f`: Especifica el archivo de citas (si no existe, se creará).
- `-a`: Añade una cita nueva (se deben proporcionar los parámetros: `-n` nombre, `-e` especialidad, `-i` inicio, `-fi` fin, `-d` día, `-id` identificador).
- `-d`: Lista todas las citas de un mismo día.
- `-id`: Muestra una cita según su identificador.
- `-n`: Muestra una cita según nombre de paciente.
- `-i`: Muestra todas las citas según hora de inicio.

## Funciones del Script

### mostrar_ayuda

Muestra la ayuda del script incluyendo todas las opciones disponibles.

### mostrar_fichero

Muestra el contenido del archivo especificado.

### anadirCita

Añade una nueva cita al archivo de citas, verificando que no se dupliquen citas para el mismo paciente y que no haya solapamiento de citas en el mismo horario y especialidad.

### buscar_por_dia

Lista todas las citas de un día específico.

### buscar_por_id

Muestra una cita según su identificador.

### buscar_por_nombre

Muestra una cita según el nombre del paciente.

### buscar_por_hora_inicio

Muestra todas las citas según la hora de inicio.

## Variables Globales

- `FILE`: Archivo de citas.
- `accion`: Acción a realizar.
- `nombre_paciente`: Nombre del paciente.
- `especialidad`: Especialidad médica.
- `inicio`: Hora de inicio de la cita.
- `fin`: Hora de fin de la cita.
- `dia`: Día de la cita.
- `id`: Identificador de la cita.

Asegúrate de proporcionar todos los parámetros necesarios al añadir una cita y de que las horas de inicio y fin estén dentro del rango permitido (7 a 21 horas).

Puedes editar y añadir más detalles según lo necesites para completar el README.
