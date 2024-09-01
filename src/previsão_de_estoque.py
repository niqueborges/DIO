import pandas as pd
import numpy as np
from datetime import datetime, timedelta

# Parâmetros
num_products = 25
days = 5
records_per_day = 25

# Gerar as datas
start_date = datetime(2023, 12, 31)
date_range = [start_date + timedelta(days=i) for i in range(days)]

# Gerar IDs de produtos e datas
data = []
for day in date_range:
    for product_id in range(1, num_products + 1):
        flag_promocao = np.random.choice([0, 1])
        quantidade_estoque = np.random.randint(50, 200)  # Quantidade inicial variável
        data.append([product_id, day.strftime('%Y-%m-%d'), flag_promocao, quantidade_estoque])

# Criar DataFrame
df = pd.DataFrame(data, columns=['ID_PRODUTO', 'DIA', 'FLAG_PROMOCAO', 'QUANTIDADE_ESTOQUE'])

# Ajustar quantidade de estoque para decrescer de maneira variável
df.sort_values(by=['ID_PRODUTO', 'DIA'], inplace=True)
for product_id in df['ID_PRODUTO'].unique():
    product_df = df[df['ID_PRODUTO'] == product_id]
    initial_stock = product_df.iloc[0]['QUANTIDADE_ESTOQUE']
    product_df['QUANTIDADE_ESTOQUE'] = np.maximum(initial_stock - np.cumsum(np.random.randint(1, 10, size=len(product_df))), 0)
    df.loc[df['ID_PRODUTO'] == product_id, 'QUANTIDADE_ESTOQUE'] = product_df['QUANTIDADE_ESTOQUE'].values

# Salvar como CSV
df.to_csv('historico_vendas.csv', index=False)
