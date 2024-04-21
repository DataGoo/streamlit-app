import streamlit as st
import xlwings as xw
import pandas as pd
import tempfile
import shutil

def save_uploaded_file(uploaded_file):
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix='.xlsx') as tmp_file:
            shutil.copyfileobj(uploaded_file, tmp_file)
            return tmp_file.name
    except Exception as e:
        st.error(f"Error al guardar el archivo: {str(e)}")
        return None

def compare_excel_files(file1, file2):
    path1 = save_uploaded_file(file1)
    path2 = save_uploaded_file(file2)

    if path1 and path2:
        # Cargar los archivos de Excel
        wb1 = xw.Book(path1)
        wb2 = xw.Book(path2)
        
        sht1 = wb1.sheets[0]
        sht2 = wb2.sheets[0]
        
        # Convertir las hojas a DataFrames
        df1 = sht1.range('A1').options(pd.DataFrame, expand='table').value
        df2 = sht2.range('A1').options(pd.DataFrame, expand='table').value
        
        # Validación de índices
        if not df1.columns.equals(df2.columns):
            wb1.close()
            wb2.close()
            st.error("Los índices de las columnas no coinciden en ambos archivos.")
            return None, None

        # Encontrar las diferencias
        diff = df1.compare(df2)
        
        # Guardar las diferencias en un nuevo archivo de Excel
        wb_diff = xw.Book()
        sht_diff = wb_diff.sheets[0]
        sht_diff.range('A1').value = diff
        wb_diff.save('differences.xlsx')
        wb_diff.close()

        wb1.close()
        wb2.close()
        
        return 'differences.xlsx', diff
    else:
        return None, None

def main():
    st.title("Comparador de Archivos Excel")

    file1 = st.file_uploader("Sube el archivo Excel original", type=['xlsx'])
    file2 = st.file_uploader("Sube el archivo Excel a comparar", type=['xlsx'])
    
    if st.button("Comparar"):
        if file1 is not None and file2 is not None:
            with st.spinner('Comparando archivos...'):
                result_file, diff = compare_excel_files(file1, file2)
                if result_file:
                    st.success('Comparación completada!')
                    st.download_button('Descargar archivo con diferencias', open(result_file, 'rb'), file_name=result_file)
                    st.dataframe(diff)
                else:
                    st.error('Error al comparar los archivos')

if __name__ == "__main__":
    main()