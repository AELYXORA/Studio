#include "aelyxora/model.hpp"
#include <cassert>
#include <iostream>
using namespace aelyxora;
int main() {
    Project p;
    p.id="app.customerdesk";p.name="CustomerDesk";
    p.targets.push_back({"desktop","qt-qml"});
    p.modules.push_back({"crm",{{"customers","data.repository",{}},
                                {"list","ui.record-list",{"customers"}}}});
    assert(validate(p).empty());
    auto r=rename_component(p,0,"customers","clients");
    assert(r.committed&&p.revision==1);
    assert(p.modules[0].components[1].dependencies[0]=="clients");
    const auto before=p;
    assert(!rename_component(p,0,"clients","broken").committed);
    assert(p.revision==before.revision);
    assert(!rename_component(p,1,"clients","list").committed);
    assert(p.modules[0].components[0].id=="clients");
    p.modules[0].components[0].dependencies.push_back("list");
    assert(!validate(p).empty());
    p.modules[0].components[0].dependencies.clear();
    p.modules[0].components[1].dependencies={"missing"};
    assert(!validate(p).empty());
    p.modules[0].components[1].dependencies={"clients"};
    p.schema_version="future";
    assert(!validate(p).empty());
    std::cout<<"model contract tests passed\n";
}
