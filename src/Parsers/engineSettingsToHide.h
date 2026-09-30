#pragma once

#include <Core/Field.h>
#include <Databases/DataLake/DataLakeConstants.h>
#include <Storages/Kafka/Kafka_fwd.h>
#include <Storages/NATS/NATS_fwd.h>
#include <Storages/ObjectStorageQueue/AzureQueue_fwd.h>
#include <Storages/ObjectStorageQueue/S3Queue_fwd.h>
#include <Storages/RabbitMQ/RabbitMQ_fwd.h>

#include <array>
#include <functional>
#include <optional>
#include <unordered_map>

namespace DB
{

/// Each engine namespace declares its own identical `ValueMaskingFunc` alias, hence the spelled-out
/// type. Unrelated to `CoreSettings::ValueMaskingFunc`, which rewrites a value string in place.
using EngineSettingsToHide = std::unordered_map<String, std::function<std::optional<std::string>(const Field &)>>;

/// The table and database engine settings whose value is a secret, and how each one is masked. A rule
/// returns the SQL text that hides the value, or `nullopt` when the value carries no secret.
///
/// Every engine's map is consulted whatever the engine of the statement being formatted, because
/// `FormatStateStacked::create_engine_name` is only set when a `SETTINGS` clause is formatted as part
/// of `ENGINE = ...`. Gating on it printed the value of
/// `ALTER TABLE t MODIFY SETTING kafka_sasl_password = '...'` in cleartext. The setting names are
/// engine-prefixed, so there is nothing for a different engine to collide with.
///
/// Everything that masks engine settings reads this list, so they cannot disagree on what is secret.
/// `static`, like the maps it points to, which each translation unit has its own copy of.
static std::array<const EngineSettingsToHide *, 6> engineSettingsToHide()
{
    return {
        &DataLake::SETTINGS_TO_HIDE,
        &RabbitMQ::SETTINGS_TO_HIDE,
        &NATS::SETTINGS_TO_HIDE,
        &Kafka::SETTINGS_TO_HIDE,
        &AzureQueue::SETTINGS_TO_HIDE,
        &S3Queue::SETTINGS_TO_HIDE,
    };
}

}
