#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define PLI_INT32 int32_t
#define PLI_BYTE8 char

#define vpiSysTfCall 1
#define vpiArgument 2
#define vpiIntVal 3
#define vpiSysTask 4
#define vpiNoDelay 5

#define cbEndOfSimulation 6

typedef struct t_vpi_value {
    PLI_INT32 format;
    union {
        PLI_INT32 integer;
    } value;
} s_vpi_value, *p_vpi_value;

typedef struct t_cb_data {
    PLI_INT32 reason;
    PLI_INT32 (*cb_rtn)(struct t_cb_data *);
    void *obj;
    void *time;
    void *value;
    void *user_data;
} s_cb_data, *p_cb_data;

typedef struct t_vpi_systf_data {
    PLI_INT32 type;
    PLI_INT32 sysfunctype;
    const char *tfname;
    PLI_INT32 (*calltf)(char *);
    PLI_INT32 (*compiletf)(char *);
    PLI_INT32 (*sizetf)(char *);
    char *user_data;
} s_vpi_systf_data, *p_vpi_systf_data;

typedef void* vpiHandle;

// Mock VPI functions
inline vpiHandle vpi_handle(PLI_INT32 type, vpiHandle refHandle) { return nullptr; }
inline vpiHandle vpi_iterate(PLI_INT32 type, vpiHandle refHandle) { return nullptr; }
inline vpiHandle vpi_scan(vpiHandle iterator) { return nullptr; }
inline void vpi_get_value(vpiHandle expr, p_vpi_value value_p) { if(value_p) value_p->value.integer = 1; }
inline vpiHandle vpi_put_value(vpiHandle object, p_vpi_value value_p, void *time_p, PLI_INT32 flags) { return nullptr; }
inline PLI_INT32 vpi_free_object(vpiHandle object) { return 1; }
inline vpiHandle vpi_handle_by_name(PLI_BYTE8 *name, vpiHandle scope) { return nullptr; }
inline vpiHandle vpi_register_cb(p_cb_data cb_data_p) { return nullptr; }
inline vpiHandle vpi_register_systf(p_vpi_systf_data systf_data_p) { return nullptr; }

#ifdef __cplusplus
}
#endif
