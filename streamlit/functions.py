import streamlit as st
import pandas as pd
import plotly.express as px

def hist_inf(df):
	st.title('Histograma Influenciadores')
	# st.write("Hello *world*")

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
	st.write('Role para ver todos os gráficos da página')

	st.markdown('### Por posicionamento')
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

	st.markdown('### Exemplos')
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

	st.markdown('### Profissões')
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

	st.markdown('### Mídias, Partidos e Filiados')
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
