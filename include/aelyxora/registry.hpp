#pragma once
#include "aelyxora/model.hpp"
#include <expected>
#include <map>
#include <string>
#include <string_view>
#include <vector>
namespace aelyxora {
struct ComponentType {
 std::string type_id;
 std::string api_version;
 std::vector<PropertyDefinition> properties;
};
using RegistryDiagnostics = std::vector<Diagnostic>;
class ComponentRegistry {
public:
 std::expected<void,RegistryDiagnostics> register_type(ComponentType type);
 const ComponentType* find(std::string_view id) const noexcept;
 std::expected<PropertyValue,RegistryDiagnostics> resolve(
    const Component& component,std::string_view property) const;
 RegistryDiagnostics validate_instance(const Component& component) const;
private:
 std::map<std::string,ComponentType,std::less<>> types_;
};
struct PropertyBinding {
 std::string source_component;
 std::string source_property;
 std::string target_component;
 std::string target_property;
};
RegistryDiagnostics validate_bindings(
 const Project& project,const ComponentRegistry& registry,
 const std::vector<PropertyBinding>& bindings);
} // namespace aelyxora
