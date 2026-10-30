#include "aelyxora/model.hpp"
#include <functional>
#include <cmath>
#include <set>
#include <unordered_map>
#include <unordered_set>
#include <utility>
namespace aelyxora {
namespace {
bool valid_id(std::string_view id) {
    if (id.empty() || id.size()>128) return false;
    for (unsigned char c : id)
        if (!((c>='a'&&c<='z')||(c>='A'&&c<='Z')||
              (c>='0'&&c<='9')||c=='_'||c=='-'||c=='.')) return false;
    return true;
}
}
std::vector<Diagnostic> validate(const Project& p) {
    std::vector<Diagnostic> errors;
    auto add=[&](ErrorCode c,std::string path,std::string msg) {
        errors.push_back({c,std::move(path),std::move(msg)});
    };
    if(p.schema_version!="0.1-draft")
        add(ErrorCode::UnsupportedSchema,"schemaVersion","unsupported schema");
    if(!valid_id(p.id)) add(ErrorCode::InvalidId,"projectId","invalid project ID");
    if(p.name.empty()) add(ErrorCode::MissingField,"name","name is required");
    std::unordered_set<std::string> ids;
    for(const auto& t:p.targets) {
        if(!valid_id(t.id)) add(ErrorCode::InvalidId,"targets","invalid target ID");
        if(t.backend.empty()) add(ErrorCode::MissingField,"targets","backend required");
        if(!ids.insert("target:"+t.id).second)
            add(ErrorCode::DuplicateId,"targets","duplicate target ID");
    }
    std::unordered_map<std::string,const Component*> components;
    for(const auto& m:p.modules) {
        if(!valid_id(m.id)) add(ErrorCode::InvalidId,"modules","invalid module ID");
        if(!ids.insert("module:"+m.id).second)
            add(ErrorCode::DuplicateId,"modules","duplicate module ID");
        for(const auto& c:m.components) {
            std::set<std::string> property_names;
            for(const auto& def:c.property_definitions) {
                if(def.name.empty() || !property_names.insert(def.name).second)
                    add(ErrorCode::DuplicateId,c.id,"duplicate or empty property name");
                if(def.default_value.index()!=static_cast<std::size_t>(def.kind))
                    add(ErrorCode::MissingField,c.id,"property default type mismatch");
                if(const auto* d=std::get_if<double>(&def.default_value);d && !std::isfinite(*d))
                    add(ErrorCode::MissingField,c.id,"nonfinite property default");
            }
            for(const auto& [name,value]:c.properties) {
                const PropertyDefinition* def=nullptr;
                for(const auto& candidate:c.property_definitions)
                    if(candidate.name==name) {def=&candidate;break;}
                if(!def || value.index()!=static_cast<std::size_t>(def->kind))
                    add(ErrorCode::MissingField,c.id,"undeclared property or type mismatch: "+name);
                if(const auto* d=std::get_if<double>(&value);d && !std::isfinite(*d))
                    add(ErrorCode::MissingField,c.id,"nonfinite property override");
            }
            if(!valid_id(c.id)) add(ErrorCode::InvalidId,"components","invalid component ID");
            if(c.type.empty()) add(ErrorCode::MissingField,c.id,"component type required");
            if(!components.emplace(c.id,&c).second)
                add(ErrorCode::DuplicateId,c.id,"duplicate component ID");
        }
    }
    for(const auto& [id,c]:components)
        for(const auto& dep:c->dependencies)
            if(!components.contains(dep))
                add(ErrorCode::UnresolvedDependency,id,"missing dependency: "+dep);
    std::unordered_map<std::string,int> states;
    std::function<void(const std::string&)> visit=[&](const std::string& id) {
        if(states[id]==2) return;
        if(states[id]==1) {add(ErrorCode::DependencyCycle,id,"dependency cycle");return;}
        states[id]=1;
        for(const auto& dep:components.at(id)->dependencies)
            if(components.contains(dep)) visit(dep);
        states[id]=2;
    };
    for(const auto& [id,_]:components) visit(id);
    return errors;
}
ChangeResult rename_component(Project& p,std::uint64_t expected,
                              std::string_view old_id,std::string new_id) {
    if(p.revision!=expected)
        return {false,{{ErrorCode::StaleRevision,"revision","stale project revision"}}};
    Project candidate=p;
    bool found=false;
    for(auto& m:candidate.modules) for(auto& c:m.components) {
        if(c.id==old_id) {c.id=new_id;found=true;}
        for(auto& dep:c.dependencies) if(dep==old_id) dep=new_id;
    }
    if(!found) return {false,{{ErrorCode::UnresolvedDependency,"component","component not found"}}};
    auto errors=validate(candidate);
    if(!errors.empty()) return {false,std::move(errors)};
    candidate.revision++;
    p=std::move(candidate);
    return {true,{}};
}
} // namespace aelyxora
