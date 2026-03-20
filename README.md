# Análise Geoespacial de Acidentes de Trânsito em SP

Projeto de análise de dados geográficos — disciplina de Banco de Dados Geográficos.

## Tema

Análise geoespacial de acidentes de trânsito no estado de São Paulo (2021–2023), com foco em identificação de zonas de risco, padrões temporais e perfil das vítimas.

## Fontes de Dados

| Fonte | Descrição | URL |
|---|---|---|
| **Infosiga SP** | Dados de acidentes com vítimas por município, tipo de veículo, causa e data | https://www.infosiga.sp.gov.br |
| **IBGE** | Malha municipal do estado de SP (shapefile 2022) | https://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/municipio_2022/UFs/SP/ |

> Os dados do Infosiga são de acesso público e podem ser baixados na seção "Dados Abertos" do portal.

## Estrutura do Projeto

```
projeto-acidentes-sp/
├── dados/                        # Arquivos de dados (gerados na execução)
│   ├── municipios_sp.geojson     # Geometria dos municípios (IBGE)
│   ├── acidentes_sp.json         # Dados de acidentes (Infosiga SP)
│   ├── SP_Municipios_2022.zip    # Shapefile original IBGE
│   └── acidentes_20XX.csv        # CSVs originais do Infosiga por ano
├── notebooks/
│   ├── 01_coleta.ipynb           # Coleta, limpeza e armazenamento
│   └── 02_analise.ipynb          # Análise exploratória e visualizações
├── sql/
│   └── schema.sql                # Schema do banco PostgreSQL/PostGIS
└── README.md
```

## Ferramentas e Tecnologias

| Ferramenta | Versão recomendada | Uso |
|---|---|---|
| Python | 3.10+ | Linguagem principal |
| PostgreSQL | 14+ | Banco de dados relacional |
| PostGIS | 3.x | Extensão geoespacial do PostgreSQL |
| GeoPandas | 0.14+ | Manipulação de dados geoespaciais |
| Folium | 0.15+ | Mapas interativos (Leaflet.js) |
| SQLAlchemy | 2.x | ORM / conexão com banco |
| GeoAlchemy2 | 0.14+ | Suporte a tipos geométricos no SQLAlchemy |
| Matplotlib / Seaborn | — | Visualizações estáticas |
| Jupyter / Google Colab | — | Notebooks |

## Como Executar

### Pré-requisitos

1. **PostgreSQL com PostGIS instalado**

```bash
# Ubuntu/Debian
sudo apt install postgresql postgresql-contrib postgis

# Criar banco de dados
psql -U postgres -c "CREATE DATABASE acidentes_sp;"
psql -U postgres -d acidentes_sp -c "CREATE EXTENSION postgis;"
```

2. **Python 3.10+** com pip

### Passo 1 — Instalar dependências Python

```bash
pip install geopandas folium psycopg2-binary sqlalchemy GeoAlchemy2 mapclassify matplotlib seaborn
```

### Passo 2 — Executar o notebook de coleta

Abra `notebooks/01_coleta.ipynb` no Jupyter ou Google Colab:

```bash
jupyter notebook notebooks/01_coleta.ipynb
```

> **No Google Colab:** faça upload dos arquivos ou monte o Google Drive.  
> Ajuste as credenciais do banco na célula de configuração (seção 3).

O notebook irá:
- Baixar a malha municipal do IBGE automaticamente
- Baixar os CSVs do Infosiga SP (ou guiar o upload manual)
- Limpar e padronizar os dados
- Criar as tabelas no PostgreSQL/PostGIS
- Exportar os dados em JSON como backup

### Passo 3 — Executar o notebook de análise

```bash
jupyter notebook notebooks/02_analise.ipynb
```

O notebook gera:
- Série temporal de acidentes e mortes (2021–2023)
- Top 20 municípios com mais acidentes
- Distribuição por dia da semana
- Análise por tipo de veículo
- Mapa coroplético estático (matplotlib)
- Mapa de calor interativo (folium)
- Heatmap dia × hora
- Taxa de mortalidade por tipo de acidente
- Sazonalidade mensal
- **Proposta de análise** (última célula)

### Usando no Google Colab

1. Faça upload dos arquivos do projeto no Colab ou clone via git:
```python
!git clone https://github.com/seu_usuario/projeto-acidentes-sp.git
%cd projeto-acidentes-sp
```

2. Para usar PostgreSQL no Colab, você pode usar um serviço externo como [ElephantSQL](https://www.elephantsql.com/) (plano gratuito) ou instalar localmente:
```python
!sudo apt-get install postgresql postgis -y
!sudo service postgresql start
!sudo -u postgres psql -c "CREATE DATABASE acidentes_sp;"
!sudo -u postgres psql -d acidentes_sp -c "CREATE EXTENSION postgis;"
```

## Schema do Banco

Duas tabelas principais:

- **`municipios`** — geometria (MultiPolygon) dos 645 municípios de SP com código IBGE
- **`acidentes`** — registros de acidentes com vítimas, incluindo ponto geográfico (Point), data, tipo, causa e contagens de mortos/feridos

Duas views auxiliares:
- **`vw_resumo_municipio`** — totais agregados por município com geometria
- **`vw_serie_temporal`** — série mensal de acidentes e mortos

Ver detalhes em `sql/schema.sql`.

## Proposta de Análise (Parte 2)

Identificação de zonas de alto risco usando **clustering geoespacial (DBSCAN)** cruzado com:
- Tipo de via (rodovia × urbana) via OpenStreetMap/osmnx
- Padrão temporal (hora, dia da semana, mês)
- Perfil de veículo (moto, carro, pedestre)

**Pergunta central:** *Quais são as zonas geográficas, tipos de via e horários de maior risco de acidente fatal no estado de SP?*
