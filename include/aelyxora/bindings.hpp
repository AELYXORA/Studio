#pragma once
#include "aelyxora/registry.hpp"
#include <expected>
#include <vector>
namespace aelyxora {
// One-way, synchronous, same-type property links. No converters or side effects.
using BindingResult = std::expected<void,RegistryDiagnostics>;
BindingResult propagate_bindings(Project& project,
    const ComponentRegistry& registry,
    const std::vector<PropertyBinding>& bindings,
    std::uint64_t expected_revision);
}
