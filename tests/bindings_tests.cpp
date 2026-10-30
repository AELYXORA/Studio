#include "aelyxora/bindings.hpp"
#include <cstdlib>
#include <iostream>
using namespace aelyxora;
static void require(bool ok){if(!ok)std::abort();}
int main(){
 ComponentRegistry registry;
 require(registry.register_type({"ui.text","1.0.0",{{"text",PropertyKind::Text,std::string("default"),true},{"visible",PropertyKind::Boolean,true,true}}}).has_value());
 Project project;project.id="app.bindings";project.name="Bindings";
 Component a{"a","ui.text",{}},b{"b","ui.text",{}},c{"c","ui.text",{}};
 a.properties["text"]=std::string("Hello");
 project.modules.push_back({"main",{a,b,c}});
 const std::vector<PropertyBinding> chain={{"a","text","b","text"},{"b","text","c","text"}};
 require(propagate_bindings(project,registry,chain,0).has_value());
 require(project.revision==1);
 require(std::get<std::string>(project.modules[0].components[2].properties.at("text"))=="Hello");
 const auto stable=project.revision;
 require(!propagate_bindings(project,registry,chain,0).has_value());
 require(project.revision==stable);
 const std::vector<PropertyBinding> cycle={{"a","text","b","text"},{"b","text","a","text"}};
 require(!propagate_bindings(project,registry,cycle,stable).has_value());
 require(project.revision==stable);
 const std::vector<PropertyBinding> conflict={{"a","text","c","text"},{"b","text","c","text"}};
 require(!propagate_bindings(project,registry,conflict,stable).has_value());
 require(project.revision==stable);
 const std::vector<PropertyBinding> mismatch={{"a","text","b","visible"}};
 require(!propagate_bindings(project,registry,mismatch,stable).has_value());
 require(project.revision==stable);
 require(propagate_bindings(project,registry,{},stable).has_value());
 require(project.revision==stable);
 std::cout<<"binding contract tests passed\n";
}
