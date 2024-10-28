#!/bin/bash

# Crear archivo de citas si no existe
# if [[$FILE == "datos.txt"]]; then
#     echo "Archivo ya existe" > /dev/null
# else
#     touch datos.txt
#     echo "Archivo creado"
# fi

# Archivo de citas
#FILE="datos.txt"

# Función para mostrar ayuda
function mostrar_ayuda() {
    echo "Uso del script: ./citas.sh [opciones]"
    echo "-h: Muestra esta ayuda"
    echo "-f: Muestra el contenido completo del fichero"
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
# Función para añadir una cita
function añadir_cita() {
    local nombre_paciente=""
    local especialidad=""
    local inicio=""
    local fin=""
    local dia=""
    local id=""

    # Procesar los parámetros
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -n)
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
                inicio="$2"
                shift 2
                ;;
            -f)
                fin="$2"
                shift 2
                ;;
            -d)
                dia="$2"
                shift 2
                ;;
            -id)
                id="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

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


# Función para listar citas de un día
function buscar_por_dia() {
    if [[ -f "$FILE" ]]; then
        # Usamos un bucle para leer el archivo línea por línea
        while IFS= read -r line; do
            # Guardamos el bloque de citas
            cita=""
            # Comenzamos a construir un bloque de citas
            while [[ "$line" ]]; do
                cita+="$line"$'\n' 
                read -r line  
            done
            
            # Verificamos si el bloque contiene la fecha deseada
            if [[ "$cita" == *"DIA: $1"* ]]; then
                echo -e "$cita"  
                echo "" 
            fi
        done < "$FILE"
    else
        echo "El fichero no existe"
    fi
}


function buscar_por_id() {
    if [[ -f "$FILE" ]]; then
        while IFS= read -r line; do
            cita=""
            while [[ "$line" ]]; do
                cita+="$line"$'\n'  
                read -r line 
            done
            
            if [[ "$cita" == *"ID: $1"* ]]; then
                echo -e "$cita"  
                echo ""  
            fi
        done < "$FILE"
    else
        echo "El fichero no existe"
    fi
}

function buscar_por_nombre() {
    if [[ -f "$FILE" ]]; then
        nombre_paciente="$1"
        shift
        while [[ $# -gt 0 && "$1" != -* ]]; do
            nombre_paciente="$nombre_paciente $1"
            shift
        done

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

function buscar_por_hora_inicio() {
    if [[ -f "$FILE" ]]; then
        while IFS= read -r line; do
            cita=""
            while [[ "$line" ]]; do
                cita+="$line"$'\n'  
                read -r line 
            done
        
            if [[ "$cita" == *"HORA_INICIAL: $1"* ]]; then
                echo -e "$cita" 
                echo ""  
            fi
        done < "$FILE"
    else
        echo "El fichero no existe"
    fi
}

# Verifica los argumentos
if [[ $# -lt 1 ]]; then
    echo -e "Tienes que introducir al menos un argumento.\n"
    mostrar_ayuda
    exit 1
fi

# Comprobacion de argumentos
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h)
            mostrar_ayuda
            exit 0
            ;;
        -f)
            shift
            FILE=$(find . -name "$1")
            if [[ -z "$FILE" ]]; then
                FILE="$1"
                touch "$FILE"
            else
                FILE="$1"
            fi
            ;;
        -a)
            shift
            añadir_cita "$@"
            exit 0
            ;;
        -d)
            shift
            buscar_por_dia "$1"
            exit 0
            ;;
        -id)
            shift
            buscar_por_id "$1"
            exit 0
            ;;
        -n)
            shift
            buscar_por_nombre "$1" "$2" "$3"
            exit 0
            ;;
        -i)
            shift
            buscar_por_hora_inicio "$1"
            exit 0
            ;;
        *)
            echo -e "Opción no válida: $1\n"
            mostrar_ayuda
            exit 1
            ;;
    esac
    shift
done

# Si se especifica el archivo pero no se da ninguna opción adicional, mostrar el contenido del archivo
if [[ -n "$FILE" ]]; then
    mostrar_fichero "$FILE"
fi