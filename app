import openai
from openai import OpenAI
import streamlit as st
import pandas as pd
# Título de la aplicación
st.title("Análisis Exploratorio de Datos de un CSV")

# Aquí comienza tu nueva sección para cargar y mostrar datos del CSV
st.write("---")
st.header("Análisis Exploratorio de Datos de un CSV")

# Cargar archivo CSV
uploaded_file = st.file_uploader("Elige un archivo CSV", type="csv")
if uploaded_file is not None:
    # Leer el archivo CSV
    df = pd.read_csv(uploaded_file)

    # Mostrar los primeros datos del dataframe
    st.subheader("Primeros datos del CSV:")
    st.write(df.head())

    st.subheader("Ultimos datos del CSV:")
    st.write(df.tail())

    # Realizar análisis básico y mostrar en la aplicación
    st.subheader("Análisis Básico del CSV")

    # Mostrar descripción estadística
    st.write("Descripción Estadística:")
    st.write(df.describe())

    # Crear y mostrar un gráfico
    st.subheader("Visualización de Datos")
    if st.checkbox("Mostrar gráfico de correlación"):
        # Calcular correlaciones
        corr = df.corr()

        # Crear un mapa de calor
        fig, ax = plt.subplots()
        sns.heatmap(corr, annot=True, ax=ax)
        st.write(fig)

# Código para visualizaciones y análisis estadístico

# Análisis Estadístico Descriptivo
if st.checkbox("Mostrar análisis estadístico descriptivo"):
    st.write(df.describe())

# Visualización de datos faltantes con un gráfico de barras y una tabla
if st.checkbox("Visualizar datos faltantes"):
    # Contar los datos nulos en cada columna
    null_counts = df.isnull().sum()

    # Filtrar las columnas que tienen datos nulos
    null_counts = null_counts[null_counts > 0]

    if null_counts.empty:
        st.write("No hay datos faltantes en el dataset.")
    else:
        # Mostrar la tabla con datos faltantes
        st.write("Datos faltantes por columna:")
        st.table(null_counts.reset_index(name="Cantidad Faltante").rename(columns={'index': 'Columna'}))

        # Configurar el tamaño del gráfico
        plt.figure(figsize=(10, 5))

        # Crear un gráfico de barras de los conteos de datos nulos
        sns.barplot(x=null_counts.index, y=null_counts.values)

        # Añadir título y etiquetas para una mejor comprensión
        plt.title('Cantidad de Datos Faltantes por Columna')
        plt.xlabel('Columnas')
        plt.ylabel('Cantidad de Datos Faltantes')
        plt.xticks(rotation=45)

        # Mostrar el gráfico en Streamlit
        st.pyplot(plt)

# Filtrado de datos
if st.checkbox("Seleccionar columnas específicas para análisis"):
    selected_columns = st.multiselect("Selecciona columnas", df.columns)
    if selected_columns:
        st.write(df[selected_columns].describe())


# Función para generar el link de descarga de un DataFrame como CSV
def get_table_download_link(df, filename='archivo.csv', text='Descargar CSV'):
    # Convertir el DataFrame a CSV
    csv = df.to_csv(index=False)
    # Crear un objeto BytesIO
    b64 = base64.b64encode(csv.encode()).decode()
    # Crear el link de descarga
    href = f'<a href="data:file/csv;base64,{b64}" download="{filename}">{text}</a>'
    return href

# Exportar datos
if st.button("Exportar análisis como CSV"):
    # Generar el link de descarga para el DataFrame 'df.describe()'
    tmp_download_link = get_table_download_link(df.describe(), filename="analisis_descriptivo.csv", text="Descargar análisis como CSV")
    # Mostrar el link de descarga
    st.markdown(tmp_download_link, unsafe_allow_html=True)
