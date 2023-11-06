import polars as pl

def load_raw():
    density = pl.read_csv(
        "/datathon/data/parsed_datafiles/density.csv",
        null_values=['NA', '-1'],
        schema={
            'x': pl.Float32,
            'y': pl.Float32,
            'density': pl.Float32,
            'id': pl.Int32,
        }
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