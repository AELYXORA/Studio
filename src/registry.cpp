#include "aelyxora/registry.hpp"
#include <cmath>
#include <set>
#include <utility>
namespace aelyxora {
namespace {
bool finite(const PropertyValue& v) {
 if(const auto* d=std::get_if<double>(&v))return std::isfinite(*d);
 return true;
}
const PropertyDefinition* property(const ComponentType& type,std::string_view name){
 for(const auto& d:type.properties)if(d.name==name)return &d;
 return nullptr;
}
}
std::expected<void,RegistryDiagnostics> ComponentRegistry::register_type(ComponentType type){
 RegistryDiagnostics errors;
 if(type.type_id.empty()||type.api_version.empty())
  errors.push_back({ErrorCode::MissingField,"type","type ID and API version required"});
 std::set<std::string> names;
 for(const auto& d:type.properties) {
  if(d.name.empty()||!names.insert(d.name).second)
   errors.push_back({ErrorCode::DuplicateId,d.name,"duplicate or empty property name"});
  if(d.default_value.index()!=static_cast<std::size_t>(d.kind)||!finite(d.default_value))
   errors.push_back({ErrorCode::MissingField,d.name,"invalid default value"});
 }
 if(types_.contains(type.type_id))
  errors.push_back({ErrorCode::DuplicateId,type.type_id,"already registered"});
 if(!errors.empty())return std::unexpected(std::move(errors));
 types_.emplace(type.type_id,std::move(type));
 return {};
}
const ComponentType* ComponentRegistry::find(std::string_view id) const noexcept {
 auto it=types_.find(id);
 return it==types_.end()?nullptr:&it->second;
}
RegistryDiagnostics ComponentRegistry::validate_instance(const Component& c) const {
 RegistryDiagnostics errors;
 const auto* type=find(c.type);
 if(!type)return {{ErrorCode::UnresolvedDependency,c.type,"component type not registered"}};
 // Legacy instance-level definitions are allowed only if they exactly agree with
 // the registry's declared public property contract.
 if(!c.property_definitions.empty()) {
  if(c.property_definitions.size()!=type->properties.size())
   errors.push_back({ErrorCode::MissingField,c.id,"instance definitions differ from registered type"});
  for(const auto& def:c.property_definitions) {
   const auto* canonical=property(*type,def.name);
   if(!canonical||canonical->kind!=def.kind||
      canonical->default_value!=def.default_value||
      canonical->writable!=def.writable)
    errors.push_back({ErrorCode::MissingField,def.name,"property definition drift"});
  }
 }
 for(const auto& [name,value]:c.properties) {
  const auto* def=property(*type,name);
  if(!def)errors.push_back({ErrorCode::UnresolvedDependency,name,"unknown property"});
  else if(value.index()!=static_cast<std::size_t>(def->kind)||!finite(value))
   errors.push_back({ErrorCode::MissingField,name,"invalid property override"});
 }
 return errors;
}
std::expected<PropertyValue,RegistryDiagnostics> ComponentRegistry::resolve(
 const Component& component,std::string_view name) const {
 auto errors=validate_instance(component);
 if(!errors.empty())return std::unexpected(std::move(errors));
 const auto* type=find(component.type);
 const auto* def=property(*type,name);
 if(!def)return std::unexpected(RegistryDiagnostics{{ErrorCode::UnresolvedDependency,std::string(name),"property not found"}});
 auto it=component.properties.find(std::string(name));
 return it==component.properties.end()?def->default_value:it->second;
}
RegistryDiagnostics validate_bindings(
 const Project& project,const ComponentRegistry& registry,
 const std::vector<PropertyBinding>& bindings) {
 RegistryDiagnostics errors;
 std::map<std::string,const Component*> instances;
 for(const auto& module:project.modules)for(const auto& c:module.components)
  instances.emplace(c.id,&c);
 for(const auto& b:bindings) {
  auto src=instances.find(b.source_component),dst=instances.find(b.target_component);
  if(src==instances.end()||dst==instances.end()){
   errors.push_back({ErrorCode::UnresolvedDependency,"binding","component not found"});continue;
  }
  const auto* st=registry.find(src->second->type);
  const auto* dt=registry.find(dst->second->type);
  if(!st||!dt){errors.push_back({ErrorCode::UnresolvedDependency,"binding","type not registered"});continue;}
  const auto* s=property(*st,b.source_property);
  const auto* t=property(*dt,b.target_property);
  if(!s||!t){errors.push_back({ErrorCode::UnresolvedDependency,"binding","property not registered"});continue;}
  if(s->kind!=t->kind)
   errors.push_back({ErrorCode::MissingField,"binding","source and destination property types differ"});
  if(!t->writable)
   errors.push_back({ErrorCode::MissingField,"binding","destination property read-only"});
 }
 return errors;
}
} // namespace aelyxora
