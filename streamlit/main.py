import streamlit as st
import pandas as pd
import plotly.express as px

st.write("""
Hello *world*
""")

df = pd.read_csv("../resumo_resultados/pontos_ideais_outras_infos.csv")
df['seguidores_analisados_rel'] = df['seguidores_analisados']/df['seguidores_analisados'].max()

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
                           'profissoes': 'Classificações'})
fig.update_layout(
    yaxis_title_text='', # yaxis label
)

st.plotly_chart(fig)