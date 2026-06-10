load("//internal:utils.bzl", "get_single_file_from")
load("//internal:providers.bzl", "NVCInfo", "VHDLLibraryProvider", "ElaborateProvider")
load("//internal:toolchain.bzl",
     _NVC_TOOLCHAIN_TYPE = "NVC_TOOLCHAIN_TYPE",
     _NVC_WRAPPER = "NVC_WRAPPER",
    _VHDL_STANDARD_DEFAULT = "VHDL_STANDARD_DEFAULT",
    _nvc_toolchain = "nvc_toolchain")


load("//internal:nvc_vhdl_library.bzl", _nvc_vhdl_library = "nvc_vhdl_library")
load("//internal:nvc_vhdl_elaborate.bzl", _nvc_vhdl_elaborate = "nvc_vhdl_elaborate")
load("//internal:nvc_vhdl_run.bzl", _nvc_vhdl_run = "nvc_vhdl_run")
load("//internal:macros.bzl", _wave_view = "wave_view")
load("//internal:produce_waveform.bzl", _produce_waveform = "produce_waveform")
load("//internal:nvc_vhdl_test.bzl", _nvc_vhdl_test = "nvc_vhdl_test")
load("//internal:extract_file.bzl", _extract_file = "extract_file")


# The main API

nvc_toolchain = _nvc_toolchain

nvc_vhdl_library = _nvc_vhdl_library

nvc_vhdl_elaborate = _nvc_vhdl_elaborate

nvc_vhdl_run = _nvc_vhdl_run

produce_waveform = _produce_waveform

extract_file = _extract_file

nvc_vhdl_test = _nvc_vhdl_test

# Macros

wave_view = _wave_view

