#include "aelyxora/properties.hpp"
#include <cstdlib>
#include <iostream>
using namespace aelyxora;
static void require(bool b){if(!b)std::abort();}
int main(){
 std::vector<PropertyDefinition> defs={
  {"title",PropertyKind::Text,std::string("Untitled"),true},
  {"visible",PropertyKind::Boolean,true,true},
  {"width",PropertyKind::Integer,std::int64_t(100),true},
  {"internalId",PropertyKind::Text,std::string("fixed"),false}};
 PropertyInstance instance{"button.submit",{}};
 require(validate_properties(defs,instance).empty());
 require(set_property(instance,defs,"title",std::string("Submit")).has_value());
 require(std::get<std::string>(instance.values.at("title"))=="Submit");
 require(!set_property(instance,defs,"width",std::string("wide")).has_value());
 require(!instance.values.contains("width"));
 require(!set_property(instance,defs,"internalId",std::string("override")).has_value());
 require(!set_property(instance,defs,"missing",true).has_value());
 require(set_property(instance,defs,"width",std::int64_t(150)).has_value());
 require(!validate_properties({{"x",PropertyKind::Integer,std::string("bad"),true}},instance).empty());
 std::cout<<"property contract tests passed\n";
}
