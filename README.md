# Análise Geoespacial de Sinistros de Trânsito em SP

Projeto de análise de dados geográficos — disciplina de Banco de Dados Geográficos.

## Grupo
| Nome | RA |
|---|---|
| Verina Hani Mekhail Wadie | 23.01266-8 |
| João Pedro de Souza Cruz | 23.00057-0 |
| Victor Cecche Pregnolatto | 21.00928-7 |

## Tema

Análise geoespacial de sinistros de trânsito no estado de São Paulo (2015–2026), com foco em identificação de zonas de risco, padrões temporais e distribuição geográfica.

## Fontes de Dados

Fonte:  **Infosiga SP**    
Descrição: Dados de sinistros com vítimas: tipo, localização, gravidade, turno e data     
URL: https://www.infosiga.sp.gov.br

Fonte:  **IBGE**    
Descrição: Malha municipal do estado de SP (shapefile 2022)   
URL: https://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/municipio_2022/UFs/SP/ 

> Os dados do Infosiga são de acesso público. Baixe o ZIP na seção **Dados Abertos** do portal e faça upload no Colab conforme instruído no notebook de coleta.
>
> O ZIP contém 6 arquivos (pessoas, sinistros, veículos × 2 períodos). O notebook usa apenas os arquivos de **sinistros** (`sinistros_2015-2021.csv` e `sinistros_2022-2026.csv`).

## Estrutura do Projeto

```
projeto-acidentes-sp/
├── dados/                          # Gerados na execução
│   ├── municipios_sp.geojson       # Geometria dos municípios (IBGE)
│   ├── sinistros_sp.json           # Dados de sinistros (Infosiga SP)
│   └── SP_Municipios_2022.zip      # Shapefile original IBGE
├── notebooks/
│   ├── 01_coleta.ipynb             # Coleta, limpeza e armazenamento
│   └── 02_analise.ipynb            # Análise exploratória e visualizações
├── sql/
│   └── schema.sql                  # Schema do banco PostgreSQL/PostGIS
└── README.md
```

## Ferramentas e Tecnologias

| Ferramenta | Versão recomendada | Uso |
|---|---|---|
| Python | 3.10+ | Linguagem principal |
| PostgreSQL | 14+ | Banco de dados relacional |
| PostGIS | 3.x | Extensão geoespacial do PostgreSQL |
| GeoPandas | 1.0+ | Manipulação de dados geoespaciais |
| Folium | 0.15+ | Mapas interativos (Leaflet.js) |
| SQLAlchemy | 2.x | Conexão com banco |
| GeoAlchemy2 | 0.14+ | Suporte a tipos geométricos |
| Matplotlib / Seaborn | — | Visualizações estáticas |
| Google Colab | — | Ambiente de execução dos notebooks |

## Como Executar (Google Colab)

### Passo 1 — Baixar os dados do Infosiga SP

1. Acesse https://www.infosiga.sp.gov.br → **Dados Abertos**
2. Baixe o arquivo ZIP com todos os dados
3. Guarde o ZIP para fazer upload no Colab

### Passo 2 — Abrir e executar o notebook de coleta

1. Abra `01_coleta.ipynb` no Google Colab
2. Execute a célula **"Subir PostgreSQL + PostGIS no Colab"** (seção 4) — apenas uma vez por sessão
3. Execute todas as células em ordem
4. Na célula de upload (seção 7), selecione o ZIP baixado do Infosiga
5. Ao final, salve o backup no Google Drive (recomendado para não perder os dados)

### Passo 3 — Abrir e executar o notebook de análise

1. Abra `02_analise.ipynb` no Google Colab
2. Execute a célula de restauração do banco (início do notebook)
3. Execute todas as células em ordem

> **Importante:** O Colab perde os dados ao encerrar a sessão. Salve o backup do banco no Google Drive após a coleta:
> ```python
> from google.colab import drive
> drive.mount('/content/drive')
> !sudo -u postgres pg_dump acidentes_sp > /content/drive/MyDrive/acidentes_sp_backup.sql
> ```
> E restaure no início de cada sessão de análise:
> ```python
> !sudo service postgresql start
> !sudo -u postgres psql acidentes_sp < /content/drive/MyDrive/acidentes_sp_backup.sql
> ```

## Schema do Banco

### Tabela `municipios`
Geometria (MultiPolygon) dos 645 municípios de SP com código IBGE.

### Tabela `acidentes`
Registros de sinistros com as seguintes colunas principais:

| Coluna | Origem no Infosiga | Descrição |
|---|---|---|
| `tipo_acidente` | `tp_sinistro_primario` | Tipo primário do sinistro |
| `causa_acidente` | `tipo_via` | Tipo de via onde ocorreu |
| `mortos` | `qtd_gravidade_fatal` | Quantidade de óbitos |
| `feridos_graves` | `qtd_gravidade_grave` | Feridos graves |
| `feridos_leves` | `qtd_gravidade_leve` | Feridos leves |
| `ilesos` | `qtd_gravidade_ileso` | Ilesos |
| `turno` | `turno` | Turno do sinistro |
| `tipo_local` | `tipo_local` | Tipo de local |

### Views auxiliares
- **`vw_resumo_municipio`** — totais agregados por município com geometria
- **`vw_serie_temporal`** — série mensal de sinistros e mortos

## Visualizações Geradas pelo `02_analise.ipynb`

- Série temporal de sinistros e mortes (2015–2026)
- Top 20 municípios com mais sinistros
- Distribuição por dia da semana
- Distribuição por turno e tipo de via
- Mapa coroplético (sinistros e mortos por município)
- Mapa de calor interativo (Folium) — salvo em `mapa_calor.html`
- Heatmap dia da semana × hora do dia
- Taxa de mortalidade por tipo de sinistro
- Sazonalidade mensal
- **Proposta de análise** (última célula)

## Proposta de Análise (Parte 2)

Identificação de zonas de alto risco usando **clustering geoespacial (DBSCAN via PostGIS)** cruzado com:
- Tipo de via (`causa_acidente`)
- Padrão temporal (turno, dia da semana, mês)
- Tipo de sinistro (`tipo_acidente`)

**Pergunta central:** *Quais são as zonas geográficas, os tipos de via e os turnos de maior risco de sinistro fatal no estado de SP, e como esses fatores se combinam para orientar políticas públicas de segurança viária?*
