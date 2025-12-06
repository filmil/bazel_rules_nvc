NVCInfo = provider(
    doc = "Information on how to run NVC for VHDL analysis, elaboration and sim",
    fields = [
      "analyzer",
      "artifacts_dir",
    ]
)

VHDLLibraryProvider = provider(
    doc = "Contains the information about the binary files in this library.",
    fields = {
        "libraries": "List[(string, File)]: a mapping from a library name to dir location, " +
        "contains both this library and deps and does not repeat keys",
        "entities": "List[string]: The entities emmphasized in this library.",
        "library_name": "string: The name of the library such as `ieee`",
        "library_dir": "string: The directory where the library is located.",
    },
)

ElaborateProvider = provider(
    doc = "TBD",
    fields = [
        "entity",
    ]
)

