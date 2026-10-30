#include "aelyxora/transaction.hpp"
#include <cstdlib>
#include <iostream>
using namespace aelyxora;
static void require(bool test) { if(!test) std::abort(); }
int main() {
    Project p; p.id="app.customerdesk";p.name="CustomerDesk";
    p.targets.push_back({"desktop","qt-qml"});
    p.modules.push_back({"crm",{{"customer","data.repository",{}},{"list","ui.list",{"customer"}}}});
    auto r=apply(p,{0,{RenameComponent{"customer","clients"},SetProjectName{"CRM"}}});
    require(r.has_value()&&*r==1&&p.name=="CRM");
    require(p.modules[0].components[1].dependencies[0]=="clients");
    auto old=p;
    require(!apply(p,{0,{SetProjectName{"stale"}}}).has_value());
    require(!apply(p,{1,{SetProjectName{"Wrong"},RenameComponent{"clients","list"}}}).has_value());
    require(p.name==old.name&&p.revision==old.revision);
    require(!apply(p,{1,{}}).has_value());
    require(!apply(p,{1,{RenameComponent{"missing","x"}}}).has_value());
    require(!apply(p,{1,{SetProjectName{""}}}).has_value());
    require(apply(p,{1,{SetProjectName{"Updated"}}}).has_value());
    // Typed properties participate in model transactions and revision control.
    Project typed;typed.id="app.typed";typed.name="Typed";
    Component button{"submit","ui.button",{}};
    button.property_definitions.push_back({"title",PropertyKind::Text,std::string("Submit"),true});
    button.property_definitions.push_back({"locked",PropertyKind::Boolean,true,false});
    typed.modules.push_back({"ui",{button}});
    require(validate(typed).empty());
    require(apply(typed,{0,{SetComponentProperty{"submit","title",std::string("Save")}}}).has_value());
    require(typed.revision==1);
    require(std::get<std::string>(typed.modules[0].components[0].properties.at("title"))=="Save");
    require(!apply(typed,{1,{SetComponentProperty{"submit","title",true}}}).has_value());
    require(!apply(typed,{1,{SetComponentProperty{"submit","locked",false}}}).has_value());
    require(typed.revision==1);
    std::cout<<"transaction tests passed\n";
}
