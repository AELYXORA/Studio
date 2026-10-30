#include "aelyxora/ui.h"
#include <unordered_set>
extern "C" int32_t ax_ui_validate(const ax_ui_node* nodes,uint32_t count) {
 if(!nodes||count==0||count>4096)return AX_UI_ERR_ARGUMENT;
 if(nodes[0].parent!=-1)return AX_UI_ERR_ROOT;
 std::unordered_set<uint32_t> keys;
 for(uint32_t i=0;i<count;++i){
  const auto& n=nodes[i];
  if(n.kind<1||n.kind>4)return AX_UI_ERR_KIND;
  if(n.flags!=0)return AX_UI_ERR_ARGUMENT;
  if(n.key==0||!keys.insert(n.key).second)return AX_UI_ERR_KEY;
  if(i==0)continue;
  if(n.parent<0||static_cast<uint32_t>(n.parent)>=i)return AX_UI_ERR_PARENT;
  if(nodes[n.parent].kind>2)return AX_UI_ERR_PARENT;
 }
 return AX_UI_OK;
}
