#include <vpi_user.h>
#ifdef VPI_BINDINGS_HEADER
#include VPI_BINDINGS_HEADER
#else
#include "vpi_bindings.hpp"
#endif
#include <unordered_map>
#include <iostream>
#include <string>
#include <cstdio>

std::unordered_map<int, InstanceState> instances;

extern "C" {

void log_to_file(const char* msg) {
    fprintf(stderr, "%s", msg);
    fflush(stderr);
}

PLI_INT32 verilator_step_call(char *user_data) {
    log_to_file("[VPI] verilator_step_call executed!\n");

    vpiHandle systfref = vpi_handle(vpiSysTfCall, nullptr);
    vpiHandle arg_iter = vpi_iterate(vpiArgument, systfref);
    if (!arg_iter) return 0;

    vpiHandle arg = vpi_scan(arg_iter);
    s_vpi_value val;
    val.format = vpiIntVal;
    vpi_get_value(arg, &val);
    int id = val.value.integer;
    vpi_free_object(arg_iter);

    if (instances.find(id) == instances.end()) {
        std::string path_prefix = "";
        vpiHandle callH = vpi_handle(vpiSysTfCall, nullptr);
        vpiHandle scopeH = vpi_handle(vpiScope, callH);
        if (scopeH) {
            path_prefix = vpi_get_str(vpiFullName, scopeH);
        } else {
            path_prefix = "top_tb.dut_inst"; // Fallback
        }

        char buf[256];
        snprintf(buf, sizeof(buf), "[VPI] Initializing bindings for id %d with path_prefix %s\n", id, path_prefix.c_str());
        log_to_file(buf);

        init_bindings(id, instances[id], path_prefix);
    }

    InstanceState& state = instances[id];

    char buf[256];
    snprintf(buf, sizeof(buf), "[VPI] Syncing inputs for id %d\n", id);
    log_to_file(buf);

    sync_inputs(state);
    eval_model(state);
    sync_outputs(state);

    return 0;
}

PLI_INT32 cleanup_callback(p_cb_data cb_data) {
    log_to_file("[VPI] Cleanup callback executed!\n");
    instances.clear();
    return 0;
}

void register_callbacks() {
    log_to_file("[VPI] register_callbacks executed!\n");

    s_cb_data cb_data;
    cb_data.reason = cbEndOfSimulation;
    cb_data.cb_rtn = cleanup_callback;
    cb_data.obj = nullptr;
    cb_data.time = nullptr;
    cb_data.value = nullptr;
    vpi_register_cb(&cb_data);

    s_vpi_systf_data tf_data;
    tf_data.type = vpiSysTask;
    tf_data.sysfunctype = 0;
    tf_data.tfname = "$verilator_step_call";
    tf_data.calltf = verilator_step_call;
    tf_data.compiletf = nullptr;
    tf_data.sizetf = nullptr;
    tf_data.user_data = nullptr;
    vpi_register_systf(&tf_data);
}

} // Close the previous extern "C" block

// Make sure it is exported cleanly
extern "C" {
PLI_DLLESPEC void (*vlog_startup_routines[])() = {
    register_callbacks,
    nullptr
};
}

