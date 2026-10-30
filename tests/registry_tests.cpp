#include "aelyxora/registry.hpp"
#include <cstdlib>
#include <iostream>
using namespace aelyxora;
static void require(bool v){if(!v)std::abort();}
int main(){
 ComponentRegistry r;
 ComponentType type{"ui.label","1.0.0",{{"text",PropertyKind::Text,std::string("Hello"),true},{"enabled",PropertyKind::Boolean,true,true}}};
 require(r.register_type(type).has_value());
 require(!r.register_type(type).has_value());
 Component label{"label","ui.label",{}};
 auto resolved=r.resolve(label,"text");
 require(resolved.has_value()&&std::get<std::string>(*resolved)=="Hello");
 label.properties["text"]=std::string("Changed");
 require(std::get<std::string>(*r.resolve(label,"text"))=="Changed");
 label.properties["text"]=true;
 require(!r.resolve(label,"text").has_value());
 label.properties["text"]=std::string("Changed");
 Project project;project.id="app.demo";project.name="Demo";
 Component second{"other","ui.label",{}};
 project.modules.push_back({"ui",{label,second}});
 require(validate_bindings(project,r,{{"label","text","other","text"}}).empty());
 require(!validate_bindings(project,r,{{"label","enabled","other","text"}}).empty());
 require(!validate_bindings(project,r,{{"unknown","text","other","text"}}).empty());
 std::cout<<"registry tests passed\n";
}
