#include "aelyxora/persistence.hpp"
#include <cstdlib>
#include <iostream>
using namespace aelyxora;
static void check(bool value){if(!value)std::abort();}
int main(){
 const std::string source=R"({"schemaVersion":"0.1-draft","projectId":"app.test","name":"Test","targets":[{"id":"desktop","backend":"qt-qml"}],"modules":[{"id":"m","components":[{"id":"a","type":"ui.label"}]}]})";
 auto p=parse_project(source);check(p.has_value());
 auto encoded=serialize_project(*p);check(encoded.has_value());
 auto roundtrip=parse_project(*encoded);check(roundtrip.has_value()&&roundtrip->id==p->id);
 check(!parse_project("not json").has_value());
 check(!parse_project(R"({"schemaVersion":"future"})").has_value());
 auto dir=std::filesystem::temp_directory_path()/"aelyxora-persistence-tests";
 std::filesystem::create_directories(dir);
 auto file=dir/"project.aelyxora.json";
 std::filesystem::remove(file);std::filesystem::remove(file.string()+".tmp");
 check(save_project(file,*p).has_value());
 check(!save_project(file,*p).has_value());
 auto loaded=load_project(file);check(loaded.has_value()&&loaded->revision==0);
 loaded->revision=1;check(save_project(file,*loaded,0).has_value());
 check(!save_project(file,*p,0).has_value());
 auto after=load_project(file);check(after.has_value()&&after->revision==1);
 std::filesystem::remove(file);std::filesystem::remove(dir);
 std::cout<<"persistence tests passed\n";
}
