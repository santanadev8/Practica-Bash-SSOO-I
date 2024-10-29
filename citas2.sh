#!/bin/bash

# Función para mostrar ayuda
function mostrar_ayuda() {
    echo "Uso del script: ./citas.sh [opciones]"
    echo "-h: Muestra esta ayuda"
    echo "-f: Especifica el archivo de citas (si no existe, se creará)"
    echo "-a: Añade una cita nueva (se deben proporcionar los parámetros: -n nombre, -e especialidad, -i inicio, -f fin, -d dia, -id identificador)"
    echo "-d: Lista todas las citas de un mismo día"
    echo "-id: Muestra una cita según su identificador"
    echo "-n: Muestra una cita según nombre de paciente"
    echo "-i: Muestra todas las citas según hora de inicio"
}

# Función para mostrar contenido del archivo
function mostrar_fichero() {
    local archivo="$1"
    if [[ -f "$archivo" ]]; then
        cat "$archivo"
    else
        echo "El fichero no existe"
    fi
}

# Función para añadir una cita
function añadir_cita() {

    # Verificación de parámetros obligatorios
    if [[ -z "$nombre_paciente" || -z "$especialidad" || -z "$inicio" || -z "$fin" || -z "$dia" || -z "$id" ]]; then
        echo "Error: Todos los parámetros son obligatorios (-n, -e, -i, -f, -d, -id)."
        return 1
    fi

    # Verificación para no duplicar citas con la misma especialidad, hora y día
    if grep "ESPECIALIDAD: $especialidad" "$FILE" > /dev/null 2>&1 && grep "HORA_INICIAL: $inicio" "$FILE" > /dev/null 2>&1 && grep "DIA: $dia" "$FILE" > /dev/null 2>&1; then
        echo "Error: Ya existe una cita para la especialidad $especialidad a las $inicio en el día $dia."
        return 1
    fi

    # Mostrar los valores que se agregarán
    echo "Añadiendo cita con los siguientes datos:"
    echo "PACIENTE: $nombre_paciente"
    echo "ESPECIALIDAD: $especialidad"
    echo "HORA_INICIAL: $inicio"
    echo "HORA_FINAL: $fin"
    echo "DIA: $dia"
    echo "ID: $id"

    # Añadir la cita al archivo
    {
        echo ""
        echo "PACIENTE: $nombre_paciente"
        echo "ESPECIALIDAD: $especialidad"
        echo "HORA_INICIAL: $inicio"
        echo "HORA_FINAL: $fin"
        echo "DIA: $dia"
        echo "ID: $id"
        echo ""
    } >> "$FILE"

    echo "Cita añadida correctamente"
}

# Función para listar citas de un día específico
function buscar_por_dia() {
    if [[ -f "$FILE" ]]; then
        while IFS= read -r line; do
            cita=""
            while [[ "$line" ]]; do
                cita+="$line"$'\n'
                read -r line
            done

            if echo "$cita" | grep "^DIA: $dia$" > /dev/null; then
                echo -e "$cita"
                echo ""
            fi
        done < "$FILE"
    else
        echo "El fichero no existe"
    fi
}

# Función para buscar una cita por ID
function buscar_por_id() {
    if [[ -f "$FILE" ]]; then
        while IFS= read -r line; do
            cita=""
            while [[ "$line" ]]; do
                cita+="$line"$'\n'
                read -r line
            done

            if echo "$cita" | grep "^ID: $id$" > /dev/null; then
                echo -e "$cita"
                echo ""
            fi
        done < "$FILE"
    else
        echo "El fichero no existe"
    fi
}

# Función para buscar una cita por nombre de paciente
function buscar_por_nombre() {
    if [[ -f "$FILE" ]]; then
        while IFS= read -r line; do
            cita=""
            while [[ "$line" ]]; do
                cita+="$line"$'\n'
                read -r line
            done

            if echo "$cita" | grep "^PACIENTE: $nombre_paciente$" > /dev/null; then
                echo -e "$cita"
                echo ""
            fi
        done < "$FILE"
    else
        echo "El fichero no existe"
    fi
}

# Función para buscar citas por hora de inicio
function buscar_por_hora_inicio() {
    if [[ -f "$FILE" ]]; then
        while IFS= read -r line; do
            cita=""
            while [[ "$line" ]]; do
                cita+="$line"$'\n'
                read -r line
            done

            if echo "$cita" | grep "^HORA_INICIAL: $inicio$" > /dev/null; then
                echo -e "$cita"
                echo ""
            fi
        done < "$FILE"
    else
        echo "El fichero no existe"
    fi
}

# Variables para almacenar opciones y sus valores
FILE=""
accion=""
nombre_paciente=""
especialidad=""
inicio=""
fin=""
dia=""
id=""

# Verificar si se proporcionaron argumentos
if [[ $# -lt 1 ]]; then
    echo -e "Tienes que introducir al menos un argumento.\n"
    mostrar_ayuda
    exit 1
fi

# Recopilar todos los argumentos restantes
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f)
            shift
            FILE="$1"
            if [[ ! -f "$FILE" ]]; then
                touch "$FILE"
            fi
            shift
            ;;
        -h)
            mostrar_ayuda
            exit 0
            ;;
        -a)
            accion="añadir_cita"
            shift
            ;;
        -d)
            if [[ "$accion" != "añadir_cita" ]]; then
                accion="buscar_por_dia"
            fi
            dia="$2"
            shift 2
            ;;
        -id)
            if [[ "$accion" != "añadir_cita" ]]; then
                accion="buscar_por_id"
            fi
            id="$2"
            shift 2
            ;;
        -n)
            if [[ "$accion" != "añadir_cita" ]]; then
                accion="buscar_por_nombre"
            fi
            nombre_paciente="$2"
            shift 2
            while [[ $# -gt 0 && "$1" != -* ]]; do
                nombre_paciente="$nombre_paciente $1"
                shift
            done
            ;;
        -e)
            especialidad="$2"
            shift 2
            while [[ $# -gt 0 && "$1" != -* ]]; do
                especialidad="$especialidad $1"
                shift
            done
            ;;
        -i)
            if [[ "$accion" != "añadir_cita" ]]; then
                accion="buscar_por_hora_inicio"
            fi
            inicio="$2"
            shift 2
            ;;
        -fi)
            fin="$2"
            shift 2
            ;;
        *)
            echo "Argumento no reconocido: $1"
            exit 1
            ;;
    esac
done

# Llamar a la función correspondiente basada en el valor de 'accion'
case "$accion" in
    añadir_cita)
        añadir_cita
        ;;
    buscar_por_dia)
        buscar_por_dia "$dia"
        ;;
    buscar_por_id)
        buscar_por_id "$id"
        ;;
    buscar_por_nombre)
        buscar_por_nombre "$nombre_paciente"
        ;;
    buscar_por_hora_inicio)
        buscar_por_hora_inicio "$inicio"
        ;;
    *)
        mostrar_fichero "$FILE"
        exit 1
        ;;
esac