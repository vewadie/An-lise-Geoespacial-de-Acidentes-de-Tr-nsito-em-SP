# Análise Geoespacial de Sinistros de Trânsito em SP
 
**Disciplina:** Banco de Dados Geográficos  
**Grupo:**
| Nome | RA |
|---|---|
| Verina Hani Mekhail Wadie | 23.01266-8 |
| João Pedro de Souza Cruz | 23.00057-0 |
| Victor Cecche Pregnolatto | 21.00928-7 |
 
---
 
## Tema
 
Análise geoespacial de sinistros de trânsito no estado de São Paulo (2015–2026), com foco em identificação de zonas de risco, padrões temporais e distribuição geográfica por município.
 
**Pergunta central (Parte 2):** *Quais são as zonas geográficas, os tipos de via e os turnos de maior risco de sinistro fatal no estado de SP, e como esses fatores se combinam para orientar políticas públicas de segurança viária?*
 
---
 
## Fontes de Dados
 
| Fonte | Descrição | URL |
|---|---|---|
| Infosiga SP | Sinistros com vítimas: tipo, localização, gravidade, turno e data (2015–2026) | https://www.infosiga.sp.gov.br |
| IBGE | Malha municipal do estado de SP (shapefile 2022) | https://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/municipio_2022/UFs/SP/ |
 
---
 
## Estrutura do Repositório
 
```
├── 01_coleta.ipynb          # Parte 1 — coleta, limpeza e carga no banco PostgreSQL
├── 02_analise.ipynb         # Parte 1 — análise exploratória e visualizações
├── 03_analise_parte2.ipynb  # Parte 2 — clustering DBSCAN, índice de risco e mapas
├── schema.sql               # Schema do banco PostgreSQL/PostGIS
└── README.md
```
 
**Dados** (não estão no repositório por serem grandes demais para o GitHub):
- `acidentes_sp_backup.sql` — backup do banco PostgreSQL gerado na Parte 1
- `dados_infosiga.zip` — CSVs originais do Infosiga SP usados na Parte 2
---
 
## Ferramentas e Tecnologias
 
| Ferramenta | Versão | Uso |
|---|---|---|
| Python | 3.10+ | Linguagem principal |
| PostgreSQL + PostGIS | 14 | Banco de dados geoespacial (Parte 1) |
| GeoPandas | 1.x | Manipulação de dados geoespaciais |
| scikit-learn (DBSCAN) | 1.x | Clustering geoespacial (Parte 2) |
| Folium | 0.x | Mapas interativos |
| Matplotlib / Seaborn | 3.x | Visualizações estáticas |
| Google Colab | — | Ambiente de execução da Parte 1 |
| VS Code + Jupyter | — | Ambiente de execução da Parte 2 |
 
---
 
## Como Executar — Parte 1
 
> `01_coleta.ipynb` e `02_analise.ipynb` — coleta e análise exploratória  
> Usa **PostgreSQL + PostGIS** instalado no Google Colab.
 
### Pré-requisitos
- Conta Google (para o Colab e Drive)
- Arquivo `dados_infosiga.zip` baixado do Infosiga SP
### Passo a passo
 
1. Acesse **https://colab.research.google.com** e abra `01_coleta.ipynb`
2. Execute a primeira célula — ela instala o PostgreSQL + PostGIS automaticamente
3. Quando solicitado, faça upload do `dados_infosiga.zip`
4. Execute todas as células em ordem
5. Ao final, salve o backup no Google Drive:
```python
from google.colab import drive
drive.mount('/content/drive')
!sudo -u postgres pg_dump acidentes_sp > /content/drive/MyDrive/acidentes_sp_backup.sql
```
 
6. Abra `02_analise.ipynb` e execute todas as células em ordem
> O Colab reinicia o ambiente a cada nova sessão. Se isso acontecer, execute novamente a célula de instalação do PostgreSQL antes de qualquer outra.
 
---
 
## Como Executar — Parte 2
 
> `03_analise_parte2.ipynb` — clustering, índice de risco e mapas  
> Roda **localmente no VS Code**, sem PostgreSQL. Lê os CSVs do Infosiga diretamente.
 
### Pré-requisitos
 
**1. Python 3.10+** instalado — verifique com:
```bash
python --version
```
 
**2. Dependências** — instale com:
```bash
pip install pandas geopandas numpy scikit-learn folium matplotlib seaborn mapclassify branca
```
 
**3. Extensão Jupyter no VS Code** — instale pelo menu de extensões (Ctrl+Shift+X → buscar "Jupyter" → instalar a da Microsoft)
 
**4. Arquivo de dados** — o `dados_infosiga.zip` deve estar acessível localmente. Ele contém os arquivos:
- `sinistros_2015-2021.csv`
- `sinistros_2022-2026.csv`
### Passo a passo
 
1. Abra `03_analise_parte2.ipynb` no VS Code
2. Na **Célula 2**, ajuste o caminho do ZIP se necessário:
```python
CAMINHO_ZIP = r'C:\Users\SEU_USUARIO\Downloads\Maua\dados_infosiga.zip'
```
 
3. Execute as células em ordem, uma por vez, aguardando cada uma terminar
> A malha municipal do IBGE é baixada automaticamente na Célula 3 e salva na pasta `dados/` local — necessário ter conexão com a internet na primeira execução.
 
### Saídas geradas
 
Após a execução completa, os seguintes arquivos são salvos na mesma pasta do notebook:
 
| Arquivo | Descrição |
|---|---|
| `mapa_clusters_fatais.html` | Mapa interativo com heatmap e clusters |
| `mapa_risco_municipal.html` | Mapa coroplético interativo por município |
| `mapa_indice_risco.png` | Mapa estático do índice de risco |
| `perfil_temporal_clusters.png` | Turno × dia × mês dos clusters |
| `heatmap_via_turno.png` | Mortos por tipo de via e turno |
| `top15_municipios_risco.png` | Ranking de municípios por risco |
| `sazonalidade_clusters.png` | Sinistros fatais por mês |
| `composicao_clusters.png` | Pizza: tipo de via e turno |
 
---
 
## Análises Realizadas (Parte 2)
 
| Análise | Descrição |
|---|---|
| **Clustering DBSCAN** | Agrupa sinistros fatais por proximidade geográfica (`eps=0.05` ~5km, `min_samples=10`). Identifica zonas de concentração de mortes no estado. |
| **Índice de Risco Municipal** | Índice composto: 50% taxa de mortalidade + 30% densidade (sinistros/km²) + 20% sazonalidade. Normalizado entre 0 e 1 por município. |
| **Perfil Temporal dos Clusters** | Analisa turno, dia da semana e mês dos sinistros nos top 5 clusters de risco. |
| **Heatmap Via × Turno** | Cruzamento entre tipo de via e turno para os sinistros fatais em clusters. |
| **Mapas coropléticos e interativos** | Visualização geográfica do índice de risco e localização dos clusters. |
