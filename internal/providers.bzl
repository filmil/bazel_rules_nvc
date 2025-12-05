NVCInfo = provider(
    doc = "Information on how to run NVC for VHDL analysis, elaboration and sim",
    fields = [
      "analyzer",
      "artifacts_dir",
    ]
)

VHDLLibraryProvider = provider(
    doc = "",
    fields = [
        "libraries",
        "entities",
        "library_name",
        "library_dir"
    ]
)

ElaborateProvider = provider(
    doc = "TBD",
    fields = [
        "entity",
    ]
)

