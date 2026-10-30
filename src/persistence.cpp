#include "aelyxora/persistence.hpp"
#include <boost/json.hpp>
#include <boost/json/src.hpp>
#include <fstream>
#include <iterator>
#include <limits>
#include <system_error>
#include <unordered_set>
namespace aelyxora {
namespace {
namespace j=boost::json;
using E=std::vector<Diagnostic>;
E error(ErrorCode c,std::string p,std::string m){return {{c,std::move(p),std::move(m)}};}
std::expected<const j::object*,E> object(const j::value& v,std::string p){
 if(!v.is_object())return std::unexpected(error(ErrorCode::MissingField,p,"expected object"));
 return &v.as_object();
}
std::expected<std::string,E> str(const j::object& o,const char* k){
 auto v=o.if_contains(k);if(!v||!v->is_string())return std::unexpected(error(ErrorCode::MissingField,k,"expected string"));
 return std::string(v->as_string().data(),v->as_string().size());
}
std::expected<const j::array*,E> arr(const j::object& o,const char* k){
 auto v=o.if_contains(k);if(!v||!v->is_array())return std::unexpected(error(ErrorCode::MissingField,k,"expected array"));
 return &v->as_array();
}
bool keys(const j::object& o,std::initializer_list<std::string_view> allowed){
 for(const auto& kv:o){bool ok=false;for(auto k:allowed)if(kv.key()==k)ok=true;if(!ok)return false;}return true;
}
}
LoadResult parse_project(std::string_view text){
 if(text.size()>4*1024*1024)return std::unexpected(error(ErrorCode::MissingField,"/","project too large"));
 boost::system::error_code ec;j::parse_options options;options.max_depth=64;
 auto parsed=j::parse(text,ec,{},options);
 if(ec)return std::unexpected(error(ErrorCode::MissingField,"/",ec.message()));
 auto root=object(parsed,"/");if(!root)return std::unexpected(root.error());
 const auto& o=**root;
 if(!keys(o,{"schemaVersion","projectId","name","revision","targets","modules"}))
  return std::unexpected(error(ErrorCode::MissingField,"/","unknown key"));
 Project p;
 auto version=str(o,"schemaVersion");if(!version)return std::unexpected(version.error());p.schema_version=*version;
 auto id=str(o,"projectId");if(!id)return std::unexpected(id.error());p.id=*id;
 auto name=str(o,"name");if(!name)return std::unexpected(name.error());p.name=*name;
 if(auto v=o.if_contains("revision")){
  if(v->is_uint64())p.revision=v->as_uint64();
  else if(v->is_int64()&&v->as_int64()>=0)p.revision=static_cast<std::uint64_t>(v->as_int64());
  else return std::unexpected(error(ErrorCode::MissingField,"revision","expected nonnegative integer"));
 }
 auto targets=arr(o,"targets");if(!targets)return std::unexpected(targets.error());
 for(const auto& v:**targets){
  auto t=object(v,"targets");if(!t)return std::unexpected(t.error());
  if(!keys(**t,{"id","backend"}))return std::unexpected(error(ErrorCode::MissingField,"targets","unknown key"));
  auto id=str(**t,"id"),backend=str(**t,"backend");
  if(!id)return std::unexpected(id.error());if(!backend)return std::unexpected(backend.error());
  p.targets.push_back({*id,*backend});
 }
 auto modules=arr(o,"modules");if(!modules)return std::unexpected(modules.error());
 for(const auto& v:**modules){
  auto m=object(v,"modules");if(!m)return std::unexpected(m.error());
  if(!keys(**m,{"id","components"}))return std::unexpected(error(ErrorCode::MissingField,"modules","unknown key"));
  auto id=str(**m,"id");if(!id)return std::unexpected(id.error());
  Module module;module.id=*id;
  auto components=arr(**m,"components");if(!components)return std::unexpected(components.error());
  for(const auto& w:**components){
   auto c=object(w,"components");if(!c)return std::unexpected(c.error());
   if(!keys(**c,{"id","type","dependencies"}))return std::unexpected(error(ErrorCode::MissingField,"components","unknown key"));
   auto cid=str(**c,"id"),type=str(**c,"type");
   if(!cid)return std::unexpected(cid.error());if(!type)return std::unexpected(type.error());
   Component component;component.id=*cid;component.type=*type;
   if(c.value()->if_contains("dependencies")){
    auto deps=arr(**c,"dependencies");if(!deps)return std::unexpected(deps.error());
    std::unordered_set<std::string> seen;
    for(const auto& dep:**deps){
     if(!dep.is_string())return std::unexpected(error(ErrorCode::MissingField,"dependencies","expected string"));
     std::string d(dep.as_string().data(),dep.as_string().size());
     if(!seen.insert(d).second)return std::unexpected(error(ErrorCode::DuplicateId,"dependencies","duplicate dependency"));
     component.dependencies.push_back(std::move(d));
    }
   }
   module.components.push_back(std::move(component));
  }
  p.modules.push_back(std::move(module));
 }
 auto errors=validate(p);if(!errors.empty())return std::unexpected(std::move(errors));
 return p;
}
std::expected<std::string,E> serialize_project(const Project& p){
 auto errs=validate(p);if(!errs.empty())return std::unexpected(std::move(errs));
 j::object root;
 root["schemaVersion"]=p.schema_version;root["projectId"]=p.id;root["name"]=p.name;root["revision"]=p.revision;
 j::array targets;
 for(const auto& t:p.targets){j::object o;o["id"]=t.id;o["backend"]=t.backend;targets.push_back(std::move(o));}
 root["targets"]=std::move(targets);
 j::array modules;
 for(const auto& m:p.modules){
  j::object mo;mo["id"]=m.id;j::array components;
  for(const auto& c:m.components){
   j::object co;co["id"]=c.id;co["type"]=c.type;j::array deps;
   for(const auto& d:c.dependencies)deps.emplace_back(j::string(d));
   co["dependencies"]=std::move(deps);components.push_back(std::move(co));
  }
  mo["components"]=std::move(components);modules.push_back(std::move(mo));
 }
 root["modules"]=std::move(modules);
 return j::serialize(root)+"\n";
}
LoadResult load_project(const std::filesystem::path& path){
 std::ifstream in(path,std::ios::binary);
 if(!in)return std::unexpected(error(ErrorCode::MissingField,path.string(),"open failed"));
 std::string text(4*1024*1024+1,'\0');
 in.read(text.data(),static_cast<std::streamsize>(text.size()));text.resize(static_cast<size_t>(in.gcount()));
 if(in.bad())return std::unexpected(error(ErrorCode::MissingField,path.string(),"read failed"));
 return parse_project(text);
}
SaveResult save_project(const std::filesystem::path& path,const Project& p,std::optional<std::uint64_t> expected){
 namespace fs=std::filesystem;
 auto text=serialize_project(p);if(!text)return std::unexpected(text.error());
 if(expected){
  if(*expected==std::numeric_limits<std::uint64_t>::max()||p.revision!=*expected+1)
   return std::unexpected(error(ErrorCode::StaleRevision,path.string(),"new revision must equal expected + 1"));
 }else if(p.revision!=0)
  return std::unexpected(error(ErrorCode::StaleRevision,path.string(),"new project revision must be zero"));
 // Cooperative writer lock. A stale lock requires explicit recovery by the user.
 auto lock=path;lock+=".aelyxora-lock";
 std::error_code ec;
 if(!fs::create_directory(lock,ec))
  return std::unexpected(error(ErrorCode::StaleRevision,lock.string(),ec ? ec.message() : "project locked"));
 struct Guard {
  fs::path p;
  ~Guard(){std::error_code e;fs::remove(p,e);}
 } guard{lock};
 auto read_bytes=[&]()->std::expected<std::string,E> {
  std::ifstream in(path,std::ios::binary);
  if(!in)return std::unexpected(error(ErrorCode::MissingField,path.string(),"open failed"));
  std::string bytes((std::istreambuf_iterator<char>(in)),std::istreambuf_iterator<char>());
  if(in.bad())return std::unexpected(error(ErrorCode::MissingField,path.string(),"read failed"));
  return bytes;
 };
 std::optional<std::string> old;
 if(expected){
  old=read_bytes();if(!old)return std::unexpected(old.error());
  auto existing=parse_project(*old);if(!existing)return std::unexpected(existing.error());
  if(existing->revision!=*expected)
   return std::unexpected(error(ErrorCode::StaleRevision,path.string(),"revision conflict"));
 }else if(fs::exists(path,ec)||ec)
  return std::unexpected(error(ErrorCode::StaleRevision,path.string(),"create requires absent destination"));
 auto tmp=path;tmp+=".aelyxora-stage";
 if(fs::exists(tmp,ec)||ec)
  return std::unexpected(error(ErrorCode::StaleRevision,tmp.string(),"staging exists; inspect before recovery"));
 {
  std::ofstream out(tmp,std::ios::binary|std::ios::trunc);
  if(!out)return std::unexpected(error(ErrorCode::MissingField,tmp.string(),"staging open failed"));
  out.write(text->data(),static_cast<std::streamsize>(text->size()));
  out.flush();if(!out){out.close();fs::remove(tmp,ec);return std::unexpected(error(ErrorCode::MissingField,tmp.string(),"write failed"));}
 }
 // Guard against external edits made while this writer prepared the output.
 // This comparison is not a cross-process atomic compare-and-swap.
 if(expected){
  auto current=read_bytes();
  if(!current||*current!=*old){
   fs::remove(tmp,ec);
   return std::unexpected(error(ErrorCode::StaleRevision,path.string(),"file changed during save"));
  }
 }else if(fs::exists(path,ec)||ec){
  fs::remove(tmp,ec);
  return std::unexpected(error(ErrorCode::StaleRevision,path.string(),"destination appeared during create"));
 }
 fs::rename(tmp,path,ec);
 if(ec){
  // In particular, do not delete existing Windows destination to force rename:
  // doing so would lose atomic replacement semantics.
  std::error_code cleanup;fs::remove(tmp,cleanup);
  return std::unexpected(error(ErrorCode::MissingField,path.string(),"replacement failed: "+ec.message()));
 }
 return {};
}
}
