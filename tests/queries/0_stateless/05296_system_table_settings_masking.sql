-- Tags: no-fasttest
-- `Kafka` and `S3Queue` are not built in fast test.

-- A secret is shown as `[HIDDEN]`, as in `SHOW CREATE TABLE`; an unset one is not reported as hidden.
DROP TABLE IF EXISTS kafka_secret;
DROP TABLE IF EXISTS kafka_no_secret;
CREATE TABLE kafka_secret (a Int) ENGINE = Kafka
SETTINGS kafka_broker_list = 'localhost:9092', kafka_topic_list = 't', kafka_group_name = 'g', kafka_format = 'JSONEachRow',
    kafka_sasl_password = 'secret_password_05296';
CREATE TABLE kafka_no_secret (a Int) ENGINE = Kafka
SETTINGS kafka_broker_list = 'localhost:9092', kafka_topic_list = 't', kafka_group_name = 'g', kafka_format = 'JSONEachRow';
SELECT table, name, value FROM system.table_settings
WHERE database = currentDatabase() AND name IN ('kafka_broker_list', 'kafka_sasl_password')
ORDER BY table, name;

-- `S3Queue` accepts its settings with an `s3queue_` prefix, which the engine strips.
DROP TABLE IF EXISTS queue;
CREATE TABLE queue (a String) ENGINE = S3Queue('http://localhost:11111/test/05296/*.csv', NOSIGN, 'CSV')
SETTINGS s3queue_mode = 'unordered';
SELECT name, value, changed FROM system.table_settings WHERE database = currentDatabase() AND table = 'queue' AND name = 'mode';

DROP TABLE queue;
DROP TABLE kafka_no_secret;
DROP TABLE kafka_secret;
