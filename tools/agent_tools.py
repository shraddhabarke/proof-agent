import subprocess
import os
import time
from autogen_core.tools import FunctionTool



def compile_fstar_code(code_str:str) -> str:
    """
    Compiles a given F* code string using fstar.exe.
    :param code_str: The F* code as a string.
    :return: The output from the fstar.exe compilation process.
    """
    # test for now, since the module name must match the file name
    file_name = f"Test.fst"
    directory = "temp_files"
    #in root directory
    os.makedirs(directory, exist_ok=True)
    print(os.getcwd())
    # Write the code to a .fst file
    file_path = os.path.join(directory, file_name)
    with open(file_path, 'w') as f:
        f.write(code_str)

    # Get the path to fstar.exe from the environment variable
    fstar_path = os.getenv('FSTAR_PATH')
    if not fstar_path:
        raise EnvironmentError("FSTAR_PATH environment variable is not set.")

    # Compile the .fst file using fstar.exe
    try:
        result = subprocess.run([fstar_path, file_path], capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"An error occurred: {e.stderr}"


# result = compile_fstar_code("""
# module Test
# let rec f x =
#     if x = 0 then 0
#     else x + f (x - 1)
# """)
# print(result)


