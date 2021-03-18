import streamlit as st
import pandas as pd
import plotly.express as px
from pathlib import Path
import base64

import functions as fc

# st.beta_set_page_title('Gráficos "Diga-me quem segues..."')

@st.cache(allow_output_mutation=True)
def load_data():
	df = pd.read_csv("pontos_ideais_outras_infos.csv")
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

@st.cache(allow_output_mutation=True)
def load_data_cidadaos():
	# draws R
	df_obs = pd.read_csv('cidadaos_fase1.csv').drop(['Unnamed: 0'], axis=1).reset_index().rename({'index': 'draw'}, axis=1)

	return df_obs

df_cid = load_data_cidadaos()

st.sidebar.title("Gráficos e Infos")
graph_selection = st.sidebar.selectbox("Escolha a visualização", ["",
								"Resumo e Outras Informações",
								"Histograma Influenciadores", 
					    			"Pontos Ideais Influenciadores", 
					    			"Histograma Dez Mil Cidadãos",
					    			"Gráficos de Rede"])

if graph_selection == "":
	st.markdown('### Diga-me quem segues e lhe direi quem és: Estimação de ideologia feminista no Twitter usando ponto ideal bayesiano')
	st.markdown('Essa página foi desenvolvida para permitir a visualização dos dados do Trabalho de Conclusão de Curso da aluna Camila Lainetti de Morais, do curso Bacharelado em Matemática Aplicada e Computacional do IME/USP.')
	st.markdown('Utilize o **menu ao lado esquerdo** para visualizar os gráficos e mais informações sobre o trabalho.')

elif graph_selection == "Resumo e Outras Informações":
	st.markdown('### Resumo')
	st.markdown("""Em um contexto no qual a última campanha presidencial vitoriosa teve como um eixo central o combate à “ideologia de gênero”, faz-se necessário compreender o posicionamento de figuras públicas e cidadãos em relação aos temas de gênero e feminismo. Valendo-se do modelo de estimação bayesiana de ponto ideal proposto por Barberá (2015)[1], este trabalho analisa um conjunto de influenciadores e cidadãos brasileiros ativos no Twitter, metrificando seus posicionamentos ideológicos no tocante ao feminismo, com o objetivo de compreender mais sobre os grupos feministas e antifeministas, a relação entre eles, e suas possíveis divisões internas. A observação das estimações de ponto ideal dos influenciadores aponta que existem dois clusters, um feminista e outro antifeminista, bastante separados e com poucos seguidores em comum. Notamos ainda uma subdivisão interna entre feministas negras e não negras, e uma subdivisão interna entre antifeministas que atuam principalmente no âmbito religioso evangélico e aqueles cuja principal atuação concentra-se no âmbito político. Em relação aos cidadãos, observamos que aqueles que seguem muitos influenciadores incluídos no estudo têm, em geral, posicionamentos estimados mais moderados que aqueles das figuras públicas. Construímos ainda, para a validação das conclusões obtidas, uma análise de rede de relacionamentos dos influenciadores.
\n
**Palavras-chaves:** gênero; feminismo; antifeminismo; posicionamento ideológico; análise bayesiana.
\n
[1] BARBERA, P. Birds of the same feather tweet together. bayesian ideal point estimation using twitter data. Political Analysis, v. 1, n. 23, p. 76–91, 2015.""")

	st.markdown('### Github [link](https://github.com/MoraisCamila91/TCCBarberaFeminismo)')

	st.markdown('### Apresentação e PDF [link](https://drive.google.com/drive/folders/1EDY-pX0m8FqxQYEnEgCPhluBa3hlmdcY?usp=sharing)')

	st.markdown('### Outros Conteúdos [link](https://drive.google.com/drive/folders/14NVcD6G6JVX87nRSTXr5Hq_bpgtUxw9V?usp=sharing)')

elif graph_selection == "Histograma Influenciadores":
	fc.hist_inf(df)

elif graph_selection == "Pontos Ideais Influenciadores":
	fc.pontos_ideais_inf(df)

elif graph_selection == "Histograma Dez Mil Cidadãos":
	fc.pontos_ideais_dezmil(df_cid)

elif graph_selection == "Gráficos de Rede":
	fc.network()

	