#pragma once
#include "aelyxora/model.hpp"
#include <expected>
#include <map>
#include <string>
#include <vector>

namespace aelyxora {
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
