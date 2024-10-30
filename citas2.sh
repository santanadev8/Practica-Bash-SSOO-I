# Función para mostrar ayuda
function mostrar_ayuda() {
    echo "Uso del script: ./citas.sh [opciones]"
    echo "-h: Muestra esta ayuda"
    echo "-f: Especifica el archivo de citas (si no existe, se creará)"
    echo "-a: Añade una cita nueva (se deben proporcionar los parámetros: -n nombre, -e especialidad, -i inicio, -fi fin, -d dia, -id identificador)"
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
function anadirCita() {
    local nombre_paciente="$1"
    local especialidad="$2"
    local inicio="$3"
    local fin="$4"
    local dia="$5"
    local id="$6"
    local archivo="$7"

    # Verificación de parámetros obligatorios
    if [[ -z "$nombre_paciente" || -z "$especialidad" || -z "$inicio" || -z "$fin" || -z "$dia" || -z "$id" ]]; then
        echo "Error: Todos los parámetros son obligatorios (-n, -e, -i, -fi, -d, -id)."
        return 1
    fi

    # Verificación para no duplicar nombres de pacientes
    if grep "^PACIENTE: $nombre_paciente$" "$archivo" > /dev/null 2>&1; then
        echo "Error: Ya existe una cita para el paciente $nombre_paciente."
        return 1
    fi

    # Verificación para no solapar citas
    while IFS= read -r line; do
        cita=""
        while [[ "$line" ]]; do
            cita+="$line"$'\n'
            read -r line
        done

        cita_inicio_actual=$(echo "$cita" | grep "HORA_INICIAL" | cut -d ' ' -f 2)
        cita_fin_actual=$(echo "$cita" | grep "HORA_FINAL" | cut -d ' ' -f 2)
        cita_dia_actual=$(echo "$cita" | grep "DIA" | cut -d ' ' -f 2)
        cita_especialidad_actual=$(echo "$cita" | grep "ESPECIALIDAD" | cut -d ' ' -f 2-)

        if [[ "$cita_dia_actual" == "$dia" && ("$inicio" -le "$cita_fin_actual" && "$fin" -ge "$cita_inicio_actual") && ("$cita_especialidad_actual" == "$especialidad") ]]; then
            echo "Error: La cita se solapa con otra ya existente."
            return 1
        fi
    done < "$archivo"

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
    } >> "$archivo"
    echo "Cita añadida correctamente"
}

# Función para listar citas de un día específico
function buscar_por_dia() {
    local dia="$1"
    local archivo="$2"
    if [[ -f "$archivo" ]]; then
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
        done < "$archivo"
    else
        echo "El fichero no existe"
    fi
}

# Función para buscar una cita por ID
function buscar_por_id() {
    local id="$1"
    local archivo="$2"
    if [[ -f "$archivo" ]]; then
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
        done < "$archivo"
    else
        echo "El fichero no existe"
    fi
}

# Función para buscar una cita por nombre de paciente
function buscar_por_nombre() {
    local nombre_paciente="$1"
    local archivo="$2"
    if [[ -f "$archivo" ]]; then
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
        done < "$archivo"
    else
        echo "El fichero no existe"
    fi
}

# Función para buscar citas por hora de inicio
function buscar_por_hora_inicio() {
    local inicio="$1"
    local archivo="$2"
    if [[ -f "$archivo" ]]; then
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
        done < "$archivo"
    else
        echo "El fichero no existe"
    fi
}
# POR DONDE ENTRA EL PROGRAMA PRINCIPAL

# Variables globales para almacenar opciones y sus valores
FILE=""
accion=""
nombre_paciente=""
especialidad=""
inicio=""
fin=""
dia=""
id=""

# Verificar si se proporcionaron al menos un argumento
if [[ $# -lt 1 ]]; then
    echo -e "Tienes que introducir al menos un argumento.\n"
    mostrar_ayuda
    exit 1
fi

# Recopilar todos los argumentos restantes
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f)
            if [[ $# -lt 2 ]]; then
                echo "Error: La opción -f requiere un argumento."
                exit 1
            fi
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
            accion="anadirCita"
            shift
            ;;
        -d)
            if [[ $# -lt 2 ]]; then
                echo "Error: La opción -d requiere un argumento."
                exit 1
            fi
            if [[ "$accion" != "anadirCita" ]]; then
                accion="buscar_por_dia"
            fi
            dia="$2"
            shift 2
            ;;
        -id)
            if [[ $# -lt 2 ]]; then
                echo "Error: La opción -id requiere un argumento."
                exit 1
            fi
            if [[ "$accion" != "anadirCita" ]]; then
                accion="buscar_por_id"
            fi
            id="$2"
            shift 2
            ;;
        -n)
            if [[ $# -lt 4 ]]; then
                echo "Error: La opción -n requiere tres argumentos (nombre y dos apellidos)."
                exit 1
            fi
            if [[ "$accion" != "anadirCita" ]]; then
                accion="buscar_por_nombre"
            fi
            nombre_paciente="$2 $3 $4"
            shift 4
            ;;
        -e)
            if [[ $# -lt 2 ]]; then
                echo "Error: La opción -e requiere un argumento."
                exit 1
            fi
            especialidad="$2"
            shift 2
            while [[ $# -gt 0 && "$1" != -* ]]; do
                especialidad="$especialidad $1"
                shift
            done
            ;;
        -i)
            if [[ $# -lt 2 ]]; then
                echo "Error: La opción -i requiere un argumento."
                exit 1
            fi
            if [[ "$accion" != "anadirCita" ]]; then
                accion="buscar_por_hora_inicio"
            fi
            inicio="$2"
            if [[ "$inicio" -lt 7 || "$inicio" -gt 21 ]]; then
                echo "Error: La hora de inicio debe estar entre las 7 y las 21."
                exit 1
            fi
            shift 2
            ;;
        -fi)
            if [[ $# -lt 2 ]]; then
                echo "Error: La opción -fi requiere un argumento."
                exit 1
            fi
            fin="$2"
            if [[ "$fin" -lt 7 || "$fin" -gt 21 ]]; then
                echo "Error: La hora de fin debe estar entre las 7 y las 21."
                exit 1
            fi
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
    anadirCita)
        anadirCita "$nombre_paciente" "$especialidad" "$inicio" "$fin" "$dia" "$id" "$FILE"
        ;;
    buscar_por_dia)
        buscar_por_dia "$dia" "$FILE"
        ;;
    buscar_por_id)
        buscar_por_id "$id" "$FILE"
        ;;
    buscar_por_nombre)
        buscar_por_nombre "$nombre_paciente" "$FILE"
        ;;
    buscar_por_hora_inicio)
        buscar_por_hora_inicio "$inicio" "$FILE"
        ;;
    *)
        mostrar_fichero "$FILE"
        exit 1
        ;;
esac