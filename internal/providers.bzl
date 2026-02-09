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
        "library_dir": """string: The container directory where library is located.
        Due to the way nvc works - it won't create a library in a dir that already exists,
        we have to have a container dir, which contains the library instead. So the actual
        library directory would be $library_dir/$library_name. Sigh.
        """,
        "includes": "List[string]: list of directories to include for verilog",
    },
)

ElaborateProvider = provider(
    doc = "TBD",
    fields = [
        "entity",
    ]
)

