#!/usr/bin/env bash
# Tags: no-fasttest
# `DataLakeCatalog` and the data lake table engines are not built in fast test.
# `none`, the default of `catalog_type` and `storage_catalog_type`, has a name, so `system.engine_settings` can show the
# default, and `catalog_type = 'none'` behaves as leaving the setting out. A shell test because the error is the same
# code either way (`BAD_ARGUMENTS`); its message tells them apart.

CUR_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../shell_config.sh
. "$CUR_DIR"/../shell_config.sh

$CLICKHOUSE_CLIENT -q "SELECT value, default FROM system.engine_settings WHERE engine_name = 'Iceberg' AND name = 'storage_catalog_type'"

for settings in "warehouse = 'w'" "catalog_type = 'none', warehouse = 'w'"; do
    $CLICKHOUSE_CLIENT -q "CREATE DATABASE ${CLICKHOUSE_DATABASE}_catalog ENGINE = DataLakeCatalog('http://localhost:1/') SETTINGS ${settings}" 2>&1 \
        | grep -o -m1 'Unspecified catalog type'
done

$CLICKHOUSE_CLIENT -q "DROP DATABASE IF EXISTS ${CLICKHOUSE_DATABASE}_catalog"
