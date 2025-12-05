
# XXX: this should not be necessary, there's a ctx.files.foo attribute for target foo
def get_single_file_from(target):
    file_list = target.files.to_list()
    # assert 1 file
    return file_list[0]

