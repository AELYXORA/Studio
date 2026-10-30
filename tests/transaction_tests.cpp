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
    std::cout<<"transaction tests passed\n";
}
