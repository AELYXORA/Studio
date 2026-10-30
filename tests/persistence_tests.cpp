#include "aelyxora/persistence.hpp"
#include <cstdlib>
#include <iostream>
using namespace aelyxora;
static void check(bool value){if(!value)std::abort();}
int main(){
 const std::string source=R"({"schemaVersion":"0.1-draft","projectId":"app.test","name":"Test","targets":[{"id":"desktop","backend":"qt-qml"}],"modules":[{"id":"m","components":[{"id":"a","type":"ui.label"}]}]})";
 auto p=parse_project(source);check(p.has_value());
 p->modules[0].components[0].property_definitions.push_back({"title",PropertyKind::Text,std::string("Default"),true});
 p->modules[0].components[0].properties.emplace("title",std::string("Saved"));
 auto encoded=serialize_project(*p);check(encoded.has_value());
 auto roundtrip=parse_project(*encoded);check(roundtrip.has_value()&&roundtrip->id==p->id);
 check(roundtrip->modules[0].components[0].property_definitions.size()==1);
 check(std::get<std::string>(roundtrip->modules[0].components[0].properties.at("title"))=="Saved");
 check(!parse_project(R"({"schemaVersion":"0.1-draft","projectId":"x","name":"x","targets":[],"modules":[{"id":"m","components":[{"id":"a","type":"ui.label","propertyDefinitions":[{"name":"title","kind":"text","default":"ok"}],"properties":{"title":false}}]}]})").has_value());
 check(!parse_project("not json").has_value());
 check(!parse_project(R"({"schemaVersion":"future"})").has_value());
 check(!parse_project(R"({"schemaVersion":"0.1-draft","projectId":"x","name":"x","targets":[],"modules":[],"unexpected":1})").has_value());
 check(!parse_project(R"({"schemaVersion":"0.1-draft","projectId":"bad id","name":"x","targets":[],"modules":[]})").has_value());
 check(!parse_project(R"({"schemaVersion":"0.1-draft","projectId":"x","name":"x","revision":-1,"targets":[],"modules":[]})").has_value());
 check(!parse_project(R"({"schemaVersion":"0.1-draft","projectId":"x","name":"x","targets":[],"modules":[{"id":"m","components":[{"id":"a","type":"x","dependencies":["b","b"]},{"id":"b","type":"x"}]}]})").has_value());
 check(!parse_project(R"({"schemaVersion":"0.1-draft","projectId":"x","name":"x","targets":[],"modules":[{"id":"m","components":[{"id":"a","type":"x","dependencies":["a"]}]}]})").has_value());
 auto dir=std::filesystem::temp_directory_path()/"aelyxora-persistence-tests";
 std::filesystem::create_directories(dir);
 auto file=dir/"project.aelyxora.json";
 std::filesystem::remove(file);std::filesystem::remove(file.string()+".tmp");std::filesystem::remove(file.string()+".aelyxora-stage");std::filesystem::remove_all(file.string()+".aelyxora-lock");
 check(save_project(file,*p).has_value());
 check(!save_project(file,*p).has_value());
 auto loaded=load_project(file);check(loaded.has_value()&&loaded->revision==0);
 loaded->revision=1;check(save_project(file,*loaded,0).has_value());
 check(!save_project(file,*p,0).has_value());
 // Non-monotonic revision and cooperative lock are rejected without modifying the file.
 check(!save_project(file,*loaded,1).has_value());
 auto lock=file;lock+=".aelyxora-lock";
 std::filesystem::create_directory(lock);
 auto updated=*loaded;updated.revision=2;
 check(!save_project(file,updated,1).has_value());
 std::filesystem::remove(lock);
 // Modified content with unchanged revision is still conflict-detected only during a save,
 // not across independent writers that ignore the cooperative lock.
 check(save_project(file,updated,1).has_value());
 check(!save_project(file,updated,1).has_value());
 auto after=load_project(file);check(after.has_value()&&after->revision==2);
 std::filesystem::remove(file);std::filesystem::remove(dir);
 std::cout<<"persistence tests passed\n";
}
