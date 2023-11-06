import polars as pl
import numpy as np

def load_raw():
    density = pl.read_csv(
        "/datathon/data/parsed_datafiles/populationDen.csv",
        null_values=['NA', '-1'],
        schema={
            'x': pl.Float32,
            'y': pl.Float32,
            'vis-gray': pl.Float32,
            'id': pl.Int32,
        }
    ).select(
        pl.col('x', 'y', 'id'),
        pl.col('vis-gray').alias('density'),
    )
    nightlight = pl.read_csv(
        "/datathon/data/parsed_datafiles/night-light.csv",
        null_values=['NA', '-1'],
        schema={
            'x': pl.Float32,
            'y': pl.Float32,
            'night-light_1': pl.Float32,
            'night-light_2': pl.Float32,
            'night-light_3': pl.Float32,
            'id': pl.Int32,
        }
    ).select([
        pl.col('x', 'y', 'id'),
        pl.col('night-light_1').alias('nightlight'),
    ])
    
    return density, nightlight

def build_demand():
    density, nightlight = load_raw()
    
    demand = (density
              .join(nightlight, on='id')
              .select('id', 'x', 'y', pl.col('density').alias('raw_density'), pl.col('density').clip(0, 255), 
                      pl.col('nightlight').alias('raw_nightlight'), pl.col('nightlight').clip(0, 255))
              .with_columns(
                  log_density=(255 - pl.col('density') + 1).log10(),
                  log_nightlight=(pl.col('nightlight') + 1).log10(),
              )    
            #   .with_columns(
            #       log_density=((pl.col('log_density') - pl.col('log_density').filter(pl.col('density') > 0.0).min())/(pl.col('log_density').filter(pl.col('density') > 0.0).max() - pl.col('log_density').filter(pl.col('density') > 0.0).min())).clip(0, None),
            #       log_nightlight=((pl.col('log_nightlight') - pl.col('log_nightlight').filter(pl.col('nightlight') > 0.0).min())/(pl.col('log_nightlight').filter(pl.col('nightlight') > 0.0).max() - pl.col('log_nightlight').filter(pl.col('nightlight') > 0.0).min())).clip(0, None),
            #   )
              .with_columns(
                  demand = pl.when((pl.col('density').le(0)) & (pl.col('nightlight').le(0)))
                  .then(None)
                  .otherwise(-(pl.col('log_density') + pl.col('log_nightlight')) + (np.log10(256)))
                  ,
              )
              .select('x', 'y', 'id', 'demand', 'raw_density', 'raw_nightlight')
            #   .fill_nan(-256)
              .sort('demand', descending=True)
    )
    
    return demand

if __name__ == "__main__":
    df = build_demand()
    df.write_csv("/datathon/data/computed_datafiles/demand.csv")
    # npf = df.sort('id').to_numpy()
    # x = npf[:,0].reshape((-1, 3600))
    # y = npf[:,1].reshape((-1, 3600))
    # z = npf[:,3].reshape((-1, 3600))
    # from matplotlib import pyplot as plt
    # plt.scatter(x, y, c=z, marker='.', s=0.01)
    # # plt.colorbar()
    # plt.savefig('/datathon/data/computed_datafiles/demand.png', dpi=150)
