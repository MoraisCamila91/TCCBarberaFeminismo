import streamlit as st
import pandas as pd
import plotly.express as px

import functions as fc

# st.beta_set_page_title('Gráficos "Diga-me quem segues..."')

@st.cache(allow_output_mutation=True)
def load_data():
	df = pd.read_csv("../resumo_resultados/pontos_ideais_outras_infos.csv")
	df['seguidores_analisados_rel'] = df['seguidores_analisados']/df['seguidores_analisados'].max()

	df.loc[df['nome'].isin(['Instituto Marielle Franco', 
				'Anielle Franco', 
                        	'Monica Benicio',
	                        'negaluy']), 'marielle_family'] = 'Família Marielle'
	df['marielle_family'].fillna('Não Família Marielle', inplace=True)

	df.loc[df['partido'].isin(['PSOL', 'PT', 'PCB', 'PCdoB', 'PSL', 'Republicanos', 'PRTB']), 'partido_str'] = df['partido']
	df.loc[(~df['partido'].isin(['PSOL', 'PT', 'PCB', 'PCdoB', 'PSL', 'Republicanos', 'PRTB'])) & (df['partido'] != ''), 'partido_str'] = 'Partido Pequeno'
	df['partido_str'].fillna('Sem Partido Encontrado', inplace=True)

	df.loc[df['nome'].isin(['Eduardo Bolsonaro', 
				'Carlos Bolsonaro', 
                        	'Flavio Bolsonaro',
	                        'Jair M. Bolsonaro']), 'bolsonaro_family'] = 'Família Bolsonaro'
	df['bolsonaro_family'].fillna('Não Família Bolsonaro', inplace=True)

	df.loc[df['nome'].isin(['Cris Bartis', 
	                        'Ju Wallauer']), 'mamilos'] = 'Podcasters Mamilos'
	df['mamilos'].fillna('Não Podcasters Mamilos', inplace=True)
	
	return df

df = load_data()

st.sidebar.title("Gráficos")
graph_selection = st.sidebar.selectbox("", ["Histograma Influenciadores", 
					    "Pontos Ideais Influenciadores", 
					    "Histograma Dez Mil Cidadãos"])

if graph_selection == "Histograma Influenciadores":
	fc.hist_inf(df)

elif graph_selection == "Pontos Ideais Influenciadores":
	fc.pontos_ideais_inf(df)

elif graph_selection == "Histograma Dez Mil Cidadãos":
        st.title('Histograma Cidadãos')