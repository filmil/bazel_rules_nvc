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
#include <stdint.h>

std::unordered_map<int, InstanceState> instances;

extern "C" {

void log_to_file(const char* msg) {
    fprintf(stderr, "%s", msg);
    fflush(stderr);
}

void verilator_step_call(int32_t id) {
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

    sync_inputs(state);
    eval_model(state);
    sync_outputs(state);
}

void cleanup_callback() {
    log_to_file("[VPI] Cleanup callback executed!\n");
    instances.clear();
}

void (*vhpi_startup_routines[])(void) = {
    nullptr
};

} // extern "C"

