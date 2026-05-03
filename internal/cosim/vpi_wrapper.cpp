#include "vhpi_user.h"
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
#include <dlfcn.h>

std::unordered_map<int, InstanceState> instances;

extern "C" {

void log_to_file(const char* msg) {
    fprintf(stderr, "%s", msg);
    fflush(stderr);
}

#ifndef VERILATOR_STEP_CALL
#define VERILATOR_STEP_CALL verilator_step_call
#endif

void VERILATOR_STEP_CALL(int32_t id) {
    char log_buf[256];
    snprintf(log_buf, sizeof(log_buf), "[VHPI] Step called with ID: %d\n", id);
    log_to_file(log_buf);

    if (instances.find(id) == instances.end()) {
        // We will just fall back to hardcoded prefix, or a better way:
        std::string path_prefix = ":top_tb:dut_inst"; // Hardcode for now, refine later

        char buf[256];
        snprintf(buf, sizeof(buf), "[VHPI] Initializing bindings for id %d with path_prefix %s\n", id, path_prefix.c_str());
        log_to_file(buf);

        init_bindings(id, instances[id], path_prefix);
    }

    InstanceState& state = instances[id];

    sync_inputs(state);
    eval_model(state);
    sync_outputs(state);
}

void (*vhpi_startup_routines[])(void) = {
    nullptr
};

} // extern "C"

