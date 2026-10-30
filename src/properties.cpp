#include "aelyxora/properties.hpp"
#include <cmath>
#include <set>
#include <utility>

namespace aelyxora {
PropertyKind kind_of(const PropertyValue& v) noexcept {
    switch(v.index()) {
    case 0: return PropertyKind::Boolean;
    case 1: return PropertyKind::Integer;
    case 2: return PropertyKind::Real;
    default: return PropertyKind::Text;
    }
}
std::vector<Diagnostic> validate_properties(
    const std::vector<PropertyDefinition>& definitions,
    const PropertyInstance& instance) {
    std::vector<Diagnostic> errors;
    std::set<std::string> declared;
    if(instance.component_id.empty())
        errors.push_back({ErrorCode::InvalidId,"component_id","component identifier required"});
    for(const auto& d:definitions) {
        if(d.name.empty() || !declared.insert(d.name).second)
            errors.push_back({ErrorCode::DuplicateId,d.name,"empty or duplicate property definition"});
        if(kind_of(d.default_value)!=d.kind)
            errors.push_back({ErrorCode::MissingField,d.name,"default value has wrong type"});
        if(auto real=std::get_if<double>(&d.default_value); real && !std::isfinite(*real))
            errors.push_back({ErrorCode::MissingField,d.name,"default must be finite"});
    }
    for(const auto& [name,value]:instance.values) {
        const PropertyDefinition* def=nullptr;
        for(const auto& d:definitions) if(d.name==name){def=&d;break;}
        if(!def) {
            errors.push_back({ErrorCode::UnresolvedDependency,name,"undeclared property"});
            continue;
        }
        if(kind_of(value)!=def->kind)
            errors.push_back({ErrorCode::MissingField,name,"property type mismatch"});
        if(auto real=std::get_if<double>(&value);real && !std::isfinite(*real))
            errors.push_back({ErrorCode::MissingField,name,"real value must be finite"});
    }
    return errors;
}
PropertyResult set_property(PropertyInstance& instance,
    const std::vector<PropertyDefinition>& definitions,
    const std::string& property,PropertyValue value) {
    const PropertyDefinition* def=nullptr;
    for(const auto& d:definitions) if(d.name==property){def=&d;break;}
    if(!def)
        return std::unexpected(std::vector<Diagnostic>{{ErrorCode::UnresolvedDependency,property,"unknown property"}});
    if(!def->writable)
        return std::unexpected(std::vector<Diagnostic>{{ErrorCode::MissingField,property,"property is read-only"}});
    PropertyInstance candidate=instance;
    candidate.values[property]=std::move(value);
    auto diagnostics=validate_properties(definitions,candidate);
    if(!diagnostics.empty())return std::unexpected(std::move(diagnostics));
    instance=std::move(candidate);
    return {};
}
}
