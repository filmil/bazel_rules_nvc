#include "vpi_user.h"
#include "vpi_bindings.hpp"
#include <unordered_map>
#include <iostream>
#include <string>

std::unordered_map<int, InstanceState> instances;

extern "C" {

PLI_INT32 verilator_step_call(char *user_data) {
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
        std::string path_prefix = ":dut";
        init_bindings(id, instances[id], path_prefix);
    }

    InstanceState& state = instances[id];

    sync_inputs(state);
    eval_model(state);
    sync_outputs(state);

    return 0;
}

PLI_INT32 cleanup_callback(p_cb_data cb_data) {
    instances.clear();
    return 0;
}

void register_callbacks() {
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

void (*vlog_startup_routines[])() = {
    register_callbacks,
    nullptr
};

} // extern "C"
