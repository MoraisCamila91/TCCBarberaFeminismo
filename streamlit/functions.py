import streamlit as st
import pandas as pd
import plotly.express as px
from pathlib import Path
import base64

def hist_inf(df):
	st.title('Histograma Influenciadores')
	st.markdown('Histograma dos influenciadores analisados na primeira fase')

	fig = px.histogram(df, x="ponto_ideal", 
                   color="posicao", 
                   marginal="rug", nbins=40,
                   color_discrete_sequence=['#800080', '#F0A202'],
                   hover_data=df.columns, histnorm='probability',
                   labels={'seguidores_analisados_rel':'Tamanho relativo de Seguidores Analisados', 
                           'ponto_ideal':'Ponto Ideal',
                           'posicao': 'Classificação',
                           'nome': 'Nome',
                           'partido': 'Partido',
                           'profissoes': 'Classificações',
			   'count': 'Quantidade'})

	fig.update_layout(
	    yaxis_title_text='', # yaxis label
	)

	st.plotly_chart(fig)

def pontos_ideais_inf(df):
	st.title('Pontos Ideais Influenciadores')
	st.markdown('⚠️ **Role para baixo para visualizar todos os gráficos** ⚠️')

	st.markdown('### 1. Posicionamento')
	df['partido'].fillna('', inplace=True)
	fig = px.scatter(df, x="ponto_ideal", 
                 y="seguidores_analisados_rel", 
                 color="posicao",
                 color_discrete_sequence=['#800080', '#F0A202'],
                 hover_data=['nome', 'partido', 'profissoes'],
                 labels={'seguidores_analisados_rel':'Tamanho Relativo de Seguidores Analisados', 
                         'ponto_ideal':'Ponto Ideal',
                         'posicao': 'Classificação',
                         'nome': 'Nome',
                         'partido': 'Partido',
                         'posicao': 'Posicionamento'})

	st.plotly_chart(fig)

	st.markdown('### 2. Exemplos')
	dic_filtros_ex = {"Músicos Evangélicos": "intersec3_str",
			"Podcasters Mamilos": "mamilos",
			"Família Bolsonaro": "bolsonaro_family",
			"Negras e Trans": "intersec1_str", 
			"Família Marielle Franco": "marielle_family"
			}

	selection_ex = st.selectbox("", list(dic_filtros_ex.keys()))
	filtro_ex = dic_filtros_ex[selection_ex]

	fig = px.scatter(df, x="ponto_ideal", 
                 y="seguidores_analisados_rel", 
                 color=filtro_ex,
                 color_discrete_sequence=['lightgrey', '#000000'],
                 hover_data=['nome', 'partido', 'profissoes'],
                 labels={'seguidores_analisados_rel':'Tamanho relativo de Seguidores Analisados', 
                         'ponto_ideal':'Ponto Ideal',
                         'posicao': 'Classificação',
                         'nome': 'Nome',
                         'partido': 'Partido',
                         'profissoes': 'Classificações',
                         filtro_ex: 'Classificações'})

	st.plotly_chart(fig)

	st.markdown('### 3. Profissões')
	dic_filtros_prof = {"Artistas e Produtores": "art_prod_str",
			"Jornalistas e Comunicadores": "jor_com_str",
			"Policiais e Militares": "polic_militar_str",
			"Profissionais da Saúde": "saude_str",
			"Profissionais das Ciências Exatas": "ciencia_str",
			"Empresários": "emp_str"
			}

	selection_prof = st.selectbox("", list(dic_filtros_prof.keys()))
	filtro_prof = dic_filtros_prof[selection_prof]
	color = ['lightgrey', 'red']

	if selection_prof in ['Jornalistas e Comunicadores']:
		color = ['red', 'lightgrey']

	fig = px.scatter(df, x="ponto_ideal", 
                 y="seguidores_analisados_rel", 
                 color=filtro_prof,
                 color_discrete_sequence = color,
                 hover_data=['nome', 'partido', 'profissoes'],
                 labels={'seguidores_analisados_rel':'Tamanho relativo de Seguidores Analisados', 
                         'ponto_ideal':'Ponto Ideal',
                         'posicao': 'Classificação',
                         'nome': 'Nome',
                         'partido': 'Partido',
                         'profissoes': 'Classificações',
                         filtro_prof: 'Classificações'})

	st.plotly_chart(fig)

	st.markdown('### 4. Mídias, Partidos e Filiados')
	dic_filtros_mp = {"Mídias": "mid_str",
			"Partidos e Coletivos": "part_col_str",
			"Filiados": "partido_str"
			}

	selection_mp = st.selectbox("", list(dic_filtros_mp.keys()))
	filtro_mp = dic_filtros_mp[selection_mp]

	color = ['lightgrey', 'green']

	if selection_mp in ['Filiados']:
		color = ['blue', 'lightgrey', 'lightgreen', 'magenta', 'purple', 'orange', 'red', 'black']

	fig = px.scatter(df, x="ponto_ideal", 
                 y="seguidores_analisados_rel", 
                 color=filtro_mp,
                 color_discrete_sequence = color,
                 hover_data=['nome', 'partido', 'profissoes'],
                 labels={'seguidores_analisados_rel':'Tamanho relativo de Seguidores Analisados', 
                         'ponto_ideal':'Ponto Ideal',
                         'posicao': 'Classificação',
                         'nome': 'Nome',
                         'partido': 'Partido',
                         'profissoes': 'Classificações',
                         filtro_mp: 'Classificações'})

	st.plotly_chart(fig)

def pontos_ideais_dezmil(df_cid):
	st.title('Histograma Dez Mil Cidadãos')
	st.markdown('Histograma dos dez mil cidadãos analisados na primeira fase')
	
	fig = px.histogram(df_cid, x="medida_media", labels={'medida_media':'Ponto Ideal'}, histnorm='probability')
	
	fig.update_layout(yaxis_title="Probabilidade")
	fig.update_traces(marker_color='rgb(158,202,225)', marker_line_color='rgb(8,48,107)', marker_line_width=2, opacity=0.8)
	
	st.plotly_chart(fig)


def img_to_bytes(img_path):
	img_bytes = Path(img_path).read_bytes()
	encoded = base64.b64encode(img_bytes).decode()
	return encoded

def image_show(path):
	header_html = "<img src='data:image/png;base64,{}' class='img-fluid'>".format(
	    img_to_bytes(path)
	)
	st.markdown(
    		header_html, unsafe_allow_html=True,
	)


def network():
	st.title('Gráficos de Rede')

	network_selection = st.selectbox("Escolha o gráfico de rede", ["", "Completo", "Cluster Feminista: Negras e Trans", "Cluster Feminista: Partidos", "Cluster Antifeminista: Partidos"])

	if network_selection == "Completo":
		st.markdown('⚠️ **Role para o lado** ⚠️')
		image_show("imagens/Forceatlas_relativo_flip.png")

	elif network_selection == "Cluster Feminista: Negras e Trans":
		st.markdown('⚠️ **Role para o lado** ⚠️')
		image_show("imagens/Forceatlas_relativo_nt.png")

	elif network_selection == "Cluster Feminista: Partidos":
		image_show("imagens/partidosfeministas_rede.png")

	elif network_selection == "Cluster Antifeminista: Partidos":
		image_show("imagens/partidosantifeministas_rede.png")