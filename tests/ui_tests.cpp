#include "aelyxora/ui.h"
#include <cstdlib>
#include <iostream>
static void check(bool v){if(!v)std::abort();}
int main(){
 const ax_ui_node good[]={{AX_UI_VSTACK,-1,1,0},{AX_UI_TEXT,0,2,0},{AX_UI_BUTTON,0,3,0}};
 check(ax_ui_validate(good,3)==AX_UI_OK);
 check(ax_ui_validate(nullptr,3)==AX_UI_ERR_ARGUMENT);
 check(ax_ui_validate(good,0)==AX_UI_ERR_ARGUMENT);
 const ax_ui_node root[]={{AX_UI_VSTACK,0,1,0}};
 check(ax_ui_validate(root,1)==AX_UI_ERR_ROOT);
 const ax_ui_node duplicate[]={{AX_UI_VSTACK,-1,1,0},{AX_UI_TEXT,0,1,0}};
 check(ax_ui_validate(duplicate,2)==AX_UI_ERR_KEY);
 const ax_ui_node leaf[]={{AX_UI_TEXT,-1,1,0},{AX_UI_BUTTON,0,2,0}};
 check(ax_ui_validate(leaf,2)==AX_UI_ERR_PARENT);
 const ax_ui_node invalid[]={{999,-1,1,0}};
 check(ax_ui_validate(invalid,1)==AX_UI_ERR_KIND);
 std::cout<<"declarative UI tree validation passed\n";
}
