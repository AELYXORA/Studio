#include "aelyxora/bindings.hpp"
#include <algorithm>
#include <limits>
#include <map>
#include <set>
#include <string>
#include <utility>
namespace aelyxora {
namespace {
using Node=std::pair<std::string,std::string>;
Node source(const PropertyBinding& b){return {b.source_component,b.source_property};}
Node target(const PropertyBinding& b){return {b.target_component,b.target_property};}
Component* find_component(Project& project,const std::string& id){
 for(auto& module:project.modules)for(auto& c:module.components)if(c.id==id)return &c;
 return nullptr;
}
}
BindingResult propagate_bindings(Project& project,const ComponentRegistry& registry,
 const std::vector<PropertyBinding>& bindings,std::uint64_t expected_revision){
 if(project.revision!=expected_revision)
  return std::unexpected(RegistryDiagnostics{{ErrorCode::StaleRevision,"revision","stale project revision"}});
 if(project.revision==std::numeric_limits<std::uint64_t>::max())
  return std::unexpected(RegistryDiagnostics{{ErrorCode::StaleRevision,"revision","revision overflow"}});
 auto diagnostics=validate(project);
 if(!diagnostics.empty())return std::unexpected(std::move(diagnostics));
 diagnostics=validate_bindings(project,registry,bindings);
 if(!diagnostics.empty())return std::unexpected(std::move(diagnostics));
 std::map<Node,std::vector<Node>> edges;
 std::map<Node,std::size_t> indegree;
 std::set<Node> destinations;
 for(const auto& b:bindings){
  const auto s=source(b),t=target(b);
  if(!destinations.insert(t).second)
   return std::unexpected(RegistryDiagnostics{{ErrorCode::DuplicateId,t.first+"."+t.second,"multiple writers for binding destination"}});
  edges[s].push_back(t);
  indegree.try_emplace(s,0);
  ++indegree[t];
 }
 std::set<Node> ready;
 for(const auto& [node,degree]:indegree)if(degree==0)ready.insert(node);
 std::vector<Node> order;
 while(!ready.empty()){
  Node node=*ready.begin();ready.erase(ready.begin());order.push_back(node);
  for(const auto& out:edges[node])if(--indegree[out]==0)ready.insert(out);
 }
 if(order.size()!=indegree.size())
  return std::unexpected(RegistryDiagnostics{{ErrorCode::DependencyCycle,"bindings","reactive binding cycle"}});
 // Validate and evaluate against a detached snapshot. Failed evaluations do not modify the project.
 Project candidate=project;
 std::map<Node,Node> incoming;
 for(const auto& b:bindings)incoming.emplace(target(b),source(b));
 for(const auto& node:order){
  const auto it=incoming.find(node);
  if(it==incoming.end())continue;
  const auto* src=find_component(candidate,it->second.first);
  auto* dst=find_component(candidate,node.first);
  if(!src||!dst)
   return std::unexpected(RegistryDiagnostics{{ErrorCode::UnresolvedDependency,"bindings","component disappeared"}});
  auto value=registry.resolve(*src,it->second.second);
  if(!value)return std::unexpected(value.error());
  dst->properties[node.second]=*value;
  auto errors=registry.validate_instance(*dst);
  if(!errors.empty())return std::unexpected(std::move(errors));
 }
 auto errors=validate(candidate);
 if(!errors.empty())return std::unexpected(std::move(errors));
 if(!bindings.empty()){
  candidate.revision++;
  project=std::move(candidate);
 }
 return {};
}
}
