EXTENSION = pg_minmax        # the extensions name
DATA = pg_minmax--0.0.1.sql  # script files to install
REGRESS = pg_minmax_test

# postgres build stuff
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)