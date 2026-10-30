#pragma once
#include "aelyxora/model.hpp"
#include <cstdint>
#include <expected>
#include <map>
#include <string>
#include <variant>
#include <vector>

namespace aelyxora {
using PropertyValue = std::variant<bool, std::int64_t, double, std::string>;
enum class PropertyKind { Boolean, Integer, Real, Text };
struct PropertyDefinition {
    std::string name;
    PropertyKind kind;
    PropertyValue default_value;
    bool writable = true;
};
struct PropertyInstance {
    std::string component_id;
    std::map<std::string, PropertyValue> values;
};
using PropertyResult = std::expected<void, std::vector<Diagnostic>>;

PropertyKind kind_of(const PropertyValue& value) noexcept;
std::vector<Diagnostic> validate_properties(
    const std::vector<PropertyDefinition>& definitions,
    const PropertyInstance& instance);
// Updates a detached candidate. Only publishes if all property checks pass.
// The revision is owned by caller; this function does not update Project.
PropertyResult set_property(
    PropertyInstance& instance,
    const std::vector<PropertyDefinition>& definitions,
    const std::string& property,
    PropertyValue value);
}
