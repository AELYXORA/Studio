#ifndef AELYXORA_UI_H
#define AELYXORA_UI_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
/* Stable draft C ABI. No pointers stored by the validator. */
typedef struct ax_ui_node {
    uint32_t kind;          /* 1=VStack, 2=HStack, 3=Text, 4=Button */
    int32_t parent;         /* -1 for root, otherwise previous node index */
    uint32_t key;           /* unique nonzero identity within a tree */
    uint32_t flags;         /* reserved; must be zero */
} ax_ui_node;
enum { AX_UI_VSTACK=1, AX_UI_HSTACK=2, AX_UI_TEXT=3, AX_UI_BUTTON=4 };
enum { AX_UI_OK=0, AX_UI_ERR_ARGUMENT=1, AX_UI_ERR_ROOT=2,
       AX_UI_ERR_PARENT=3, AX_UI_ERR_KIND=4, AX_UI_ERR_KEY=5 };
/* Node list must be preorder; parents appear before children.
   Root is node 0 and has parent=-1. Count is 1..4096. */
int32_t ax_ui_validate(const ax_ui_node* nodes, uint32_t count);
#ifdef __cplusplus
}
#endif
#endif
